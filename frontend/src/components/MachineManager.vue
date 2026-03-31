<template>
  <div class="machine-manager-panel">
    <div class="panel-wrapper">
      <div class="panel-header">
        <h2 class="panel-title">
          <IconSvg name="settings" :size="24" />
          Machine Manager
          <span class="subtitle">จัดการเครื่องจักร</span>
        </h2>
        <button class="close-btn" @click="$emit('close')">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <line x1="18" y1="6" x2="6" y2="18"></line>
            <line x1="6" y1="6" x2="18" y2="18"></line>
          </svg>
        </button>
      </div>

      <div class="panel-content">
      <!-- Create/Edit Form (อยู่บนสุด) -->
      <div class="machine-form-section">
        <h3>{{ editingMachine ? 'แก้ไข' : 'เพิ่ม' }} เครื่องจักร</h3>
        
        <div class="form-group">
          <label>รหัสเครื่องจักร <span class="required">*</span></label>
          <input 
            v-model="formData.id" 
            type="text" 
            class="form-input"
            placeholder="เช่น MC-01, LINE-A-01"
            :disabled="!!editingMachine"
          />
        </div>

        <div class="form-group">
          <label>ชื่อเครื่องจักร <span class="required">*</span></label>
          <input 
            v-model="formData.name" 
            type="text" 
            class="form-input"
            placeholder="เช่น Machine 01"
          />
        </div>

        <div class="form-group">
          <label>รายละเอียด</label>
          <textarea 
            v-model="formData.description" 
            class="form-textarea"
            rows="3"
            placeholder="รายละเอียดเครื่องจักร..."
          ></textarea>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label>สถานที่ตั้ง</label>
            <input 
              v-model="formData.location" 
              type="text" 
              class="form-input"
              placeholder="เช่น สายการผลิต A"
            />
          </div>

          <div class="form-group">
            <label>สถานะ</label>
            <select v-model="formData.status" class="form-select">
              <option value="active">ใช้งาน (Active)</option>
              <option value="inactive">ไม่ใช้งาน (Inactive)</option>
              <option value="maintenance">ซ่อมบำรุง (Maintenance)</option>
            </select>
          </div>
        </div>

        <div class="form-actions">
          <button class="btn btn-secondary" @click="cancelForm">
            ยกเลิก
          </button>
          <button 
            class="btn btn-primary" 
            @click="saveMachine"
            :disabled="!formData.id || !formData.name"
          >
            <IconSvg name="check" :size="16" />
            {{ editingMachine ? 'บันทึก' : 'เพิ่มเครื่องจักร' }}
          </button>
        </div>
      </div>

      <!-- Machine List (อยู่ล่าง) -->
      <div class="machine-list-section">
        <div class="section-header">
          <h3>รายการเครื่องจักร</h3>
        </div>

        <div class="machine-list">
          <div 
            v-for="machine in machines" 
            :key="machine.id"
            class="machine-item"
          >
            <div class="machine-info">
              <div class="machine-name">{{ machine.name }}</div>
              <div class="machine-details">
                <span class="badge badge-info">{{ machine.id }}</span>
                <span v-if="machine.location" class="location">📍 {{ machine.location }}</span>
                <span 
                  class="status-badge" 
                  :class="statusClass(machine.status)"
                >
                  {{ statusText(machine.status) }}
                </span>
              </div>
              <div v-if="machine.description" class="machine-description">
                {{ machine.description }}
              </div>
            </div>
            <div class="machine-actions">
              <button class="btn-icon" @click="editMachine(machine)">
                <IconSvg name="edit" :size="16" />
              </button>
              <button class="btn-icon danger" @click="deleteMachine(machine.id)">
                <IconSvg name="trash" :size="16" />
              </button>
            </div>
          </div>

          <div v-if="machines.length === 0" class="empty-state">
            <IconSvg name="folder" :size="48" style="opacity: 0.3; margin-bottom: 16px;" />
            <p>ยังไม่มีเครื่องจักร</p>
          </div>
        </div>
      </div>
    </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import IconSvg from './IconSvg.vue'
