module.exports = {
  apps: [
    {
      name: 'pse-vision-backend',
      script: 'python_scripts/backend_server.py',
      interpreter: 'venv/bin/python',
      cwd: '/home/adminpse/pse-vision',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
        PYTHONUNBUFFERED: '1'
      },
      error_file: 'logs/pm2-backend-error.log',
      out_file: 'logs/pm2-backend-out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true,
      time: true
    },
    {
      name: 'pse-vision-display',
      script: 'user_display/dist-installer/pse-vision-worker-1.0.0.AppImage',
      cwd: '/home/adminpse/pse-vision',
      instances: 1,
      autorestart: true,
      watch: false,
      env: {
        DISPLAY: ':0',
        NODE_ENV: 'production'
      },
      error_file: 'logs/pm2-display-error.log',
      out_file: 'logs/pm2-display-out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true,
      time: true
    }
  ]
};
