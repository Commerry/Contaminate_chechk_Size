# PSE Vision - ระบบตรวจสอบขนาดวัตถุอัตโนมัติ
**Object Measurement & Quality Inspection System**

ระบบตรวจสอบขนาดและคุณภาพวัตถุแบบอัตโนมัติด้วย OAK-D Camera (DepthAI)  
Version 1.0.0 | March 2026

---

## � Quick Links

- **🚀 [Quick Start Guide](QUICK_START.md)** - เริ่มต้นใช้งานฉบับย่อ (อ่านก่อน!)
- **📦 [Installation Structure](INSTALLATION_STRUCTURE.md)** - โครงสร้างไฟล์และคำอธิบาย
- **📝 [Changelog](CHANGELOG.md)** - ประวัติการเปลี่ยนแปลง
- **✅ Check Installation Files** - รัน `.\CHECK_INSTALLATION_FILES.ps1`

---

## �📋 ภาพรวมระบบ

PSE Vision ประกอบด้วย 3 ส่วนหลัก:

1. **Backend Server** - Flask API + ระบบกล้อง + Socket.IO (พอร์ต 64020)
2. **Admin Web** - หน้าเว็บจัดการระบบ (Vue.js 3)
3. **Desktop App** - โปรแกรมสำหรับคนงาน (React + Electron)

---

## 🚀 การติดตั้ง (Installation)

### วิธีที่ 1: ติดตั้งบนเครื่องเซิร์ฟเวอร์ (Backend + Admin Web)

**สำหรับเครื่องที่ไม่มี Python, Node.js:**

```powershell
# 1. เปิด PowerShell แบบ Administrator
# 2. รันคำสั่ง:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
cd "d:\PSE vision Project\Contaminate_chechk_Size"
.\INSTALL_COMPLETE_SYSTEM.ps1
```

**สคริปต์จะ:**
- ✅ ตรวจสอบและติดตั้ง Python + libraries
- ✅ ตรวจสอบและติดตั้ง Node.js packages
- ✅ Build Admin Web (frontend/dist)
- ✅ สร้างสคริปต์ Auto-Start
- ✅ เพิ่มใน Windows Startup (รันอัตโนมัติเมื่อเปิดเครื่อง)

### วิธีที่ 2: Build Desktop App (เครื่องคนงาน)

```batch
# รันคำสั่ง:
BUILD_DESKTOP_APP.bat

# ไฟล์ติดตั้งจะอยู่ที่: user_display\dist-installer\
# ไฟล์: PSE Vision Worker Display-Setup-1.0.0.exe
```

---

## 💻 การใช้งานประจำวัน

### รัน Backend + Admin Web

```batch
# วิธีที่ 1: ใช้ startup script (สร้างอัตโนมัติหลังติดตั้ง)
PSE_VISION_STARTUP.bat

# วิธีที่ 2: รัน Backend โดยตรง
cd python_scripts
python backend_server.py
```

### เข้าใช้งาน Admin Web

- **เครื่องเดียวกัน:** http://localhost:64020
- **เครื่องอื่นในเครือข่าย:** http://[IP-Address]:64020

### หยุด Backend

กด `Ctrl + C` ใน Terminal

---

## 📁 โครงสร้างโปรเจค

```
PSE Vision/
├── INSTALL_COMPLETE_SYSTEM.ps1  ← ติดตั้งระบบสมบูรณ์
├── BUILD_DESKTOP_APP.bat        ← Build Desktop App (.exe)
├── PSE_VISION_STARTUP.bat       ← Auto-start (สร้างอัตโนมัติ)
├── README.md                    ← คู่มือนี้
├── CHANGELOG.md                 ← บันทึกการเปลี่ยนแปลง
│
├── python_scripts/              ← Backend Server (Flask)
│   ├── backend_server.py        ← Main server
│   ├── backend_extension.py     ← Extensions
│   ├── backend_requirements.txt ← Python dependencies
│   ├── configurations.json      ← กำหนดค่าการตรวจสอบ
│   ├── system_config.py         ← ระบบ Config
│   └── database/                ← Database modules (SQLite)
│
├── frontend/                    ← Admin Web (Vue.js 3)
│   ├── src/                     ← Source code
│   ├── dist/                    ← Built files
│   └── package.json
│
├── user_display/                ← Desktop App (React + Electron)
│   ├── src/                     ← Source code
│   ├── electron/                ← Electron main process
│   ├── dist-installer/          ← Built installer (.exe)
│   └── package.json
│
├── config/                      ← Configuration files
│   └── database/                ← Database config
│
├── logs/                        ← Log files
└── system_config.db             ← SQLite database
```

---

## ⚙️ ฟีเจอร์หลัก

### 1. Admin Web (พอร์ต 64020)
- 📊 Dashboard แสดงสถิติแบบ Realtime
- 🎯 จัดการ Configurations (กำหนดขนาดวัตถุที่ยอมรับได้)
- 🏭 จัดการเครื่องจักร (Machines)
- 📦 จัดการ Lots
- 📸 ดูภาพที่บันทึกไว้
- 📈 รายงานและสถิติ

