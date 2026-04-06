# ========================================================================
# PSE Vision Complete System Installer
# ติดตั้งระบบสมบูรณ์บนเครื่องที่ไม่มีโปรแกรมใดๆ
# ========================================================================

#Requires -RunAsAdministrator

param(
    [switch]$SkipDesktopApp = $false
)

$ErrorActionPreference = "Stop"
$ProgressPreference = 'SilentlyContinue'

# Colors
function Write-Success { Write-Host "✅ $args" -ForegroundColor Green }
function Write-Info { Write-Host "ℹ️  $args" -ForegroundColor Cyan }
function Write-Warning { Write-Host "⚠️  $args" -ForegroundColor Yellow }
function Write-Error { Write-Host "❌ $args" -ForegroundColor Red }
function Write-Step { Write-Host "`n========================================" -ForegroundColor Cyan; Write-Host "$args" -ForegroundColor Cyan; Write-Host "========================================" -ForegroundColor Cyan }

$BASE_DIR = $PSScriptRoot
$PYTHON_EMBEDDED_DIR = Join-Path $BASE_DIR "python_embedded"
$PYTHON_SCRIPTS_DIR = Join-Path $BASE_DIR "python_scripts"
$FRONTEND_DIR = Join-Path $BASE_DIR "frontend"
$USER_DISPLAY_DIR = Join-Path $BASE_DIR "user_display"
$LOGS_DIR = Join-Path $BASE_DIR "logs"

Write-Host @"

╔═══════════════════════════════════════════════════════╗
║                                                       ║
║     PSE VISION - ระบบติดตั้งอัตโนมัติ               ║
║     Complete System Auto Installer                    ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

Write-Info "โฟลเดอร์ติดตั้ง: $BASE_DIR"
Write-Host ""

# ========================================================================
# Step 1: Check and Install Python
# ========================================================================
Write-Step "ขั้นตอนที่ 1: ตรวจสอบ Python"

$pythonCmd = $null
$pythonVersion = $null

# Check if Python is already installed in system
try {
    $pythonCheck = Get-Command python -ErrorAction SilentlyContinue
    if ($pythonCheck) {
        $pythonVersion = & python --version 2>&1
        if ($pythonVersion -match "Python (\d+\.\d+)") {
            $versionNum = [double]$matches[1]
            if ($versionNum -ge 3.8) {
                $pythonCmd = "python"
                Write-Success "พบ Python ในระบบแล้ว: $pythonVersion"
            } else {
                Write-Warning "Python version ต่ำกว่า 3.8: $pythonVersion"
                $pythonCmd = $null
            }
        }
    }
} catch {
    Write-Info "ไม่พบ Python ในระบบ"
}

# Use Python Embedded if no suitable Python found
if (-not $pythonCmd) {
    if (Test-Path $PYTHON_EMBEDDED_DIR) {
        $pythonEmbedded = Join-Path $PYTHON_EMBEDDED_DIR "python.exe"
        if (Test-Path $pythonEmbedded) {
            $pythonCmd = $pythonEmbedded
            $pythonVersion = & $pythonCmd --version 2>&1
            Write-Success "ใช้ Python Embedded: $pythonVersion"
            
            # Check if pip is available in embedded
            $pipCmd = Join-Path $PYTHON_EMBEDDED_DIR "Scripts\pip.exe"
            if (-not (Test-Path $pipCmd)) {
                Write-Info "กำลังติดตั้ง pip ใน Python Embedded..."
                $getPip = Join-Path $env:TEMP "get-pip.py"
                Invoke-WebRequest -Uri "https://bootstrap.pypa.io/get-pip.py" -OutFile $getPip
                & $pythonCmd $getPip
                Remove-Item $getPip -Force
                Write-Success "ติดตั้ง pip เสร็จสิ้น"
            }
        } else {
            Write-Error "ไม่พบ python.exe ใน $PYTHON_EMBEDDED_DIR"
            Write-Info "กรุณาดาวน์โหลด Python Embedded จาก: https://www.python.org/downloads/windows/"
            exit 1
        }
    } else {
        Write-Error "ไม่พบ Python และไม่พบ Python Embedded"
        Write-Info "กรุณาติดตั้ง Python 3.8+ หรือวาง Python Embedded ที่: $PYTHON_EMBEDDED_DIR"
        Write-Info "ดาวน์โหลดจาก: https://www.python.org/downloads/windows/"
        exit 1
    }
}

