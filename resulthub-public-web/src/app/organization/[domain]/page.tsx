"use client";

import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { api } from '@/lib/api';
import { 
  Search, 
  MapPin, 
  Link as LinkIcon, 
  Database, 
  CheckSquare, 
  MessageSquareWarning, 
  CheckCircle2, 
  Globe, 
  Users, 
  Calendar, 
  ArrowRight,
  TrendingUp,
  Percent,
  UploadCloud,
  ChevronRight
} from 'lucide-react';
import Link from 'next/link';
import { useParams, useRouter } from 'next/navigation';

// Dynamic state will replace mocks

export default function PublicOrganizationProfile() {
  const params = useParams();
  const router = useRouter();
  const domain = params?.domain as string || 'stanford';
  const [activeTab, setActiveTab] = useState<'datasets' | 'polls' | 'complaints'>('datasets');
  const [searchQuery, setSearchQuery] = useState('');

  const [workspace, setWorkspace] = useState<any>(null);
  const [datasets, setDatasets] = useState<any[]>([]);
  const [polls, setPolls] = useState<any[]>([]);
  const [complaints, setComplaints] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  // Polls State
  const [selectedPollOptions, setSelectedPollOptions] = useState<Record<string, string>>({});
  const [isSubmittingVote, setIsSubmittingVote] = useState<Record<string, boolean>>({});

  // Complaints State
  const [complaintCategory, setComplaintCategory] = useState("");
  const [complaintSubject, setComplaintSubject] = useState("");
  const [complaintDetails, setComplaintDetails] = useState("");
  const [isSubmittingComplaint, setIsSubmittingComplaint] = useState(false);
  const [complaintError, setComplaintError] = useState("");
  const [complaintSuccess, setComplaintSuccess] = useState(false);

  useEffect(() => {
    const fetchOrgData = async () => {
      setIsLoading(true);
      try {
        // 1. Fetch workspace by slug (domain)
        const ws = await api.workspaces.getBySlug(domain);
        setWorkspace(ws);

        // 2. Fetch datasets for this workspace
        if (ws && ws.id) {
          const dsRes = await api.datasets.getByWorkspace(ws.id, 0, 50);
          setDatasets(dsRes.content || []);
          
          // 3. Fetch Polls
          const pollsRes = await api.votes.getVoteBoxes().catch(() => ({ content: [] }));
          if (pollsRes && pollsRes.content) {
            setPolls(pollsRes.content.map((p: any) => {
              const total = p.options?.reduce((acc: number, curr: any) => acc + (curr.voteCount || 0), 0) || 0;
              return {
                id: p.id,
                displayId: `P-${p.id.substring(0, 4).toUpperCase()}`,
                question: p.title,
                totalVotes: total,
                hasVoted: p.hasVoted,
                endDate: new Date(p.endDate).toLocaleDateString(),
                options: (p.options || []).map((opt: any) => ({
                  id: opt.id,
                  text: opt.title,
                  votes: opt.voteCount || 0,
                  percentage: total > 0 ? Math.round(((opt.voteCount || 0) / total) * 100) : 0
                })).sort((a: any, b: any) => b.votes - a.votes)
              };
            }));
          }

          // 4. Fetch Complaints
          const compRes = await api.complaints.getComplaints('new').catch(() => ({ content: [] }));
          if (compRes && compRes.content) {
            setComplaints(compRes.content.map((c: any) => ({
              id: `C-${c.id.substring(0, 4).toUpperCase()}`,
              title: c.title,
              status: c.status === 'NEW' ? 'New' : c.status === 'IN_PROGRESS' ? 'In Progress' : c.status === 'ESCALATED' ? 'Escalated' : 'Resolved',
              category: c.category || 'General',
              date: new Date(c.createdAt).toLocaleDateString()
            })));
          }
        }
      } catch (err) {
        console.error("Failed to load organization data:", err);
      } finally {
        setIsLoading(false);
      }
    };
    
    fetchOrgData();
  }, [domain]);

  const handleVoteSubmit = async (pollId: string) => {
    const selectedOptionId = selectedPollOptions[pollId];
    if (!selectedOptionId) return;

    try {
      setIsSubmittingVote(prev => ({ ...prev, [pollId]: true }));
      await api.votes.vote(pollId, selectedOptionId);
      // Refresh polls
      const pollsRes = await api.votes.getVoteBoxes().catch(() => ({ content: [] }));
      if (pollsRes && pollsRes.content) {
        setPolls(pollsRes.content.map((p: any) => {
          const total = p.options?.reduce((acc: number, curr: any) => acc + (curr.voteCount || 0), 0) || 0;
          return {
            id: p.id,
            displayId: `P-${p.id.substring(0, 4).toUpperCase()}`,
            question: p.title,
            totalVotes: total,
            hasVoted: p.hasVoted,
            endDate: new Date(p.endDate).toLocaleDateString(),
            options: (p.options || []).map((opt: any) => ({
              id: opt.id,
              text: opt.title,
              votes: opt.voteCount || 0,
              percentage: total > 0 ? Math.round(((opt.voteCount || 0) / total) * 100) : 0
            })).sort((a: any, b: any) => b.votes - a.votes)
          };
        }));
      }
    } catch (err: any) {
      alert(err.message || 'Failed to submit vote. Please login.');
    } finally {
      setIsSubmittingVote(prev => ({ ...prev, [pollId]: false }));
    }
  };

  const handleComplaintSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!complaintSubject || !complaintDetails || !complaintCategory) return;
    
    try {
      setIsSubmittingComplaint(true);
      setComplaintError("");
      const formData = new FormData();
      formData.append('title', complaintSubject);
      formData.append('description', complaintDetails);
      formData.append('category', complaintCategory);
      
      await api.complaints.create(formData);
      
      setComplaintSuccess(true);
      setComplaintSubject("");
      setComplaintDetails("");
      setComplaintCategory("");
      
      // Refresh complaints ledger
      const compRes = await api.complaints.getComplaints('new').catch(() => ({ content: [] }));
      if (compRes && compRes.content) {
        setComplaints(compRes.content.map((c: any) => ({
          id: `C-${c.id.substring(0, 4).toUpperCase()}`,
          title: c.title,
          status: c.status === 'NEW' ? 'New' : c.status === 'IN_PROGRESS' ? 'In Progress' : c.status === 'ESCALATED' ? 'Escalated' : 'Resolved',
          category: c.category || 'General',
          date: new Date(c.createdAt).toLocaleDateString()
        })));
      }
    } catch (err: any) {
      setComplaintError(err.message || "Failed to submit report. Ensure you are logged in.");
    } finally {
      setIsSubmittingComplaint(false);
      setTimeout(() => setComplaintSuccess(false), 5000);
    }
  };

  if (isLoading) {
    return <div className="min-h-screen bg-[#F9FAFB] flex items-center justify-center font-bold text-zinc-500">Loading profile...</div>;
  }

  if (!workspace) {
    return <div className="min-h-screen bg-[#F9FAFB] flex items-center justify-center font-bold text-zinc-500 text-xl">Organization not found.</div>;
  }

  return (
    <div className="min-h-screen bg-[#F9FAFB] text-zinc-900 font-sans selection:bg-[#635BFF]/20">
      
      {/* 1. BRANDED HEADER */}
      <div className="relative bg-white border-b border-zinc-200 shadow-sm">
        {/* Cover Banner */}
        <div className="h-48 md:h-64 w-full bg-gradient-to-r from-[#635BFF]/80 via-purple-600/80 to-indigo-800/80 relative overflow-hidden">
          <div className="absolute inset-0 bg-[url('https://www.transparenttextures.com/patterns/cubes.png')] opacity-10"></div>
          {/* Mock abstract shapes for the banner */}
          <div className="absolute -bottom-24 -left-24 w-96 h-96 bg-white/10 rounded-full blur-3xl"></div>
          <div className="absolute top-0 right-0 w-64 h-64 bg-black/10 rounded-full blur-3xl"></div>
        </div>

        <div className="max-w-6xl mx-auto px-4 md:px-8 relative pb-8">
          <div className="flex flex-col md:flex-row gap-6 md:items-end -mt-16 md:-mt-20 relative z-10">
            {/* Logo */}
            <div className="w-32 h-32 md:w-40 md:h-40 bg-white rounded-2xl shadow-xl border-4 border-white flex items-center justify-center shrink-0 overflow-hidden relative">
              <div className="absolute inset-0 bg-gradient-to-tr from-[#635BFF]/10 to-transparent"></div>
              <span className="text-5xl font-black text-[#635BFF]">{domain.substring(0, 2).toUpperCase()}</span>
            </div>

            {/* Org Details */}
            <div className="flex-1 space-y-3 pt-4 md:pt-0">
              <div className="flex flex-col sm:flex-row sm:items-center gap-3">
                <h1 className="text-3xl md:text-4xl font-extrabold tracking-tight text-zinc-900 capitalize">
                  {workspace.name}
                </h1>
                {workspace.settings?.isVerified && (
                  <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full bg-emerald-50 text-emerald-700 text-xs font-bold border border-emerald-200 w-fit">
                    <CheckCircle2 className="w-3.5 h-3.5" /> Verified Official
                  </span>
                )}
              </div>
              <p className="text-zinc-500 max-w-2xl text-base md:text-lg leading-relaxed">
                {workspace.description || 'Access our public records, participate in community polls, and submit feedback directly.'}
              </p>
              
              <div className="flex flex-wrap items-center gap-4 text-sm font-medium text-zinc-600 pt-2">
                <span className="flex items-center gap-1.5"><MapPin className="w-4 h-4 text-zinc-400" /> Global</span>
                <span className="flex items-center gap-1.5"><Globe className="w-4 h-4 text-zinc-400" /> {workspace.domainType || 'Organization'}</span>
                <a href="#" className="flex items-center gap-1.5 text-[#635BFF] hover:underline"><LinkIcon className="w-4 h-4" /> {domain}</a>
              </div>
            </div>
            
            {/* CTA */}
            <div className="shrink-0 flex gap-3 w-full md:w-auto">
              <button className="flex-1 md:flex-none px-6 py-2.5 bg-white border border-zinc-200 rounded-xl text-sm font-bold text-zinc-700 hover:bg-zinc-50 transition-colors shadow-sm">
                Follow
              </button>
              <button className="flex-1 md:flex-none px-6 py-2.5 bg-[#635BFF] text-white rounded-xl text-sm font-bold hover:bg-[#5249E5] transition-colors shadow-sm shadow-[#635BFF]/20">
                Contact
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* 2. GLOBAL SEARCH (RESULTS SPACE) */}
      <div className="bg-white border-b border-zinc-200 sticky top-0 z-40 shadow-sm">
        <div className="max-w-6xl mx-auto px-4 md:px-8 py-6">
          <div className="relative group max-w-3xl mx-auto">
            <div className="absolute inset-0 bg-gradient-to-r from-[#635BFF] to-purple-500 rounded-2xl blur opacity-20 group-hover:opacity-30 transition-opacity"></div>
              <form 
                onSubmit={(e) => {
                  e.preventDefault();
                  if (searchQuery.trim()) {
                    router.push(`/search?q=${encodeURIComponent(searchQuery.trim())}`);
                  }
                }}
                className="relative flex items-center bg-white border border-zinc-200 rounded-2xl shadow-sm focus-within:ring-2 focus-within:ring-[#635BFF]/20 focus-within:border-[#635BFF] overflow-hidden transition-all w-full"
              >
                <div className="pl-6 pr-4 text-zinc-400">
                  <Search className="w-6 h-6" />
                </div>
                <input 
                  type="text"
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  placeholder="Search by Student ID, Name, or Enrollment Number..."
                  className="w-full py-5 pr-6 text-lg font-medium text-zinc-900 bg-transparent outline-none placeholder:text-zinc-400"
                />
                <button type="submit" className="hidden sm:flex items-center gap-2 mr-2 px-6 py-3 bg-zinc-900 text-white font-bold rounded-xl hover:bg-zinc-800 transition-colors">
                  Search <ArrowRight className="w-4 h-4" />
                </button>
              </form>
            </div>
          {searchQuery && (
            <motion.div initial={{ opacity: 0, y: -10 }} animate={{ opacity: 1, y: 0 }} className="max-w-3xl mx-auto mt-4 text-center text-sm font-medium text-zinc-500">
              Searching across <span className="text-zinc-900 font-bold">{datasets.length}</span> public datasets...
            </motion.div>
          )}
        </div>
      </div>

      {/* 3. INTERACTIVE SERVICE TABS */}
      <div className="max-w-6xl mx-auto px-4 md:px-8 py-8 md:py-12">
        <div className="flex space-x-2 md:space-x-8 border-b border-zinc-200 overflow-x-auto scrollbar-hide mb-8">
          {[
            { id: 'datasets', label: 'Public Datasets', icon: Database, count: datasets.length },
            { id: 'polls', label: 'Active Polls', icon: CheckSquare, count: polls.length },
            { id: 'complaints', label: 'Complaint Box', icon: MessageSquareWarning, count: complaints.length }
          ].map(tab => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id as any)}
              className={`flex items-center gap-2.5 pb-4 px-2 md:px-4 font-bold text-sm md:text-base relative transition-colors whitespace-nowrap ${activeTab === tab.id ? 'text-[#635BFF]' : 'text-zinc-500 hover:text-zinc-800'}`}
            >
              <tab.icon className="w-5 h-5" />
              {tab.label}
              {tab.count && (
                <span className={`px-2 py-0.5 rounded-full text-xs ${activeTab === tab.id ? 'bg-[#635BFF]/10 text-[#635BFF]' : 'bg-zinc-100 text-zinc-500'}`}>
                  {tab.count}
                </span>
              )}
              {activeTab === tab.id && (
                <motion.div layoutId="public-tab-indicator" className="absolute bottom-0 left-0 right-0 h-0.5 bg-[#635BFF]" />
              )}
            </button>
          ))}
        </div>

        <div className="min-h-[400px]">
          <AnimatePresence mode="wait">
            
            {/* DATASETS TAB */}
            {activeTab === 'datasets' && (
              <motion.div
                key="datasets"
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                className="space-y-6"
              >
                <div className="flex items-center justify-between">
                  <h2 className="text-xl font-extrabold text-zinc-900">Featured Datasets</h2>
                  <button className="text-sm font-bold text-[#635BFF] hover:underline flex items-center gap-1">
                    View All Categories <ChevronRight className="w-4 h-4" />
                  </button>
                </div>
                
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                  {datasets.length === 0 ? (
                    <div className="col-span-full py-12 text-center text-zinc-500 font-medium border-2 border-dashed border-zinc-200 rounded-2xl">
                      No public datasets available yet.
                    </div>
                  ) : (
                    datasets.map((ds) => (
                      <div key={ds.id} className="bg-white border border-zinc-200 rounded-2xl p-6 shadow-sm hover:shadow-md hover:border-zinc-300 transition-all group cursor-pointer flex flex-col justify-between">
                        <div>
                          <div className="flex justify-between items-start mb-4">
                            <div className="w-10 h-10 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center group-hover:scale-110 transition-transform">
                              <Database className="w-5 h-5" />
                            </div>
                            <span className="px-2.5 py-1 rounded-md text-[10px] font-bold bg-zinc-100 text-zinc-600 uppercase tracking-wider">
                              {ds.domainType || 'General'}
                            </span>
                          </div>
                          <h3 className="text-lg font-bold text-zinc-900 mb-2 leading-tight group-hover:text-[#635BFF] transition-colors">{ds.name}</h3>
                          <p className="text-zinc-500 text-sm font-medium font-mono">{ds.id.split('-')[0]}</p>
                        </div>
                        
                        <div className="mt-6 pt-4 border-t border-zinc-100 flex items-center justify-between text-xs font-semibold text-zinc-500">
                          <span className="flex items-center gap-1.5"><Users className="w-4 h-4 text-zinc-400" /> 0 Records</span>
                          <span className="flex items-center gap-1.5"><Calendar className="w-4 h-4 text-zinc-400" /> {new Date(ds.updatedAt).toLocaleDateString()}</span>
                        </div>
                      </div>
                    ))
                  )}
                </div>
              </motion.div>
            )}

            {/* POLLS TAB */}
            {activeTab === 'polls' && (
              <motion.div
                key="polls"
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                className="max-w-4xl mx-auto space-y-6"
              >
                <div className="text-center mb-8">
                  <h2 className="text-2xl font-extrabold text-zinc-900 mb-2">Community Voting Hub</h2>
                  <p className="text-zinc-500">Have your say in ongoing public surveys and organizational decisions.</p>
                </div>

                {polls.map((poll) => (
                  <div key={poll.id} className="bg-white border border-zinc-200 rounded-3xl p-6 md:p-8 shadow-sm">
                    <div className="flex flex-wrap items-center gap-3 mb-4">
                      <span className="flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200">
                        <TrendingUp className="w-3.5 h-3.5" /> ACTIVE POLL
                      </span>
                      <span className="text-zinc-500 text-xs font-medium font-mono">{poll.id}</span>
                    </div>
                    
                    <h3 className="text-xl md:text-2xl font-bold text-zinc-900 leading-tight mb-8">{poll.question}</h3>
                    
                    <div className="space-y-4 mb-8">
                      {poll.options.map((opt: any, idx: number) => (
                        <div key={idx} className="relative group cursor-pointer">
                          <input 
                            type="radio" 
                            name={`poll-${poll.id}`} 
                            id={`opt-${poll.id}-${idx}`} 
                            checked={selectedPollOptions[poll.id] === opt.id}
                            onChange={() => setSelectedPollOptions(prev => ({ ...prev, [poll.id]: opt.id }))}
                            disabled={poll.hasVoted}
                            className="peer sr-only" 
                          />
                          <label htmlFor={`opt-${poll.id}-${idx}`} className={`flex flex-col p-4 rounded-xl border-2 font-semibold transition-all cursor-pointer ${
                            selectedPollOptions[poll.id] === opt.id
                              ? 'border-[#635BFF] bg-[#635BFF]/5 text-[#635BFF]' 
                              : 'border-zinc-100 bg-zinc-50 text-zinc-700 hover:border-zinc-200'
                          }`}>
                            <div className="flex items-center justify-between w-full">
                              <span>{opt.text}</span>
                              <div className={`w-5 h-5 rounded-full border-2 transition-all ${
                                selectedPollOptions[poll.id] === opt.id ? 'border-[#635BFF] border-[6px]' : 'border-zinc-300'
                              }`}></div>
                            </div>
                            {poll.hasVoted && (
                              <div className="mt-3 w-full">
                                <div className="flex items-center justify-between text-xs font-bold text-zinc-500 mb-1">
                                  <span>{opt.percentage}%</span>
                                  <span>{opt.votes} votes</span>
                                </div>
                                <div className="h-1.5 w-full bg-zinc-200 rounded-full overflow-hidden">
                                  <div className="h-full bg-[#635BFF]" style={{ width: `${opt.percentage}%` }}></div>
                                </div>
                              </div>
                            )}
                          </label>
                        </div>
                      ))}
                    </div>

                    <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pt-6 border-t border-zinc-100">
                      <div className="flex items-center gap-4 text-sm font-medium text-zinc-500">
                        <span className="flex items-center gap-1.5"><Users className="w-4 h-4" /> {poll.totalVotes.toLocaleString()} Votes Cast</span>
                        <span className="flex items-center gap-1.5"><Calendar className="w-4 h-4" /> {poll.endDate}</span>
                      </div>
                      <button 
                        disabled={poll.hasVoted || isSubmittingVote[poll.id] || !selectedPollOptions[poll.id]}
                        onClick={() => handleVoteSubmit(poll.id)}
                        className="px-6 py-2.5 bg-zinc-900 text-white rounded-xl font-bold hover:bg-zinc-800 transition-colors w-full sm:w-auto disabled:opacity-50 disabled:cursor-not-allowed"
                      >
                        {poll.hasVoted ? "Vote Recorded" : isSubmittingVote[poll.id] ? "Submitting..." : "Submit Vote"}
                      </button>
                    </div>
                  </div>
                ))}
              </motion.div>
            )}

            {/* COMPLAINTS TAB */}
            {activeTab === 'complaints' && (
              <motion.div
                key="complaints"
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                className="grid grid-cols-1 lg:grid-cols-2 gap-10"
              >
                {/* Submit Form */}
                <div className="bg-white border border-zinc-200 rounded-3xl p-6 md:p-8 shadow-sm h-fit">
                  <h2 className="text-xl font-extrabold text-zinc-900 mb-2">Submit a Report</h2>
                  <p className="text-zinc-500 text-sm mb-6">Your feedback helps us improve. Please provide details below.</p>
                  
                  <form className="space-y-4" onSubmit={handleComplaintSubmit}>
                    <div className="space-y-1.5">
                      <label className="text-sm font-bold text-zinc-700">Category</label>
                      <select 
                        required
                        value={complaintCategory}
                        onChange={(e) => setComplaintCategory(e.target.value)}
                        className="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-zinc-900 focus:outline-none focus:ring-2 focus:ring-[#635BFF]/20 focus:border-[#635BFF] appearance-none font-medium text-sm"
                      >
                        <option value="">Select a category...</option>
                        <option value="Infrastructure & Maintenance">Infrastructure & Maintenance</option>
                        <option value="IT & Technical Support">IT & Technical Support</option>
                        <option value="General Feedback">General Feedback</option>
                      </select>
                    </div>

                    <div className="space-y-1.5">
                      <label className="text-sm font-bold text-zinc-700">Subject</label>
                      <input 
                        required
                        type="text" 
                        value={complaintSubject}
                        onChange={(e) => setComplaintSubject(e.target.value)}
                        placeholder="Brief summary of the issue" 
                        className="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-zinc-900 focus:outline-none focus:ring-2 focus:ring-[#635BFF]/20 focus:border-[#635BFF] text-sm" 
                      />
                    </div>

                    <div className="space-y-1.5">
                      <label className="text-sm font-bold text-zinc-700">Details</label>
                      <textarea 
                        required
                        value={complaintDetails}
                        onChange={(e) => setComplaintDetails(e.target.value)}
                        placeholder="Provide as much context as possible..." 
                        rows={4} 
                        className="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-zinc-900 focus:outline-none focus:ring-2 focus:ring-[#635BFF]/20 focus:border-[#635BFF] resize-none text-sm"
                      ></textarea>
                    </div>

                    {complaintError && (
                      <div className="p-3 bg-rose-50 text-rose-600 border border-rose-100 rounded-xl text-sm font-bold">
                        {complaintError}
                      </div>
                    )}

                    {complaintSuccess && (
                      <div className="p-3 bg-emerald-50 text-emerald-600 border border-emerald-100 rounded-xl text-sm font-bold flex items-center gap-2">
                        <CheckCircle2 className="w-4 h-4" /> Report submitted successfully!
                      </div>
                    )}

                    <div className="pt-2">
                      <button disabled={isSubmittingComplaint} className="w-full flex items-center justify-center gap-2 px-6 py-3 bg-[#635BFF] text-white rounded-xl font-bold hover:bg-[#5249E5] transition-colors shadow-sm shadow-[#635BFF]/20 disabled:opacity-50">
                        {isSubmittingComplaint ? "Submitting..." : "Submit Report"}
                      </button>
                    </div>
                  </form>
                </div>

                {/* Public Ledger */}
                <div>
                  <div className="flex items-center justify-between mb-6">
                    <h2 className="text-xl font-extrabold text-zinc-900">Public Ledger</h2>
                    <span className="text-xs font-bold text-zinc-500 uppercase tracking-wider">Recently Resolved</span>
                  </div>

                  <div className="space-y-4">
                    {complaints.map(comp => (
                      <div key={comp.id} className="bg-white border border-zinc-200 rounded-2xl p-5 hover:border-zinc-300 transition-colors">
                        <div className="flex items-start justify-between mb-2">
                          <span className="px-2.5 py-1 rounded-md text-[10px] font-bold bg-zinc-100 text-zinc-600 uppercase tracking-wider">
                            {comp.category}
                          </span>
                          <span className="text-xs font-medium text-zinc-400">{comp.date}</span>
                        </div>
                        <h4 className="font-bold text-zinc-900 mb-3">{comp.title}</h4>
                        <div className="flex items-center justify-between">
                          <span className="text-xs font-mono text-zinc-500">{comp.id}</span>
                          <span className="flex items-center gap-1.5 text-xs font-bold text-emerald-600 bg-emerald-50 px-2.5 py-1 rounded-full border border-emerald-100">
                            <CheckCircle2 className="w-3.5 h-3.5" /> Resolved
                          </span>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

              </motion.div>
            )}

          </AnimatePresence>
        </div>
      </div>
    </div>
  );
}
