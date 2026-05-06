/**
 * PSE Vision - Dev Launcher
 * Usage: npm run dev  (from project root)
 *
 * - Kills any existing process on port 64020 (backend) and 64021 (frontend)
 * - Starts Python backend + Vite frontend concurrently
 * - Ctrl+C kills both cleanly
 */
const { execSync, spawn } = require('child_process');
const path = require('path');

const ROOT = __dirname;
const PORTS = [64020, 64021];

// ── Kill any process listening on the given port ──────────────────────────────
function killPort(port) {
  try {
    const out = execSync(`netstat -ano | findstr :${port}`, { encoding: 'utf8' });
    for (const line of out.split('\n')) {
      const parts = line.trim().split(/\s+/);
      // parts: [proto, local, foreign, state, pid]
      if (
        parts.length >= 5 &&
        parts[1].endsWith(`:${port}`) &&
        parts[3] === 'LISTENING'
      ) {
        const pid = parseInt(parts[4]);
        if (pid > 0) {
          try {
            execSync(`taskkill /F /PID ${pid}`, { stdio: 'pipe' });
            console.log(`  [KILL] PID ${pid} on port ${port}`);
          } catch (_) {}
        }
      }
    }
  } catch (_) {
    // No process on this port — that's fine
  }
}

console.log('\n====================================================');
console.log('  PSE Vision - Dev Launcher');
console.log('====================================================\n');

console.log('[1/2] Clearing existing processes...');
PORTS.forEach(killPort);
console.log('[OK]  Ports 64020 and 64021 are free\n');

console.log('[2/2] Starting Backend + Frontend...\n');

// ── Spawn a process and prefix every output line with a coloured label ────────
const children = [];

function spawnProc(label, colorCode, cmd, args, cwd) {
  const proc = spawn(cmd, args, { cwd, shell: true, stdio: 'pipe' });
  children.push(proc);

  const prefix = `\x1b[${colorCode}m[${label}]\x1b[0m`;

  proc.stdout.on('data', (d) => {
    process.stdout.write(d.toString().replace(/^(?=.)/gm, `${prefix} `));
  });
  proc.stderr.on('data', (d) => {
    process.stderr.write(d.toString().replace(/^(?=.)/gm, `${prefix} `));
  });

  proc.on('exit', (code) => {
    console.log(`\n${prefix} Process exited (code ${code ?? 0})`);
    // If one process dies unexpectedly, kill the other too
    children.forEach((c) => {
      try { c.kill(); } catch (_) {}
    });
    process.exit(code ?? 0);
  });

  return proc;
}

// Backend: Python from project root
spawnProc('BACKEND ', '34;1', 'python', ['python_scripts/backend_server.py'], ROOT);

// Frontend: Vite inside frontend/ directory
spawnProc('FRONTEND', '32;1', 'npm', ['run', 'frontend'], path.join(ROOT, 'frontend'));

// ── Ctrl+C handler ─────────────────────────────────────────────────────────────
process.on('SIGINT', () => {
  console.log('\n\n[DEV] Shutting down (Ctrl+C)...');
  children.forEach((c) => {
    try { c.kill(); } catch (_) {}
  });
  setTimeout(() => process.exit(0), 800);
});