# ========================================================================
# Step 2: Install Python Dependencies
# ========================================================================
Write-Step "ขั้นตอนที่ 2: ติดตั้ง Python Libraries"

$requirementsFile = Join-Path $PYTHON_SCRIPTS_DIR "backend_requirements.txt"
if (Test-Path $requirementsFile) {
    Write-Info "กำลังตรวจสอบและติดตั้ง Python packages..."
    
    # Get pip command
    if ($pythonCmd -eq "python") {
        $pipCmd = "pip"
    } else {
        $pipCmd = Join-Path (Split-Path $pythonCmd) "Scripts\pip.exe"
        if (-not (Test-Path $pipCmd)) {
            $pipCmd = "$pythonCmd -m pip"
        }
    }
    
    # Install requirements
    Write-Info "กำลังติดตั้ง packages จาก backend_requirements.txt..."
    if ($pipCmd -like "*-m pip") {
        & $pythonCmd -m pip install -r $requirementsFile --upgrade
    } else {
        & $pipCmd install -r $requirementsFile --upgrade
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "ติดตั้ง Python packages สำเร็จ"
    } else {
        Write-Warning "มีปัญหาบางอย่างในการติดตั้ง packages (อาจติดตั้งได้บางส่วน)"
    }
} else {
    Write-Warning "ไม่พบไฟล์ backend_requirements.txt"
}

# ========================================================================
# Step 3: Check and Install Node.js
# ========================================================================
Write-Step "ขั้นตอนที่ 3: ตรวจสอบ Node.js"

$nodeCmd = $null
$nodeVersion = $null

try {
    $nodeCheck = Get-Command node -ErrorAction SilentlyContinue
    if ($nodeCheck) {
        $nodeVersion = & node --version 2>&1
        if ($nodeVersion -match "v(\d+)\.") {
            $versionNum = [int]$matches[1]
            if ($versionNum -ge 16) {
                $nodeCmd = "node"
                $npmCmd = "npm"
                Write-Success "พบ Node.js ในระบบแล้ว: $nodeVersion"
                $npmVersion = & npm --version 2>&1
                Write-Success "npm version: $npmVersion"
            } else {
                Write-Warning "Node.js version ต่ำกว่า 16: $nodeVersion"
            }
        }
    }
} catch {
    Write-Info "ไม่พบ Node.js ในระบบ"
}

if (-not $nodeCmd) {
    Write-Error "ไม่พบ Node.js ในระบบ!"
    Write-Info "กรุณาติดตั้ง Node.js 16+ จาก: https://nodejs.org/"
    Write-Info "แนะนำ: ติดตั้ง LTS version (Node.js 20.x)"
    Write-Host ""
    Write-Info "หลังจากติดตั้ง Node.js แล้ว กรุณารันสคริปต์นี้อีกครั้ง"
    exit 1
}

# ========================================================================
# Step 4: Install Frontend Dependencies
# ========================================================================
Write-Step "ขั้นตอนที่ 4: ติดตั้ง Frontend Dependencies"

Push-Location $FRONTEND_DIR
Write-Info "กำลังติดตั้ง npm packages สำหรับ Admin Web..."

if (Test-Path "node_modules") {
    Write-Info "พบ node_modules อยู่แล้ว - กำลังตรวจสอบและอัพเดท..."
}

npm install --legacy-peer-deps

if ($LASTEXITCODE -eq 0) {
    Write-Success "ติดตั้ง Frontend dependencies สำเร็จ"
} else {
    Write-Error "การติดตั้ง Frontend dependencies ล้มเหลว"
    Pop-Location
    exit 1
}

Pop-Location

# ========================================================================
# Step 5: Build Frontend
# ========================================================================
Write-Step "ขั้นตอนที่ 5: Build Frontend (Admin Web)"

Push-Location $FRONTEND_DIR
Write-Info "กำลัง build Admin Web..."

npm run build

