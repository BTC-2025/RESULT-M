import express from 'express';
import { globalSearch } from '../controllers/searchController';
import { requireAuth } from '../middleware/auth';

const router = express.Router();

// Route can be public or require auth depending on original design
// The java code had `required = false` for auth header, so we'll make it public
// but pass token optionally if we had an optionalAuth middleware. For now, public.
router.get('/', globalSearch);

export default router;
