# 编译与部署（可复现步骤）

> 目标：把这个仓库的源码变成游戏能加载的模组包。
> 全程只需要 .NET SDK，不需要 Unity、不需要 MelonLoader。

## 0. 环境检查

```bash
dotnet --version
```

本机实测：`9.0.312`。6.0 及以上都可以，官方指南写的是「6.0 或更高」。

## 1. 配置游戏路径

游戏路径写在根目录的 `Directory.Build.props` 里：

```xml
<GameDir Condition="'$(GameDir)' == ''">F:\Program Files (x86)\Steam\steamapps\common\Probably Stolen</GameDir>
```

三种改法，任选其一：

| 方式 | 做法 |
| --- | --- |
| 改文件 | 直接改上面那一行 |
| 环境变量（临时） | `set PS_GAME_DIR=D:\你的路径\Probably Stolen` |
| 命令行传入 | `dotnet build -c Release -p:GameDir="D:\你的路径\Probably Stolen"` |

判断标准：`<游戏目录>\Probably Stolen_Data\Managed\Assembly-CSharp.dll` 必须存在。

## 2. 编译

```bash
scripts\build.bat
```

等价于：

```bash
dotnet build src/AppraisalHelper/AppraisalHelper.csproj -c Release
```

产物：

```
src/AppraisalHelper/bin/Release/netstandard2.1/AppraisalHelper.dll
```

本机实测输出：

```
AppraisalHelper -> src\AppraisalHelper\bin\Release\netstandard2.1\AppraisalHelper.dll
    0 个警告
    0 个错误
```

> 编译只读游戏目录里的 DLL 作为引用，**不会写入游戏目录**。

## 3. 部署

```bash
scripts\deploy.bat
```

等价于手工做这两件事：

```bash
mkdir "<游戏目录>\Mods\appraisal_helper"
cp src/AppraisalHelper/bin/Release/netstandard2.1/AppraisalHelper.dll "<游戏目录>\Mods\appraisal_helper\"
cp mod/manifest.xml "<游戏目录>\Mods\appraisal_helper\"
```

最终结构必须是：

```
<游戏目录>\Mods\appraisal_helper\
├── manifest.xml
└── AppraisalHelper.dll
```

三个常见错误：

- **多套一层**：变成了 `Mods\appraisal_helper\appraisal_helper\...`，游戏找不到。
- **少 `manifest.xml`**：整个文件夹会被跳过，模组菜单里根本不出现。
- **文件夹里多放了 DLL**：任何没写进 `<Assemblies>` 的 DLL 都会让启用被拒绝。

## 4. 在游戏里启用

1. 启动游戏到主菜单。
2. 打开「模组」菜单，`Appraisal Helper` 会出现在**未启用**一栏。
3. 选中并点**启用**。这一步游戏会扫描 DLL 检查能力声明；通过后会移到已启用栏。
4. **重启游戏**——启用只在下一次启动生效。
5. 若被拒绝，会给出原因；在 `F8` 控制台（若能打开）运行 `mod-scan appraisal_helper` 查看详情。

> 反复重新编译时，游戏会认为 DLL 变了，可能要求再次审核。在模组详情面板里打开一次**开发者模式**，之后这个文件夹的每次重编译都会被信任。

## 5. 看日志

游戏自己会写日志，路径：

```
C:\Users\<用户名>\AppData\LocalLow\Questing Goose Studio\Probably Stolen\GameLog_YYYY-MM-DD_HH-MM-SS.txt
```

每次启动生成一个新文件，按时间排序取最新的那个即可。

`ModLog` 输出的行会带模组名前缀，例如：

```
[Appraisal Helper]: AppraisalHelper 已加载（Init）
```

> `F8` 控制台在本机打不开（VERSION 100-REV13），日志文件是更可靠的替代。

## 6. 卸载

删掉 `<游戏目录>\Mods\appraisal_helper\` 整个文件夹即可。

## 7. 一次性全流程（复制粘贴用）

```bash
# 在仓库根目录
scripts\build.bat && scripts\deploy.bat
```

然后启动游戏 → 模组菜单 → 启用 → 重启 → 看日志。

## 8. 踩过的坑

### 8.1 脚本里的中文变成乱码

现象：

```
[鎴愬姛] 宸查儴缃插埌锛?TARGET
'垙' 不是内部或外部命令
```

原因：`.bat` 文件是 UTF-8，而 `cmd.exe` 按系统 OEM 代码页（简体中文为 936 / GBK）读取批处理文本。多字节中文字符被拆错，甚至拼出非法命令名；`%TARGET%` 这类变量也会被截断成字面量。

处理：**两个 .bat 一律保持纯 ASCII**，中文说明只写在文档里。加 `chcp 65001` 或用 UTF-8 BOM 是另一种思路，但在部分 Windows 版本上会让后续行继续乱码，不采用。

自查命令（应无输出）：

```bash
grep -nP '[^\x00-\x7F]' scripts/*.bat
```

### 8.2 PowerShell 里的调用方式

PowerShell 用 `scripts\deploy.bat` 或 `.\scripts\deploy.bat` 都可以；git-bash 里要用 `scripts/deploy.bat`（正斜杠）。

### 8.3 验证记录

| 日期 | 验证内容 | 结果 |
| --- | --- | --- |
| 2026-11-12 | `scripts\build.bat` | 编译成功，0 警告 0 错误 |
| 2026-11-12 | `scripts\deploy.bat`（指向临时模拟目录） | 正确创建 `Mods\appraisal_helper\` 并拷入两个文件 |
| 2026-11-12 | `scripts\deploy.bat`（错误路径） | 输出 `[ERROR] Probably Stolen.exe not found`，退出码 1 |


### 8.4 首次进游戏验证（2026-11-12）

部署后启动游戏、在模组菜单启用、重启，日志出现：

```
[22:41:01] [Log] [Appraisal Helper]: 检测到存档载入完成，游戏对象可用
```

说明加载链路全部打通：DLL 被加载、能力扫描通过、`ModLog` 输出正常（中文无乱码）、`ModHook.OnGameLoadedNormal` 正常触发。

> 同一份日志里还看到已启用的第三方模组 `Smart Inventory Arrange`，后续做兼容性验证时要一并覆盖。
