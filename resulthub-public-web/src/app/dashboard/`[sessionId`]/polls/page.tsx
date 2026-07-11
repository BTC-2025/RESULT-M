"use client";

import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  BarChart2, 
  Plus, 
  Calendar, 
  Lock, 
  Globe, 
  Users, 
  Clock, 
  CheckCircle2, 
  X, 
  Trash2, 
  ShieldAlert, 
  ArrowRight, 
  Activity, 
  Percent,
  MoreHorizontal
} from 'lucide-react';

import { api } from '@/lib/api';

const DEFAULT_POLLS = [
  {
    id: 'P-01',
    question: 'Should the library extend its opening hours to midnight during finals week?',
    status: 'Active',
    privacy: 'Public',
    totalVotes: 1248,
    endDate: '2 days left',
    options: [
      { text: 'Yes, definitely', votes: 850, percentage: 68 },
      { text: 'No, current hours are fine', votes: 312, percentage: 25 },
      { text: 'Undecided', votes: 86, percentage: 7 },
    ]
  }
];

export default function PollsPage() {
  const [expandedPoll, setExpandedPoll] = useState<string | null>(null);
  const [isCreateOpen, setIsCreateOpen] = useState(false);
  const [pollOptions, setPollOptions] = useState(['', '']);
  const [privacyMode, setPrivacyMode] = useState('Public');
  const [polls, setPolls] = useState<any[]>(DEFAULT_POLLS);
  const [isLoading, setIsLoading] = useState(true);

  React.useEffect(() => {
    async function loadPolls() {
      try {
        const response = await api.votes.getVoteBoxes();
        if (response && response.content && response.content.length > 0) {
          const mapped = response.content.map((p: any) => {
            const total = p.options?.reduce((acc: number, curr: any) => acc + (curr.voteCount || 0), 0) || 0;
            return {
              id: `P-${p.id.substring(0, 4).toUpperCase()}`,
              question: p.title,
              status: p.isActive ? 'Active' : 'Ended',
              privacy: p.isPrivate ? 'Private' : 'Public',
              totalVotes: total,
              endDate: new Date(p.endDate).toLocaleDateString(),
              options: (p.options || []).map((opt: any) => ({
                text: opt.title,
                votes: opt.voteCount || 0,
                percentage: total > 0 ? Math.round(((opt.voteCount || 0) / total) * 100) : 0
              })).sort((a: any, b: any) => b.votes - a.votes)
            };
          });
          setPolls(mapped);
        }
      } catch (error) {
        console.error("Failed to load polls:", error);
      } finally {
        setIsLoading(false);
      }
    }
    loadPolls();
  }, []);

  const getStatusBadge = (status: string) => {
    switch(status) {
      case 'Active': return <span className="flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-bold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20"><Activity className="w-3 h-3" /> ACTIVE</span>;
      case 'Ended': return <span className="flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-bold bg-zinc-500/10 text-zinc-500 border border-zinc-500/20"><CheckCircle2 className="w-3 h-3" /> ENDED</span>;
      default: return <span className="flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-bold bg-amber-500/10 text-amber-400 border border-amber-500/20"><Clock className="w-3 h-3" /> DRAFT</span>;
    }
  };

  const getPrivacyIcon = (privacy: string) => {
    switch(privacy) {
      case 'Public': return <Globe className="w-3.5 h-3.5" />;
      case 'Password Protected': return <Lock className="w-3.5 h-3.5" />;
      case 'Private': return <ShieldAlert className="w-3.5 h-3.5" />;
      default: return <Globe className="w-3.5 h-3.5" />;
    }
  };

  return (
    <div className="min-h-screen bg-transparent text-zinc-900 p-4 md:p-8 font-sans selection:bg-purple-500/30 overflow-hidden relative">
      <div className="max-w-[1600px] mx-auto space-y-8">
        
        {/* Header */}
        <div className="flex flex-col md:flex-row md:items-end justify-between gap-6 relative z-10">
          <div>
            <motion.div 
              initial={{ opacity: 0, y: -10 }}
              animate={{ opacity: 1, y: 0 }}
              className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-indigo-500/10 border border-indigo-500/20 text-indigo-400 text-sm font-medium mb-4"
            >
              <BarChart2 className="w-4 h-4" />
              1,740 Total Votes Cast
            </motion.div>
            <motion.h1 
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              className="text-4xl md:text-5xl font-extrabold tracking-tight bg-clip-text text-transparent bg-gradient-to-r from-zinc-900 via-zinc-700 to-zinc-500"
            >
              Poll Center
            </motion.h1>
            <motion.p 
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.1 }}
              className="text-zinc-500 mt-2 text-lg max-w-2xl"
            >
              Engage your community, gather feedback, and monitor live voting results.
            </motion.p>
          </div>

          <motion.div 
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            className="flex gap-3"
          >
            <button 
              onClick={() => setIsCreateOpen(true)}
              className="group relative inline-flex items-center justify-center gap-2 px-6 py-3 font-semibold text-zinc-900 bg-gradient-to-b from-indigo-500 to-indigo-600 rounded-xl overflow-hidden transition-all hover:scale-105 hover:shadow-[0_0_40px_-10px_rgba(99,102,241,0.5)] active:scale-95 text-white">
              <div className="absolute inset-0 bg-white/20 translate-y-full group-hover:translate-y-0 transition-transform duration-300 ease-out" />
              <Plus className="w-5 h-5 relative z-10" />
              <span className="relative z-10">Create Poll</span>
            </button>
          </motion.div>
        </div>

        {/* Polls Grid */}
        <div className="grid grid-cols-1 gap-6">
          {polls.map((poll, i) => (
            <motion.div 
              key={poll.id}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.1 }}
              className={`bg-white/50 border border-zinc-200 rounded-3xl overflow-hidden backdrop-blur-xl transition-all ${expandedPoll === poll.id ? 'ring-1 ring-indigo-500/50 shadow-[0_0_30px_-10px_rgba(99,102,241,0.15)]' : 'hover:border-zinc-200'}`}
            >
              {/* Card Header (Always Visible) */}
              <div 
                className="p-6 md:p-8 cursor-pointer flex flex-col md:flex-row md:items-center justify-between gap-6"
                onClick={() => setExpandedPoll(expandedPoll === poll.id ? null : poll.id)}
              >
                <div className="flex-1 space-y-4">
                  <div className="flex flex-wrap items-center gap-3">
                    {getStatusBadge(poll.status)}
                    <span className="flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-bold bg-zinc-100 text-zinc-600 border border-zinc-200">
                      {getPrivacyIcon(poll.privacy)} {poll.privacy}
                    </span>
                    <span className="text-zinc-500 text-xs font-medium font-mono">{poll.id}</span>
                  </div>
                  <h3 className="text-xl md:text-2xl font-bold text-zinc-900 leading-tight">{poll.question}</h3>
                  <div className="flex flex-wrap items-center gap-4 text-sm font-medium text-zinc-500">
                    <span className="flex items-center gap-1.5"><Users className="w-4 h-4 text-indigo-400" /> {poll.totalVotes.toLocaleString()} Votes</span>
                    <span className="flex items-center gap-1.5"><Calendar className="w-4 h-4 text-zinc-500" /> {poll.endDate}</span>
                  </div>
                </div>

                <div className="shrink-0 flex items-center justify-between md:flex-col gap-4 border-t border-zinc-200 pt-4 md:pt-0 md:border-t-0 md:border-l md:pl-8">
                  <div className="text-left md:text-center">
                    <div className="text-sm font-bold text-zinc-500 uppercase tracking-wider mb-1">Leading Option</div>
                    <div className="text-indigo-400 font-bold truncate max-w-[150px]">{poll.options[0].text}</div>
                    <div className="text-2xl font-black text-zinc-900">{poll.options[0].percentage}%</div>
                  </div>
                  <button className="w-10 h-10 rounded-full bg-white border border-zinc-200 flex items-center justify-center text-zinc-500 hover:text-zinc-900 transition-colors">
                    <motion.div animate={{ rotate: expandedPoll === poll.id ? 90 : 0 }}>
                      <ArrowRight className="w-5 h-5" />
                    </motion.div>
                  </button>
                </div>
              </div>

              {/* Expanded Live Analytics Section */}
              <AnimatePresence>
                {expandedPoll === poll.id && (
                  <motion.div 
                    initial={{ height: 0, opacity: 0 }}
                    animate={{ height: 'auto', opacity: 1 }}
                    exit={{ height: 0, opacity: 0 }}
                    className="overflow-hidden border-t border-zinc-200 bg-white/30"
                  >
                    <div className="p-6 md:p-8 grid grid-cols-1 lg:grid-cols-3 gap-8">
                      
                      <div className="lg:col-span-2 space-y-6">
                        <div className="flex items-center justify-between mb-2">
                          <h4 className="text-sm font-bold text-zinc-900 uppercase tracking-wider flex items-center gap-2">
                            <Activity className="w-4 h-4 text-emerald-400" /> Live Results
                          </h4>
                          <span className="text-xs font-medium text-zinc-500">Auto-updating...</span>
                        </div>
                        
                        <div className="space-y-4">
                          {poll.options.map((opt: any, idx: number) => (
                            <div key={idx} className="relative">
                              <div className="flex justify-between items-end mb-2 text-sm">
                                <span className="font-bold text-zinc-800">{opt.text}</span>
                                <span className="font-mono text-zinc-500">{opt.votes} votes ({opt.percentage}%)</span>
                              </div>
                              <div className="h-3 w-full bg-zinc-50 rounded-full overflow-hidden border border-zinc-200">
                                <motion.div 
                                  initial={{ width: 0 }}
                                  animate={{ width: `${opt.percentage}%` }}
                                  transition={{ duration: 1, delay: 0.1 * idx, type: 'spring' }}
                                  className={`h-full rounded-full ${idx === 0 ? 'bg-indigo-500' : 'bg-zinc-600'}`}
                                />
                              </div>
                            </div>
                          ))}
                        </div>
                      </div>

                      <div className="space-y-6 lg:border-l border-zinc-200 lg:pl-8">
                        <div>
                          <h4 className="text-xs font-bold text-zinc-500 uppercase tracking-wider mb-4">Quick Stats</h4>
                          <div className="space-y-4">
                            <div className="bg-zinc-50 border border-zinc-200 rounded-xl p-4 flex items-center justify-between">
                              <div className="flex items-center gap-3 text-zinc-600 font-medium">
                                <Percent className="w-4 h-4 text-indigo-400" /> Engagement
                              </div>
                              <span className="text-lg font-bold text-zinc-900">42%</span>
                            </div>
                             <div className="bg-zinc-50 border border-zinc-200 rounded-xl p-4 flex items-center justify-between">
                              <div className="flex items-center gap-3 text-zinc-600 font-medium">
                                <Users className="w-4 h-4 text-emerald-400" /> Unique Voters
                              </div>
                              <span className="text-lg font-bold text-zinc-900">{poll.totalVotes - 12}</span>
                            </div>
                          </div>
                        </div>

                        <div className="flex gap-2">
                           <button className="flex-1 py-2.5 bg-zinc-50 border border-zinc-200 text-sm font-bold text-zinc-900 rounded-xl hover:bg-zinc-100 transition-colors">
                             Edit Poll
                           </button>
                           <button className="px-4 py-2.5 bg-zinc-50 border border-zinc-200 text-zinc-500 rounded-xl hover:text-zinc-900 transition-colors">
                             <MoreHorizontal className="w-5 h-5" />
                           </button>
                        </div>
                      </div>

                    </div>
                  </motion.div>
                )}
              </AnimatePresence>
            </motion.div>
          ))}
        </div>
      </div>

      {/* Create Poll Drawer */}
      <AnimatePresence>
        {isCreateOpen && (
          <>
            <motion.div 
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setIsCreateOpen(false)}
              className="fixed inset-0 bg-black/60 backdrop-blur-sm z-40"
            />
            <motion.div 
              initial={{ x: '100%', opacity: 0.5 }}
              animate={{ x: 0, opacity: 1 }}
              exit={{ x: '100%', opacity: 0.5 }}
              transition={{ type: 'spring', damping: 25, stiffness: 200 }}
              className="fixed top-0 right-0 bottom-0 w-full max-w-xl bg-white border-l border-zinc-200 z-50 flex flex-col shadow-2xl"
            >
              <div className="flex items-center justify-between p-6 border-b border-zinc-200 bg-white/50">
                <h2 className="text-xl font-bold text-zinc-900 flex items-center gap-2">
                  <BarChart2 className="w-5 h-5 text-indigo-400" /> Create New Poll
                </h2>
                <button 
                  onClick={() => setIsCreateOpen(false)}
                  className="p-2 text-zinc-500 hover:text-zinc-900 rounded-lg hover:bg-zinc-100 transition-colors"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>

              <div className="flex-1 overflow-y-auto p-6 space-y-8">
                
                {/* Question Area */}
                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-bold text-zinc-600 mb-2">Poll Question</label>
                    <textarea 
                      placeholder="What would you like to ask?"
                      className="w-full bg-zinc-50 border border-zinc-200 rounded-xl p-4 text-zinc-900 focus:outline-none focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500 transition-all resize-none h-24"
                    />
                  </div>
                </div>

                {/* Options Area */}
                <div className="space-y-4">
                  <label className="block text-sm font-bold text-zinc-600">Poll Options</label>
                  <div className="space-y-3">
                    <AnimatePresence>
                      {pollOptions.map((opt, idx) => (
                        <motion.div 
                          key={idx}
                          initial={{ opacity: 0, height: 0 }}
                          animate={{ opacity: 1, height: 'auto' }}
                          exit={{ opacity: 0, height: 0 }}
                          className="flex items-center gap-3"
                        >
                          <div className="w-8 h-8 rounded-full bg-zinc-50 border border-zinc-200 flex items-center justify-center text-xs font-bold text-zinc-500 shrink-0">
                            {idx + 1}
                          </div>
                          <input 
                            type="text"
                            placeholder={`Option ${idx + 1}`}
                            className="flex-1 px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm text-zinc-900 focus:outline-none focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500 transition-all"
                          />
                          {pollOptions.length > 2 && (
                            <button 
                              onClick={() => setPollOptions(pollOptions.filter((_, i) => i !== idx))}
                              className="p-3 text-zinc-500 hover:text-red-400 hover:bg-red-500/10 rounded-xl transition-colors"
                            >
                              <Trash2 className="w-4 h-4" />
                            </button>
                          )}
                        </motion.div>
                      ))}
                    </AnimatePresence>
                  </div>
                  <button 
                    onClick={() => setPollOptions([...pollOptions, ''])}
                    className="flex items-center gap-2 text-sm font-bold text-indigo-400 hover:text-indigo-300 transition-colors mt-2"
                  >
                    <Plus className="w-4 h-4" /> Add Another Option
                  </button>
                </div>

                {/* Settings */}
                <div className="space-y-6 pt-6 border-t border-zinc-200">
                  <h3 className="text-sm font-bold text-zinc-900 uppercase tracking-wider">Security & Privacy</h3>
                  
                  <div className="grid grid-cols-3 gap-3">
                    {['Public', 'Private', 'Password Protected'].map((mode) => (
                      <button
                        key={mode}
                        onClick={() => setPrivacyMode(mode)}
                        className={`p-3 rounded-xl border flex flex-col items-center justify-center gap-2 text-center transition-all ${
                          privacyMode === mode 
                            ? 'bg-indigo-500/10 border-indigo-500 text-indigo-400' 
                            : 'bg-zinc-50 border-zinc-200 text-zinc-500 hover:border-zinc-200'
                        }`}
                      >
                        {getPrivacyIcon(mode)}
                        <span className="text-[10px] font-bold leading-tight">{mode}</span>
                      </button>
                    ))}
                  </div>

                  {privacyMode === 'Password Protected' && (
                    <motion.div initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: 'auto' }}>
                      <input 
                        type="password"
                        placeholder="Set a password for this poll"
                        className="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm text-zinc-900 focus:outline-none focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500 transition-all"
                      />
                    </motion.div>
                  )}
                </div>

              </div>

              {/* Drawer Footer */}
              <div className="p-6 border-t border-zinc-200 bg-white/50 flex gap-3">
                <button 
                  onClick={() => setIsCreateOpen(false)}
                  className="flex-1 py-3 rounded-xl border border-zinc-200 text-zinc-600 font-bold hover:bg-zinc-100 transition-colors"
                >
                  Cancel
                </button>
                <button className="flex-1 py-3 rounded-xl bg-indigo-600 text-white font-bold transition-all hover:bg-indigo-500 hover:shadow-[0_0_20px_-5px_rgba(99,102,241,0.5)]">
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
