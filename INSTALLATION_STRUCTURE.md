# 📦 PSE Vision - Installation Package Structure
# โครงสร้างการจัดเก็บไฟล์ติดตั้ง

```
PSE Vision/
│
├── 📖 QUICK_START.md                    ← เริ่มต้นใช้งาน (อ่านก่อน!)
├── 📖 README.md                         ← คู่มือฉบับเต็ม
├── 📝 CHANGELOG.md                      ← บันทึกการเปลี่ยนแปลง
│
├── 🔧 INSTALL_COMPLETE_SYSTEM.ps1       ← ติดตั้งระบบสมบูรณ์ (รันนี้ก่อน!)
├── 🔧 BUILD_DESKTOP_APP.bat             ← Build Desktop App (.exe)
├── ✅ CHECK_INSTALLATION_FILES.ps1      ← ตรวจสอบไฟล์ครบถ้วน
│
├── 📁 python_scripts/                   ← Backend Server
│   ├── backend_server.py                ← Main server
│   ├── backend_extension.py             ← Extensions
│   ├── backend_requirements.txt         ← Python dependencies
│   ├── configurations.json              ← Config templates
│   ├── system_config.py                 ← System config handler
│   └── database/                        ← Database modules
│
├── 📁 frontend/                         ← Admin Web (Vue.js)
│   ├── src/                             ← Source code
│   ├── dist/                            ← Built files (after install)
│   ├── package.json                     ← Node.js dependencies
│   └── vite.config.js                   ← Build config
│
├── 📁 user_display/                     ← Desktop App (Electron)
│   ├── src/                             ← React source code
│   ├── electron/                        ← Electron main process
│   ├── dist-installer/                  ← Built .exe (after build)
│   ├── package.json                     ← Node.js dependencies
│   └── vite.config.js                   ← Build config
│
├── 📁 python_embedded/                  ← Python Embedded (ถ้ามี)
│   └── python.exe                       ← Python interpreter
│
├── 📁 config/                           ← Config files
│   └── database/                        ← Database config
│
├── 📁 logs/                             ← Log files
│
├── 📄 config.json                       ← Global config
├── 📄 lots.json                         ← Lots data
├── 📄 system_config.db                  ← SQLite database
│
└── ⚙️ PSE_VISION_STARTUP.bat           ← Auto-start (สร้างโดย installer)
```

---

## 📝 คำอธิบายไฟล์สำคัญ

### เอกสาร:
- **QUICK_START.md** - คู่มือเริ่มต้นฉบับย่อ อ่านก่อนใช้งาน!
- **README.md** - คู่มือฉบับเต็ม รายละเอียดทุกอย่าง
- **CHANGELOG.md** - ประวัติการแก้ไขและอัพเดท

### สคริปต์ติดตั้ง:
- **INSTALL_COMPLETE_SYSTEM.ps1** - ติดตั้งระบบอัตโนมัติ (รันนี้ก่อน!)
- **BUILD_DESKTOP_APP.bat** - Build Desktop App เป็นไฟล์ .exe
- **CHECK_INSTALLATION_FILES.ps1** - ตรวจสอบไฟล์ครบถ้วนหรือไม่

### โค้ดหลัก:
- **python_scripts/** - Backend + API (Flask + Socket.IO)
- **frontend/** - Admin Web (Vue.js 3 + Vite)
- **user_display/** - Desktop App (React + Electron)

### Configuration:
- **config.json** - ค่าตั้งต้นระบบ
- **system_config.db** - ฐานข้อมูล SQLite
- **python_scripts/configurations.json** - Template สำหรับ config ตรวจสอบ

---

## 🎯 ลำดับการติดตั้ง

### ขั้นตอนที่ 1: ตรวจสอบไฟล์
```powershell
.\CHECK_INSTALLATION_FILES.ps1
```

### ขั้นตอนที่ 2: ติดตั้งระบบ
```powershell
.\INSTALL_COMPLETE_SYSTEM.ps1
```

### ขั้นตอนที่ 3: Build Desktop App (ถ้าต้องการ)
```batch
BUILD_DESKTOP_APP.bat
```

---

## 📊 ขนาดไฟล์โดยประมาณ

| Component | Size | Description |
|-----------|------|-------------|
| python_scripts/ | ~500 MB | Backend + dependencies |
| frontend/ | ~200 MB | Admin Web + node_modules |
| user_display/ | ~300 MB | Desktop App + node_modules |
| python_embedded/ | ~150 MB | Python Embedded (ถ้ามี) |
| Desktop App .exe | ~250 MB | Built installer |
| **Total** | **~1.4 GB** | รวมทุกอย่าง |

---

## 🔐 ไฟล์ที่ไม่ควรลบ

### ห้ามลบ (จำเป็นต่อการทำงาน):
- python_scripts/
- frontend/src/ และ frontend/dist/
- user_display/src/ และ user_display/electron/
- config/
- ไฟล์ .json ทั้งหมด

### ลบได้ (สามารถสร้างใหม่):
- node_modules/ (ทั้ง frontend และ user_display)
- python_scripts/__pycache__/
- logs/*.log (log files)
- frontend/dist/ (build ใหม่ได้)
- user_display/dist-installer/ (build ใหม่ได้)

### ลบได้ (ไม่จำเป็น):
- .venv/ (virtual environment)
- .vscode/ (VS Code settings)

---

**อัพเดทล่าสุด:** 30 มีนาคม 2026
