@echo off
setlocal

echo ============================================
echo   Limbus Company Chinese Patch Installer
echo   边狱巴士中文补丁一键安装器
echo ============================================
echo.

set "SCRIPT_DIR=%~dp0"
if "%~1"=="" (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%install.ps1"
) else (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%install.ps1" -GamePath "%~1"
)
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if not "%EXIT_CODE%"=="0" (
    echo Installation failed. / 安装失败。
) else (
    echo Installation finished. / 安装完成。
)
if "%~1"=="" pause
exit /b %EXIT_CODE%