import { useToast } from '../composables/useToast'

const emit = defineEmits(['close', 'updated'])
const { showToast } = useToast()

const machines = ref([])
const editingMachine = ref(null)
const formData = ref({
  id: '',
  name: '',
  description: '',
  location: '',
  status: 'active'
})

const statusClass = (status) => {
  return {
    'status-active': status === 'active',
    'status-inactive': status === 'inactive',
    'status-maintenance': status === 'maintenance'
  }
}

const statusText = (status) => {
  const texts = {
    active: 'ใช้งาน',
    inactive: 'ไม่ใช้งาน',
    maintenance: 'ซ่อมบำรุง'
  }
  return texts[status] || status
}

const loadMachines = async () => {
  try {
    const response = await fetch('/api/machines')
    const data = await response.json()
    
    if (data.success) {
      machines.value = data.machines || []
    } else {
      showToast(data.message || 'โหลดข้อมูลเครื่องจักรไม่สำเร็จ', 'error')
    }
  } catch (error) {
    console.error('Error loading machines:', error)
    showToast('เชื่อมต่อ backend ไม่ได้', 'error')
  }
}

const editMachine = (machine) => {
  editingMachine.value = machine
  formData.value = {
    id: machine.id,
    name: machine.name,
    description: machine.description || '',
    location: machine.location || '',
    status: machine.status || 'active'
  }
  showCreateForm.value = false
}

const cancelForm = () => {
  editingMachine.value = null
  formData.value = {
    id: '',
    name: '',
    description: '',
    location: '',
    status: 'active'
  }
}

const saveMachine = async () => {
  if (!formData.value.id || !formData.value.name) {
    showToast('กรุณากรอกข้อมูลที่จำเป็น', 'warning')
    return
  }

  try {
    const url = editingMachine.value 
      ? `/api/machines/${editingMachine.value.id}` 
      : '/api/machines'
    
    const method = editingMachine.value ? 'PUT' : 'POST'
    
    const response = await fetch(url, {
      method,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(formData.value)
    })
    
    const data = await response.json()
    
    if (data.success) {
      showToast(
        editingMachine.value ? 'แก้ไขเครื่องจักรสำเร็จ' : 'เพิ่มเครื่องจักรสำเร็จ',
        'success'
      )
      cancelForm()
      await loadMachines()
      emit('updated')
    } else {
      showToast(data.message || 'บันทึกไม่สำเร็จ', 'error')
    }
  } catch (error) {
    console.error('Error saving machine:', error)
    showToast('เกิดข้อผิดพลาดในการบันทึก', 'error')
  }
}

const deleteMachine = async (machineId) => {
  if (!confirm(`คุณต้องการลบเครื่องจักร ${machineId} หรือไม่?`)) {
    return
  }

  try {
    const response = await fetch(`/api/machines/${machineId}`, {
      method: 'DELETE'
    })
    
    const data = await response.json()
    
    if (data.success) {
      showToast('ลบเครื่องจักรสำเร็จ', 'success')
      await loadMachines()
      emit('updated')
    } else {
      showToast(data.message || 'ลบไม่สำเร็จ', 'error')
    }
  } catch (error) {
    console.error('Error deleting machine:', error)
    showToast('เกิดข้อผิดพลาดในการลบ', 'error')
  }
}

onMounted(() => {
  loadMachines()
})
</script>

<style scoped>
.machine-manager-panel {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 100001;
  padding: 20px;
}

.panel-wrapper {
  background: white;
  border-radius: 12px;
  max-width: 900px;
  width: 100%;
  max-height: 90vh;
  display: flex;
  flex-direction: column;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: 24px;
  border-bottom: 1px solid #e5e7eb;
  flex-shrink: 0;
}

