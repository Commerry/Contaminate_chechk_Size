# Installation Guide - Step by Step

**For new machines WITHOUT Python/Node.js installed**

---

## Quick Install (Recommended)

Copy and paste commands one by one:

### Step 1: Navigate to project folder
```batch
cd /d "D:\Contaminate_chechk_Size-V6\Contaminate_chechk_Size-master"
```

### Step 2: Install Python packages
```batch
cd python_scripts
python -m pip install --upgrade pip
python -m pip install -r backend_requirements.txt
cd ..
```

### Step 3: Create required folders
```batch
mkdir logs
mkdir python_scripts\captures
```

### Step 4: Start Backend Server
```batch
cd python_scripts
python backend_server.py
```

### Step 5: Open Admin Web
Open your browser and go to:
```
http://localhost:64020
```

---

## Alternative: Using Python Embedded (No Python installation needed)

If you don't have Python installed, use the embedded version:

### Step 1: Navigate to project
```batch
cd /d "D:\Contaminate_chechk_Size-V6\Contaminate_chechk_Size-master"
```

### Step 2: Install packages with embedded Python
```batch
cd python_scripts
..\python_embedded\python.exe -m pip install --upgrade pip
..\python_embedded\python.exe -m pip install -r backend_requirements.txt
cd ..
```

### Step 3: Create folders
```batch
mkdir logs
mkdir python_scripts\captures
```

### Step 4: Run with embedded Python
```batch
cd python_scripts
..\python_embedded\python.exe backend_server.py
```

---

## For Worker Machines (Desktop App)

Just install the .exe file:
```
user_display\dist-installer\PSE Vision Worker Display-Setup-1.0.0.exe
```

Double-click and follow the installation wizard.

---

## Troubleshooting

### Error: Python not found
**Solution:**
- Install Python 3.8+: https://www.python.org/downloads/
- OR use Python Embedded (see alternative method above)

### Error: Port 64020 already in use
**Solution:**
```batch
netstat -ano | findstr :64020
taskkill /F /PID <PID_NUMBER>
```

### Error: Cannot connect to camera
**Solution:**
1. Check USB 3.0 cable
2. Install DepthAI drivers
3. Restart camera: `python reset_camera.py`
