const { app, BrowserWindow, dialog } = require('electron')
const path = require('path')
const fs = require('fs')
const { spawn } = require('child_process')
const AutoLaunch = require('auto-launch')
const http = require('http')

// Single Instance Lock - ป้องกันเปิดโปรแกรมซ้อน
const gotTheLock = app.requestSingleInstanceLock()

if (!gotTheLock) {
  // ถ้ามีโปรแกรมเปิดอยู่แล้ว ให้ปิดตัวนี้ทันที (ไม่ทำอะไร)
  app.quit()
} else {
  // ถ้ามีคนพยายามเปิดซ้ำ ปิดหน้าใหม่ทันที (second instance จะถูก quit อัตโนมัติ)
  app.on('second-instance', (event, commandLine, workingDirectory) => {
    // ไม่ทำอะไร - ให้ second instance quit ไปเลย
  })
}

app.commandLine.appendSwitch('disable-gpu-shader-disk-cache')
app.commandLine.appendSwitch('disable-http-cache')

const safeUserDataPath = path.join(app.getPath('temp'), 'user-display-modern')
if (!fs.existsSync(safeUserDataPath)) {
  fs.mkdirSync(safeUserDataPath, { recursive: true })
}
app.setPath('userData', safeUserDataPath)

// Auto-launch configuration
const autoLauncher = new AutoLaunch({
  name: 'PSE Vision Worker',
  path: app.getPath('exe'),
  isHidden: false
})

// Start backend web server on port 64020
let backendProcess = null

function startBackendServer() {
  const isDev = !app.isPackaged
  
  let pythonScriptsPath, pythonExecutable
  if (isDev) {
    pythonScriptsPath = path.join(__dirname, '..', '..', 'python_scripts')
    pythonExecutable = 'python'
  } else {
    const resourcesPath = process.resourcesPath
    pythonScriptsPath = path.join(resourcesPath, 'python_scripts')
    pythonExecutable = path.join(resourcesPath, 'python_embedded', 'python.exe')
  }
  
  const backendScript = path.join(pythonScriptsPath, 'backend_server.py')
  
  if (!fs.existsSync(backendScript)) {
    console.warn('❌ Backend script not found:', backendScript)
    return
  }
  
  if (!isDev && !fs.existsSync(pythonExecutable)) {
    console.error('❌ Bundled Python not found:', pythonExecutable)
    return
  }
  
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
  console.log('🚀 Starting backend server on port 64020...')
  console.log('🐍 Python:', pythonExecutable)
  console.log('📄 Backend script:', backendScript)
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
  
  backendProcess = spawn(pythonExecutable, [backendScript], {
    cwd: pythonScriptsPath,
    env: { ...process.env, FLASK_PORT: '64020' },
    detached: false,
    stdio: 'inherit'
  })
  
  backendProcess.on('error', (err) => {
    console.error('❌ Failed to start backend:', err)
  })
  
  backendProcess.on('exit', (code, signal) => {
    console.log(`⚠️  Backend exited: code=${code}, signal=${signal}`)
  })
}

function createWindow() {
  const win = new BrowserWindow({
    width: 1360,
    height: 860,
    minWidth: 1200,
    minHeight: 720,
    fullscreen: true,  // ✅ เปิดโปรแกรมแบบเต็มจอทันที
    title: 'PSE Vision - Object Measurement System',
    autoHideMenuBar: true,
    icon: path.join(__dirname, '..', 'public', 'Logo_checksize.ico'),
    webPreferences: {
      preload: path.join(__dirname, 'preload.cjs'),
      contextIsolation: true,
      nodeIntegration: false,
      webSecurity: false
    }
  })

  // ✅ Load Desktop App (React) จาก file:// 
  const indexPath = path.join(__dirname, '..', 'dist', 'index.html')

  if (!fs.existsSync(indexPath)) {
    dialog.showErrorBox(
      'Build not found',
      'ไม่พบไฟล์ dist/index.html\nกรุณารันคำสั่ง npm run build ก่อน'
    )
    app.quit()
    return
  }

  console.log('🖥️  Loading Desktop App from:', indexPath)
  win.loadFile(indexPath)
}

// Health check - wait for backend to start
async function waitForBackend(maxAttempts = 30, intervalMs = 1000) {
  console.log('⏳ Waiting for backend to start...')
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      await new Promise((resolve, reject) => {
        const req = http.get('http://localhost:64020/api/camera/status', (res) => {
          res.statusCode === 200 ? resolve() : reject(new Error(`HTTP ${res.statusCode}`))
        })
        req.on('error', reject)
        req.setTimeout(1000)
      })
      console.log(`✅ Backend ready (attempt ${attempt})`)
      return true
    } catch {
      console.log(`⏳ Not ready yet (${attempt}/${maxAttempts})`)
      if (attempt < maxAttempts) await new Promise(r => setTimeout(r, intervalMs))
    }
  }
  console.warn('⚠️ Backend health check timed out, continuing anyway')
  return false
}

app.whenReady().then(async () => {
  // Enable auto-launch on startup (only in production)
  if (app.isPackaged) {
    try {
      const isEnabled = await autoLauncher.isEnabled()
      if (!isEnabled) {
        await autoLauncher.enable()
        console.log('Auto-launch enabled')
      }
    } catch (err) {
      console.error('Failed to enable auto-launch:', err)
    }
  }
  
  // Start backend server (runs in background)
  startBackendServer()
  
  // Wait for backend to be ready (health check)
  console.log('⏳ Waiting for backend to initialize...')
  await waitForBackend()  // ✅ Async health check แทน setTimeout
  
  createWindow()

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow()
  })
})

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    // Kill backend process when app closes
    if (backendProcess) {
      backendProcess.kill()
    }
    app.quit()
  }
})

app.on('before-quit', () => {
  // Cleanup backend process
  if (backendProcess) {
    backendProcess.kill()
  }
})
