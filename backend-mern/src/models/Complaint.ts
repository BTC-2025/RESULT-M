import mongoose, { Schema, Document } from 'mongoose';

export enum ComplaintStatus {
  OPEN = 'OPEN',
  IN_PROGRESS = 'IN_PROGRESS',
  RESOLVED = 'RESOLVED',
  CLOSED = 'CLOSED'
}

export enum ComplaintPriority {
  LOW = 'LOW',
  MEDIUM = 'MEDIUM',
  HIGH = 'HIGH',
  CRITICAL = 'CRITICAL'
}

export interface IComplaint extends Document {
  creator?: mongoose.Types.ObjectId;
  workspace?: mongoose.Types.ObjectId;
  category: string;
  title: string;
  description: string;
  mediaUrls: string[];
  latitude?: number;
  longitude?: number;
  locationName?: string;
  status: ComplaintStatus;
  priority: ComplaintPriority;
  assignee?: mongoose.Types.ObjectId;
  anonymous: boolean;
  flagCount: number;
  upvotes: number;
  downvotes: number;
  netScore: number;
  createdAt: Date;
  updatedAt: Date;
}

const ComplaintSchema: Schema = new Schema({
  creator: { type: Schema.Types.ObjectId, ref: 'User' },
  workspace: { type: Schema.Types.ObjectId, ref: 'Workspace' },
  category: { type: String, required: true, maxlength: 100 },
  title: { type: String, required: true, maxlength: 255 },
  description: { type: String, required: true },
  mediaUrls: [{ type: String }],
  latitude: { type: Number },
  longitude: { type: Number },
  locationName: { type: String },
  status: { type: String, enum: Object.values(ComplaintStatus), default: ComplaintStatus.OPEN },
  priority: { type: String, enum: Object.values(ComplaintPriority), default: ComplaintPriority.MEDIUM },
  assignee: { type: Schema.Types.ObjectId, ref: 'User' },
  anonymous: { type: Boolean, default: false },
  flagCount: { type: Number, default: 0 },
  upvotes: { type: Number, default: 0 },
  downvotes: { type: Number, default: 0 },
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for netScore
ComplaintSchema.virtual('netScore').get(function() {
  return this.upvotes - this.downvotes;
});

export default mongoose.model<IComplaint>('Complaint', ComplaintSchema);
