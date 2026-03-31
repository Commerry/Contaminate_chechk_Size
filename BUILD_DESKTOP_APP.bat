@echo off
chcp 65001 >nul
REM ========================================
REM Build Desktop App Installer (.exe)
REM สร้างไฟล์ติดตั้ง Desktop App
REM ========================================

echo.
echo ╔════════════════════════════════════════════╗
echo ║                                            ║
echo ║  PSE Vision - Build Desktop App Installer  ║
echo ║                                            ║
echo ╚════════════════════════════════════════════╝
echo.

cd /d "%~dp0user_display"

REM Check if node_modules exists
if not exist "node_modules" (
    echo ❌ ไม่พบ node_modules
    echo ℹ️  กรุณารัน INSTALL_COMPLETE_SYSTEM.ps1 ก่อน
    echo.
    pause
    exit /b 1
)

echo ✅ กำลัง Build Desktop App...
echo.
echo 📋 ขั้นตอน:
echo    1. Pre-build (copy icons)
echo    2. Build frontend (Vite)
echo    3. Package with Electron Builder
echo.
echo ⏳ กรุณารอ... (อาจใช้เวลา 5-10 นาที)
echo.

REM Run electron-builder
call npm run dist:win

if errorlevel 1 (
    echo.
    echo ❌ Build ล้มเหลว!
    echo ℹ️  กรุณาตรวจสอบ error ด้านบน
    pause
    exit /b 1
)

echo.
echo ╔════════════════════════════════════════════╗
echo ║                                            ║
echo ║        ✅ Build สำเร็จ!                   ║
echo ║                                            ║
echo ╚════════════════════════════════════════════╝
echo.

REM Show installer location
if exist "dist-installer\PSE Vision Worker Display-Setup-1.0.0.exe" (
    echo 📦 ไฟล์ติดตั้งอยู่ที่:
    echo    %~dp0user_display\dist-installer\PSE Vision Worker Display-Setup-1.0.0.exe
    echo.
    
    REM Show file size
    for %%F in ("dist-installer\PSE Vision Worker Display-Setup-1.0.0.exe") do (
        set size=%%~zF
    )
    echo 📊 ขนาดไฟล์: %size% bytes
    echo.
    
    echo ℹ️  คุณสามารถนำไฟล์นี้ไปติดตั้งบนเครื่องอื่นได้
    echo    (รวม Backend + Frontend + Desktop App ไว้ทั้งหมดแล้ว)
) else (
    echo ⚠️  ไม่พบไฟล์ .exe ที่ dist-installer\
    dir /b dist-installer\*.exe 2>nul
)

echo.
pause
