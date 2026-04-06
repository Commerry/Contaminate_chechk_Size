@echo off
chcp 65001 >nul
REM ========================================
REM PSE Vision Auto-Startup Script
REM Kill old processes and start fresh
REM ========================================

cd /d "%~dp0"

echo.
echo ╔════════════════════════════════════════╗
echo ║  PSE Vision - Starting System...      ║
echo ╚════════════════════════════════════════╝
echo.

REM ========================================
REM Step 1: Kill existing Backend processes
REM ========================================
echo [1/3] Checking for existing Backend processes...

REM Kill processes using port 64020
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :64020 ^| findstr LISTENING') do (
    echo       Killing process on port 64020 (PID: %%a)
    taskkill /F /PID %%a >nul 2>&1
)

REM Kill any python.exe running backend_server.py
echo       Killing any existing python backend processes...
wmic process where "name='python.exe' and commandline like '%%backend_server.py%%'" delete >nul 2>&1

REM Wait for cleanup
timeout /t 2 /nobreak >nul
echo       ✓ Old processes cleared

REM ========================================
REM Step 2: Start Backend Server
REM ========================================
echo.
echo [2/3] Starting Backend Server...

REM Detect Python command
if exist "%~dp0python_embedded\python.exe" (
    set PYTHON_CMD=%~dp0python_embedded\python.exe
    echo       Using Python Embedded
) else (
    set PYTHON_CMD=python
    echo       Using System Python
)

REM Start backend in new window (minimized)
start "PSE Vision Backend" /MIN %PYTHON_CMD% "%~dp0python_scripts\backend_server.py"

REM Wait for backend to initialize
echo       Waiting for backend to start...
timeout /t 10 /nobreak >nul

REM Verify backend is running
ping -n 2 127.0.0.1 >nul
curl -s http://localhost:64020/api/health >nul 2>&1
if %errorlevel% equ 0 (
    echo       ✓ Backend started successfully
) else (
    echo       ⚠ Backend may still be starting...
)

REM ========================================
REM Step 3: Open Admin Web
REM ========================================
echo.
echo [3/3] Opening Admin Web...
start http://localhost:64020
echo       ✓ Browser launched

REM ========================================
REM Complete
REM ========================================
echo.
echo ╔════════════════════════════════════════╗
echo ║  ✓ System Started Successfully!       ║
echo ╚════════════════════════════════════════╝
echo.
echo 📌 Backend API:  http://localhost:64020/api/
echo 📌 Admin Web:    http://localhost:64020/
echo.
echo 💡 To stop: Close the "PSE Vision Backend" window
echo    or run: taskkill /F /IM python.exe
echo.

pause
