# สรุปการเปลี่ยนแปลง - PSE Vision System

## 🎯 สิ่งที่แก้ไข (5 มี.ค. 2569)

### 1. ✅ เปลี่ยนไอคอนโปรแกรม
- **เดิม**: `src/assets/logo.ico` (ไอคอน Electron)
- **ใหม่**: `public/Logo_checksize.ico` (โลโก้ PSE Vision)
- **แก้ไขที่**: 
  - `electron/main.cjs` → เปลี่ยน path ไอคอน
  - `package.json` → เปลี่ยน icon ใน build config

### 2. ✅ ระบบ Auto-Start เมื่อเปิดเครื่อง
- **ติดตั้ง**: `auto-launch` package
- **ฟีเจอร์**:
  - โปรแกรม Desktop App จะเปิดทันทีเมื่อ Windows เริ่มต้น
  - Backend Server รันพร้อมกับโปรแกรม (background)
  - รอ 2 วินาทีให้ backend พร้อมก่อนเปิดหน้าต่างโปรแกรม
- **เงื่อนไข**: Auto-start จะเปิดเฉพาะใน Production (ติดตั้งแล้ว)
- **แก้ไขที่**: `electron/main.cjs`

### 3. ✅ เปลี่ยน Port เป็น 64020
- **Backend API**: Port **64020** (เดิม 5000)
- **Admin Web**: Port **64020** (เดิม 3000)
- **แก้ไขที่**:
  - `user_display/src/App.jsx` → Backend URL
  - `frontend/vite.config.js` → Frontend port และ proxy
  - `electron/main.cjs` → Backend start command

### 4. ✅ Backend Auto-Start
- **ฟีเจอร์**: Backend รันอัตโนมัติเมื่อเปิดโปรแกรม
- **รันแบบ**: Background (ไม่แสดงหน้าต่าง console)
- **Environment Variable**: `FLASK_PORT=64020`
- **ตรวจจับ Mode**:
  - **Development**: หา backend ที่ `../../python_scripts/`
  - **Production**: หา backend ที่ `resources/python_scripts/`

### 5. ✅ โลโก้ในหน้าโปรแกรม
- **ยังคงใช้**: `src/assets/logo.png` (PSE Vision logo)
- **แยกจาก**: ไอคอนโปรแกรม (Logo_checksize.ico)

---

## 📦 การสร้าง Installer

```powershell
cd user_display
npm run dist:win
```

**Installer จะมี**:
- ✅ โปรแกรม Desktop App (ไอคอน Logo_checksize.ico)
- ✅ Admin Web (Vue.js)
- ✅ Backend API (Python) - รันบน port 64020
- ✅ Auto-start เมื่อเปิดเครื่อง
- ✅ Shortcuts บน Desktop

---

## 🚀 การใช้งาน

### หลังติดตั้งครั้งแรก:

1. **โปรแกรมจะตั้งค่า Auto-start อัตโนมัติ**
   - ครั้งต่อไปที่เปิดเครื่อง โปรแกรมจะเปิดเองทันที

2. **Backend รันทันที** (background)
   - ไม่มีหน้าต่าง console แสดง
   - รันบน port **64020**
   - รอ 2 วินาทีจึงเปิดหน้าต่างโปรแกรม

3. **Desktop App เปิดขึ้นมา**
   - แสดงหน้าต่างโปรแกรม (Worker Display)
   - เชื่อมต่อกับ Backend port 64020

### เข้าถึง Admin Web:

```
http://localhost:64020
```

หรือเปิด browser ไปที่ไฟล์:
```
C:\Program Files\PSE Vision Worker Display\resources\frontend\index.html
```

---

## 🔧 การปิด Auto-Start (ถ้าต้องการ)

### วิธีที่ 1: ผ่าน Windows Settings
```
1. เปิด Task Manager (Ctrl+Shift+Esc)
2. ไปที่แท็บ "Startup"
3. หา "PSE Vision Worker"
4. คลิกขวา → Disable
```

### วิธีที่ 2: ผ่าน Windows Settings
```
1. เปิด Settings → Apps → Startup
2. หา "PSE Vision Worker"
3. ปิด toggle
```

---

## 📊 Port Summary

| Service | Port | URL |
|---------|------|-----|
| Backend API | 64020 | http://localhost:64020/api/ |
| Admin Web | 64020 | http://localhost:64020 |
| Desktop App | - | Connected to port 64020 |
| WebSocket | 64020 | ws://localhost:64020 |

---

## ✅ Checklist การทำงาน

- [x] เปลี่ยนไอคอนโปรแกรมเป็น Logo_checksize.ico
- [x] Auto-start เมื่อเปิดเครื่อง (Production only)
- [x] Backend รันอัตโนมัติบน port 64020
- [x] Desktop App เชื่อมต่อ port 64020
- [x] Admin Web ใช้ port 64020
- [x] Backend รัน background (ไม่แสดงหน้าต่าง)
- [x] โลโก้ในหน้าโปรแกรมยังคงใช้ logo.png

---

## 🎓 สรุป

**คำสั่งเดียวจบ**:
```powershell
cd user_display
npm run dist:win
```

**ผลลัพธ์**:
- Installer .exe ขนาด ~171 MB
- ติดตั้งครบทุกอย่าง (Desktop + Web + Backend)
- Auto-start เมื่อเปิดเครื่อง
- ใช้ port 64020 ทั้งระบบ
- ไอคอนโปรแกรมถูกต้อง (Logo_checksize.ico)

---

© 2026 PSE Vision Project
