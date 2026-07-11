"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { 
  FolderKanban, Plus, Search, Users, Database, HardDrive, 
  ChevronRight, Grid, List, ArrowUpRight, Activity, TrendingUp, 
  MoreVertical, Lock, Globe, SlidersHorizontal, ArrowDownToLine, 
  RefreshCw, CheckCircle2, AlertCircle, Building2, Eye, ShieldCheck, 
  X, ExternalLink, Calendar, PlusCircle
} from "lucide-react";

// Mock Workspaces Data for Rich UI Experience
const INITIAL_WORKSPACES = [
  {
    id: "ws-1",
    name: "Admissions & Exams",
    slug: "admissions-exams",
    description: "Primary workspace for managing academic entrance exams, enrollment lists, and semester mark sheets.",
    category: "Academic",
    visibility: "Public",
    membersCount: 24,
    datasetsCount: 18,
    storageUsed: 4.8, // GB
    storageLimit: 10,
    healthScore: 98,
    lastUpdated: "2 mins ago",
    status: "Active",
    traffic: [30, 40, 35, 50, 49, 60, 70, 91],
  },
  {
    id: "ws-2",
    name: "Finance & Budgets",
    slug: "finance-budgets",
    description: "Secure node handling financial audits, quarterly statements, funding allocation datasets, and NGO metrics.",
    category: "Corporate",
    visibility: "Private",
    membersCount: 8,
    datasetsCount: 12,
    storageUsed: 2.1,
    storageLimit: 5,
    healthScore: 100,
    lastUpdated: "1 hour ago",
    status: "Active",
    traffic: [20, 25, 22, 30, 28, 35, 40, 45],
  },
  {
    id: "ws-3",
    name: "Hospitality & Clinic Records",
    slug: "hospital-records",
    description: "HIPAA-compliant portal managing clinic performance, patient satisfaction data, and public healthcare stats.",
    category: "Healthcare",
    visibility: "Restricted",
    membersCount: 15,
    datasetsCount: 7,
    storageUsed: 8.2,
    storageLimit: 15,
    healthScore: 94,
    lastUpdated: "Yesterday",
    status: "Active",
    traffic: [50, 55, 52, 60, 65, 70, 75, 80],
  },
  {
    id: "ws-4",
    name: "Sports & Athletics Federation",
    slug: "sports-athletics",
    description: "Public space for publishing tournament brackets, player statistics, historical rankings, and live stories.",
    category: "Athletics",
    visibility: "Public",
    membersCount: 19,
    datasetsCount: 34,
    storageUsed: 3.4,
    storageLimit: 10,
    healthScore: 89,
    lastUpdated: "3 days ago",
    status: "Active",
    traffic: [80, 85, 90, 88, 95, 100, 110, 120],
  },
  {
    id: "ws-5",
    name: "Government Civic Datasets",
    slug: "gov-civic",
    description: "Public census logs, municipal compliance reviews, local government election stats, and public complaints feed.",
    category: "Government",
    visibility: "Public",
    membersCount: 42,
    datasetsCount: 22,
    storageUsed: 12.5,
    storageLimit: 20,
    healthScore: 97,
    lastUpdated: "5 mins ago",
    status: "Active",
    traffic: [100, 110, 120, 115, 130, 140, 145, 150],
  }
];

const CATEGORIES = ["All", "Academic", "Healthcare", "Government", "Corporate", "Athletics"];

