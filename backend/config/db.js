const mongoose = require('mongoose');

async function connectDB() {
  const mongoUri = process.env.MONGO_URI;

  if (!mongoUri) {
    throw new Error('MONGO_URI is not configured');
  }

  await mongoose.connect(mongoUri);
  console.log('MongoDB connected');
}

function isDatabaseReady() {
  return mongoose.connection.readyState === 1;
}

module.exports = connectDB;
module.exports.isDatabaseReady = isDatabaseReady;
