import mongoose, { Schema, Document } from 'mongoose';

export interface IUserFollow extends Document {
  follower: mongoose.Types.ObjectId;
  following: mongoose.Types.ObjectId;
  createdAt: Date;
}

const UserFollowSchema: Schema = new Schema({
  follower: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  following: { type: Schema.Types.ObjectId, ref: 'User', required: true },
}, {
  timestamps: true
});

UserFollowSchema.index({ follower: 1, following: 1 }, { unique: true });

export default mongoose.model<IUserFollow>('UserFollow', UserFollowSchema);
