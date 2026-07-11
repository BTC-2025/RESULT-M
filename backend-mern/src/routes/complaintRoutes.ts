import express from 'express';
import multer from 'multer';
import { requireAuth } from '../middleware/auth';
import { 
  getComplaints, 
  getWorkspaceComplaints, 
  createComplaint, 
  updateStatus, 
  upvoteComplaint, 
  removeUpvote 
} from '../controllers/complaintController';

const router = express.Router();
const upload = multer({ dest: 'uploads/' });

router.get('/', getComplaints);
router.get('/workspaces/:workspaceId', getWorkspaceComplaints);

router.post('/', requireAuth, upload.array('files'), createComplaint);
router.patch('/:id/status', requireAuth, updateStatus);
router.post('/:id/upvote', requireAuth, upvoteComplaint);
router.delete('/:id/upvote', requireAuth, removeUpvote);

export default router;
