# AGENTS.md

本文件是本仓库的 **AI 代理工作约定**。任何在本目录下工作的 AI 编码代理（Claude Code / Codex / Cursor / Copilot / 其他）在动手前都必须先读本文件，再读 `project.md`。

---

## 1. 项目是什么

为《深空当铺》制作的一个**辅助鉴别 Mod**。

核心价值：玩家鉴别物品时，Mod 自动在当前可访问的位置找到对应鉴别手册，并把**原版手册界面**固定在屏幕左侧展示，免去在鉴别界面与手册之间反复切换。

- 项目性质：兴趣项目，AI 辅助开发，需求驱动，不以学习编程为目标。
- 当前阶段：**需求梳理完成，尚未进入技术实现**。

## 2. 事实来源与优先级

| 优先级 | 文件 | 作用 |
| --- | --- | --- |
| 1 | `project.md` | 需求唯一来源（功能需求 R01–R05、设计原则、验收目标） |
| 2 | `AGENTS.md`（本文件） | 工程约定、协作流程 |
| 3 | 代码与注释 | 实现细节 |

规则：**两者冲突时以 `project.md` 为准**；如果 `project.md` 自身有歧义，先提问，不要自行裁决。
`project.md` 第 5 章「暂未确定的事项」是**未确认需求**，不得当成已定需求实现。

## 3. 硬性约束（任何改动都不得违反）

1. **不改原版规则**：不修改游戏的物品获取、交易、鉴别流程与判定逻辑。
2. **不做自动判定**：Mod 不识别物品等级、不替玩家做鉴定结论，只负责「把手册摆到眼前」。
3. **不凭空造物**：不生成、不复制、不伪造鉴别手册。
4. **访问范围受限**：只检索玩家背包 + 玩家当前可操作的文档柜，不扫描玩家无法访问的位置。
5. **原版界面优先**：复用原版手册的打开方式、排版与文本，不重新设计手册内容。
6. **不臆测游戏内部机制**：涉及游戏 API、数据结构、存档格式、UI 层级的任何假设，必须先确认（见 §4），再落代码。

## 4. 遇到这些点必须停下来提问

以下条目在 `project.md` 中明确标记为未确定。代理**不得**选一个看起来合理的方案就实现，应带着 2–3 个候选方案 + 影响说明去问用户：

- 同时持有多本手册、多本可能命中同一物体时的匹配规则
- 开始鉴别新物体时，已展示的旧手册如何处理
- 新物体没有对应手册时，旧界面如何处理（保留 / 清空 / 显示提示）
- 玩家手动关闭手册后，当前鉴别流程内是否自动重新打开
- 翻页是否循环、是否记忆上次阅读页
- 手册界面的尺寸、精确位置、出现/消失动画
- 快捷键默认键位与可配置方式
- 文档柜不可访问（距离过远 / 被锁 / 未打开）时的行为
- 是否还有其他「玩家可访问的存储位置」
- 是否需要接入原版通知系统，以及提示的措辞
- **技术栈相关**：游戏引擎、Mod 框架、加载方式、如何取得物品与手册数据、如何复用原版 UI

## 5. 协作流程

### 5.0 权限申请（硬性，优先于一切）

代理**默认的活动范围只有本仓库目录**。以下三类操作必须先说明「要做什么、为什么、影响范围」，**得到用户明确同意后**才能执行：

| 类别 | 需要申请的典型操作 |
| --- | --- |
| 仓库外的文件读写 | 扫描盘符定位游戏目录、读游戏根目录 / `MelonLoader/` / `UserData/`、写入或修改游戏目录内任何文件、读取 Steam 库或注册表 |
| 编译 | `dotnet build` / `dotnet restore` / 安装 SDK 或 NuGet 包 / 首次编译生成产物 |
| 验证 | 启动游戏、装 / 卸 MelonLoader、改配置后重启、读取 `MelonLoader/Latest.log`、任何进游戏观察的行为 |

补充约定：
- 申请里要写清楚**是只读还是写入**；只读操作也要申请，不要因为“不破坏”就跳过。
- 一次申请只覆盖**当次、当范围**，需求变化要重新申请。
- 仓库内的文件操作（写代码、写文档、本地 commit）不需要申请；`git push` 除外，按需确认。
- 未经同意就执行了上述操作，必须立刻如实报告，而不是事后补一句说明。

