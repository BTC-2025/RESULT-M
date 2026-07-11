import mongoose, { Schema, Document } from 'mongoose';

export interface IFeedPostComment extends Document {
  post: mongoose.Types.ObjectId;
  creator: mongoose.Types.ObjectId;
  parentComment?: mongoose.Types.ObjectId;
  content: string;
  likeCount: number;
  createdAt: Date;
  updatedAt: Date;
  deletedAt?: Date;
}

const FeedPostCommentSchema: Schema = new Schema({
  post: { type: Schema.Types.ObjectId, ref: 'FeedPost', required: true },
  creator: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  parentComment: { type: Schema.Types.ObjectId, ref: 'FeedPostComment' },
  content: { type: String, required: true },
  likeCount: { type: Number, default: 0 },
  deletedAt: { type: Date }
}, {
  timestamps: true
});

export default mongoose.model<IFeedPostComment>('FeedPostComment', FeedPostCommentSchema);
