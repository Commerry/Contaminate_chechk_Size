# Worker Mode - Auto-Startup Guide

**For factory worker machines**

---

## 🎯 What is Worker Mode?

Worker Mode automatically starts:
- ✅ **Backend Server** (hidden, background)
- ✅ **Admin Web** (available at http://localhost:64020 but NOT opened)
- ✅ **Desktop App** (visible for workers)

Workers will only see the Desktop App - no technical interfaces.

---

## 📦 Installation Steps

### Step 1: Install Desktop App

Double-click to install:
```
user_display\dist-installer\PSE Vision Worker Display-Setup-1.0.0.exe
```

Follow the installation wizard.

### Step 2: Setup Auto-Startup

Run this script:
```batch
SETUP_AUTO_STARTUP_WORKER.bat
```

This will:
- Create a shortcut in Windows Startup folder
- Configure the system to auto-start on boot

---

## 🚀 Testing Worker Mode

### Manual Start (Before Auto-Startup)

To test if everything works:
```batch
START_WORKER_MODE.bat
```

You should see:
1. Backend starts in background (no window)
2. Desktop App opens automatically
3. No browser window opens

### Verify Backend is Running

Open browser manually and go to:
```
http://localhost:64020
```

You should see the Admin Web interface.

---

## 🔄 What Happens on Boot?

When Windows starts:

1. **5-8 seconds:** Backend Server initializes (hidden)
2. **Desktop App launches** - Worker sees this immediately
3. **Admin Web ready** - Accessible at http://localhost:64020 (but not opened)

Workers only interact with Desktop App. Admins can access the web interface when needed.

---

## ⚙️ Configuration

### Desktop App Installation Location

Default location:
```
%LOCALAPPDATA%\Programs\pse-vision-worker\PSE Vision Worker Display.exe
```

### Backend Configuration

Edit settings at:
```
python_scripts\config.json
python_scripts\configurations.json
python_scripts\machines.json
```

---

## 🛠️ Troubleshooting

### Desktop App doesn't open on startup

**Check installation:**
```batch
dir "%LOCALAPPDATA%\Programs\pse-vision-worker"
```

If not found, reinstall Desktop App.

### Backend not responding

**Check if Python is installed:**
```batch
python --version
```

**Or use Python Embedded:**
```batch
python_embedded\python.exe --version
```

### Port 64020 already in use

**Kill existing process:**
```batch
netstat -ano | findstr :64020
taskkill /F /PID <PID_NUMBER>
```

---

## 📁 Files Structure

```
Contaminate_chechk_Size/
├── START_WORKER_MODE.bat              ← Start in Worker Mode
├── SETUP_AUTO_STARTUP_WORKER.bat      ← Configure auto-startup
│
├── PSE_VISION_STARTUP.bat             ← Standard mode (opens browser)
├── SETUP_AUTO_STARTUP.ps1             ← Standard auto-startup
│
├── python_scripts/
│   └── backend_server.py              ← Backend Server
│
└── user_display/
    └── dist-installer/
        └── PSE Vision Worker Display-Setup-1.0.0.exe
```

---

## 🔐 Admin Access

Admins can access the web interface anytime by opening:
```
http://localhost:64020
```

Or from other computers on the same network:
```
http://[WORKER-PC-IP]:64020
```

---

## ❌ Removing Auto-Startup

To disable auto-startup, delete the shortcut:
```
%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\PSE Vision Worker.lnk
```

Or run:
```batch
del "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\PSE Vision Worker.lnk"
```

---

## 📞 Support

For issues or questions, contact system administrator.

**Repository:** https://github.com/Commerry/Contaminate_chechk_Size
