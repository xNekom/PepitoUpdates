const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');

const app = express();
const PORT = 3001;

// Habilitar CORS para todas las rutas
app.use(cors());

// Proxy para thecatdoor API
app.use('/api/thecatdoor', createProxyMiddleware({
  target: 'https://api.thecatdoor.com',
  changeOrigin: true,
  secure: true,
  pathRewrite: {
    '^/api/thecatdoor': '',
  },
  onProxyReq: (proxyReq, req, res) => {
    console.log(`[PROXY] ${req.method} ${req.url} -> ${proxyReq.path}`);
  },
  onError: (err, req, res) => {
    console.error(`[PROXY ERROR] ${req.method} ${req.url}:`, err.message);
  }
}));

// Proxy para Supabase
app.use('/api/supabase', createProxyMiddleware({
  target: 'https://ewxarmlqoowlxdqoebcb.supabase.co',
  changeOrigin: true,
  secure: true,
  pathRewrite: {
    '^/api/supabase': '',
  },
  onProxyReq: (proxyReq, req, res) => {
    console.log(`[PROXY] ${req.method} ${req.url} -> ${proxyReq.path}`);
  },
  onError: (err, req, res) => {
    console.error(`[PROXY ERROR] ${req.method} ${req.url}:`, err.message);
  }
}));

app.listen(PORT, () => {
  console.log(`🚀 Proxy server running on http://localhost:${PORT}`);
  console.log(`📡 Proxying:`);
  console.log(`   /api/thecatdoor/* -> https://api.thecatdoor.com/*`);
  console.log(`   /api/supabase/* -> https://ewxarmlqoowlxdqoebcb.supabase.co/*`);
});