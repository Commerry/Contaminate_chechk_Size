<template>
  <aside class="sidebar" :class="{ 'open': isOpen }">
    <div class="sidebar-header">
      <div class="logo">
        <img src="/Icon/output-onlinepngtools_PSE.ico" alt="PSE Logo" class="logo-image" />
      </div>
    </div>

    <nav class="sidebar-nav">
      <!-- ⚠️ DISABLED: Size Mode Selector - ใช้เฉพาะ Small Mode เท่านั้น -->
      <!-- 
      <div class="nav-section size-selector-section">
        <h3 class="nav-section-title">Detection Size Mode</h3>
        <div class="size-toggle-container">
          <span class="size-label" :class="{ active: !isSmallObjectMode }">Large</span>
          <label class="toggle-switch">
            <input 
              type="checkbox" 
              v-model="isSmallObjectMode" 
              @change="toggleSmallObjectMode"
            >
            <span class="toggle-slider"></span>
          </label>
          <span class="size-label" :class="{ active: isSmallObjectMode }">Small</span>
        </div>
      </div>
      -->
      
      <!-- ✅ Small Object Mode - Fixed (ไม่ต้อง toggle) -->
      <div class="nav-section size-selector-section">
        <h3 class="nav-section-title">Small Object Detection</h3>
        
        <!-- Target Size Input -->
        <div class="target-size-input">
          <label class="input-label">Target Size (mm)</label>
          
          <!-- Width Input -->
          <div class="input-group">
            <label class="input-sublabel">Width:</label>
            <input 
              type="number" 
              v-model.number="targetWidth" 
              min="0" 
              max="200" 
              step="1"
              class="size-input"
              placeholder="Width"
            >
            <span class="input-unit">mm</span>
          </div>
          
          <!-- Height Input -->
          <div class="input-group">
            <label class="input-sublabel">Height:</label>
            <input 
              type="number" 
              v-model.number="targetHeight" 
              min="0" 
              max="200" 
              step="1"
              class="size-input"
              placeholder="Height"
            >
            <span class="input-unit">mm</span>
          </div>
          
          <!-- Tolerance Input -->
          <div class="input-group">
            <label class="input-sublabel">Tolerance:</label>
            <input 
              type="number" 
              v-model.number="tolerance" 
              min="0" 
              max="20" 
              step="1"
              class="size-input"
              placeholder="±"
            >
            <span class="input-unit">mm</span>
          </div>
          
          <!-- Save Button -->
          <button 
            class="save-target-btn" 
            @click="saveTargetSize"
            :disabled="!targetWidth || !targetHeight"
          >
            <IconSvg name="check" :size="16" class="btn-icon" />
            <span>Save Target Size</span>
          </button>
          
          <p class="input-hint">
            Range: W={{ Math.max(0, targetWidth - tolerance) }}-{{ targetWidth + tolerance }}mm, 
            H={{ Math.max(0, targetHeight - tolerance) }}-{{ targetHeight + tolerance }}mm
          </p>
        </div>
      </div>

      <!-- Camera Control -->
      <div class="nav-section">
        <h3 class="nav-section-title">Camera Control</h3>
        <button 
          class="nav-button"
          :class="{ 'active': isCameraActive }"
          @click="$emit('toggle-camera')"
        >
          <IconSvg :name="isCameraActive ? 'pause' : 'play'" :size="20" class="nav-icon" />
          <span>{{ isCameraActive ? 'Stop Camera' : 'Start Camera' }}</span>
        </button>

        <!-- DISABLED: AI Prediction (คอมเมนต์ไว้ - ไม่ใช้งานแล้ว)
        <button 
          class="nav-button"
          :class="{ 'active': isPredicting }"
          :disabled="!isCameraActive"
          @click="$emit('toggle-prediction')"
        >
          <IconSvg name="sparkles" :size="20" class="nav-icon" />
          <span>{{ isPredicting ? 'Stop Prediction' : 'Start Prediction' }}</span>
        </button>
        -->

        <button 
          class="nav-button"
          :class="{ 'active': isContourDetecting }"
          :disabled="!isCameraActive"
          @click="$emit('toggle-contour')"
        >
          <IconSvg name="target" :size="20" class="nav-icon" />
          <span>{{ isContourDetecting ? 'Stop Contour' : 'Start Contour' }}</span>
        </button>

        <!-- ✅ Rubber Type Toggle -->
        <button 
          class="nav-button rubber-type-toggle"
          :class="{ 'white-mode': rubberType === 'white' }"
          :disabled="!isCameraActive || !isContourDetecting"
          @click="toggleRubberType"
          :title="rubberType === 'black' ? 'ยางดำ: พื้นขาว-วัตถุดำ' : 'ยางขาว: พื้นดำ-วัตถุขาว'"
        >
          <svg v-if="rubberType === 'black'" width="20" height="20" viewBox="0 0 24 24" fill="currentColor" class="nav-icon">
            <circle cx="12" cy="12" r="10"/>
          </svg>
          <svg v-else width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="nav-icon">
            <circle cx="12" cy="12" r="10"/>
          </svg>
          <span>{{ rubberType === 'black' ? 'ยางดำ' : 'ยางขาว' }}</span>
        </button>

        <button 
          class="nav-button"
          :class="{ 'active': isMultiObjectActive }"
          :disabled="!isCameraActive || !isContourDetecting"
          @click="toggleMultiObject"
          title="ตรวจจับและแสดงหลายวัตถุพร้อมกัน"
        >
          <IconSvg name="grid" :size="20" class="nav-icon" />
          <span>{{ isMultiObjectActive ? 'Multi: ON' : 'Multi: OFF' }}</span>
        </button>

        <!-- ⚠️ DISABLED: Large Mode Features (3-Zone Detection) -->
        <!-- 
        <template v-if="!isSmallObjectMode">
          <button 
            class="nav-button"
            :class="{ 'active': isThreeZoneActive }"
            :disabled="!isCameraActive || !isContourDetecting"
            @click="toggleThreeZone"
            title="แบ่งหน้าจอเป็น 3 ช่อง และตรวจจับแยกกัน"
          >
            <IconSvg name="layout" :size="20" class="nav-icon" />
            <span>{{ isThreeZoneActive ? '3-Zone: ON' : '3-Zone: OFF' }}</span>
          </button>
        </template>
        -->
      </div>

      <!-- Status Info -->
      <div class="nav-section">
        <h3 class="nav-section-title">Status</h3>
        <div class="status-card">
          <div class="status-item">
            <span class="status-label">Connection:</span>
            <span class="status-value" :class="isConnected ? 'connected' : 'disconnected'">
              {{ isConnected ? 'Connected' : 'Disconnected' }}
            </span>
          </div>
          <div class="status-item">
            <span class="status-label">FPS:</span>
            <span class="status-value">{{ fps }}</span>
          </div>
          <div class="status-item">
            <span class="status-label">Objects:</span>
            <span class="status-value">{{ objectCount }}</span>
          </div>
        </div>
      </div>
    </nav>

    <div class="sidebar-footer">
      <div class="version-info">
        <div class="version-text">Version 1.0.0</div>
        <div class="copyright">© 2025 PSE Vision</div>
      </div>
    </div>
  </aside>
