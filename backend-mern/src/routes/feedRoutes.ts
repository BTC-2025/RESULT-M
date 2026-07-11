import express from 'express';
import { getFeed, getSavedItems, getUserFeed } from '../controllers/feedController';
import { requireAuth } from '../middleware/auth';

const router = express.Router();

// The frontend calls these without auth tokens on public feeds sometimes, 
// so we won't strictly enforce requireAuth on GET /
router.get('/', getFeed);
router.get('/saved', requireAuth, getSavedItems);
router.get('/user/:userId', getUserFeed);

export default router;
