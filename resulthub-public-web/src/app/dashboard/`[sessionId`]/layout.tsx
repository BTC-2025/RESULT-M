"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { motion, AnimatePresence } from "framer-motion";
import { api, getAuthToken, clearAuthToken } from "@/lib/api";
import { WorkspaceProvider, useWorkspace } from "./WorkspaceContext";
import { 
  LayoutDashboard, Database, FolderKanban, BarChart3, Search, 
  LineChart, Users, Bell, Key, Webhook, CreditCard, Settings,
  LogOut, ChevronLeft, ChevronRight, Menu, CheckCircle2,
  HardDrive, Upload, Plus, ChevronDown, MessageSquareWarning, 
  CheckSquare, ShieldCheck, UploadCloud, Terminal, Activity, Building2, BellRing
} from "lucide-react";

function DashboardLayoutContent({ children }: { children: React.ReactNode }) {
  const [isCollapsed, setIsCollapsed] = useState(false);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [userContext, setUserContext] = useState<any>(null);
  const pathname = usePathname();
  const router = useRouter();
  const { activeWorkspace, setActiveWorkspace, workspaces } = useWorkspace();

  useEffect(() => {
    const token = getAuthToken();
    if (!token) {
      router.push('/login');
      return;
    }

    if (typeof window !== 'undefined') {
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

  const navItems = [
    { label: "Dashboard", icon: LayoutDashboard, href: "/dashboard" },
    { label: "Workspaces", icon: FolderKanban, href: "/dashboard/workspaces" },
    { label: "Datasets", icon: Database, href: "/dashboard/datasets" },
    { label: "Data Imports", icon: UploadCloud, href: "/dashboard/imports" },
    { label: "Search Center", icon: Search, href: "/dashboard/search" },
    { label: "Analytics", icon: LineChart, href: "/dashboard/analytics" },
    { label: "Activity Logs", icon: Activity, href: "/dashboard/activity" },
    { label: "Complaints", icon: MessageSquareWarning, href: "/dashboard/complaints" },
    { label: "Polls", icon: CheckSquare, href: "/dashboard/polls" },
    { label: "Team Members", icon: Users, href: "/dashboard/team" },
    { label: "Notifications", icon: BellRing, href: "/dashboard/notifications" },
    { label: "Security Center", icon: ShieldCheck, href: "/dashboard/security" },
    { label: "Developers", icon: Terminal, href: "/dashboard/developers" },
    { label: "Organization Profile", icon: Building2, href: "/dashboard/profile" },
    { label: "Settings", icon: Settings, href: "/dashboard/settings" },
  ];

  return (
    <div className="flex h-screen bg-[#F9FAFB] text-zinc-900 overflow-hidden font-sans selection:bg-[#635BFF]/20">
      
      {/* LEFT SIDEBAR (Desktop) */}
      <motion.aside 
        animate={{ width: isCollapsed ? 80 : 280 }}
        className="hidden md:flex flex-col bg-white border-r border-zinc-200 h-full relative z-20 shadow-sm"
      >
        {/* Toggle Button */}
        <button 
          onClick={() => setIsCollapsed(!isCollapsed)}
          className="absolute -right-4 top-8 w-8 h-8 bg-white border border-zinc-200 rounded-full flex items-center justify-center text-zinc-500 hover:text-zinc-900 shadow-sm hover:shadow-md transition-all z-30"
        >
          {isCollapsed ? <ChevronRight size={16} /> : <ChevronLeft size={16} />}
        </button>

        {/* Logo Area */}
        <div className="p-6 flex items-center gap-3 border-b border-zinc-100 overflow-hidden shrink-0">
          <div className="w-10 h-10 bg-[#635BFF]/10 text-[#635BFF] rounded-xl flex items-center justify-center font-bold text-lg shrink-0">
            {activeWorkspace ? activeWorkspace.name.substring(0, 2).toUpperCase() : 'RH'}
          </div>
          <AnimatePresence>
            {!isCollapsed && (
              <motion.div 
                initial={{ opacity: 0, x: -10 }} 
                animate={{ opacity: 1, x: 0 }} 
                exit={{ opacity: 0, x: -10 }}
                className="whitespace-nowrap flex-1 overflow-hidden"
              >
                <h2 className="font-bold text-sm truncate">{activeWorkspace ? activeWorkspace.name : 'Loading...'}</h2>
                <p className="text-[11px] font-medium text-emerald-600 flex items-center gap-1">
                  <CheckCircle2 size={12} /> {activeWorkspace?.domainType || 'Verified'}
                </p>
              </motion.div>
            )}
          </AnimatePresence>
        </div>

        {/* Navigation */}
        <div className="flex-1 overflow-y-auto py-6 px-4 scrollbar-hide space-y-1">
          {navItems.map((item) => {
            const isActive = pathname === item.href || (item.href !== '/dashboard' && pathname?.startsWith(item.href));
            return (
              <Link 
                key={item.label} 
                href={item.href}
                className={`flex items-center gap-3 px-3 py-2.5 rounded-xl transition-all group relative overflow-hidden ${
                  isActive 
                    ? "bg-[#635BFF]/5 text-[#635BFF] font-semibold" 
                    : "text-zinc-600 font-medium hover:bg-zinc-50 hover:text-zinc-900"
                }`}
                title={isCollapsed ? item.label : undefined}
              >
                {isActive && (
                  <motion.div layoutId="activeNavIndicator" className="absolute left-0 top-0 bottom-0 w-1 bg-[#635BFF] rounded-r-full" />
                )}
                <item.icon size={20} className={`shrink-0 ${isActive ? "text-[#635BFF]" : "text-zinc-400 group-hover:text-zinc-600"}`} />
                <AnimatePresence>
                  {!isCollapsed && (
                    <motion.span 
                      initial={{ opacity: 0, x: -10 }} 
                      animate={{ opacity: 1, x: 0 }} 
                      exit={{ opacity: 0, x: -10 }}
                      className="whitespace-nowrap text-sm"
                    >
                      {item.label}
                    </motion.span>
                  )}
                </AnimatePresence>
              </Link>
            );
          })}
        </div>

        {/* Bottom Profile / Storage */}
        <div className="p-4 border-t border-zinc-100 shrink-0">
           <AnimatePresence>
             {!isCollapsed && (
               <motion.div initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: "auto" }} exit={{ opacity: 0, height: 0 }} className="mb-4 px-2 overflow-hidden">
                 <div className="flex items-center justify-between text-xs font-semibold text-zinc-500 mb-2">
                   <span>Storage</span>
                   <span>64%</span>
                 </div>
                 <div className="h-1.5 bg-zinc-100 rounded-full overflow-hidden">
                   <div className="h-full bg-[#635BFF] w-[64%] rounded-full"></div>
                 </div>
               </motion.div>
             )}
           </AnimatePresence>

           <button onClick={handleLogout} className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-zinc-600 font-medium hover:bg-red-50 hover:text-red-600 transition-colors ${isCollapsed ? "justify-center" : ""}`}>
             <LogOut size={20} className="shrink-0" />
             {!isCollapsed && <span className="text-sm">Log out</span>}
           </button>
        </div>
      </motion.aside>

      {/* MOBILE SIDEBAR (Overlay) */}
      <AnimatePresence>
        {isMobileMenuOpen && (
          <>
            <motion.div 
              initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
              onClick={() => setIsMobileMenuOpen(false)}
              className="md:hidden fixed inset-0 bg-zinc-900/50 backdrop-blur-sm z-40"
            />
            <motion.aside 
              initial={{ x: "-100%" }} animate={{ x: 0 }} exit={{ x: "-100%" }} transition={{ type: "spring", bounce: 0, duration: 0.3 }}
              className="md:hidden fixed top-0 left-0 bottom-0 w-[280px] bg-white border-r border-zinc-200 z-50 flex flex-col shadow-2xl"
            >
              {/* Logo Area */}
              <div className="p-6 flex items-center justify-between border-b border-zinc-100">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-[#635BFF]/10 text-[#635BFF] rounded-xl flex items-center justify-center font-bold text-lg">
                    {activeWorkspace ? activeWorkspace.name.substring(0, 2).toUpperCase() : 'RH'}
                  </div>
                  <div>
                    <h2 className="font-bold text-sm truncate">{activeWorkspace ? activeWorkspace.name : 'Loading...'}</h2>
                    <p className="text-[11px] font-medium text-emerald-600 flex items-center gap-1"><CheckCircle2 size={12} /> {activeWorkspace?.domainType || 'Verified'}</p>
                  </div>
                </div>
                <button onClick={() => setIsMobileMenuOpen(false)} className="p-2 text-zinc-400 hover:text-zinc-900 bg-zinc-50 rounded-lg"><ChevronLeft size={20}/></button>
              </div>

              {/* Navigation */}
              <div className="flex-1 overflow-y-auto py-6 px-4 space-y-1">
                {navItems.map((item) => {
                  const isActive = pathname === item.href || (item.href !== '/dashboard' && pathname?.startsWith(item.href));
                  return (
                    <Link 
                      key={item.label} 
                      href={item.href}
                      onClick={() => setIsMobileMenuOpen(false)}
                      className={`flex items-center gap-3 px-3 py-2.5 rounded-xl transition-all ${isActive ? "bg-[#635BFF]/5 text-[#635BFF] font-semibold" : "text-zinc-600 font-medium hover:bg-zinc-50 hover:text-zinc-900"}`}
                    >
                      <item.icon size={20} className={isActive ? "text-[#635BFF]" : "text-zinc-400"} />
                      <span className="text-sm">{item.label}</span>
                    </Link>
                  );
                })}
              </div>

              {/* Bottom Actions */}
              <div className="p-4 border-t border-zinc-100">
                <button onClick={handleLogout} className="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-zinc-600 font-medium hover:bg-red-50 hover:text-red-600 transition-colors">
                  <LogOut size={20} />
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
        <header className="h-16 bg-white/80 backdrop-blur-xl border-b border-zinc-200/80 flex items-center justify-between px-6 shrink-0 sticky top-0 z-30">
          
          <div className="flex items-center gap-4 flex-1">
            <button className="md:hidden text-zinc-500" onClick={() => setIsMobileMenuOpen(true)}>
              <Menu size={24} />
            </button>

            {/* Global Search */}
            <div className="hidden md:flex relative group max-w-md w-full">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-zinc-400 group-focus-within:text-[#635BFF] transition-colors" size={18} />
              <input 
                type="text" 
                placeholder="Search datasets, results, teammates..." 
                className="w-full bg-zinc-100/50 hover:bg-zinc-100 border border-transparent focus:border-[#635BFF]/30 focus:bg-white pl-10 pr-4 py-2 rounded-xl text-sm font-medium transition-all outline-none"
              />
              <div className="absolute right-3 top-1/2 -translate-y-1/2 flex gap-1">
                <kbd className="hidden lg:inline-flex items-center justify-center px-1.5 py-0.5 text-[10px] font-bold text-zinc-400 bg-white border border-zinc-200 rounded flex-shrink-0 shadow-sm">⌘</kbd>
                <kbd className="hidden lg:inline-flex items-center justify-center px-1.5 py-0.5 text-[10px] font-bold text-zinc-400 bg-white border border-zinc-200 rounded flex-shrink-0 shadow-sm">K</kbd>
              </div>
            </div>
          </div>

          {/* Top Nav Actions */}
          <div className="flex items-center gap-3 lg:gap-4 shrink-0">
             
             {/* Workspace Selector */}
             <div className="hidden lg:flex relative items-center gap-2 px-3 py-1.5 bg-zinc-50 border border-zinc-200 rounded-lg cursor-pointer hover:bg-zinc-100 transition-colors group">
               <span className="w-2 h-2 rounded-full bg-emerald-500"></span>
               <span className="text-sm font-semibold text-zinc-700 truncate max-w-[120px]">
                 {activeWorkspace ? activeWorkspace.name : 'No Workspace'}
               </span>
               <ChevronDown size={14} className="text-zinc-400" />
               
               {/* Dropdown menu */}
               <div className="absolute top-full right-0 mt-2 w-64 bg-white border border-zinc-200 rounded-xl shadow-lg opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all z-50 py-2">
                  <div className="px-4 py-2 text-xs font-semibold text-zinc-500 uppercase tracking-wider">Your Workspaces</div>
                  {workspaces.map((ws: any) => (
                    <button 
                      key={ws.id}
                      onClick={() => setActiveWorkspace(ws)}
                      className={`w-full text-left px-4 py-2.5 text-sm hover:bg-zinc-50 transition-colors flex items-center justify-between ${activeWorkspace?.id === ws.id ? 'text-[#635BFF] bg-[#635BFF]/5 font-semibold' : 'text-zinc-700 font-medium'}`}
                    >
                      <span className="truncate">{ws.name}</span>
                      {activeWorkspace?.id === ws.id && <CheckCircle2 size={14} />}
                    </button>
                  ))}
                  <div className="border-t border-zinc-100 mt-2 pt-2">
                    <button className="w-full text-left px-4 py-2 flex items-center gap-2 text-sm text-zinc-600 font-medium hover:text-zinc-900 transition-colors">
                      <Plus size={16} /> Create Workspace
                    </button>
                  </div>
               </div>
             </div>

             <div className="h-6 w-px bg-zinc-200 hidden lg:block mx-1"></div>

             <button className="hidden sm:flex items-center gap-2 text-sm font-semibold text-zinc-600 hover:text-zinc-900 bg-white border border-zinc-200 px-3 py-1.5 rounded-lg shadow-sm hover:shadow transition-all">
               <Upload size={16} /> <span className="hidden xl:inline">Upload CSV</span>
             </button>
             
             <button className="flex items-center gap-2 text-sm font-bold text-white bg-[#635BFF] hover:bg-[#5249E5] px-4 py-1.5 rounded-lg shadow-sm shadow-[#635BFF]/20 hover:shadow-md transition-all">
               <Plus size={16} /> <span>Publish</span>
             </button>

             <button className="relative p-2 text-zinc-500 hover:text-zinc-900 transition-colors">
               <Bell size={20} />
               <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-red-500 rounded-full border border-white"></span>
             </button>

             <div className="w-8 h-8 rounded-full bg-gradient-to-tr from-indigo-500 to-purple-500 border-2 border-white shadow-sm cursor-pointer hover:scale-105 transition-transform ml-2 flex items-center justify-center text-[10px] text-white font-bold">
                {userContext?.email?.[0]?.toUpperCase() || 'U'}
             </div>
          </div>

        </header>

        {/* PAGE CONTENT */}
        <main className="flex-1 overflow-y-auto relative p-4 md:p-8">
          {children}
        </main>

      </div>

    </div>
  );
}

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <WorkspaceProvider>
      <DashboardLayoutContent>{children}</DashboardLayoutContent>
    </WorkspaceProvider>
  );
}
