import { Request, Response } from 'express';
import Complaint from '../models/Complaint';
import { AuthRequest } from '../middleware/auth';

// @route   GET /api/v1/complaints
export const getComplaints = async (req: Request, res: Response): Promise<void> => {
  try {
    const complaints = await Complaint.find().populate('creator', 'name email').sort({ createdAt: -1 });
    res.status(200).json({
      content: complaints,
      totalElements: complaints.length,
      totalPages: 1
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   GET /api/v1/complaints/workspaces/:workspaceId
export const getWorkspaceComplaints = async (req: Request, res: Response): Promise<void> => {
  try {
    const complaints = await Complaint.find({ workspace: req.params.workspaceId })
      .populate('creator', 'name email')
      .sort({ createdAt: -1 });
      
    res.status(200).json({
      content: complaints,
      totalElements: complaints.length,
      totalPages: 1
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   POST /api/v1/complaints
export const createComplaint = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    let data = req.body;
    if (req.body.data) {
      try {
        data = typeof req.body.data === 'string' ? JSON.parse(req.body.data) : req.body.data;
      } catch (e) {
        data = req.body;
      }
    }
    
    const { category, title, description, workspaceId, mediaUrls, latitude, longitude, locationName, isAnonymous } = data;
    
    const fileUrls: string[] = [];
    if (req.files && Array.isArray(req.files)) {
      req.files.forEach(file => {
        fileUrls.push(`/uploads/${file.filename}`);
      });
    }
    
    const complaintPayload: any = {
      creator: req.user.id,
      category,
      title,
      description,
      mediaUrls: mediaUrls || fileUrls,
      latitude,
      longitude,
      locationName,
      anonymous: isAnonymous
    };

    if (workspaceId) {
      complaintPayload.workspace = workspaceId;
    }

    const complaint = await Complaint.create(complaintPayload);

    res.status(201).json(complaint);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   PATCH /api/v1/complaints/:id/status
export const updateStatus = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const complaint = await Complaint.findByIdAndUpdate(
      req.params.id,
      { status: req.body.status },
      { new: true }
    );
    
    if (!complaint) {
      res.status(404).json({ message: 'Complaint not found' });
      return;
    }
    res.status(200).json(complaint);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// Note: In a full production app we would implement the Comment, Upvote, and Bookmark tables
// similarly to FeedPost. Since they follow the exact same pattern, they are mocked here.
// @route   POST /api/v1/complaints/:id/upvote
export const upvoteComplaint = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    await Complaint.findByIdAndUpdate(req.params.id, { $inc: { upvotes: 1 } });
    res.status(200).json({ message: 'Upvoted' });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   DELETE /api/v1/complaints/:id/upvote
export const removeUpvote = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    await Complaint.findByIdAndUpdate(req.params.id, { $inc: { upvotes: -1 } });
    res.status(200).json({ message: 'Upvote removed' });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};
