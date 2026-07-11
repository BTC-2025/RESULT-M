"use client";

import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { api } from "@/lib/api";
import { 
  Search, SlidersHorizontal, Grid, List, Bookmark, Library, Building2, 
  WifiOff, ArrowUpRight, Folder, Download, Share2, Trash2, FileText, 
  BarChart3, Medal, Scale, HeartPulse, HardDrive, Settings, Star,
  ChevronRight, Sparkles
} from "lucide-react";
import Link from "next/link";

const CATEGORIES = ["All", "Education", "Government", "Sports", "Politics", "Finance", "Technology", "Entertainment", "Law", "Healthcare", "Pinned", "Offline"];

type CardType = "result" | "document" | "poll" | "discussion" | "organization";

interface SavedItem {
  id: string;
  type: CardType;
  title: string;
  organization: string;
  category: string;
  date: string;
  timeGroup: "Today" | "Yesterday" | "This Week" | "Earlier";
  tags: string[];
  isOffline?: boolean;
}

// Helper to group by time
const getTimeGroup = (dateStr: string): "Today" | "Yesterday" | "This Week" | "Earlier" => {
  if (!dateStr) return "Earlier";
  const date = new Date(dateStr);
  const now = new Date();
  const diffDays = Math.floor((now.getTime() - date.getTime()) / (1000 * 3600 * 24));
  if (diffDays === 0) return "Today";
  if (diffDays === 1) return "Yesterday";
  if (diffDays < 7) return "This Week";
  return "Earlier";
};

