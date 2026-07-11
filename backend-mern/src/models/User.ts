import mongoose, { Schema, Document } from 'mongoose';

export enum UserRole {
  USER = 'USER',
  ADMIN = 'ADMIN',
  SUPER_ADMIN = 'SUPER_ADMIN'
}

export interface IUser extends Document {
  email: string;
  name: string;
  passwordHash?: string;
  role: UserRole;
  oauthProvider?: string;
  
  phoneNumber?: string;
  organizationType?: string;
  bio?: string;
  website?: string;
  city?: string;
  profilePictureBase64?: string;
  coverPictureBase64?: string;
  
  workspaceQuota: number;
  mfaEnabled: boolean;
  mfaSecret?: string;
  
  followerCount: number;
  followingCount: number;
  
  deletedAt?: Date;
  deletedBy?: mongoose.Types.ObjectId;
  
  createdAt: Date;
  updatedAt: Date;
}

const UserSchema: Schema = new Schema({
  email: { type: String, required: true, unique: true },
  name: { type: String, required: true },
  passwordHash: { type: String },
  role: { type: String, enum: Object.values(UserRole), default: UserRole.USER },
  oauthProvider: { type: String },
  
  phoneNumber: { type: String },
  organizationType: { type: String },
  bio: { type: String, maxlength: 500 },
  website: { type: String },
  city: { type: String },
  profilePictureBase64: { type: String },
  coverPictureBase64: { type: String },
  
  workspaceQuota: { type: Number, default: 5 },
  mfaEnabled: { type: Boolean, default: false },
  mfaSecret: { type: String },
  
  followerCount: { type: Number, default: 0 },
  followingCount: { type: Number, default: 0 },
  
  deletedAt: { type: Date },
  deletedBy: { type: Schema.Types.ObjectId, ref: 'User' },
}, {
  timestamps: true // Automatically manages createdAt and updatedAt
});

export default mongoose.model<IUser>('User', UserSchema);
