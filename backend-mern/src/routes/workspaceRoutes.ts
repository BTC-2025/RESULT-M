import express from 'express';
import { requireAuth } from '../middleware/auth';
import { 
  createWorkspace, 
  getWorkspace, 
  getWorkspaceBySlug, 
  getMyWorkspaces, 
  getPublicWorkspaces, 
  updateWorkspace, 
  deleteWorkspace 
} from '../controllers/workspaceController';

const router = express.Router();

router.get('/public', getPublicWorkspaces);
router.get('/my', requireAuth, getMyWorkspaces);
router.get('/slug/:slug', getWorkspaceBySlug);
router.get('/:id', getWorkspace);

router.post('/', requireAuth, createWorkspace);
router.put('/:id', requireAuth, updateWorkspace);
router.delete('/:id', requireAuth, deleteWorkspace);

export default router;
