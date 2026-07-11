import { Request, Response } from 'express';
import User from '../models/User';
import Workspace, { VisibilityMode } from '../models/Workspace';
import FeedPost from '../models/FeedPost';
import Complaint, { ComplaintStatus } from '../models/Complaint';

// @route   GET /api/v1/search
export const globalSearch = async (req: Request, res: Response): Promise<void> => {
  try {
    const q = req.query.q as string || '';
    const workspaceId = req.query.workspaceId as string;
    
    // In Mongoose, we use $regex for text search similar to PostgreSQL LIKE %q%
    const searchRegex = new RegExp(q, 'i');

    const results = {
      users: [] as any[],
      workspaces: [] as any[],
      posts: [] as any[],
      complaints: [] as any[]
    };

    if (!workspaceId) {
      // Global search
      results.users = await User.find({ 
        $or: [{ name: searchRegex }, { email: searchRegex }],
        deletedAt: null
      }).limit(10).select('name email profilePictureBase64 role');

      results.workspaces = await Workspace.find({ 
        $or: [{ name: searchRegex }, { description: searchRegex }],
        visibility: VisibilityMode.PUBLIC,
        deletedAt: null
      }).limit(10);
    }

    // Search posts
    const postQuery: any = { text: searchRegex, deletedAt: null };
    if (workspaceId) postQuery.workspace = workspaceId;
    
    results.posts = await FeedPost.find(postQuery)
      .populate('creator', 'name email profilePictureBase64')
      .limit(10);

    // Search complaints
    const complaintQuery: any = { 
      $or: [{ title: searchRegex }, { description: searchRegex }] 
    };
    if (workspaceId) complaintQuery.workspace = workspaceId;

    results.complaints = await Complaint.find(complaintQuery)
      .populate('creator', 'name email profilePictureBase64')
      .limit(10);

    res.status(200).json({
      content: [results], // Wrap in array to match paginated structure if needed
      totalElements: results.users.length + results.workspaces.length + results.posts.length + results.complaints.length,
      totalPages: 1
    });

  } catch (error) {
    res.status(500).json({ message: 'Server error during search' });
  }
};