### 5.1 常规流程

1. **先问再做**：需求不清时先提问，不要用「合理的默认值」填补空白。
2. **先方案后代码**：非平凡改动先给出简要方案（改哪些文件、为什么），确认后再动手。
3. **小步提交**：一个提交只做一件事，提交信息使用中文，格式 `<type>: <简短描述>`（`feat` / `fix` / `docs` / `refactor` / `chore`）。
4. **对照验收**：每完成一个可演示的功能，逐条核对 `project.md` 第 6 章的验收目标。
5. **同步文档**：需求一旦变更，先改 `project.md`，再改代码；已被确认的「未确定事项」要从第 5 章移出并落到对应需求里。
6. **如实汇报**：无法验证的事情（尤其是需要进游戏里观察的行为）如实说明，不要把推测写成结论。

## 6. 工具链

### 6.1 已核实的事实（2026-11-12 实机检查游戏目录）

游戏根目录：`F:\Program Files (x86)\Steam\steamapps\common\Probably Stolen`

| 项 | 结论 | 依据 |
| --- | --- | --- |
| 游戏 | 《深空当铺：可能是偷的》/ Probably Stolen: Cyberpunk Shopkeeper Sim，Questing Goose Studio 开发，tinyBuild 发行 | Steam / indienova / GameLook |
| 引擎 | **Unity 2021.3.45f2** | exe 的 ProductVersion；根目录有 `UnityPlayer.dll` |
| 脚本后端 | **Mono**（不是 IL2CPP） | 存在 `MonoBleedingEdge/` 与 `_Data/Managed/Assembly-CSharp.dll`（4.8 MB），**没有** `GameAssembly.dll` |
| **原生 Mod 框架** | **游戏自带**，程序集内含 `ModLoader` / `ModScanner` / `ModReflect` / `ModManifest` / `IMod` 等类型 | 从 `Assembly-CSharp.dll` 字符串表提取，见 6.2 |
| Mod 目录 | 游戏根目录 `Mods/`（安装时自带，当前为空） | `ls` 实机确认 |
| 游戏内 Mod 面板 | 存在（`ModUIManager`、`ModEnablePromptUI`、`ModConfigWindow`） | 同上 |
| 游戏自带库 | `0Harmony.dll`、`DseCecil.dll`（Mono.Cecil）、DOTween、Newtonsoft.Json、QFSW.QC（控制台） | `Managed/` 目录列表 |

> **更正记录：** 先前依据社区 mod 仓库自述判定为「IL2CPP」。实机检查证明**本机这个正式版是 Mono**。该社区信息可能对应 Demo / Playtest 版本，或直接是错的。以实机为准。

### 6.2 游戏原生 Mod 框架（已从字符串表确认的类型）

| 类型 / 成员 | 推测职责 |
| --- | --- |
| `IMod`、`IModNameBytes`、`ModHelper`、`ModHook`、`ModLog` | Mod 入口接口与辅助 API |
| `ModLoader`、`ModScanner.EnumerateModFiles`、`ModReflect.ScopeAssemblies` | 扫描与加载 |
| `ModManifest`、`ParseManifestCore`、`manifest` | 清单解析（格式待确认，疑似 JSON） |
| `RunningPrerequisites`、`IsRunningPrerequisite`、`OrderByPrerequisites` | Mod 前置依赖排序 |
| `ModConfig`、`ModConfigWindow`、`ModHasSettings`、`ModEnableCheck`、`ModEnablePromptUI` | 配置面板与首次启用授权 |
| `ModDataStore`、`ModDataKey`、`ClearModData`、`ModDataFileExists` | 给 Mod 用的持久化存储 |
| `ModItemDirectory` | Mod 物品目录（疑似可注册物品） |
| `ModLootEntryJson`、`ModLootPatchJson`、`ModLootFileJson` | 以 JSON 打补丁修改掉落表 |
| `EnabledMods`、`LocalMods`、`ModAssemblies`、`ModFingerprint`、`ModIdOfAssembly` | 启用列表、程序集与指纹 |

