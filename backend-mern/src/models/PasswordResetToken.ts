import mongoose, { Schema, Document } from 'mongoose';

export interface IPasswordResetToken extends Document {
  user: mongoose.Types.ObjectId;
  token: string;
  expiryDate: Date;
  used: boolean;
}

const PasswordResetTokenSchema: Schema = new Schema({
  user: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  token: { type: String, required: true },
  expiryDate: { type: Date, required: true },
  used: { type: Boolean, default: false }
});

export default mongoose.model<IPasswordResetToken>('PasswordResetToken', PasswordResetTokenSchema);
