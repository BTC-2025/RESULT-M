import express from 'express';
import mongoose from 'mongoose';
import cors from 'cors';
import dotenv from 'dotenv';
import morgan from 'morgan';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());
app.use(morgan('dev')); // Log all HTTP requests to terminal

// Routes
import authRoutes from './routes/authRoutes';
import userRoutes from './routes/userRoutes';
import workspaceRoutes from './routes/workspaceRoutes';
import feedPostRoutes from './routes/feedPostRoutes';
import complaintRoutes from './routes/complaintRoutes';
import searchRoutes from './routes/searchRoutes';
import adminRoutes from './routes/adminRoutes';
import feedRoutes from './routes/feedRoutes';
import notificationRoutes from './routes/notificationRoutes';
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/users', userRoutes);
app.use('/api/v1/workspaces', workspaceRoutes);
app.use('/api/v1/posts', feedPostRoutes);
app.use('/api/v1/complaints', complaintRoutes);
app.use('/api/v1/search', searchRoutes);
app.use('/api/v1/admin', adminRoutes);
app.use('/api/v1/feed', feedRoutes);
app.use('/api/v1/notifications', notificationRoutes);

// MongoDB Connection
const MONGO_URI = process.env.MONGO_URI || 'mongodb://root:password@localhost:27017/resulthub?authSource=admin';

mongoose.connect(MONGO_URI)
  .then(() => console.log('✅ Successfully connected to MongoDB.'))
  .catch((err) => console.error('❌ MongoDB connection error:', err));

import { errorHandler } from './middleware/errorHandler';

// Basic Route
app.get('/api/v1/health', (req, res) => {
  res.json({ status: 'UP', message: 'MERN Backend is running smoothly.' });
});

// Global Error Handler
app.use(errorHandler);

app.listen(PORT, () => {
  console.log(`🚀 Server is running on http://localhost:${PORT}`);
});
