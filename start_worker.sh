#!/bin/bash
# ========================================================================
# PSE Vision - Worker Mode Auto-Startup (Ubuntu/Linux)
# Starts Backend + Opens Desktop App (for factory workers)
# NO browser window - only Desktop App visible
# ========================================================================

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "========================================================"
echo "  PSE Vision - Worker Mode"
echo "========================================================"
echo ""

# ========================================================================
# Kill existing processes
# ========================================================================
echo "[INFO] Preparing to start Worker Mode..."

# Kill existing Backend processes on port 64020
if command -v lsof &> /dev/null; then
    lsof -ti:64020 | xargs -r kill -9 2>/dev/null || true
elif command -v fuser &> /dev/null; then
    fuser -k 64020/tcp 2>/dev/null || true
fi

# Kill any python backend process
pkill -f "backend_server.py" 2>/dev/null || true

# Wait for processes to terminate
sleep 2

# ========================================================================
# Start Backend Server (Background)
# ========================================================================
echo "[INFO] Starting Backend Server (background mode)..."

cd "$SCRIPT_DIR/python_scripts"
# Use virtual environment python
if [ -f "$SCRIPT_DIR/venv/bin/python" ]; then
    "$SCRIPT_DIR/venv/bin/python" backend_server.py > /dev/null 2>&1 &
else
    python3 backend_server.py > /dev/null 2>&1 &
fi
BACKEND_PID=$!

echo "[OK] Backend started (PID: $BACKEND_PID)"
cd "$SCRIPT_DIR"

# ========================================================================
# Wait for Backend to initialize
# ========================================================================
echo "[INFO] Waiting for backend to initialize..."
sleep 8

# Check if backend is running
if ! ps -p $BACKEND_PID > /dev/null; then
    echo "[ERROR] Backend failed to start!"
    exit 1
fi

# ========================================================================
# Check if Desktop App is installed
# ========================================================================
DESKTOP_APP="$SCRIPT_DIR/user_display/dist-installer/pse-vision-worker-*.AppImage"

if ls $DESKTOP_APP 1> /dev/null 2>&1; then
    # Desktop App is installed - Launch it
    echo "[INFO] Launching Desktop App..."
    APP_FILE=$(ls $DESKTOP_APP | head -1)
    chmod +x "$APP_FILE"
    "$APP_FILE" &
    echo "[OK] Desktop App launched"
else
    # Desktop App not installed - Show message
    echo ""
    echo "========================================================"
    echo "  Desktop App NOT installed"
    echo "========================================================"
    echo ""
    echo "Please build Desktop App first:"
    echo "  cd user_display && npm run dist"
    echo ""
    echo "For now, you can access Admin Web at:"
    echo "  http://localhost:64020"
    echo ""
fi

# ========================================================================
# Completion
# ========================================================================
echo ""
echo "========================================================"
echo "  ✓ Worker Mode Started Successfully"
echo "========================================================"
echo ""
echo "  • Backend Server: Running (PID: $BACKEND_PID)"
echo "  • Admin Web: http://localhost:64020"
echo "  • Desktop App: Running"
echo ""
echo "  To stop backend:"
echo "    kill $BACKEND_PID"
echo ""
echo "========================================================"
echo ""

# Keep script running
wait
