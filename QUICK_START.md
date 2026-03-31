# 🚀 PSE Vision - Quick Start Guide

**ระบบตรวจสอบขนาดวัตถุอัตโนมัติ | Object Measurement System**

---

## 📋 สิ่งที่ต้องเตรียม (Prerequisites)

### สำหรับเครื่องเซิร์ฟเวอร์ (Backend + Admin Web):
- ✅ Windows 10/11 (64-bit)
- ✅ สิทธิ์ Administrator
- ✅ Internet connection (สำหรับดาวน์โหลด Node.js ถ้ายังไม่มี)
- ✅ OAK-D Camera (DepthAI)
- ✅ พื้นที่ว่าง 10 GB

### สำหรับ Desktop App (เครื่องคนงาน):
- ✅ Windows 10/11 (64-bit)
- ✅ เชื่อมต่อ LAN กับเครื่อง Backend

---

## 🎯 ขั้นตอนที่ 1: ติดตั้งบนเครื่องเซิร์ฟเวอร์

### วิธีที่ 1: ติดตั้งแบบอัตโนมัติ (แนะนำ)

1. **คลิกขวา PowerShell → Run as Administrator**

2. **รันคำสั่งให้สิทธิ์:**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. **เข้าไปยังโฟลเดอร์โปรเจค:**
   ```powershell
   cd "d:\PSE vision Project\Contaminate_chechk_Size"
   ```

4. **รันสคริปต์ติดตั้ง:**
   ```powershell
   .\INSTALL_COMPLETE_SYSTEM.ps1
   ```

5. **รอให้ติดตั้งเสร็จ** (ประมาณ 5-10 นาที)
   - ติดตั้ง Python libraries
   - ติดตั้ง Node.js packages
   - Build Admin Web
   - ตั้งค่า Auto-startup

6. **เมื่อเสร็จแล้ว ระบบจะถาม:** ทดสอบรันหรือไม่?
   - กด `y` เพื่อทดสอบทันที
   - หรือกด `n` เพื่อข้าม

### วิธีที่ 2: ติดตั้งแบบ Manual

ดูรายละเอียดใน [README.md](README.md) หัวข้อ "การติดตั้ง"

---

## 🎯 ขั้นตอนที่ 2: รันระบบครั้งแรก

### เริ่มต้น Backend + Admin Web:

**วิธีที่ 1:** Double-click ที่ไฟล์:
```
PSE_VISION_STARTUP.bat
```

**วิธีที่ 2:** รันจาก Command Prompt:
```batch
cd "d:\PSE vision Project\Contaminate_chechk_Size"
PSE_VISION_STARTUP.bat
```

**วิธีที่ 3:** รัน Backend โดยตรง:
```powershell
cd python_scripts
python backend_server.py
```

### เข้าใช้งาน Admin Web:

เปิด Browser ไปที่:
- **เครื่องเซิร์ฟเวอร์:** http://localhost:64020
- **เครื่องอื่นในเครือข่าย:** http://[IP-ของเครื่องเซิร์ฟเวอร์]:64020

---

## 🎯 ขั้นตอนที่ 3: Build Desktop App (ถ้าต้องการ)

1. **รันสคริปต์ Build:**
   ```batch
   BUILD_DESKTOP_APP.bat
   ```

2. **รอให้ build เสร็จ** (ประมาณ 5-10 นาที)

3. **ไฟล์ installer จะอยู่ที่:**
   ```
   user_display\dist-installer\PSE Vision Worker Display-Setup-1.0.0.exe
   ```

4. **นำไฟล์ไปติดตั้งบนเครื่องคนงาน:**
   - Double-click ไฟล์ .exe
   - ทำตามขั้นตอนการติดตั้ง
   - Desktop App จะรัน Backend ในตัวเอง (ไม่ต้องพึ่งเซิร์ฟเวอร์)

---

## ✅ ตรวจสอบว่าติดตั้งสำเร็จ

### 1. ตรวจสอบ Backend:
```powershell
# ทดสอบ API
Invoke-WebRequest -Uri "http://localhost:64020/api/health" -UseBasicParsing
# ควรได้ผลลัพธ์: {"status":"ok"}
```

### 2. ตรวจสอบ Admin Web:
- เปิด Browser → http://localhost:64020
- ควรเห็นหน้า Dashboard

### 3. ตรวจสอบ Camera:
- ไปที่ Admin Web → Camera
- ควรเห็น Video feed จากกล้อง

---

## 🛠️ หากมีปัญหา

### ปัญหา: ไม่พบ Node.js

**วิธีแก้:**
1. ดาวน์โหลด Node.js จาก: https://nodejs.org/
2. ติดตั้ง LTS version (แนะนำ v20.x)
3. Restart PowerShell
4. รัน `INSTALL_COMPLETE_SYSTEM.ps1` อีกครั้ง

### ปัญหา: Backend รันไม่ได้

**วิธีแก้:**
```powershell
# ติดตั้ง Python dependencies ใหม่
cd python_scripts
pip install -r backend_requirements.txt --upgrade
```

### ปัญหา: Port 64020 ถูกใช้งาน

**วิธีแก้:**
```powershell
# หา process ที่ใช้ port
netstat -ano | findstr :64020

# ปิด process (แทน [PID] ด้วยเลข PID ที่ได้)
taskkill /PID [PID] /F
```

### ปัญหา: Frontend Build ล้มเหลว

**วิธีแก้:**
```powershell
cd frontend
Remove-Item -Recurse -Force node_modules
npm install --legacy-peer-deps
npm run build
```

---

## 📚 เอกสารเพิ่มเติม

- **คู่มือใช้งานฉบับสมบูรณ์:** [README.md](README.md)
- **ประวัติการเปลี่ยนแปลง:** [CHANGELOG.md](CHANGELOG.md)

---

## 📞 การติดต่อ

หากมีปัญหาหรือข้อสงสัย กรุณาติดต่อทีมพัฒนา

---

**Version:** 1.0.0  
**Last Update:** March 30, 2026
