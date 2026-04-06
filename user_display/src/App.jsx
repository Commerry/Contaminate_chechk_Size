import { useEffect, useMemo, useState, useRef } from 'react'
import { io } from 'socket.io-client'
import logoImg from './assets/logo.png'

// Backend URL - Backend รันบนเครื่องเดียวกัน (localhost)
// วิศวกรเข้า Admin Web ผ่าน http://<IP-ของเครื่องนี้>:64020/
const backendUrl = 'http://localhost:64020'

function App() {
  const [connected, setConnected] = useState(false)
  const [machines, setMachines] = useState([])
  const [selectedMachineId, setSelectedMachineId] = useState('')
  const [configs, setConfigs] = useState([])
  const [selectedConfigId, setSelectedConfigId] = useState('')
  const [lots, setLots] = useState([])  // 🎯 LOT list
  const [selectedLotId, setSelectedLotId] = useState('')  // 🎯 Selected LOT
  const [frameSrc, setFrameSrc] = useState('')
  const [measurements, setMeasurements] = useState([])
  const [running, setRunning] = useState(false)
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const [capturing, setCapturing] = useState(false)  // 📸 Capture state
  const [rubberType, setRubberType] = useState('black')  // 🔲 Rubber type: black | white

  // Statistics state
  const [stats, setStats] = useState({
    total: 0,
    pass: 0,
    fail: 0,
    near_pass: 0  // ใกล้เคียงผ่าน (สีเหลือง)
  })
  
  // ✅ Canvas refs สำหรับวาดกรอบ ROI
  const canvasRef = useRef(null)
  const videoImageRef = useRef(null)  // เก็บ Image object สำหรับวาดซ้ำ

  const selectedConfig = useMemo(
    () => configs.find((cfg) => String(cfg.id) === String(selectedConfigId)) || null,
    [configs, selectedConfigId]
  )

  const loadMachines = async () => {
    try {
      const response = await fetch(`${backendUrl}/api/machines`)
      const data = await response.json()
      if (data?.success) {
        setMachines(data.machines || [])
        // Select first machine by default
        if (!selectedMachineId && data.machines?.length) {
          setSelectedMachineId(data.machines[0].id)
        }
      } else {
        // Fallback to sample data if database is not ready
        const fallbackMachines = [
          { id: 'MC-01', name: 'Machine 01', status: 'active' },
          { id: 'MC-02', name: 'Machine 02', status: 'active' },
          { id: 'MC-03', name: 'Machine 03', status: 'active' }
        ]
        setMachines(fallbackMachines)
        setSelectedMachineId(fallbackMachines[0].id)
      }
    } catch (err) {
      console.error('Failed to load machines:', err)
      // Fallback to sample data
      const fallbackMachines = [
        { id: 'MC-01', name: 'Machine 01', status: 'active' },
        { id: 'MC-02', name: 'Machine 02', status: 'active' },
        { id: 'MC-03', name: 'Machine 03', status: 'active' }
      ]
      setMachines(fallbackMachines)
      setSelectedMachineId(fallbackMachines[0].id)
    }
  }

  const loadConfigs = async () => {
    try {
      const response = await fetch(`${backendUrl}/api/configurations`)
      const data = await response.json()
      if (data?.success) {
        setConfigs(data.configurations || [])
        if (!selectedConfigId && data.configurations?.length) {
          setSelectedConfigId(String(data.configurations[0].id))
        }
      } else {
        setError('โหลด configurations ไม่สำเร็จ')
      }
    } catch (err) {
      setError(`เชื่อมต่อ backend ไม่ได้: ${err.message}`)
    }
  }

  const loadLots = async () => {
    try {
      const response = await fetch(`${backendUrl}/api/lots`)
      const data = await response.json()
      if (data?.success) {
        setLots(data.lots || [])
        if (!selectedLotId && data.lots?.length) {
          setSelectedLotId(data.lots[0].id)
        }
      } else {
        console.warn('โหลด LOTs ไม่สำเร็จ')
      }
    } catch (err) {
      console.error('เชื่อมต่อ backend ไม่ได้ (LOTs):', err)
    }
  }

  const loadRubberType = async () => {
    try {
      const res = await fetch(`${backendUrl}/api/rubber/type`)
      const data = await res.json()
      if (data?.success) setRubberType(data.rubber_type || 'black')
    } catch (err) {
      console.warn('Could not load rubber type:', err)
    }
  }

  const toggleRubberType = async () => {
    const newType = rubberType === 'black' ? 'white' : 'black'
    try {
      const res = await fetch(`${backendUrl}/api/rubber/type`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ rubber_type: newType })
      })
      const data = await res.json()
      if (data?.success) setRubberType(data.rubber_type)
    } catch (err) {
      console.error('Failed to toggle rubber type:', err)
    }
  }

  const captureImage = async () => {
    if (!selectedLotId) {
      setError('กรุณาเลือก LOT ก่อนเก็บภาพ')
      return
    }
    if (!selectedMachineId) {
      setError('กรุณาเลือกเครื่องจักรก่อนเก็บภาพ')
      return
    }

    setCapturing(true)
    setError('')
    try {
      const selectedLot = lots.find(l => l.id === selectedLotId)
      const selectedMachine = machines.find(m => m.id === selectedMachineId)
      
      const response = await fetch(`${backendUrl}/api/capture`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          lot: selectedLot,
          machine: selectedMachine,
          rubber_type: rubberType  // ⚫/⚪ black | white
        })
      })
      
      const data = await response.json()
      if (data?.success) {
        alert(`✅ บันทึกภาพสำเร็จ!\nไฟล์: ${data.filename}`)
      } else {
        setError(`เก็บภาพไม่สำเร็จ: ${data.message}`)
      }
    } catch (err) {
      setError(`เก็บภาพไม่สำเร็จ: ${err.message}`)
    } finally {
      setCapturing(false)
    }
  }

  const startMeasurement = async () => {
    if (!selectedConfigId) {
      setError('กรุณาเลือก configuration ก่อน')
      return
    }

    setLoading(true)
    setError('')
    try {
      // 🔢 1. เปิด Multi-Object Detection Mode ก่อนเสมอ (ตรวจจับหลายชิ้นพร้อมกัน)
      const multiObjRes = await fetch(`${backendUrl}/api/camera/multi-object/start`, {
        method: 'POST'
      })
      const multiObjData = await multiObjRes.json()
      if (!multiObjData?.success) {
        console.warn('⚠️ ไม่สามารถเปิด Multi-Object Detection ได้')
      } else {
        console.log('✅ Multi-Object Detection Mode activated')
      }

      // ✅ 2. เปิด Contour Detection Mode (หลัง multi-object เสมอ)
      const contourRes = await fetch(`${backendUrl}/api/camera/contour/start`, {
        method: 'POST'
      })
      const contourData = await contourRes.json()
      if (!contourData?.success) {
        setError('ไม่สามารถเปิด Contour Detection Mode ได้')
        setLoading(false)
        return
      }
      
      // ✅ 3. เริ่ม measurement session
      const res = await fetch(`${backendUrl}/api/measurement/start`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          config_id: Number(selectedConfigId),
          machine_id: selectedMachineId,
          machine_name: machines.find((machine) => machine.id === selectedMachineId)?.name || '',
          lot_id: selectedLotId || null,
          lot_name: lots.find((l) => l.id === selectedLotId)?.name || ''
        })
      })
      const data = await res.json()
      if (data?.success) {
        setRunning(true)
      } else {
        setError(data?.error || 'เริ่มการวัดไม่สำเร็จ')
      }
    } catch (err) {
      setError(`เริ่มการวัดไม่สำเร็จ: ${err.message}`)
    } finally {
      setLoading(false)
    }
  }

  const stopMeasurement = async () => {
    setLoading(true)
    setError('')
    // Reset statistics when stopping measurement
    setStats({ total: 0, pass: 0, fail: 0, near_pass: 0 })
    try {
      // ✅ 1. หยุด measurement session
      const res = await fetch(`${backendUrl}/api/measurement/stop`, { method: 'POST' })
      const data = await res.json()
      
      // 🔢 2. ปิด Multi-Object Detection Mode
      const multiObjRes = await fetch(`${backendUrl}/api/camera/multi-object/stop`, {
        method: 'POST'
      })
      if (multiObjRes.ok) {
        console.log('✅ Multi-Object Detection Mode deactivated')
      }
      
      // ✅ 3. ปิด Contour Detection Mode
      const contourRes = await fetch(`${backendUrl}/api/camera/contour/stop`, {
        method: 'POST'
      })
      
      if (data?.success) {
        setRunning(false)
      } else {
        setError(data?.error || 'หยุดการวัดไม่สำเร็จ')
      }
    } catch (err) {
      setError(`หยุดการวัดไม่สำเร็จ: ${err.message}`)
    } finally {
      setLoading(false)
    }
  }
  
  // ✅ ฟังก์ชันวาดภาพและกรอบ ROI บน canvas
  const drawFrame = (frameDataUrl, detections = []) => {
    const canvas = canvasRef.current
    if (!canvas) {
      console.warn('❌ Canvas not found!')
      return
    }

    const ctx = canvas.getContext('2d')
    
    console.log(`🎨 Drawing frame with ${detections.length} detections`)
    
    // โหลดภาพ
    const img = new Image()
    img.onload = () => {
      // ตั้งขนาด canvas ตามขนาดภาพ
      canvas.width = img.width
      canvas.height = img.height
      
      console.log(`📐 Canvas size: ${canvas.width}x${canvas.height}`)
      
      // วาดภาพ
      ctx.drawImage(img, 0, 0)
      
      // วาดกรอบ ROI สำหรับแต่ละ detection
      if (detections && detections.length > 0) {
        console.log('🖌️ Drawing detection boxes:', detections)
        detections.forEach((detection, index) => {
          const bbox = detection.bbox
          if (!bbox || bbox.length !== 4) return
          
          const [x, y, w, h] = bbox
          const widthMm = detection.width_mm || 0
          const heightMm = detection.height_mm || 0
          const label = detection.label || `Object_${index + 1}`
          const confidence = detection.confidence || 0
          
          // 🎨 3-tier color system: pass (green), near_pass (yellow), fail (red)
          const status = detection.status || null
          let color, fillColor
          
          if (status === 'pass') {
            color = '#00ff00'  // เขียว - ผ่าน
            fillColor = 'rgba(0, 255, 0, 0.15)'
          } else if (status === 'near_pass') {
            color = '#ffff00'  // เหลือง - ใกล้เคียงผ่าน
            fillColor = 'rgba(255, 255, 0, 0.15)'
          } else if (status === 'fail') {
            color = '#ff0000'  // แดง - ไม่ผ่าน
            fillColor = 'rgba(255, 0, 0, 0.15)'
          } else {
            // No config loaded yet
            color = '#888888'
            fillColor = 'rgba(136, 136, 136, 0.15)'
          }
          
          // วาดกรอบ (เส้นบางลง)
          ctx.strokeStyle = color
          ctx.lineWidth = 1.5
          ctx.strokeRect(x, y, w, h)
          
          // วาดพื้นหลังโปร่งใส
          ctx.fillStyle = fillColor
          ctx.fillRect(x, y, w, h)
          
          // วาดขนาด W:xxx H:xxx ที่กลางกรอบ (ตัวอักษรเล็กลงอีก)
          if (widthMm > 0 && heightMm > 0) {
            const sizeText = `W:${Math.round(widthMm)} H:${Math.round(heightMm)}`
            ctx.font = 'bold 11px Arial'
            ctx.textAlign = 'center'
            ctx.textBaseline = 'middle'
            
            const textMetrics = ctx.measureText(sizeText)
            const textWidth = textMetrics.width + 8
            const textHeight = 16
            const textX = x + w / 2
            const textY = y + h / 2
            
            // Background
            ctx.fillStyle = 'rgba(0, 0, 0, 0.85)'
            ctx.fillRect(textX - textWidth/2, textY - textHeight/2, textWidth, textHeight)
            
            // ข้อความ
            ctx.fillStyle = '#ffffff'
            ctx.fillText(sizeText, textX, textY)
          }
          
          // วาด label บนซ้าย (ตัวอักษรเล็กลงอีก)
          const labelText = `#${index + 1} ${label} ${(confidence * 100).toFixed(1)}%`
          ctx.font = 'bold 10px Arial'
          ctx.textAlign = 'left'
          const textMetrics = ctx.measureText(labelText)
          const textWidth = textMetrics.width
          const padding = 3
          
          // Background
          ctx.fillStyle = color
          ctx.globalAlpha = 0.9
          ctx.fillRect(x, y - 18, textWidth + padding * 2, 18)
          ctx.globalAlpha = 1.0
          
          // ข้อความ
          ctx.fillStyle = '#000000'
          ctx.textBaseline = 'top'
          ctx.fillText(labelText, x + padding, y - 15)
          
          // วาดมุมกรอบ (เส้นบางลง)
          const cornerLength = 20
          ctx.strokeStyle = color
          ctx.lineWidth = 2
          
          // มุมบนซ้าย
          ctx.beginPath()
          ctx.moveTo(x, y + cornerLength)
          ctx.lineTo(x, y)
          ctx.lineTo(x + cornerLength, y)
          ctx.stroke()
          
          // มุมบนขวา
          ctx.beginPath()
          ctx.moveTo(x + w - cornerLength, y)
          ctx.lineTo(x + w, y)
          ctx.lineTo(x + w, y + cornerLength)
          ctx.stroke()
          
          // มุมล่างซ้าย
          ctx.beginPath()
          ctx.moveTo(x, y + h - cornerLength)
          ctx.lineTo(x, y + h)
          ctx.lineTo(x + cornerLength, y + h)
          ctx.stroke()
          
          // มุมล่างขวา
          ctx.beginPath()
          ctx.moveTo(x + w - cornerLength, y + h)
          ctx.lineTo(x + w, y + h)
          ctx.lineTo(x + w, y + h - cornerLength)
          ctx.stroke()
        })
      }
    }
    
    img.onerror = () => {
      console.error('Failed to load frame image')
      // วาดข้อความ error
      ctx.fillStyle = '#1e293b'
      ctx.fillRect(0, 0, canvas.width, canvas.height)
      ctx.fillStyle = '#ef4444'
      ctx.font = '20px sans-serif'
      ctx.textAlign = 'center'
      ctx.fillText('Error loading frame', canvas.width / 2, canvas.height / 2)
    }
    
    img.src = frameDataUrl
  }

  useEffect(() => {
    console.log('Connecting to backend:', backendUrl)
    loadMachines()
    loadConfigs()
    loadLots()  // 🎯 โหลด LOT list
    loadRubberType()  // 🔲 โหลด rubber type

    // Auto-reload machines, configs และ lots เมื่อหน้าต่างกลับมา focus
    const handleFocus = () => {
      console.log('[Auto-refresh] Window focused, reloading data...')
      loadMachines()
      loadConfigs()
      loadLots()
    }
    
    window.addEventListener('focus', handleFocus)

    const socket = io(backendUrl, {
      transports: ['websocket', 'polling'],
      reconnection: true,
      reconnectionAttempts: Infinity,
      reconnectionDelay: 1000
    })

    socket.on('connect', () => {
      setConnected(true)
      setError('')
    })

    socket.on('disconnect', () => {
      setConnected(false)
    })

    socket.on('frame_update', (payload) => {
      console.log('📡 Received frame_update:', {
        hasFrame: !!payload?.frame,
        measurementsCount: payload?.measurements?.length || 0,
        statistics: payload?.statistics
      })
      
      if (payload?.frame) {
        const frameDataUrl = `data:image/jpeg;base64,${payload.frame}`
        setFrameSrc(frameDataUrl)
        
        // ✅ วาดภาพพร้อมกรอบ ROI
        const detections = payload.measurements || []
        console.log('🎯 Calling drawFrame with detections:', detections)
        drawFrame(frameDataUrl, detections)
      }
      if (Array.isArray(payload?.measurements)) {
        setMeasurements(payload.measurements)
      }
      
      // 📊 Update statistics from backend
      if (payload?.statistics) {
        setStats(payload.statistics)
      }
    })

    socket.on('measurement_update', (payload) => {
      // ⚠️ Legacy event - not used anymore (frame_update handles everything)
      // Keeping listener for backward compatibility but using statistics from backend
      if (Array.isArray(payload?.measurements)) {
        setMeasurements(payload.measurements)
      }
      
      // ✅ ใช้ statistics จาก backend (ถ้ามี)
      if (payload?.statistics) {
        setStats(payload.statistics)
      }
    })

    // 🔄 Sync measurement state from other clients (Admin Web)
    socket.on('measurement_state_changed', (payload) => {
      console.log('🔄 Measurement state changed:', payload)
      
      if (payload.running) {
        setRunning(true)
        // ✅ Sync machine selection from Admin Web
        if (payload.machine_id) {
          setSelectedMachineId(payload.machine_id)
        }
        // ✅ Sync config selection if config_id exists in payload
        // Note: Backend sends full config object, extract id if available
        if (payload.config && payload.config.id) {
          setSelectedConfigId(String(payload.config.id))
        }
        
        if (payload.statistics) {
          setStats(payload.statistics)
        }
      } else {
        setRunning(false)
        
        if (payload.statistics) {
          setStats(payload.statistics)
        } else {
          setStats({ total: 0, pass: 0, fail: 0, near_pass: 0 })
        }
      }
    })

    // 🔄 Sync camera state from other clients (Admin Web)
    socket.on('camera_state_changed', (payload) => {
      console.log('🔄 Camera state changed:', payload)
      // Note: Desktop App doesn't control camera, this is just for awareness
      // Camera state is managed by backend and Admin Web only
      if (payload.active) {
        console.log('✅ Camera started from another client')
      } else {
        console.log('⚠️ Camera stopped from another client')
      }
    })
    
    // ✅ Initialize canvas เมื่อ mount
    if (canvasRef.current) {
      const canvas = canvasRef.current
      canvas.width = 1920
      canvas.height = 1080
      const ctx = canvas.getContext('2d')
      ctx.fillStyle = '#1e293b'
      ctx.fillRect(0, 0, canvas.width, canvas.height)
    }

    return () => {
      window.removeEventListener('focus', handleFocus)
      socket.disconnect()
    }
  }, [])

  const latest = measurements.length ? measurements[measurements.length - 1] : null

  return (
    <div className="page">
      <div className="bg-orb orb-1" />
      <div className="bg-orb orb-2" />

      <header className="topbar glass">
        <div className="topbar-left">
          <img src={logoImg} alt="PSE Vision" className="logo" />
          <div>
            <h1>PSE Vision</h1>
            <p>Object Measurement System</p>
          </div>
        </div>
        <div className={`status ${connected ? 'ok' : 'bad'}`}>
          <span className="dot" />
          {connected ? 'Connected' : 'Disconnected'}
        </div>
      </header>

      <main className="layout">
        <section className="viewer glass">
          <div className="viewer-head">
            <h2>Live View</h2>
            <button className="btn ghost" onClick={loadConfigs}>รีเฟรชรายการ</button>
          </div>

          <div className="viewer-frame">
            {frameSrc ? (
              <canvas 
                ref={canvasRef} 
                style={{ width: '100%', height: '100%', objectFit: 'contain' }}
              />
            ) : (
              <div className="placeholder">กำลังรอ live frame จาก backend...</div>
            )}
          </div>
        </section>

        <aside className="panel glass">
          <h3>Control</h3>

          <label className="label">เครื่องจักร</label>
          <select
            className="input"
            value={selectedMachineId}
            onChange={(event) => setSelectedMachineId(event.target.value)}
          >
            {machines.map((machine) => (
              <option key={machine.id} value={machine.id}>
                {machine.name}
              </option>
            ))}
          </select>

          <label className="label">Configuration</label>
          <select
            className="input"
            value={selectedConfigId}
            onChange={(event) => setSelectedConfigId(event.target.value)}
          >
            {configs.map((cfg) => (
              <option key={cfg.id} value={cfg.id}>
                {cfg.name} ({cfg.target_area_min}-{cfg.target_area_max} mm²)
              </option>
            ))}
          </select>

          <label className="label">LOT</label>
          <select
            className="input"
            value={selectedLotId}
            onChange={(event) => setSelectedLotId(event.target.value)}
          >
            {lots.map((lot) => (
              <option key={lot.id} value={lot.id}>
                {lot.name} ({lot.type})
              </option>
            ))}
          </select>

          <div className="card">
            <div className="k">Target Area</div>
            <div className="v">
              {selectedConfig
                ? `${selectedConfig.target_area_min} - ${selectedConfig.target_area_max} mm²`
                : '-'}
            </div>
            <div className="k">Tolerance</div>
            <div className="v">{selectedConfig ? `±${selectedConfig.tolerance} mm²` : '-'}</div>
          </div>

          {/* 🎛️ Control Bar: Start/Stop + Rubber Toggle + Capture */}
          <div className="ctrl-bar">
            {/* Start / Stop button */}
            {!running ? (
              <button className="btn primary ctrl-main-btn" disabled={loading} onClick={startMeasurement}>
                {loading ? 'กำลังเริ่ม...' : '▶ Start'}
              </button>
            ) : (
              <button className="btn danger ctrl-main-btn" disabled={loading} onClick={stopMeasurement}>
                {loading ? 'กำลังหยุด...' : '■ Stop'}
              </button>
            )}

            {/* Rubber type toggle */}
            <button
              className={`rubber-toggle-btn ctrl-rubber-btn ${rubberType === 'black' ? 'rubber-active-black' : 'rubber-active-white'}`}
              onClick={toggleRubberType}
              title="เปลี่ยนสียาง"
            >
              {rubberType === 'black' ? '⚫ ดำ' : '⚪ ขาว'}
            </button>

            {/* Capture image icon button */}
            <button
              className="capture-icon-btn"
              disabled={capturing || !running}
              onClick={captureImage}
              title={!running ? 'กรุณาเริ่ม Measurement ก่อน' : capturing ? 'กำลังเก็บภาพ...' : 'Capture Image'}
            >
              {capturing ? (
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" width="20" height="20" style={{ animation: 'spin 1s linear infinite' }}>
                  <path d="M21 12a9 9 0 1 1-6.219-8.56"/>
                </svg>
              ) : (
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" width="20" height="20">
                  <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/>
                  <circle cx="12" cy="13" r="4"/>
                </svg>
              )}
            </button>
          </div>

          {/* Live Object Counter — always visible */}
          <div className="live-counter-box">
            <div className="live-counter-label">Objects Detected (frame)</div>
            <div className="live-counter-value">{measurements.length}</div>
            <div className="live-counter-unit">ชิ้น</div>
          </div>

          <h3>Latest Result</h3>
          <div className="card">
            <div className="k">Area</div>
            <div className="v">{latest ? `${latest.area_mm2 ?? '-'} mm²` : '-'}</div>
            <div className="k">Status</div>
            <div className={`v ${latest?.status === 'pass' ? 'pass' : latest?.status === 'near_pass' ? 'near-pass' : latest?.status === 'fail' ? 'fail' : ''}`}>
              {latest ? (
                latest.status === 'pass' ? '✓ PASS' :
                latest.status === 'near_pass' ? '≈ NEAR PASS' :
                latest.status === 'fail' ? '✗ FAIL' : '-'
              ) : '-'}
            </div>
          </div>

          <h3>Statistics (Session)</h3>
          <div className="stat-grid">
            <div className="stat-box total-box">
              <div className="stat-box-num">{stats.total}</div>
              <div className="stat-box-lbl">Total</div>
            </div>
            <div className="stat-box pass-box">
              <div className="stat-box-num">{stats.pass}</div>
              <div className="stat-box-lbl">✓ Pass</div>
            </div>
            <div className="stat-box near-box">
              <div className="stat-box-num">{stats.near_pass}</div>
              <div className="stat-box-lbl">≈ Near</div>
            </div>
            <div className="stat-box fail-box">
              <div className="stat-box-num">{stats.fail}</div>
              <div className="stat-box-lbl">✗ Fail</div>
            </div>
          </div>

          {error ? <div className="error">{error}</div> : null}
        </aside>
      </main>
    </div>
  )
}

export default App
