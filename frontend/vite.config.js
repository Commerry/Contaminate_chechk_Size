import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  server: {
    host: '0.0.0.0', // เปิดให้เครื่องอื่นเข้าถึงได้
    port: 64021,
    proxy: {
      '/api': {
        target: 'http://localhost:64020',
        changeOrigin: true
      }
    }
  }
})
