# ========================================================================
# PSE Vision - Deploy to Ubuntu Server via SSH (Windows PowerShell)
# Deploys entire project to remote Ubuntu server
# Target: adminpse@10.1.100.78
# ========================================================================

# Configuration
$REMOTE_USER = 'adminpse'
$REMOTE_HOST = '10.1.100.78'
$REMOTE_PATH = '/home/adminpse/pse-vision'
$LOCAL_PATH = $PSScriptRoot

Write-Host ''
Write-Host '========================================================'
Write-Host '  PSE Vision - Deploy to Ubuntu Server'
Write-Host '========================================================'
Write-Host ''
Write-Host 'Configuration:'
Write-Host "  • Remote: $REMOTE_USER@$REMOTE_HOST"
Write-Host "  • Path:   $REMOTE_PATH"
Write-Host "  • Local:  $LOCAL_PATH"
Write-Host ''
$confirm = Read-Host 'Continue deployment? (y/n)'

if ($confirm -ne 'y' -and $confirm -ne 'Y') {
    Write-Host 'Cancelled.'
    exit 0
}

# Test SSH connection
Write-Host ''
Write-Host '[1/6] Testing SSH connection...'
$sshTarget = "$REMOTE_USER@$REMOTE_HOST"
try {
    $testCmd = 'echo ''[OK] Connection successful'''
    $result = ssh -o ConnectTimeout=5 $sshTarget $testCmd 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw 'Connection failed'
    }
    Write-Host $result
}
catch {
    Write-Host "[ERROR] Cannot connect to $sshTarget" -ForegroundColor Red
    Write-Host 'Please check:'
    Write-Host '  1. Server is online'
    Write-Host '  2. SSH credentials are correct'
    Write-Host '  3. Network connectivity'
    Write-Host '  4. SSH client is installed (OpenSSH)'
    exit 1
}
Write-Host ''

# Create remote directory
Write-Host '[2/6] Creating remote directory...'
$mkdirCmd = "mkdir -p $REMOTE_PATH"
ssh $sshTarget $mkdirCmd
Write-Host '[OK] Directory ready'
Write-Host ""

# Build frontend before deployment
Write-Host '[3/6] Building frontend...'
Push-Location "$LOCAL_PATH\frontend"
if (-not (Test-Path 'node_modules')) {
    Write-Host '[INFO] Installing frontend dependencies...'
    npm install --quiet
}
npm run build 2>&1 | Select-Object -Last 10
if (-not (Test-Path 'dist\index.html')) {
    Write-Host '[ERROR] Frontend build failed' -ForegroundColor Red
    Pop-Location
    exit 1
}
Write-Host '[OK] Frontend built'
Pop-Location
Write-Host ''

# Check if rsync is available (via WSL or Cygwin)
Write-Host '[4/6] Syncing files to server...'
Write-Host '[INFO] This may take a few minutes...'

$hasRsync = Get-Command rsync -ErrorAction SilentlyContinue
if ($hasRsync) {
    # Use rsync if available
    $rsyncTarget = "$REMOTE_USER@$REMOTE_HOST`:$REMOTE_PATH/"
    rsync -avz --progress `
        --exclude 'node_modules' `
        --exclude '.git' `
        --exclude '__pycache__' `
        --exclude '*.pyc' `
        --exclude '.venv' `
        --exclude 'venv' `
        --exclude 'dist-installer' `
        --exclude 'user_display/dist' `
        --exclude '.vscode' `
        --exclude '.DS_Store' `
        --exclude '*.log' `
        --exclude 'logs/*' `
        "$LOCAL_PATH/" `
        $rsyncTarget
}
else {
    # Fallback to scp - upload in batches to avoid timeout
    Write-Host '[INFO] Using SCP (rsync not available)...'
    Write-Host '[INFO] Uploading files in batches...'
    
    $scpTarget = "$REMOTE_USER@$REMOTE_HOST`:$REMOTE_PATH/"
    
    # Upload critical files and folders separately
    $items = @(
        '*.sh',
        '*.json',
        '*.md',
        '*.bat',
        'dev.js',
        'python_scripts',
        'frontend/dist',
        'frontend/*.json',
        'frontend/*.js',
        'frontend/*.html',
        'frontend/src',
        'frontend/public',
        'user_display/electron',
        'user_display/public',
        'user_display/src',
        'user_display/scripts',
        'user_display/*.json',
        'user_display/*.js',
        'user_display/*.html',
        'user_display/*.md',
        'user_display/*.ps1',
        'user_display/*.nsh',
        'config'
    )
    
    $uploadedCount = 0
    foreach ($item in $items) {
        if (Test-Path $item) {
            $uploadedCount++
            Write-Host "  [$uploadedCount/$($items.Count)] Uploading $item..."
            scp -r -C $item $scpTarget 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "    ✓ $item uploaded" -ForegroundColor Green
            } else {
                Write-Host "    ✗ Failed to upload $item" -ForegroundColor Yellow
            }
        }
    }
}

Write-Host '[OK] Files synced'
Write-Host ''

# Set executable permissions on remote
Write-Host '[5/6] Setting permissions on remote...'
$permCmd = @'
cd ~/pse-vision && chmod +x *.sh build_desktop.sh setup_service.sh remove_service.sh && echo "[OK] Permissions set"
'@
ssh $sshTarget $permCmd
Write-Host ''

# Display next steps
Write-Host '[6/6] Deployment complete!'
Write-Host ''
Write-Host '========================================================'
Write-Host '  ✓ DEPLOYMENT SUCCESSFUL'
Write-Host '========================================================'
Write-Host ''
Write-Host 'Next steps on the server:'
Write-Host ''
Write-Host '  1. SSH to server:'
Write-Host "     ssh $sshTarget"
Write-Host ''
Write-Host '  2. Navigate to project:'
Write-Host "     cd $REMOTE_PATH"
Write-Host ''
Write-Host '  3. Install dependencies:'
Write-Host '     ./install.sh'
Write-Host ''
Write-Host '  4. Start the system:'
Write-Host '     ./start.sh'
Write-Host ''
Write-Host '  5. (Optional) Setup auto-start:'
Write-Host '     ./setup_service.sh'
Write-Host ''
Write-Host '  6. Access Admin Web:'
Write-Host "     http://$REMOTE_HOST`:64020"
Write-Host ''
Write-Host '========================================================'
Write-Host ''
$sshNow = Read-Host 'Would you like to SSH into the server now? (y/n)'

if ($sshNow -eq 'y' -or $sshNow -eq 'Y') {
    ssh $sshTarget
}
