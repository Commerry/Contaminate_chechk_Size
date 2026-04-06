# ================================================
# PSE Vision - Auto-Startup Configuration Script
# ================================================
# This script creates a shortcut in Windows Startup folder
# to automatically launch PSE Vision system on boot
# ================================================

param(
    [switch]$Remove
)

$ErrorActionPreference = "Stop"

# Paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$StartupBatchFile = Join-Path $ScriptDir "PSE_VISION_STARTUP.bat"
$StartupFolder = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp"
$ShortcutPath = Join-Path $StartupFolder "PSE_Vision_Startup.lnk"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "PSE Vision - Auto-Startup Configuration" -ForegroundColor Cyan
Write-Host "================================================`n" -ForegroundColor Cyan

# Check if startup batch file exists
if (-not (Test-Path $StartupBatchFile)) {
    Write-Host "❌ ERROR: Startup batch file not found!" -ForegroundColor Red
    Write-Host "   Expected: $StartupBatchFile" -ForegroundColor Yellow
    Write-Host "`n   Please ensure PSE_VISION_STARTUP.bat exists in the project root." -ForegroundColor Yellow
    exit 1
}

# Remove mode
if ($Remove) {
    Write-Host "🗑️  Removing auto-startup configuration..." -ForegroundColor Yellow
    
    if (Test-Path $ShortcutPath) {
        Remove-Item $ShortcutPath -Force
        Write-Host "✅ Auto-startup shortcut removed successfully!" -ForegroundColor Green
        Write-Host "   PSE Vision will no longer start automatically on boot." -ForegroundColor Gray
    } else {
        Write-Host "⚠️  Auto-startup shortcut not found. Nothing to remove." -ForegroundColor Yellow
    }
    exit 0
}

# Install mode
Write-Host "📝 Configuration Details:" -ForegroundColor Cyan
Write-Host "   Startup Script: $StartupBatchFile" -ForegroundColor Gray
Write-Host "   Shortcut Path:  $ShortcutPath" -ForegroundColor Gray
Write-Host ""

# Create startup folder if it doesn't exist
if (-not (Test-Path $StartupFolder)) {
    Write-Host "📁 Creating startup folder..." -ForegroundColor Yellow
    New-Item -Path $StartupFolder -ItemType Directory -Force | Out-Null
}

# Create WScript Shell COM object
Write-Host "🔧 Creating auto-startup shortcut..." -ForegroundColor Yellow
$WshShell = New-Object -ComObject WScript.Shell

# Create shortcut
$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = $StartupBatchFile
$Shortcut.WorkingDirectory = $ScriptDir
$Shortcut.Description = "PSE Vision System Auto-Startup"
$Shortcut.IconLocation = "imageres.dll,76"  # Windows default application icon
$Shortcut.WindowStyle = 7  # Minimized window
$Shortcut.Save()

Write-Host "✅ Auto-startup configured successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "System will now start automatically on boot!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📌 What happens on startup:" -ForegroundColor Cyan
Write-Host "   1. Backend Server (Python Flask) starts on port 64020" -ForegroundColor Gray
Write-Host "   2. Frontend Web Server (Vite) starts" -ForegroundColor Gray
Write-Host "   3. Desktop Display App (Electron) launches" -ForegroundColor Gray
Write-Host ""
Write-Host "🔧 To remove auto-startup:" -ForegroundColor Cyan
Write-Host "   Run: .\SETUP_AUTO_STARTUP.ps1 -Remove" -ForegroundColor Yellow
Write-Host ""
Write-Host "⚠️  Note: Shortcut created in:" -ForegroundColor Yellow
Write-Host "   $ShortcutPath" -ForegroundColor Gray
Write-Host ""