</template>

<script setup>
import { ref, computed } from 'vue'
import IconSvg from './IconSvg.vue'

const props = defineProps({
  isConnected: {
    type: Boolean,
    default: false
  },
  isOpen: {
    type: Boolean,
    default: false
  },
  isCameraActive: {
    type: Boolean,
    default: false
  },
  isPredicting: {
    type: Boolean,
    default: false
  },
  isContourDetecting: {
    type: Boolean,
    default: false
  },
  fps: {
    type: Number,
    default: 0
  },
  objectCount: {
    type: Number,
    default: 0
  }
})

const emit = defineEmits([
  'toggle-camera', 
  'toggle-contour', 
  'open-settings', 
  'open-calibration', 
  'open-machines',
  'open-configurations',
  'open-lots',
  'close', 
  'update:contrast', 
  'update:colorScheme', 
  'update:zoom'
])

// Image enhancement controls
const contrastEnabled = ref(false)
const selectedColorScheme = ref('gray')
const zoomLevel = ref(1.0)

// ⭐ Multi-object detection control
const isMultiObjectActive = ref(false)
const isThreeZoneActive = ref(false)
const isSmallObjectMode = ref(false)  // ✅ Small object mode state
const targetWidth = ref(25)   // ✅ Target width (mm)
const targetHeight = ref(25)  // ✅ Target height (mm)
const tolerance = ref(3)      // ✅ Tolerance (±mm)
const rubberType = ref('black')  // ✅ Rubber type: 'black' or 'white'

