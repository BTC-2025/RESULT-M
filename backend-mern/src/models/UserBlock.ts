import mongoose, { Schema, Document } from 'mongoose';

export interface IUserBlock extends Document {
  blocker: mongoose.Types.ObjectId;
  blocked: mongoose.Types.ObjectId;
  createdAt: Date;
}

const UserBlockSchema: Schema = new Schema({
  blocker: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  blocked: { type: Schema.Types.ObjectId, ref: 'User', required: true },
}, {
  timestamps: true
});

UserBlockSchema.index({ blocker: 1, blocked: 1 }, { unique: true });

export default mongoose.model<IUserBlock>('UserBlock', UserBlockSchema);
