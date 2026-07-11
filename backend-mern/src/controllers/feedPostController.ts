import { Request, Response } from 'express';
import FeedPost from '../models/FeedPost';
import FeedPostComment from '../models/FeedPostComment';
import FeedPostLike from '../models/FeedPostLike';
import FeedPostBookmark from '../models/FeedPostBookmark';
import { AuthRequest } from '../middleware/auth';

// @route   POST /api/v1/posts
export const createPost = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    let data = req.body;
    if (req.body.data) {
      try {
        data = typeof req.body.data === 'string' ? JSON.parse(req.body.data) : req.body.data;
      } catch (e) {
        data = req.body;
      }
    }
    
    const { postType, text, category, locationName, workspaceId, mediaUrls } = data;
    
    // In Express with Multer, files are in req.files
    // We would upload these to S3/Cloudinary and get URLs back.
    // For now, we will simulate storing file paths if files are present.
    const fileUrls: string[] = [];
    if (req.files && Array.isArray(req.files)) {
      req.files.forEach(file => {
        fileUrls.push(`/uploads/${file.filename}`);
      });
    }
    
    const postPayload: any = {
      creator: req.user.id,
      postType,
      text,
      category,
      locationName,
      mediaUrls: mediaUrls || fileUrls
    };

    if (workspaceId) {
      postPayload.workspace = workspaceId;
    }

    const post = await FeedPost.create(postPayload);

    res.status(201).json(post);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   GET /api/v1/posts/workspaces/:workspaceId
export const getWorkspacePosts = async (req: Request, res: Response): Promise<void> => {
  try {
    const posts = await FeedPost.find({ workspace: req.params.workspaceId, deletedAt: null })
      .populate('creator', 'name email profilePictureBase64')
      .sort({ createdAt: -1 });
      
    res.status(200).json({
      content: posts,
      totalElements: posts.length,
      totalPages: 1
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   GET /api/v1/posts/:postId
export const getPost = async (req: Request, res: Response): Promise<void> => {
  try {
    const post = await FeedPost.findById(req.params.postId)
      .populate('creator', 'name email profilePictureBase64');
      
    if (!post) {
      res.status(404).json({ message: 'Post not found' });
      return;
    }
    res.status(200).json(post);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   POST /api/v1/posts/:postId/like
export const likePost = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const postId = req.params.postId;
    const userId = req.user.id;

    const existingLike = await FeedPostLike.findOne({ post: postId, user: userId });
    if (!existingLike) {
      await FeedPostLike.create({ post: postId, user: userId });
      await FeedPost.findByIdAndUpdate(postId, { $inc: { likeCount: 1 } });
    }
    
    res.status(200).json({ message: 'Post liked' });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   DELETE /api/v1/posts/:postId/like
export const unlikePost = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const postId = req.params.postId;
    const userId = req.user.id;

    const existingLike = await FeedPostLike.findOneAndDelete({ post: postId, user: userId });
    if (existingLike) {
      await FeedPost.findByIdAndUpdate(postId, { $inc: { likeCount: -1 } });
    }
    
    res.status(200).json({ message: 'Post unliked' });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   GET /api/v1/posts/:postId/comments
export const getComments = async (req: Request, res: Response): Promise<void> => {
  try {
    const comments = await FeedPostComment.find({ post: req.params.postId, deletedAt: null })
      .populate('creator', 'name email profilePictureBase64')
      .sort({ createdAt: 1 });
      
    res.status(200).json(comments);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   POST /api/v1/posts/:postId/comments
export const addComment = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { content, parentCommentId } = req.body;
    
    const comment = await FeedPostComment.create({
      post: req.params.postId,
      creator: req.user.id,
      content,
      parentComment: parentCommentId
    });

    await FeedPost.findByIdAndUpdate(req.params.postId, { $inc: { commentCount: 1 } });
    
    res.status(201).json(comment);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};
