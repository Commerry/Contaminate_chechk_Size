# ✅ Installation Files Checklist
# รายการตรวจสอบไฟล์ติดตั้งที่จำเป็น

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PSE Vision - Installation Checklist" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseDir = $PSScriptRoot
$allOK = $true

# Helper function
function Check-File {
    param($path, $name)
    if (Test-Path $path) {
        Write-Host "✅ $name" -ForegroundColor Green
        return $true
    } else {
        Write-Host "❌ $name - NOT FOUND!" -ForegroundColor Red
        $script:allOK = $false
        return $false
    }
}

function Check-Folder {
    param($path, $name)
    if (Test-Path $path) {
        $count = (Get-ChildItem $path -Recurse -File | Measure-Object).Count
        Write-Host "✅ $name ($count files)" -ForegroundColor Green
        return $true
    } else {
        Write-Host "❌ $name - NOT FOUND!" -ForegroundColor Red
        $script:allOK = $false
        return $false
    }
}

# ========================================
# 1. Installation Scripts
# ========================================
Write-Host ""
Write-Host "[1] Installation Scripts" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray

Check-File "$baseDir\INSTALL_COMPLETE_SYSTEM.ps1" "INSTALL_COMPLETE_SYSTEM.ps1"
Check-File "$baseDir\BUILD_DESKTOP_APP.bat" "BUILD_DESKTOP_APP.bat"

# ========================================
# 2. Documentation
# ========================================
Write-Host ""
Write-Host "[2] Documentation" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray

Check-File "$baseDir\README.md" "README.md"
Check-File "$baseDir\QUICK_START.md" "QUICK_START.md"
Check-File "$baseDir\CHANGELOG.md" "CHANGELOG.md"

# ========================================
# 3. Backend Files
# ========================================
Write-Host ""
Write-Host "[3] Backend (Python Scripts)" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray

Check-Folder "$baseDir\python_scripts" "python_scripts/"
Check-File "$baseDir\python_scripts\backend_server.py" "  - backend_server.py"
Check-File "$baseDir\python_scripts\backend_extension.py" "  - backend_extension.py"
Check-File "$baseDir\python_scripts\backend_requirements.txt" "  - backend_requirements.txt"
Check-File "$baseDir\python_scripts\configurations.json" "  - configurations.json"
Check-File "$baseDir\python_scripts\system_config.py" "  - system_config.py"
Check-Folder "$baseDir\python_scripts\database" "  - database/"

# ========================================
# 4. Frontend Files
# ========================================
Write-Host ""
Write-Host "[4] Frontend (Admin Web)" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray

Check-Folder "$baseDir\frontend" "frontend/"
Check-File "$baseDir\frontend\package.json" "  - package.json"
Check-File "$baseDir\frontend\vite.config.js" "  - vite.config.js"
Check-File "$baseDir\frontend\index.html" "  - index.html"
Check-Folder "$baseDir\frontend\src" "  - src/"

# Check if built
if (Test-Path "$baseDir\frontend\dist") {
    Write-Host "✅   - dist/ (Built)" -ForegroundColor Green
} else {
    Write-Host "⚠️   - dist/ (Not built yet - run INSTALL_COMPLETE_SYSTEM.ps1)" -ForegroundColor Yellow
}

# ========================================
# 5. Desktop App Files
# ========================================
Write-Host ""
Write-Host "[5] Desktop App (User Display)" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray

Check-Folder "$baseDir\user_display" "user_display/"
Check-File "$baseDir\user_display\package.json" "  - package.json"
Check-File "$baseDir\user_display\vite.config.js" "  - vite.config.js"
Check-File "$baseDir\user_display\index.html" "  - index.html"
Check-Folder "$baseDir\user_display\src" "  - src/"
Check-Folder "$baseDir\user_display\electron" "  - electron/"

