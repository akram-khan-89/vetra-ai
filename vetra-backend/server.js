require('dotenv').config();
const express = require('express');
const cors = require('cors');

/**
 * Vetra AI - Production Backend Entry
 * Features:
 * - CORS enabled
 * - JSON body parsing with 10mb limit
 * - Health check route
 * - Graceful shutdown logic
 */

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Basic Request Logger for development/production visibility
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  next();
});

// Health Route
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'UP',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    service: 'Vetra AI Backend'
  });
});

// Root Route
app.get('/', (req, res) => {
  res.send('Vetra AI API is running...');
});

// 404 Handler
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Global Error Handler
app.use((err, req, res, next) => {
  console.error('Unhandled Error:', err);
  res.status(err.status || 500).json({
    error: {
      message: err.message || 'Internal Server Error',
      ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
    }
  });
});

// Start Server
const server = app.listen(PORT, () => {
  console.log(`\n🚀 Vetra AI Server is running in ${process.env.NODE_ENV || 'development'} mode`);
  console.log(`📡 Listening on port: ${PORT}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health\n`);
});

// Graceful Shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('SIGINT signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
    process.exit(0);
  });
});
