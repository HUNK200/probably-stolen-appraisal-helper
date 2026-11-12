# 深空当铺 原生 Mod API 速查（调研笔记）

> 来源：社区指南 `dragonpan2/probably-stolen-modding`（67★，`ModdingGuide.zh-CN.md` 约 17 万字），该仓库链接出现在 Steam 讨论区「Where is the API?」中，回帖者为开发者账号 `questinggoosestudio`。
> 可信度：**高，但非官方文档**。所有签名以 `Assembly-CSharp.dll` 反编译为准，落地前需复核。
> 整理时间：2026-11-12

---

## 1. Mod 包结构

```
Probably Stolen/
├── Probably Stolen.exe
└── Mods/
    └── <ModId>/                  ← 文件夹名 = manifest 里的 ID
        ├── manifest.xml          ← 必需，缺失则整个文件夹被跳过
        ├── XxxMod.dll            ← 必需，必须在 <Assemblies> 里列出
        ├── Books/*.json          ← 纸质手册（可选）
        ├── Textures/{Paper,Items}/  ← 自制美术（可选）
        └── Localization/*.csv    ← 本地化（可选）
```

- 没有 MelonLoader，游戏自己加载。
- 文件夹内**任何未在 `<Assemblies>` 列出的 DLL 都会导致启用被拒**。
- 与游戏/框架同名的 DLL（`0Harmony`、`Assembly-CSharp`、`UnityEngine.*`、`Steamworks.NET`）会被拒绝。

## 2. manifest.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<Manifest>
  <ID>appraisal_helper</ID>
  <Name>Appraisal Helper</Name>
  <Author>HUNK200</Author>
  <ModVersion>0.1.0</ModVersion>
  <Description>鉴别时自动展示对应手册。</Description>
  <GameVersions>
    <Version>1.0.0</Version>
  </GameVersions>
  <Prerequisites />
  <Assemblies>
    <Assembly>AppraisalHelper.dll</Assembly>
  </Assemblies>
  <Capabilities />
</Manifest>
```

| 字段 | 规则 |
| --- | --- |
| `ID` | 只用 ASCII 字母数字 `_ - .`，不以 `.` 开头，≤64 字符；会变成磁盘文件夹名 |
| `GameVersions` | 四段式 `主.次.补丁.修订`；商店标签 `100-Rev14` = `1.0.0.14`；前缀匹配，`1.0.0` 覆盖全部修订；版本不匹配只警告，不阻止加载 |
| `Prerequisites` | 依赖的其它 Mod ID |
| `Assemblies` | 加载顺序即列表顺序 |
| `Capabilities` | **必填**，无特殊能力时写 `<Capabilities />` |

### Capabilities（能力声明）

可用值：`files`、`network`、`process`、`steam`、`steam-auth`、`window`。
正在淘汰、**2026-12-10 起一律拒绝**：`dynamic-code`、`native`、`reflection-external`、`threads`。

- 启用时游戏会扫描 DLL，**用到却没声明的能力 → 直接拒绝启用**。
- 自查命令：控制台 `mod-scan <modId>`。
- 对我们：只读写自己的文件要声明 `files`；调用 user32 / 多线程都是死路，必须避开。

## 3. Mod 生命周期

```csharp
public class ModEntry : IMod
{
    private ModLog log;
    public void Init(ModManifest manifest) => log = new ModLog(manifest);
    public void OnEnable()  { /* 订阅钩子 */ }
    public void OnDisable() { /* 取消订阅 */ }
}
```

- 三个方法都在**主菜单**阶段执行：此时没有存档、没有商店容器、没有游戏管理器。
- 因此在 `Init`/`OnEnable` 里**不能**读存档、生成物品、访问管理器，否则 `NullReferenceException`。
- 注册型操作（物品目录、掉落表、手册、起始方案……）必须在 `Init`/`OnEnable` 里做；访问运行时状态必须进钩子。

## 4. 钩子（`ModHook` 静态事件）——首选方案

> 官方立场：**钩子优先于 Harmony**。更快，且游戏更新时更不容易失效。

```csharp
ModHook.OnGameLoadedNormal += OnGameLoaded;   // 订阅
ModHook.OnGameLoadedNormal -= OnGameLoaded;   // 必须取消订阅
```

- 每个订阅者独立 try/catch，异常不会影响他人。
- 层级：顾客生成 `VeryEarly→Early→Normal→Late→VeryLate`；游戏载入 `Init→Early→Normal→Late`；其余多为 `Early`/`Late`。

与本项目相关的钩子：

| 钩子 | 用途 |
| --- | --- |
| `OnGameLoaded*` | 存档载入完成，可安全访问游戏对象 |
| `OnGenerateCustomer*` | 顾客生成，可拿到 `StoreClientManager`（含待鉴定物品？**待确认**） |
| `OnModItemDirectoryInit` | 注册自定义物品 |
| `OnCreateTooltip*` | 物品提示框；可追加行（R05 提示可能可复用） |
| `OnPaperOpened(string "modId:bookId", PaperUI)` | 手册面板构建完成，绑定按钮/元素 |
| `OnShutterOpened*` / `OnShutterClosed*` | 开店 / 关店 |
| `OnModConfigApplied` | 玩家在模组配置面板点了「应用」 |

**缺口：没有「开始鉴定某物品」的钩子。** R01/R02 的触发点大概率要用 Harmony 补丁，或轮询鉴定窗口状态。

## 5. 纸质手册系统（R03 的核心）

游戏内的「鉴定指南」就是纸质手册（paper book）：固定背景 + 原版纸张外框（关闭/缩放/翻页按钮、页码、翻纸音效）+ 页面元素。

- 手册放在 `Mods/<ModId>/Books/<id>.json`，可用游戏内编辑器制作（`F9` → Special → Modding Panel → Paper Editor）。
- **手册可以声明打开它的文档物品**，所以纯指南模组完全不用写物品代码。
- 手册字段里 `posX`/`posY` 是相对屏幕中心的偏移，**原版鉴定指南用 `-450, 0`——也就是屏幕左侧**。这直接满足 R03 的「固定在左侧」。
- `draggable`、`zoomable` 默认 true，可关。

```csharp
ModHelper.OpenPaper("appraisal_helper", "my_guide");   // 打开并置顶，返回 PaperUI
ModHelper.ClosePaper(...); ModHelper.IsPaperOpen(...); ModHelper.GetOpenPaper(...);
```

`PaperUI` 常用成员：`FlipTo(page)`、`CurrentPage`、`PageCount`、`Hide()`、`Close()`、`SetText(id, text)`、`SetSprite(id, key)`、`Get(id)`、`OnAction(name, cb)`、`OnPageShown(cb)`，事件 `PageShown` / `Closed` / `ActionFired`。

控制台命令：`paper-list`、`paper-open <id>`、`paper-close`、`paper-reload`、`paper-edit`、`paper-item <id>`。

## 6. 鉴定（Appraisal）API（R02 的核心）

```csharp
ModHelper.AddAppraisalItem(modId, itemId,
    itemId: "my_mod_id.antique_watch",
    unlockRank: AppraisalRankHelper.RANK_SENIOR,
    createRandom: CreateRandomWatch,
    getCorrectValue: item => item.GetTagReadonly(TAG).GetInt(),
    guideItemId: "my_mod_id.watch_guide");   // ← 该类型对应的「指南物品」
