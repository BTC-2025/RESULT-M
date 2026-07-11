import { Request, Response } from 'express';
import Workspace, { VisibilityMode } from '../models/Workspace';
import WorkspaceMember, { WorkspaceRole } from '../models/WorkspaceMember';
import { AuthRequest } from '../middleware/auth';
import crypto from 'crypto';

// @route   POST /api/v1/workspaces
export const createWorkspace = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { name, slug, description, category, visibility } = req.body;
    
    // Check if slug exists
    const existing = await Workspace.findOne({ slug });
    if (existing) {
      res.status(400).json({ message: 'Workspace slug already exists' });
      return;
    }

    const accessCode = visibility === VisibilityMode.RESTRICTED ? crypto.randomBytes(4).toString('hex') : undefined;

    const workspace = await Workspace.create({
      name,
      slug,
      description,
      category,
      visibility,
      accessCode,
      owner: req.user.id
    });

    // Make creator the owner in members table
    await WorkspaceMember.create({
      workspace: workspace._id,
      user: req.user.id,
      role: WorkspaceRole.OWNER
    });

    res.status(201).json(workspace);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   GET /api/v1/workspaces/:id
export const getWorkspace = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const workspace = await Workspace.findById(req.params.id);
    if (!workspace) {
      res.status(404).json({ message: 'Workspace not found' });
      return;
    }
    res.status(200).json(workspace);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   GET /api/v1/workspaces/slug/:slug
export const getWorkspaceBySlug = async (req: Request, res: Response): Promise<void> => {
  try {
    const workspace = await Workspace.findOne({ slug: req.params.slug });
    if (!workspace) {
      res.status(404).json({ message: 'Workspace not found' });
      return;
    }
    res.status(200).json(workspace);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   GET /api/v1/workspaces/my
export const getMyWorkspaces = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const memberships = await WorkspaceMember.find({ user: req.user.id }).populate('workspace');
    const workspaces = memberships.map(m => m.workspace);
    res.status(200).json({
      content: workspaces,
      totalElements: workspaces.length,
      totalPages: 1
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   GET /api/v1/workspaces/public
export const getPublicWorkspaces = async (req: Request, res: Response): Promise<void> => {
  try {
    const workspaces = await Workspace.find({ visibility: VisibilityMode.PUBLIC });
    res.status(200).json({
      content: workspaces,
      totalElements: workspaces.length,
      totalPages: 1
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   PUT /api/v1/workspaces/:id
export const updateWorkspace = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const workspace = await Workspace.findOneAndUpdate(
      { _id: req.params.id, owner: req.user.id },
      req.body,
      { new: true }
    );
    
    if (!workspace) {
      res.status(404).json({ message: 'Workspace not found or unauthorized' });
      return;
    }
    res.status(200).json(workspace);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @route   DELETE /api/v1/workspaces/:id
export const deleteWorkspace = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const workspace = await Workspace.findOneAndDelete({ _id: req.params.id, owner: req.user.id });
    if (!workspace) {
      res.status(404).json({ message: 'Workspace not found or unauthorized' });
      return;
    }
    // Also delete members
    await WorkspaceMember.deleteMany({ workspace: req.params.id });
    res.status(204).send();
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};
