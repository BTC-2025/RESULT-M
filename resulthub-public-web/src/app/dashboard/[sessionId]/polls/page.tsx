"use client";

import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  BarChart2, Plus, Calendar, Lock, Globe, Users, Clock, CheckCircle2, 
  X, Trash2, ShieldAlert, ArrowRight, Activity, Percent, MoreHorizontal,
  Search, Filter, Download, MoreVertical, Settings, FileText, Share2, Eye, Edit, Copy, TrendingUp, ChevronDown, Check, MousePointerClick, ChevronRight, Image as ImageIcon, Sparkles, Smartphone, Map
} from 'lucide-react';
import { 
  AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, 
  BarChart, Bar, Cell, PieChart, Pie, Legend
} from 'recharts';

import { api } from '@/lib/api';

const MOCK_TIME_DATA = [
  { name: 'Mon', votes: 400 },
  { name: 'Tue', votes: 300 },
  { name: 'Wed', votes: 550 },
  { name: 'Thu', votes: 200 },
  { name: 'Fri', votes: 680 },
  { name: 'Sat', votes: 900 },
  { name: 'Sun', votes: 850 },
];

const MOCK_DEVICE_DATA = [
  { name: 'Mobile', value: 65, color: '#6366f1' },
  { name: 'Desktop', value: 30, color: '#8b5cf6' },
  { name: 'Tablet', value: 5, color: '#ec4899' },
];

