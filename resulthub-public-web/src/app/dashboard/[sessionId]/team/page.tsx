"use client";

import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Users, 
  ShieldCheck, 
  UserPlus, 
  Search, 
  Filter, 
  MoreVertical, 
  Key, 
  Database, 
  Eye, 
  Activity, 
  ShieldAlert, 
  X, 
  CheckCircle2, 
  Clock, 
  Mail, 
  ChevronDown, 
  Check, 
  Briefcase
} from 'lucide-react';

import { useWorkspace } from '../WorkspaceContext';
import { api } from '@/lib/api';

const MOCK_TEAM_MEMBERS = [
  { id: 1, name: 'Alice Johnson', email: 'alice@resulthub.com', role: 'Owner', workspaces: ['All Workspaces'], status: 'Active', lastActive: '2 mins ago', avatar: 'https://api.dicebear.com/7.x/notionists/svg?seed=Alice' },
];

const AUDIT_LOGS = [
  { id: 1, action: 'User Invited', details: 'Bob Smith invited dana@resulthub.com as Editor', time: '2 hours ago', icon: Mail, color: 'text-blue-400', bg: 'bg-blue-400/10' },
  { id: 2, action: 'Role Changed', details: 'Alice Johnson changed Bob Smith to Admin', time: '1 day ago', icon: ShieldCheck, color: 'text-purple-400', bg: 'bg-purple-400/10' },
  { id: 3, action: 'Access Revoked', details: 'Alice Johnson removed Evan Wright from Finance', time: '3 days ago', icon: ShieldAlert, color: 'text-red-400', bg: 'bg-red-400/10' },
  { id: 4, action: 'Login from New IP', details: 'Charlie Davis logged in from 192.168.1.55', time: '4 days ago', icon: Activity, color: 'text-emerald-400', bg: 'bg-emerald-400/10' },
];

const ROLES_MATRIX = [
  { role: 'Owner', desc: 'Full administrative control, billing, and ownership.', canInvite: true, canEditSchema: true, canPublish: true, canView: true },
  { role: 'Admin', desc: 'Can manage team members, datasets, and settings.', canInvite: true, canEditSchema: true, canPublish: true, canView: true },
  { role: 'Dataset Manager', desc: 'Can create and structure datasets, but cannot manage billing or invite Admins.', canInvite: false, canEditSchema: true, canPublish: true, canView: true },
  { role: 'Editor', desc: 'Can add or edit records in assigned datasets, cannot alter schemas.', canInvite: false, canEditSchema: false, canPublish: true, canView: true },
  { role: 'Viewer', desc: 'Read-only access to published records in assigned datasets.', canInvite: false, canEditSchema: false, canPublish: false, canView: true },
];

