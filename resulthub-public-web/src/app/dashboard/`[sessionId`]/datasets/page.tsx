"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { motion, AnimatePresence } from "framer-motion";
import { api } from "@/lib/api";
import { useWorkspace } from "../WorkspaceContext";
import { 
  Database, Plus, Search, Calendar, ChevronRight, Grid, List, 
  Trash2, Archive, CheckCircle2, Eye, ArrowDownToLine, SlidersHorizontal, 
  ArrowUpRight, Users, CloudLightning, ShieldAlert, Sparkles, HardDrive, 
  HelpCircle, ChevronDown, Check, Folder, Info, Download, RefreshCw, Lock, Globe, X
} from "lucide-react";

// Mock datasets representation (used as fallback or schema ref)
const INITIAL_DATASETS: any[] = [];

const CATEGORIES = ["All", "Academic", "Healthcare", "Government", "Corporate", "Athletics"];
const VISIBILITIES = ["All", "Public", "Private", "Password Protected"];
const STATUSES = ["All", "Draft", "Published", "Archived", "Scheduled"];

export default function DatasetsPage() {
  const { activeWorkspace } = useWorkspace();
  const [datasets, setDatasets] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  
  const [viewMode, setViewMode] = useState<"grid" | "table">("table");
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedCategory, setSelectedCategory] = useState("All");
  const [selectedVisibility, setSelectedVisibility] = useState("All");
  const [selectedStatus, setSelectedStatus] = useState("All");
  const [selectedRows, setSelectedRows] = useState<string[]>([]);
  const [showFilters, setShowFilters] = useState(false);

  useEffect(() => {
    if (!activeWorkspace?.id) {
      setIsLoading(false);
      setDatasets([]);
      return;
    }

    const fetchDatasets = async () => {
      setIsLoading(true);
      try {
        const res = await api.datasets.getByWorkspace(activeWorkspace.id, 0, 50);
        
        // Map backend response to UI format
        const mapped = (res.content || []).map((d: any) => ({
          id: d.id,
          name: d.name,
          category: d.domainType || "Generic",
          visibility: "Public", // To be dynamic later
          status: d.status || "Draft",
          recordsCount: 0,
          viewsCount: 0,
          downloadsCount: 0,
          owner: activeWorkspace.name,
          lastUpdated: d.updatedAt ? new Date(d.updatedAt).toLocaleDateString() : "Just now",
          workspace: activeWorkspace.name
        }));
        
        setDatasets(mapped);
      } catch (err) {
        console.error("Failed to fetch datasets", err);
        setDatasets([]);
      } finally {
        setIsLoading(false);
      }
    };

    fetchDatasets();
  }, [activeWorkspace]);

  // Toggle single row selection
  const handleSelectRow = (id: string) => {
    if (selectedRows.includes(id)) {
      setSelectedRows(selectedRows.filter(rowId => rowId !== id));
    } else {
      setSelectedRows([...selectedRows, id]);
    }
  };

  // Toggle all row selections
  const handleSelectAllRows = () => {
    if (selectedRows.length === filteredDatasets.length) {
      setSelectedRows([]);
    } else {
      setSelectedRows(filteredDatasets.map(d => d.id));
    }
  };

  // Bulk operation actions
  const handleBulkDelete = () => {
    setDatasets(datasets.filter(d => !selectedRows.includes(d.id)));
    setSelectedRows([]);
  };

  const handleBulkArchive = () => {
    setDatasets(datasets.map(d => selectedRows.includes(d.id) ? { ...d, status: "Archived" } : d));
    setSelectedRows([]);
  };

  const handleBulkPublish = () => {
    setDatasets(datasets.map(d => selectedRows.includes(d.id) ? { ...d, status: "Published" } : d));
    setSelectedRows([]);
  };

  // Filters application
  const filteredDatasets = datasets.filter(d => {
    const ownerStr = d.owner ? d.owner.toLowerCase() : "";
    const nameStr = d.name ? d.name.toLowerCase() : "";
    const searchLow = searchQuery.toLowerCase();
    
    const matchesSearch = nameStr.includes(searchLow) || ownerStr.includes(searchLow);
    const matchesCategory = selectedCategory === "All" || d.category === selectedCategory;
    const matchesVisibility = selectedVisibility === "All" || d.visibility === selectedVisibility;
    const matchesStatus = selectedStatus === "All" || d.status === selectedStatus;
    
    return matchesSearch && matchesCategory && matchesVisibility && matchesStatus;
  });

  return (
    <div className="flex flex-col xl:flex-row gap-8 font-sans pb-16">
      
      {/* LEFT/MAIN CONTAINER: 75% width on large screens */}
      <div className="flex-1 min-w-0 space-y-8">
        
        {/* 1. HEADER SECTION */}
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-zinc-200/60 pb-6">
          <div>
            <h1 className="text-3xl font-extrabold tracking-tight text-zinc-950 flex items-center gap-3">
              Datasets
              <span className="text-xs font-semibold px-2.5 py-0.5 rounded-full bg-indigo-50 border border-indigo-100 text-[#635BFF]">
                {datasets.length} Total
              </span>
            </h1>
            <p className="text-zinc-500 text-sm mt-1">Create, organize, configure and publish structured databases for public or private access.</p>
          </div>
          <div className="flex items-center gap-3">
            <Link 
              href="/dashboard/datasets/new"
              className="flex items-center gap-2 bg-[#635BFF] hover:bg-[#5249E5] text-white px-5 py-2.5 rounded-xl text-sm font-bold shadow-md shadow-[#635BFF]/10 transition-all active:scale-95 shrink-0"
            >
              <Plus size={16} />
              New Dataset
            </Link>
            <button className="flex items-center gap-2 bg-white border border-zinc-200 text-zinc-700 px-4 py-2.5 rounded-xl text-sm font-semibold hover:bg-zinc-50 transition-colors shadow-sm shrink-0">
              <ArrowDownToLine size={16} />
              Import CSV
            </button>
          </div>
        </div>

        {/* 2. STATS RIBBON */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          {[
            { label: "Published Tables", value: datasets.filter(d => d.status === "Published").length, change: "Active on public api", sparkline: [10, 15, 8, 20, 18, 30] },
            { label: "Drafts Scheduled", value: datasets.filter(d => d.status === "Draft" || d.status === "Scheduled").length, change: "Pending validation", sparkline: [5, 12, 10, 5, 8, 14] },
            { label: "Today's Impressions", value: "199.5k", change: "+14% from yesterday", sparkline: [40, 50, 45, 60, 55, 75], trend: "up" },
            { label: "Total Downloads", value: "96.6k", change: "+8% this week", sparkline: [20, 25, 22, 35, 30, 42], trend: "up" },
          ].map((stat, idx) => (
            <motion.div
              key={stat.label}
              initial={{ opacity: 0, y: 15 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: idx * 0.05 }}
              className="bg-white border border-zinc-200/80 p-4 rounded-2xl shadow-sm cursor-default hover:border-zinc-300 transition-all flex flex-col justify-between min-h-[120px]"
            >
              <div>
                <span className="text-[10px] font-black uppercase tracking-wider text-zinc-400 block">{stat.label}</span>
                <span className="text-2xl font-black text-zinc-950 mt-1 block">{stat.value}</span>
              </div>
              <div className="flex items-end justify-between mt-3">
                <span className={`text-[10px] font-semibold ${stat.trend === "up" ? "text-emerald-600" : "text-zinc-500"}`}>
                  {stat.change}
                </span>
                
                {/* SVG Mini Sparkline */}
                <svg className="w-14 h-6 text-[#635BFF]" viewBox="0 0 60 20">
                  <polyline
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="1.5"
                    points={stat.sparkline.map((val, i) => `${i * 10}, ${20 - (val / 30) * 18}`).join(" ")}
                  />
                </svg>
              </div>
            </motion.div>
          ))}
        </div>

        {/* 3. QUICK ACTIONS GRID */}
        <div className="bg-white border border-zinc-200/80 p-5 rounded-3xl shadow-sm space-y-4">
          <h3 className="text-sm font-bold text-zinc-900 flex items-center gap-2"><Sparkles size={16} className="text-amber-500" /> Quick Ingestion Channels</h3>
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-4">
            {[
              { title: "Define Schema", desc: "No-code generic columns setup.", icon: Database, href: "/dashboard/datasets/new" },
              { title: "Excel Import", desc: "Instantly parse Excel sheets.", icon: ArrowDownToLine, href: "#" },
              { title: "Manual Entries", desc: "Type directly row by row.", icon: List, href: "#" },
              { title: "API Endpoint", desc: "Push raw JSON via curl.", icon: CloudLightning, href: "#" },
            ].map((action, i) => (
              <Link 
                key={action.title} 
                href={action.href}
                className="p-4 rounded-2xl border border-zinc-100 hover:border-[#635BFF]/20 hover:bg-[#635BFF]/5 transition-all flex flex-col justify-between group min-h-[110px]"
              >
                <div className="w-8 h-8 rounded-lg bg-zinc-50 border border-zinc-100 flex items-center justify-center text-zinc-500 group-hover:text-[#635BFF] transition-colors shrink-0">
                  <action.icon size={18} />
                </div>
                <div className="mt-3">
                  <span className="font-bold text-sm text-zinc-900 block group-hover:text-[#635BFF] transition-colors">{action.title}</span>
                  <span className="text-[11px] text-zinc-400 block mt-0.5">{action.desc}</span>
                </div>
              </Link>
            ))}
          </div>
        </div>

        {/* 4. FILTER CONTROL BAR */}
        <div className="bg-white border border-zinc-200/80 p-4 rounded-3xl shadow-sm space-y-4">
          <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-4">
            
            {/* Search */}
            <div className="relative flex-1 max-w-md">
              <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 text-zinc-400" size={18} />
              <input 
                type="text"
                placeholder="Search datasets by name, code or creator..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full bg-zinc-50 border border-zinc-200/80 focus:border-[#635BFF]/30 focus:bg-white pl-11 pr-4 py-2.5 rounded-xl text-sm font-medium outline-none transition-all"
              />
            </div>

            {/* Layout view controls */}
            <div className="flex items-center gap-3 self-end sm:self-auto">
              <button 
                onClick={() => setShowFilters(!showFilters)}
                className={`flex items-center gap-2 px-4 py-2.5 border rounded-xl text-sm font-semibold transition-all ${
                  showFilters ? "bg-zinc-50 text-zinc-900 border-zinc-300" : "bg-white text-zinc-600 border-zinc-200 hover:bg-zinc-50"
                }`}
              >
                <SlidersHorizontal size={16} /> Filters
              </button>
              <div className="h-6 w-px bg-zinc-200 hidden sm:block"></div>
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

          {/* Expandable filters shelf */}
          <AnimatePresence>
            {showFilters && (
              <motion.div 
                initial={{ opacity: 0, height: 0 }}
                animate={{ opacity: 1, height: "auto" }}
                exit={{ opacity: 0, height: 0 }}
                className="grid grid-cols-1 sm:grid-cols-3 gap-4 pt-3 border-t border-zinc-100 overflow-hidden"
              >
                <div>
                  <label className="block text-xs font-bold text-zinc-500 mb-1.5 uppercase tracking-wider">Category</label>
                  <select 
                    value={selectedCategory}
                    onChange={(e) => setSelectedCategory(e.target.value)}
                    className="w-full bg-zinc-50 border border-zinc-200 px-3 py-2 rounded-xl text-sm font-semibold outline-none"
                  >
                    {CATEGORIES.map(c => <option key={c} value={c}>{c}</option>)}
                  </select>
                </div>
                <div>
                  <label className="block text-xs font-bold text-zinc-500 mb-1.5 uppercase tracking-wider">Visibility</label>
                  <select 
                    value={selectedVisibility}
                    onChange={(e) => setSelectedVisibility(e.target.value)}
                    className="w-full bg-zinc-50 border border-zinc-200 px-3 py-2 rounded-xl text-sm font-semibold outline-none"
                  >
                    {VISIBILITIES.map(v => <option key={v} value={v}>{v}</option>)}
                  </select>
                </div>
                <div>
                  <label className="block text-xs font-bold text-zinc-500 mb-1.5 uppercase tracking-wider">Status</label>
                  <select 
                    value={selectedStatus}
                    onChange={(e) => setSelectedStatus(e.target.value)}
                    className="w-full bg-zinc-50 border border-zinc-200 px-3 py-2 rounded-xl text-sm font-semibold outline-none"
                  >
                    {STATUSES.map(s => <option key={s} value={s}>{s}</option>)}
                  </select>
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>

        {/* 5. DATASET MAIN VIEWS */}
        <AnimatePresence mode="wait">
          {filteredDatasets.length === 0 ? (
            <motion.div 
              key="empty"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="bg-white border border-zinc-200/80 rounded-3xl p-12 text-center shadow-sm max-w-xl mx-auto mt-8"
            >
              <div className="w-16 h-16 bg-zinc-50 rounded-2xl flex items-center justify-center border border-zinc-100 mx-auto text-zinc-400 mb-6">
                <Database size={32} />
              </div>
              <h3 className="text-xl font-bold text-zinc-950 mb-2">Create your first dataset</h3>
              <p className="text-zinc-500 text-sm mb-8 max-w-md mx-auto leading-relaxed">
                Datasets power ResultHub. Publish results, rankings, government lists, sports statistics, financial data, and much more.
              </p>
              {activeWorkspace ? (
                <Link 
                  href="/dashboard/datasets/new"
                  className="bg-[#635BFF] text-white px-6 py-3 rounded-xl font-bold hover:bg-[#5249E5] transition-all"
                >
                  Create Dataset
                </Link>
              ) : (
                <div className="text-red-500 font-medium">Please create or select a Workspace first.</div>
              )}
            </motion.div>
          ) : viewMode === "grid" ? (
            <motion.div 
              key="grid"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="grid grid-cols-1 md:grid-cols-2 gap-6"
            >
              {filteredDatasets.map(ds => (
                <div key={ds.id} className="bg-white border border-zinc-200/80 p-6 rounded-3xl shadow-sm hover:shadow-md transition-all hover:border-zinc-300 flex flex-col group relative">
                  <div className="absolute top-6 left-6">
                    <input 
                      type="checkbox"
                      checked={selectedRows.includes(ds.id)}
                      onChange={() => handleSelectRow(ds.id)}
                      className="w-4 h-4 rounded border-zinc-300 text-[#635BFF] focus:ring-[#635BFF] cursor-pointer"
                    />
                  </div>
                  <div className="flex justify-between items-start pl-8">
                    <div>
                      <span className="text-[10px] font-black uppercase tracking-wider text-zinc-400">{ds.category}</span>
                      <h3 className="font-extrabold text-lg text-zinc-950 mt-1 block">{ds.name}</h3>
                    </div>
                    <div className="flex items-center gap-2">
                      <span className={`text-[10px] font-black uppercase px-2 py-0.5 rounded-full border ${
                        ds.status === "Published" ? "bg-emerald-50 text-emerald-600 border-emerald-100" :
                        ds.status === "Draft" ? "bg-zinc-50 text-zinc-600 border-zinc-200" : "bg-amber-50 text-amber-600 border-amber-100"
                      }`}>
                        {ds.status}
                      </span>
                    </div>
                  </div>

                  <p className="text-zinc-500 text-sm mt-3 pl-8 flex-1 leading-relaxed">Workspace: <span className="font-bold text-zinc-600">{ds.workspace}</span></p>

                  <div className="mt-6 pt-4 border-t border-zinc-100 flex items-center justify-between text-zinc-500 text-xs font-bold pl-8">
                    <span>{ds.recordsCount.toLocaleString()} Records</span>
                    <span>{ds.viewsCount.toLocaleString()} Views</span>
                    <span>{ds.downloadsCount.toLocaleString()} DLs</span>
                  </div>
                </div>
              ))}
            </motion.div>
          ) : (
            <motion.div 
              key="table"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="bg-white border border-zinc-200/80 rounded-3xl overflow-hidden shadow-sm"
            >
              <div className="overflow-x-auto">
                <table className="w-full text-left text-sm whitespace-nowrap">
                  <thead>
                    <tr className="border-b border-zinc-200 bg-zinc-50/50 text-zinc-500 font-bold select-none">
                      <th className="px-6 py-4 w-10">
                        <input 
                          type="checkbox"
                          checked={selectedRows.length === filteredDatasets.length && filteredDatasets.length > 0}
                          onChange={handleSelectAllRows}
                          className="w-4 h-4 rounded border-zinc-300 text-[#635BFF] focus:ring-[#635BFF] cursor-pointer"
                        />
                      </th>
                      <th className="px-6 py-4">Dataset</th>
                      <th className="px-6 py-4">Category</th>
                      <th className="px-6 py-4">Workspace</th>
                      <th className="px-6 py-4">Visibility</th>
                      <th className="px-6 py-4">Status</th>
                      <th className="px-6 py-4">Records</th>
                      <th className="px-6 py-4">Views</th>
                      <th className="px-6 py-4">Owner</th>
                      <th className="px-6 py-4 text-right">Actions</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-zinc-100">
                    {filteredDatasets.map(ds => (
                      <tr key={ds.id} className={`hover:bg-zinc-50/50 transition-colors group ${selectedRows.includes(ds.id) ? "bg-indigo-50/20" : ""}`}>
                        <td className="px-6 py-4">
                          <input 
                            type="checkbox"
                            checked={selectedRows.includes(ds.id)}
                            onChange={() => handleSelectRow(ds.id)}
                            className="w-4 h-4 rounded border-zinc-300 text-[#635BFF] focus:ring-[#635BFF] cursor-pointer"
                          />
                        </td>
                        <td className="px-6 py-4">
                          <div>
                            <span className="font-bold text-zinc-950 block">{ds.name}</span>
                            <span className="text-[11px] text-zinc-400 block mt-0.5">Updated {ds.lastUpdated}</span>
                          </div>
                        </td>
                        <td className="px-6 py-4 font-semibold text-zinc-600">{ds.category}</td>
                        <td className="px-6 py-4 text-zinc-500 font-medium">{ds.workspace}</td>
                        <td className="px-6 py-4">
                          <span className={`inline-flex items-center gap-1.5 text-[10px] font-black uppercase tracking-wider px-2 py-0.5 rounded-full border ${
                            ds.visibility === "Public" ? "bg-emerald-50 text-emerald-600 border-emerald-100" :
                            ds.visibility === "Private" ? "bg-rose-50 text-rose-600 border-rose-100" : "bg-amber-50 text-amber-600 border-amber-100"
                          }`}>
                            {ds.visibility === "Public" ? <Globe size={10} /> : <Lock size={10} />}
                            {ds.visibility}
                          </span>
                        </td>
                        <td className="px-6 py-4">
                          <span className={`text-[10px] font-black uppercase px-2 py-0.5 rounded-full border ${
                            ds.status === "Published" ? "bg-emerald-50 text-emerald-600 border-emerald-100" :
                            ds.status === "Draft" ? "bg-zinc-50 text-zinc-600 border-zinc-200" :
                            ds.status === "Archived" ? "bg-rose-50 text-rose-600 border-rose-100" : "bg-blue-50 text-blue-600 border-blue-100"
                          }`}>
                            {ds.status}
                          </span>
                        </td>
                        <td className="px-6 py-4 font-bold text-zinc-600">{ds.recordsCount.toLocaleString()}</td>
                        <td className="px-6 py-4 font-bold text-zinc-600">{ds.viewsCount.toLocaleString()}</td>
                        <td className="px-6 py-4 text-zinc-500 font-medium">{ds.owner}</td>
                        <td className="px-6 py-4 text-right">
                          <div className="flex items-center justify-end gap-1.5 opacity-0 group-hover:opacity-100 transition-opacity">
                            <button title="Preview" className="p-1.5 hover:bg-zinc-100 text-zinc-500 hover:text-zinc-900 rounded-lg"><Eye size={16} /></button>
                            <button title="Download" className="p-1.5 hover:bg-zinc-100 text-zinc-500 hover:text-zinc-900 rounded-lg"><Download size={16} /></button>
                            <button title="Delete" onClick={() => setDatasets(datasets.filter(item => item.id !== ds.id))} className="p-1.5 hover:bg-red-50 text-zinc-400 hover:text-red-600 rounded-lg"><Trash2 size={16} /></button>
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </motion.div>
          )}
        </AnimatePresence>

      </div>

      {/* RIGHT SIDE PANEL: INSIGHTS & STATS (25% width, sticky) */}
      <div className="w-full xl:w-[320px] shrink-0 space-y-6">
        
        {/* Storage Volume Meter */}
        <div className="bg-white border border-zinc-200/80 p-5 rounded-3xl shadow-sm">
          <div className="flex items-center gap-2 text-zinc-900 font-bold mb-4">
            <HardDrive size={18} className="text-[#635BFF]" />
            <h3>Storage & Quota</h3>
          </div>
          <div className="space-y-4">
            <div className="flex justify-between text-xs font-semibold text-zinc-500">
              <span>Overall volume</span>
              <span>21.5 GB / 50 GB</span>
            </div>
            <div className="h-2.5 bg-zinc-100 rounded-full overflow-hidden">
              <div className="h-full bg-gradient-to-r from-[#635BFF] to-purple-500 rounded-full w-[43%]" />
            </div>
            <div className="flex gap-4 pt-1 text-center justify-between">
              <div>
                <span className="text-[10px] text-zinc-400 font-medium block">Free</span>
                <span className="text-sm font-black text-zinc-800">28.5 GB</span>
              </div>
              <div className="w-px h-6 bg-zinc-200"></div>
              <div>
                <span className="text-[10px] text-zinc-400 font-medium block">Premium band</span>
                <span className="text-sm font-black text-emerald-600">Active</span>
              </div>
            </div>
          </div>
        </div>

        {/* Live Visitors section */}
        <div className="bg-white border border-zinc-200/80 p-5 rounded-3xl shadow-sm">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-bold text-zinc-900 flex items-center gap-2">
              <span className="w-2.5 h-2.5 rounded-full bg-emerald-500 animate-ping" />
              Live Visitors
            </h3>
            <span className="text-xs font-black bg-emerald-50 text-emerald-600 px-2 py-0.5 rounded-md">Realtime</span>
          </div>
          <div className="space-y-3">
            <span className="text-3xl font-black text-zinc-950 block">412</span>
            <p className="text-zinc-500 text-xs font-medium leading-relaxed">Unique users currently searching, polling, and downloading records from your workspaces.</p>
          </div>
        </div>

        {/* Today's Activity timeline log */}
        <div className="bg-white border border-zinc-200/80 p-5 rounded-3xl shadow-sm">
          <h3 className="font-bold text-zinc-900 mb-4 flex items-center gap-2">
            <Info size={16} className="text-blue-500" />
            Today's Activity
          </h3>
          <div className="space-y-4">
            {[
              { type: "Ingest", msg: "CSV parsed: 42,350 lines", time: "10 mins ago", target: "TNPSC Group IV" },
              { type: "Publish", msg: "Schema updated to v1.2", time: "1 hour ago", target: "Cardiology Trial" },
              { type: "Download", msg: "Bulk zip exported", time: "4 hours ago", target: "Semester 6 Grades" },
            ].map((act, i) => (
              <div key={i} className="flex gap-3 text-xs">
                <div className="w-1.5 h-1.5 rounded-full bg-zinc-300 mt-1.5 shrink-0" />
                <div>
                  <span className="font-bold text-zinc-800 block">{act.msg}</span>
                  <span className="text-zinc-400 block mt-0.5">{act.time} • {act.target}</span>
                </div>
              </div>
            ))}
          </div>
        </div>

      </div>

      {/* 6. BULK OPERATIONS FLOAT BAR */}
      <AnimatePresence>
        {selectedRows.length > 0 && (
          <motion.div 
            initial={{ y: 100, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            exit={{ y: 100, opacity: 0 }}
            transition={{ type: "spring", stiffness: 260, damping: 25 }}
            className="fixed bottom-6 left-1/2 -translate-x-1/2 bg-zinc-950/90 text-white backdrop-blur-xl border border-white/10 px-6 py-4 rounded-2xl shadow-2xl z-40 flex items-center gap-6"
          >
            <span className="text-sm font-semibold shrink-0">
              <span className="text-[#635BFF] font-black">{selectedRows.length}</span> datasets selected
            </span>
            <div className="h-5 w-px bg-white/20"></div>
            <div className="flex items-center gap-2">
              <button 
                onClick={handleBulkPublish}
                className="flex items-center gap-1.5 bg-[#635BFF] hover:bg-[#5249E5] text-white px-3.5 py-2 rounded-xl text-xs font-bold transition-all"
              >
                <CheckCircle2 size={14} /> Publish
              </button>
              <button 
                onClick={handleBulkArchive}
                className="flex items-center gap-1.5 bg-white/10 hover:bg-white/20 text-white px-3.5 py-2 rounded-xl text-xs font-bold transition-all border border-white/10"
              >
                <Archive size={14} /> Archive
              </button>
              <button 
                onClick={handleBulkDelete}
                className="flex items-center gap-1.5 bg-red-600/90 hover:bg-red-600 text-white px-3.5 py-2 rounded-xl text-xs font-bold transition-all"
              >
                <Trash2 size={14} /> Delete
              </button>
            </div>
            <button 
              onClick={() => setSelectedRows([])} 
              className="p-1 bg-white/10 hover:bg-white/20 rounded-lg text-white/70 hover:text-white transition-colors"
            >
              <X size={16} />
            </button>
          </motion.div>
        )}
      </AnimatePresence>

    </div>
  );
}
