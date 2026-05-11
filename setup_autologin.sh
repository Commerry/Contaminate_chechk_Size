#!/bin/bash
# ========================================================================
# PSE Vision - Setup Auto-Login on Ubuntu Desktop
# Configures Ubuntu to auto-login and start PSE Vision
# ========================================================================

set -e

CURRENT_USER=$(whoami)

echo ""
echo "========================================================"
echo "  PSE Vision - Auto-Login Setup"
echo "========================================================"
echo ""
echo "This will configure Ubuntu to:"
echo "  1. Auto-login as $CURRENT_USER"
echo "  2. Start PSE Vision Desktop App on login"
echo "  3. Keep backend running with PM2"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

# Check desktop environment
if [ -n "$XDG_CURRENT_DESKTOP" ]; then
    echo "[INFO] Desktop Environment: $XDG_CURRENT_DESKTOP"
else
    echo "[WARNING] Could not detect desktop environment"
fi
echo ""

# Configure auto-login for GDM (GNOME Display Manager)
echo "[1/4] Configuring auto-login for GDM..."
if [ -f "/etc/gdm3/custom.conf" ]; then
    # Backup original config
    sudo cp /etc/gdm3/custom.conf /etc/gdm3/custom.conf.backup 2>/dev/null || true
    
    # Enable auto-login
    sudo bash -c "cat > /etc/gdm3/custom.conf << 'EOF'
# GDM configuration storage

[daemon]
AutomaticLoginEnable = true
AutomaticLogin = $CURRENT_USER
WaylandEnable = false

[security]

[xdmcp]

[chooser]

[debug]
EOF"
    echo "[OK] GDM auto-login configured"
elif [ -f "/etc/lightdm/lightdm.conf" ]; then
    # LightDM configuration
    sudo bash -c "cat >> /etc/lightdm/lightdm.conf << EOF

[Seat:*]
autologin-user=$CURRENT_USER
autologin-user-timeout=0
EOF"
    echo "[OK] LightDM auto-login configured"
else
    echo "[WARNING] Display manager not detected. Please configure auto-login manually."
fi
echo ""

# Create autostart directory
echo "[2/4] Creating autostart entry..."
mkdir -p ~/.config/autostart

# Create desktop entry for PSE Vision Display App
cat > ~/.config/autostart/pse-vision-display.desktop << EOF
[Desktop Entry]
Type=Application
Name=PSE Vision Worker Display
Comment=Auto-start PSE Vision Display Application
Exec=$(pwd)/user_display/dist-installer/pse-vision-worker-1.0.0.AppImage
Path=$(pwd)
Terminal=false
StartupNotify=false
X-GNOME-Autostart-enabled=true
EOF

echo "[OK] Autostart entry created"
echo ""

# Make sure PM2 is set up
echo "[3/4] Checking PM2 setup..."
if command -v pm2 &> /dev/null; then
    # Ensure PM2 startup is configured
    pm2 startup systemd -u $USER --hp $HOME > /dev/null 2>&1 || true
    echo "[OK] PM2 configured"
else
    echo "[WARNING] PM2 not installed. Run ./setup_pm2.sh first"
fi
echo ""

# Create startup notification
echo "[4/4] Creating startup indicator..."
cat > ~/.config/autostart/pse-vision-notify.desktop << EOF
[Desktop Entry]
Type=Application
Name=PSE Vision Startup
Comment=PSE Vision startup notification
Exec=notify-send "PSE Vision" "System is starting..." -i dialog-information
Terminal=false
StartupNotify=false
X-GNOME-Autostart-enabled=true
EOF

echo "[OK] Startup indicator created"
echo ""

echo "========================================================"
echo "  ✓ AUTO-LOGIN SETUP COMPLETE"
echo "========================================================"
echo ""
echo "Changes made:"
echo "  1. Auto-login enabled for user: $CURRENT_USER"
echo "  2. Desktop App will auto-start on login"
echo "  3. PM2 backend starts on system boot"
echo ""
echo "To disable auto-login:"
echo "  • Edit: /etc/gdm3/custom.conf"
echo "  • Set: AutomaticLoginEnable = false"
echo ""
echo "To disable auto-start:"
echo "  • Remove: ~/.config/autostart/pse-vision-display.desktop"
echo ""
echo "⚠️  IMPORTANT: Reboot to apply changes"
echo "  sudo reboot"
echo ""
