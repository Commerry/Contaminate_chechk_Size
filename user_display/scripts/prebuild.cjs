#!/usr/bin/env node

/**
 * Pre-Build Script for PSE Vision Installer
 * Automatically builds Admin Web before packaging
 */

const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

const PROJECT_ROOT = path.resolve(__dirname, '../..');
const FRONTEND = path.join(PROJECT_ROOT, 'frontend');

console.log('🔧 Pre-Build: Building Admin Web (Vue.js)...');
console.log('─'.repeat(60));
console.log(`📁 Frontend path: ${FRONTEND}`);

// Check if frontend exists
if (!fs.existsSync(FRONTEND)) {
  console.log('⚠️  Frontend directory not found, skipping...');
  process.exit(0);
}

// Check if frontend has package.json
const frontendPackageJson = path.join(FRONTEND, 'package.json');
if (!fs.existsSync(frontendPackageJson)) {
  console.log('⚠️  Frontend package.json not found, skipping...');
  process.exit(0);
}

try {
  // Build frontend
  console.log(`📁 Building frontend at: ${FRONTEND}`);
  execSync('npm run build', {
    cwd: FRONTEND,
    stdio: 'inherit',
    windowsHide: true
  });
  
  console.log('✅ Admin Web built successfully!');
  console.log('');
} catch (error) {
  console.error('❌ Frontend build failed:', error.message);
  console.log('⚠️  Continuing without frontend...');
  // Don't fail the entire build
}
