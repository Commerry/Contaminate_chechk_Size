@echo off
REM ========================================================================
REM PSE Vision - Complete Installation (One-Click)
REM This installs everything and starts the system automatically
REM ========================================================================

echo.
echo ========================================================
echo.
echo     PSE VISION - ONE-CLICK INSTALLATION
echo.
echo ========================================================
echo.

cd /d "%~dp0"

REM ========================================================================
REM Step 1: Check Python
REM ========================================================================
echo [1/5] Checking Python...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python not found!
    echo Please install Python 3.8+ from https://www.python.org/downloads/
    pause
    exit /b 1
)

python --version
echo [OK] Python found
echo.

REM ========================================================================
REM Step 2: Install Python Packages
REM ========================================================================
echo [2/5] Installing Python packages...
cd python_scripts
python -m pip install --upgrade pip --quiet
python -m pip install -r backend_requirements.txt --upgrade --quiet

if %errorlevel% neq 0 (
    echo [ERROR] Failed to install Python packages
    cd ..
    pause
    exit /b 1
)

echo [OK] Python packages installed
cd ..
echo.

REM ========================================================================
REM Step 3: Check Node.js and Install Frontend
REM ========================================================================
echo [3/5] Checking Node.js...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js not found!
    echo Please install Node.js 16+ from https://nodejs.org/
    pause
    exit /b 1
)

node --version
echo [OK] Node.js found
echo.

echo [INFO] Installing Frontend packages and building...
cd frontend
call npm install --legacy-peer-deps --silent
call npm run build

if %errorlevel% neq 0 (
    echo [ERROR] Failed to build frontend
    cd ..
    pause
    exit /b 1
)

echo [OK] Frontend built successfully
cd ..
echo.

REM ========================================================================
REM Step 4: Install Desktop App
REM ========================================================================
echo [4/5] Installing Desktop App...

REM Check if installer exists
if exist "user_display\dist-installer\PSE Vision Worker Display-Setup-1.0.0.exe" (
    echo [INFO] Found Desktop App installer
    echo [INFO] Installing Desktop App...
    start /wait "Installing Desktop App" "user_display\dist-installer\PSE Vision Worker Display-Setup-1.0.0.exe" /S
    echo [OK] Desktop App installed
) else (
    echo [WARNING] Desktop App installer not found
    echo [INFO] You can build it later with: cd user_display ^&^& npm run dist:win
)

echo.

REM ========================================================================
REM Step 5: Create Required Folders
REM ========================================================================
echo [5/5] Creating required folders...
if not exist "logs" mkdir logs
if not exist "python_scripts\captures" mkdir python_scripts\captures
echo [OK] Folders created
echo.

REM ========================================================================
REM Installation Complete
REM ========================================================================
echo.
echo ========================================================
echo.
echo     [SUCCESS] Installation Complete!
echo.
echo ========================================================
echo.
echo What has been installed:
echo   [OK] Python packages
echo   [OK] Frontend (Web Admin)
echo   [OK] Desktop App (for workers)
echo.
echo --------------------------------------------------------
echo IMPORTANT: Auto-Startup Setup
echo --------------------------------------------------------
echo.
echo To make the system start automatically when Windows boots:
echo   1. Press Windows + R
echo   2. Type: shell:startup
echo   3. Copy "START.bat" into that folder
echo.
echo --------------------------------------------------------
echo.
echo Starting system now...
timeout /t 3 /nobreak >nul
call START.bat
