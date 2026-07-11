import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import User from '../models/User';

export interface AuthRequest extends Request {
  user?: any;
}

export const requireAuth = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    let token;
    
    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
      token = req.headers.authorization.split(' ')[1];
    }

    if (!token) {
      res.status(401).json({ message: 'Not authorized, no token provided' });
      return;
    }

    const decoded: any = jwt.verify(token, process.env.JWT_SECRET || 'fallback_secret');
    
    // Check if user still exists
    const currentUser = await User.findById(decoded.id).select('-passwordHash');
    if (!currentUser) {
      res.status(401).json({ message: 'The user belonging to this token no longer exists.' });
      return;
    }

    // Attach user to request
    req.user = currentUser;
    next();
  } catch (error: any) {
    console.error("JWT Verification Error:", error.message);
    res.status(401).json({ message: 'Not authorized, token failed or expired' });
    return;
  }
};
