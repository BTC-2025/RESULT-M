import express from 'express';
import multer from 'multer';
import { requireAuth } from '../middleware/auth';
import { 
  createPost, 
  getWorkspacePosts, 
  getPost, 
  likePost, 
  unlikePost, 
  getComments, 
  addComment 
} from '../controllers/feedPostController';

const router = express.Router();
const upload = multer({ dest: 'uploads/' });

router.get('/:postId', getPost);
router.get('/workspaces/:workspaceId', getWorkspacePosts);
router.get('/:postId/comments', getComments);

router.post('/', requireAuth, upload.array('files'), createPost);
router.post('/:postId/like', requireAuth, likePost);
router.delete('/:postId/like', requireAuth, unlikePost);
router.post('/:postId/comments', requireAuth, addComment);

export default router;
