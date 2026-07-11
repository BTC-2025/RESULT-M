import mongoose, { Schema, Document } from 'mongoose';

export enum WorkspaceRole {
  OWNER = 'OWNER',
  ADMIN = 'ADMIN',
  MEMBER = 'MEMBER',
  VIEWER = 'VIEWER'
}

export interface IWorkspaceMember extends Document {
  workspace: mongoose.Types.ObjectId;
  user: mongoose.Types.ObjectId;
  role: WorkspaceRole;
  joinedAt: Date;
}

const WorkspaceMemberSchema: Schema = new Schema({
  workspace: { type: Schema.Types.ObjectId, ref: 'Workspace', required: true },
  user: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  role: { type: String, enum: Object.values(WorkspaceRole), required: true },
  joinedAt: { type: Date, default: Date.now },
});

// Ensure a user can only be a member of a specific workspace once
WorkspaceMemberSchema.index({ workspace: 1, user: 1 }, { unique: true });

export default mongoose.model<IWorkspaceMember>('WorkspaceMember', WorkspaceMemberSchema);
