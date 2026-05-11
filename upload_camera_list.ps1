# Upload Camera List Feature Files
$ErrorActionPreference = "Stop"
$server = "adminpse@10.1.100.78"
$password = "Abc123**"
$remotePath = "~/pse-vision"

Write-Host "Uploading Camera List Feature..." -ForegroundColor Cyan

# Test if using pscp or scp
$usePscp = $false
try {
    $null = Get-Command pscp -ErrorAction Stop
    $usePscp = $true
    Write-Host "Using PSCP for upload" -ForegroundColor Yellow
} catch {
    Write-Host "Using SCP for upload" -ForegroundColor Yellow
}

# Upload backend_server.py
Write-Host "`n1. Uploading backend_server.py..." -ForegroundColor Green
if ($usePscp) {
    echo y | pscp -pw $password python_scripts/backend_server.py "${server}:${remotePath}/python_scripts/"
} else {
    scp python_scripts/backend_server.py "${server}:${remotePath}/python_scripts/"
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "   backend_server.py uploaded" -ForegroundColor Green
} else {
    Write-Host "   Failed to upload backend_server.py" -ForegroundColor Red
}

# Upload SettingsPanel.vue
Write-Host "`n2. Uploading SettingsPanel.vue..." -ForegroundColor Green
if ($usePscp) {
    echo y | pscp -pw $password frontend/src/components/SettingsPanel.vue "${server}:${remotePath}/frontend/src/components/"
} else {
    scp frontend/src/components/SettingsPanel.vue "${server}:${remotePath}/frontend/src/components/"
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "   SettingsPanel.vue uploaded" -ForegroundColor Green
} else {
    Write-Host "   Failed to upload SettingsPanel.vue" -ForegroundColor Red
}

Write-Host "`nUpload complete!" -ForegroundColor Cyan
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. SSH to server: ssh adminpse@10.1.100.78" -ForegroundColor White
Write-Host "  2. Rebuild frontend: cd ~/pse-vision/frontend; npm run build" -ForegroundColor White
Write-Host "  3. Restart backend: pm2 restart pse-vision-backend" -ForegroundColor White
