import { Request, Response, NextFunction } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import User, { UserRole } from '../models/User';
import SignupOtp from '../models/SignupOtp';
import PasswordResetToken from '../models/PasswordResetToken';
import crypto from 'crypto';
import { sendOtpEmail } from '../services/emailService';

const JWT_EXPIRES_IN = '7d';

const generateToken = (id: string, role: string) => {
  const secret = process.env.JWT_SECRET || 'fallback_secret';
  return jwt.sign({ id, role }, secret, { expiresIn: JWT_EXPIRES_IN });
};

// @route   POST /api/v1/auth/register
export const registerPre = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { email, password, name } = req.body;
    
    const userExists = await User.findOne({ email });
    if (userExists) {
      res.status(400).json({ message: 'User already exists' });
      return;
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);
    
    // Generate a random 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expiryDate = new Date(Date.now() + 15 * 60 * 1000); // 15 mins

    // Upsert the OTP in case they ask to resend
    await SignupOtp.findOneAndUpdate(
      { email }, 
      { name, passwordHash, otp, expiryDate, used: false }, 
      { upsert: true, new: true }
    );

    // Send email via Brevo / SMTP
    const emailSent = await sendOtpEmail(email, otp, name);
    
    if (emailSent) {
      res.status(200).json({ message: 'OTP sent successfully to your email.' });
    } else {
      res.status(500).json({ message: 'Failed to send OTP email. Please ensure your SMTP credentials are valid.' });
    }
  } catch (error) {
    next(error);
  }
};

// @route   POST /api/v1/auth/register/verify
export const verifySignupOtp = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { email, otp } = req.body;
    
    const signupOtp = await SignupOtp.findOne({ email, otp, used: false });
    if (!signupOtp || signupOtp.expiryDate < new Date()) {
      res.status(400).json({ message: 'Invalid or expired OTP' });
      return;
    }

    signupOtp.used = true;
    await signupOtp.save();

    const user = await User.create({
      email: signupOtp.email,
      name: signupOtp.name,
      passwordHash: signupOtp.passwordHash,
      role: UserRole.USER
    });

    const token = generateToken(user._id.toString(), user.role);

    res.status(200).json({
      accessToken: token,
      user: {
        id: user._id,
        email: user.email,
        name: user.name,
        role: user.role
      }
    });
  } catch (error) {
    next(error);
  }
};

// @route   POST /api/v1/auth/login
export const login = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { email, password } = req.body;
    
    const user = await User.findOne({ email, deletedAt: null });
    if (!user) {
      res.status(401).json({ message: 'No account found with this email address.' });
      return;
    }

    if (!user.passwordHash) {
      res.status(401).json({ message: 'Please reset your password or sign in using a different method.' });
      return;
    }

    const isMatch = await bcrypt.compare(password, user.passwordHash);
    if (!isMatch) {
      res.status(401).json({ message: 'Incorrect password. Please try again.' });
      return;
    }

    const token = generateToken(user._id.toString(), user.role);

    res.status(200).json({
      accessToken: token,
      user: {
        id: user._id,
        email: user.email,
        name: user.name,
        role: user.role
      }
    });
  } catch (error) {
    next(error);
  }
};

// @route   POST /api/v1/auth/forgot-password
export const forgotPassword = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { email } = req.body;
    
    const user = await User.findOne({ email });
    if (!user) {
      // Explicitly tell the user the account doesn't exist
      res.status(404).json({ message: 'No account found with this email address.' });
      return;
    }

    // Generate a random 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expiryDate = new Date(Date.now() + 15 * 60 * 1000);

    await PasswordResetToken.create({
      user: user._id,
      token: otp,
      expiryDate
    });

    // Send email via Brevo / SMTP
    const emailSent = await sendOtpEmail(email, otp, user.name);

    if (emailSent) {
      res.status(200).json({ message: 'Password reset code has been sent to your email.' });
    } else {
      res.status(500).json({ message: 'Failed to send password reset email. Please try again later.' });
    }
  } catch (error) {
    next(error);
  }
};

// @route   POST /api/v1/auth/reset-password
export const resetPassword = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { email, otp, newPassword } = req.body;
    
    const user = await User.findOne({ email });
    if (!user) {
      res.status(404).json({ message: 'No account found with this email address.' });
      return;
    }

    const resetToken = await PasswordResetToken.findOne({ user: user._id, token: otp, used: false });
    
    if (!resetToken || resetToken.expiryDate < new Date()) {
      res.status(400).json({ message: 'Invalid or expired verification code.' });
      return;
    }

    const salt = await bcrypt.genSalt(10);
    user.passwordHash = await bcrypt.hash(newPassword, salt);
    await user.save();

    resetToken.used = true;
    await resetToken.save();

    res.status(200).json({ message: 'Password successfully reset! You can now log in.' });
  } catch (error) {
    next(error);
  }
};
