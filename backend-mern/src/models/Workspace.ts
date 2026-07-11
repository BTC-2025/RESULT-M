import mongoose, { Schema, Document } from 'mongoose';

export enum VisibilityMode {
  PUBLIC = 'PUBLIC',
  PRIVATE = 'PRIVATE',
  RESTRICTED = 'RESTRICTED'
}

export interface IWorkspace extends Document {
  name: string;
  slug: string;
  description?: string;
  category: string;
  visibility: VisibilityMode;
  accessCode?: string;
  owner: mongoose.Types.ObjectId;
  createdAt: Date;
  updatedAt: Date;
  deletedAt?: Date;
  deletedBy?: mongoose.Types.ObjectId;
}

const WorkspaceSchema: Schema = new Schema({
  name: { type: String, required: true },
  slug: { type: String, required: true, unique: true },
  description: { type: String },
  category: { type: String, default: 'Academic', maxlength: 100 },
  visibility: { type: String, enum: Object.values(VisibilityMode), default: VisibilityMode.PUBLIC },
  accessCode: { type: String },
  owner: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  deletedAt: { type: Date },
  deletedBy: { type: Schema.Types.ObjectId, ref: 'User' },
}, {
  timestamps: true
});

export default mongoose.model<IWorkspace>('Workspace', WorkspaceSchema);
