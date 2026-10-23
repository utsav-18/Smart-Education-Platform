const express = require('express');
const cors = require('cors');
const database = require('./config/db');
const courseRoutes = require('./routes/courseRoutes');

const app = express();

const defaultOrigins = [
  'http://localhost:5173',
  'http://localhost:3000',
  'http://localhost:8080',
  'http://localhost',
];

const rawOrigin = process.env.CLIENT_ORIGIN;
const corsOrigin = !rawOrigin
  ? defaultOrigins
  : rawOrigin === '*'
    ? '*'
    : rawOrigin.split(',').map((origin) => origin.trim());

app.use(
  cors({
    origin: corsOrigin,
    methods: ['GET', 'POST', 'OPTIONS'],
  }),
);
app.use(express.json());

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

app.get('/readyz', (req, res) => {
  if (!database.isDatabaseReady()) {
    return res.status(503).json({ status: 'not ready' });
  }

  return res.status(200).json({ status: 'ready' });
});

app.use('/api/courses', (req, res, next) => {
  if (!database.isDatabaseReady()) {
    return res.status(503).json({ error: 'Service unavailable' });
  }

  return next();
}, courseRoutes);

app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

app.use((error, req, res, next) => {
  console.error(error);
  res.status(500).json({ error: 'Internal server error' });
});

module.exports = app;
