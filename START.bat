@echo off
REM ========================================================================
REM PSE Vision - Start System
REM Run this file to start Backend + Admin Web
REM For auto-start: Copy this file to Windows Startup folder
REM ========================================================================

cd /d "%~dp0"

REM Kill existing processes on port 64020
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :64020 ^| findstr LISTENING 2^>nul') do (
    taskkill /F /PID %%a >nul 2>&1
)

REM Detect Python
if exist "%~dp0python_embedded\python.exe" (
    set PYTHON_CMD=%~dp0python_embedded\python.exe
) else (
    set PYTHON_CMD=python
)

REM Start Backend (minimized window)
start "PSE Vision Backend" /MIN %PYTHON_CMD% "%~dp0python_scripts\backend_server.py"

REM Wait for backend to initialize
timeout /t 8 /nobreak >nul

REM Open Admin Web in browser
start http://localhost:64020