// 🌐 Dynamic server URL
const API_BASE = window.location.origin

// Load saved settings from config on mount
const loadConfig = async () => {
  try {
    const response = await fetch(`${API_BASE}/api/config/get`)
    const data = await response.json()
    if (data.success) {
      const config = data.config
      
      // Load all saved settings
      contrastEnabled.value = config.height_on === 1
      selectedColorScheme.value = config.depth_color_scheme || 'gray'
      zoomLevel.value = config.zoom_level || 1.0
      
      // Emit initial values to parent
      emit('update:contrast', contrastEnabled.value)
      emit('update:colorScheme', selectedColorScheme.value)
      emit('update:zoom', zoomLevel.value)
      
      console.log('[Config] ✅ Loaded saved settings:', {
        contrast: contrastEnabled.value,
        colorScheme: selectedColorScheme.value,
        zoom: zoomLevel.value
      })
    }
  } catch (error) {
    console.error('[Config] ❌ Failed to load:', error)
  }
}

// Load rubber type from camera status
const loadRubberType = async () => {
  try {
    const response = await fetch(`${API_BASE}/api/camera/status`)
    const data = await response.json()
    if (data.rubber_type) {
      rubberType.value = data.rubber_type
      console.log('[Rubber Type] Loaded:', rubberType.value)
    }
  } catch (error) {
    console.error('[Rubber Type] Failed to load:', error)
  }
}

// Auto-load config on mount
loadConfig()
loadRubberType()

const toggleContrast = async () => {
  contrastEnabled.value = !contrastEnabled.value
  emit('update:contrast', contrastEnabled.value)
  
  // Save to backend config
  try {
    await fetch(`${API_BASE}/api/config/set`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        key: 'height_on',
        value: contrastEnabled.value ? 1 : 0
      })
    })
  } catch (error) {
    console.error('[Config] Failed to save contrast:', error)
  }
  
  console.log('Contrast enabled:', contrastEnabled.value)
}

const updateColorScheme = async () => {
  emit('update:colorScheme', selectedColorScheme.value)
  
  // Save to backend config
  try {
    await fetch(`${API_BASE}/api/config/set`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        key: 'depth_color_scheme',
        value: selectedColorScheme.value
      })
    })
  } catch (error) {
    console.error('[Config] Failed to save color scheme:', error)
  }
  
  console.log('Color scheme changed to:', selectedColorScheme.value)
}

const updateZoom = async () => {
  emit('update:zoom', zoomLevel.value)
  
  // Save to backend config and apply zoom
  try {
    const response = await fetch(`${API_BASE}/api/camera/zoom`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ zoom: zoomLevel.value })
    })
    const data = await response.json()
    console.log('[Zoom]', data.message)
    
    // Save to config
    await fetch(`${API_BASE}/api/config/set`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        key: 'zoom_level',
        value: zoomLevel.value
      })
    })
    
    // Alert user to restart camera for zoom to take effect
    if (data.message && data.message.includes('restart')) {
      console.warn('⚠️ Please restart camera to apply zoom changes')
    }
  } catch (error) {
    console.error('[Zoom] Failed to update:', error)
  }
}

// ⭐ Toggle multi-object detection mode
const toggleMultiObject = async () => {
  try {
    const response = await fetch(`${API_BASE}/api/camera/multi-object/toggle`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' }
    })
    const data = await response.json()
    
    if (data.success) {
      isMultiObjectActive.value = data.active
      console.log('[Multi-Object]', data.message)
    }
  } catch (error) {
    console.error('[Multi-Object] Failed to toggle:', error)
  }
}

// 🎯 Toggle 3-zone detection mode
const toggleThreeZone = async () => {
  try {
    const response = await fetch(`${API_BASE}/api/camera/three-zone/toggle`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' }
    })
    const data = await response.json()
    
    if (data.success) {
      isThreeZoneActive.value = data.active
      console.log('[3-Zone]', data.message)
    }
  } catch (error) {
    console.error('[3-Zone] Failed to toggle:', error)
  }
}

