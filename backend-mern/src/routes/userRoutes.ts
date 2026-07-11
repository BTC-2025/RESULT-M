import express from 'express';
import { getMyProfile, updateMyProfile, deleteMyAccount, getPublicProfile, followUser, unfollowUser, blockUser } from '../controllers/userController';
import { requireAuth } from '../middleware/auth';

const router = express.Router();

router.get('/me', requireAuth, getMyProfile);
router.put('/me', requireAuth, updateMyProfile);
router.delete('/me', requireAuth, deleteMyAccount);

router.get('/:userId/profile', getPublicProfile);

router.post('/:userId/follow', requireAuth, followUser);
router.delete('/:userId/follow', requireAuth, unfollowUser);

router.post('/:userId/block', requireAuth, blockUser);

export default router;
