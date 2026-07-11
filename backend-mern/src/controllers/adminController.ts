import { Request, Response } from 'express';
import User from '../models/User';
import Workspace from '../models/Workspace';
import FeedPost from '../models/FeedPost';
import Complaint from '../models/Complaint';
import bcrypt from 'bcryptjs';

// @route   GET /api/v1/admin/stats
export const getPlatformStats = async (req: Request, res: Response): Promise<void> => {
  try {
    const userCount = await User.countDocuments({ deletedAt: null });
    const workspaceCount = await Workspace.countDocuments({ deletedAt: null });
    const postCount = await FeedPost.countDocuments({ deletedAt: null });
    const complaintCount = await Complaint.countDocuments();

    res.status(200).json({
      totalUsers: userCount,
      totalWorkspaces: workspaceCount,
      totalPosts: postCount,
      totalComplaints: complaintCount
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   GET /api/v1/admin/system/health
export const getSystemHealth = async (req: Request, res: Response): Promise<void> => {
  res.status(200).json({ status: 'UP', database: 'UP', version: '1.0.0-MERN' });
};

// @route   GET /api/v1/admin/users
export const searchUsers = async (req: Request, res: Response): Promise<void> => {
  try {
    const users = await User.find().select('-passwordHash');
    res.status(200).json({
      content: users,
      totalElements: users.length,
      totalPages: 1
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   GET /api/v1/admin/users/:userId
export const getUser = async (req: Request, res: Response): Promise<void> => {
  try {
    const user = await User.findById(req.params.userId).select('-passwordHash');
    if (!user) {
      res.status(404).json({ message: 'User not found' });
      return;
    }
    res.status(200).json(user);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   PUT /api/v1/admin/users/:userId/suspend
export const suspendUser = async (req: Request, res: Response): Promise<void> => {
  try {
    const suspend = req.query.suspend === 'true';
    const user = await User.findByIdAndUpdate(
      req.params.userId,
      { isLocked: suspend },
      { new: true }
    ).select('-passwordHash');
    res.status(200).json(user);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   PUT /api/v1/admin/users/:userId/quota
export const updateUserQuota = async (req: Request, res: Response): Promise<void> => {
  try {
    const { workspaceQuota } = req.body;
    const user = await User.findByIdAndUpdate(
      req.params.userId,
      { workspaceQuota },
      { new: true }
    ).select('-passwordHash');
    res.status(200).json(user);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   PUT /api/v1/admin/users/:userId/role
export const changeUserRole = async (req: Request, res: Response): Promise<void> => {
  try {
    const { role } = req.body;
    const user = await User.findByIdAndUpdate(
      req.params.userId,
      { role },
      { new: true }
    ).select('-passwordHash');
    res.status(200).json(user);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   POST /api/v1/admin/users/:userId/reset-password
export const resetUserPassword = async (req: Request, res: Response): Promise<void> => {
  try {
    const { newPassword } = req.body;
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(newPassword, salt);
    
    await User.findByIdAndUpdate(req.params.userId, { passwordHash });
    res.status(200).json({ message: 'Password reset successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   DELETE /api/v1/admin/users/:userId
export const deleteUser = async (req: Request, res: Response): Promise<void> => {
  try {
    await User.findByIdAndUpdate(req.params.userId, { deletedAt: new Date() });
    res.status(200).json({ message: 'User deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   GET /api/v1/admin/workspaces
export const getAllWorkspaces = async (req: Request, res: Response): Promise<void> => {
  try {
    const workspaces = await Workspace.find();
    res.status(200).json({
      content: workspaces,
      totalElements: workspaces.length,
      totalPages: 1
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   DELETE /api/v1/admin/workspaces/:workspaceId
export const deleteWorkspace = async (req: Request, res: Response): Promise<void> => {
  try {
    await Workspace.findByIdAndDelete(req.params.workspaceId);
    res.status(200).json({ message: 'Workspace deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   GET /api/v1/admin/posts
export const getAllPosts = async (req: Request, res: Response): Promise<void> => {
  try {
    const posts = await FeedPost.find().populate('creator', 'name email');
    res.status(200).json({
      content: posts,
      totalElements: posts.length,
      totalPages: 1
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   DELETE /api/v1/admin/posts/:postId
export const deletePost = async (req: Request, res: Response): Promise<void> => {
  try {
    await FeedPost.findByIdAndDelete(req.params.postId);
    res.status(200).json({ message: 'Post deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};