// ✅ Toggle rubber type (black/white)
const toggleRubberType = async () => {
  try {
    const response = await fetch(`${API_BASE}/api/rubber/toggle`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' }
    })
    const data = await response.json()
    
    if (data.success) {
      rubberType.value = data.rubber_type
      console.log('[Rubber Type]', data.message)
    }
  } catch (error) {
    console.error('[Rubber Type] Failed to toggle:', error)
  }
}

// ✅ Toggle small object detection mode (≤ 50mm)
const toggleSmallObjectMode = async () => {
  try {
    const response = await fetch(`${API_BASE}/api/camera/small-object/toggle`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ 
        target_width: targetWidth.value,
        target_height: targetHeight.value,
        tolerance: tolerance.value
      })
    })
    const data = await response.json()
    
    if (data.success) {
      isSmallObjectMode.value = data.active
      console.log('[Small Object Mode]', data.message, 
        `Target: W=${targetWidth.value}mm H=${targetHeight.value}mm ±${tolerance.value}mm`)
      
      // 🔄 เมื่อเปลี่ยนโหมด อาจต้อง reset Multi/3-Zone
      // Small Mode: ไม่มี 3-Zone
      if (isSmallObjectMode.value && isThreeZoneActive.value) {
        await toggleThreeZone() // ปิด 3-Zone อัตโนมัติ
      }
    }
  } catch (error) {
    console.error('[Small Object Mode] Failed to toggle:', error)
  }
}

// ✅ Save target size (new function)
const saveTargetSize = async () => {
  try {
    const response = await fetch(`${API_BASE}/api/camera/small-object/set-target`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ 
        target_width: targetWidth.value,
        target_height: targetHeight.value,
        tolerance: tolerance.value
      })
    })
    const data = await response.json()
    if (data.success) {
      alert(`✅ Target size saved!\nWidth: ${targetWidth.value}mm ±${tolerance.value}mm\nHeight: ${targetHeight.value}mm ±${tolerance.value}mm`)
      console.log('[Target Size] Saved:', data)
    } else {
      alert('❌ Failed to save target size: ' + (data.message || 'Unknown error'))
    }
  } catch (error) {
    console.error('[Target Size] Failed to save:', error)
    alert('❌ Failed to save target size')
  }
}

// ✅ REMOVED: updateTargetSize - replaced by saveTargetSize

const calibrate = () => {
  emit('open-calibration')
}

const resetMeasurement = () => {
  console.log('Resetting measurements...')
  // TODO: Implement reset
}
</script>

<style scoped>
.sidebar {
  width: 280px;
  background: var(--bg-card);
  border-right: 1px solid var(--border-color);
  display: flex;
  flex-direction: column;
  overflow-y: auto;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  flex-shrink: 0;
}

.sidebar:not(.open) {
  width: 0;
  min-width: 0;
  border-right-width: 0;
  overflow: hidden;
}

.sidebar.open {
  width: 280px;
}

.sidebar-header {
  padding: 20px;
  border-bottom: 1px solid var(--border-color);
}

.logo {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0;
}

.logo-image {
  width: 80px;
  height: 80px;
  object-fit: contain;
  filter: drop-shadow(0 2px 8px rgba(99, 102, 241, 0.3));
  transition: all 0.3s ease;
}

.logo-image:hover {
  filter: drop-shadow(0 4px 12px rgba(99, 102, 241, 0.5));
  transform: scale(1.05);
}

.logo-icon {
  width: 48px;
  height: 48px;
  background: var(--gradient-primary);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 16px;
  color: white;
  box-shadow: 0 4px 16px rgba(16, 185, 129, 0.3);
  animation: float 3s ease-in-out infinite;
  position: relative;
  overflow: hidden;
}

.logo-icon::before {
  content: '';
  position: absolute;
  top: -50%;
  left: -50%;
  width: 200%;
  height: 200%;
  background: linear-gradient(45deg, transparent, rgba(255,255,255,0.2), transparent);
  animation: shimmer 3s infinite;
}

.logo-text {
  flex: 1;
}

