@echo off
chcp 65001 >nul
REM ======================================================================
REM PSE Vision - สคริปต์ติดตั้งแบบง่าย (Simple Installation)
REM ใช้สำหรับเครื่องที่ติดตั้ง Python 3.8+ แล้ว
REM ======================================================================

echo.
echo ╔═══════════════════════════════════════════════════════╗
echo ║                                                       ║
echo ║     PSE VISION - สคริปต์ติดตั้งแบบง่าย              ║
echo ║     Simple Installation Script                        ║
echo ║                                                       ║
echo ╚═══════════════════════════════════════════════════════╝
echo.

cd /d "%~dp0"

REM ======================================================================
REM ตรวจสอบ Python
REM ======================================================================
echo [1/3] ตรวจสอบ Python...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ ไม่พบ Python ในระบบ!
    echo.
    echo กรุณาติดตั้ง Python 3.8 ขึ้นไปก่อน
    echo ดาวน์โหลดจาก: https://www.python.org/downloads/
    echo.
    echo หรือใช้ Python Embedded ที่มากับโปรเจค:
    echo   python_embedded\python.exe
    echo.
    pause
    exit /b 1
)

python --version
echo ✅ พบ Python แล้ว
echo.

REM ======================================================================
REM ติดตั้ง Python Packages
REM ======================================================================
echo [2/3] ติดตั้ง Python Libraries...
echo.

cd python_scripts
python -m pip install --upgrade pip
python -m pip install -r backend_requirements.txt

if %errorlevel% neq 0 (
    echo.
    echo ❌ การติดตั้ง Python packages ล้มเหลว
    pause
    exit /b 1
)

echo.
echo ✅ ติดตั้ง Python packages สำเร็จ
cd ..
echo.

REM ======================================================================
REM สร้างโฟลเดอร์ที่จำเป็น
REM ======================================================================
echo [3/3] สร้างโฟลเดอร์ที่จำเป็น...

if not exist "logs" mkdir logs
if not exist "python_scripts\captures" mkdir python_scripts\captures

echo ✅ สร้างโฟลเดอร์เสร็จสิ้น
echo.

REM ======================================================================
REM เสร็จสิ้นการติดตั้ง
REM ======================================================================
echo.
echo ╔═══════════════════════════════════════════════════════╗
echo ║                                                       ║
echo ║        ✅ ติดตั้งสำเร็จ! Installation Complete!     ║
echo ║                                                       ║
echo ╚═══════════════════════════════════════════════════════╝
echo.
echo 📌 วิธีใช้งาน:
echo.
echo   1. รัน Backend Server:
echo      PSE_VISION_STARTUP.bat
echo.
echo   2. เปิดเว็บ Admin:
echo      http://localhost:64020
echo.
echo   3. สำหรับเครื่องคนงาน ติดตั้ง:
echo      user_display\dist-installer\PSE Vision Worker Display-Setup-1.0.0.exe
echo.
echo.
pause
