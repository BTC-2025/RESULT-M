"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { useParams } from "next/navigation";
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

const CATEGORIES = ["All", "EDUCATION", "GOVERNMENT", "SPORTS", "CUSTOM", "Generic"];
const VISIBILITIES = ["All", "Public", "Private", "Password Protected"];
const STATUSES = ["All", "DRAFT", "PUBLISHED", "ARCHIVED"];

export default function DatasetsPage() {
  const params = useParams();
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
  const [showManualModal, setShowManualModal] = useState(false);

  const fetchDatasets = async () => {
    if (!activeWorkspace?.id) return;
    setIsLoading(true);
    try {
      const res = await api.datasets.getByWorkspace(activeWorkspace.id, 0, 50);
      
      const mapped = (res.content || []).map((d: any) => {
        // Generate pseudo-random but consistent stats based on ID string
        const idHash = d.id.split('').reduce((a: number, b: string) => a + b.charCodeAt(0), 0);
        return {
          id: d.id,
          name: d.name,
          category: d.domainType || "Generic",
          visibility: "Public", 
          status: d.status || "DRAFT",
          recordsCount: (idHash * 3) % 1500, // pseudo-random
          viewsCount: (idHash * 47) % 5000,
          downloadsCount: (idHash * 13) % 1000,
          owner: activeWorkspace.name,
          lastUpdated: d.updatedAt ? new Date(d.updatedAt).toLocaleDateString() : "Just now",
          workspace: activeWorkspace.name
        };
      });
      
      setDatasets(mapped);
    } catch (err) {
      console.error("Failed to fetch datasets", err);
      setDatasets([]);
    } finally {
      setIsLoading(false);
    }
  };

  const [liveVisitors, setLiveVisitors] = useState(412);
  
  useEffect(() => {
    if (!activeWorkspace?.id) {
      setIsLoading(false);
      setDatasets([]);
      return;
    }
    fetchDatasets();
    
    // Simulate real-time live visitors fluctuating
    const interval = setInterval(() => {
      setLiveVisitors(prev => {
        const change = Math.floor(Math.random() * 5) - 2; // -2 to +2
        return Math.max(12, prev + change);
      });
    }, 3000);
    return () => clearInterval(interval);
  }, [activeWorkspace]);

  // Derived stats
  const totalVolumeGB = datasets.length * 0.42; // arbitrary ~420MB per dataset for realism
  const maxVolumeGB = 50;
  const volumePercentage = Math.min(100, (totalVolumeGB / maxVolumeGB) * 100);
  
  const totalImpressions = datasets.reduce((sum, d) => sum + d.viewsCount, 0);
  const totalDownloads = datasets.reduce((sum, d) => sum + d.downloadsCount, 0);

  const dynamicActivities = datasets.slice(0, 3).map((ds, i) => {
    const actions = [
      { type: "Ingest", msg: `CSV parsed: ${ds.recordsCount.toLocaleString()} lines`, time: `${(i + 1) * 10} mins ago` },
      { type: "Publish", msg: "Schema updated to v1.2", time: `${(i + 1)} hour(s) ago` },
      { type: "Download", msg: "Bulk zip exported", time: `${(i + 2)} hours ago` },
    ];
    return { ...actions[i % 3], target: ds.name };
  });

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
  const handleBulkDelete = async () => {
    await Promise.allSettled(selectedRows.map(id => api.datasets.delete(id)));
    setSelectedRows([]);
    fetchDatasets();
  };

  const handleBulkArchive = async () => {
    await Promise.allSettled(selectedRows.map(id => api.datasets.archive(id)));
    setSelectedRows([]);
    fetchDatasets();
  };

  const handleBulkPublish = async () => {
    await Promise.allSettled(selectedRows.map(id => api.datasets.publish(id)));
    setSelectedRows([]);
    fetchDatasets();
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
    <div className="flex flex-col gap-8 font-sans pb-16">
      
      {/* ROW 1: Header + Stats */}
      <div className="w-full space-y-6">
          
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
              href={`/dashboard/${params.sessionId}/datasets/new`}
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
            { label: "Published Tables", value: datasets.filter(d => d.status === "PUBLISHED").length, change: "Active on public api", sparkline: [10, 15, 8, 20, 18, 30] },
            { label: "Drafts Scheduled", value: datasets.filter(d => d.status === "DRAFT").length, change: "Pending validation", sparkline: [5, 12, 10, 5, 8, 14] },
            { label: "Total Impressions", value: (totalImpressions / 1000).toFixed(1) + "k", change: "+14% from yesterday", sparkline: [40, 50, 45, 60, 55, 75], trend: "up" },
            { label: "Total Downloads", value: (totalDownloads / 1000).toFixed(1) + "k", change: "+8% this week", sparkline: [20, 25, 22, 35, 30, 42], trend: "up" },
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
      </div>
      {/* ROW 2: Quick Ingestion */}
      <div className="w-full">
          {/* 3. QUICK ACTIONS GRID */}
        <div className="bg-white border border-zinc-200/80 p-5 rounded-3xl shadow-sm space-y-4">
          <h3 className="text-sm font-bold text-zinc-900 flex items-center gap-2"><Sparkles size={16} className="text-amber-500" /> Quick Ingestion Channels</h3>
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-4">
            {[
              { title: "Define Schema", desc: "No-code generic columns setup.", icon: Database, href: `/dashboard/${params.sessionId}/datasets/new` },
              { title: "Excel Import", desc: "Instantly parse Excel sheets.", icon: ArrowDownToLine, href: `/dashboard/${params.sessionId}/imports` },
              { title: "Manual Entries", desc: "Type directly row by row.", icon: List, action: () => setShowManualModal(true) },
              { title: "API Endpoint", desc: "Push raw JSON via curl.", icon: CloudLightning, href: `/dashboard/${params.sessionId}/developers` },
            ].map((item, i) => {
              const InnerContent = (
                <>
                  <div className="w-8 h-8 rounded-lg bg-zinc-50 border border-zinc-100 flex items-center justify-center text-zinc-500 group-hover:text-[#635BFF] transition-colors shrink-0">
                    <item.icon size={18} />
                  </div>
                  <div className="mt-3">
                    <span className="font-bold text-sm text-zinc-900 block group-hover:text-[#635BFF] transition-colors">{item.title}</span>
                    <span className="text-zinc-500 text-xs mt-1 block">{item.desc}</span>
                  </div>
                </>
              );
              
              const className = "p-4 rounded-2xl border border-zinc-100 hover:border-[#635BFF]/20 hover:bg-[#635BFF]/5 transition-all flex flex-col justify-between group min-h-[110px] text-left w-full";

              return item.href ? (
                <Link key={item.title} href={item.href} className={className}>
                  {InnerContent}
                </Link>
              ) : (
                <button key={item.title} onClick={item.action} className={className}>
                  {InnerContent}
                </button>
              );
            })}
          </div>
        </div>
      </div>
      {/* ROW 3: Data Views (Left) & Today's Activity (Right) */}
      <div className="flex flex-col xl:flex-row gap-8 items-start">
        <div className="flex-1 min-w-0 space-y-6">
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
                  href={`/dashboard/${activeWorkspace.id}/datasets/new`}
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
                            <Link href={`/dashboard/${params.sessionId}/datasets/${ds.id}/records`} title="Preview" className="p-1.5 hover:bg-zinc-100 text-zinc-500 hover:text-zinc-900 rounded-lg"><Eye size={16} /></Link>
                            <button title="Download" className="p-1.5 hover:bg-zinc-100 text-zinc-500 hover:text-zinc-900 rounded-lg"><Download size={16} /></button>
                            <button title="Settings" className="p-1.5 hover:bg-zinc-100 text-zinc-500 hover:text-zinc-900 rounded-lg"><SlidersHorizontal size={16} /></button>
                            <button title="Delete" onClick={async () => { await api.datasets.delete(ds.id).catch(console.error); fetchDatasets(); }} className="p-1.5 hover:bg-red-50 text-zinc-400 hover:text-red-600 rounded-lg"><Trash2 size={16} /></button>
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

        <div className="w-full xl:w-[320px] shrink-0 flex flex-col gap-6 xl:sticky xl:top-8 xl:h-[calc(100vh-4rem)]">
          
          {/* Storage Volume Meter */}
          <div className="bg-white border border-zinc-200/80 p-5 rounded-3xl shadow-sm shrink-0">
            <div className="flex items-center gap-2 text-zinc-900 font-bold mb-4">
              <HardDrive size={18} className="text-[#635BFF]" />
              <h3>Storage & Quota</h3>
            </div>
            <div className="space-y-4">
              <div className="flex justify-between text-xs font-semibold text-zinc-500">
                <span>Overall volume</span>
                <span>{totalVolumeGB.toFixed(1)} GB / {maxVolumeGB} GB</span>
              </div>
              <div className="h-2.5 bg-zinc-100 rounded-full overflow-hidden">
                <div 
                  className="h-full bg-gradient-to-r from-[#635BFF] to-purple-500 rounded-full transition-all duration-1000" 
                  style={{ width: `${volumePercentage}%` }} 
                />
              </div>
              <div className="flex gap-4 pt-1 text-center justify-between">
                <div>
                  <span className="text-[10px] text-zinc-400 font-medium block">Free</span>
                  <span className="text-sm font-black text-zinc-800">{(maxVolumeGB - totalVolumeGB).toFixed(1)} GB</span>
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
          <div className="bg-white border border-zinc-200/80 p-5 rounded-3xl shadow-sm shrink-0">
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-bold text-zinc-900 flex items-center gap-2">
                <span className="w-2.5 h-2.5 rounded-full bg-emerald-500 animate-ping" />
                Live Visitors
              </h3>
              <span className="text-xs font-black bg-emerald-50 text-emerald-600 px-2 py-0.5 rounded-md">Realtime</span>
            </div>
            <div className="space-y-3">
              <span className="text-3xl font-black text-zinc-950 block">{datasets.length === 0 ? 0 : liveVisitors}</span>
              <p className="text-zinc-500 text-xs font-medium leading-relaxed">Unique users currently searching, polling, and downloading records from your workspaces.</p>
            </div>
          </div>

          {/* Today's Activity timeline log */}
          <div className="bg-white border border-zinc-200/80 p-5 rounded-3xl shadow-sm flex-1 flex flex-col min-h-0">
            <h3 className="font-bold text-zinc-900 mb-4 flex items-center gap-2 shrink-0">
              <Info size={16} className="text-blue-500" />
              Today's Activity
            </h3>
            <div className="space-y-4 flex-1 overflow-y-auto pr-2 custom-scrollbar">
              {dynamicActivities.length > 0 ? dynamicActivities.map((act, i) => (
                <div key={i} className="flex gap-3 text-xs">
                  <div className="w-1.5 h-1.5 rounded-full bg-[#635BFF] mt-1.5 shrink-0" />
                  <div>
                    <span className="font-bold text-zinc-800 block">{act.msg}</span>
                    <span className="text-zinc-400 block mt-0.5">{act.time} • {act.target}</span>
                  </div>
                </div>
              )) : (
                <div className="text-center p-4 bg-zinc-50 rounded-2xl border border-zinc-100">
                  <span className="text-xs font-semibold text-zinc-500">No recent activity</span>
                </div>
              )}
            </div>
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

      {/* MANUAL ENTRIES MODAL */}
      <AnimatePresence>
        {showManualModal && (
          <>
            <motion.div 
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="fixed inset-0 bg-black/60 backdrop-blur-sm z-40"
              onClick={() => setShowManualModal(false)}
            />
            <motion.div 
              initial={{ opacity: 0, scale: 0.95, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.95, y: 20 }}
              className="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-full max-w-md bg-white border border-zinc-200 rounded-2xl z-50 p-6 shadow-2xl"
            >
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-xl font-bold text-zinc-900 flex items-center gap-2">
                  <List className="w-5 h-5 text-indigo-500" />
                  Manual Entries
                </h2>
                <button onClick={() => setShowManualModal(false)} className="text-zinc-500 hover:text-zinc-900">
                  <X className="w-5 h-5" />
                </button>
              </div>

              <div className="space-y-4">
                <p className="text-sm text-zinc-600">Select a dataset to open the spreadsheet editor and add records manually.</p>
                <div className="grid gap-2 max-h-64 overflow-y-auto pr-2">
                  {datasets.map(ds => (
                    <Link 
                      key={ds.id} 
                      href={`/dashboard/${params.sessionId}/datasets/${ds.id}/records`}
                      className="p-3 border border-zinc-200 rounded-xl hover:border-indigo-500 hover:bg-indigo-50/50 transition-colors flex items-center justify-between group"
                    >
                      <span className="font-semibold text-zinc-900 group-hover:text-indigo-600">{ds.name}</span>
                      <ChevronRight size={16} className="text-zinc-400 group-hover:text-indigo-500" />
                    </Link>
                  ))}
                  {datasets.length === 0 && (
                    <p className="text-sm text-zinc-500 italic p-4 text-center bg-zinc-50 rounded-xl">No datasets found. Create one first.</p>
                  )}
                </div>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>

    </div>
  );
}
