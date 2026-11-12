@echo off
rem Build the mod.
rem Output: src\AppraisalHelper\bin\Release\netstandard2.1\AppraisalHelper.dll
rem Usage:   scripts\build.bat
rem
rem ASCII-only on purpose: cmd.exe reads .bat with the OEM codepage (936 on zh-CN),
rem so UTF-8 Chinese text in a .bat gets garbled. Keep this file ASCII.
setlocal
set "ROOT=%~dp0.."
pushd "%ROOT%" || (echo [ERROR] Cannot enter repo root: %ROOT% & exit /b 1)

dotnet build "src\AppraisalHelper\AppraisalHelper.csproj" -c Release %*
set "RC=%ERRORLEVEL%"
popd

if not "%RC%"=="0" (
    echo.
    echo [ERROR] Build failed. See the messages above.
    exit /b %RC%
)

echo.
echo [OK] Built: src\AppraisalHelper\bin\Release\netstandard2.1\AppraisalHelper.dll
exit /b 0
