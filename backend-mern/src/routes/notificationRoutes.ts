import express from 'express';
import { requireAuth } from '../middleware/auth';

const router = express.Router();

// Mock notifications
router.get('/', requireAuth, (req, res) => {
  res.status(200).json({
    content: [],
    totalElements: 0,
    totalPages: 0
  });
});

export default router;
