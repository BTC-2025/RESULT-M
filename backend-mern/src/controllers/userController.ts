import { Request, Response } from 'express';
import User from '../models/User';
import UserFollow from '../models/UserFollow';
import UserBlock from '../models/UserBlock';
import { AuthRequest } from '../middleware/auth';
import bcrypt from 'bcryptjs';

// @route   GET /api/v1/users/me
export const getMyProfile = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const user = await User.findById(req.user.id).select('-passwordHash');
    if (!user) {
      res.status(404).json({ message: 'User not found' });
      return;
    }
    res.status(200).json(user);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   PUT /api/v1/users/me
export const updateMyProfile = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { name, phoneNumber, organizationType, bio, website, city, profilePictureBase64, coverPictureBase64 } = req.body;
    
    const user = await User.findById(req.user.id);
    if (!user) {
      res.status(404).json({ message: 'User not found' });
      return;
    }

    if (name) user.name = name;
    if (phoneNumber !== undefined) user.phoneNumber = phoneNumber;
    if (organizationType !== undefined) user.organizationType = organizationType;
    if (bio !== undefined) user.bio = bio;
    if (website !== undefined) user.website = website;
    if (city !== undefined) user.city = city;
    if (profilePictureBase64 !== undefined) user.profilePictureBase64 = profilePictureBase64;
    if (coverPictureBase64 !== undefined) user.coverPictureBase64 = coverPictureBase64;

    await user.save();
    
    res.status(200).json(user);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   DELETE /api/v1/users/me
export const deleteMyAccount = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { password } = req.body;
    
    const user = await User.findById(req.user.id);
    if (!user || !user.passwordHash) {
      res.status(404).json({ message: 'User not found' });
      return;
    }

    const isMatch = await bcrypt.compare(password, user.passwordHash);
    if (!isMatch) {
      res.status(401).json({ message: 'Invalid password' });
      return;
    }

    user.deletedAt = new Date();
    user.deletedBy = user._id as any;
    await user.save();

    res.status(200).json({ message: 'Account deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   GET /api/v1/users/:userId/profile
export const getPublicProfile = async (req: Request, res: Response): Promise<void> => {
  try {
    const { userId } = req.params;
    const user = await User.findOne({ _id: userId, deletedAt: null }).select('-passwordHash -mfaSecret');
    
    if (!user) {
      res.status(404).json({ message: 'User not found' });
      return;
    }

    res.status(200).json(user);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   POST /api/v1/users/:userId/follow
export const followUser = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const followerId = req.user.id;
    const followingId = req.params.userId;
    
    if (followerId === followingId) {
      res.status(400).json({ message: 'Cannot follow yourself' });
      return;
    }

    const followExists = await UserFollow.findOne({ follower: followerId, following: followingId });
    if (!followExists) {
      await UserFollow.create({ follower: followerId, following: followingId });
      await User.findByIdAndUpdate(followerId, { $inc: { followingCount: 1 } });
      await User.findByIdAndUpdate(followingId, { $inc: { followerCount: 1 } });
    }
    
    res.status(200).json({ message: 'User followed successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   DELETE /api/v1/users/:userId/follow
export const unfollowUser = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const followerId = req.user.id;
    const followingId = req.params.userId;
    
    const followExists = await UserFollow.findOneAndDelete({ follower: followerId, following: followingId });
    if (followExists) {
      await User.findByIdAndUpdate(followerId, { $inc: { followingCount: -1 } });
      await User.findByIdAndUpdate(followingId, { $inc: { followerCount: -1 } });
    }
    
    res.status(200).json({ message: 'User unfollowed successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   POST /api/v1/users/:userId/block
export const blockUser = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const blockerId = req.user.id;
    const blockedId = req.params.userId;
    
    await UserBlock.findOneAndUpdate(
      { blocker: blockerId, blocked: blockedId },
      { blocker: blockerId, blocked: blockedId },
      { upsert: true, new: true }
    );
    
    res.status(200).json({ message: 'User blocked successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};
