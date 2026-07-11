import mongoose, { Schema, Document } from 'mongoose';

export interface IFeedPostBookmark extends Document {
  post: mongoose.Types.ObjectId;
  user: mongoose.Types.ObjectId;
  createdAt: Date;
}

const FeedPostBookmarkSchema: Schema = new Schema({
  post: { type: Schema.Types.ObjectId, ref: 'FeedPost', required: true },
  user: { type: Schema.Types.ObjectId, ref: 'User', required: true },
}, {
  timestamps: true
});

FeedPostBookmarkSchema.index({ post: 1, user: 1 }, { unique: true });

export default mongoose.model<IFeedPostBookmark>('FeedPostBookmark', FeedPostBookmarkSchema);
