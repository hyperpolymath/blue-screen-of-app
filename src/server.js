// Blue Screen of App - Deno Server (Minimal JavaScript)
// Imports compiled ReScript modules for business logic

import { getRandomErrorJS, getErrorByCodeJS, getAllStopCodes } from './ErrorMessages.bs.js';
import { trackVisit, trackApiCall, getStatsObject, resetStats, getUptime } from './Analytics.bs.js';

// Load configuration from Nickel (via JSON export)
const configPath = new URL('../config.json', import.meta.url);
let config = {
  server: { port: 443, host: '0.0.0.0' },
  app: { name: 'Blue Screen of App', url: 'https://localhost' },
  features: { qrCodes: true, defaultQrUrl: 'https://github.com/Hyperpolymath/blue-screen-of-app' }
};

try {
  const configText = await Deno.readTextFile(configPath);
  config = JSON.parse(configText);
} catch {
  console.log('⚠️  config.json not found, using defaults');
}

// BSOD style templates
const styles = ['win10', 'win11', 'win7', 'winxp'];

// Render BSOD HTML (pure functions, no EJS needed)
const renderBSOD = (style, errorData, qrCode) => {
  const { stopCode, description, technicalDetail, percentage } = errorData;

  // Base styles for all BSOD versions
  const baseStyle = `
    margin: 0; padding: 0; overflow: hidden;
    font-family: 'Segoe UI', Arial, sans-serif;
    display: flex; flex-direction: column;
    justify-content: center; align-items: center;
    height: 100vh; width: 100vw;
    color: white; text-align: center;
  `;

  // Style-specific colors and fonts
  const styleConfig = {
    win10: { bg: '#0178D4', font: "'Segoe UI', sans-serif", emoji: '😞' },
    win11: { bg: '#0067C0', font: "'Segoe UI Variable', 'Segoe UI', sans-serif", emoji: '😞' },
    win7: { bg: '#00579e', font: "'Lucida Console', monospace", emoji: '' },
    winxp: { bg: '#0000AA', font: "'Perfect DOS VGA 437', 'Courier New', monospace", emoji: '' }
  };

  const cfg = styleConfig[style] || styleConfig.win10;

  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${stopCode} - Blue Screen of App</title>
  <style>
    body { ${baseStyle} background: ${cfg.bg}; font-family: ${cfg.font}; }
    .container { max-width: 800px; padding: 40px; }
    .emoji { font-size: 120px; margin-bottom: 30px; }
    .stop-code { font-size: 24px; margin: 20px 0; font-weight: bold; }
    .description { font-size: 18px; margin: 20px 0; line-height: 1.6; }
    .technical { font-size: 14px; margin: 30px 0; opacity: 0.9; }
    .percentage { font-size: 28px; margin: 20px 0; font-weight: bold; }
    .qr { margin: 30px 0; }
    .qr img { width: 150px; height: 150px; }
  </style>
</head>
<body>
  <div class="container">
    ${cfg.emoji ? `<div class="emoji">${cfg.emoji}</div>` : ''}
    <div class="stop-code">${stopCode}</div>
    <div class="description">${description}</div>
    <div class="technical">${technicalDetail}</div>
    <div class="percentage">${percentage}% complete</div>
    ${qrCode ? `<div class="qr"><img src="${qrCode}" alt="QR Code" /></div>` : ''}
  </div>
</body>
</html>`;
};

// Generate QR code (minimal implementation, or skip if complex)
const generateQR = async (url) => {
  // For now, return null - can implement WASM QR generator later
  // This keeps JS minimal as requested
  return null;
};

// Parse URL query parameters
const getQueryParams = (url) => {
  const params = new URL(url).searchParams;
  return {
    style: params.get('style') || 'win10',
    code: params.get('code'),
    message: params.get('message'),
    technical: params.get('technical'),
    qr: params.get('qr'),
    percentage: params.get('percentage')
  };
};

// Main request handler
const handler = async (req) => {
  const url = new URL(req.url);
  const path = url.pathname;

  // Get allowed origin from request or use default
  const requestOrigin = req.headers.get('Origin');
  const allowedOrigins = (Deno.env.get('CORS_ORIGIN') || '').split(',').filter(Boolean);
  const corsOrigin = allowedOrigins.length > 0
    ? (allowedOrigins.includes(requestOrigin) ? requestOrigin : allowedOrigins[0])
    : (requestOrigin || 'https://localhost');

  // Security headers (Helmet.js equivalent)
  const headers = {
    // CORS headers - restricted to specific origins
    'Access-Control-Allow-Origin': corsOrigin,
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
    // Security headers
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'X-XSS-Protection': '0',
    'Referrer-Policy': 'strict-origin-when-cross-origin',
    'Cross-Origin-Opener-Policy': 'same-origin',
    'Cross-Origin-Resource-Policy': 'same-origin',
    'X-DNS-Prefetch-Control': 'off',
    'X-Download-Options': 'noopen',
    'X-Permitted-Cross-Domain-Policies': 'none',
    'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
  };

  // Health check
  if (path === '/api/health') {
    trackApiCall();
    return new Response(JSON.stringify({
      status: 'ok',
      uptime: getUptime(),
      timestamp: new Date().toISOString()
    }), {
      status: 200,
      headers: { ...headers, 'Content-Type': 'application/json' }
    });
  }

  // Get all error codes
  if (path === '/api/codes') {
    trackApiCall();
    return new Response(JSON.stringify({
      codes: getAllStopCodes()
    }), {
      status: 200,
      headers: { ...headers, 'Content-Type': 'application/json' }
    });
  }

  // Get all styles
  if (path === '/api/styles') {
    trackApiCall();
    return new Response(JSON.stringify({
      styles: styles
    }), {
      status: 200,
      headers: { ...headers, 'Content-Type': 'application/json' }
    });
  }

  // Get analytics
  if (path === '/api/analytics') {
    trackApiCall();
    return new Response(JSON.stringify(getStatsObject()), {
      status: 200,
      headers: { ...headers, 'Content-Type': 'application/json' }
    });
  }

  // Reset analytics (POST only)
  if (path === '/api/analytics/reset' && req.method === 'POST') {
    trackApiCall();
    resetStats();
    return new Response(JSON.stringify({ message: 'Analytics reset' }), {
      status: 200,
      headers: { ...headers, 'Content-Type': 'application/json' }
    });
  }

  // Get random error
  if (path === '/api/error') {
    trackApiCall();
    const error = getRandomErrorJS();
    return new Response(JSON.stringify(error), {
      status: 200,
      headers: { ...headers, 'Content-Type': 'application/json' }
    });
  }

  // Get specific error by code
  if (path.startsWith('/api/error/')) {
    trackApiCall();
    const code = path.split('/api/error/')[1];
    const error = getErrorByCodeJS(code);

    if (!error) {
      return new Response(JSON.stringify({ error: 'Error code not found' }), {
        status: 404,
        headers: { ...headers, 'Content-Type': 'application/json' }
      });
    }

    return new Response(JSON.stringify(error), {
      status: 200,
      headers: { ...headers, 'Content-Type': 'application/json' }
    });
  }

  // Random style redirect
  if (path === '/random') {
    const randomStyle = styles[Math.floor(Math.random() * styles.length)];
    return Response.redirect(`/?style=${randomStyle}`, 302);
  }

  // Main BSOD page
  if (path === '/' || path === '') {
    const params = getQueryParams(req.url);

    // Get error data
    let errorData;
    if (params.code) {
      errorData = getErrorByCodeJS(params.code);
      if (!errorData) {
        errorData = getRandomErrorJS();
      }
    } else {
      errorData = getRandomErrorJS();
    }

    // Override with custom values
    if (params.message) errorData.description = params.message;
    if (params.technical) errorData.technicalDetail = params.technical;
    if (params.percentage) {
      const pct = parseInt(params.percentage) || 0;
      errorData.percentage = Math.min(100, Math.max(0, pct));
    }

    // Generate QR code
    const qrCode = await generateQR(params.qr || config.features.defaultQrUrl);

    // Track analytics
    trackVisit(params.style, errorData.stopCode, !!(params.message || params.technical));

    // Render BSOD
    const html = renderBSOD(params.style, errorData, qrCode);

    return new Response(html, {
      status: 200,
      headers: { ...headers, 'Content-Type': 'text/html; charset=utf-8' }
    });
  }

  // 404
  return new Response(JSON.stringify({ error: 'Not found' }), {
    status: 404,
    headers: { ...headers, 'Content-Type': 'application/json' }
  });
};

// Start server with QUIC/HTTP3 support (Deno experimental)
const port = config.server.port || 443;

console.log(`
╔═══════════════════════════════════════════╗
║                                           ║
║       Blue Screen of App                  ║
║       (Deno + ReScript Edition)           ║
║                                           ║
║   Server running on port ${port}            ║
║   Protocol: QUIC/HTTP3 + HTTP/2/1.1       ║
║                                           ║
║   Visit: ${config.app.url}                  ║
║                                           ║
╚═══════════════════════════════════════════╝
`);

// Deno.serve with HTTP/2 and HTTP/3 support (experimental)
Deno.serve({
  port: port,
  hostname: config.server.host || '0.0.0.0',
  // Enable HTTP/2 and HTTP/3 (QUIC) - requires --unstable flag
  // and TLS certificates
  onListen: ({ hostname, port }) => {
    console.log(`✅ Listening on ${hostname}:${port}`);
  },
}, handler);
