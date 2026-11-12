@echo off
rem 把编译产物和清单复制到游戏的 Mods 目录。
rem
rem 这是「写入游戏目录」的操作，只在你自己执行时发生；构建过程本身不会碰游戏目录。
rem
rem 用法：
rem   scripts\deploy.bat                使用默认游戏路径
rem   set PS_GAME_DIR=D:\...\Probably Stolen ^&^& scripts\deploy.bat
setlocal

set "GAME=%PS_GAME_DIR%"
if "%GAME%"=="" set "GAME=F:\Program Files (x86)\Steam\steamapps\common\Probably Stolen"

set "DLL=%~dp0..\src\AppraisalHelper\bin\Release\netstandard2.1\AppraisalHelper.dll"
set "MANIFEST=%~dp0..\mod\manifest.xml"
set "TARGET=%GAME%\Mods\appraisal_helper"

if not exist "%GAME%\Probably Stolen.exe" (
    echo [失败] 这个路径下没有 Probably Stolen.exe：%GAME%
    echo         请先设置 PS_GAME_DIR 再运行。
    exit /b 1
)
if not exist "%DLL%" (
    echo [失败] 找不到编译产物，请先运行 scripts\build.bat
    exit /b 1
)

if not exist "%TARGET%" mkdir "%TARGET%"
copy /y "%DLL%" "%TARGET%\" >nul
copy /y "%MANIFEST%" "%TARGET%\" >nul

echo [成功] 已部署到：%TARGET%
echo         里面应该有 manifest.xml 和 AppraisalHelper.dll 两个文件。
echo         下一步：启动游戏 → 模组菜单 → 启用 Appraisal Helper → 重启游戏。
exit /b 0
