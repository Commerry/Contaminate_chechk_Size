@echo off
REM ======================================================================
REM PSE Vision - Simple Installation Script
REM For machines with Python 3.8+ already installed
REM ======================================================================

echo.
echo ========================================================
echo.
echo     PSE VISION - Simple Installation Script
echo.
echo ========================================================
echo.

cd /d "%~dp0"

REM ======================================================================
REM Check Python
REM ======================================================================
echo [1/3] Checking Python...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python not found!
    echo.
    echo Please install Python 3.8 or higher first
    echo Download from: https://www.python.org/downloads/
    echo.
    echo Or use Python Embedded included in this project:
    echo   python_embedded\python.exe
    echo.
    pause
    exit /b 1
)

python --version
echo [OK] Python found
echo.

REM ======================================================================
REM Install Python Packages
REM ======================================================================
echo [2/3] Installing Python Libraries...
echo.

cd python_scripts
python -m pip install --upgrade pip
python -m pip install -r backend_requirements.txt

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Failed to install Python packages
    pause
    exit /b 1
)

echo.
echo [OK] Python packages installed successfully
cd ..
echo.

REM ======================================================================
REM Create Required Folders
REM ======================================================================
echo [3/3] Creating required folders...

if not exist "logs" mkdir logs
if not exist "python_scripts\captures" mkdir python_scripts\captures

echo [OK] Folders created
echo.

REM ======================================================================
REM Installation Complete
REM ======================================================================
echo.
echo ========================================================
echo.
echo     [SUCCESS] Installation Complete!
echo.
echo ========================================================
echo.
echo How to use:
echo.
echo   1. Start Backend Server:
echo      PSE_VISION_STARTUP.bat
echo.
echo   2. Open Admin Web:
echo      http://localhost:64020
echo.
echo   3. For worker machines, install:
echo      user_display\dist-installer\PSE Vision Worker Display-Setup-1.0.0.exe
echo.
echo.
pause