```

- 等级常量：`RANK_JUNIOR`(0) / `RANK_APPRAISER`(1) / `RANK_SENIOR`(2) / `RANK_MASTER`(3)；`ModHelper.GetAppraiserRank()`。
- 原版类型：`hand`（初级）、`ribwich`（鉴定师）、`plasma_fuel`（高级），大师级不解锁物品。
- `guideItemId` 在玩家晋升到该等级时发放——**说明「鉴定类型 → 指南物品」的映射游戏里本来就有**。R02 的匹配逻辑大概率可以直接复用这条既有关系，不必自己建表。

## 7. 其它可用设施

| 设施 | 说明 |
| --- | --- |
| `ModConfig` / `ModConfigWindow` | 模组配置面板（R04 键位可挂这里） |
| `ModDataStore` / `ModDataKey` | 模组持久化存储（记住上次翻到第几页） |
| `ModHelper.AddItem` / `SpawnItem` + `MoveItemTo*` | 生成与放置物品 |
| `ModHelper.GetLocalized(modId, key)` + `Localization/*.csv` | 本地化 |
| 控制台 `F8` / 开发菜单 `F9` | 需游戏 exe 旁存在空文件 `dev.txt` |
| `ModLog` | `new ModLog(manifest)`，`log.Log(...)` |

## 8. 构建

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>netstandard2.1</TargetFramework>
    <LangVersion>latest</LangVersion>
  </PropertyGroup>
  <ItemGroup>
    <Reference Include="Assembly-CSharp"><HintPath>..\..\Probably Stolen_Data\Managed\Assembly-CSharp.dll</HintPath><Private>false</Private></Reference>
    <Reference Include="UnityEngine"><HintPath>..\..\Probably Stolen_Data\Managed\UnityEngine.dll</HintPath><Private>false</Private></Reference>
    <Reference Include="UnityEngine.CoreModule"><HintPath>..\..\Probably Stolen_Data\Managed\UnityEngine.CoreModule.dll</HintPath><Private>false</Private></Reference>
    <Reference Include="0Harmony"><HintPath>..\..\Probably Stolen_Data\Managed\0Harmony.dll</HintPath><Private>false</Private></Reference>
  </ItemGroup>
</Project>
```

`dotnet build -c Release` → `bin/Release/netstandard2.1/Xxx.dll` → 连同 `manifest.xml` 一起放进 `Mods/<ID>/`。

## 9. 仍需确认

- 鉴定窗口打开的方法名与签名（用于 R01/R02 的触发点）
- 「待鉴定物品」的运行时对象结构，以及它是如何关联到 appraisal 类型的
- 手册物品（文档物品）在背包/文档柜中的类型与容器 API（R01 检索）
- 玩家「可操作的文档柜」如何判定
- 原版手册的 bookId / 物品 id 全集
- `ModHook` 上的完整事件列表（指南只列了部分，需反编译补齐）
- 游戏当前版本串（主菜单显示，形如 `100-Rev14`）

## 10. 参考

- 指南与示例：https://github.com/dragonpan2/probably-stolen-modding
- 开发者模板/文档工具：https://github.com/aamobe/probably-stolen-mod-dev
- 其它可参考 Mod 源码：`CharlesYWL/ProbablyStolen-ContainerWindowFinder`（窗口定位）、`Cs2Cr2O7/Probability`（物品分类筛选）、`infrahate/Probably-Stolen_Better-Nightly-Report`
