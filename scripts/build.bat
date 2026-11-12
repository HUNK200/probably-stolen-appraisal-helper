@echo off
rem 编译模组。产物：src\AppraisalHelper\bin\Release\netstandard2.1\AppraisalHelper.dll
rem 用法：scripts\build.bat
setlocal
cd /d "%~dp0.."
dotnet build "src\AppraisalHelper\AppraisalHelper.csproj" -c Release %*
if errorlevel 1 (
    echo.
    echo [失败] 编译未通过，看上面的报错。
    exit /b 1
)
echo.
echo [成功] 产物在 src\AppraisalHelper\bin\Release\netstandard2.1\
exit /b 0
