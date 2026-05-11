# PSE Vision - User Display (Desktop App)

แอปพลิเคชันสำหรับคนงาน (Worker Interface) ใช้วัดขนาดวัตถุด้วย Computer Vision แบบ Real-time

---

## ⚡ Quick Start

### 1. Development Mode

```bash
cd user_display
npm install
npm run desktop
```

### 2. Production Build

```bash
cd user_display
npm run build
npm run desktop
```

---

## 📋 Features

### ✨ หน้าจอแสดงผลแบบ Real-time
- แสดงภาพกล้องแบบ live streaming
- แสดง ROI (Region of Interest) และกรอบตรวจจับ
- แสดงผลการวัดแบบ real-time

### 🏭 เลือกเครื่องจักร
- ดึงรายการเครื่องจักรจาก database
- เลือกเครื่องจักรที่ต้องการใช้งาน
- แสดงสถานะและข้อมูลเครื่องจักร

### ⚙️ เลือก Configuration
- ดึงรายการ configurations จาก database
- เลือก configuration ที่วิศวกรตั้งไว้
- แสดงค่า target และ tolerance

### 📊 แสดงผลการวัด
- สถานะ: **PASS** (สีเขียว) หรือ **FAIL** (สีแดง)
- แสดงขนาดที่วัดได้ (mm²)
- แสดงเปอร์เซ็นต์เทียบกับ target
- เก็บประวัติการวัดย้อนหลัง

### 🎨 Modern UI/UX
- Theme สีขาวสะอาดตา
- Responsive design (ปรับขนาดหน้าจออัตโนมัติ)
- Modern fonts (Inter & Poppins)
- PSE Vision logo

---

## 🏗️ Technology Stack

- **React 18.3.1** - UI framework
- **Vite 5.4.21** - Build tool
- **Electron 37.2.0** - Desktop app wrapper
- **Socket.IO Client 4.8.1** - Real-time communication
- **Google Fonts** - Inter & Poppins

---

## 📦 Project Structure

```
user_display/
├── src/
│   ├── App.jsx              # Main React component
│   ├── main.js              # React entry point
│   ├── style.css            # Global styles
│   └── assets/
│       └── logo.png         # PSE Vision logo
│
├── electron/
│   ├── main.cjs             # Electron main process
│   └── preload.cjs          # Preload script
│
├── dist/                    # Production build
├── package.json
└── vite.config.js
```

---

## 🔧 Configuration

### Environment Variables

สร้างไฟล์ `.env` ในโฟลเดอร์ `user_display/`:

```env
VITE_BACKEND_URL=http://localhost:64020
```

### Backend Connection

App จะเชื่อมต่อไปที่:
- **Backend API**: `http://localhost:5000`
- **WebSocket**: `ws://localhost:5000`

---

## 🚀 Build & Package

### Build Production

```bash
npm run build
```

### Run Desktop App

```bash
npm run desktop
```

### Package เป็น Installer

ติดตั้ง electron-builder:
```bash
npm install electron-builder --save-dev
```

เพิ่มใน `package.json`:
```json
{
  "scripts": {
    "dist": "npm run build && electron-builder"
  },
  "build": {
    "appId": "com.pse.vision.worker",
    "productName": "PSE Vision Worker Display",
    "directories": {
      "output": "release"
    },
    "files": [
      "dist/**/*",
      "electron/**/*",
      "package.json"
    ],
    "win": {
      "target": ["nsis"],
      "icon": "src/assets/logo.ico"
    }
  }
}
```

สร้าง installer:
```bash
npm run dist
```

---

## 📖 Usage

### 1. เปิดโปรแกรม

```bash
npm run desktop
```

### 2. เลือกเครื่องจักร

จาก dropdown ด้านขวา → เลือกเครื่องที่ต้องการใช้

### 3. เลือก Configuration

จาก dropdown configuration → เลือก config ที่วิศวกรตั้งค่าไว้

### 4. เริ่มการวัด

กดปุ่ม **"Start Measurement" (สีเขียว)**

### 5. ดูผลลัพธ์

- หน้าจอจะแสดงภาพกล้อง real-time
- แสดง ROI และกรอบตรวจจับ
- แสดงผลการวัด: **PASS** ✅ หรือ **FAIL** ❌

### 6. หยุดการวัด

กดปุ่ม **"Stop Measurement" (สีแดง)**

---

## 🔌 API Integration

### GET /api/machines
ดึงรายการเครื่องจักร (จาก database)

### GET /api/configurations
ดึงรายการ configurations

### POST /api/measurement/start
เริ่มการวัด

### POST /api/measurement/stop
หยุดการวัด

### WebSocket Events
- `frame_update` - รับภาพกล้อง real-time
- `measurement_update` - รับผลการวัด

---

## 🐛 Troubleshooting

### ปัญหา: Blank screen

```bash
rm -rf node_modules dist
npm install
npm run build
npm run desktop
```

### ปัญหา: ไม่แสดงรายการเครื่องจักร

1. ตรวจสอบ backend ทำงาน (http://localhost:5000)
2. ตรวจสอบ database connection
3. รัน SQL script: `config/database/create_machines_table.sql`

### ปัญหา: Logo ไม่แสดง

```bash
cp frontend/Icon/output-onlinepngtools_PSE.png user_display/src/assets/logo.png
npm run build
```

---

## 📄 License

© 2026 PSE Vision Project
