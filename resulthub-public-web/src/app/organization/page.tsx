"use client";

import Link from "next/link";
import { motion, useScroll, useTransform } from "framer-motion";
import { useRef } from "react";
import { 
  Building2, Server, Users, ShieldCheck, Database, LayoutGrid, 
  ChevronRight, Lock, Key, Eye, Globe, Zap, Network, Briefcase, 
  GraduationCap, Building, Stethoscope, Medal, Scale, Landmark,
  BarChart3, Search, MessageSquare, Heart, ArrowUpRight, CheckCircle2,
  PieChart, Activity
} from "lucide-react";

export default function OrganizationLandingPage() {
  const containerRef = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start start", "end end"]
  });

  // Stagger variants for smooth section reveals
  const fadeUpVariant = {
    hidden: { opacity: 0, y: 50 },
    visible: { opacity: 1, y: 0, transition: { duration: 0.8 } }
  };

  return (
    <div ref={containerRef} className="min-h-screen bg-[#FAFAFA] text-zinc-900 font-sans selection:bg-primary/20">
      
      {/* LOCAL HEADER */}
      <nav className="fixed top-0 w-full z-50 bg-[#FAFAFA]/70 backdrop-blur-2xl border-b border-black/5 transition-all">
        <div className="max-w-[1440px] mx-auto px-6 h-16 flex items-center justify-between">
          <Link href="/" className="flex items-center gap-3 group">
             <div className="w-8 h-8 flex items-center justify-center rounded-xl bg-gradient-to-br from-indigo-600 to-purple-600 text-white font-black text-sm shadow-lg shadow-indigo-500/20 group-hover:scale-105 transition-transform duration-300">
                R
             </div>
             <span className="font-extrabold text-lg tracking-tight bg-clip-text text-transparent bg-gradient-to-r from-zinc-900 to-zinc-600">ResultHub</span>
             <span className="px-2 py-0.5 rounded-full bg-indigo-50 text-indigo-600 text-[10px] font-black uppercase tracking-widest ml-1 border border-indigo-100">Org</span>
          </Link>
          <div className="flex items-center gap-6">
             <Link href="/contact" className="text-sm font-semibold text-zinc-500 hover:text-zinc-900 transition-colors hidden sm:block">Sales</Link>
             <Link href="/organization/create" className="text-sm font-semibold text-zinc-500 hover:text-zinc-900 transition-colors hidden sm:block">Register</Link>
             <Link href="/organization/login" className="flex items-center gap-2 bg-zinc-900 text-white px-5 py-2 rounded-full text-sm font-bold shadow-[0_4px_14px_0_rgb(0,0,0,20%)] hover:shadow-[0_6px_20px_rgba(0,0,0,0.23)] hover:-translate-y-0.5 transition-all duration-200">
               Sign In
               <ChevronRight size={16} />
             </Link>
          </div>
        </div>
      </nav>

      {/* HERO SECTION */}
      <section className="relative pt-32 pb-20 lg:pt-48 lg:pb-32 overflow-hidden flex items-center justify-center min-h-[95vh]">
        
        {/* Vibrant Animated Background Meshes */}
        <div className="absolute top-1/4 left-1/4 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-indigo-500/20 rounded-full blur-[120px] opacity-70 pointer-events-none animate-pulse"></div>
        <div className="absolute bottom-1/4 right-1/4 translate-x-1/4 translate-y-1/4 w-[600px] h-[600px] bg-purple-500/20 rounded-full blur-[120px] opacity-60 pointer-events-none" style={{animation: 'pulse 8s infinite alternate-reverse'}}></div>
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[800px] bg-emerald-500/10 rounded-full blur-[120px] opacity-50 pointer-events-none"></div>
        <div className="absolute bottom-0 left-0 w-full h-[30vh] bg-gradient-to-t from-[#FAFAFA] to-transparent z-10 pointer-events-none"></div>

        <div className="max-w-[1200px] mx-auto px-6 relative z-20 flex flex-col items-center text-center">
          
          <motion.div 
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1] }}
            className="flex items-center gap-2 px-4 py-2 rounded-full bg-white border border-black/5 shadow-sm mb-8 hover:shadow-md transition-shadow cursor-pointer"
          >
            <span className="w-2.5 h-2.5 rounded-full bg-indigo-500 animate-ping absolute"></span>
            <span className="w-2.5 h-2.5 rounded-full bg-indigo-500 relative"></span>
            <span className="text-xs font-bold text-zinc-700 tracking-wide ml-1">ResultHub Enterprise is Live</span>
            <ArrowUpRight size={14} className="text-zinc-400"/>
          </motion.div>

          <motion.h1 
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.1, ease: [0.16, 1, 0.3, 1] }}
            className="text-5xl sm:text-6xl md:text-7xl lg:text-[92px] font-extrabold tracking-tight leading-[1.05] text-zinc-950 max-w-5xl"
          >
            Manage Results. <br className="hidden md:block"/>
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500">Publish Data.</span> <br className="hidden md:block"/>
            Engage Communities.
          </motion.h1>

          <motion.p 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.2, ease: [0.16, 1, 0.3, 1] }}
            className="mt-8 text-lg md:text-2xl text-zinc-500 max-w-3xl font-medium leading-relaxed"
          >
            Empower your organization to publish structured data, manage workspaces, collaborate with teams, and reach millions through one secure platform.
          </motion.p>

          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.3, ease: [0.16, 1, 0.3, 1] }}
            className="flex flex-col sm:flex-row items-center gap-4 mt-12 w-full sm:w-auto"
          >
             <Link href="/organization/login" className="w-full sm:w-auto px-8 py-4 bg-zinc-900 text-white rounded-2xl font-bold text-lg shadow-[0_8px_30px_rgb(0,0,0,0.12)] hover:scale-105 active:scale-95 transition-transform flex items-center justify-center gap-2">
               Organization Login
               <ArrowUpRight size={18}/>
             </Link>
             <Link href="/results" className="w-full sm:w-auto px-8 py-4 bg-white border border-black/10 text-zinc-900 rounded-2xl font-bold text-lg shadow-sm hover:bg-zinc-50 active:scale-95 transition-all flex items-center justify-center gap-2">
               Explore Platform
             </Link>
          </motion.div>

          {/* Animated Ecosystem Visual */}
          <motion.div 
            initial={{ opacity: 0, y: 40 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 1.2, delay: 0.5, ease: [0.16, 1, 0.3, 1] }}
            className="mt-16 md:mt-24 relative w-full max-w-6xl md:aspect-[21/9] border border-white/50 bg-white/40 backdrop-blur-3xl rounded-[40px] shadow-2xl p-6 md:p-8 overflow-hidden flex flex-col md:flex-row items-center justify-center"
          >
             {/* Ecosystem Map Animated Lines (Desktop Only) */}
             <svg className="hidden md:block absolute inset-0 w-full h-full opacity-30" preserveAspectRatio="none">
               <motion.path 
                 d="M 200,200 C 400,100 600,300 800,200" 
                 stroke="url(#gradient1)" 
                 strokeWidth="3" 
                 fill="none" 
                 initial={{ pathLength: 0 }}
                 animate={{ pathLength: 1 }}
                 transition={{ duration: 2.5, repeat: Infinity, repeatType: "loop", ease: "linear" }}
               />
               <motion.path 
                 d="M 800,200 C 600,400 400,100 200,300" 
                 stroke="url(#gradient2)" 
                 strokeWidth="3" 
                 fill="none" 
                 initial={{ pathLength: 0 }}
                 animate={{ pathLength: 1 }}
                 transition={{ duration: 3, repeat: Infinity, repeatType: "loop", ease: "linear", delay: 1 }}
               />
               <defs>
                 <linearGradient id="gradient1" x1="0%" y1="0%" x2="100%" y2="0%">
                   <stop offset="0%" stopColor="#6366f1" stopOpacity="0" />
                   <stop offset="50%" stopColor="#6366f1" stopOpacity="1" />
                   <stop offset="100%" stopColor="#6366f1" stopOpacity="0" />
                 </linearGradient>
                 <linearGradient id="gradient2" x1="0%" y1="0%" x2="100%" y2="0%">
                   <stop offset="0%" stopColor="#a855f7" stopOpacity="0" />
                   <stop offset="50%" stopColor="#a855f7" stopOpacity="1" />
                   <stop offset="100%" stopColor="#a855f7" stopOpacity="0" />
                 </linearGradient>
               </defs>
             </svg>

             {/* Floating Nodes */}
             <div className="relative flex flex-col md:block gap-4 items-center justify-center z-10 w-full h-full">
                
                <motion.div animate={{ y: [0, -15, 0] }} transition={{ duration: 5, repeat: Infinity, ease: "easeInOut" }} className="relative md:absolute md:top-[20%] md:left-[10%] w-full md:w-52 bg-white/90 backdrop-blur-md p-5 rounded-2xl shadow-[0_8px_30px_rgb(0,0,0,0.08)] border border-black/5 flex items-center gap-4">
                  <div className="w-12 h-12 bg-indigo-100 text-indigo-600 rounded-xl flex items-center justify-center shrink-0"><Building2 size={24}/></div>
                  <div className="flex flex-col text-left"><span className="text-sm font-bold">Workspace</span><span className="text-xs text-zinc-400">Admin Control</span></div>
                </motion.div>

                <motion.div animate={{ y: [0, 15, 0] }} transition={{ duration: 6, repeat: Infinity, ease: "easeInOut", delay: 1 }} className="relative md:absolute md:bottom-[20%] md:left-[30%] w-full md:w-52 bg-white/90 backdrop-blur-md p-5 rounded-2xl shadow-[0_8px_30px_rgb(0,0,0,0.08)] border border-black/5 flex items-center gap-4">
                  <div className="w-12 h-12 bg-emerald-100 text-emerald-600 rounded-xl flex items-center justify-center shrink-0"><Database size={24}/></div>
                  <div className="flex flex-col text-left"><span className="text-sm font-bold">Datasets</span><span className="text-xs text-zinc-400">Live Engine</span></div>
                </motion.div>

                <motion.div animate={{ y: [0, -10, 0] }} transition={{ duration: 4.5, repeat: Infinity, ease: "easeInOut", delay: 0.5 }} className="relative md:absolute md:top-[30%] md:right-[30%] w-full md:w-52 bg-white/90 backdrop-blur-md p-5 rounded-2xl shadow-[0_8px_30px_rgb(0,0,0,0.08)] border border-black/5 flex items-center gap-4">
                  <div className="w-12 h-12 bg-purple-100 text-purple-600 rounded-xl flex items-center justify-center shrink-0"><Users size={24}/></div>
                  <div className="flex flex-col text-left"><span className="text-sm font-bold">Community</span><span className="text-xs text-zinc-400">1.2M Users</span></div>
                </motion.div>

                <motion.div animate={{ y: [0, 20, 0] }} transition={{ duration: 5.5, repeat: Infinity, ease: "easeInOut", delay: 1.5 }} className="relative md:absolute md:bottom-[30%] md:right-[10%] w-full md:w-52 bg-white/90 backdrop-blur-md p-5 rounded-2xl shadow-[0_8px_30px_rgb(0,0,0,0.08)] border border-black/5 flex items-center gap-4">
                  <div className="w-12 h-12 bg-pink-100 text-pink-600 rounded-xl flex items-center justify-center shrink-0"><BarChart3 size={24}/></div>
                  <div className="flex flex-col text-left"><span className="text-sm font-bold">Analytics</span><span className="text-xs text-zinc-400">Real-time</span></div>
                </motion.div>

             </div>
          </motion.div>
        </div>
      </section>

      {/* TRUST MARQUEE */}
      <section className="py-12 border-y border-black/5 bg-white overflow-hidden relative z-20">
        <div className="max-w-[1440px] mx-auto px-6 mb-8 text-center">
          <p className="text-xs font-black uppercase tracking-widest text-zinc-400">Trusted by modern organizations globally</p>
        </div>
        <div className="flex w-fit whitespace-nowrap animate-marquee items-center gap-10 md:gap-32 px-4 md:px-8">
           {/* Duplicated for infinite scroll effect */}
           {[...Array(3)].map((_, i) => (
             <div key={i} className="flex items-center gap-10 md:gap-32 text-zinc-300 font-extrabold text-xl md:text-3xl">
                <span className="hover:text-zinc-400 transition-colors cursor-default">Stanford University</span>
                <span className="hover:text-zinc-400 transition-colors cursor-default">Ministry of Health</span>
                <span className="hover:text-zinc-400 transition-colors cursor-default">TechCorp Inc.</span>
                <span className="hover:text-zinc-400 transition-colors cursor-default">BCCI Cricket</span>
                <span className="hover:text-zinc-400 transition-colors cursor-default">Global NGO Fund</span>
             </div>
           ))}
        </div>
      </section>

      {/* COMPREHENSIVE SCROLL STORYTELLING */}
      <section className="py-32 max-w-[1200px] mx-auto px-6 flex flex-col gap-32 lg:gap-48 relative z-20">
        
        {/* Story 1: Workspace Management */}
        <motion.div 
          initial="hidden" whileInView="visible" viewport={{ once: true, margin: "-100px" }} variants={fadeUpVariant}
          className="flex flex-col lg:flex-row items-center gap-16"
        >
          <div className="flex-1 space-y-6">
            <div className="w-14 h-14 bg-indigo-50 rounded-2xl flex items-center justify-center text-indigo-600 border border-indigo-100 shadow-sm"><Building2 size={28}/></div>
            <h2 className="text-4xl md:text-5xl font-extrabold tracking-tight text-zinc-900">Enterprise Workspace Management.</h2>
            <p className="text-lg text-zinc-500 font-medium leading-relaxed">
              Model your real-world organization hierarchy. Create departments, assign precise roles, and collaborate securely in isolated environments without friction.
            </p>
            <ul className="space-y-3 mt-6">
              {['Unlimited Sub-Departments', 'Granular Role Permissions', 'Secure Isolation'].map(item => (
                <li key={item} className="flex items-center gap-3 text-zinc-700 font-semibold">
                  <CheckCircle2 size={20} className="text-indigo-500"/> {item}
                </li>
              ))}
            </ul>
          </div>
          <div className="flex-1 w-full relative">
            <div className="bg-zinc-950 p-8 rounded-[32px] shadow-[0_20px_50px_rgba(0,0,0,0.3)] relative overflow-hidden text-white min-h-[350px] flex items-center justify-center border border-zinc-800">
              <div className="absolute inset-0 opacity-20 bg-[radial-gradient(circle_at_center,rgba(255,255,255,0.2)_1px,transparent_1px)] bg-[size:16px_16px]"></div>
              
              <div className="flex flex-col gap-4 relative z-10 w-full max-w-sm">
                 <motion.div whileHover={{ scale: 1.02, x: 5 }} className="bg-white/10 backdrop-blur-md border border-white/10 p-4 rounded-2xl flex items-center gap-4 shadow-lg cursor-pointer transition-all">
                   <div className="w-10 h-10 rounded-xl bg-indigo-500/20 text-indigo-400 flex items-center justify-center"><Building size={20}/></div>
                   <div>
                     <span className="font-bold block">Engineering Dept</span>
                     <span className="text-xs text-zinc-400">Parent Node</span>
                   </div>
                 </motion.div>
                 
                 {/* Connection Line */}
                 <div className="w-0.5 h-6 bg-zinc-700 ml-9"></div>

                 <motion.div whileHover={{ scale: 1.02, x: 5 }} className="bg-white/5 backdrop-blur-md border border-white/5 p-4 rounded-2xl flex items-center gap-4 ml-4 shadow-lg cursor-pointer transition-all">
                   <div className="w-10 h-10 rounded-xl bg-purple-500/20 text-purple-400 flex items-center justify-center"><Users size={20}/></div>
                   <div>
                     <span className="font-bold block text-zinc-200">Frontend Team</span>
                     <span className="text-xs text-zinc-400">12 Members • Admin</span>
                   </div>
                 </motion.div>
              </div>
            </div>
          </div>
        </motion.div>

        {/* Story 2: Generic Engine */}
        <motion.div 
          initial="hidden" whileInView="visible" viewport={{ once: true, margin: "-100px" }} variants={fadeUpVariant}
          className="flex flex-col lg:flex-row-reverse items-center gap-16"
        >
          <div className="flex-1 space-y-6">
            <div className="w-14 h-14 bg-emerald-50 rounded-2xl flex items-center justify-center text-emerald-600 border border-emerald-100 shadow-sm"><Database size={28}/></div>
            <h2 className="text-4xl md:text-5xl font-extrabold tracking-tight text-zinc-900">Generic Dataset Engine.</h2>
            <p className="text-lg text-zinc-500 font-medium leading-relaxed">
              Push any structured JSON data. Our rendering engine automatically transforms it into dynamic UI, searchable tables, and interactive dashboards with zero configuration.
            </p>
          </div>
          <div className="flex-1 w-full relative group">
            <div className="bg-white border border-black/10 p-3 rounded-[32px] shadow-xl min-h-[350px] flex items-center justify-center group-hover:shadow-2xl transition-shadow duration-500 overflow-hidden relative">
              
              {/* Animated Gradient Glow */}
              <div className="absolute inset-0 bg-gradient-to-br from-emerald-500/5 to-blue-500/5 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>

              <div className="bg-zinc-950 w-full h-full rounded-[24px] p-8 font-mono text-sm overflow-hidden shadow-inner relative z-10">
                <div className="flex gap-2 mb-4">
                  <div className="w-3 h-3 rounded-full bg-red-500"></div>
                  <div className="w-3 h-3 rounded-full bg-yellow-500"></div>
                  <div className="w-3 h-3 rounded-full bg-green-500"></div>
                </div>
                <motion.div 
                  initial={{ opacity: 0 }}
                  whileInView={{ opacity: 1 }}
                  transition={{ duration: 1.5, staggerChildren: 0.2 }}
                  className="text-zinc-300"
                >
                  <span className="text-purple-400">const</span> dataset = {'{'} <br/>
                  &nbsp;&nbsp;<span className="text-blue-400">schema</span>: <span className="text-emerald-400">"auto-generate"</span>, <br/>
                  &nbsp;&nbsp;<span className="text-blue-400">records</span>: [ <br/>
                  &nbsp;&nbsp;&nbsp;&nbsp;{'{'} id: <span className="text-emerald-400">"TNPSC-2026"</span>, status: <span className="text-emerald-400">"Published"</span> {'}'}<br/>
                  &nbsp;&nbsp;] <br/>
                  {'}'};
                  <br/><br/>
                  <span className="text-zinc-500">// ResultHub Engine renders this instantly.</span>
                  <motion.div 
                    initial={{ width: 0 }}
                    whileInView={{ width: "100%" }}
                    transition={{ delay: 1, duration: 1 }}
                    className="h-1 bg-gradient-to-r from-emerald-500 to-blue-500 mt-4 rounded-full"
                  />
                </motion.div>
              </div>
            </div>
          </div>
        </motion.div>

        {/* Story 3: Community */}
        <motion.div 
          initial="hidden" whileInView="visible" viewport={{ once: true, margin: "-100px" }} variants={fadeUpVariant}
          className="flex flex-col lg:flex-row items-center gap-16"
        >
          <div className="flex-1 space-y-6">
            <div className="w-14 h-14 bg-pink-50 rounded-2xl flex items-center justify-center text-pink-600 border border-pink-100 shadow-sm"><Heart size={28}/></div>
            <h2 className="text-4xl md:text-5xl font-extrabold tracking-tight text-zinc-900">Social Engagement.</h2>
            <p className="text-lg text-zinc-500 font-medium leading-relaxed">
              Don't just publish data into the void. ResultHub features native social mechanics allowing your audience to follow, like, comment, and participate in polls directly on your records.
            </p>
          </div>
          <div className="flex-1 w-full relative">
            <div className="bg-gradient-to-br from-pink-500 to-rose-600 p-8 rounded-[32px] shadow-2xl relative overflow-hidden min-h-[350px] flex flex-col items-center justify-center gap-6">
               
               <motion.div whileHover={{ scale: 1.05 }} className="w-full max-w-sm bg-white rounded-2xl p-5 shadow-lg">
                 <div className="flex items-center gap-3 mb-3">
                   <div className="w-8 h-8 rounded-full bg-zinc-200"></div>
                   <div className="flex-1"><div className="h-2 w-24 bg-zinc-200 rounded-full"></div></div>
                 </div>
                 <div className="h-2 w-full bg-zinc-100 rounded-full mb-2"></div>
                 <div className="h-2 w-2/3 bg-zinc-100 rounded-full mb-4"></div>
                 
                 <div className="flex items-center gap-6 pt-3 border-t border-zinc-100 text-zinc-400">
                    <motion.div whileTap={{ scale: 0.9 }} className="flex items-center gap-1.5 cursor-pointer hover:text-pink-500 transition-colors">
                      <Heart size={18} className="fill-pink-500 text-pink-500"/>
                      <span className="text-sm font-bold text-pink-500">12.4k</span>
                    </motion.div>
                    <div className="flex items-center gap-1.5 cursor-pointer hover:text-zinc-600">
                      <MessageSquare size={18}/>
                      <span className="text-sm font-bold">842</span>
                    </div>
                 </div>
               </motion.div>

               <motion.div animate={{ y: [0, -10, 0] }} transition={{ duration: 4, repeat: Infinity, ease: "easeInOut" }} className="absolute -right-4 top-12 bg-white px-4 py-3 rounded-2xl shadow-xl flex items-center gap-3">
                  <div className="w-8 h-8 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center"><Activity size={16}/></div>
                  <div>
                    <span className="block text-sm font-bold text-zinc-900">New Poll Vote</span>
                    <span className="block text-xs text-zinc-500">Just now</span>
                  </div>
               </motion.div>

            </div>
          </div>
        </motion.div>

        {/* Story 4: Global Search */}
        <motion.div 
          initial="hidden" whileInView="visible" viewport={{ once: true, margin: "-100px" }} variants={fadeUpVariant}
          className="flex flex-col lg:flex-row-reverse items-center gap-16"
        >
          <div className="flex-1 space-y-6">
            <div className="w-14 h-14 bg-blue-50 rounded-2xl flex items-center justify-center text-blue-600 border border-blue-100 shadow-sm"><Search size={28}/></div>
            <h2 className="text-4xl md:text-5xl font-extrabold tracking-tight text-zinc-900">Global Query Engine.</h2>
            <p className="text-lg text-zinc-500 font-medium leading-relaxed">
              Every piece of data you publish is instantly indexed. Users can find your datasets, records, and posts globally via our blazing-fast Command Palette search.
            </p>
          </div>
          <div className="flex-1 w-full relative">
            <div className="bg-zinc-100 border border-black/5 p-8 rounded-[32px] shadow-inner relative overflow-hidden min-h-[350px] flex items-center justify-center">
               
               <motion.div 
                 initial={{ y: 20, opacity: 0 }}
                 whileInView={{ y: 0, opacity: 1 }}
                 transition={{ delay: 0.2 }}
                 className="w-full max-w-sm bg-white rounded-2xl shadow-2xl overflow-hidden border border-black/10"
               >
                 <div className="p-4 border-b border-black/5 flex items-center gap-3 bg-zinc-50">
                    <Search size={20} className="text-zinc-400"/>
                    <motion.div 
                      initial={{ width: 0 }}
                      whileInView={{ width: "100%" }}
                      transition={{ delay: 0.5, duration: 1 }}
                      className="overflow-hidden whitespace-nowrap"
                    >
                      <span className="text-zinc-900 font-bold">Stanford 2026 Admissions</span>
                    </motion.div>
                 </div>
                 <div className="p-2 bg-white">
                    <div className="px-3 py-2 text-xs font-bold text-zinc-400 uppercase tracking-wider">Results</div>
                    <div className="p-3 bg-blue-50 rounded-xl flex items-center gap-3 cursor-pointer">
                       <div className="w-8 h-8 rounded-lg bg-blue-100 text-blue-600 flex items-center justify-center"><Database size={16}/></div>
                       <div>
                         <span className="block font-bold text-zinc-900 text-sm">Admissions Dataset</span>
                         <span className="block text-xs text-zinc-500">Stanford University • Live</span>
                       </div>
                    </div>
                 </div>
               </motion.div>

            </div>
          </div>
        </motion.div>

        {/* Story 5: Analytics */}
        <motion.div 
          initial="hidden" whileInView="visible" viewport={{ once: true, margin: "-100px" }} variants={fadeUpVariant}
          className="flex flex-col lg:flex-row items-center gap-16"
        >
          <div className="flex-1 space-y-6">
            <div className="w-14 h-14 bg-orange-50 rounded-2xl flex items-center justify-center text-orange-600 border border-orange-100 shadow-sm"><PieChart size={28}/></div>
            <h2 className="text-4xl md:text-5xl font-extrabold tracking-tight text-zinc-900">Real-time Analytics.</h2>
            <p className="text-lg text-zinc-500 font-medium leading-relaxed">
              Understand exactly how your data is performing. Track views, unique downloads, engagement heatmaps, and demographic breakdowns in beautiful dashboards.
            </p>
          </div>
          <div className="flex-1 w-full relative">
            <div className="bg-zinc-900 p-8 rounded-[32px] shadow-2xl relative overflow-hidden text-white min-h-[350px] flex flex-col items-center justify-center">
               
               {/* Animated Chart Bars */}
               <div className="flex items-end gap-4 h-40 w-full max-w-xs border-b border-white/20 pb-4">
                  {[40, 70, 45, 90, 60, 110, 85].map((height, i) => (
                    <motion.div 
                      key={i}
                      initial={{ height: 0 }}
                      whileInView={{ height: `${(height / 110) * 100}%` }}
                      transition={{ duration: 0.8, delay: i * 0.1, type: "spring" }}
                      className="flex-1 bg-gradient-to-t from-orange-600 to-orange-400 rounded-t-sm"
                    ></motion.div>
                  ))}
               </div>
               
               <div className="mt-8 flex gap-8 w-full max-w-xs">
                 <div>
                   <span className="block text-zinc-400 text-sm font-medium mb-1">Total Views</span>
                   <span className="block text-3xl font-black">1.2M</span>
                 </div>
                 <div>
                   <span className="block text-zinc-400 text-sm font-medium mb-1">Downloads</span>
                   <span className="block text-3xl font-black text-emerald-400">+42%</span>
                 </div>
               </div>

            </div>
          </div>
        </motion.div>

      </section>

      {/* SECURITY VAULT SECTION */}
      <section className="bg-zinc-950 text-white py-32 relative overflow-hidden">
        {/* Animated Grid/Rings */}
        <div className="absolute top-0 left-0 w-full h-full opacity-20 pointer-events-none flex items-center justify-center">
          <motion.div 
             animate={{ rotate: 360 }}
             transition={{ duration: 60, repeat: Infinity, ease: "linear" }}
             className="w-[800px] h-[800px] border border-zinc-700 rounded-full"
          ></motion.div>
          <motion.div 
             animate={{ rotate: -360 }}
             transition={{ duration: 80, repeat: Infinity, ease: "linear" }}
             className="absolute w-[600px] h-[600px] border border-zinc-700 rounded-full border-dashed"
          ></motion.div>
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-full h-full bg-[radial-gradient(circle_at_center,transparent_0%,#09090b_70%)]"></div>
        </div>

        <div className="max-w-[1200px] mx-auto px-6 relative z-10 text-center">
          <div className="w-20 h-20 bg-white/5 rounded-3xl mx-auto flex items-center justify-center mb-8 border border-white/10 backdrop-blur-xl shadow-[0_0_50px_rgba(255,255,255,0.1)]">
             <ShieldCheck size={40} className="text-white"/>
          </div>
          <h2 className="text-4xl md:text-6xl font-extrabold tracking-tight mb-6">Enterprise-Grade Security.</h2>
          <p className="text-xl text-zinc-400 max-w-2xl mx-auto font-medium mb-20">
            Your data is protected by industry-leading security protocols. Designed for governments, hospitals, and financial institutions from day one.
          </p>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8 text-left">
             <motion.div whileHover={{ y: -5 }} className="p-8 rounded-3xl bg-zinc-900/50 border border-white/10 backdrop-blur-md shadow-xl transition-all">
               <div className="w-12 h-12 bg-emerald-500/10 rounded-2xl flex items-center justify-center mb-6 border border-emerald-500/20">
                 <Lock className="text-emerald-400" size={24}/>
               </div>
               <h3 className="text-xl font-bold mb-3 text-zinc-100">Role-Based Access</h3>
               <p className="text-zinc-400 leading-relaxed font-medium">Granular control over who can view, edit, or publish datasets within your workspace hierarchy.</p>
             </motion.div>

             <motion.div whileHover={{ y: -5 }} className="p-8 rounded-3xl bg-zinc-900/50 border border-white/10 backdrop-blur-md shadow-xl transition-all">
               <div className="w-12 h-12 bg-blue-500/10 rounded-2xl flex items-center justify-center mb-6 border border-blue-500/20">
                 <Key className="text-blue-400" size={24}/>
               </div>
               <h3 className="text-xl font-bold mb-3 text-zinc-100">JWT Authentication</h3>
               <p className="text-zinc-400 leading-relaxed font-medium">Stateless, cryptographically signed tokens ensure every API request is authenticated securely.</p>
             </motion.div>

             <motion.div whileHover={{ y: -5 }} className="p-8 rounded-3xl bg-zinc-900/50 border border-white/10 backdrop-blur-md shadow-xl transition-all">
               <div className="w-12 h-12 bg-purple-500/10 rounded-2xl flex items-center justify-center mb-6 border border-purple-500/20">
                 <Eye className="text-purple-400" size={24}/>
               </div>
               <h3 className="text-xl font-bold mb-3 text-zinc-100">Audit Logs</h3>
               <p className="text-zinc-400 leading-relaxed font-medium">Comprehensive tracking and immutability of every critical action taken within your organization.</p>
             </motion.div>
          </div>
        </div>
      </section>

      {/* ORGANIZATION TYPES GRID */}
      <section className="py-32 bg-white">
        <div className="max-w-[1200px] mx-auto px-6">
          <div className="text-center mb-20">
            <h2 className="text-4xl md:text-5xl font-extrabold tracking-tight mb-6 text-zinc-900">Built for Every Industry.</h2>
            <p className="text-xl text-zinc-500 font-medium max-w-2xl mx-auto">ResultHub scales perfectly whether you are publishing global exam results, municipal budgets, or live medical data.</p>
          </div>

          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
             {[
               { name: "Schools", icon: <Building />, color: "text-blue-600" },
               { name: "Universities", icon: <GraduationCap />, color: "text-indigo-600" },
               { name: "Government", icon: <Landmark />, color: "text-emerald-600" },
               { name: "Healthcare", icon: <Stethoscope />, color: "text-rose-600" },
               { name: "Sports", icon: <Medal />, color: "text-orange-600" },
               { name: "Law", icon: <Scale />, color: "text-slate-600" },
               { name: "Technology", icon: <Network />, color: "text-cyan-600" },
               { name: "Business", icon: <Briefcase />, color: "text-purple-600" },
             ].map((org, i) => (
               <motion.div 
                 key={org.name}
                 initial={{ opacity: 0, scale: 0.9, y: 20 }}
                 whileInView={{ opacity: 1, scale: 1, y: 0 }}
                 viewport={{ once: true }}
                 transition={{ delay: i * 0.05, type: "spring", stiffness: 100 }}
                 whileHover={{ y: -5, scale: 1.03 }}
                 className="p-8 rounded-[32px] bg-[#FAFAFA] border border-black/5 shadow-sm hover:shadow-xl hover:border-black/10 transition-all cursor-pointer flex flex-col items-center justify-center gap-5 text-center group"
               >
                 <div className={`w-16 h-16 rounded-2xl bg-white shadow-sm flex items-center justify-center ${org.color} group-hover:scale-110 transition-transform`}>
                   {org.icon}
                 </div>
                 <span className="font-extrabold text-zinc-800 text-lg group-hover:text-zinc-950">{org.name}</span>
               </motion.div>
             ))}
          </div>
        </div>
      </section>

      {/* FINAL CTA */}
      <section className="py-40 bg-[#FAFAFA] border-t border-black/5 overflow-hidden relative">
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[1000px] h-[500px] bg-gradient-to-b from-indigo-500/10 to-transparent blur-[100px] pointer-events-none"></div>
        <div className="max-w-[800px] mx-auto px-6 text-center relative z-10">
          <h2 className="text-4xl sm:text-5xl md:text-7xl font-extrabold tracking-tight mb-8 text-zinc-900 leading-tight">
            Ready to modernize your organization?
          </h2>
          <div className="flex flex-col sm:flex-row items-center justify-center gap-4 mt-12">
             <Link href="/organization/login" className="w-full sm:w-auto px-10 py-5 bg-zinc-900 text-white rounded-2xl font-bold text-lg shadow-[0_8px_30px_rgb(0,0,0,0.15)] hover:shadow-[0_10px_40px_rgb(0,0,0,0.25)] hover:-translate-y-1 active:scale-95 transition-all flex items-center justify-center gap-2">
               Login as Organization
               <ArrowUpRight size={20}/>
             </Link>
             <Link href="/contact" className="w-full sm:w-auto px-10 py-5 bg-white border border-black/10 text-zinc-900 rounded-2xl font-bold text-lg hover:bg-zinc-50 hover:-translate-y-1 active:scale-95 transition-all">
               Request Demo
             </Link>
          </div>
        </div>
      </section>

      {/* MINIMAL FOOTER */}
      <footer className="bg-white border-t border-black/5 py-16">
        <div className="max-w-[1200px] mx-auto px-6 flex flex-col md:flex-row justify-between items-center gap-8">
          <div className="flex flex-col items-center md:items-start gap-2">
            <div className="flex items-center gap-2">
               <div className="w-6 h-6 flex items-center justify-center rounded-lg bg-zinc-900 text-white font-black text-[10px]">R</div>
               <span className="font-extrabold tracking-tight text-zinc-900">ResultHub</span>
            </div>
            <span className="text-sm font-medium text-zinc-400">The Public Data Ecosystem</span>
          </div>
          
          <div className="flex flex-wrap items-center justify-center gap-8 text-sm font-bold text-zinc-500">
             <Link href="/developers" className="hover:text-zinc-900 transition-colors">Developers</Link>
             <Link href="/api" className="hover:text-zinc-900 transition-colors">API</Link>
             <Link href="/security" className="hover:text-zinc-900 transition-colors">Security</Link>
             <Link href="/privacy" className="hover:text-zinc-900 transition-colors">Privacy</Link>
             <Link href="/support" className="hover:text-zinc-900 transition-colors">Support</Link>
          </div>
          <div className="text-xs font-bold text-zinc-400 uppercase tracking-widest">
            © 2026 ResultHub Inc.
          </div>
        </div>
      </footer>

      {/* Global CSS for marquee */}
      <style dangerouslySetInnerHTML={{__html: `
        @keyframes marquee {
          0% { transform: translateX(0); }
          100% { transform: translateX(-50%); }
        }
        .animate-marquee {
          animation: marquee 30s linear infinite;
        }
      `}} />
    </div>
  );
}
