# OAK Camera Object Measurement System - Vue.js Frontend

Modern, responsive web interface for the Luxonis OAK Camera object measurement system.

## Features

- 🎥 **Live Camera Feed** - Real-time video stream from OAK camera
- 📏 **Object Detection & Measurement** - Automatic width, height, and depth measurement
- 🎲 **3D Visualization** - Interactive 3D representation of measured objects
- ⚙️ **Advanced Settings** - Comprehensive configuration panel
- 📊 **Statistics & Analytics** - Track measurement history and averages
- 💾 **Data Export** - Export measurements in JSON format
- 🎨 **Modern UI** - Clean, dark-themed interface with smooth animations

## Technology Stack

- **Vue 3** - Progressive JavaScript framework
- **Vite** - Next-generation frontend build tool
- **Pinia** - State management
- **Axios** - HTTP client for API communication

## Project Structure

```
frontend/
├── src/
│   ├── components/
│   │   ├── Sidebar.vue              # Navigation and quick actions
│   │   ├── CameraView.vue           # Live camera feed with detection overlay
│   │   ├── MeasurementDisplay.vue   # Measurement values and 3D visualization
│   │   └── SettingsPanel.vue        # Configuration panel
│   ├── services/
│   │   └── measurementService.js    # API communication service
│   ├── stores/
│   │   └── measurementStore.js      # Pinia store for state management
│   ├── App.vue                      # Main application component
│   ├── main.js                      # Application entry point
│   └── style.css                    # Global styles
├── index.html
├── vite.config.js
└── package.json
```

## Installation

### Prerequisites

- Node.js 16+ and npm
- Python backend server running (see main README)

### Setup

1. Navigate to the frontend directory:
```cmd
cd frontend
```

2. Install dependencies:
```cmd
npm install
```

3. Start the development server:
```cmd
npm run dev
```

4. Open your browser and navigate to:
```
http://localhost:3000
```

## Configuration

### API Endpoint

The frontend connects to the Python backend API. Configure the endpoint in `src/services/measurementService.js`:

```javascript
const API_BASE_URL = 'http://localhost:5000/api'
```

### Vite Proxy

The Vite dev server is configured to proxy API requests. See `vite.config.js`:

```javascript
server: {
  port: 3000,
  proxy: {
    '/api': {
      target: 'http://localhost:5000',
      changeOrigin: true
    }
  }
}
```

## Usage

### Starting the Camera

1. Click **"Start Camera"** in the sidebar
2. Wait for the connection to establish
3. The live feed will appear with detection overlays

### Adjusting Settings

1. Click the **Settings** button in the sidebar
2. Configure camera, measurement, and detection parameters
3. Click **Save Settings** to apply changes

Available settings:
- **Camera**: Resolution, FPS limit, depth map display
- **Measurement**: Unit (mm/cm/m/in), depth range, auto-capture
- **Detection**: Confidence threshold, minimum object size
- **Calibration**: Reference object size

### Viewing Measurements

Real-time measurements are displayed in the right panel:
- **Width**: Horizontal dimension
- **Height**: Vertical dimension
- **Depth**: Distance from camera
- **Volume**: Calculated volume
- **3D Visualization**: Animated 3D box representation

### Exporting Data

Click the **"Export Data"** button to download measurements as JSON:
```json
{
  "timestamp": "2025-12-06T...",
  "measurements": {
    "width": 150.5,
    "height": 200.3,
    "depth": 100.8,
    "volume": 3045678.2
  },
  "unit": "mm"
}
```

## Building for Production

1. Build the application:
```cmd
npm run build
```

2. Preview the production build:
```cmd
npm run preview
```

3. Deploy the `dist/` folder to your web server

## API Endpoints

The frontend expects these backend endpoints:

- `POST /api/camera/connect` - Connect to camera
- `POST /api/camera/disconnect` - Disconnect camera
- `GET /api/camera/status` - Get camera status
- `GET /api/measurement/current` - Get current frame and measurements
- `POST /api/measurement/snapshot` - Capture snapshot
- `POST /api/measurement/reset` - Reset measurements
- `GET /api/settings` - Get current settings
- `POST /api/settings/update` - Update settings
- `POST /api/calibration/start` - Start calibration

## Customization

### Changing Colors

Edit CSS variables in `src/style.css`:

```css
:root {
  --primary-color: #2563eb;
  --secondary-color: #8b5cf6;
  --bg-dark: #0f172a;
  --bg-card: #1e293b;
  /* ... more variables */
}
```

### Adding Components

1. Create new component in `src/components/`
2. Import and use in `App.vue` or other components
3. Add to store if state management is needed

## Troubleshooting

### Camera Not Connecting

- Ensure Python backend is running on port 5000
- Check browser console for API errors
- Verify CORS settings on backend

### Slow Performance

- Reduce FPS limit in settings
- Disable depth map visualization
- Check network latency to backend

### Detection Issues

- Adjust confidence threshold in settings
- Verify lighting conditions
- Calibrate with reference object

## License

Copyright © 2025 PSE Vision Project

## Support

For issues and questions, please refer to the main project documentation.
