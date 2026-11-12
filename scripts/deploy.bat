@echo off
rem Copy the built mod and its manifest into the game's Mods folder.
rem
rem NOTE: this WRITES to the game directory. Run it yourself when you intend to deploy.
rem       Building (scripts\build.bat) never touches the game folder.
rem
rem Usage:
rem   scripts\deploy.bat
rem   set PS_GAME_DIR=D:\...\Probably Stolen
rem   scripts\deploy.bat
rem
rem ASCII-only on purpose: cmd.exe reads .bat with the OEM codepage (936 on zh-CN),
rem so UTF-8 Chinese text in a .bat gets garbled. Keep this file ASCII.
setlocal

set "GAME=%PS_GAME_DIR%"
if "%GAME%"=="" set "GAME=F:\Program Files (x86)\Steam\steamapps\common\Probably Stolen"

set "ROOT=%~dp0.."
set "DLL=%ROOT%\src\AppraisalHelper\bin\Release\netstandard2.1\AppraisalHelper.dll"
set "MANIFEST=%ROOT%\mod\manifest.xml"
set "TARGET=%GAME%\Mods\appraisal_helper"

if not exist "%GAME%\Probably Stolen.exe" goto no_game
if not exist "%DLL%" goto no_dll

if not exist "%TARGET%" mkdir "%TARGET%"
copy /y "%DLL%" "%TARGET%\" >nul
copy /y "%MANIFEST%" "%TARGET%\" >nul

echo [OK] Deployed to: %TARGET%
echo      Expected files: manifest.xml, AppraisalHelper.dll
echo      Next: launch game - Mods menu - enable Appraisal Helper - restart game.
exit /b 0

:no_game
echo [ERROR] Probably Stolen.exe not found under:
echo         %GAME%
echo         Set PS_GAME_DIR to your game folder, then run again.
exit /b 1

:no_dll
echo [ERROR] Build output missing:
echo         %DLL%
echo         Run scripts\build.bat first.
exit /b 1