export default function WorkspacesPage() {
  const [workspaces, setWorkspaces] = useState(INITIAL_WORKSPACES);
  const [viewMode, setViewMode] = useState<"grid" | "table">("grid");
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedCategory, setSelectedCategory] = useState("All");
  const [isCreateOpen, setIsCreateOpen] = useState(false);
  const [selectedWorkspace, setSelectedWorkspace] = useState<typeof INITIAL_WORKSPACES[0] | null>(null);

  // New Workspace Form State
  const [newName, setNewName] = useState("");
  const [newDesc, setNewDesc] = useState("");
  const [newCategory, setNewCategory] = useState("Academic");
  const [newVisibility, setNewVisibility] = useState("Public");

  const handleCreateWorkspace = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newName) return;

    const newWs = {
      id: `ws-${Date.now()}`,
      name: newName,
      slug: newName.toLowerCase().replace(/[^a-z0-9]+/g, "-"),
      description: newDesc || "No description provided.",
      category: newCategory,
      visibility: newVisibility,
      membersCount: 1,
      datasetsCount: 0,
      storageUsed: 0.1,
      storageLimit: 10,
      healthScore: 100,
      lastUpdated: "Just now",
      status: "Active",
      traffic: [10, 15, 20, 25, 30, 35, 40, 45],
    };

    setWorkspaces([newWs, ...workspaces]);
    setIsCreateOpen(false);
    setNewName("");
    setNewDesc("");
  };

  const filteredWorkspaces = workspaces.filter(ws => {
    const matchesSearch = ws.name.toLowerCase().includes(searchQuery.toLowerCase()) || 
                          ws.description.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCategory = selectedCategory === "All" || ws.category === selectedCategory;
    return matchesSearch && matchesCategory;
  });

  return (
    <div className="space-y-8 font-sans pb-12">
      
      {/* 1. HEADER SECTION */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-zinc-200/60 pb-6">
        <div>
          <h1 className="text-3xl font-extrabold tracking-tight text-zinc-950">Workspace Management</h1>
          <p className="text-zinc-500 text-sm mt-1">Manage and isolate your organization's departmental hubs, analytics, and datasets.</p>
        </div>
        <div className="flex flex-wrap items-center gap-3">
          <button 
            onClick={() => setIsCreateOpen(true)}
            className="flex items-center gap-2 bg-[#635BFF] hover:bg-[#5249E5] text-zinc-900 px-5 py-2.5 rounded-xl text-sm font-bold shadow-md shadow-[#635BFF]/10 transition-all active:scale-95"
          >
            <Plus size={16} />
            Create Workspace
          </button>
          <button className="flex items-center gap-2 bg-white border border-zinc-200 text-zinc-700 px-4 py-2.5 rounded-xl text-sm font-semibold hover:bg-zinc-50 transition-colors shadow-sm">
            <ArrowDownToLine size={16} />
            Import Node
          </button>
          <button className="flex items-center gap-2 bg-white border border-zinc-200 text-zinc-700 px-4 py-2.5 rounded-xl text-sm font-semibold hover:bg-zinc-50 transition-colors shadow-sm">
            Templates
          </button>
        </div>
      </div>

      {/* 2. STATS SECTION */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        {[
          { label: "Total Workspaces", value: workspaces.length, change: "+1 this month", icon: FolderKanban, color: "text-[#635BFF]" },
          { label: "Collaborating Members", value: workspaces.reduce((acc, ws) => acc + ws.membersCount, 0), change: "Active across hubs", icon: Users, color: "text-blue-500" },
          { label: "Total Datasets", value: workspaces.reduce((acc, ws) => acc + ws.datasetsCount, 0), change: "JSONB Tables live", icon: Database, color: "text-emerald-500" },
          { label: "Overall Storage", value: `${workspaces.reduce((acc, ws) => acc + ws.storageUsed, 0).toFixed(1)} GB`, change: "64% of total quota", icon: HardDrive, color: "text-purple-500" },
        ].map((stat, idx) => (
          <motion.div
            key={stat.label}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: idx * 0.05 }}
            whileHover={{ y: -4, boxShadow: "0 12px 30px rgba(0,0,0,0.04)" }}
            className="bg-white border border-zinc-200/80 p-5 rounded-2xl flex items-center gap-4 shadow-sm hover:border-zinc-300 transition-all cursor-default"
          >
            <div className={`w-12 h-12 bg-zinc-50 rounded-xl flex items-center justify-center border border-zinc-100 ${stat.color}`}>
              <stat.icon size={22} />
            </div>
            <div>
              <span className="text-[12px] font-bold uppercase tracking-wider text-zinc-500 block">{stat.label}</span>
              <span className="text-2xl font-extrabold text-zinc-950 mt-1 block">{stat.value}</span>
              <span className="text-[11px] text-zinc-500 font-medium block mt-0.5">{stat.change}</span>
            </div>
          </motion.div>
        ))}
      </div>

      {/* 3. FILTER BAR */}
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-4 bg-white border border-zinc-200/80 p-4 rounded-2xl shadow-sm">
        
        {/* Search */}
        <div className="relative flex-1 max-w-md">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 text-zinc-500" size={18} />
          <input 
            type="text"
            placeholder="Search workspaces by name or description..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full bg-zinc-50 border border-zinc-200/80 focus:border-[#635BFF]/30 focus:bg-white pl-11 pr-4 py-2.5 rounded-xl text-sm font-medium outline-none transition-all"
          />
        </div>

        {/* View and Category Filter */}
        <div className="flex flex-wrap items-center gap-3">
          
          {/* Category Dropdown */}
          <div className="relative">
            <select
              value={selectedCategory}
              onChange={(e) => setSelectedCategory(e.target.value)}
              className="bg-white border border-zinc-200 text-zinc-700 px-4 py-2.5 rounded-xl text-sm font-semibold hover:bg-zinc-50 outline-none cursor-pointer transition-colors shadow-sm"
            >
              {CATEGORIES.map(cat => (
                <option key={cat} value={cat}>{cat} Hubs</option>
              ))}
            </select>
          </div>

          <div className="h-6 w-px bg-zinc-200 mx-1 hidden sm:block"></div>

          {/* Toggle buttons */}
          <div className="flex items-center bg-zinc-100 p-1 rounded-xl shadow-inner">
            <button 
              onClick={() => setViewMode("grid")}
              className={`p-2 rounded-lg transition-all ${viewMode === "grid" ? "bg-white text-zinc-900 shadow-sm" : "text-zinc-500 hover:text-zinc-900"}`}
            >
              <Grid size={18} />
            </button>
            <button 
              onClick={() => setViewMode("table")}
              className={`p-2 rounded-lg transition-all ${viewMode === "table" ? "bg-white text-zinc-900 shadow-sm" : "text-zinc-500 hover:text-zinc-900"}`}
            >
              <List size={18} />
            </button>
          </div>
        </div>
      </div>

      {/* 4. CONTENT AREA (GRID or TABLE) */}
      <AnimatePresence mode="wait">
        {filteredWorkspaces.length === 0 ? (
          <motion.div 
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="bg-white border border-zinc-200/80 rounded-3xl p-12 text-center shadow-sm max-w-xl mx-auto mt-8"
          >
            <div className="w-16 h-16 bg-zinc-50 rounded-2xl flex items-center justify-center border border-zinc-100 mx-auto text-zinc-500 mb-6">
              <FolderKanban size={32} />
            </div>
            <h3 className="text-xl font-bold text-zinc-950 mb-2">No Workspaces Found</h3>
            <p className="text-zinc-500 text-sm mb-8">No environments match your query. Create a new workspace to start publishing results.</p>
            <button 
              onClick={() => setIsCreateOpen(true)}
              className="bg-[#635BFF] text-zinc-900 px-6 py-3 rounded-xl font-bold hover:bg-[#5249E5] transition-all"
            >
              Create First Workspace
            </button>
          </motion.div>
        ) : viewMode === "grid" ? (
          <motion.div 
            key="grid"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
          >
            {filteredWorkspaces.map((ws) => (
              <motion.div
                key={ws.id}
                layoutId={`card-${ws.id}`}
                whileHover={{ y: -4, boxShadow: "0 20px 40px rgba(0,0,0,0.06)" }}
                className="bg-white border border-zinc-200/80 rounded-3xl p-6 shadow-sm hover:border-zinc-300 transition-all flex flex-col group relative"
              >
                {/* Header Info */}
                <div className="flex items-start justify-between gap-4">
                  <div className="w-12 h-12 bg-[#635BFF]/5 text-[#635BFF] rounded-xl flex items-center justify-center font-bold text-lg border border-[#635BFF]/10 shrink-0">
                    {ws.name.slice(0,2).toUpperCase()}
                  </div>
                  
                  <div className="flex items-center gap-2">
                    <span className={`text-[10px] font-black uppercase tracking-widest px-2.5 py-1 rounded-full border ${
                      ws.visibility === "Public" 
                        ? "bg-emerald-50 text-emerald-600 border-emerald-100" 
                        : ws.visibility === "Private"
                        ? "bg-rose-50 text-rose-600 border-rose-100"
                        : "bg-amber-50 text-amber-600 border-amber-100"
                    }`}>
                      {ws.visibility}
                    </span>
                    <button className="text-zinc-500 hover:text-zinc-900 p-1.5 hover:bg-zinc-50 rounded-lg">
                      <MoreVertical size={16} />
                    </button>
                  </div>
                </div>

                <div className="mt-5 flex-1 cursor-pointer" onClick={() => setSelectedWorkspace(ws)}>
                  <h3 className="font-extrabold text-lg text-zinc-950 hover:text-[#635BFF] transition-colors flex items-center gap-2">
                    {ws.name}
                    <ArrowUpRight size={16} className="opacity-0 group-hover:opacity-100 transition-opacity text-zinc-500" />
                  </h3>
                  <p className="text-zinc-500 text-sm mt-2 line-clamp-2 leading-relaxed">{ws.description}</p>
                </div>

                {/* Micro Stats & Progress */}
                <div className="mt-6 pt-5 border-t border-zinc-100 space-y-4">
                  
                  {/* Storage Meter */}
                  <div>
                    <div className="flex justify-between items-center text-xs font-semibold text-zinc-500 mb-1.5">
                      <span className="flex items-center gap-1.5"><HardDrive size={13} /> Storage Usage</span>
                      <span>{ws.storageUsed} GB / {ws.storageLimit} GB</span>
                    </div>
                    <div className="h-1.5 bg-zinc-100 rounded-full overflow-hidden">
                      <div 
                        style={{ width: `${(ws.storageUsed / ws.storageLimit) * 100}%` }}
                        className="h-full bg-[#635BFF] rounded-full"
                      />
                    </div>
                  </div>

                  {/* Datasets and Members Row */}
                  <div className="flex items-center justify-between text-zinc-500 text-xs font-bold pt-1">
                    <span className="flex items-center gap-1.5"><Database size={15} /> {ws.datasetsCount} Datasets</span>
                    <span className="flex items-center gap-1.5"><Users size={15} /> {ws.membersCount} Members</span>
                    <span className="text-[11px] font-medium text-zinc-500">Updated {ws.lastUpdated}</span>
                  </div>

                </div>
              </motion.div>
            ))}
          </motion.div>
        ) : (
          <motion.div 
            key="table"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="bg-white border border-zinc-200/80 rounded-3xl overflow-hidden shadow-sm border-collapse"
          >
            <div className="overflow-x-auto">
              <table className="w-full text-left text-sm">
                <thead>
                  <tr className="border-b border-zinc-200 bg-zinc-50/50 text-zinc-500 font-bold">
                    <th className="px-6 py-4">Workspace Name</th>
                    <th className="px-6 py-4">Category</th>
                    <th className="px-6 py-4">Visibility</th>
                    <th className="px-6 py-4">Datasets</th>
                    <th className="px-6 py-4">Members</th>
                    <th className="px-6 py-4">Storage</th>
                    <th className="px-6 py-4">Health</th>
                    <th className="px-6 py-4 text-right">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-zinc-100">
                  {filteredWorkspaces.map(ws => (
                    <tr key={ws.id} className="hover:bg-zinc-50/50 transition-colors group">
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-3 cursor-pointer" onClick={() => setSelectedWorkspace(ws)}>
                          <div className="w-8 h-8 rounded-lg bg-zinc-100 flex items-center justify-center font-bold text-xs shrink-0">{ws.name.slice(0,2).toUpperCase()}</div>
                          <div>
                            <span className="font-bold text-zinc-950 hover:text-[#635BFF] transition-colors block">{ws.name}</span>
                            <span className="text-[11px] text-zinc-500 block mt-0.5">{ws.lastUpdated}</span>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 font-semibold text-zinc-600">{ws.category}</td>
                      <td className="px-6 py-4">
                        <span className={`text-[10px] font-black uppercase tracking-widest px-2.5 py-1 rounded-full border ${
                          ws.visibility === "Public" 
                            ? "bg-emerald-50 text-emerald-600 border-emerald-100" 
                            : ws.visibility === "Private"
                            ? "bg-rose-50 text-rose-600 border-rose-100"
                            : "bg-amber-50 text-amber-600 border-amber-100"
                        }`}>
                          {ws.visibility}
                        </span>
                      </td>
                      <td className="px-6 py-4 font-bold text-zinc-600">{ws.datasetsCount} tables</td>
                      <td className="px-6 py-4 font-bold text-zinc-600">{ws.membersCount} active</td>
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-2">
                          <span className="font-semibold text-zinc-700">{ws.storageUsed} GB</span>
                          <span className="text-zinc-500">/ {ws.storageLimit} GB</span>
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-1.5">
                          <span className={`w-2 h-2 rounded-full ${ws.healthScore >= 95 ? "bg-emerald-500" : ws.healthScore >= 90 ? "bg-amber-500" : "bg-red-500"}`} />
                          <span className="font-semibold text-zinc-800">{ws.healthScore}%</span>
                        </div>
                      </td>
                      <td className="px-6 py-4 text-right">
                        <button className="text-zinc-500 hover:text-zinc-900 p-1.5 rounded-lg group-hover:bg-white border border-transparent group-hover:border-zinc-200 transition-all">
                          <MoreVertical size={16} />
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* 5. CREATE WORKSPACE DIALOG (Overlay Drawer) */}
      <AnimatePresence>
        {isCreateOpen && (
          <>
            <motion.div 
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setIsCreateOpen(false)}
              className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50"
            />
            <motion.div 
              initial={{ x: "100%" }}
              animate={{ x: 0 }}
              exit={{ x: "100%" }}
              transition={{ type: "spring", damping: 30, stiffness: 200 }}
              className="fixed top-0 right-0 bottom-0 w-full max-w-lg bg-white border-l border-zinc-200 shadow-2xl z-50 flex flex-col"
            >
              <div className="p-6 border-b border-zinc-100 flex items-center justify-between">
                <div>
                  <h3 className="text-xl font-bold text-zinc-950">Create Workspace</h3>
                  <p className="text-zinc-500 text-xs mt-0.5">Spin up a secure sub-tenant to organize records.</p>
                </div>
                <button onClick={() => setIsCreateOpen(false)} className="p-2 text-zinc-500 hover:text-zinc-900 bg-zinc-50 rounded-lg"><X size={20}/></button>
              </div>

              <form onSubmit={handleCreateWorkspace} className="flex-1 overflow-y-auto p-6 space-y-6">
                <div>
                  <label className="block text-sm font-bold text-zinc-800 mb-2">Workspace Name</label>
                  <input 
                    type="text"
                    required
                    placeholder="e.g. Admissions Department"
                    value={newName}
                    onChange={(e) => setNewName(e.target.value)}
                    className="w-full bg-zinc-50 border border-zinc-200/80 focus:border-[#635BFF]/30 focus:bg-white px-4 py-3 rounded-xl text-sm font-medium outline-none transition-all"
                  />
                </div>

                <div>
                  <label className="block text-sm font-bold text-zinc-800 mb-2">Description</label>
                  <textarea 
                    rows={4}
                    placeholder="Describe the target data, departmental objectives, or scope of this workspace..."
                    value={newDesc}
                    onChange={(e) => setNewDesc(e.target.value)}
                    className="w-full bg-zinc-50 border border-zinc-200/80 focus:border-[#635BFF]/30 focus:bg-white px-4 py-3 rounded-xl text-sm font-medium outline-none transition-all resize-none"
                  />
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-bold text-zinc-800 mb-2">Category</label>
                    <select 
                      value={newCategory}
                      onChange={(e) => setNewCategory(e.target.value)}
                      className="w-full bg-zinc-50 border border-zinc-200 px-3 py-2.5 rounded-xl text-sm font-semibold outline-none cursor-pointer"
                    >
                      {CATEGORIES.filter(c => c !== "All").map(cat => (
                        <option key={cat} value={cat}>{cat}</option>
                      ))}
                    </select>
                  </div>

                  <div>
                    <label className="block text-sm font-bold text-zinc-800 mb-2">Visibility</label>
                    <select 
                      value={newVisibility}
                      onChange={(e) => setNewVisibility(e.target.value)}
                      className="w-full bg-zinc-50 border border-zinc-200 px-3 py-2.5 rounded-xl text-sm font-semibold outline-none cursor-pointer"
                    >
                      <option value="Public">Public (Global search)</option>
                      <option value="Restricted">Restricted (Invitation only)</option>
                      <option value="Private">Private (Org Admins only)</option>
                    </select>
                  </div>
                </div>

                <div className="bg-[#635BFF]/5 border border-[#635BFF]/10 rounded-2xl p-4 flex gap-3 text-sm text-[#635BFF]">
                  <ShieldCheck size={20} className="shrink-0 mt-0.5" />
                  <p className="leading-relaxed">This workspace inherits your enterprise-grade encryption. All datasets, results, and records created inside this node are isolated from other workspaces by default.</p>
                </div>
              </form>

              <div className="p-6 border-t border-zinc-100 flex items-center justify-end gap-3 bg-zinc-50">
                <button type="button" onClick={() => setIsCreateOpen(false)} className="px-4 py-2.5 border border-zinc-200 text-zinc-700 bg-white rounded-xl text-sm font-semibold hover:bg-zinc-50 transition-all">Cancel</button>
                <button type="button" onClick={handleCreateWorkspace} className="px-5 py-2.5 bg-[#635BFF] hover:bg-[#5249E5] text-zinc-900 rounded-xl text-sm font-bold shadow-md shadow-[#635BFF]/10 transition-all">Create Workspace</button>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>

      {/* 6. WORKSPACE DETAILS DRAWER */}
      <AnimatePresence>
        {selectedWorkspace && (
          <>
            <motion.div 
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setSelectedWorkspace(null)}
              className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50"
            />
            <motion.div 
              initial={{ x: "100%" }}
              animate={{ x: 0 }}
              exit={{ x: "100%" }}
              transition={{ type: "spring", damping: 30, stiffness: 200 }}
              className="fixed top-0 right-0 bottom-0 w-full max-w-lg bg-white border-l border-zinc-200 shadow-2xl z-50 flex flex-col text-zinc-900"
            >
              {/* Header */}
              <div className="p-6 border-b border-zinc-100 flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-[#635BFF]/10 text-[#635BFF] rounded-xl flex items-center justify-center font-bold">{selectedWorkspace.name.slice(0,2).toUpperCase()}</div>
                  <div>
                    <h3 className="text-lg font-bold">{selectedWorkspace.name}</h3>
                    <p className="text-zinc-500 text-xs flex items-center gap-1.5 mt-0.5"><Globe size={12} /> {selectedWorkspace.visibility} Workspace</p>
                  </div>
                </div>
                <button onClick={() => setSelectedWorkspace(null)} className="p-2 text-zinc-500 hover:text-zinc-900 bg-zinc-50 rounded-lg"><X size={20}/></button>
              </div>

              {/* Body */}
              <div className="flex-1 overflow-y-auto p-6 space-y-6">
                
                {/* Description */}
                <div>
                  <h4 className="text-xs font-black uppercase text-zinc-500 tracking-wider mb-2">Description</h4>
                  <p className="text-zinc-600 text-sm leading-relaxed">{selectedWorkspace.description}</p>
                </div>

                {/* Analytics Sparkline Mock */}
                <div>
                  <h4 className="text-xs font-black uppercase text-zinc-500 tracking-wider mb-3 flex items-center justify-between">
                    <span>Traffic & Load</span>
                    <span className="text-emerald-500 font-bold flex items-center gap-1"><TrendingUp size={14}/> +12.4%</span>
                  </h4>
                  <div className="bg-zinc-50 border border-zinc-200/60 rounded-2xl p-4 flex items-end gap-1 h-28">
                    {selectedWorkspace.traffic.map((height, i) => (
                      <div 
                        key={i} 
                        style={{ height: `${(height / 150) * 100}%` }}
                        className="flex-1 bg-[#635BFF]/30 group-hover:bg-[#635BFF]/50 rounded-t-sm transition-all"
                      />
                    ))}
                  </div>
                </div>

                {/* Details list */}
                <div className="grid grid-cols-2 gap-4">
                  <div className="bg-zinc-50 border border-zinc-200/50 p-4 rounded-2xl">
                    <span className="text-[10px] font-black uppercase tracking-wider text-zinc-500">Health Index</span>
                    <span className="text-2xl font-black block text-zinc-900 mt-1">{selectedWorkspace.healthScore}%</span>
                    <span className="text-[10px] text-zinc-500 font-medium block mt-0.5 flex items-center gap-1"><CheckCircle2 size={10} className="text-emerald-500"/> Normal Operations</span>
                  </div>
                  <div className="bg-zinc-50 border border-zinc-200/50 p-4 rounded-2xl">
                    <span className="text-[10px] font-black uppercase tracking-wider text-zinc-500">Quota Limit</span>
                    <span className="text-2xl font-black block text-zinc-900 mt-1">{selectedWorkspace.storageLimit} GB</span>
                    <span className="text-[10px] text-zinc-500 font-medium block mt-0.5">Flexible expand available</span>
                  </div>
                </div>

                {/* Recent activity timeline mock */}
                <div>
                  <h4 className="text-xs font-black uppercase text-zinc-500 tracking-wider mb-4">Activity Timeline</h4>
                  <div className="space-y-4">
                    {[
                      { title: "CSV Dataset uploaded", time: "2 hours ago", author: "Alex User", detail: "Added tnpsc-exam-marks.csv to node." },
                      { title: "Team member joined", time: "1 day ago", author: "Sarah Jenkins", detail: "Assigned Moderator role." },
                      { title: "Workspace created", time: "3 days ago", author: "System", detail: "Branding environment initialized." }
                    ].map((activity, idx) => (
                      <div key={idx} className="flex gap-3">
                        <div className="relative flex flex-col items-center">
                          <div className="w-2.5 h-2.5 bg-primary/20 border border-primary text-primary rounded-full shrink-0 mt-1" />
                          {idx !== 2 && <div className="w-0.5 flex-1 bg-zinc-200 my-1" />}
                        </div>
                        <div className="space-y-0.5 pb-2">
                          <span className="text-sm font-bold text-zinc-900 block">{activity.title}</span>
                          <span className="text-xs text-zinc-500 block leading-relaxed">{activity.detail}</span>
                          <span className="text-[10px] text-zinc-500 block mt-1">{activity.time} • by {activity.author}</span>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

              </div>

              {/* Actions Footer */}
              <div className="p-6 border-t border-zinc-100 bg-zinc-50 flex flex-wrap items-center justify-between gap-3">
                <button className="flex items-center gap-2 bg-white hover:bg-zinc-50 border border-zinc-200 text-zinc-700 px-4 py-2.5 rounded-xl text-sm font-semibold transition-all">
                  <SlidersHorizontal size={16} /> Configure
                </button>
                <div className="flex items-center gap-3">
                  <button onClick={() => setSelectedWorkspace(null)} className="px-4 py-2.5 border border-zinc-200 text-zinc-700 bg-white rounded-xl text-sm font-semibold hover:bg-zinc-50 transition-all">Close</button>
                  <button className="flex items-center gap-1.5 bg-[#635BFF] hover:bg-[#5249E5] text-zinc-900 px-4 py-2.5 rounded-xl text-sm font-bold shadow-md shadow-[#635BFF]/10 transition-all">
                    Open Hub <ExternalLink size={14} />
                  </button>
                </div>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>

    </div>
  );
}
