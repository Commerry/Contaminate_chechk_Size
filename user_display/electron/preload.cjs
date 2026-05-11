const { contextBridge } = require('electron')

contextBridge.exposeInMainWorld('appInfo', {
  mode: 'desktop'
})