.logo-title {
  font-size: 18px;
  font-weight: 700;
  background: linear-gradient(135deg, var(--primary-color) 0%, var(--accent-color) 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  line-height: 1.2;
}

.logo-subtitle {
  font-size: 12px;
  color: var(--text-secondary);
  line-height: 1.2;
}

.sidebar-nav {
  flex: 1;
  padding: 20px;
}

.nav-section {
  margin-bottom: 28px;
}

.nav-section-title {
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  color: var(--text-secondary);
  margin-bottom: 12px;
}

.nav-button {
  width: 100%;
  padding: 12px 16px;
  background: transparent;
  border: 1px solid var(--border-color);
  border-radius: 8px;
  color: var(--text-primary);
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 12px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  margin-bottom: 8px;
  position: relative;
  overflow: hidden;
}

.nav-button::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: var(--gradient-glass);
  transition: left 0.3s ease;
}

.nav-button:hover::before {
  left: 0;
}

.nav-button:hover {
  background: var(--bg-card-hover);
  border-color: var(--primary-color);
  transform: translateX(4px);
  box-shadow: 0 4px 12px rgba(139, 92, 246, 0.2);
}

.nav-button.active {
  background: var(--gradient-primary);
  border-color: var(--primary-color);
  color: white;
  box-shadow: 0 4px 16px rgba(139, 92, 246, 0.3);
}

/* ✅ Rubber Type Toggle Styles */
.nav-button.rubber-type-toggle {
  background: linear-gradient(135deg, rgba(30, 30, 40, 0.6), rgba(20, 20, 30, 0.6));
  border: 1px solid rgba(100, 100, 120, 0.3);
}

.nav-button.rubber-type-toggle:not(:disabled):hover {
  background: linear-gradient(135deg, rgba(50, 50, 60, 0.8), rgba(40, 40, 50, 0.8));
  border-color: rgba(150, 150, 170, 0.5);
}

.nav-button.rubber-type-toggle.white-mode {
  background: linear-gradient(135deg, rgba(240, 240, 250, 0.2), rgba(220, 220, 235, 0.2));
  border: 1px solid rgba(200, 200, 220, 0.4);
  color: #e2e8f0;
}

.nav-button.rubber-type-toggle.white-mode:not(:disabled):hover {
  background: linear-gradient(135deg, rgba(240, 240, 250, 0.3), rgba(220, 220, 235, 0.3));
  border-color: rgba(200, 200, 220, 0.6);
  color: #f1f5f9;
}

.nav-button:active {
  transform: translateX(2px) scale(0.98);
}

.nav-icon {
  font-size: 18px;
}

/* ✅ Size Selector - Toggle Switch Styles */
.size-selector-section {
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.1), rgba(16, 185, 129, 0.1));
  border: 1px solid var(--border-color);
  border-radius: 10px;
  padding: 12px;
  margin-bottom: 16px;
}

.size-selector-section .nav-section-title {
  font-size: 12px;
  margin-bottom: 8px;
}

.size-toggle-container {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  margin: 8px 0;
}

.size-label {
  font-size: 13px;
  font-weight: 600;
  color: var(--text-secondary);
  transition: all 0.3s ease;
  min-width: 45px;
  text-align: center;
}

.size-label.active {
  color: var(--primary-color);
  transform: scale(1.1);
}

.toggle-switch {
  position: relative;
  display: inline-block;
  width: 50px;
  height: 26px;
}

.toggle-switch input {
  opacity: 0;
  width: 0;
  height: 0;
}

.toggle-slider {
  position: absolute;
  cursor: pointer;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, #8b5cf6, #7c3aed);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  border-radius: 34px;
  box-shadow: 0 2px 8px rgba(139, 92, 246, 0.3);
}

.toggle-slider:before {
  position: absolute;
  content: "";
  height: 18px;
  width: 18px;
  left: 4px;
  bottom: 4px;
  background: white;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  border-radius: 50%;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}