### 2. Desktop App (สำหรับคนงาน)
- 🎥 แสดงภาพจากกล้องแบบ Realtime
- ✅ แสดงผลการตรวจสอบ (Pass/Fail)
- 📏 แสดงขนาดวัตถุ (mm²)
- 🔔 แจ้งเตือนเมื่อตรวจพบวัตถุที่ไม่ผ่าน
- 📊 สถิติการผลิต (Pass/Fail count)

### 3. Backend API
- 🎥 ระบบกล้อง OAK-D (DepthAI)
- 🔍 Object Detection + Depth Measurement
- 📐 คำนวณพื้นที่วัตถุ (mm²)
- ⚡ Socket.IO สำหรับ Realtime updates
- 💾 บันทึกภาพและข้อมูลใน Database

---

## 🔧 Configuration

### Configurations (กำหนดขนาดวัตถุ)

แก้ไขได้ที่: **Admin Web → Configurations**

ตัวอย่าง Configuration:
```json
{
  "id": 1,
  "name": "Very Small (100-500mm²)",
  "target_area_min": 100,
  "target_area_max": 500,
  "camera_id": 0,
  "depth_threshold": 1000
}
```

### Machines (เครื่องจักร)

แก้ไขได้ที่: **Admin Web → Machines**

```json
{
  "machine_id": "MC-01",
  "machine_name": "Machine 1",
  "location": "Line A",
  "ip_address": "10.2.100.90"
}
```

---

## 🛠️ การพัฒนา (Development)

### Backend Development

```powershell
cd python_scripts
python backend_server.py
```

### Frontend Development

```powershell
cd frontend
npm install
npm run dev    # Dev server port 5173
npm run build  # Build to dist/
```

### Desktop App Development

```powershell
cd user_display
npm install
npm start         # Dev mode
npm run dist:win  # Build installer
```

---

## 📊 System Requirements

### เครื่องเซิร์ฟเวอร์ (Backend)
- **OS:** Windows 10/11 (64-bit)
- **CPU:** Intel i5+ (แนะนำ i7+)
- **RAM:** 8 GB+ (แนะนำ 16 GB+)
- **Storage:** 10 GB
- **Camera:** OAK-D Camera (DepthAI)
- **Network:** Ethernet 1 Gbps

### เครื่องคนงาน (Desktop App)
- **OS:** Windows 10/11 (64-bit)
- **CPU:** Intel i3+
- **RAM:** 4 GB+
- **Storage:** 2 GB
- **Network:** LAN connection to Backend

---

## 🔍 Troubleshooting

### Backend รันไม่ได้

```powershell
# ตรวจสอบ Python dependencies
cd python_scripts
pip install -r backend_requirements.txt --upgrade
```

### Frontend Build ล้มเหลว

```powershell
cd frontend
Remove-Item -Recurse -Force node_modules
npm install --legacy-peer-deps
npm run build
```

### Desktop App Build ล้มเหลว

```powershell
cd user_display
Remove-Item -Recurse -Force node_modules
npm install --legacy-peer-deps
npm run dist:win
```

### Port 64020 ถูกใช้งาน

```powershell
# หา process ที่ใช้ port
netstat -ano | findstr :64020
# ปิด process
taskkill /PID [PID-NUMBER] /F
```

---

## 🔐 Security Notes

- Backend รันบน `0.0.0.0:64020` (เปิดให้เครือข่ายเข้าถึงได้)
- ไม่มีระบบ authentication (เหมาะสำหรับเครือข่ายภายใน)
- แนะนำให้ตั้ง Firewall บนเครื่อง Backend
- Database: SQLite (system_config.db)

---

## 📝 API Endpoints

### Backend API (พอร์ต 64020)

**Configurations:**
- `GET /api/configurations` - ดึงรายการ config ทั้งหมด
- `POST /api/configurations` - สร้าง config ใหม่
- `PUT /api/configurations/:id` - แก้ไข config
- `DELETE /api/configurations/:id` - ลบ config

**Machines:**
- `GET /api/machines` - ดึงรายการเครื่องจักร
- `POST /api/machines` - เพิ่มเครื่องจักร

**Measurement:**
- `POST /api/measurement/start` - เริ่มการวัด
- `POST /api/measurement/stop` - หยุดการวัด
- `GET /api/measurement/current-config` - ดู config ปัจจุบัน

**Camera:**
- `GET /api/camera/status` - สถานะกล้อง
- `GET /video_feed` - Video stream

**Socket.IO Events:**
- `measurement_result` - ผลการวัดแบบ Realtime
- `statistics_update` - อัพเดทสถิติ

---

## 📞 Support

หากมีปัญหาในการติดตั้งหรือใช้งาน กรุณาติดต่อทีมพัฒนา

---

## 📄 License

Copyright © 2026 PSE Vision Project  
ระบบนี้พัฒนาสำหรับใช้งานภายใน

---

**เวอร์ชัน:** 1.0.0  
**อัพเดทล่าสุด:** 30 มีนาคม 2026 