export default function PollsPage() {
  const [polls, setPolls] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [selectedPolls, setSelectedPolls] = useState<Set<string>>(new Set());
  
  const [activeWorkspace, setActiveWorkspace] = useState<any>(null);

  useEffect(() => {
    const ws = localStorage.getItem('activeWorkspace');
    if (ws) {
      setActiveWorkspace(JSON.parse(ws));
    }
  }, []);
  
  // Modals & Drawers
  const [isCreateOpen, setIsCreateOpen] = useState(false);
  const [analyticsPollId, setAnalyticsPollId] = useState<string | null>(null);
  
  // Create Modal State
  const [activeTab, setActiveTab] = useState('General');
  const [pollData, setPollData] = useState({
    title: '', description: '', category: 'General', visibility: 'Public', password: '',
    options: ['', ''], allowAnonymous: true, requireLogin: false, oneVotePerUser: true, autoClose: false
  });
  const [isSubmitting, setIsSubmitting] = useState(false);

  const loadPolls = async () => {
    try {
      if (!activeWorkspace?.id) return;
      setIsLoading(true);
      const response = await api.votes.getWorkspaceVoteBoxes(activeWorkspace.id);
      if (response && response.content) {
        const mapped = response.content.map((p: any) => {
          const total = p.options?.reduce((acc: number, curr: any) => acc + (curr.voteCount || 0), 0) || 0;
          return {
            id: p.id,
            title: p.title,
            category: p.category || 'General',
            visibility: p.isPrivate ? 'Private' : (p.visibility === 'PASSWORD_PROTECTED' ? 'Protected' : 'Public'),
            status: p.isActive ? 'Active' : 'Closed',
            votes: total,
            createdBy: 'System', // Mocked until API gives creator
            expires: p.endDate ? new Date(p.endDate).toLocaleDateString() : 'Never',
            raw: p
          };
        });
        setPolls(mapped);
      }
    } catch (error) {
      console.error("Failed to load polls:", error);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadPolls();
  }, [activeWorkspace?.id]);

  const stats = React.useMemo(() => {
    const totalPolls = polls.length;
    const activePolls = polls.filter(p => p.status === 'Active').length;
    const closedPolls = polls.filter(p => p.status === 'Closed').length;
    const totalVotes = polls.reduce((sum, p) => sum + (p.totalVotes || 0), 0);
    const participationRate = totalPolls > 0 ? Math.min(100, Math.round((totalVotes / (totalPolls * 50)) * 100)) : 0;
    
    return [
      { label: 'Total Polls', value: totalPolls.toString(), trend: 'All', color: 'text-[#635BFF]' },
      { label: 'Active Polls', value: activePolls.toString(), trend: 'Live', color: 'text-emerald-500' },
      { label: 'Closed Polls', value: closedPolls.toString(), trend: 'Ended', color: 'text-zinc-500' },
      { label: 'Total Votes', value: totalVotes.toLocaleString(), trend: 'All Time', color: 'text-blue-500' },
      { label: 'Participation Rate', value: `${participationRate}%`, trend: 'Est', color: 'text-amber-500' },
      { label: 'Avg Votes/Poll', value: totalPolls > 0 ? Math.round(totalVotes / totalPolls).toString() : '0', trend: 'Avg', color: 'text-purple-500' }
    ];
  }, [polls]);

  const handleLaunchPoll = async () => {
    setIsSubmitting(true);
    try {
      let visibility = 'PUBLIC';
      if (pollData.visibility === 'Private') visibility = 'PRIVATE';
      if (pollData.visibility === 'Password Protected') visibility = 'PASSWORD_PROTECTED';

      const payload = {
        title: pollData.title,
        description: pollData.description,
        visibility,
        accessCode: pollData.visibility === 'Password Protected' ? pollData.password : null,
        allowAnonymous: pollData.allowAnonymous,
        linkedWorkspaceId: activeWorkspace?.id,
        options: pollData.options.filter(o => o.trim() !== '')
      };

      await api.votes.create(payload);
      setIsCreateOpen(false);
      loadPolls();
    } catch (err) {
      console.error(err);
    } finally {
      setIsSubmitting(false);
    }
  };

  const getStatusBadge = (status: string) => {
    switch(status) {
      case 'Active': return <span className="flex items-center gap-1.5 px-2.5 py-1 rounded-md text-[11px] font-bold bg-emerald-50 text-emerald-600 border border-emerald-200"><span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span> Active</span>;
      case 'Closed': return <span className="flex items-center gap-1.5 px-2.5 py-1 rounded-md text-[11px] font-bold bg-zinc-100 text-zinc-600 border border-zinc-200"><CheckCircle2 className="w-3 h-3" /> Closed</span>;
      case 'Scheduled': return <span className="flex items-center gap-1.5 px-2.5 py-1 rounded-md text-[11px] font-bold bg-blue-50 text-blue-600 border border-blue-200"><Clock className="w-3 h-3" /> Scheduled</span>;
      default: return <span className="flex items-center gap-1.5 px-2.5 py-1 rounded-md text-[11px] font-bold bg-amber-50 text-amber-600 border border-amber-200">Draft</span>;
    }
  };

  const activeAnalytics = polls.find(p => p.id === analyticsPollId);

  return (
    <div className="min-h-screen bg-transparent text-zinc-900 p-4 md:p-8 font-sans overflow-hidden relative">
      <div className="max-w-[1600px] mx-auto space-y-6">
        
        {/* Top Header */}
        <div className="flex flex-col md:flex-row md:items-end justify-between gap-6">
          <div>
            <h1 className="text-3xl font-extrabold text-zinc-900 tracking-tight">Poll Center</h1>
            <p className="text-zinc-500 mt-1 text-sm font-medium">Engage with your audience through interactive voting.</p>
          </div>
          <div className="flex gap-3">
            <button className="px-4 py-2 bg-white border border-zinc-200 text-zinc-700 font-semibold rounded-xl hover:bg-zinc-50 transition-colors shadow-sm flex items-center gap-2 text-sm">
              <Download className="w-4 h-4" /> Export All
            </button>
            <button 
              onClick={() => setIsCreateOpen(true)}
              className="px-5 py-2 bg-[#635BFF] text-white font-semibold rounded-xl hover:bg-[#5b54eb] transition-all shadow-sm flex items-center gap-2 text-sm"
            >
              <Plus className="w-4 h-4" /> Create Poll
            </button>
          </div>
        </div>

        {/* Statistics Cards */}
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
          <div className="p-4 border-b border-zinc-200 bg-zinc-50/50 flex flex-col sm:flex-row items-center justify-between gap-4">
            <div className="flex items-center gap-2 w-full sm:w-auto">
              <div className="relative flex-1 sm:w-72">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-zinc-400" />
                <input 
                  type="text" 
                  placeholder="Search polls by title or ID..."
                  className="w-full pl-9 pr-4 py-2 bg-white border border-zinc-200 rounded-lg text-sm focus:outline-none focus:border-[#635BFF] focus:ring-1 focus:ring-[#635BFF] transition-all"
                />
              </div>
              <button className="p-2 bg-white border border-zinc-200 rounded-lg text-zinc-500 hover:text-zinc-900 transition-colors">
                <Filter className="w-4 h-4" />
              </button>
            </div>
            
            <div className="flex items-center gap-2 text-sm text-zinc-500 font-medium w-full sm:w-auto justify-between sm:justify-end">
              {selectedPolls.size > 0 && (
                <span className="text-[#635BFF] bg-[#635BFF]/10 px-3 py-1 rounded-md">{selectedPolls.size} selected</span>
              )}
              <div className="flex items-center gap-2">
                <button className="px-3 py-1.5 border border-zinc-200 rounded-lg hover:bg-zinc-100 transition-colors flex items-center gap-2">
                  Bulk Actions <ChevronDown className="w-4 h-4" />
                </button>
              </div>
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
                             if (e.target.checked) setSelectedPolls(new Set(polls.map(p => p.id)));
                             else setSelectedPolls(new Set());
                           }} 
                           checked={selectedPolls.size === polls.length && polls.length > 0}/>
                  </th>
                  <th className="px-6 py-4">Title</th>
                  <th className="px-6 py-4">Category</th>
                  <th className="px-6 py-4">Visibility</th>
                  <th className="px-6 py-4">Status</th>
                  <th className="px-6 py-4">Votes</th>
                  <th className="px-6 py-4">Expires</th>
                  <th className="px-6 py-4 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-zinc-100">
                {polls.map((poll) => (
                  <tr key={poll.id} className="hover:bg-zinc-50/80 transition-colors group">
                    <td className="px-6 py-4">
                      <input type="checkbox" className="rounded border-zinc-300 text-[#635BFF] focus:ring-[#635BFF]" 
                             checked={selectedPolls.has(poll.id)}
                             onChange={(e) => {
                               const newSet = new Set(selectedPolls);
                               if (e.target.checked) newSet.add(poll.id); else newSet.delete(poll.id);
                               setSelectedPolls(newSet);
                             }}/>
                    </td>
                    <td className="px-6 py-4 font-bold text-zinc-900 max-w-[300px] truncate">{poll.title}</td>
                    <td className="px-6 py-4 text-zinc-500 font-medium">{poll.category}</td>
                    <td className="px-6 py-4">
                      <span className="flex items-center gap-1.5 text-zinc-600 font-medium text-xs">
                        {poll.visibility === 'Public' ? <Globe className="w-3.5 h-3.5"/> : <Lock className="w-3.5 h-3.5"/>}
                        {poll.visibility}
                      </span>
                    </td>
                    <td className="px-6 py-4">{getStatusBadge(poll.status)}</td>
                    <td className="px-6 py-4 font-mono text-zinc-600">{poll.votes.toLocaleString()}</td>
                    <td className="px-6 py-4 text-zinc-500">{poll.expires}</td>
                    <td className="px-6 py-4 text-right">
                      <div className="flex items-center justify-end gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                        <button onClick={() => setAnalyticsPollId(poll.id)} className="p-1.5 text-indigo-500 hover:bg-indigo-50 rounded-md" title="Analytics">
                          <BarChart2 className="w-4 h-4" />
                        </button>
                        <button className="p-1.5 text-blue-500 hover:bg-blue-50 rounded-md" title="Edit">
                          <Edit className="w-4 h-4" />
                        </button>
                        <button className="p-1.5 text-rose-500 hover:bg-rose-50 rounded-md" title="Delete">
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
                {polls.length === 0 && (
                  <tr>
                    <td colSpan={8} className="px-6 py-12 text-center text-zinc-500">
                      No polls found. Click "Create Poll" to get started.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
          
          <div className="p-4 border-t border-zinc-200 bg-zinc-50 flex items-center justify-between text-xs text-zinc-500 font-medium">
            <span>Showing {polls.length} of {polls.length} results</span>
            <div className="flex gap-2">
              <button className="px-3 py-1 bg-white border border-zinc-200 rounded-md hover:bg-zinc-50" disabled>Previous</button>
              <button className="px-3 py-1 bg-white border border-zinc-200 rounded-md hover:bg-zinc-50" disabled>Next</button>
            </div>
          </div>
        </div>
      </div>

      {/* Analytics Drawer */}
      <AnimatePresence>
        {analyticsPollId && activeAnalytics && (
          <>
            <motion.div 
              initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
              onClick={() => setAnalyticsPollId(null)}
              className="fixed inset-0 bg-black/40 backdrop-blur-sm z-40"
            />
            <motion.div 
              initial={{ x: '100%', boxShadow: '0 0 0 rgba(0,0,0,0)' }} 
              animate={{ x: 0, boxShadow: '-10px 0 30px rgba(0,0,0,0.1)' }} 
              exit={{ x: '100%' }}
              transition={{ type: 'spring', damping: 25, stiffness: 200 }}
              className="fixed top-0 right-0 bottom-0 w-full max-w-2xl bg-white border-l border-zinc-200 z-50 flex flex-col overflow-hidden"
            >
              <div className="p-6 border-b border-zinc-100 flex items-center justify-between bg-white shrink-0">
                <div>
                  <h2 className="text-xl font-bold text-zinc-900 leading-tight pr-8">{activeAnalytics.title}</h2>
                  <p className="text-xs text-zinc-500 mt-1 font-medium">Poll Analytics & Insights</p>
                </div>
                <button onClick={() => setAnalyticsPollId(null)} className="p-2 bg-zinc-50 hover:bg-zinc-100 rounded-full text-zinc-500 transition-colors">
                  <X className="w-5 h-5" />
                </button>
              </div>

              <div className="flex-1 overflow-y-auto p-6 space-y-8 bg-zinc-50/30">
                {/* Metric Strip */}
                <div className="grid grid-cols-3 gap-4">
                  <div className="bg-white p-4 rounded-xl border border-zinc-200 shadow-sm">
                    <p className="text-xs font-bold text-zinc-500 uppercase">Total Votes</p>
                    <p className="text-2xl font-black text-[#635BFF] mt-1">{activeAnalytics.votes}</p>
                  </div>
                  <div className="bg-white p-4 rounded-xl border border-zinc-200 shadow-sm">
                    <p className="text-xs font-bold text-zinc-500 uppercase">Participation</p>
                    <p className="text-2xl font-black text-emerald-500 mt-1">42%</p>
                  </div>
                  <div className="bg-white p-4 rounded-xl border border-zinc-200 shadow-sm">
                    <p className="text-xs font-bold text-zinc-500 uppercase">Shares</p>
                    <p className="text-2xl font-black text-amber-500 mt-1">1,024</p>
                  </div>
                </div>

                {/* Vote Distribution */}
                <div className="bg-white border border-zinc-200 rounded-xl p-5 shadow-sm space-y-4">
                  <h3 className="text-sm font-bold text-zinc-900 uppercase tracking-wider border-b border-zinc-100 pb-2">Vote Distribution</h3>
                  <div className="space-y-4 pt-2">
                    {activeAnalytics.raw.options?.map((opt: any, idx: number) => {
                      const total = activeAnalytics.votes || 1;
                      const percentage = Math.round(((opt.voteCount || 0) / total) * 100);
                      return (
                        <div key={idx}>
                          <div className="flex justify-between items-end mb-1 text-sm">
                            <span className="font-bold text-zinc-800">{opt.title}</span>
                            <span className="font-mono text-zinc-500 text-xs">{opt.voteCount || 0} ({percentage}%)</span>
                          </div>
                          <div className="h-2.5 w-full bg-zinc-100 rounded-full overflow-hidden">
                            <motion.div 
                              initial={{ width: 0 }} animate={{ width: `${percentage}%` }} transition={{ duration: 1, type: 'spring' }}
                              className="h-full bg-[#635BFF] rounded-full"
                            />
                          </div>
                        </div>
                      )
                    })}
                  </div>
                </div>

                {/* Engagement Timeline Chart */}
                <div className="bg-white border border-zinc-200 rounded-xl p-5 shadow-sm">
                  <h3 className="text-sm font-bold text-zinc-900 uppercase tracking-wider mb-6 border-b border-zinc-100 pb-2">Engagement Timeline</h3>
                  <div className="h-64">
                    <ResponsiveContainer width="100%" height="100%">
                      <AreaChart data={MOCK_TIME_DATA} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                        <defs>
                          <linearGradient id="colorVotes" x1="0" y1="0" x2="0" y2="1">
                            <stop offset="5%" stopColor="#635BFF" stopOpacity={0.3}/>
                            <stop offset="95%" stopColor="#635BFF" stopOpacity={0}/>
                          </linearGradient>
                        </defs>
                        <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e4e4e7" />
                        <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#71717a' }} dy={10} />
                        <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#71717a' }} />
                        <Tooltip contentStyle={{ borderRadius: '12px', border: '1px solid #e4e4e7', boxShadow: '0 4px 6px -1px rgba(0,0,0,0.1)' }} />
                        <Area type="monotone" dataKey="votes" stroke="#635BFF" strokeWidth={3} fillOpacity={1} fill="url(#colorVotes)" />
                      </AreaChart>
                    </ResponsiveContainer>
                  </div>
                </div>

                {/* Demographics / Device */}
                <div className="grid grid-cols-2 gap-4">
                  <div className="bg-white border border-zinc-200 rounded-xl p-5 shadow-sm">
                    <h3 className="text-sm font-bold text-zinc-900 uppercase tracking-wider mb-4 border-b border-zinc-100 pb-2">Device Stats</h3>
                    <div className="h-40 flex items-center justify-center">
                       <ResponsiveContainer width="100%" height="100%">
                         <PieChart>
                           <Pie data={MOCK_DEVICE_DATA} innerRadius={35} outerRadius={60} paddingAngle={5} dataKey="value">
                             {MOCK_DEVICE_DATA.map((entry, index) => <Cell key={`cell-${index}`} fill={entry.color} />)}
                           </Pie>
                           <Tooltip />
                         </PieChart>
                       </ResponsiveContainer>
                    </div>
                    <div className="flex justify-center gap-4 text-xs font-bold text-zinc-600 mt-2">
                      <span className="flex items-center gap-1"><Smartphone className="w-3 h-3 text-[#6366f1]"/> Mobile</span>
                      <span className="flex items-center gap-1"><Monitor className="w-3 h-3 text-[#8b5cf6]"/> Desktop</span>
                    </div>
                  </div>
                  <div className="bg-white border border-zinc-200 rounded-xl p-5 shadow-sm flex flex-col items-center justify-center text-center">
                    <Map className="w-8 h-8 text-indigo-200 mb-2" />
                    <h3 className="text-sm font-bold text-zinc-900 mb-1">Location Data</h3>
                    <p className="text-xs text-zinc-500 font-medium">Export raw data to view geographical vote distribution.</p>
                    <button className="mt-4 px-4 py-2 bg-zinc-100 text-zinc-700 text-xs font-bold rounded-lg hover:bg-zinc-200 transition-colors">Export CSV</button>
                  </div>
                </div>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>

      {/* Create Poll Modal (Enterprise Multi-step) */}
      <AnimatePresence>
        {isCreateOpen && (
          <>
            <motion.div 
              initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
              onClick={() => setIsCreateOpen(false)}
              className="fixed inset-0 bg-zinc-900/40 backdrop-blur-sm z-40"
            />
            <motion.div 
              initial={{ opacity: 0, scale: 0.95, y: 20 }} animate={{ opacity: 1, scale: 1, y: 0 }} exit={{ opacity: 0, scale: 0.95, y: 20 }}
              className="fixed top-[5%] left-1/2 -translate-x-1/2 w-full max-w-4xl max-h-[90vh] bg-white rounded-2xl shadow-2xl z-50 flex flex-col overflow-hidden border border-zinc-200"
            >
              {/* Modal Header */}
              <div className="flex items-center justify-between p-5 border-b border-zinc-200 bg-zinc-50/50">
                <h2 className="text-lg font-bold text-zinc-900 flex items-center gap-2">
                  <BarChart2 className="w-5 h-5 text-[#635BFF]" /> Create New Poll
                </h2>
                <div className="flex items-center gap-2">
                  <button className="px-3 py-1.5 text-sm font-semibold text-zinc-500 hover:text-zinc-900 hover:bg-zinc-100 rounded-lg transition-colors">Save Draft</button>
                  <button onClick={() => setIsCreateOpen(false)} className="p-1.5 text-zinc-400 hover:text-zinc-900 hover:bg-zinc-100 rounded-lg transition-colors"><X className="w-5 h-5" /></button>
                </div>
              </div>

              <div className="flex flex-1 overflow-hidden">
                {/* Left Tabs */}
                <div className="w-56 bg-zinc-50 border-r border-zinc-200 p-4 space-y-1 overflow-y-auto shrink-0">
                  {['General', 'Questions', 'Visibility', 'Voting Rules', 'Advanced'].map(tab => (
                    <button 
                      key={tab}
                      onClick={() => setActiveTab(tab)}
                      className={`w-full text-left px-4 py-2.5 rounded-xl text-sm font-semibold transition-colors ${activeTab === tab ? 'bg-white text-[#635BFF] shadow-sm border border-zinc-200/50' : 'text-zinc-500 hover:text-zinc-900 hover:bg-zinc-100'}`}
                    >
                      {tab}
                    </button>
                  ))}
                </div>

                {/* Right Content Area */}
                <div className="flex-1 p-8 overflow-y-auto bg-white relative">
                  
                  {activeTab === 'General' && (
                    <motion.div initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} className="space-y-6 max-w-xl">
                      <div>
                        <label className="block text-sm font-bold text-zinc-700 mb-2">Internal Title</label>
                        <input type="text" placeholder="e.g., Q3 Product Feedback" value={pollData.title} onChange={e => setPollData({...pollData, title: e.target.value})} className="w-full px-4 py-2.5 bg-zinc-50 border border-zinc-200 rounded-xl text-sm focus:outline-none focus:border-[#635BFF] focus:ring-1 focus:ring-[#635BFF] transition-all font-medium text-zinc-900" />
                      </div>
                      <div>
                        <label className="block text-sm font-bold text-zinc-700 mb-2">Description / Context</label>
                        <textarea placeholder="Provide background info to the voters..." value={pollData.description} onChange={e => setPollData({...pollData, description: e.target.value})} className="w-full h-32 px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm focus:outline-none focus:border-[#635BFF] focus:ring-1 focus:ring-[#635BFF] transition-all resize-none text-zinc-900" />
                      </div>
                      <div>
                        <label className="block text-sm font-bold text-zinc-700 mb-2">Cover Image (Optional)</label>
                        <div className="w-full h-32 border-2 border-dashed border-zinc-300 rounded-xl flex flex-col items-center justify-center text-zinc-400 hover:bg-zinc-50 hover:border-[#635BFF] transition-all cursor-pointer">
                          <ImageIcon className="w-6 h-6 mb-2" />
                          <span className="text-xs font-semibold">Click to upload image</span>
                        </div>
                      </div>
                    </motion.div>
                  )}

                  {activeTab === 'Questions' && (
                    <motion.div initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} className="space-y-6 max-w-xl">
                       <div className="p-4 border border-zinc-200 rounded-xl bg-zinc-50 space-y-4 shadow-sm relative group">
                         <div className="absolute top-2 right-2 flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                           <button className="p-1.5 hover:bg-white rounded text-zinc-400 hover:text-zinc-900"><Copy className="w-4 h-4"/></button>
                           <button className="p-1.5 hover:bg-white rounded text-zinc-400 hover:text-red-500"><Trash2 className="w-4 h-4"/></button>
                         </div>
                         <div className="pr-16">
                            <label className="block text-xs font-bold text-zinc-500 uppercase tracking-wider mb-2">Question 1</label>
                            <input type="text" placeholder="What is your question?" value={pollData.title} onChange={e => setPollData({...pollData, title: e.target.value})} className="w-full bg-transparent text-lg font-bold text-zinc-900 placeholder:text-zinc-400 border-b border-zinc-300 focus:border-[#635BFF] outline-none pb-2 transition-colors" />
                         </div>
                         
                         <div className="space-y-3 pt-4">
                           {pollData.options.map((opt, idx) => (
                             <div key={idx} className="flex items-center gap-3">
                               <div className="w-5 h-5 rounded-full border-2 border-zinc-300 shrink-0"></div>
                               <input type="text" placeholder={`Option ${idx + 1}`} value={opt} onChange={(e) => { const newOpts = [...pollData.options]; newOpts[idx] = e.target.value; setPollData({...pollData, options: newOpts}); }} className="flex-1 bg-white border border-zinc-200 px-3 py-2 rounded-lg text-sm outline-none focus:border-[#635BFF]" />
                               {pollData.options.length > 2 && <button onClick={() => setPollData({...pollData, options: pollData.options.filter((_, i) => i !== idx)})} className="text-zinc-400 hover:text-red-500"><X className="w-4 h-4"/></button>}
                             </div>
                           ))}
                           <button onClick={() => setPollData({...pollData, options: [...pollData.options, '']})} className="text-sm font-bold text-[#635BFF] flex items-center gap-1 mt-2 hover:underline"><Plus className="w-4 h-4"/> Add Option</button>
                         </div>
                       </div>
                       
                       <button className="w-full py-3 border-2 border-dashed border-zinc-300 rounded-xl text-sm font-bold text-zinc-500 hover:border-[#635BFF] hover:text-[#635BFF] transition-colors flex items-center justify-center gap-2">
                         <Plus className="w-5 h-5"/> Add Another Question
                       </button>
                    </motion.div>
                  )}

                  {activeTab === 'Visibility' && (
                    <motion.div initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} className="space-y-6 max-w-xl">
                      <div className="grid grid-cols-1 gap-3">
                        {['Public', 'Followers Only', 'Workspace Members', 'Private', 'Password Protected'].map((mode) => (
                          <div key={mode} onClick={() => setPollData({...pollData, visibility: mode})} className={`p-4 border rounded-xl flex items-center gap-4 cursor-pointer transition-all ${pollData.visibility === mode ? 'border-[#635BFF] bg-[#635BFF]/5 ring-1 ring-[#635BFF]' : 'border-zinc-200 bg-white hover:border-zinc-300'}`}>
                            <div className={`w-5 h-5 rounded-full border-2 flex items-center justify-center shrink-0 ${pollData.visibility === mode ? 'border-[#635BFF]' : 'border-zinc-300'}`}>
                              {pollData.visibility === mode && <div className="w-2.5 h-2.5 bg-[#635BFF] rounded-full"></div>}
                            </div>
                            <div>
                              <p className={`text-sm font-bold ${pollData.visibility === mode ? 'text-[#635BFF]' : 'text-zinc-700'}`}>{mode}</p>
                              <p className="text-xs text-zinc-500 font-medium">Configure who can see and participate in this poll.</p>
                            </div>
                          </div>
                        ))}
                      </div>
                      
                      <AnimatePresence>
                        {pollData.visibility === 'Password Protected' && (
                          <motion.div initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: 'auto' }} exit={{ opacity: 0, height: 0 }}>
                            <label className="block text-sm font-bold text-zinc-700 mb-2">Access Password</label>
                            <input type="text" placeholder="Enter secure password" value={pollData.password} onChange={e => setPollData({...pollData, password: e.target.value})} className="w-full px-4 py-2.5 bg-zinc-50 border border-zinc-200 rounded-xl text-sm focus:outline-none focus:border-[#635BFF] focus:ring-1 focus:ring-[#635BFF]" />
                          </motion.div>
                        )}
                      </AnimatePresence>
                    </motion.div>
                  )}

                  {(activeTab === 'Voting Rules' || activeTab === 'Advanced') && (
                    <motion.div initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} className="space-y-6 max-w-xl">
                      <p className="text-sm text-zinc-500 font-medium bg-blue-50 text-blue-600 p-4 rounded-xl border border-blue-100 flex items-start gap-3">
                        <Sparkles className="w-5 h-5 shrink-0" /> Enterprise controls for precise engagement modeling. Ensure you understand the impact of modifying these settings.
                      </p>
                      
                      <div className="space-y-4">
                        <label className="flex items-center justify-between p-4 border border-zinc-200 rounded-xl bg-white cursor-pointer hover:bg-zinc-50 transition-colors">
                          <div>
                            <p className="text-sm font-bold text-zinc-900">One Vote Per User</p>
                            <p className="text-xs text-zinc-500 font-medium">Prevent multiple submissions via cookies and IP tracking.</p>
                          </div>
                          <div className={`w-11 h-6 rounded-full flex items-center px-1 transition-colors ${pollData.oneVotePerUser ? 'bg-[#635BFF]' : 'bg-zinc-300'}`} onClick={() => setPollData({...pollData, oneVotePerUser: !pollData.oneVotePerUser})}>
                            <motion.div animate={{ x: pollData.oneVotePerUser ? 20 : 0 }} className="w-4 h-4 bg-white rounded-full shadow-sm" />
                          </div>
                        </label>
                        
                        <label className="flex items-center justify-between p-4 border border-zinc-200 rounded-xl bg-white cursor-pointer hover:bg-zinc-50 transition-colors">
                          <div>
                            <p className="text-sm font-bold text-zinc-900">Allow Anonymous</p>
                            <p className="text-xs text-zinc-500 font-medium">Users do not need a ResultHub account to vote.</p>
                          </div>
                          <div className={`w-11 h-6 rounded-full flex items-center px-1 transition-colors ${pollData.allowAnonymous ? 'bg-[#635BFF]' : 'bg-zinc-300'}`} onClick={() => setPollData({...pollData, allowAnonymous: !pollData.allowAnonymous})}>
                            <motion.div animate={{ x: pollData.allowAnonymous ? 20 : 0 }} className="w-4 h-4 bg-white rounded-full shadow-sm" />
                          </div>
                        </label>
                      </div>
                    </motion.div>
                  )}
                  
                </div>
              </div>

              {/* Modal Footer */}
              <div className="p-5 border-t border-zinc-200 bg-white flex justify-between items-center shrink-0">
                <button onClick={() => setIsCreateOpen(false)} className="px-5 py-2.5 text-sm font-bold text-zinc-600 hover:text-zinc-900 transition-colors">Cancel</button>
                <button 
                  onClick={handleLaunchPoll} 
                  disabled={isSubmitting || !pollData.title}
                  className="px-6 py-2.5 bg-[#635BFF] text-white text-sm font-bold rounded-xl hover:bg-[#5b54eb] shadow-md shadow-[#635BFF]/20 transition-all flex items-center gap-2 disabled:opacity-50"
                >
                  {isSubmitting && <BarChart2 className="w-4 h-4 animate-spin" />}
                  Launch Poll
                </button>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>

    </div>
  );
}

const Monitor = ({ className }: { className?: string }) => (
  <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className={className}><rect width="20" height="14" x="2" y="3" rx="2"/><line x1="8" x2="16" y1="21" y2="21"/><line x1="12" x2="12" y1="17" y2="21"/></svg>
);
