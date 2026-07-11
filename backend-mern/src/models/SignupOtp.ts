import mongoose, { Schema, Document } from 'mongoose';

export interface ISignupOtp extends Document {
  email: string;
  name?: string;
  passwordHash: string;
  phoneNumber?: string;
  otp: string;
  expiryDate: Date;
  used: boolean;
}

const SignupOtpSchema: Schema = new Schema({
  email: { type: String, required: true },
  name: { type: String },
  passwordHash: { type: String, required: true },
  phoneNumber: { type: String },
  otp: { type: String, required: true },
  expiryDate: { type: Date, required: true },
  used: { type: Boolean, default: false }
});

export default mongoose.model<ISignupOtp>('SignupOtp', SignupOtpSchema);
