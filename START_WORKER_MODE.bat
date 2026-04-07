@echo off
REM ========================================================================
REM PSE Vision - Worker Mode Auto-Startup
REM Starts Backend + Opens Desktop App (for factory workers)
REM NO browser window - only Desktop App visible
REM ========================================================================

cd /d "%~dp0"

REM ========================================================================
REM Kill existing processes
REM ========================================================================
echo [PSE Vision] Preparing to start Worker Mode...

REM Kill existing Backend processes on port 64020
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :64020 ^| findstr LISTENING 2^>nul') do (
    taskkill /F /PID %%a >nul 2>&1
)

REM Kill any python.exe running backend_server.py
tasklist /FI "IMAGENAME eq python.exe" 2>nul | find /I "python.exe" >nul
if %errorlevel% equ 0 (
    for /f "tokens=2" %%a in ('tasklist /FI "IMAGENAME eq python.exe" /FO LIST ^| findstr "PID:"') do (
        taskkill /F /PID %%a >nul 2>&1
    )
)

REM Wait for processes to terminate
timeout /t 2 /nobreak >nul

REM ========================================================================
REM Start Backend Server (Hidden - No Window)
REM ========================================================================
echo [PSE Vision] Starting Backend Server (background mode)...

REM Check if Python is available
python --version >nul 2>&1
if %errorlevel% equ 0 (
    REM Use system Python
    start "PSE Backend Server" /B pythonw "%~dp0python_scripts\backend_server.py"
    echo [OK] Backend started with system Python
) else (
    REM Use Python Embedded
    if exist "%~dp0python_embedded\pythonw.exe" (
        start "PSE Backend Server" /B "%~dp0python_embedded\pythonw.exe" "%~dp0python_scripts\backend_server.py"
        echo [OK] Backend started with Python Embedded
    ) else (
        echo [ERROR] Python not found!
        echo Please install Python or provide Python Embedded
        pause
        exit /b 1
    )
)

REM ========================================================================
REM Wait for Backend to initialize
REM ========================================================================
echo [PSE Vision] Waiting for backend to initialize...
timeout /t 8 /nobreak >nul

REM ========================================================================
REM Check if Desktop App is installed
REM ========================================================================
set "DESKTOP_APP=%LOCALAPPDATA%\Programs\pse-vision-worker\PSE Vision Worker Display.exe"

if exist "%DESKTOP_APP%" (
    REM Desktop App is installed - Launch it
    echo [PSE Vision] Launching Desktop App...
    start "" "%DESKTOP_APP%"
    echo [OK] Desktop App launched
) else (
    REM Desktop App not installed - Show message
    echo.
    echo ========================================================
    echo  Desktop App NOT installed
    echo ========================================================
    echo.
    echo Please install Desktop App first:
    echo   user_display\dist-installer\PSE Vision Worker Display-Setup-1.0.0.exe
    echo.
    echo For now, you can access Admin Web at:
    echo   http://localhost:64020
    echo.
    pause
)

REM ========================================================================
REM Completion
REM ========================================================================
echo.
echo [PSE Vision] Worker Mode started successfully!
echo - Backend Server: Running (background)
echo - Admin Web: http://localhost:64020 (available but not opened)
echo - Desktop App: Running (for workers)
echo.

REM Exit silently (no pause)
exit
