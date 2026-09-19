@echo off
setlocal

echo ============================================
echo   Limbus Company Chinese Patch Installer
echo   (Chinese prompts are printed by PowerShell)
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
    echo Installation failed. Please read the message above.
) else (
    echo Installation finished.
)
if "%~1"=="" pause
exit /b %EXIT_CODE%