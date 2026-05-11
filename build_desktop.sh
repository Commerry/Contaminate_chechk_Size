#!/bin/bash
# ========================================================================
# PSE Vision - Build Desktop App for Linux
# Creates AppImage for Ubuntu/Debian
# ========================================================================

set -e  # Exit on error

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo ""
echo "========================================================"
echo "  PSE Vision - Desktop App Builder (Linux)"
echo "========================================================"
echo ""

# Check Node.js
if ! command -v node &> /dev/null; then
    echo "[ERROR] Node.js not found!"
    echo "Please install Node.js 16+ first"
    exit 1
fi

echo "[INFO] Node.js version: $(node --version)"
echo ""

# Navigate to user_display
cd user_display

# Clean previous builds
echo "[1/3] Cleaning previous builds..."
rm -rf dist dist-installer
echo "[OK] Clean complete"
echo ""

# Install dependencies
echo "[2/3] Installing dependencies..."
npm install --quiet 2>&1 | grep -E "added|removed|updated|audited" || true
echo "[OK] Dependencies installed"
echo ""

# Build for Linux
echo "[3/3] Building AppImage for Linux..."
npm run dist -- --linux 2>&1 | tail -20

if [ $? -ne 0 ]; then
    echo ""
    echo "[ERROR] Build failed!"
    exit 1
fi

echo ""
echo "========================================================"
echo "  ✓ BUILD COMPLETE"
echo "========================================================"
echo ""
echo "Output files:"
ls -lh dist-installer/*.AppImage 2>/dev/null || echo "  [WARNING] AppImage not found"
echo ""
echo "To install:"
echo "  1. Copy AppImage to desired location"
echo "  2. Make it executable: chmod +x *.AppImage"
echo "  3. Run: ./pse-vision-worker-*.AppImage"
echo ""
echo "To integrate with desktop:"
echo "  Right-click AppImage → Allow executing file as program"
echo ""
echo "========================================================"
echo ""