export default function TeamManagementPage() {
  const { activeWorkspace } = useWorkspace();
  const [members, setMembers] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  const [activeTab, setActiveTab] = useState<'members' | 'roles'>('members');
  const [isInviteOpen, setIsInviteOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  
  // Invite Form State
  const [inviteEmails, setInviteEmails] = useState('');
  const [inviteRole, setInviteRole] = useState('Editor');
  const [inviteWorkspaces, setInviteWorkspaces] = useState<string[]>(['Admissions']);
  
  // Quick Mock Workspaces for dropdown
  const availableWorkspaces = ['All Workspaces', 'Admissions', 'Academics', 'Finance', 'HR'];

  React.useEffect(() => {
    if (activeWorkspace?.id) {
      setIsLoading(true);
      api.workspaces.getMembers(activeWorkspace.id)
        .then(res => {
          const mappedMembers = (res || []).map((m: any) => ({
            id: m.id || Math.random(),
            name: m.user?.name || 'Unknown User',
            email: m.user?.email || 'No email',
            role: m.role || 'Member',
            workspaces: [activeWorkspace.name],
            status: m.user?.status || 'Active',
            lastActive: 'Recently',
            avatar: `https://api.dicebear.com/7.x/notionists/svg?seed=${m.user?.name || 'user'}`
          }));
          setMembers(mappedMembers.length > 0 ? mappedMembers : MOCK_TEAM_MEMBERS);
        })
        .catch(err => {
          console.error("Failed to fetch members:", err);
          setMembers(MOCK_TEAM_MEMBERS);
        })
        .finally(() => setIsLoading(false));
    }
  }, [activeWorkspace]);

  const filteredMembers = members.filter(m => 
    m.name.toLowerCase().includes(searchQuery.toLowerCase()) || 
    m.email.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const getRoleIcon = (role: string) => {
    switch (role) {
      case 'Owner': return <Key className="w-4 h-4 text-amber-400" />;
      case 'Admin': return <ShieldCheck className="w-4 h-4 text-purple-400" />;
      case 'Dataset Manager': return <Database className="w-4 h-4 text-blue-400" />;
      case 'Editor': return <Briefcase className="w-4 h-4 text-emerald-400" />;
      case 'Viewer': return <Eye className="w-4 h-4 text-zinc-500" />;
      default: return <Users className="w-4 h-4 text-zinc-500" />;
    }
  };

  const getStatusBadge = (status: string) => {
    switch(status) {
      case 'Active': return <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-emerald-500/10 text-emerald-400 border border-emerald-500/20"><CheckCircle2 className="w-3.5 h-3.5" /> {status}</span>;
      case 'Invited': return <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-amber-500/10 text-amber-400 border border-amber-500/20"><Clock className="w-3.5 h-3.5" /> {status}</span>;
      default: return <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-zinc-500/10 text-zinc-500 border border-zinc-500/20"><ShieldAlert className="w-3.5 h-3.5" /> {status}</span>;
    }
  }

  return (
    <div className="min-h-screen bg-transparent text-zinc-900 p-4 md:p-8 font-sans selection:bg-purple-500/30">
      <div className="max-w-[1600px] mx-auto space-y-8">
        
        {/* Header */}
        <div className="flex flex-col md:flex-row md:items-end justify-between gap-6 relative z-10">
          <div>
            <motion.div 
              initial={{ opacity: 0, y: -10 }}
              animate={{ opacity: 1, y: 0 }}
              className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-purple-500/10 border border-purple-500/20 text-purple-400 text-sm font-medium mb-4"
            >
              <ShieldCheck className="w-4 h-4" />
              RBAC Enabled
            </motion.div>
            <motion.h1 
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              className="text-4xl md:text-5xl font-extrabold tracking-tight bg-clip-text text-transparent bg-gradient-to-r from-zinc-900 via-zinc-700 to-zinc-500"
            >
              Team Management
            </motion.h1>
            <motion.p 
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.1 }}
              className="text-zinc-500 mt-2 text-lg max-w-2xl"
            >
              Govern your organization's workforce, roles, and access permissions across all workspaces.
            </motion.p>
          </div>

          <motion.div 
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            className="flex gap-3"
          >
            <button 
              onClick={() => setIsInviteOpen(true)}
              className="group relative inline-flex items-center justify-center gap-2 px-6 py-3 font-semibold text-zinc-900 bg-gradient-to-b from-purple-500 to-purple-600 rounded-xl overflow-hidden transition-all hover:scale-105 hover:shadow-[0_0_40px_-10px_rgba(168,85,247,0.5)] active:scale-95"
            >
              <div className="absolute inset-0 bg-white/20 translate-y-full group-hover:translate-y-0 transition-transform duration-300 ease-out" />
              <UserPlus className="w-5 h-5 relative z-10" />
              <span className="relative z-10">Invite Members</span>
            </button>
          </motion.div>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 md:gap-6">
          {[
            { label: 'Total Members', value: '24', icon: Users, color: 'text-blue-400', bg: 'bg-blue-400/10' },
            { label: 'Active Admins', value: '4', icon: ShieldCheck, color: 'text-purple-400', bg: 'bg-purple-400/10' },
            { label: 'Pending Invites', value: '3', icon: Mail, color: 'text-amber-400', bg: 'bg-amber-400/10' },
            { label: '2FA Enabled', value: '92%', icon: Key, color: 'text-emerald-400', bg: 'bg-emerald-400/10' },
          ].map((stat, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.1 }}
              className="p-6 rounded-2xl bg-white/50 border border-zinc-200 backdrop-blur-xl flex items-center gap-5 hover:bg-zinc-100/50 transition-colors"
            >
              <div className={`p-4 rounded-xl ${stat.bg} ${stat.color}`}>
                <stat.icon className="w-6 h-6" />
              </div>
              <div>
                <p className="text-zinc-500 text-sm font-medium">{stat.label}</p>
                <p className="text-2xl font-bold text-zinc-900 mt-1">{stat.value}</p>
              </div>
            </motion.div>
          ))}
        </div>

        {/* Main Content Area */}
        <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
          
          {/* Left/Center Column: Members & Roles */}
          <div className="lg:col-span-3 space-y-6">
            
            {/* Tabs */}
            <div className="flex border-b border-zinc-200">
              <button
                onClick={() => setActiveTab('members')}
                className={`px-6 py-4 font-medium text-sm relative transition-colors ${activeTab === 'members' ? 'text-zinc-900' : 'text-zinc-500 hover:text-zinc-800'}`}
              >
                Team Roster
                {activeTab === 'members' && (
                  <motion.div layoutId="tab-indicator" className="absolute bottom-0 left-0 right-0 h-0.5 bg-purple-500" />
                )}
              </button>
              <button
                onClick={() => setActiveTab('roles')}
                className={`px-6 py-4 font-medium text-sm relative transition-colors ${activeTab === 'roles' ? 'text-zinc-900' : 'text-zinc-500 hover:text-zinc-800'}`}
              >
                Roles & Permissions
                {activeTab === 'roles' && (
                  <motion.div layoutId="tab-indicator" className="absolute bottom-0 left-0 right-0 h-0.5 bg-purple-500" />
                )}
              </button>
            </div>

            <AnimatePresence mode="wait">
              {activeTab === 'members' ? (
                <motion.div
                  key="members"
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -10 }}
                  className="space-y-4"
                >
                  {/* Toolbar */}
                  <div className="flex flex-col sm:flex-row gap-4 justify-between items-center bg-white/50 p-4 rounded-2xl border border-zinc-200 backdrop-blur-xl">
                    <div className="relative w-full sm:w-96">
                      <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-zinc-500" />
                      <input 
                        type="text" 
                        placeholder="Search team members by name or email..."
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        className="w-full pl-10 pr-4 py-2.5 bg-white border border-zinc-200 rounded-xl text-sm focus:outline-none focus:border-purple-500 focus:ring-1 focus:ring-purple-500 transition-all text-zinc-900 placeholder-zinc-500"
                      />
                    </div>
                    <button className="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-white border border-zinc-200 text-zinc-600 text-sm font-medium hover:bg-zinc-100 transition-colors w-full sm:w-auto justify-center">
                      <Filter className="w-4 h-4" />
                      Filters
                    </button>
                  </div>

                  {/* Roster Table */}
                  <div className="bg-white/50 border border-zinc-200 rounded-2xl overflow-hidden backdrop-blur-xl">
                    <div className="overflow-x-auto">
                      <table className="w-full text-left border-collapse">
                        <thead>
                          <tr className="border-b border-zinc-200 bg-white/50 text-xs uppercase tracking-wider text-zinc-500">
                            <th className="p-4 font-semibold">User</th>
                            <th className="p-4 font-semibold">Role</th>
                            <th className="p-4 font-semibold">Workspaces</th>
                            <th className="p-4 font-semibold">Status</th>
                            <th className="p-4 font-semibold text-right">Actions</th>
                          </tr>
                        </thead>
                        <tbody className="divide-y divide-zinc-800/50">
                          {filteredMembers.map((member) => (
                            <tr key={member.id} className="hover:bg-zinc-100/30 transition-colors group">
                              <td className="p-4">
                                <div className="flex items-center gap-3">
                                  <img src={member.avatar} alt={member.name} className="w-10 h-10 rounded-full bg-zinc-100" />
                                  <div>
                                    <p className="text-sm font-medium text-zinc-900">{member.name}</p>
                                    <p className="text-xs text-zinc-500">{member.email}</p>
                                  </div>
                                </div>
                              </td>
                              <td className="p-4">
                                <div className="flex items-center gap-2 text-sm text-zinc-600">
                                  {getRoleIcon(member.role)}
                                  {member.role}
                                </div>
                              </td>
                              <td className="p-4">
                                <div className="flex flex-wrap gap-1.5">
                                  {member.workspaces.map((ws: any, i: number) => (
                                    <span key={i} className="px-2 py-0.5 rounded text-[11px] font-medium bg-zinc-100 text-zinc-600 border border-zinc-200/50">
                                      {ws}
                                    </span>
                                  ))}
                                </div>
                              </td>
                              <td className="p-4">
                                {getStatusBadge(member.status)}
                                <p className="text-[10px] text-zinc-500 mt-1 pl-1">Last seen: {member.lastActive}</p>
                              </td>
                              <td className="p-4 text-right">
                                <button className="p-2 text-zinc-500 hover:text-zinc-900 rounded-lg hover:bg-zinc-100 transition-colors opacity-0 group-hover:opacity-100 focus:opacity-100">
                                  <MoreVertical className="w-4 h-4" />
                                </button>
                              </td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                      {filteredMembers.length === 0 && (
                        <div className="p-8 text-center text-zinc-500">
                          <Users className="w-12 h-12 mx-auto mb-3 opacity-20" />
                          <p>No team members found.</p>
                        </div>
                      )}
                    </div>
                  </div>
                </motion.div>
              ) : (
                <motion.div
                  key="roles"
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -10 }}
                  className="space-y-4"
                >
                  <div className="bg-white/50 border border-zinc-200 rounded-2xl overflow-hidden backdrop-blur-xl">
                    <div className="overflow-x-auto">
                      <table className="w-full text-left border-collapse min-w-[800px]">
                        <thead>
                          <tr className="border-b border-zinc-200 bg-white/50 text-xs uppercase tracking-wider text-zinc-500">
                            <th className="p-6 font-semibold w-1/3">Role & Description</th>
                            <th className="p-6 font-semibold text-center">Manage Users</th>
                            <th className="p-6 font-semibold text-center">Edit Schemas</th>
                            <th className="p-6 font-semibold text-center">Publish Data</th>
                            <th className="p-6 font-semibold text-center">View Data</th>
                          </tr>
                        </thead>
                        <tbody className="divide-y divide-zinc-800/50">
                          {ROLES_MATRIX.map((role, idx) => (
                            <tr key={idx} className="hover:bg-zinc-100/30 transition-colors">
                              <td className="p-6">
                                <div className="flex items-center gap-2 text-zinc-900 font-medium mb-1">
                                  {getRoleIcon(role.role)}
                                  {role.role}
                                </div>
                                <p className="text-sm text-zinc-500">{role.desc}</p>
                              </td>
                              <td className="p-6 text-center">
                                {role.canInvite ? <Check className="w-5 h-5 text-emerald-400 mx-auto" /> : <X className="w-5 h-5 text-zinc-700 mx-auto" />}
                              </td>
                              <td className="p-6 text-center">
                                {role.canEditSchema ? <Check className="w-5 h-5 text-emerald-400 mx-auto" /> : <X className="w-5 h-5 text-zinc-700 mx-auto" />}
                              </td>
                              <td className="p-6 text-center">
                                {role.canPublish ? <Check className="w-5 h-5 text-emerald-400 mx-auto" /> : <X className="w-5 h-5 text-zinc-700 mx-auto" />}
                              </td>
                              <td className="p-6 text-center">
                                {role.canView ? <Check className="w-5 h-5 text-emerald-400 mx-auto" /> : <X className="w-5 h-5 text-zinc-700 mx-auto" />}
                              </td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>
          </div>

          {/* Right Column: Audit Logs */}
          <div className="lg:col-span-1">
            <div className="bg-white/50 border border-zinc-200 rounded-2xl p-6 backdrop-blur-xl sticky top-8">
              <div className="flex items-center justify-between mb-6">
                <h3 className="font-semibold text-zinc-900 flex items-center gap-2">
                  <Activity className="w-4 h-4 text-purple-400" />
                  Audit Log
                </h3>
                <button className="text-xs text-purple-400 hover:text-purple-300 font-medium transition-colors">
                  View All
                </button>
              </div>
              
              <div className="space-y-6 relative before:absolute before:inset-0 before:ml-5 before:-translate-x-px md:before:mx-auto md:before:translate-x-0 before:h-full before:w-0.5 before:bg-gradient-to-b before:from-transparent before:via-zinc-800 before:to-transparent">
                {AUDIT_LOGS.map((log) => (
                  <div key={log.id} className="relative flex items-start justify-between md:justify-normal md:odd:flex-row-reverse group is-active">
                    
                    <div className="flex items-center justify-center w-10 h-10 rounded-full border border-zinc-200 bg-white shrink-0 md:order-1 md:group-odd:-translate-x-1/2 md:group-even:translate-x-1/2 shadow-sm relative z-10">
                       <div className={`p-1.5 rounded-full ${log.bg} ${log.color}`}>
                          <log.icon className="w-4 h-4" />
                       </div>
                    </div>
                    
                    <div className="w-[calc(100%-3rem)] md:w-[calc(50%-2.5rem)] p-4 rounded-xl border border-zinc-200 bg-white/50 shadow-sm hover:border-zinc-200 transition-colors ml-4 md:ml-0 md:group-odd:mr-8 md:group-even:ml-8">
                      <div className="flex items-center justify-between space-x-2 mb-1">
                        <div className="font-semibold text-zinc-900 text-sm">{log.action}</div>
                        <time className="font-mono text-xs text-zinc-500">{log.time}</time>
                      </div>
                      <div className="text-sm text-zinc-500 leading-snug">{log.details}</div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

        </div>
      </div>

      {/* Invite Member Drawer/Modal Overlay */}
      <AnimatePresence>
        {isInviteOpen && (
          <>
            <motion.div 
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setIsInviteOpen(false)}
              className="fixed inset-0 bg-black/60 backdrop-blur-sm z-40"
            />
            <motion.div 
              initial={{ x: '100%', opacity: 0.5 }}
              animate={{ x: 0, opacity: 1 }}
              exit={{ x: '100%', opacity: 0.5 }}
              transition={{ type: 'spring', damping: 25, stiffness: 200 }}
              className="fixed top-0 right-0 bottom-0 w-full max-w-md bg-white border-l border-zinc-200 z-50 p-6 sm:p-8 flex flex-col shadow-2xl"
            >
              <div className="flex items-center justify-between mb-8">
                <h2 className="text-2xl font-bold text-zinc-900">Invite Members</h2>
                <button 
                  onClick={() => setIsInviteOpen(false)}
                  className="p-2 text-zinc-500 hover:text-zinc-900 rounded-lg hover:bg-zinc-50 transition-colors"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>

              <div className="flex-1 overflow-y-auto space-y-6 -mx-2 px-2 pb-8">
                
                {/* Email Input */}
                <div className="space-y-2">
                  <label className="text-sm font-medium text-zinc-600">Email Addresses</label>
                  <textarea 
                    value={inviteEmails}
                    onChange={(e) => setInviteEmails(e.target.value)}
                    placeholder="e.g. jane@example.com, bob@example.com&#10;Separate multiple emails with commas or newlines."
                    className="w-full h-32 p-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm focus:outline-none focus:border-purple-500 focus:ring-1 focus:ring-purple-500 transition-all text-zinc-900 placeholder-zinc-600 resize-none"
                  />
                </div>

                {/* Role Selection */}
                <div className="space-y-2">
                  <label className="text-sm font-medium text-zinc-600">Assign Role</label>
                  <div className="relative">
                    <select 
                      value={inviteRole}
                      onChange={(e) => setInviteRole(e.target.value)}
                      className="w-full appearance-none pl-10 pr-10 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm focus:outline-none focus:border-purple-500 focus:ring-1 focus:ring-purple-500 transition-all text-zinc-900 cursor-pointer"
                    >
                      <option value="Admin">Admin</option>
                      <option value="Dataset Manager">Dataset Manager</option>
                      <option value="Editor">Editor</option>
                      <option value="Viewer">Viewer</option>
                    </select>
                    <div className="absolute left-3 top-1/2 -translate-y-1/2 text-zinc-500">
                      {getRoleIcon(inviteRole)}
                    </div>
                    <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-zinc-500 pointer-events-none" />
                  </div>
                  <p className="text-xs text-zinc-500 mt-1">
                    {ROLES_MATRIX.find(r => r.role === inviteRole)?.desc}
                  </p>
                </div>

                {/* Workspace Selection */}
                <div className="space-y-3">
                  <label className="text-sm font-medium text-zinc-600">Assign Workspaces</label>
                  <div className="space-y-2">
                    {availableWorkspaces.map(ws => (
                      <label key={ws} className="flex items-center gap-3 p-3 rounded-xl border border-zinc-200 hover:bg-zinc-50 transition-colors cursor-pointer group">
                        <div className={`w-5 h-5 rounded flex items-center justify-center border transition-colors ${inviteWorkspaces.includes(ws) ? 'bg-purple-500 border-purple-500' : 'border-zinc-200 group-hover:border-zinc-300'}`}>
                          {inviteWorkspaces.includes(ws) && <Check className="w-3.5 h-3.5 text-zinc-900" />}
                        </div>
                        <input 
                          type="checkbox"
                          className="hidden"
                          checked={inviteWorkspaces.includes(ws)}
                          onChange={(e) => {
                            if (ws === 'All Workspaces') {
                              setInviteWorkspaces(e.target.checked ? ['All Workspaces'] : []);
                              return;
                            }
                            
                            let newWs = [...inviteWorkspaces];
                            if (e.target.checked) {
                              newWs.push(ws);
                              newWs = newWs.filter(w => w !== 'All Workspaces');
                            } else {
                              newWs = newWs.filter(w => w !== ws);
                            }
                            setInviteWorkspaces(newWs);
                          }}
                        />
                        <span className="text-sm text-zinc-600 group-hover:text-zinc-900 transition-colors">{ws}</span>
                      </label>
                    ))}
                  </div>
                </div>
              </div>

              {/* Footer */}
              <div className="pt-6 border-t border-zinc-200 mt-auto">
                <button 
                  onClick={() => setIsInviteOpen(false)}
                  className="w-full py-3 px-4 bg-purple-600 hover:bg-purple-500 text-zinc-900 font-medium rounded-xl transition-all shadow-[0_0_20px_-5px_rgba(168,85,247,0.4)] active:scale-[0.98]"
                >
                  Send Invitations
                </button>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </div>
  );
}