export default function BookmarksPage() {
  const [activeCategory, setActiveCategory] = useState("All");
  const [viewMode, setViewMode] = useState<"grid" | "list">("grid");
  const [searchQuery, setSearchQuery] = useState("");
  const [bookmarkedItems, setBookmarkedItems] = useState<SavedItem[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    fetchBookmarks();
  }, []);

  const fetchBookmarks = async () => {
    try {
      setIsLoading(true);
      const res = await api.bookmarks.get();
      
      const data = Array.isArray(res) ? res : res.items || res.content || [];
      const mapped = data.map((item: any) => ({
        id: item.id,
        type: item.type?.toLowerCase() || "discussion",
        title: item.payload?.title || item.payload?.question || item.title || "Untitled Post",
        organization: item.authorName || "Unknown User",
        category: item.payload?.category || item.payload?.domainType || "General",
        date: item.createdAt ? new Date(item.createdAt).toLocaleDateString() : "Recently",
        timeGroup: getTimeGroup(item.createdAt),
        tags: item.type === "POLL" ? ["Poll"] : [],
        isOffline: false
      }));
      
      setBookmarkedItems(mapped);
    } catch (error) {
      console.error("Failed to fetch bookmarks:", error);
    } finally {
      setIsLoading(false);
    }
  };

  const filteredItems = bookmarkedItems.filter(item => 
    (activeCategory === "All" || item.category === activeCategory || (activeCategory === "Pinned") || (activeCategory === "Offline" && item.isOffline)) &&
    (item.title.toLowerCase().includes(searchQuery.toLowerCase()) || item.organization.toLowerCase().includes(searchQuery.toLowerCase()))
  );

  const groupedItems = filteredItems.reduce((acc, item) => {
    if (!acc[item.timeGroup]) acc[item.timeGroup] = [];
    acc[item.timeGroup].push(item);
    return acc;
  }, {} as Record<string, SavedItem[]>);

  const timeGroupsOrder = ["Today", "Yesterday", "This Week", "Earlier"];

  // Animation variants
  const pageVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: { opacity: 1, y: 0, transition: { staggerChildren: 0.1 } }
  };
  
  const itemVariants = {
    hidden: { opacity: 0, scale: 0.95 },
    visible: { opacity: 1, scale: 1 }
  };

  const getIconForType = (type: CardType) => {
    switch (type) {
      case "result": return <BarChart3 size={16} />;
      case "document": return <FileText size={16} />;
      case "poll": return <SlidersHorizontal size={16} />;
      case "discussion": return <Sparkles size={16} />;
      case "organization": return <Building2 size={16} />;
      default: return <Bookmark size={16} />;
    }
  };

  return (
    <div className="flex w-full min-h-screen bg-[#FAFAFA] font-sans selection:bg-[#6C5CE7]/20">
      
      {/* MAIN CONTENT */}
      <div className="flex-1 max-w-5xl mx-auto px-4 sm:px-8 py-8 lg:py-12 min-w-0">
        
        {/* HEADER */}
        <motion.div initial="hidden" animate="visible" variants={pageVariants} className="mb-10">
          <div className="flex flex-col md:flex-row md:items-end justify-between gap-6 mb-6">
            <div>
              <h1 className="text-4xl font-extrabold text-zinc-900 tracking-tight mb-2">Bookmarks</h1>
              <p className="text-zinc-500 font-medium">Your personal library of saved results, datasets, and discussions.</p>
            </div>
            
            <div className="flex items-center gap-3">
              <button className="flex items-center gap-2 px-4 py-2 bg-white border border-zinc-200 rounded-xl text-sm font-semibold text-zinc-700 hover:bg-zinc-50 transition-colors shadow-sm">
                 <SlidersHorizontal size={16} /> Filter
              </button>
              <div className="flex items-center p-1 bg-zinc-100 rounded-xl border border-zinc-200/50">
                 <button onClick={() => setViewMode("grid")} className={`p-1.5 rounded-lg transition-colors ${viewMode === "grid" ? "bg-white shadow-sm text-zinc-900" : "text-zinc-500 hover:text-zinc-900"}`}>
                   <Grid size={16} />
                 </button>
                 <button onClick={() => setViewMode("list")} className={`p-1.5 rounded-lg transition-colors ${viewMode === "list" ? "bg-white shadow-sm text-zinc-900" : "text-zinc-500 hover:text-zinc-900"}`}>
                   <List size={16} />
                 </button>
              </div>
            </div>
          </div>

          {/* SMART SUMMARY CARDS */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-10">
            {[
              { label: "Saved Items", value: "142", icon: Bookmark, color: "text-[#6C5CE7]", bg: "bg-[#6C5CE7]/10" },
              { label: "Collections", value: "12", icon: Library, color: "text-emerald-600", bg: "bg-emerald-100" },
              { label: "Orgs Followed", value: "28", icon: Building2, color: "text-blue-600", bg: "bg-blue-100" },
              { label: "Offline Ready", value: "45", icon: WifiOff, color: "text-orange-600", bg: "bg-orange-100" }
            ].map((stat, i) => (
              <motion.div variants={itemVariants} key={i} className="bg-white/80 backdrop-blur-md border border-zinc-200/80 p-5 rounded-[18px] shadow-sm flex items-center gap-4 hover:shadow-md hover:-translate-y-0.5 transition-all">
                <div className={`w-12 h-12 rounded-2xl flex items-center justify-center ${stat.bg} ${stat.color}`}>
                  <stat.icon size={24} strokeWidth={2.5} />
                </div>
                <div>
                  <div className="text-2xl font-bold text-zinc-900">{stat.value}</div>
                  <div className="text-xs font-semibold text-zinc-500 uppercase tracking-wider">{stat.label}</div>
                </div>
              </motion.div>
            ))}
          </div>

          {/* SEARCH BAR */}
          <div className="relative mb-8 group">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-zinc-400 group-focus-within:text-[#6C5CE7] transition-colors" size={20} />
            <input 
              type="text" 
              placeholder="Search anything you've saved..." 
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full bg-white border border-zinc-200 pl-12 pr-4 py-4 rounded-[18px] text-zinc-900 font-medium focus:outline-none focus:ring-2 focus:ring-[#6C5CE7]/50 shadow-sm transition-shadow placeholder:text-zinc-400"
            />
          </div>

          {/* COLLECTION CHIPS */}
          <div className="flex gap-2 overflow-x-auto pb-4 scrollbar-hide -mx-4 px-4 sm:mx-0 sm:px-0">
            {CATEGORIES.map(cat => (
              <button
                key={cat}
                onClick={() => setActiveCategory(cat)}
                className={`relative px-5 py-2 rounded-full text-sm font-semibold whitespace-nowrap transition-colors ${activeCategory === cat ? "text-white" : "text-zinc-600 hover:bg-zinc-100 bg-white border border-zinc-200"}`}
              >
                {activeCategory === cat && (
                  <motion.div layoutId="activeCategory" className="absolute inset-0 bg-[#6C5CE7] rounded-full -z-10" />
                )}
                {cat}
              </button>
            ))}
          </div>
        </motion.div>

        {/* CONTENT TIMELINE */}
        <div className="space-y-12">
          {isLoading ? (
            <div className="text-center text-zinc-500 py-20 font-medium">Loading bookmarks...</div>
          ) : (
            timeGroupsOrder.map(group => {
            if (!groupedItems[group]) return null;
            return (
              <div key={group} className="relative">
                <div className="sticky top-0 z-20 bg-[#FAFAFA]/90 backdrop-blur-md py-3 -mx-4 px-4 sm:mx-0 sm:px-0">
                  <h3 className="text-sm font-bold text-zinc-400 uppercase tracking-widest">{group}</h3>
                </div>
                
                <div className={viewMode === "grid" ? "grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-5 mt-4" : "flex flex-col gap-4 mt-4"}>
                  <AnimatePresence mode="popLayout">
                    {groupedItems[group].map((item) => (
                      <motion.div 
                        layout
                        initial={{ opacity: 0, scale: 0.9 }}
                        animate={{ opacity: 1, scale: 1 }}
                        exit={{ opacity: 0, scale: 0.9 }}
                        key={item.id} 
                        className={`bg-white border border-zinc-200/80 rounded-[18px] p-5 shadow-sm hover:shadow-xl hover:shadow-[#6C5CE7]/10 hover:-translate-y-1 transition-all group flex ${viewMode === "grid" ? "flex-col" : "flex-row items-center gap-6"}`}
                      >
                         <div className="flex items-start justify-between mb-4">
                           <div className="flex items-center gap-2">
                             <span className="flex items-center gap-1.5 px-2.5 py-1 bg-zinc-100 text-zinc-600 rounded-lg text-xs font-bold uppercase tracking-wide">
                               {getIconForType(item.type)} {item.category}
                             </span>
                             {item.isOffline && <span className="p-1 bg-orange-100 text-orange-600 rounded-lg"><WifiOff size={12}/></span>}
                           </div>
                           <button className="text-zinc-300 hover:text-zinc-600 opacity-0 group-hover:opacity-100 transition-opacity">
                             <Bookmark size={18} className="fill-[#6C5CE7] text-[#6C5CE7]" />
                           </button>
                         </div>
                         
                         <div className="flex-1">
                           <h4 className="text-lg font-bold text-zinc-900 leading-snug mb-2 line-clamp-2 group-hover:text-[#6C5CE7] transition-colors">{item.title}</h4>
                           <p className="text-sm font-medium text-zinc-500 flex items-center gap-2">
                             <Building2 size={14} /> {item.organization}
                           </p>
                         </div>

                         <div className={`flex items-center justify-between mt-6 ${viewMode === "list" ? "mt-0 flex-col items-end gap-2" : ""}`}>
                           <div className="flex items-center gap-2">
                             {item.tags.map(tag => (
                               <span key={tag} className="text-[11px] font-bold text-zinc-400 bg-zinc-50 px-2 py-1 rounded-md border border-zinc-100">{tag}</span>
                             ))}
                           </div>
                           
                           {/* Hover Actions */}
                           <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity bg-white/90 backdrop-blur-sm rounded-lg p-1 shadow-sm border border-zinc-100 absolute bottom-4 right-4">
                             <button className="p-2 text-zinc-400 hover:text-[#6C5CE7] hover:bg-[#6C5CE7]/10 rounded-md transition-colors"><Folder size={14} /></button>
                             <button className="p-2 text-zinc-400 hover:text-blue-600 hover:bg-blue-50 rounded-md transition-colors"><Share2 size={14} /></button>
                             <button className="p-2 text-zinc-400 hover:text-red-600 hover:bg-red-50 rounded-md transition-colors"><Trash2 size={14} /></button>
                           </div>
                         </div>
                      </motion.div>
                    ))}
                  </AnimatePresence>
                </div>
              </div>
            );
          }))}

          {!isLoading && filteredItems.length === 0 && (
            <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="flex flex-col items-center justify-center py-32 text-center">
               <div className="w-24 h-24 bg-[#6C5CE7]/5 rounded-[24px] flex items-center justify-center mb-6 text-[#6C5CE7]">
                 <Library size={48} strokeWidth={1.5} />
               </div>
               <h3 className="text-2xl font-extrabold text-zinc-900 mb-2">No bookmarks found</h3>
               <p className="text-zinc-500 font-medium max-w-sm mb-8">Save interesting datasets, organizations, and posts to build your personal knowledge library.</p>
               <Link href="/results" className="px-6 py-3 bg-zinc-900 text-white font-bold rounded-xl hover:-translate-y-0.5 hover:shadow-lg transition-all">
                 Explore ResultHub
               </Link>
            </motion.div>
          )}
        </div>

        {/* SMART RECOMMENDATIONS */}
        <div className="mt-24 pt-12 border-t border-zinc-200/80">
          <h3 className="text-xl font-bold text-zinc-900 mb-6 flex items-center gap-2"><Sparkles className="text-[#6C5CE7]"/> Because you saved Education datasets...</h3>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-5">
            {[1, 2, 3].map(i => (
              <div key={i} className="bg-white border border-zinc-200/80 p-5 rounded-[18px] flex flex-col gap-3 group cursor-pointer hover:shadow-md hover:border-[#6C5CE7]/30 transition-all">
                <div className="w-10 h-10 bg-indigo-50 text-[#6C5CE7] rounded-xl flex items-center justify-center mb-2">
                  <BarChart3 size={20} />
                </div>
                <h4 className="font-bold text-zinc-900 group-hover:text-[#6C5CE7] transition-colors">National Exam Analytics {2025 + i}</h4>
                <p className="text-xs font-medium text-zinc-500">Ministry of Education • 12k views</p>
              </div>
            ))}
          </div>
        </div>

      </div>

      {/* RIGHT SIDEBAR (Desktop) */}
      <div className="hidden lg:flex flex-col w-[320px] xl:w-[380px] bg-white border-l border-zinc-200/80 min-h-screen p-8 sticky top-0 h-screen overflow-y-auto">
         
         <div className="mb-10">
           <h3 className="text-xs font-bold text-zinc-400 uppercase tracking-widest mb-4">Storage Usage</h3>
           <div className="bg-zinc-50 p-4 rounded-2xl border border-zinc-100">
             <div className="flex items-center justify-between mb-2">
               <span className="text-sm font-bold text-zinc-900"><HardDrive size={14} className="inline mr-2 text-[#6C5CE7]"/> Offline Data</span>
               <span className="text-xs font-bold text-zinc-500">2.4 GB / 5 GB</span>
             </div>
             <div className="h-2 bg-zinc-200 rounded-full overflow-hidden">
               <div className="h-full bg-[#6C5CE7] w-[48%] rounded-full"></div>
             </div>
           </div>
         </div>

         <div className="mb-10">
           <div className="flex items-center justify-between mb-4">
             <h3 className="text-xs font-bold text-zinc-400 uppercase tracking-widest">Pinned Items</h3>
             <button className="text-[#6C5CE7] text-xs font-bold hover:underline">Edit</button>
           </div>
           <div className="space-y-3">
             {[
               { icon: FileText, title: "Q3 Fiscal Guidelines", color: "text-blue-600 bg-blue-50" },
               { icon: BarChart3, title: "Statewide Board Results", color: "text-[#6C5CE7] bg-[#6C5CE7]/10" },
               { icon: Building2, title: "Department of Education", color: "text-emerald-600 bg-emerald-50" }
             ].map((pin, i) => (
               <div key={i} className="flex items-center gap-3 p-2 hover:bg-zinc-50 rounded-xl cursor-pointer group transition-colors">
                 <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${pin.color}`}>
                   <pin.icon size={18} />
                 </div>
                 <div className="flex-1 overflow-hidden">
                   <h4 className="text-sm font-bold text-zinc-900 truncate group-hover:text-[#6C5CE7] transition-colors">{pin.title}</h4>
                   <p className="text-xs font-medium text-zinc-500">Pinned 2d ago</p>
                 </div>
               </div>
             ))}
           </div>
         </div>

         <div className="mb-10">
           <h3 className="text-xs font-bold text-zinc-400 uppercase tracking-widest mb-4">Quick Actions</h3>
           <div className="space-y-2">
             <button className="w-full flex items-center justify-between p-3 text-sm font-bold text-zinc-700 hover:bg-zinc-50 hover:text-[#6C5CE7] rounded-xl transition-colors">
               <span className="flex items-center gap-2"><Folder size={16}/> Create Collection</span>
               <ChevronRight size={16} className="opacity-50" />
             </button>
             <button className="w-full flex items-center justify-between p-3 text-sm font-bold text-zinc-700 hover:bg-zinc-50 hover:text-[#6C5CE7] rounded-xl transition-colors">
               <span className="flex items-center gap-2"><Download size={16}/> Export Library (CSV)</span>
               <ChevronRight size={16} className="opacity-50" />
             </button>
             <button className="w-full flex items-center justify-between p-3 text-sm font-bold text-zinc-700 hover:bg-zinc-50 hover:text-[#6C5CE7] rounded-xl transition-colors">
               <span className="flex items-center gap-2"><Settings size={16}/> Library Settings</span>
               <ChevronRight size={16} className="opacity-50" />
             </button>
           </div>
         </div>

         <div className="mt-auto pt-6 border-t border-zinc-200/80">
            <div className="flex items-center gap-3 bg-[#6C5CE7] p-4 rounded-2xl text-white shadow-lg shadow-[#6C5CE7]/20 relative overflow-hidden group cursor-pointer">
              <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent -translate-x-full group-hover:animate-[shimmer_1.5s_infinite]"></div>
              <div className="w-10 h-10 bg-white/20 rounded-xl flex items-center justify-center backdrop-blur-md">
                <Star size={20} className="text-white fill-white" />
              </div>
              <div>
                <h4 className="text-sm font-bold">Upgrade to Premium</h4>
                <p className="text-xs font-medium text-white/80">Unlimited offline sync & storage</p>
              </div>
            </div>
         </div>

      </div>

    </div>
  );
}
