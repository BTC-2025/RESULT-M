import { Request, Response } from 'express';
import FeedPost from '../models/FeedPost';
import Complaint from '../models/Complaint';

export const getFeed = async (req: Request, res: Response): Promise<void> => {
  try {
    const size = parseInt(req.query.size as string) || 20;
    
    // In a real app we'd handle cursor pagination.
    // For now we'll just fetch the latest Posts and Complaints and merge them.
    
    const posts = await FeedPost.find({ deletedAt: null })
      .sort({ createdAt: -1 })
      .limit(size)
      .populate('creator', 'name email profilePictureBase64');
      
    const complaints = await Complaint.find()
      .sort({ createdAt: -1 })
      .limit(size)
      .populate('creator', 'name email profilePictureBase64');

    // Combine and sort by createdAt descending
    const allItems = [...posts, ...complaints].sort((a: any, b: any) => 
      b.createdAt.getTime() - a.createdAt.getTime()
    ).slice(0, size);

    // Map to FeedItem format expected by frontend
    const items = allItems.map((item: any) => {
      // Determine if it's a Complaint or a Post
      const isComplaint = item.category !== undefined && item.title !== undefined;
      
      return {
        id: item._id,
        type: isComplaint ? 'COMPLAINT' : item.postType,
        authorName: item.creator?.name,
        authorHandle: item.creator?.email,
        isAuthorVerified: false,
        createdAt: item.createdAt,
        isBookmarked: false,
        isLiked: false,
        likeCount: isComplaint ? item.upvotes : item.likeCount,
        commentCount: item.commentCount || 0,
        payload: {
          title: item.title,
          description: item.description,
          text: item.text,
          mediaUrls: item.mediaUrls,
          locationName: item.locationName,
          upvotes: item.upvotes
        }
      };
    });

    res.status(200).json({
      items,
      nextCursor: null,
      hasMore: false,
      liveStories: []
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error fetching feed' });
  }
};

export const getSavedItems = async (req: Request, res: Response): Promise<void> => {
  try {
    res.status(200).json([]);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

export const getUserFeed = async (req: Request, res: Response): Promise<void> => {
  try {
    res.status(200).json({ items: [], nextCursor: null, hasMore: false });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};