if ($LASTEXITCODE -eq 0) {
    Write-Success "Build Frontend สำเร็จ"
    if (Test-Path "dist") {
        $distFiles = Get-ChildItem "dist" -Recurse | Measure-Object -Property Length -Sum
        $distSize = [math]::Round($distFiles.Sum / 1MB, 2)
        Write-Info "ขนาด dist folder: $distSize MB"
    }
} else {
    Write-Error "การ build Frontend ล้มเหลว"
    Pop-Location
    exit 1
}

Pop-Location

# ========================================================================
# Step 6: Install Desktop App Dependencies (Optional)
# ========================================================================
if (-not $SkipDesktopApp) {
    Write-Step "ขั้นตอนที่ 6: ติดตั้ง Desktop App Dependencies"
    
    Push-Location $USER_DISPLAY_DIR
    Write-Info "กำลังติดตั้ง npm packages สำหรับ Desktop App..."
    
    if (Test-Path "node_modules") {
        Write-Info "พบ node_modules อยู่แล้ว - กำลังตรวจสอบและอัพเดท..."
    }
    
    npm install --legacy-peer-deps
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "ติดตั้ง Desktop App dependencies สำเร็จ"
        Write-Info "สามารถ build Desktop App ได้ด้วยคำสั่ง: npm run dist:win"
    } else {
        Write-Warning "การติดตั้ง Desktop App dependencies ล้มเหลว"
    }
    
    Pop-Location
} else {
    Write-Info "ข้าม Desktop App installation (ใช้ -SkipDesktopApp)"
}

# ========================================================================
# Step 7: Create Logs Directory
# ========================================================================
Write-Step "ขั้นตอนที่ 7: สร้างโฟลเดอร์ที่จำเป็น"

if (-not (Test-Path $LOGS_DIR)) {
    New-Item -ItemType Directory -Path $LOGS_DIR -Force | Out-Null
    Write-Success "สร้างโฟลเดอร์ logs"
} else {
    Write-Info "โฟลเดอร์ logs มีอยู่แล้ว"
}

# Create captures directory
$capturesDir = Join-Path $PYTHON_SCRIPTS_DIR "captures"
if (-not (Test-Path $capturesDir)) {
    New-Item -ItemType Directory -Path $capturesDir -Force | Out-Null
    Write-Success "สร้างโฟลเดอร์ captures"
}

# ========================================================================
# Step 8: Create Auto-Startup Script
# ========================================================================
Write-Step "ขั้นตอนที่ 8: สร้างสคริปต์ Auto-Start"

$startupScriptPath = Join-Path $BASE_DIR "PSE_VISION_STARTUP.bat"
$startupScriptContent = @"
@echo off
chcp 65001 >nul
REM ========================================
REM PSE Vision Auto-Startup Script
REM ระบบจะรันอัตโนมัติเมื่อ Windows Boot
REM ========================================

cd /d "%~dp0"

echo [PSE Vision] Starting system...
echo.

REM Kill existing Backend processes on port 64020
echo [PSE Vision] Checking for existing Backend processes...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :64020 ^| findstr LISTENING') do (
    echo [PSE Vision] Killing process on port 64020 (PID: %%a)
    taskkill /F /PID %%a >nul 2>&1
)

REM Kill any python.exe running backend_server.py
echo [PSE Vision] Killing any existing backend_server.py processes...
for /f "tokens=2" %%a in ('tasklist /FI "IMAGENAME eq python.exe" /FO LIST ^| findstr "PID:"') do (
    taskkill /F /PID %%a >nul 2>&1
)

REM Wait a moment for processes to terminate
timeout /t 2 /nobreak >nul

echo [PSE Vision] All old processes cleared.
echo.

REM Start Backend Server in background
echo [PSE Vision] Starting Backend Server...
start "PSE Backend" /MIN "$pythonCmd" "%~dp0python_scripts\backend_server.py"

REM Wait for backend to start
echo [PSE Vision] Waiting for backend to initialize...
timeout /t 10 /nobreak >nul

REM Open Admin Web in browser
echo [PSE Vision] Opening Admin Web...
start http://localhost:64020

echo.
echo [PSE Vision] System started successfully!
echo - Backend: http://localhost:64020
echo - Admin Web: http://localhost:64020

REM Optional: Start Desktop App if installed
if exist "%~dp0user_display\dist-installer\PSE Vision Worker Display-Setup-1.0.0.exe" (
    echo - Desktop App: Available in user_display\dist-installer
)