# Check if built
if (Test-Path "$baseDir\user_display\dist-installer") {
    $installerFiles = Get-ChildItem "$baseDir\user_display\dist-installer" -Filter "*.exe" -ErrorAction SilentlyContinue
    if ($installerFiles) {
        Write-Host "✅   - dist-installer/ (Built - $($installerFiles.Count) installer(s))" -ForegroundColor Green
    } else {
        Write-Host "⚠️   - dist-installer/ (Folder exists but no .exe - run BUILD_DESKTOP_APP.bat)" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️   - dist-installer/ (Not built yet - run BUILD_DESKTOP_APP.bat)" -ForegroundColor Yellow
}

# ========================================
# 6. Python Embedded (Optional)
# ========================================
Write-Host ""
Write-Host "[6] Python Embedded (Optional)" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray

if (Test-Path "$baseDir\python_embedded\python.exe") {
    $pythonVersion = & "$baseDir\python_embedded\python.exe" --version 2>&1
    Write-Host "✅ python_embedded/ ($pythonVersion)" -ForegroundColor Green
} else {
    Write-Host "⚠️  python_embedded/ - Not found (will use system Python)" -ForegroundColor Yellow
}

# ========================================
# 7. Configuration & Data
# ========================================
Write-Host ""
Write-Host "[7] Configuration & Database" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray

Check-File "$baseDir\config.json" "config.json"
Check-Folder "$baseDir\config" "config/"

if (Test-Path "$baseDir\system_config.db") {
    $dbSize = [math]::Round((Get-Item "$baseDir\system_config.db").Length / 1KB, 2)
    Write-Host "✅ system_config.db ($dbSize KB)" -ForegroundColor Green
} else {
    Write-Host "⚠️  system_config.db - Will be created on first run" -ForegroundColor Yellow
}

if (Test-Path "$baseDir\logs") {
    Write-Host "✅ logs/ (exists)" -ForegroundColor Green
} else {
    Write-Host "⚠️  logs/ - Will be created by installer" -ForegroundColor Yellow
}

# ========================================
# 8. Startup Script (Created by Installer)
# ========================================
Write-Host ""
Write-Host "[8] Auto-Startup Script" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray

if (Test-Path "$baseDir\PSE_VISION_STARTUP.bat") {
    Write-Host "✅ PSE_VISION_STARTUP.bat (Created)" -ForegroundColor Green
} else {
    Write-Host "⚠️  PSE_VISION_STARTUP.bat - Will be created by INSTALL_COMPLETE_SYSTEM.ps1" -ForegroundColor Yellow
}

# ========================================
# Summary
# ========================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

if ($allOK) {
    Write-Host "✅ ALL REQUIRED FILES PRESENT!" -ForegroundColor Green
    Write-Host ""
    Write-Host "System is ready for installation." -ForegroundColor Green
    Write-Host "Run: .\INSTALL_COMPLETE_SYSTEM.ps1" -ForegroundColor Yellow
} else {
    Write-Host "❌ SOME FILES ARE MISSING!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please check the missing files above." -ForegroundColor Yellow
    Write-Host "The system may not install properly." -ForegroundColor Yellow
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check system requirements
Write-Host "[System Requirements Check]" -ForegroundColor Cyan
Write-Host "----------------------------------------" -ForegroundColor Gray

# Check Python
try {
    $pythonCheck = Get-Command python -ErrorAction SilentlyContinue
    if ($pythonCheck) {
        $pyVer = & python --version 2>&1
        Write-Host "✅ Python: $pyVer" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Python: Not found (will use Python Embedded)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️  Python: Not found" -ForegroundColor Yellow
}

# Check Node.js
try {
    $nodeCheck = Get-Command node -ErrorAction SilentlyContinue
    if ($nodeCheck) {
        $nodeVer = & node --version 2>&1
        $npmVer = & npm --version 2>&1
        Write-Host "✅ Node.js: $nodeVer (npm $npmVer)" -ForegroundColor Green
    } else {
        Write-Host "❌ Node.js: NOT FOUND - Please install from https://nodejs.org/" -ForegroundColor Red
        $allOK = $false
    }
} catch {
    Write-Host "❌ Node.js: NOT FOUND" -ForegroundColor Red
    $allOK = $false
}

Write-Host ""

if ($allOK) {
    Write-Host "🚀 Ready to install! Run: .\INSTALL_COMPLETE_SYSTEM.ps1" -ForegroundColor Green
} else {
    Write-Host "⚠️  Please install missing requirements first." -ForegroundColor Yellow
}

Write-Host ""
