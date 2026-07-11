"use client";

import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  MessageSquareWarning, Filter, Plus, Clock, CheckCircle2, MoreVertical, 
  Search, Paperclip, Send, AlertTriangle, Users, MapPin, X, User, ShieldAlert, 
  Check, TrendingDown, Timer, Loader2, Download, BellRing, Flag, ArrowRight,
  MessageCircle, Link as LinkIcon, Edit3, Trash2, Calendar, FileText, Image as ImageIcon, ChevronDown
} from 'lucide-react';
import { api } from '@/lib/api';
import { 
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Cell
} from 'recharts';

const CATEGORIES = ['All', 'Infrastructure', 'Academics', 'Security', 'IT Support', 'Facilities'];

const MOCK_ANALYTICS_DATA = [
  { name: 'Mon', value: 12 },
  { name: 'Tue', value: 19 },
  { name: 'Wed', value: 15 },
  { name: 'Thu', value: 8 },
  { name: 'Fri', value: 22 },
  { name: 'Sat', value: 5 },
  { name: 'Sun', value: 3 },
];

export default function ComplaintsPage() {
  const [activeFilter, setActiveFilter] = useState('All');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedComplaint, setSelectedComplaint] = useState<any | null>(null);
  const [selectedRowIds, setSelectedRowIds] = useState<Set<string>>(new Set());
  
  const [complaints, setComplaints] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  
  const [activeWorkspace, setActiveWorkspace] = useState<any>(null);

  useEffect(() => {
    const ws = localStorage.getItem('activeWorkspace');
    if (ws) {
      setActiveWorkspace(JSON.parse(ws));
    }
  }, []);

  const loadComplaints = async () => {
    try {
      if (!activeWorkspace?.id) return;
      setIsLoading(true);
      const response = await api.complaints.getWorkspaceComplaints(activeWorkspace.id, 'new');
      const mapped = (response.content || []).map((c: any) => ({
        id: `C-${c.id.substring(0, 4).toUpperCase()}`,
        originalId: c.id,
        title: c.title,
        category: c.category || 'Infrastructure',
        priority: c.priority === 'CRITICAL' ? 'Critical' : c.priority === 'HIGH' ? 'High' : c.priority === 'MEDIUM' ? 'Medium' : 'Low',
        status: c.status === 'OPEN' ? 'New' : c.status === 'IN_PROGRESS' || c.status === 'UNDER_REVIEW' ? 'In Progress' : c.status === 'RESOLVED' ? 'Resolved' : 'Escalated',
        reporter: c.isAnonymous ? 'Anonymous' : c.creator?.name || 'Unknown User',
        time: new Date(c.createdAt).toLocaleDateString(),
        assigned: c.assignee?.name || null,
        description: c.description
      }));
      setComplaints(mapped);
      
      if (selectedComplaint) {
        const updated = mapped.find((m: any) => m.originalId === selectedComplaint.originalId);
        if (updated) setSelectedComplaint(updated);
      }
    } catch (error) {
      console.error("Failed to load complaints:", error);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadComplaints();
  }, [activeWorkspace?.id]);

  const stats = React.useMemo(() => {
    const open = complaints.filter(c => c.status === 'New').length;
    const pending = complaints.filter(c => c.status === 'In Progress').length;
    const resolved = complaints.filter(c => c.status === 'Resolved').length;
    const escalated = complaints.filter(c => c.status === 'Escalated').length;
    const highPriority = complaints.filter(c => c.priority === 'Critical' || c.priority === 'High').length;
    
    return [
      { label: 'Open', value: open.toString(), trend: 'Active', color: 'text-amber-500' },
      { label: 'Pending', value: pending.toString(), trend: 'In Progress', color: 'text-blue-500' },
      { label: 'Resolved', value: resolved.toString(), trend: 'Completed', color: 'text-emerald-500' },
      { label: 'Escalated', value: escalated.toString(), trend: 'Needs Review', color: 'text-red-500' },
      { label: 'High Priority', value: highPriority.toString(), trend: 'Urgent', color: 'text-orange-500' },
      { label: 'Total', value: complaints.length.toString(), trend: 'All Time', color: 'text-purple-500' }
    ];
  }, [complaints]);

  const [replyText, setReplyText] = useState('');
  const [isReplying, setIsReplying] = useState(false);
  const [isUpdatingStatus, setIsUpdatingStatus] = useState(false);

  const handleSendReply = async () => {
    if (!replyText.trim() || !selectedComplaint) return;
    setIsReplying(true);
    try {
      await api.complaints.addComment(selectedComplaint.originalId, replyText); 
      setReplyText('');
    } catch (e) {
      console.error(e);
    } finally {
      setIsReplying(false);
    }
  };

  const filteredComplaints = complaints.filter(c => 
    (activeFilter === 'All' || c.category === activeFilter) &&
    (c.title.toLowerCase().includes(searchQuery.toLowerCase()) || c.id.toLowerCase().includes(searchQuery.toLowerCase()))
  );

  const getPriorityBadge = (priority: string) => {
    switch(priority) {
      case 'Critical': return <span className="inline-flex items-center gap-1.5 px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-wider bg-red-50 text-red-600 border border-red-200"><span className="w-1.5 h-1.5 rounded-full bg-red-500 animate-pulse"></span> Critical</span>;
      case 'High': return <span className="inline-flex items-center gap-1.5 px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-wider bg-orange-50 text-orange-600 border border-orange-200"><span className="w-1.5 h-1.5 rounded-full bg-orange-500"></span> High</span>;
      case 'Medium': return <span className="inline-flex items-center gap-1.5 px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-wider bg-blue-50 text-blue-600 border border-blue-200">Medium</span>;
      default: return <span className="inline-flex items-center gap-1.5 px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-wider bg-zinc-100 text-zinc-600 border border-zinc-200">Low</span>;
    }
  };

  const getStatusBadge = (status: string) => {
    switch(status) {
      case 'New': return <span className="flex items-center gap-1.5 px-2.5 py-1 rounded-md text-[11px] font-bold bg-purple-50 text-purple-600 border border-purple-200"><ShieldAlert className="w-3 h-3" /> New</span>;
      case 'In Progress': return <span className="flex items-center gap-1.5 px-2.5 py-1 rounded-md text-[11px] font-bold bg-blue-50 text-blue-600 border border-blue-200"><Clock className="w-3 h-3" /> In Progress</span>;
      case 'Escalated': return <span className="flex items-center gap-1.5 px-2.5 py-1 rounded-md text-[11px] font-bold bg-red-50 text-red-600 border border-red-200"><AlertTriangle className="w-3 h-3" /> Escalated</span>;
      case 'Resolved': return <span className="flex items-center gap-1.5 px-2.5 py-1 rounded-md text-[11px] font-bold bg-emerald-50 text-emerald-600 border border-emerald-200"><CheckCircle2 className="w-3 h-3" /> Resolved</span>;
      default: return null;
    }
  };

  return (
    <div className="min-h-screen bg-transparent text-zinc-900 p-4 md:p-8 font-sans overflow-hidden">
      <div className="max-w-[1600px] mx-auto space-y-6">
        
        {/* Header */}
        <div className="flex flex-col md:flex-row md:items-end justify-between gap-6">
          <div>
            <h1 className="text-3xl font-extrabold text-zinc-900 tracking-tight">Complaint Center</h1>
            <p className="text-zinc-500 mt-1 text-sm font-medium">Manage and resolve complaints submitted by users.</p>
          </div>
          <div className="flex gap-3">
            <button className="px-4 py-2 bg-white border border-zinc-200 text-zinc-700 font-semibold rounded-xl hover:bg-zinc-50 transition-colors shadow-sm flex items-center gap-2 text-sm">
              <Download className="w-4 h-4" /> Export
            </button>
            <button className="px-5 py-2 bg-[#635BFF] text-white font-semibold rounded-xl hover:bg-[#5b54eb] transition-all shadow-sm flex items-center gap-2 text-sm">
              <Plus className="w-4 h-4" /> Create Notice
            </button>
          </div>
        </div>

        {/* Global Statistics Grid */}
        <div className="grid grid-cols-2 lg:grid-cols-6 gap-4">
          {stats.map((stat, i) => (
             <div key={i} className="bg-white border border-zinc-200 rounded-2xl p-4 shadow-sm hover:shadow-md transition-shadow">
               <p className="text-[11px] font-bold text-zinc-500 uppercase tracking-wider mb-1">{stat.label}</p>
               <div className="flex items-end justify-between">
                 <span className={`text-2xl font-black ${stat.color}`}>{stat.value}</span>
                 <span className="text-[10px] font-bold text-zinc-400 bg-zinc-50 px-1.5 py-0.5 rounded">{stat.trend}</span>
               </div>
             </div>
          ))}
        </div>

        {/* Enterprise Data Table Area */}
        <div className="bg-white border border-zinc-200 rounded-2xl shadow-sm overflow-hidden flex flex-col">
          
          {/* Table Toolbar */}
          <div className="p-4 border-b border-zinc-200 bg-zinc-50/50 flex flex-col xl:flex-row items-center justify-between gap-4">
            <div className="flex items-center gap-2 w-full xl:w-auto">
              <div className="relative flex-1 xl:w-80">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-zinc-400" />
                <input 
                  type="text" 
                  placeholder="Search by ID, title, or reporter..."
                  value={searchQuery}
                  onChange={e => setSearchQuery(e.target.value)}
                  className="w-full pl-9 pr-4 py-2 bg-white border border-zinc-200 rounded-lg text-sm focus:outline-none focus:border-[#635BFF] focus:ring-1 focus:ring-[#635BFF] transition-all"
                />
              </div>
              <div className="hidden md:flex bg-zinc-200/50 p-1 rounded-lg">
                {CATEGORIES.slice(0, 4).map(cat => (
                  <button 
                    key={cat} onClick={() => setActiveFilter(cat)} 
                    className={`px-3 py-1 text-xs font-bold rounded-md transition-all ${activeFilter === cat ? 'bg-white shadow-sm text-zinc-900' : 'text-zinc-500 hover:text-zinc-700'}`}
                  >
                    {cat}
                  </button>
                ))}
              </div>
            </div>
            
            <div className="flex items-center gap-3 text-sm text-zinc-500 font-medium w-full xl:w-auto justify-between xl:justify-end">
              {selectedRowIds.size > 0 && (
                <div className="flex items-center gap-2">
                   <span className="text-[#635BFF] bg-[#635BFF]/10 px-3 py-1 rounded-md text-xs font-bold">{selectedRowIds.size} selected</span>
                   <button className="px-3 py-1.5 border border-zinc-200 rounded-lg hover:bg-zinc-100 flex items-center gap-2 text-xs font-bold text-zinc-700"><Check className="w-3 h-3"/> Resolve</button>
                   <button className="px-3 py-1.5 border border-zinc-200 rounded-lg hover:bg-zinc-100 flex items-center gap-2 text-xs font-bold text-zinc-700"><User className="w-3 h-3"/> Assign</button>
                </div>
              )}
            </div>
          </div>

          {/* Table */}
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm">
              <thead className="bg-zinc-50 border-b border-zinc-200 text-zinc-500 font-bold uppercase tracking-wider text-[10px]">
                <tr>
                  <th className="px-6 py-4 w-10">
                    <input type="checkbox" className="rounded border-zinc-300 text-[#635BFF] focus:ring-[#635BFF]" 
                           onChange={(e) => {
                             if (e.target.checked) setSelectedRowIds(new Set(filteredComplaints.map(p => p.id)));
                             else setSelectedRowIds(new Set());
                           }} 
                           checked={selectedRowIds.size === filteredComplaints.length && filteredComplaints.length > 0}/>
                  </th>
                  <th className="px-6 py-4">ID</th>
                  <th className="px-6 py-4 min-w-[250px]">Title</th>
                  <th className="px-6 py-4">Priority</th>
                  <th className="px-6 py-4">Status</th>
                  <th className="px-6 py-4">Reporter</th>
                  <th className="px-6 py-4">Assignee</th>
                  <th className="px-6 py-4">Created</th>
                  <th className="px-6 py-4 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-zinc-100">
                {isLoading ? (
                  <tr>
                    <td colSpan={9} className="px-6 py-20 text-center">
                      <Loader2 className="w-8 h-8 animate-spin text-[#635BFF] mx-auto mb-2" />
                      <p className="text-zinc-500 text-sm font-medium">Loading complaints...</p>
                    </td>
                  </tr>
                ) : filteredComplaints.map((complaint) => (
                  <tr key={complaint.id} onClick={() => setSelectedComplaint(complaint)} className="hover:bg-zinc-50/80 transition-colors group cursor-pointer">
                    <td className="px-6 py-4" onClick={(e) => e.stopPropagation()}>
                      <input type="checkbox" className="rounded border-zinc-300 text-[#635BFF] focus:ring-[#635BFF]" 
                             checked={selectedRowIds.has(complaint.id)}
                             onChange={(e) => {
                               const newSet = new Set(selectedRowIds);
                               if (e.target.checked) newSet.add(complaint.id); else newSet.delete(complaint.id);
                               setSelectedRowIds(newSet);
                             }}/>
                    </td>
                    <td className="px-6 py-4 font-mono font-bold text-zinc-500 text-xs">{complaint.id}</td>
                    <td className="px-6 py-4">
                      <div className="font-bold text-zinc-900 truncate max-w-[300px]">{complaint.title}</div>
                      <div className="text-xs text-zinc-500 font-medium mt-0.5">{complaint.category}</div>
                    </td>
                    <td className="px-6 py-4">{getPriorityBadge(complaint.priority)}</td>
                    <td className="px-6 py-4">{getStatusBadge(complaint.status)}</td>
                    <td className="px-6 py-4 text-zinc-700 font-medium">{complaint.reporter}</td>
                    <td className="px-6 py-4">
                      {complaint.assigned ? (
                         <div className="flex items-center gap-1.5">
                           <div className="w-5 h-5 rounded-full bg-[#635BFF]/10 flex items-center justify-center text-[9px] font-bold text-[#635BFF]">A</div>
                           <span className="text-zinc-700 font-medium">{complaint.assigned}</span>
                         </div>
                      ) : (
                        <span className="text-zinc-400 font-medium italic text-xs">Unassigned</span>
                      )}
                    </td>
                    <td className="px-6 py-4 text-zinc-500 text-xs font-medium">{complaint.time}</td>
                    <td className="px-6 py-4 text-right">
                      <div className="flex items-center justify-end gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                        <button className="p-1.5 text-zinc-500 hover:text-zinc-900 hover:bg-zinc-100 rounded-md" title="View Detail">
                          <ArrowRight className="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          
          <div className="p-4 border-t border-zinc-200 bg-zinc-50 flex items-center justify-between text-xs text-zinc-500 font-medium">
            <span>Showing {filteredComplaints.length} results</span>
            <div className="flex gap-2">
              <button className="px-3 py-1 bg-white border border-zinc-200 rounded-md hover:bg-zinc-50">Previous</button>
              <button className="px-3 py-1 bg-white border border-zinc-200 rounded-md hover:bg-zinc-50">Next</button>
            </div>
          </div>
        </div>
      </div>

      {/* Advanced Drawer Inspector */}
      <AnimatePresence>
        {selectedComplaint && (
          <>
            <motion.div 
              initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
              onClick={() => setSelectedComplaint(null)}
              className="fixed inset-0 bg-black/40 backdrop-blur-sm z-40"
            />
            <motion.div 
              initial={{ x: '100%', boxShadow: '0 0 0 rgba(0,0,0,0)' }} 
              animate={{ x: 0, boxShadow: '-10px 0 30px rgba(0,0,0,0.1)' }} 
              exit={{ x: '100%' }}
              transition={{ type: 'spring', damping: 25, stiffness: 200 }}
              className="fixed top-0 right-0 bottom-0 w-full max-w-[900px] bg-white border-l border-zinc-200 z-50 flex flex-col shadow-2xl overflow-hidden"
            >
              {/* Drawer Toolbar */}
              <div className="p-4 border-b border-zinc-200 flex items-center justify-between bg-zinc-50/80 shrink-0">
                <div className="flex items-center gap-3">
                  <button onClick={() => setSelectedComplaint(null)} className="p-1.5 hover:bg-white rounded-md text-zinc-500 transition-colors border border-transparent hover:border-zinc-200"><X className="w-5 h-5"/></button>
                  <span className="text-xs font-mono font-bold text-zinc-500 bg-white px-2 py-1 rounded-md border border-zinc-200">{selectedComplaint.id}</span>
                  {getPriorityBadge(selectedComplaint.priority)}
                  {getStatusBadge(selectedComplaint.status)}
                </div>
                <div className="flex items-center gap-2">
                  <button className="px-3 py-1.5 bg-white border border-zinc-200 text-zinc-600 font-bold text-xs rounded-lg hover:bg-zinc-50 flex items-center gap-1.5"><LinkIcon className="w-3.5 h-3.5"/> Copy Link</button>
                  <button className="p-1.5 bg-white border border-zinc-200 text-zinc-600 rounded-lg hover:bg-zinc-50"><MoreVertical className="w-4 h-4"/></button>
                </div>
              </div>

              {/* Drawer Split Content */}
              <div className="flex-1 overflow-hidden flex flex-col lg:flex-row bg-white">
                
                {/* Left Panel: Complaint Details */}
                <div className="flex-1 overflow-y-auto p-6 border-r border-zinc-200">
                  <h2 className="text-2xl font-black text-zinc-900 leading-tight mb-6">{selectedComplaint.title}</h2>
                  
                  <div className="space-y-8">
                    {/* Meta Info Grid */}
                    <div className="grid grid-cols-2 gap-4">
                      <div className="bg-zinc-50 border border-zinc-200 rounded-xl p-4">
                        <p className="text-[10px] font-bold text-zinc-500 uppercase tracking-wider mb-1">Reporter</p>
                        <div className="flex items-center gap-2">
                          <div className="w-6 h-6 rounded-full bg-zinc-200 flex items-center justify-center"><User className="w-3 h-3 text-zinc-500"/></div>
                          <p className="text-sm font-bold text-zinc-900">{selectedComplaint.reporter}</p>
                        </div>
                      </div>
                      <div className="bg-zinc-50 border border-zinc-200 rounded-xl p-4">
                        <p className="text-[10px] font-bold text-zinc-500 uppercase tracking-wider mb-1">Created At</p>
                        <div className="flex items-center gap-2 text-zinc-700">
                          <Calendar className="w-4 h-4"/>
                          <p className="text-sm font-bold">{selectedComplaint.time}</p>
                        </div>
                      </div>
                    </div>

                    {/* Description */}
                    <div>
                      <h3 className="text-xs font-bold text-zinc-500 uppercase tracking-wider mb-3 flex items-center gap-2"><FileText className="w-4 h-4"/> Description</h3>
                      <div className="p-5 rounded-xl bg-zinc-50 border border-zinc-100 text-sm text-zinc-700 leading-relaxed whitespace-pre-wrap font-medium">
                        {selectedComplaint.description || "No description provided by the reporter."}
                      </div>
                    </div>

                    {/* Attachments */}
                    <div>
                      <h3 className="text-xs font-bold text-zinc-500 uppercase tracking-wider mb-3 flex items-center gap-2"><Paperclip className="w-4 h-4"/> Attachments</h3>
                      <div className="flex gap-3 overflow-x-auto pb-2">
                        <div className="w-32 h-24 rounded-xl border border-zinc-200 bg-zinc-50 flex flex-col items-center justify-center text-zinc-400 hover:bg-zinc-100 cursor-pointer transition-colors group">
                           <ImageIcon className="w-6 h-6 mb-2 group-hover:text-zinc-600 transition-colors" />
                           <span className="text-[10px] font-bold uppercase tracking-wider">screenshot.png</span>
                        </div>
                      </div>
                    </div>

                    {/* Timeline */}
                    <div>
                      <h3 className="text-xs font-bold text-zinc-500 uppercase tracking-wider mb-4 flex items-center gap-2"><Clock className="w-4 h-4"/> Activity Timeline</h3>
                      <div className="relative border-l-2 border-zinc-200 ml-2 space-y-6 pt-2 pb-4">
                        <div className="relative pl-6">
                          <div className="absolute -left-[9px] top-1 w-4 h-4 rounded-full bg-white border-2 border-zinc-200" />
                          <div className="flex justify-between items-center mb-1">
                            <span className="text-xs font-bold text-zinc-800">Complaint Logged</span>
                            <span className="text-[10px] text-zinc-500 font-medium">10 mins ago</span>
                          </div>
                          <p className="text-xs text-zinc-500 font-medium">System generated via public portal.</p>
                        </div>
                        <div className="relative pl-6">
                          <div className="absolute -left-[9px] top-1 w-4 h-4 rounded-full bg-white border-2 border-orange-400" />
                          <div className="flex justify-between items-center mb-1">
                            <span className="text-xs font-bold text-zinc-900">Priority Escalated</span>
                            <span className="text-[10px] text-zinc-500 font-medium">8 mins ago</span>
                          </div>
                          <p className="text-xs text-orange-600 font-medium">Automated Triage bumped priority to High.</p>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Right Panel: Actions & Internal Notes */}
                <div className="w-full lg:w-[320px] bg-zinc-50 flex flex-col shrink-0">
                  <div className="p-5 border-b border-zinc-200 space-y-4">
                    <h3 className="text-xs font-bold text-zinc-500 uppercase tracking-wider">Manage Complaint</h3>
                    
                    <div>
                      <label className="text-[10px] font-bold text-zinc-500 uppercase tracking-wider mb-1 block">Assign Staff</label>
                      <button className="w-full px-3 py-2 bg-white border border-zinc-200 rounded-lg text-left text-sm font-medium text-zinc-500 hover:border-zinc-300 flex justify-between items-center">
                        Select Assignee... <ChevronDown className="w-4 h-4"/>
                      </button>
                    </div>

                    <div>
                      <label className="text-[10px] font-bold text-zinc-500 uppercase tracking-wider mb-1 block">Change Status</label>
                      <div className="grid grid-cols-2 gap-2">
                        <button className="px-2 py-1.5 bg-white border border-zinc-200 rounded-lg text-xs font-bold text-zinc-700 hover:bg-zinc-100">In Progress</button>
                        <button className="px-2 py-1.5 bg-emerald-50 border border-emerald-200 rounded-lg text-xs font-bold text-emerald-700 hover:bg-emerald-100 flex justify-center gap-1"><Check className="w-3 h-3"/> Resolve</button>
                        <button className="px-2 py-1.5 bg-white border border-zinc-200 rounded-lg text-xs font-bold text-zinc-700 hover:bg-zinc-100">Escalate</button>
                        <button className="px-2 py-1.5 bg-rose-50 border border-rose-200 rounded-lg text-xs font-bold text-rose-700 hover:bg-rose-100">Reject</button>
                      </div>
                    </div>
                  </div>

                  {/* Internal Notes / Comments */}
                  <div className="flex-1 flex flex-col p-5 overflow-hidden">
                     <h3 className="text-xs font-bold text-zinc-500 uppercase tracking-wider mb-3 flex items-center gap-2"><MessageCircle className="w-4 h-4"/> Internal Notes</h3>
                     <div className="flex-1 overflow-y-auto space-y-4 pb-4">
                       <div className="text-center text-xs text-zinc-400 font-medium mt-10">
                         No internal notes yet.<br/>Use this space to collaborate with your team.
                       </div>
                     </div>
                     
                     <div className="mt-auto relative">
                       <textarea 
                         placeholder="Type an internal note..."
                         value={replyText}
                         onChange={(e) => setReplyText(e.target.value)}
                         className="w-full bg-white border border-zinc-200 rounded-xl px-4 py-3 text-sm focus:outline-none focus:border-[#635BFF] focus:ring-1 focus:ring-[#635BFF] resize-none pr-12 min-h-[80px]"
                       />
                       <button onClick={handleSendReply} className="absolute bottom-2 right-2 p-2 bg-[#635BFF] text-white rounded-lg hover:bg-[#5b54eb] shadow-sm">
                         <Send className="w-4 h-4" />
                       </button>
                     </div>
                  </div>
                </div>

              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>

    </div>
  );
}