input:checked + .toggle-slider {
  background: linear-gradient(135deg, #10b981, #059669);
}

input:checked + .toggle-slider:before {
  transform: translateX(24px);
}

.toggle-slider:hover {
  box-shadow: 0 4px 12px rgba(139, 92, 246, 0.4);
}

/* ✅ Target Size Input Styles */
.target-size-input {
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid var(--border-color);
}

.input-label {
  display: block;
  font-size: 11px;
  font-weight: 600;
  color: var(--text-secondary);
  margin-bottom: 8px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.input-sublabel {
  font-size: 11px;
  font-weight: 600;
  color: var(--text-secondary);
  min-width: 60px;
}

.input-group {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.size-input {
  flex: 1;
  background: var(--bg-dark);
  border: 1px solid var(--border-color);
  border-radius: 6px;
  padding: 8px 12px;
  color: var(--text-primary);
  font-size: 14px;
  font-weight: 600;
  transition: all 0.3s ease;
}

.size-input:focus {
  outline: none;
  border-color: var(--primary-color);
  box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.1);
}

.input-unit {
  font-size: 12px;
  font-weight: 600;
  color: var(--primary-color);
  white-space: nowrap;
  min-width: 30px;
}

.save-target-btn {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  background: linear-gradient(135deg, var(--primary-color), #7c3aed);
  color: white;
  border: none;
  border-radius: 8px;
  padding: 10px 16px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  margin: 12px 0 8px 0;
}

.save-target-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(139, 92, 246, 0.4);
}

.save-target-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.save-target-btn .btn-icon {
  width: 16px;
  height: 16px;
}

.input-hint {
  font-size: 9px;
  color: var(--text-secondary);
  margin: 4px 0 0 0;
  text-align: center;
  line-height: 1.3;
}

.status-card {
  background: var(--bg-dark);
  border: 1px solid var(--border-color);
  border-radius: 8px;
  padding: 12px;
}

.status-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
  border-bottom: 1px solid var(--border-color);
}

.status-item:last-child {
  border-bottom: none;
  padding-bottom: 0;
}

.status-item:first-child {
  padding-top: 0;
}

.status-label {
  font-size: 13px;
  color: var(--text-secondary);
}

.status-value {
  font-size: 13px;
  font-weight: 600;
  color: var(--text-primary);
}

.status-value.connected {
  color: var(--success-color);
}

.status-value.disconnected {
  color: var(--danger-color);
}

/* Color Scheme Selector */
.color-scheme-selector {
  padding: 12px;
  background: rgba(30, 41, 59, 0.5);
  border-radius: 8px;
  border: 1px solid var(--border-color);
}

/* Zoom Control */
.zoom-control {
  padding: 12px;
  background: rgba(30, 41, 59, 0.5);
  border-radius: 8px;
  border: 1px solid var(--border-color);
  margin-bottom: 12px;
}

.zoom-slider-container {
  margin-top: 8px;
}

.zoom-slider {
  width: 100%;
  height: 6px;
  border-radius: 3px;
  background: linear-gradient(90deg, 
    rgba(59, 130, 246, 0.3) 0%, 
    rgba(59, 130, 246, 0.6) 100%);
  outline: none;
  -webkit-appearance: none;
  appearance: none;
  cursor: pointer;
  transition: all 0.2s ease;
}

.zoom-slider::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 18px;
  height: 18px;
  border-radius: 50%;
  background: var(--primary-color);
  box-shadow: 0 2px 8px rgba(59, 130, 246, 0.5);
  cursor: pointer;
  transition: all 0.2s ease;
}

.zoom-slider::-webkit-slider-thumb:hover {
  background: #60a5fa;
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.7);
  transform: scale(1.1);
}

.zoom-slider::-moz-range-thumb {
  width: 18px;
  height: 18px;
  border-radius: 50%;
  background: var(--primary-color);
  box-shadow: 0 2px 8px rgba(59, 130, 246, 0.5);
  cursor: pointer;
  border: none;
  transition: all 0.2s ease;
}

.zoom-slider::-moz-range-thumb:hover {
  background: #60a5fa;
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.7);
  transform: scale(1.1);
}

.zoom-slider:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  background: rgba(100, 116, 139, 0.3);
}

.zoom-slider:disabled::-webkit-slider-thumb {
  background: rgba(100, 116, 139, 0.6);
  box-shadow: none;
  cursor: not-allowed;
}

.zoom-marks {
  display: flex;
  justify-content: space-between;
  margin-top: 4px;
  padding: 0 4px;
}

.zoom-marks span {
  font-size: 10px;
  color: var(--text-secondary);
  opacity: 0.7;
}