exit
"@

Set-Content -Path $startupScriptPath -Value $startupScriptContent -Encoding UTF8
Write-Success "สร้างไฟล์ startup script: PSE_VISION_STARTUP.bat"

# ========================================================================
# Step 9: Add to Windows Startup
# ========================================================================
Write-Step "ขั้นตอนที่ 9: เพิ่มใน Windows Startup"

$startupFolder = [Environment]::GetFolderPath("Startup")
$shortcutPath = Join-Path $startupFolder "PSE Vision System.lnk"

Write-Info "Startup folder: $startupFolder"

try {
    $WScriptShell = New-Object -ComObject WScript.Shell
    $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $startupScriptPath
    $shortcut.WorkingDirectory = $BASE_DIR
    $shortcut.Description = "PSE Vision Auto-Start"
    $shortcut.Save()
    
    Write-Success "เพิ่ม shortcut ใน Windows Startup แล้ว"
    Write-Info "ระบบจะรันอัตโนมัติเมื่อ Windows บูต"
} catch {
    Write-Warning "ไม่สามารถสร้าง startup shortcut ได้: $_"
    Write-Info "คุณสามารถเพิ่ม shortcut ของ PSE_VISION_STARTUP.bat ใน Startup folder ด้วยตนเอง"
}

# ========================================================================
# Step 10: Test Backend
# ========================================================================
Write-Step "ขั้นตอนที่ 10: ทดสอบระบบ"

Write-Info "ต้องการทดสอบรัน Backend ตอนนี้หรือไม่? (y/n)"
$testNow = Read-Host "ทดสอบ"

if ($testNow -eq "y" -or $testNow -eq "Y") {
    Write-Info "กำลังเริ่มต้น Backend Server..."
    Write-Info "กด Ctrl+C เพื่อหยุด Server"
    Write-Host ""
    
    Push-Location $PYTHON_SCRIPTS_DIR
    & $pythonCmd "backend_server.py"
    Pop-Location
} else {
    Write-Info "ข้ามการทดสอบ"
}

# ========================================================================
# Installation Complete
# ========================================================================
Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                       ║" -ForegroundColor Green
Write-Host "║        ✅ ติดตั้งระบบสำเร็จ!                        ║" -ForegroundColor Green
Write-Host "║           Installation Complete!                      ║" -ForegroundColor Green
Write-Host "║                                                       ║" -ForegroundColor Green
Write-Host "╚═══════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Info "สิ่งที่ติดตั้งแล้ว:"
Write-Host "  ✅ Python และ libraries จำเป็น" -ForegroundColor Gray
Write-Host "  ✅ Node.js และ npm packages" -ForegroundColor Gray
Write-Host "  ✅ Frontend (Admin Web) - Built" -ForegroundColor Gray
if (-not $SkipDesktopApp) {
    Write-Host "  ✅ Desktop App dependencies" -ForegroundColor Gray
}
Write-Host "  ✅ Auto-startup script" -ForegroundColor Gray
Write-Host "  ✅ Windows Startup integration" -ForegroundColor Gray
Write-Host ""

Write-Info "วิธีใช้งาน:"
Write-Host "  1. รัน Backend ด้วยตนเอง:" -ForegroundColor Cyan
Write-Host "     $startupScriptPath" -ForegroundColor Yellow
Write-Host ""
Write-Host "  2. หรือรอให้รันอัตโนมัติเมื่อเปิดเครื่องใหม่" -ForegroundColor Cyan
Write-Host ""
Write-Host "  3. เข้าใช้งาน Admin Web ที่:" -ForegroundColor Cyan
Write-Host "     http://localhost:64020" -ForegroundColor Yellow
Write-Host ""

if (-not $SkipDesktopApp) {
    Write-Info "สำหรับ Desktop App:"
    Write-Host "  Build Desktop App installer:" -ForegroundColor Cyan
    Write-Host "     cd user_display" -ForegroundColor Yellow
    Write-Host "     npm run dist:win" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  ไฟล์ .exe จะอยู่ที่: user_display\dist-installer\" -ForegroundColor Gray
    Write-Host ""
}

Write-Success "Installation script completed!"
