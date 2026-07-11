import express from 'express';
import { requireAuth } from '../middleware/auth';
import { UserRole } from '../models/User';
import { 
  getPlatformStats, 
  getSystemHealth, 
  searchUsers, 
  getUser, 
  suspendUser, 
  updateUserQuota, 
  changeUserRole, 
  resetUserPassword, 
  deleteUser, 
  getAllWorkspaces, 
  deleteWorkspace, 
  getAllPosts, 
  deletePost 
} from '../controllers/adminController';

const router = express.Router();

const requireAdmin = (req: any, res: any, next: any) => {
  if (req.user && req.user.role === UserRole.ADMIN) {
    next();
  } else {
    res.status(403).json({ message: 'Access denied: Admin role required' });
  }
};

// All admin routes require auth AND admin role
router.use(requireAuth, requireAdmin);

router.get('/stats', getPlatformStats);
router.get('/system/health', getSystemHealth);

router.get('/users', searchUsers);
router.get('/users/:userId', getUser);
router.put('/users/:userId/suspend', suspendUser);
router.put('/users/:userId/quota', updateUserQuota);
router.put('/users/:userId/role', changeUserRole);
router.post('/users/:userId/reset-password', resetUserPassword);
router.delete('/users/:userId', deleteUser);

router.get('/workspaces', getAllWorkspaces);
router.delete('/workspaces/:workspaceId', deleteWorkspace);

router.get('/posts', getAllPosts);
router.delete('/posts/:postId', deletePost);

export default router;