.selector-label {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  font-weight: 600;
  color: var(--text-secondary);
  margin-bottom: 8px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.scheme-select {
  width: 100%;
  padding: 8px 12px;
  background: rgba(15, 23, 42, 0.8);
  border: 1px solid var(--border-color);
  border-radius: 6px;
  color: var(--text-primary);
  font-size: 13px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.scheme-select:hover:not(:disabled) {
  border-color: var(--primary-color);
  background: rgba(59, 130, 246, 0.1);
}

.scheme-select:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.scheme-select option {
  background: #1e293b;
  color: var(--text-primary);
  padding: 8px;
}

.sidebar-footer {
  padding: 20px;
  border-top: 1px solid var(--border-color);
}

/* ✨ Size Mode Toggle Switch Styles */
.size-selector-section {
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.1), rgba(139, 92, 246, 0.1));
  padding: 16px;
  border-radius: 12px;
  border: 1px solid rgba(99, 102, 241, 0.2);
  margin-bottom: 20px !important;
}

.size-selector-section .nav-section-title {
  color: var(--primary-color);
  margin-bottom: 16px;
  font-size: 12px;
}

.size-toggle-container {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  padding: 8px 0;
}

.size-label {
  font-size: 13px;
  font-weight: 600;
  color: var(--text-secondary);
  transition: all 0.3s ease;
  user-select: none;
}

.size-label.active {
  color: var(--primary-color);
  font-size: 14px;
}

/* Toggle Switch */
.toggle-switch {
  position: relative;
  display: inline-block;
  width: 56px;
  height: 28px;
  cursor: pointer;
}

.toggle-switch input {
  opacity: 0;
  width: 0;
  height: 0;
}

.toggle-slider {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, #64748b 0%, #475569 100%);
  border-radius: 28px;
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.2);
}

.toggle-slider:before {
  content: "";
  position: absolute;
  height: 22px;
  width: 22px;
  left: 3px;
  bottom: 3px;
  background: white;
  border-radius: 50%;
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
}

.toggle-switch input:checked + .toggle-slider {
  background: linear-gradient(135deg, var(--primary-color) 0%, var(--accent-color) 100%);
  box-shadow: 0 0 12px rgba(139, 92, 246, 0.4);
}

.toggle-switch input:checked + .toggle-slider:before {
  transform: translateX(28px);
  box-shadow: 0 2px 12px rgba(139, 92, 246, 0.6);
}

.toggle-switch input:disabled + .toggle-slider {
  opacity: 0.5;
  cursor: not-allowed;
  background: #334155;
}

.size-description {
  text-align: center;
  font-size: 11px;
  color: var(--text-secondary);
  margin-top: 12px;
  margin-bottom: 0;
  padding: 6px 12px;
  background: rgba(0, 0, 0, 0.2);
  border-radius: 6px;
  font-weight: 500;
}

.version-info {
  text-align: center;
}

.version-text {
  font-size: 12px;
  color: var(--text-secondary);
  margin-bottom: 4px;
}

.copyright {
  font-size: 11px;
  color: var(--text-secondary);
}

/* Responsive Design */
@media (max-width: 1024px) {
  .sidebar {
    width: 240px;
  }
  
  .sidebar.open {
    width: 240px;
  }
  
  .sidebar-header {
    padding: 16px;
  }
  
  .logo-icon {
    width: 40px;
    height: 40px;
    font-size: 16px;
  }
  
  .logo-title {
    font-size: 16px;
  }
  
  .sidebar-nav {
    padding: 16px;
  }
  
  .nav-button {
    padding: 10px 12px;
    font-size: 13px;
  }
}

@media (max-width: 768px) {
  .sidebar {
    width: 260px;
  }
  
  .logo-icon {
    width: 36px;
    height: 36px;
    font-size: 14px;
  }
  
  .logo-title {
    font-size: 14px;
  }
  
  .logo-subtitle {
    font-size: 10px;
  }
  
  .nav-button {
    padding: 8px 10px;
    font-size: 12px;
    gap: 8px;
  }
}

@media (max-width: 480px) {
  .sidebar {
    width: 280px;
    max-width: calc(100vw - 60px);
  }
}
</style>
