#!/bin/bash
# PSE Vision System - API Test Script
# ทดสอบ API endpoints ทั้งหมดเพื่อตรวจสอบว่าระบบทำงานปกติ

BASE_URL="http://localhost:64020"
PASS=0
FAIL=0

echo "======================================"
echo "  PSE Vision System - API Tests"
echo "======================================"
echo ""

# Function to test API
test_api() {
    local name="$1"
    local endpoint="$2"
    local expected_key="$3"
    
    echo -n "Testing $name... "
    
    response=$(python3 -c "
import urllib.request
import json
import sys

try:
    data = json.loads(urllib.request.urlopen('${BASE_URL}${endpoint}').read().decode())
    if '${expected_key}' in data or '${expected_key}' == '':
        sys.exit(0)
    else:
        sys.exit(1)
except Exception as e:
    print('Error: ' + str(e))
    sys.exit(1)
" 2>&1)
    
    if [ $? -eq 0 ]; then
        echo "✅ PASS"
        ((PASS++))
    else
        echo "❌ FAIL"
        echo "  Error: $response"
        ((FAIL++))
    fi
}

# Test Core APIs
echo "=== Core System APIs ==="
test_api "Health Check" "/api/health" "status"
test_api "Config Get" "/api/config/get" "config"
echo ""

# Test Camera APIs
echo "=== Camera APIs ==="
test_api "Camera Status" "/api/camera/status" "connected"
test_api "Camera Ping" "/api/camera/ping" "pong"
test_api "Cameras List (NEW)" "/api/cameras/list" "cameras"
echo ""

# Test Database APIs
echo "=== Database APIs ==="
test_api "Database Config" "/api/database/config" "config"
test_api "Session Status" "/api/database/session/status" "session_active"
echo ""

# Test Management APIs
echo "=== Management APIs ==="
test_api "Machines List" "/api/machines" "machines"
test_api "Lots List" "/api/lots" "lots"
test_api "Rubber Type" "/api/rubber/type" "rubber_type"
echo ""

# Test Settings APIs
echo "=== Settings APIs ==="
test_api "Settings Get" "/api/settings" ""
test_api "Setup Check" "/api/setup/check" "setup_completed"
echo ""

# Summary
echo "======================================"
echo "  Test Results"
echo "======================================"
echo "✅ Passed: $PASS"
echo "❌ Failed: $FAIL"
echo "Total: $((PASS + FAIL))"
echo ""

if [ $FAIL -eq 0 ]; then
    echo "🎉 All tests passed! System is ready."
    exit 0
else
    echo "⚠️  Some tests failed. Please check the errors above."
    exit 1
fi