**结论：优先做「原生 Mod」，不要用 MelonLoader。** 理由：不受加载器与游戏版本绑定影响；能直接复用游戏自己的配置面板与数据存储；符合项目「复用原版」的原则。

### 6.3 由此产生的硬性技术影响

1. **Mono 后端**：可以直接在工程里引用 `Probably Stolen_Data/Managed/Assembly-CSharp.dll`，用 Harmony（游戏自带 `0Harmony.dll`）打补丁。不需要 Cpp2IL / Il2CppInterop。
2. **目标框架用 `net472` 或 `netstandard2.1`**：Unity 2021.3 Mono 的运行时基于 .NET Framework 4.x API 面，不要用 `net6.0`/`net8.0` 以免加载失败。（待实测确认）
3. **版本绑定依旧存在**：游戏高频打补丁，`Assembly-CSharp.dll` 的签名会变。每次验证必须记录游戏版本号；用反射访问而非硬编码偏移。
4. **复用原版手册 UI 的现实路径**：优先「调用原版打开手册的方法，再把生成出来的界面挪到屏幕左侧 / 改锚点与缩放」，而不是自己重建布局。
5. **先读原生 API 再写代码**：`IMod` 的成员签名、manifest 格式必须反编译确认，不得凭类型名猜。

### 6.4 待确认（不要当成已知）

- `IMod` 接口成员与方法签名、manifest 的确切字段与文件名
- Mod 是「一个 DLL + 一个 manifest」还是「一个文件夹」
- 手册的运行时类型名、手册内容的数据结构
- 手册界面技术栈（UGUI / UI Toolkit / IMGUI）
- 鉴别流程的入口方法
- 游戏版本串（主菜单显示的那个，如 `100-REV3`）

### 6.5 构建与验证命令

- 目标框架：`netstandard2.1`（官方模板如此，Unity 2021.3 Mono 可直接加载）
- 构建：`dotnet build -c Release` → `bin/Release/netstandard2.1/<Name>.dll`
- 部署：DLL 与 `manifest.xml` 一起放进 `<游戏根目录>/Mods/<ModId>/`
- 调试：游戏 exe 旁放空文件 `dev.txt` → 游戏内 `F8` 控制台、`F9` 开发菜单
- 手册调试命令：`paper-list` / `paper-open <id>` / `paper-close` / `paper-reload`
- 能力自查：`mod-scan <ModId>`

### 6.6 参考资源

- **`docs/mod-api-notes.md`** —— 本项目的 API 速查笔记（包结构、manifest、生命周期、钩子、纸质手册、鉴定 API）。写代码前先读它。
- 社区指南（开发者账号在 Steam 讨论区贴出的链接）：https://github.com/dragonpan2/probably-stolen-modding
- 开发模板 + 文档工具：https://github.com/aamobe/probably-stolen-mod-dev

**两条硬性技术红线（来自框架的能力扫描器）：**

1. `Capabilities` 必须与实际行为一致，扫描器发现未声明能力会**直接拒绝启用**。我们默认 `<Capabilities />`；需要读写自己的文件时声明 `files`。
2. `native`、`threads`、`dynamic-code`、`reflection-external` **将于 2026-12-10 起一律拒绝**，不要在任何设计里依赖它们。

**优先级规则：钩子（`ModHook`）> Harmony 补丁。** 只有在没有对应钩子时才用 Harmony。


## 7. 代码与文档约定

- 文档、代码注释、提交信息统一使用**中文**；标识符（类名、变量名）使用英文。
- 文件编码 UTF-8，行尾 LF（由 `.gitattributes` 统一）。
- 目录划分建议（随技术栈确定后调整）：
  - `project.md` — 需求文档，位于根目录
  - `AGENTS.md` — 代理约定
  - `src/` — Mod 源码
  - `docs/` — 技术调研、游戏机制笔记、逆向结论
  - `assets/` — Mod 需要的贴图 / 本地化文件
- 不提交：构建产物、游戏本体文件、解包资源、个人配置、日志。

## 8. 需要代理主动维护的文件

- `project.md`：需求变化时更新，并更新文档版本号与「当前阶段」。
- `AGENTS.md`：工具链与目录结构确定后，补齐 §6 并修正 §7。
