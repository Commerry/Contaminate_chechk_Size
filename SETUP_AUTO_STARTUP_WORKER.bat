@echo off
REM ========================================================================
REM Setup Auto-Startup for Worker Mode
REM This will configure Windows to auto-start PSE Vision in Worker Mode
REM when the computer boots up
REM ========================================================================

echo.
echo ========================================================
echo.
echo   PSE Vision - Auto-Startup Configuration
echo   (Worker Mode)
echo.
echo ========================================================
echo.

cd /d "%~dp0"

REM ========================================================================
REM Create shortcut in Windows Startup folder
REM ========================================================================
echo [1/2] Creating startup shortcut...

set "STARTUP_FOLDER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "SHORTCUT_PATH=%STARTUP_FOLDER%\PSE Vision Worker.lnk"
set "TARGET_SCRIPT=%~dp0START_WORKER_MODE.bat"

REM Create VBS script to generate shortcut
set "VBS_SCRIPT=%TEMP%\create_shortcut.vbs"

echo Set oWS = WScript.CreateObject("WScript.Shell") > "%VBS_SCRIPT%"
echo sLinkFile = "%SHORTCUT_PATH%" >> "%VBS_SCRIPT%"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%VBS_SCRIPT%"
echo oLink.TargetPath = "%TARGET_SCRIPT%" >> "%VBS_SCRIPT%"
echo oLink.WorkingDirectory = "%~dp0" >> "%VBS_SCRIPT%"
echo oLink.Description = "PSE Vision Worker Mode - Auto Start" >> "%VBS_SCRIPT%"
echo oLink.Save >> "%VBS_SCRIPT%"

REM Execute VBS script
cscript //nologo "%VBS_SCRIPT%"
del "%VBS_SCRIPT%"

if exist "%SHORTCUT_PATH%" (
    echo [OK] Shortcut created successfully
    echo      Location: %SHORTCUT_PATH%
) else (
    echo [ERROR] Failed to create shortcut
    pause
    exit /b 1
)

echo.

REM ========================================================================
REM Verify Desktop App installation
REM ========================================================================
echo [2/2] Checking Desktop App installation...

set "DESKTOP_APP=%LOCALAPPDATA%\Programs\pse-vision-worker\PSE Vision Worker Display.exe"

if exist "%DESKTOP_APP%" (
    echo [OK] Desktop App is installed
    echo      Location: %DESKTOP_APP%
) else (
    echo [WARNING] Desktop App NOT installed yet
    echo.
    echo   Please install it from:
    echo   user_display\dist-installer\PSE Vision Worker Display-Setup-1.0.0.exe
    echo.
    echo   The auto-startup is configured, but Desktop App
    echo   will not launch until it's installed.
)

echo.

REM ========================================================================
REM Completion
REM ========================================================================
echo ========================================================
echo.
echo   [SUCCESS] Auto-Startup Configured!
echo.
echo ========================================================
echo.
echo What happens on next boot:
echo   1. Backend Server starts automatically (background)
echo   2. Desktop App opens for workers
echo   3. Admin Web available at http://localhost:64020
echo.
echo To test now, run:
echo   START_WORKER_MODE.bat
echo.
echo To remove auto-startup:
echo   Delete: %SHORTCUT_PATH%
echo.
pause
