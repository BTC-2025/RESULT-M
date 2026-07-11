import mongoose, { Schema, Document } from 'mongoose';

export enum FeedPostType {
  UPDATE = 'UPDATE',
  IMAGE = 'IMAGE',
  VIDEO = 'VIDEO'
}

export interface IFeedPost extends Document {
  creator: mongoose.Types.ObjectId;
  workspace?: mongoose.Types.ObjectId;
  postType: FeedPostType;
  text?: string;
  category?: string;
  locationName?: string;
  mediaUrls: string[];
  likeCount: number;
  commentCount: number;
  createdAt: Date;
  updatedAt: Date;
  deletedAt?: Date;
}

const FeedPostSchema: Schema = new Schema({
  creator: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  workspace: { type: Schema.Types.ObjectId, ref: 'Workspace' },
  postType: { type: String, enum: Object.values(FeedPostType), default: FeedPostType.UPDATE },
  text: { type: String },
  category: { type: String, maxlength: 100 },
  locationName: { type: String, maxlength: 255 },
  mediaUrls: [{ type: String }],
  likeCount: { type: Number, default: 0 },
  commentCount: { type: Number, default: 0 },
  deletedAt: { type: Date },
}, {
  timestamps: true
});

export default mongoose.model<IFeedPost>('FeedPost', FeedPostSchema);
