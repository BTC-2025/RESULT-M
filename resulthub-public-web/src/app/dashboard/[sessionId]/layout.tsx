"use client";

import { useState, useEffect, use, useRef } from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { motion, AnimatePresence } from "framer-motion";
import { api, getAuthToken, clearAuthToken } from "@/lib/api";
import { WorkspaceProvider, useWorkspace } from "./WorkspaceContext";
import { 
  LayoutDashboard, Database, FolderKanban, Search, 
  LineChart, Users, Bell, Settings,
  LogOut, ChevronLeft, ChevronRight, Menu, CheckCircle2,
  Upload, Plus, ChevronDown, MessageSquareWarning, 
  CheckSquare, Activity, Building2, BellRing, BarChart3, PieChart, Focus, MapPin, 
  HelpCircle, Megaphone, FileText, Webhook, Zap, AlertCircle, Users2, Heart,
  Loader2, X
} from "lucide-react";
import { CreatePostModal } from "@/components/dashboard/CreatePostModal";

function DashboardLayoutContent({ children, sessionId }: { children: React.ReactNode, sessionId: string }) {
  const [isCollapsed, setIsCollapsed] = useState(false);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [isCreatePostOpen, setIsCreatePostOpen] = useState(false);
  const [userContext, setUserContext] = useState<any>(null);
  const pathname = usePathname();
  const router = useRouter();
  const [isSearchExpanded, setIsSearchExpanded] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");
  const [isSearching, setIsSearching] = useState(false);
  const [searchResults, setSearchResults] = useState<any>(null);
  const searchTimeoutRef = useRef<NodeJS.Timeout | null>(null);
  const searchInputRef = useRef<HTMLInputElement>(null);
  const searchContainerRef = useRef<HTMLDivElement>(null);
  
  const { activeWorkspace, setActiveWorkspace, workspaces } = useWorkspace();

  // Close search when clicking outside
  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (searchContainerRef.current && !searchContainerRef.current.contains(e.target as Node)) {
        setIsSearchExpanded(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const handleSearch = (query: string) => {
    setSearchQuery(query);
    if (query.trim().length === 0) {
      setSearchResults(null);
      return;
    }
    
    setIsSearching(true);
    if (searchTimeoutRef.current) clearTimeout(searchTimeoutRef.current);
    
    searchTimeoutRef.current = setTimeout(async () => {
      try {
        // Use real api.search endpoint
        const res = await api.search(query);
        setSearchResults(res);
      } catch (e) {
        console.error("Search failed, falling back to local filter", e);
        // Fallback: local filter of workspaces as mock
        const filteredWs = workspaces.filter(w => w.name.toLowerCase().includes(query.toLowerCase()));
        setSearchResults({ workspaces: filteredWs, datasets: [] });
      } finally {
        setIsSearching(false);
      }
    }, 400);
  };

  useEffect(() => {
    if (isSearchExpanded && searchInputRef.current) {
      searchInputRef.current.focus();
    }
  }, [isSearchExpanded]);

  const generateBreadcrumbs = () => {
    if (!pathname) return [];
    const segments = pathname.split('/').filter(Boolean);
    const isId = (str: string) => str === sessionId || /^[0-9a-fA-F-]{16,}$/.test(str) || str.length > 20;
    
    const crumbs = [];
    let currentPath = '';
    
    for (const segment of segments) {
      currentPath += `/${segment}`;
      if (segment === 'dashboard' || isId(segment)) continue;
      
      let label = segment.charAt(0).toUpperCase() + segment.slice(1).replace(/-/g, ' ');
      crumbs.push({ label, href: currentPath });
    }
    return crumbs;
  };
  const breadcrumbs = generateBreadcrumbs();

  useEffect(() => {
    const token = getAuthToken();
    if (!token) {
      router.push('/login');
      return;
    }

    if (typeof window !== 'undefined') {
      const storedSession = localStorage.getItem('rh_session_id');
      if (!storedSession || storedSession !== sessionId) {
        // Invalid session or mismatch URL -> kick to login
        router.push('/login');
        return;
      }

      const storedUser = localStorage.getItem('rh_user');
      if (storedUser) {
        const parsedUser = JSON.parse(storedUser);
        if (parsedUser.role === 'USER') {
          // Standard users cannot access the organization dashboard
          router.push('/');
          return;
        }
        setUserContext(parsedUser);
      }
    }
  }, [router]);

  const handleLogout = () => {
    clearAuthToken();
    if (typeof window !== 'undefined') {
      localStorage.removeItem('rh_user');
    }
    router.push('/login');
  };

  const navGroups = [
    {
      label: "DATA MANAGEMENT",
      items: [
        { label: "Workspaces", icon: FolderKanban, href: `/dashboard/${sessionId}/workspaces` },
        { label: "Datasets", icon: Database, href: `/dashboard/${sessionId}/datasets` },
        { label: "CSV Imports", icon: Upload, href: `/dashboard/${sessionId}/imports` },
        { label: "Records", icon: FileText, href: `/dashboard/${sessionId}/records` },
      ]
    },
    {
      label: "COMMUNITY",
      items: [
        { label: "Polls", icon: CheckSquare, href: `/dashboard/${sessionId}/polls` },
        { label: "Complaints", icon: MessageSquareWarning, href: `/dashboard/${sessionId}/complaints` },
        { label: "Announcements", icon: Megaphone, href: `/dashboard/${sessionId}/announcements` },
      ]
    },
    {
      label: "ANALYTICS",
      items: [
        { label: "Dashboard", icon: LineChart, href: `/dashboard/${sessionId}/analytics` },
        { label: "Search Analytics", icon: Search, href: `/dashboard/${sessionId}/analytics/search` },
        { label: "User Analytics", icon: Users2, href: `/dashboard/${sessionId}/analytics/users` },
        { label: "Dataset Analytics", icon: Database, href: `/dashboard/${sessionId}/analytics/datasets` },
        { label: "Workspace Analytics", icon: Building2, href: `/dashboard/${sessionId}/analytics/workspaces` },
        { label: "Complaint Analytics", icon: AlertCircle, href: `/dashboard/${sessionId}/analytics/complaints` },
        { label: "Poll Analytics", icon: BarChart3, href: `/dashboard/${sessionId}/analytics/polls` },
        { label: "Community Analytics", icon: Heart, href: `/dashboard/${sessionId}/analytics/community` },
        { label: "Performance", icon: Zap, href: `/dashboard/${sessionId}/analytics/performance` },
        { label: "Reports", icon: FileText, href: `/dashboard/${sessionId}/analytics/reports` },
      ]
    },
    {
      label: "MANAGEMENT",
      items: [
        { label: "Team Members", icon: Users, href: `/dashboard/${sessionId}/team` },
        { label: "API & Webhooks", icon: Webhook, href: `/dashboard/${sessionId}/developers` },
        { label: "Settings", icon: Settings, href: `/dashboard/${sessionId}/settings` },
      ]
    }
  ];

  return (
    <div className="flex h-screen bg-[#F9FAFB] text-zinc-900 overflow-hidden font-sans selection:bg-[#635BFF]/20">
      
      {/* DESKTOP SIDEBAR */}
      <motion.aside 
        animate={{ width: isCollapsed ? 80 : 260 }}
        transition={{ type: "spring", bounce: 0, duration: 0.4 }}
        className="hidden md:flex flex-col bg-zinc-950 border-r border-zinc-800 h-full relative z-20 shadow-sm"
      >
        {/* Toggle Button */}
        <button 
          onClick={() => setIsCollapsed(!isCollapsed)}
          className="absolute -right-4 top-8 w-8 h-8 bg-zinc-900 border border-zinc-800 rounded-full flex items-center justify-center text-zinc-400 hover:text-white shadow-sm hover:shadow-md transition-all z-30"
        >
          {isCollapsed ? <ChevronRight size={16} /> : <ChevronLeft size={16} />}
        </button>

        {/* Logo Area */}
        <div className="p-6 flex items-center justify-between border-b border-zinc-800/50 overflow-hidden shrink-0">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-[#635BFF] text-white rounded-xl flex items-center justify-center font-black text-xl shrink-0 hexagon-logo">
              R
            </div>
            <AnimatePresence>
              {!isCollapsed && (
                <motion.div 
                  initial={{ opacity: 0, x: -10 }} 
                  animate={{ opacity: 1, x: 0 }} 
                  exit={{ opacity: 0, x: -10 }}
                  className="whitespace-nowrap flex-1 overflow-hidden"
                >
                  <h2 className="font-extrabold text-base text-white tracking-tight leading-tight">ResultHub</h2>
                  <p className="text-[11px] font-bold text-zinc-400 uppercase tracking-widest truncate">
                    {userContext?.organizationName || "Platform"}
                  </p>
                </motion.div>
              )}
            </AnimatePresence>
          </div>
        </div>

        {/* Navigation */}
        <div className="flex-1 overflow-y-auto py-6 px-4 scrollbar-hide space-y-6">
          
          {/* Main Dashboard Link */}
          <div>
            <Link 
              href={`/dashboard/${sessionId}`}
              className={`flex items-center gap-3 px-4 py-3 rounded-xl transition-all group ${
                pathname === `/dashboard/${sessionId}` 
                  ? "bg-[#635BFF]/10 text-[#635BFF]" 
                  : "text-zinc-400 font-medium hover:bg-zinc-800/50 hover:text-white"
              }`}
              title={isCollapsed ? "Dashboard" : undefined}
            >
              <LayoutDashboard size={20} className={pathname === `/dashboard/${sessionId}` ? "text-[#635BFF]" : "text-zinc-500 group-hover:text-zinc-400"} />
              <AnimatePresence>
                {!isCollapsed && (
                  <motion.span 
                    initial={{ opacity: 0, width: 0 }} animate={{ opacity: 1, width: "auto" }} exit={{ opacity: 0, width: 0 }}
                    className={`whitespace-nowrap text-sm ${pathname === `/dashboard/${sessionId}` ? 'font-bold' : 'font-semibold'}`}
                  >
                    Dashboard
                  </motion.span>
                )}
              </AnimatePresence>
            </Link>
          </div>

          {/* Grouped Links */}
          {navGroups.map((group, idx) => (
            <div key={idx} className="space-y-1">
              {!isCollapsed && (
                <div className="px-4 mb-3 text-[10px] font-bold text-zinc-500 uppercase tracking-widest">
                  {group.label}
                </div>
              )}
              {group.items.map((item) => {
                const isActive = pathname === item.href || pathname?.startsWith(item.href);
                return (
                  <Link 
                    key={item.label} 
                    href={item.href}
                    className={`flex items-center gap-3 px-4 py-2.5 rounded-xl transition-all group relative overflow-hidden ${
                      isActive 
                        ? "text-[#635BFF] font-bold bg-[#635BFF]/10" 
                        : "text-zinc-400 font-medium hover:bg-zinc-800/50 hover:text-white"
                    }`}
                    title={isCollapsed ? item.label : undefined}
                  >
                    <item.icon size={18} className={`shrink-0 ${isActive ? "text-[#635BFF]" : "text-zinc-500 group-hover:text-zinc-400"}`} />
                    <AnimatePresence>
                      {!isCollapsed && (
                        <motion.span 
                          initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
                          className="whitespace-nowrap text-sm"
                        >
                          {item.label}
                        </motion.span>
                      )}
                    </AnimatePresence>
                    {!isCollapsed && item.label === "Datasets" && (
                      <ChevronRight size={14} className="absolute right-4 text-zinc-600 group-hover:text-zinc-500" />
                    )}
                    {!isCollapsed && item.label === "Records" && (
                      <ChevronRight size={14} className="absolute right-4 text-zinc-600 group-hover:text-zinc-500" />
                    )}
                  </Link>
                );
              })}
            </div>
          ))}
        </div>

        {/* Bottom Actions */}
        <div className="p-4 shrink-0">
          {/* School Selector (Bottom) */}
          <div className="relative group cursor-pointer">
            <div className={`flex items-center gap-3 p-3 rounded-2xl hover:bg-zinc-800/50 border border-transparent hover:border-zinc-800 transition-all ${isCollapsed ? 'justify-center' : 'justify-between'}`}>
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-zinc-900 flex items-center justify-center shrink-0 border border-zinc-800 overflow-hidden shadow-sm">
                  <Building2 size={20} className="text-zinc-400" />
                </div>
                {!isCollapsed && (
                  <div className="flex-1 min-w-0">
                    <p className="font-bold text-sm text-white truncate">
                      {activeWorkspace?.name || "ResultHub Workspace"}
                    </p>
                    <p className="text-[11px] font-semibold text-zinc-400 capitalize">
                      {userContext?.role?.toLowerCase() || "Admin"}
                    </p>
                  </div>
                )}
              </div>
              {!isCollapsed && <ChevronDown size={16} className="text-zinc-500" />}
            </div>
          </div>

        </div>
      </motion.aside>

      {/* MOBILE SIDEBAR (Overlay) */}
      <AnimatePresence>
        {isMobileMenuOpen && (
          <>
            <motion.div 
              initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
              onClick={() => setIsMobileMenuOpen(false)}
              className="md:hidden fixed inset-0 bg-zinc-950/80 backdrop-blur-sm z-40"
            />
            <motion.aside 
              initial={{ x: "-100%" }} animate={{ x: 0 }} exit={{ x: "-100%" }} transition={{ type: "spring", bounce: 0, duration: 0.3 }}
              className="md:hidden fixed top-0 left-0 bottom-0 w-[280px] bg-zinc-950 border-r border-zinc-800 z-50 flex flex-col shadow-2xl"
            >
              {/* Logo Area */}
              <div className="p-6 flex items-center justify-between border-b border-zinc-800/50">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-[#635BFF] text-white rounded-xl flex items-center justify-center font-bold text-lg hexagon-logo">
                    {activeWorkspace ? activeWorkspace.name.substring(0, 2).toUpperCase() : 'RH'}
                  </div>
                  <div>
                    <h2 className="font-extrabold text-base text-white">ResultHub</h2>
                    <p className="text-[11px] font-bold text-zinc-400 uppercase truncate max-w-[100px]">{userContext?.organizationName || "Platform"}</p>
                  </div>
                </div>
                <button onClick={() => setIsMobileMenuOpen(false)} className="p-2 text-zinc-400 hover:text-zinc-900 bg-zinc-900 rounded-lg"><ChevronLeft size={20}/></button>
              </div>

              {/* Navigation */}
              <div className="flex-1 overflow-y-auto py-6 px-4 space-y-6">
                <div>
                  <Link 
                    href={`/dashboard/${sessionId}`}
                    onClick={() => setIsMobileMenuOpen(false)}
                    className={`flex items-center gap-3 px-4 py-3 rounded-xl transition-all group ${
                      pathname === `/dashboard/${sessionId}` 
                        ? "bg-[#635BFF]/10 text-[#635BFF] font-bold" 
                        : "text-zinc-400 font-medium hover:bg-zinc-800/50 hover:text-white"
                    }`}
                  >
                    <LayoutDashboard size={20} className={pathname === `/dashboard/${sessionId}` ? "text-[#635BFF]" : "text-zinc-400 group-hover:text-zinc-600"} />
                    <span className="text-sm">Dashboard</span>
                  </Link>
                </div>
                
                {navGroups.map((group, idx) => (
                  <div key={idx} className="space-y-1">
                    <div className="px-4 mb-3 text-[10px] font-bold text-zinc-500 uppercase tracking-widest">
                      {group.label}
                    </div>
                    {group.items.map((item) => {
                      const isActive = pathname === item.href || pathname?.startsWith(item.href);
                      return (
                        <Link 
                          key={item.label} 
                          href={item.href}
                          onClick={() => setIsMobileMenuOpen(false)}
                          className={`flex items-center gap-3 px-4 py-3 rounded-xl transition-all group ${
                            isActive 
                              ? "bg-[#635BFF]/10 text-[#635BFF] font-bold" 
                              : "text-zinc-400 font-medium hover:bg-zinc-800/50 hover:text-white"
                          }`}
                        >
                          <item.icon size={18} className={isActive ? "text-[#635BFF]" : "text-zinc-500 group-hover:text-zinc-400"} />
                          <span className="text-sm">{item.label}</span>
                        </Link>
                      );
                    })}
                  </div>
                ))}
              </div>

              {/* Logout/User area mobile */}
              <div className="p-4 border-t border-zinc-800/50">
                <button 
                  onClick={handleLogout}
                  className="flex items-center gap-3 px-4 py-3 w-full rounded-xl text-red-400 font-medium hover:bg-red-500/10 transition-colors"
                >
                  <LogOut size={18} />
                  <span className="text-sm">Log out</span>
                </button>
              </div>
            </motion.aside>
          </>
        )}
      </AnimatePresence>

      {/* MAIN CONTENT AREA */}
      <div className="flex-1 flex flex-col min-w-0 overflow-hidden relative z-10">
        
        {/* TOP NAVIGATION */}
        <header className="h-[80px] bg-white border-b border-zinc-100 flex items-center justify-between px-6 shrink-0 sticky top-0 z-30">
          
          <div className="flex items-center gap-4 flex-1">
            <button className="md:hidden text-zinc-500" onClick={() => setIsMobileMenuOpen(true)}>
              <Menu size={24} />
            </button>

            {/* Global Breadcrumbs */}
            {breadcrumbs.length > 0 && (
              <div className="hidden sm:flex items-center gap-2 text-[13px] font-semibold">
                <Link href={`/dashboard/${sessionId}`} className="text-zinc-400 hover:text-zinc-600 transition-colors">
                  <LayoutDashboard size={14} />
                </Link>
                {breadcrumbs.map((crumb, idx) => (
                  <div key={crumb.href} className="flex items-center gap-2">
                    <ChevronRight size={14} className="text-zinc-300" />
                    {idx === breadcrumbs.length - 1 ? (
                      <span className="text-[#635BFF]">{crumb.label}</span>
                    ) : (
                      <Link href={crumb.href} className="text-zinc-400 hover:text-zinc-600 transition-colors">
                        {crumb.label}
                      </Link>
                    )}
                  </div>
                ))}
              </div>
            )}

            {/* Global Search */}
            <div className="relative flex items-center ml-auto mr-4 lg:ml-4 lg:mr-0" ref={searchContainerRef}>
              <AnimatePresence mode="wait">
                {!isSearchExpanded ? (
                  <motion.button 
                    key="search-icon"
                    initial={{ opacity: 0, scale: 0.8 }}
                    animate={{ opacity: 1, scale: 1 }}
                    exit={{ opacity: 0, scale: 0.8 }}
                    transition={{ duration: 0.15 }}
                    onClick={() => setIsSearchExpanded(true)}
                    className="p-2 text-zinc-500 hover:text-[#635BFF] hover:bg-[#635BFF]/10 rounded-xl transition-all"
                  >
                    <Search size={22} strokeWidth={2.5} />
                  </motion.button>
                ) : (
                  <motion.div 
                    key="search-input"
                    initial={{ opacity: 0, width: 0 }}
                    animate={{ opacity: 1, width: 320 }}
                    exit={{ opacity: 0, width: 0 }}
                    transition={{ duration: 0.2 }}
                    className="relative flex items-center"
                  >
                    <div className="relative w-full">
                      <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 text-[#635BFF]" size={16} />
                      <input 
                        ref={searchInputRef}
                        type="text" 
                        value={searchQuery}
                        onChange={(e) => handleSearch(e.target.value)}
                        placeholder="Search workspaces & datasets..." 
                        className="w-full bg-white border border-[#635BFF]/30 shadow-sm focus:border-[#635BFF] pl-10 pr-8 py-2 rounded-xl text-sm font-semibold text-zinc-900 placeholder:text-zinc-400 outline-none transition-all"
                      />
                      <button 
                        onClick={() => { setIsSearchExpanded(false); setSearchQuery(""); setSearchResults(null); }}
                        className="absolute right-2 top-1/2 -translate-y-1/2 text-zinc-400 hover:text-zinc-700 p-1 rounded-md hover:bg-zinc-100 transition-colors"
                      >
                        <X size={14} />
                      </button>
                    </div>

                    {/* Results Dropdown */}
                    <AnimatePresence>
                      {searchQuery.trim().length > 0 && (
                        <motion.div 
                          initial={{ opacity: 0, y: 10 }}
                          animate={{ opacity: 1, y: 0 }}
                          exit={{ opacity: 0, y: 10 }}
                          className="absolute top-full mt-3 right-0 lg:left-0 lg:right-auto w-[400px] bg-white border border-zinc-200/80 rounded-2xl shadow-xl z-50 max-h-[60vh] overflow-y-auto"
                        >
                          {isSearching ? (
                            <div className="p-8 text-center text-zinc-400 flex flex-col items-center">
                               <Loader2 className="animate-spin mb-2 text-[#635BFF]" size={24} />
                               <span className="text-sm font-medium">Searching ResultHub...</span>
                            </div>
                          ) : searchResults && (searchResults.datasets?.length > 0 || searchResults.workspaces?.length > 0) ? (
                            <div className="p-2 space-y-4">
                              {searchResults.workspaces?.length > 0 && (
                                <div>
                                  <div className="px-3 py-2 text-[10px] font-black text-zinc-400 uppercase tracking-widest">Workspaces</div>
                                  {searchResults.workspaces.map((ws: any) => (
                                    <Link key={ws.id} href={`/dashboard/${sessionId}/workspaces`} onClick={() => setIsSearchExpanded(false)} className="flex items-center gap-3 p-2.5 hover:bg-zinc-50 rounded-xl transition-colors group">
                                      <div className="w-9 h-9 rounded-xl bg-indigo-50 border border-indigo-100 text-indigo-500 flex items-center justify-center shrink-0">
                                        <FolderKanban size={18} className="group-hover:scale-110 transition-transform" />
                                      </div>
                                      <div className="min-w-0 flex-1">
                                        <p className="text-sm font-bold text-zinc-900 group-hover:text-indigo-600 truncate">{ws.name}</p>
                                        <p className="text-[11px] text-zinc-500 truncate">{ws.description || "Workspace"}</p>
                                      </div>
                                    </Link>
                                  ))}
                                </div>
                              )}
                              {searchResults.datasets?.length > 0 && (
                                <div>
                                  <div className="px-3 py-2 text-[10px] font-black text-zinc-400 uppercase tracking-widest">Datasets</div>
                                  {searchResults.datasets.map((ds: any) => (
                                    <Link key={ds.id} href={`/dashboard/${sessionId}/datasets/${ds.id}/records`} onClick={() => setIsSearchExpanded(false)} className="flex items-center gap-3 p-2.5 hover:bg-zinc-50 rounded-xl transition-colors group">
                                      <div className="w-9 h-9 rounded-xl bg-emerald-50 border border-emerald-100 text-emerald-500 flex items-center justify-center shrink-0">
                                        <Database size={18} className="group-hover:scale-110 transition-transform" />
                                      </div>
                                      <div className="min-w-0 flex-1">
                                        <p className="text-sm font-bold text-zinc-900 group-hover:text-emerald-600 truncate">{ds.name}</p>
                                        <p className="text-[11px] text-zinc-500 truncate">{ds.domainType || ds.category || "Dataset"}</p>
                                      </div>
                                    </Link>
                                  ))}
                                </div>
                              )}
                            </div>
                          ) : (
                            <div className="p-8 text-center flex flex-col items-center justify-center">
                              <div className="w-12 h-12 rounded-2xl bg-zinc-50 flex items-center justify-center mb-3 text-zinc-300">
                                <Search size={24} />
                              </div>
                              <p className="text-sm font-bold text-zinc-900">No results found</p>
                              <p className="text-xs text-zinc-500 mt-1">We couldn't find anything matching "{searchQuery}"</p>
                            </div>
                          )}
                        </motion.div>
                      )}
                    </AnimatePresence>
                  </motion.div>
                )}
              </AnimatePresence>
            </div>
          </div>

          {/* Top Nav Actions */}
          <div className="flex items-center gap-4 shrink-0">
             
             <button className="relative p-2 text-zinc-600 hover:text-zinc-900 transition-colors">
               <Bell size={20} />
               <span className="absolute top-1 right-1.5 w-2 h-2 bg-red-500 rounded-full border border-white"></span>
             </button>

             <button className="p-2 text-zinc-600 hover:text-zinc-900 transition-colors hidden sm:block">
               <HelpCircle size={20} />
             </button>

             <div className="h-8 w-px bg-zinc-200 hidden sm:block mx-1"></div>

             <div className="flex items-center gap-3 cursor-pointer group">
               <div className="w-10 h-10 rounded-full bg-gradient-to-tr from-[#635BFF] to-purple-500 overflow-hidden shadow-sm shrink-0 flex items-center justify-center text-white font-bold text-lg">
                 {userContext?.profileImageUrl ? (
                   <img src={userContext.profileImageUrl} alt="Avatar" className="w-full h-full object-cover" />
                 ) : (
                   <span>{userContext?.firstName ? userContext.firstName.charAt(0).toUpperCase() : "U"}</span>
                 )}
               </div>
               <div className="hidden sm:block text-left">
                 <p className="text-sm font-bold text-zinc-900 group-hover:text-[#635BFF] transition-colors leading-tight capitalize">
                   {userContext ? `${userContext.firstName || ""} ${userContext.lastName || ""}`.trim() || "User" : "Loading..."}
                 </p>
                 <p className="text-[11px] font-semibold text-zinc-500 leading-tight mt-0.5 capitalize">
                   {userContext?.role?.toLowerCase().replace('_', ' ') || "Member"}
                 </p>
               </div>
               <ChevronDown size={16} className="text-zinc-400 hidden sm:block group-hover:text-zinc-600 transition-colors" />
             </div>

          </div>
        </header>

        {/* PAGE CONTENT */}
        <main className="flex-1 overflow-y-auto relative p-4 md:p-8">
          {children}
        </main>

      </div>

      <CreatePostModal isOpen={isCreatePostOpen} onClose={() => setIsCreatePostOpen(false)} />

    </div>
  );
}

export default function DashboardLayout({ children, params }: { children: React.ReactNode, params: Promise<{ sessionId: string }> }) {
  const { sessionId } = use(params);
  return (
    <WorkspaceProvider>
      <DashboardLayoutContent sessionId={sessionId}>{children}</DashboardLayoutContent>
    </WorkspaceProvider>
  );
}
