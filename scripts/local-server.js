// Simple local backend for testing the REAL app without Vercel.
// Serves POST /api/analyze using the same handler as api/analyze.js.
// Reads GEMINI_API_KEY from .env. Run: node scripts/local-server.js
// Then: cd app && flutter run -d chrome --dart-define=API_BASE=http://localhost:3000

const http = require('http');
const fs = require('fs');
const path = require('path');

// Load .env into process.env (no dependency).
const envPath = path.join(__dirname, '..', '.env');
if (fs.existsSync(envPath)) {
  for (const line of fs.readFileSync(envPath, 'utf8').split('\n')) {
    const m = line.match(/^\s*([A-Z_]+)\s*=\s*(.*)\s*$/);
    if (m) process.env[m[1]] = m[2].replace(/^["']|["']$/g, '');
  }
}
if (!process.env.GEMINI_API_KEY) {
  console.error('No GEMINI_API_KEY found in .env. Add it and try again.');
  process.exit(1);
}

// The real Vercel handler (same code that deploys).
const handler = require('../api/analyze.js');

const PORT = 3000;
const MAX_BODY = 8 * 1024 * 1024; // 8 MB, room for multi-page

// Allow the local Flutter web app (any localhost port) to call us.
function setCors(req, res) {
  const origin = req.headers.origin || '*';
  res.setHeader('Access-Control-Allow-Origin', origin);
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  res.setHeader('Access-Control-Max-Age', '86400');
}

const server = http.createServer((req, res) => {
  const url = (req.url || '').split('?')[0];

  // Answer the browser's CORS preflight ourselves.
  if (req.method === 'OPTIONS') {
    setCors(req, res);
    res.writeHead(204);
    res.end();
    return;
  }

  if (url !== '/api/analyze') {
    setCors(req, res);
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Not found. POST to /api/analyze' }));
    return;
  }

  const chunks = [];
  let size = 0;
  req.on('data', (c) => {
    size += c.length;
    if (size > MAX_BODY) { req.destroy(); return; }
    chunks.push(c);
  });
  req.on('end', () => {
    let body = {};
    if (chunks.length) {
      try { body = JSON.parse(Buffer.concat(chunks).toString('utf8')); }
      catch { /* leave as {} */ }
    }

    const shim = { method: req.method, headers: req.headers, body };
    const resShim = {
      _status: 200,
      setHeader: (k, v) => res.setHeader(k, v),
      status(code) { this._status = code; return this; },
      json(obj) {
        setCors(req, res); // ensure CORS on the actual response too
        res.writeHead(this._status, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(obj));
      },
      end() { setCors(req, res); res.writeHead(this._status); res.end(); },
    };

    const t0 = Date.now();
    Promise.resolve(handler(shim, resShim))
      .then(() => console.log(`POST /api/analyze -> ${resShim._status} (${Date.now() - t0}ms)`))
      .catch((e) => {
        console.error('handler error', e);
        if (!res.headersSent) {
          setCors(req, res);
          res.writeHead(500, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ error: 'Server error' }));
        }
      });
  });
});

server.listen(PORT, () => {
  console.log(`Local Veracity backend on http://localhost:${PORT}`);
  console.log('Keep this running. In another terminal:');
  console.log('  cd app  &&  flutter run -d chrome --dart-define=API_BASE=http://localhost:3000');
  console.log('(No DEMO flag = it reads your real document.)');
});
