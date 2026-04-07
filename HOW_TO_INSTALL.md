# 📦 วิธีติดตั้ง PSE Vision บนเครื่องใหม่

**อัพเดท:** ไฟล์ทั้งหมด Build เสร็จแล้ว ✅  
**วันที่:** 7 เมษายน 2026

---

## 🎯 สำหรับเครื่อง Backend (เครื่องต่อกล้อง)

### วิธีที่ 1: Clone จาก GitHub (แนะนำ) ⭐

```powershell
# 1. ติดตั้ง Git (ถ้ายังไม่มี)
winget install Git.Git

# 2. ติดตั้ง Python 3.8+
winget install Python.Python.3.12

# 3. Clone โปรเจค
cd D:\
git clone https://github.com/Commerry/Contaminate_chechk_Size.git
cd Contaminate_chechk_Size

# 4. ติดตั้ง Python packages
INSTALL_SIMPLE.bat
```

### วิธีที่ 2: Copy โฟลเดอร์ทั้งหมด

1. **Copy โฟลเดอร์** `Contaminate_chechk_Size` ทั้งหมดมายังเครื่องใหม่

2. **ติดตั้ง Python 3.8+** (ถ้ายังไม่มี):
   ```powershell
   winget install Python.Python.3.12
   ```

3. **รันสคริปต์ติดตั้ง:**
   ```batch
   INSTALL_SIMPLE.bat
   ```

---

## 🚀 รันระบบ

### เริ่มต้น Backend Server:

**วิธีที่ 1:** Double-click
```
PSE_VISION_STARTUP.bat
```

**วิธีที่ 2:** รันจาก Command Line
```batch
cd "D:\Contaminate_chechk_Size"
PSE_VISION_STARTUP.bat
```

**วิธีที่ 3:** รัน Python โดยตรง
```batch
cd python_scripts
python backend_server.py
```

### เข้าใช้งาน Admin Web:

- **เครื่องเดียวกัน:** http://localhost:64020
- **เครื่องอื่นในเครือข่าย:** http://[IP-Address]:64020

---

## 💻 สำหรับเครื่องคนงาน (Worker Display)

### ติดตั้ง Desktop App:

1. ไปที่โฟลเดอร์:
   ```
   user_display\dist-installer\
   ```

2. Double-click ติดตั้ง:
   ```
   PSE Vision Worker Display-Setup-1.0.0.exe
   ```

3. ตั้งค่า IP ของเครื่อง Backend ในโปรแกรม

4. เสร็จสิ้น! โปรแกรมจะรันอัตโนมัติเมื่อเปิดเครื่อง

---

## 📋 ข้อกำหนดระบบ

### เครื่อง Backend:
- ✅ Windows 10/11 (64-bit)
- ✅ Python 3.8+ หรือ Python Embedded (มีอยู่ในโฟลเดอร์ `python_embedded/`)
- ✅ RAM 8 GB ขึ้นไป
- ✅ OAK-D Camera (DepthAI)
- ✅ พื้นที่ว่าง 10 GB

### เครื่อง Worker:
- ✅ Windows 10/11 (64-bit)
- ✅ RAM 4 GB ขึ้นไป
- ✅ เชื่อมต่อ LAN กับเครื่อง Backend

---

## 🔧 การใช้งาน Python Embedded (ไม่ต้องติดตั้ง Python)

ถ้าไม่ต้องการติดตั้ง Python ในระบบ สามารถใช้ Python Embedded ที่มีอยู่แล้ว:

### ติดตั้ง Packages:
```batch
cd python_scripts
..\python_embedded\python.exe -m pip install -r backend_requirements.txt
```

### รัน Backend:
```batch
cd python_scripts
..\python_embedded\python.exe backend_server.py
```

---

## 📁 โครงสร้างไฟล์สำคัญ

```
Contaminate_chechk_Size/
├── INSTALL_SIMPLE.bat              ← สคริปต์ติดตั้งแบบง่าย
├── PSE_VISION_STARTUP.bat          ← รัน Backend Server
├── HOW_TO_INSTALL.md               ← คู่มือนี้
│
├── frontend/dist/                  ← Admin Web (Build แล้ว ✅)
├── user_display/dist-installer/    ← Desktop App Installer (Build แล้ว ✅)
│   └── PSE Vision Worker Display-Setup-1.0.0.exe
│
├── python_scripts/
│   ├── backend_server.py           ← Main Backend Server
│   ├── backend_requirements.txt    ← Python Dependencies
│   ├── configurations.json         ← การตั้งค่าการตรวจสอบ
│   └── machines.json               ← ข้อมูลเครื่องจักร
│
└── python_embedded/                ← Python แบบพกพา (ไม่ต้องติดตั้ง)
    └── python.exe
```

---

## ⚠️ Troubleshooting

### ปัญหา: ไม่พบ Python
**วิธีแก้:**
1. ติดตั้ง Python: https://www.python.org/downloads/
2. หรือใช้ Python Embedded ที่มีอยู่แล้ว

### ปัญหา: Port 64020 ถูกใช้งานอยู่
**วิธีแก้:**
```batch
# หยุด process ที่ใช้ port 64020
netstat -ano | findstr :64020
taskkill /F /PID [PID_NUMBER]
```

### ปัญหา: ไม่เชื่อมต่อกล้อง OAK-D
**วิธีแก้:**
1. ตรวจสอบสาย USB 3.0
2. ติดตั้ง Driver: https://docs.luxonis.com/en/latest/
3. รีสตาร์ทกล้อง: `python reset_camera.py`

---

## 📞 การสนับสนุน

- **Repository:** https://github.com/Commerry/Contaminate_chechk_Size
- **Issues:** https://github.com/Commerry/Contaminate_chechk_Size/issues

---

**สร้างโดย:** PSE Vision Project  
**เวอร์ชัน:** 1.0.0  
**อัพเดท:** 7 เมษายน 2026
