import mongoose, { Schema, Document } from 'mongoose';

export interface IFeedPostLike extends Document {
  post: mongoose.Types.ObjectId;
  user: mongoose.Types.ObjectId;
  createdAt: Date;
}

const FeedPostLikeSchema: Schema = new Schema({
  post: { type: Schema.Types.ObjectId, ref: 'FeedPost', required: true },
  user: { type: Schema.Types.ObjectId, ref: 'User', required: true },
}, {
  timestamps: true
});

FeedPostLikeSchema.index({ post: 1, user: 1 }, { unique: true });

export default mongoose.model<IFeedPostLike>('FeedPostLike', FeedPostLikeSchema);
