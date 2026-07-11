"use client";

import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Megaphone, Plus, Search, Filter, Download, MoreVertical, 
  BarChart2, Users, Eye, Target, Share2, MessageSquare, 
  Settings, Link as LinkIcon, Send, X, Clock, CheckCircle2, Check,
  Image as ImageIcon, Type, Video, LayoutTemplate, Smartphone, Mail, BellRing, MousePointerClick
} from 'lucide-react';
import { 
  AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, BarChart, Bar
} from 'recharts';
import { api } from '@/lib/api';

const MOCK_REACH_DATA = [
  { name: 'Day 1', reach: 4000, engagement: 2400 },
  { name: 'Day 2', reach: 3000, engagement: 1398 },
  { name: 'Day 3', reach: 2000, engagement: 9800 },
  { name: 'Day 4', reach: 2780, engagement: 3908 },
  { name: 'Day 5', reach: 1890, engagement: 4800 },
  { name: 'Day 6', reach: 2390, engagement: 3800 },
  { name: 'Day 7', reach: 3490, engagement: 4300 },
];

export default function AnnouncementsPage() {
  const [announcements, setAnnouncements] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [selectedRowIds, setSelectedRowIds] = useState<Set<string>>(new Set());
  
  const [activeWorkspace, setActiveWorkspace] = useState<any>(null);
  
  useEffect(() => {
    const ws = localStorage.getItem('activeWorkspace');
    if (ws) {
      setActiveWorkspace(JSON.parse(ws));
    }
  }, []);
  
  // Modals
  const [isCreateOpen, setIsCreateOpen] = useState(false);
  const [analyticsPostId, setAnalyticsPostId] = useState<string | null>(null);

  // Composer State
  const [composerTab, setComposerTab] = useState('Content');
  const [formData, setFormData] = useState({
    title: '', subtitle: '', content: '',
    audience: 'Everyone',
    notifications: { push: true, email: false, sms: false, inApp: true }
  });
  const [isSubmitting, setIsSubmitting] = useState(false);

  const loadAnnouncements = async () => {
    try {
      if (!activeWorkspace?.id) return;
      setIsLoading(true);
      const res = await api.posts.getWorkspacePosts(activeWorkspace.id);
      if (res && res.content) {
        setAnnouncements(res.content.map((p: any) => ({
          ...p,
          status: p.visibility === 'PRIVATE' ? 'Draft' : 'Published',
          views: Math.floor(Math.random() * 5000) + 100, // Mock views
          ctr: (Math.random() * 15 + 1).toFixed(1) + '%'  // Mock CTR
        })));
      }
    } catch (error) {
      console.error(error);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadAnnouncements();
  }, [activeWorkspace?.id]);

  const stats = React.useMemo(() => {
    const published = announcements.filter(a => a.status === 'Published').length;
    const scheduled = announcements.filter(a => a.status === 'Scheduled').length;
    const drafts = announcements.filter(a => a.status === 'Draft').length;
    const totalViews = announcements.reduce((acc, curr) => acc + (curr.views || 0), 0);
    
    return [
      { label: 'Published', value: published.toString(), trend: 'Live', color: 'text-emerald-500' },
      { label: 'Scheduled', value: scheduled.toString(), trend: 'Upcoming', color: 'text-blue-500' },
      { label: 'Drafts', value: drafts.toString(), trend: 'Pending', color: 'text-zinc-500' },
      { label: 'Total Views', value: totalViews.toLocaleString(), trend: 'All Time', color: 'text-purple-500' },
      { label: 'Total Reach', value: Math.floor(totalViews * 0.8).toLocaleString(), trend: 'Est', color: 'text-amber-500' },
      { label: 'Total Posts', value: announcements.length.toString(), trend: 'All', color: 'text-[#635BFF]' }
    ];
  }, [announcements]);

  const handlePublish = async () => {
    setIsSubmitting(true);
    try {
      const form = new FormData();
      const payload = {
        text: formData.title ? `**${formData.title}**\n\n${formData.content}` : formData.content,
        postType: 'UPDATE',
        workspaceId: activeWorkspace?.id
      };
      
      form.append('data', new Blob([JSON.stringify(payload)], { type: 'application/json' }));
      
      await api.posts.create(form);
      setIsCreateOpen(false);
      loadAnnouncements();
    } catch (error) {
      console.error(error);
    } finally {
      setIsSubmitting(false);
    }
  };

  const getStatusBadge = (status: string) => {
    switch(status) {
      case 'Published': return <span className="flex items-center gap-1.5 px-2.5 py-1 rounded-md text-[11px] font-bold bg-emerald-50 text-emerald-600 border border-emerald-200"><CheckCircle2 className="w-3 h-3" /> Published</span>;
      case 'Scheduled': return <span className="flex items-center gap-1.5 px-2.5 py-1 rounded-md text-[11px] font-bold bg-blue-50 text-blue-600 border border-blue-200"><Clock className="w-3 h-3" /> Scheduled</span>;
      default: return <span className="flex items-center gap-1.5 px-2.5 py-1 rounded-md text-[11px] font-bold bg-zinc-100 text-zinc-600 border border-zinc-200">Draft</span>;
    }
  };

  const activeAnalytics = announcements.find(a => a.id === analyticsPostId);

  return (
    <div className="min-h-screen bg-transparent text-zinc-900 p-4 md:p-8 font-sans overflow-hidden relative">
      <div className="max-w-[1600px] mx-auto space-y-6">
        
        {/* Header */}
        <div className="flex flex-col md:flex-row md:items-end justify-between gap-6">
          <div>
            <h1 className="text-3xl font-extrabold text-zinc-900 tracking-tight">Announcement Center</h1>
            <p className="text-zinc-500 mt-1 text-sm font-medium">Publish official updates to followers and users.</p>
          </div>
          <div className="flex gap-3">
            <button className="px-4 py-2 bg-white border border-zinc-200 text-zinc-700 font-semibold rounded-xl hover:bg-zinc-50 transition-colors shadow-sm flex items-center gap-2 text-sm">
              <Download className="w-4 h-4" /> Export
            </button>
            <button 
              onClick={() => setIsCreateOpen(true)}
              className="px-5 py-2 bg-[#635BFF] text-white font-semibold rounded-xl hover:bg-[#5b54eb] transition-all shadow-sm flex items-center gap-2 text-sm"
            >
              <Plus className="w-4 h-4" /> Create Announcement
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
          
          <div className="p-4 border-b border-zinc-200 bg-zinc-50/50 flex flex-col sm:flex-row items-center justify-between gap-4">
            <div className="flex items-center gap-2 w-full sm:w-auto">
              <div className="relative flex-1 sm:w-80">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-zinc-400" />
                <input 
                  type="text" placeholder="Search announcements..."
                  className="w-full pl-9 pr-4 py-2 bg-white border border-zinc-200 rounded-lg text-sm focus:outline-none focus:border-[#635BFF] focus:ring-1 focus:ring-[#635BFF]"
                />
              </div>
              <button className="p-2 bg-white border border-zinc-200 rounded-lg text-zinc-500 hover:text-zinc-900">
                <Filter className="w-4 h-4" />
              </button>
            </div>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm">
              <thead className="bg-zinc-50 border-b border-zinc-200 text-zinc-500 font-bold uppercase tracking-wider text-[10px]">
                <tr>
                  <th className="px-6 py-4 w-10">
                    <input type="checkbox" className="rounded border-zinc-300 text-[#635BFF] focus:ring-[#635BFF]" 
                           onChange={(e) => {
                             if (e.target.checked) setSelectedRowIds(new Set(announcements.map(p => p.id)));
                             else setSelectedRowIds(new Set());
                           }} 
                           checked={selectedRowIds.size === announcements.length && announcements.length > 0}/>
                  </th>
                  <th className="px-6 py-4 min-w-[300px]">Title</th>
                  <th className="px-6 py-4">Audience</th>
                  <th className="px-6 py-4">Status</th>
                  <th className="px-6 py-4">Published</th>
                  <th className="px-6 py-4">Views</th>
                  <th className="px-6 py-4">CTR</th>
                  <th className="px-6 py-4 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-zinc-100">
                {announcements.map((post) => (
                  <tr key={post.id} className="hover:bg-zinc-50/80 transition-colors group">
                    <td className="px-6 py-4">
                      <input type="checkbox" className="rounded border-zinc-300 text-[#635BFF]" 
                             checked={selectedRowIds.has(post.id)}
                             onChange={(e) => {
                               const newSet = new Set(selectedRowIds);
                               if (e.target.checked) newSet.add(post.id); else newSet.delete(post.id);
                               setSelectedRowIds(newSet);
                             }}/>
                    </td>
                    <td className="px-6 py-4">
                      <div className="font-bold text-zinc-900 truncate max-w-[300px]">{post.title || "Untitled Broadcast"}</div>
                      <div className="text-xs text-zinc-500 truncate max-w-[300px] mt-0.5">{post.content.substring(0,60)}...</div>
                    </td>
                    <td className="px-6 py-4 text-zinc-600 font-medium text-xs flex items-center gap-1.5"><Globe className="w-3.5 h-3.5"/> Everyone</td>
                    <td className="px-6 py-4">{getStatusBadge(post.status)}</td>
                    <td className="px-6 py-4 text-zinc-500 text-xs">{new Date(post.createdAt).toLocaleDateString()}</td>
                    <td className="px-6 py-4 font-mono text-zinc-600">{post.views.toLocaleString()}</td>
                    <td className="px-6 py-4 font-mono text-emerald-600 font-bold">{post.ctr}</td>
                    <td className="px-6 py-4 text-right">
                      <div className="flex items-center justify-end gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                        <button onClick={() => setAnalyticsPostId(post.id)} className="p-1.5 text-indigo-500 hover:bg-indigo-50 rounded-md" title="Analytics"><BarChart2 className="w-4 h-4" /></button>
                        <button className="p-1.5 text-zinc-500 hover:bg-zinc-100 rounded-md"><MoreVertical className="w-4 h-4" /></button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          
        </div>
      </div>

      {/* Analytics Drawer */}
      <AnimatePresence>
        {analyticsPostId && activeAnalytics && (
          <>
            <motion.div 
              initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
              onClick={() => setAnalyticsPostId(null)} className="fixed inset-0 bg-black/40 backdrop-blur-sm z-40"
            />
            <motion.div 
              initial={{ x: '100%' }} animate={{ x: 0 }} exit={{ x: '100%' }}
              transition={{ type: 'spring', damping: 25, stiffness: 200 }}
              className="fixed top-0 right-0 bottom-0 w-full max-w-[800px] bg-white border-l border-zinc-200 z-50 flex flex-col overflow-hidden shadow-2xl"
            >
              <div className="p-6 border-b border-zinc-100 flex justify-between items-center bg-white shrink-0">
                <div>
                  <h2 className="text-xl font-bold text-zinc-900 leading-tight">{activeAnalytics.title || "Untitled Broadcast"}</h2>
                  <p className="text-xs text-zinc-500 mt-1 font-medium flex items-center gap-2">
                    <Calendar className="w-3.5 h-3.5"/> Published: {new Date(activeAnalytics.createdAt).toLocaleDateString()}
                  </p>
                </div>
                <button onClick={() => setAnalyticsPostId(null)} className="p-2 bg-zinc-50 hover:bg-zinc-100 rounded-full text-zinc-500 transition-colors"><X className="w-5 h-5" /></button>
              </div>

              <div className="flex-1 overflow-y-auto p-6 space-y-6 bg-zinc-50/50">
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                  {[
                    { l: 'Total Views', v: activeAnalytics.views.toLocaleString(), i: Eye, c: 'text-blue-500' },
                    { l: 'Engagements', v: (activeAnalytics.upvotesCount || 0) + (activeAnalytics.commentsCount || 0), i: Target, c: 'text-[#635BFF]' },
                    { l: 'Shares', v: '142', i: Share2, c: 'text-emerald-500' },
                    { l: 'CTR', v: activeAnalytics.ctr, i: MousePointerClick, c: 'text-amber-500' }
                  ].map((s, idx) => (
                    <div key={idx} className="bg-white p-4 rounded-xl border border-zinc-200 shadow-sm">
                      <div className="flex items-center gap-2 text-zinc-500 mb-2"><s.i className="w-4 h-4"/> <span className="text-[10px] font-bold uppercase">{s.l}</span></div>
                      <p className={`text-2xl font-black ${s.c}`}>{s.v}</p>
                    </div>
                  ))}
                </div>

                <div className="bg-white border border-zinc-200 rounded-xl p-5 shadow-sm">
                  <h3 className="text-sm font-bold text-zinc-900 uppercase tracking-wider mb-6 border-b border-zinc-100 pb-2">Reach vs Engagement (7 Days)</h3>
                  <div className="h-72">
                    <ResponsiveContainer width="100%" height="100%">
                      <AreaChart data={MOCK_REACH_DATA} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                        <defs>
                          <linearGradient id="colorReach" x1="0" y1="0" x2="0" y2="1"><stop offset="5%" stopColor="#3b82f6" stopOpacity={0.3}/><stop offset="95%" stopColor="#3b82f6" stopOpacity={0}/></linearGradient>
                          <linearGradient id="colorEngage" x1="0" y1="0" x2="0" y2="1"><stop offset="5%" stopColor="#635BFF" stopOpacity={0.3}/><stop offset="95%" stopColor="#635BFF" stopOpacity={0}/></linearGradient>
                        </defs>
                        <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e4e4e7" />
                        <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#71717a' }} dy={10} />
                        <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#71717a' }} />
                        <Tooltip contentStyle={{ borderRadius: '12px', border: '1px solid #e4e4e7' }} />
                        <Area type="monotone" dataKey="reach" stroke="#3b82f6" strokeWidth={3} fillOpacity={1} fill="url(#colorReach)" />
                        <Area type="monotone" dataKey="engagement" stroke="#635BFF" strokeWidth={3} fillOpacity={1} fill="url(#colorEngage)" />
                      </AreaChart>
                    </ResponsiveContainer>
                  </div>
                </div>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>

      {/* Composer Modal */}
      <AnimatePresence>
        {isCreateOpen && (
          <>
            <motion.div 
              initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
              onClick={() => setIsCreateOpen(false)} className="fixed inset-0 bg-zinc-900/60 backdrop-blur-sm z-40"
            />
            <motion.div 
              initial={{ y: '100%', opacity: 0, scale: 0.95 }} animate={{ y: 0, opacity: 1, scale: 1 }} exit={{ y: '100%', opacity: 0, scale: 0.95 }}
              transition={{ type: 'spring', damping: 25, stiffness: 200 }}
              className="fixed bottom-0 left-1/2 -translate-x-1/2 w-full max-w-5xl h-[85vh] bg-white rounded-t-3xl z-50 flex flex-col shadow-2xl overflow-hidden border-t border-zinc-200"
            >
              <div className="flex items-center justify-between p-5 border-b border-zinc-200 bg-zinc-50/50">
                <h2 className="text-lg font-bold text-zinc-900 flex items-center gap-2">
                  <Megaphone className="w-5 h-5 text-[#635BFF]" /> Create Announcement
                </h2>
                <div className="flex items-center gap-3">
                  <button className="px-4 py-1.5 text-sm font-semibold text-zinc-500 hover:text-zinc-900 hover:bg-zinc-100 rounded-lg">Save Draft</button>
                  <button onClick={() => setIsCreateOpen(false)} className="p-1.5 text-zinc-400 hover:text-zinc-900 hover:bg-zinc-100 rounded-lg"><X className="w-5 h-5"/></button>
                </div>
              </div>

              <div className="flex flex-1 overflow-hidden">
                <div className="w-56 bg-zinc-50 border-r border-zinc-200 p-4 space-y-1 overflow-y-auto shrink-0">
                  {['Content', 'Audience', 'Publishing', 'Notifications'].map(tab => (
                    <button key={tab} onClick={() => setComposerTab(tab)} className={`w-full text-left px-4 py-3 rounded-xl text-sm font-semibold transition-colors ${composerTab === tab ? 'bg-white text-[#635BFF] shadow-sm border border-zinc-200/50' : 'text-zinc-500 hover:text-zinc-900 hover:bg-zinc-100'}`}>
                      {tab}
                    </button>
                  ))}
                </div>

                <div className="flex-1 p-8 overflow-y-auto bg-white">
                  {composerTab === 'Content' && (
                    <motion.div initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} className="space-y-6 max-w-2xl">
                      <div>
                        <input type="text" placeholder="Announcement Title" value={formData.title} onChange={e => setFormData({...formData, title: e.target.value})} className="w-full text-3xl font-extrabold bg-transparent border-none text-zinc-900 placeholder-zinc-300 focus:outline-none mb-2" />
                        <input type="text" placeholder="Subtitle (Optional)" value={formData.subtitle} onChange={e => setFormData({...formData, subtitle: e.target.value})} className="w-full text-lg font-medium bg-transparent border-none text-zinc-500 placeholder-zinc-300 focus:outline-none mb-6" />
                      </div>

                      <div className="border border-zinc-200 rounded-xl overflow-hidden shadow-sm">
                        <div className="bg-zinc-50 border-b border-zinc-200 p-2 flex items-center gap-1 overflow-x-auto hide-scrollbar">
                           <button className="p-1.5 hover:bg-zinc-200 rounded text-zinc-600"><Type className="w-4 h-4"/></button>
                           <button className="p-1.5 hover:bg-zinc-200 rounded text-zinc-600"><ImageIcon className="w-4 h-4"/></button>
                           <button className="p-1.5 hover:bg-zinc-200 rounded text-zinc-600"><Video className="w-4 h-4"/></button>
                           <button className="p-1.5 hover:bg-zinc-200 rounded text-zinc-600"><LinkIcon className="w-4 h-4"/></button>
                           <div className="w-px h-4 bg-zinc-300 mx-2"></div>
                           <button className="p-1.5 hover:bg-zinc-200 rounded text-zinc-600"><LayoutTemplate className="w-4 h-4"/></button>
                        </div>
                        <textarea placeholder="Write your announcement content here..." value={formData.content} onChange={e => setFormData({...formData, content: e.target.value})} className="w-full h-80 p-4 bg-white focus:outline-none resize-none text-zinc-700 leading-relaxed font-medium" />
                      </div>
                    </motion.div>
                  )}

                  {composerTab === 'Audience' && (
                    <motion.div initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} className="space-y-4 max-w-xl">
                      <h3 className="text-sm font-bold text-zinc-900 uppercase tracking-wider mb-4 border-b border-zinc-100 pb-2">Target Audience</h3>
                      {['Everyone', 'Followers Only', 'Workspace Members', 'Specific Region'].map(aud => (
                        <label key={aud} onClick={() => setFormData({...formData, audience: aud})} className={`flex items-center justify-between p-4 border rounded-xl bg-white cursor-pointer transition-all ${formData.audience === aud ? 'border-[#635BFF] bg-[#635BFF]/5 ring-1 ring-[#635BFF]' : 'border-zinc-200 hover:border-zinc-300'}`}>
                          <span className={`text-sm font-bold ${formData.audience === aud ? 'text-[#635BFF]' : 'text-zinc-700'}`}>{aud}</span>
                          <div className={`w-5 h-5 rounded-full border-2 flex items-center justify-center ${formData.audience === aud ? 'border-[#635BFF]' : 'border-zinc-300'}`}>
                            {formData.audience === aud && <div className="w-2.5 h-2.5 bg-[#635BFF] rounded-full"></div>}
                          </div>
                        </label>
                      ))}
                    </motion.div>
                  )}

                  {composerTab === 'Notifications' && (
                    <motion.div initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} className="space-y-4 max-w-xl">
                      <h3 className="text-sm font-bold text-zinc-900 uppercase tracking-wider mb-4 border-b border-zinc-100 pb-2">Broadcast Channels</h3>
                      <label className="flex items-center justify-between p-4 border border-zinc-200 rounded-xl bg-white cursor-pointer hover:bg-zinc-50 transition-colors">
                        <div className="flex items-center gap-3">
                           <div className="w-8 h-8 rounded-full bg-blue-50 text-blue-500 flex items-center justify-center"><BellRing className="w-4 h-4"/></div>
                           <div>
                             <p className="text-sm font-bold text-zinc-900">In-App Notification</p>
                             <p className="text-xs text-zinc-500 font-medium">Standard push to notification center.</p>
                           </div>
                        </div>
                        <div className={`w-11 h-6 rounded-full flex items-center px-1 transition-colors ${formData.notifications.inApp ? 'bg-[#635BFF]' : 'bg-zinc-300'}`} onClick={() => setFormData({...formData, notifications: {...formData.notifications, inApp: !formData.notifications.inApp}})}>
                          <motion.div animate={{ x: formData.notifications.inApp ? 20 : 0 }} className="w-4 h-4 bg-white rounded-full shadow-sm" />
                        </div>
                      </label>
                      
                      <label className="flex items-center justify-between p-4 border border-zinc-200 rounded-xl bg-white cursor-pointer hover:bg-zinc-50 transition-colors">
                        <div className="flex items-center gap-3">
                           <div className="w-8 h-8 rounded-full bg-emerald-50 text-emerald-500 flex items-center justify-center"><Smartphone className="w-4 h-4"/></div>
                           <div>
                             <p className="text-sm font-bold text-zinc-900">Push Notification (Mobile)</p>
                             <p className="text-xs text-zinc-500 font-medium">Send native push to installed devices.</p>
                           </div>
                        </div>
                        <div className={`w-11 h-6 rounded-full flex items-center px-1 transition-colors ${formData.notifications.push ? 'bg-[#635BFF]' : 'bg-zinc-300'}`} onClick={() => setFormData({...formData, notifications: {...formData.notifications, push: !formData.notifications.push}})}>
                          <motion.div animate={{ x: formData.notifications.push ? 20 : 0 }} className="w-4 h-4 bg-white rounded-full shadow-sm" />
                        </div>
                      </label>

                      <label className="flex items-center justify-between p-4 border border-zinc-200 rounded-xl bg-white cursor-pointer hover:bg-zinc-50 transition-colors">
                        <div className="flex items-center gap-3">
                           <div className="w-8 h-8 rounded-full bg-amber-50 text-amber-500 flex items-center justify-center"><Mail className="w-4 h-4"/></div>
                           <div>
                             <p className="text-sm font-bold text-zinc-900">Email Blast</p>
                             <p className="text-xs text-zinc-500 font-medium">Send full HTML email to audience.</p>
                           </div>
                        </div>
                        <div className={`w-11 h-6 rounded-full flex items-center px-1 transition-colors ${formData.notifications.email ? 'bg-[#635BFF]' : 'bg-zinc-300'}`} onClick={() => setFormData({...formData, notifications: {...formData.notifications, email: !formData.notifications.email}})}>
                          <motion.div animate={{ x: formData.notifications.email ? 20 : 0 }} className="w-4 h-4 bg-white rounded-full shadow-sm" />
                        </div>
                      </label>
                    </motion.div>
                  )}
                </div>
              </div>

              <div className="p-5 border-t border-zinc-200 bg-white flex justify-between items-center shrink-0">
                <button onClick={() => setIsCreateOpen(false)} className="px-5 py-2.5 text-sm font-bold text-zinc-600 hover:text-zinc-900 transition-colors">Discard</button>
                <button 
                  onClick={handlePublish} 
                  disabled={isSubmitting || !formData.content}
                  className="px-8 py-3 bg-[#635BFF] text-white text-sm font-bold rounded-xl hover:bg-[#5b54eb] shadow-md shadow-[#635BFF]/20 transition-all flex items-center gap-2 disabled:opacity-50"
                >
                  {isSubmitting ? <span className="w-4 h-4 border-2 border-white/20 border-t-white rounded-full animate-spin" /> : <Send className="w-4 h-4" />}
                  Publish Broadcast
                </button>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </div>
  );
}

const Calendar = ({ className }: { className?: string }) => (
  <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className={className}><rect width="18" height="18" x="3" y="4" rx="2" ry="2"/><line x1="16" x2="16" y1="2" y2="6"/><line x1="8" x2="8" y1="2" y2="6"/><line x1="3" x2="21" y1="10" y2="10"/></svg>
);
const Globe = ({ className }: { className?: string }) => (
  <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className={className}><circle cx="12" cy="12" r="10"/><line x1="2" x2="22" y1="12" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
);