.panel-title {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 24px;
  font-weight: 700;
  color: #111827;
  margin: 0;
  flex-direction: column;
  align-items: flex-start;
}

.subtitle {
  font-size: 14px;
  font-weight: 400;
  color: #6b7280;
  margin-top: 4px;
}

.close-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 8px;
  border-radius: 6px;
  color: #6b7280;
  transition: all 0.2s;
}

.close-btn:hover {
  background: #f3f4f6;
  color: #111827;
}

.panel-content {
  padding: 24px;
  overflow-y: auto;
  flex: 1;
}

.machine-list-section {
  margin-bottom: 24px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.section-header h3 {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: #111827;
}

.machine-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.machine-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  background: #f9fafb;
  border: 2px solid transparent;
  border-radius: 8px;
  transition: all 0.2s;
}

.machine-item:hover {
  background: #f3f4f6;
  border-color: #3b82f6;
}

.machine-info {
  flex: 1;
}

.machine-name {
  font-size: 16px;
  font-weight: 600;
  color: #111827;
  margin-bottom: 8px;
}

.machine-details {
  display: flex;
  gap: 8px;
  align-items: center;
  flex-wrap: wrap;
  margin-bottom: 4px;
}

.machine-description {
  font-size: 13px;
  color: #6b7280;
  margin-top: 8px;
  line-height: 1.5;
}

.badge {
  padding: 4px 10px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 500;
}

.badge-info {
  background: #dbeafe;
  color: #1d4ed8;
}

.location {
  font-size: 12px;
  color: #6b7280;
}

.status-badge {
  padding: 4px 10px;
  border-radius: 6px;
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
}

.status-active {
  background: #d1fae5;
  color: #047857;
}

.status-inactive {
  background: #f3f4f6;
  color: #6b7280;
}

.status-maintenance {
  background: #fef3c7;
  color: #b45309;
}

.machine-actions {
  display: flex;
  gap: 8px;
}

.btn-icon {
  background: #f3f4f6;
  border: none;
  border-radius: 8px;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #6b7280;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-icon:hover {
  background: #dbeafe;
  color: #1d4ed8;
}

.btn-icon.danger:hover {
  background: #fee2e2;
  color: #dc2626;
}

.empty-state {
  text-align: center;
  padding: 48px 24px;
  color: #9ca3af;
}

.empty-state p {
  margin: 0 0 16px 0;
  font-size: 14px;
  color: #6b7280;
}

.machine-form-section {
  background: #f9fafb;
  border-radius: 12px;
  padding: 24px;
  border: 1px solid #e5e7eb;
}

.machine-form-section h3 {
  color: #111827;
  font-size: 16px;
  margin: 0 0 20px 0;
  font-weight: 600;
}

.form-group {
  margin-bottom: 16px;
}

.form-group label {
  display: block;
  color: #374151;
  font-size: 13px;
  margin-bottom: 8px;
  font-weight: 500;
}

.required {
  color: #dc2626;
}

.form-input,
.form-textarea,
.form-select {
  width: 100%;
  background: white;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  padding: 10px 12px;
  color: #111827;
  font-size: 14px;
  transition: all 0.2s;
}

.form-input:focus,
.form-textarea:focus,
.form-select:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.form-input:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  background: #f3f4f6;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.form-actions {
  display: flex;
  gap: 12px;
  margin-top: 24px;
}

.btn {
  padding: 10px 20px;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  gap: 8px;
  justify-content: center;
}

.btn-primary {
  background: #3b82f6;
  color: white;
  flex: 1;
}

.btn-primary:hover:not(:disabled) {
  background: #2563eb;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
}

.btn-primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-secondary {
  background: #f3f4f6;
  color: #374151;
}

.btn-secondary:hover {
  background: #e5e7eb;
}

.btn-sm {
  padding: 8px 16px;
  font-size: 13px;
}
</style>
