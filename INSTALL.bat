@echo off
REM ========================================================================
REM PSE Vision - Complete Installation (One-Click)
REM Safe to run on fresh install OR existing install (will update)
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
REM Step 0: Stop existing running system (if any)
REM ========================================================================
echo [0/5] Stopping existing system (if running)...

REM Kill processes using port 64020
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :64020 ^| findstr LISTENING 2^>nul') do (
    taskkill /F /PID %%a >nul 2>&1
)

REM Kill any python backend process
wmic process where "name='python.exe' and commandline like '%%backend_server%%'" delete >nul 2>&1
wmic process where "name='pythonw.exe'" delete >nul 2>&1

timeout /t 2 /nobreak >nul
echo [OK] Ready to install
echo.

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
REM Step 2: Install/Update Python Packages
REM ========================================================================
echo [2/5] Installing/Updating Python packages...
cd python_scripts
python -m pip install --upgrade pip --quiet
python -m pip install -r backend_requirements.txt --upgrade --quiet

if %errorlevel% neq 0 (
    echo [ERROR] Failed to install Python packages
    cd ..
    pause
    exit /b 1
)

echo [OK] Python packages up to date
cd ..
echo.

REM ========================================================================
REM Step 3: Check Node.js, Install Frontend packages and Build
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

echo [INFO] Installing/Updating Frontend packages...
cd frontend

REM Remove node_modules only if package.json is newer (force clean install)
call npm install --legacy-peer-deps --silent

echo [INFO] Building Frontend...
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
REM Step 4: Install/Update Desktop App
REM ========================================================================
echo [4/5] Installing/Updating Desktop App...

if exist "user_display\dist-installer\PSE Vision Worker Display-Setup-1.0.0.exe" (

    REM Uninstall old version first if already installed (silent)
    set "UNINSTALLER=%LOCALAPPDATA%\Programs\pse-vision-worker\Uninstall PSE Vision Worker Display.exe"
    if exist "%UNINSTALLER%" (
        echo [INFO] Removing old version...
        start /wait "" "%UNINSTALLER%" /S
        timeout /t 3 /nobreak >nul
        echo [OK] Old version removed
    )

    REM Install new version silently
    echo [INFO] Installing new version...
    start /wait "Installing Desktop App" "user_display\dist-installer\PSE Vision Worker Display-Setup-1.0.0.exe" /S
    echo [OK] Desktop App installed/updated

) else (
    echo [WARNING] Desktop App installer not found, skipping
)

echo.

REM ========================================================================
REM Step 5: Create Required Folders
REM ========================================================================
echo [5/5] Creating required folders...
if not exist "logs" mkdir logs
if not exist "python_scripts\captures" mkdir python_scripts\captures
echo [OK] Folders ready
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
echo   [OK] Python packages installed/updated
echo   [OK] Frontend built
echo   [OK] Desktop App installed/updated
echo.
echo --------------------------------------------------------
echo  Auto-Startup: To run on Windows boot automatically,
echo  copy START.bat to your Startup folder:
echo    1. Press Win+R, type: shell:startup
echo    2. Copy START.bat into that folder
echo --------------------------------------------------------
echo.
echo Starting system now...
timeout /t 3 /nobreak >nul
call "%~dp0START.bat"
echo   1. Press Windows + R
echo   2. Type: shell:startup
echo   3. Copy "START.bat" into that folder
echo.
echo --------------------------------------------------------
echo.
echo Starting system now...
timeout /t 3 /nobreak >nul
call START.bat
