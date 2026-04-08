# PSE Vision - Object Measurement System  

**Version 1.0.0** | ระบบตรวจสอบขนาดวัตถุอัตโนมัติด้วย OAK-D Camera

---

## 🚀 Quick Start (ง่ายมาก!)

### ติดตั้ง
```batch
INSTALL.bat
```
รอ 5-10 นาที → ระบบรันขึ้นมาเลย!

### ใช้งาน
- **Admin Web:** http://localhost:64020
- **Desktop App:** ติดตั้งแล้วอัตโนมัติ

### Auto-Start ตอนเปิดเครื่อง
1. กด `Win + R`
2. พิมพ์: `shell:startup` กด Enter
3. Copy `START.bat` วางในโฟลเดอร์นั้น

จบ! รีบูตเครื่องระบบจะรันเอง

---

## 📦 Requirements

- Windows 10/11 (64-bit)
- Python 3.8+
- Node.js 16+
- OAK-D Camera (สำหรับเครื่อง Backend)

---

## Files

| File | Purpose |
|------|---------|
| `INSTALL.bat` | ติดตั้งทุกอย่าง (รันครั้งเดียว) |
| `START.bat` | รันระบบ (ใส่ Startup ได้) |
| `START_WORKER_MODE.bat` | รันแบบ Worker (Desktop App only) |

---

## Troubleshooting

### ติดตั้งไม่ผ่าน
ติดตั้ง Python และ Node.js ก่อน:
- Python: https://www.python.org/downloads/
- Node.js: https://nodejs.org/

### Frontend ไม่แสดง
```batch
cd frontend
npm run build
```

### Port 64020 ถูกใช้
```batch
netstat -ano | findstr :64020
taskkill /F /PID <PID>
```

---

**GitHub:** https://github.com/Commerry/Contaminate_chechk_Size
