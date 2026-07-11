"use client";

import React from 'react';
import { motion } from 'framer-motion';
import { 
  Database, 
  ShieldCheck, 
  Server, 
  Search, 
  MessageSquareWarning, 
  CheckSquare,
  Globe2,
  ChevronRight,
  Code2,
  ArrowRight,
  BarChart3,
  Layers
} from 'lucide-react';
import Link from 'next/link';

export default function Home() {
  return (
    <div className="min-h-screen bg-[#0A0A0A] text-zinc-100 font-sans selection:bg-[#635BFF]/30 overflow-hidden">
      
      {/* 1. PREMIUM NAVIGATION */}
      <nav className="fixed top-0 left-0 right-0 z-50 bg-[#0A0A0A]/80 backdrop-blur-xl border-b border-zinc-800/50">
        <div className="max-w-7xl mx-auto px-6 h-16 flex items-center justify-between">
          <div className="flex items-center gap-8">
            <Link href="/" className="flex items-center gap-2">
              <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-[#635BFF] to-purple-600 flex items-center justify-center shadow-lg shadow-[#635BFF]/20">
                <span className="text-white font-black text-sm">RH</span>
              </div>
              <span className="font-extrabold text-lg tracking-tight text-white hidden sm:block">ResultHub</span>
            </Link>
            
            <div className="hidden md:flex items-center gap-6 text-sm font-medium text-zinc-400">
              <a href="#features" className="hover:text-white transition-colors">Features</a>
              <a href="#architecture" className="hover:text-white transition-colors">Architecture</a>
              <a href="#security" className="hover:text-white transition-colors">Security</a>
              <Link href="/search" className="hover:text-white transition-colors">Public Search</Link>
            </div>
          </div>
          
          <div className="flex items-center gap-4">
            <Link href="/login" className="text-sm font-bold text-zinc-300 hover:text-white transition-colors hidden sm:block">Sign In</Link>
            <Link href="/dashboard" className="px-4 py-2 bg-white text-zinc-900 rounded-lg text-sm font-bold hover:bg-zinc-200 transition-colors shadow-sm">
              Dashboard
            </Link>
          </div>
        </div>
      </nav>

      {/* 2. MASSIVE HERO SECTION */}
      <main className="relative pt-32 pb-20 md:pt-48 md:pb-32 px-6 max-w-7xl mx-auto">
        {/* Animated Background Gradients */}
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[800px] h-[400px] bg-[#635BFF]/20 blur-[120px] rounded-full pointer-events-none" />
        <div className="absolute top-40 left-1/2 translate-x-1/4 w-[600px] h-[300px] bg-purple-600/20 blur-[100px] rounded-full pointer-events-none" />

        <div className="relative z-10 flex flex-col items-center text-center">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
          >
            <Link href="/search" className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-zinc-900/50 border border-zinc-800 text-xs font-bold text-zinc-400 hover:text-white hover:border-zinc-700 transition-all mb-8">
              <span className="w-2 h-2 rounded-full bg-[#635BFF] animate-pulse" />
              Introducing Universal Search
              <ChevronRight className="w-3 h-3" />
            </Link>
          </motion.div>

          <motion.h1 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.1 }}
            className="text-5xl md:text-7xl lg:text-8xl font-black tracking-tighter text-white mb-6 leading-[1.1]"
          >
            The Operating System <br className="hidden md:block" />
            for <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#635BFF] via-purple-500 to-indigo-400">Public Data.</span>
          </motion.h1>

          <motion.p 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.2 }}
            className="text-lg md:text-xl text-zinc-400 max-w-2xl mx-auto mb-10 font-medium leading-relaxed"
          >
            ResultHub is a secure, multi-tenant publishing platform enabling organizations to manage datasets, run public polls, and resolve community complaints from one command center.
          </motion.p>

          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.3 }}
            className="flex flex-col sm:flex-row items-center gap-4 w-full sm:w-auto"
          >
            <Link href="/signup" className="w-full sm:w-auto px-8 py-4 bg-white text-zinc-900 rounded-xl font-bold text-sm hover:bg-zinc-200 transition-all flex items-center justify-center gap-2 shadow-[0_0_40px_-10px_rgba(255,255,255,0.3)]">
              Start your organization <ArrowRight className="w-4 h-4" />
            </Link>
            <Link href="/search" className="w-full sm:w-auto px-8 py-4 bg-zinc-900 border border-zinc-800 text-white rounded-xl font-bold text-sm hover:bg-zinc-800 transition-colors flex items-center justify-center gap-2">
              <Search className="w-4 h-4" /> Explore Public Data
            </Link>
          </motion.div>
        </div>

        {/* Floating Mock Dashboard Window */}
        <motion.div 
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.7, delay: 0.4 }}
          className="mt-20 relative mx-auto max-w-5xl"
        >
          <div className="absolute inset-0 bg-gradient-to-t from-[#0A0A0A] via-transparent to-transparent z-20 h-full w-full bottom-0 top-auto"></div>
          <div className="rounded-2xl border border-zinc-800/80 bg-zinc-950/80 p-2 shadow-2xl backdrop-blur-sm overflow-hidden">
            <div className="rounded-xl border border-zinc-800 bg-zinc-900 overflow-hidden">
              {/* Fake Window Header */}
              <div className="h-10 bg-zinc-950 border-b border-zinc-800 flex items-center px-4 gap-2">
                <div className="w-3 h-3 rounded-full bg-red-500/80" />
                <div className="w-3 h-3 rounded-full bg-amber-500/80" />
                <div className="w-3 h-3 rounded-full bg-emerald-500/80" />
              </div>
              {/* Fake Dashboard Content */}
              <div className="h-[400px] bg-[#F9FAFB] p-8 flex flex-col gap-6 relative overflow-hidden">
                <div className="absolute inset-0 bg-[url('https://www.transparenttextures.com/patterns/cubes.png')] opacity-5" />
                <div className="w-48 h-6 bg-zinc-200 rounded-md" />
                <div className="flex gap-4">
                  <div className="w-64 h-32 bg-white rounded-xl shadow-sm border border-zinc-200" />
                  <div className="w-64 h-32 bg-white rounded-xl shadow-sm border border-zinc-200" />
                  <div className="w-64 h-32 bg-white rounded-xl shadow-sm border border-zinc-200" />
                </div>
                <div className="w-full flex-1 bg-white rounded-xl shadow-sm border border-zinc-200" />
              </div>
            </div>
          </div>
        </motion.div>
      </main>

      {/* 3. BENTO GRID FEATURES (The 4 Pillars) */}
      <section id="features" className="py-24 px-6 max-w-7xl mx-auto border-t border-zinc-900">
        <div className="mb-16">
          <h2 className="text-3xl md:text-5xl font-black text-white tracking-tight mb-4">Four powerful ecosystems.<br />One unified platform.</h2>
          <p className="text-zinc-400 text-lg max-w-xl font-medium">ResultHub gives organizations the enterprise tools they need to publish, engage, and analyze public interaction securely.</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          
          {/* Results Space */}
          <div className="md:col-span-2 bg-gradient-to-br from-zinc-900 to-zinc-950 border border-zinc-800/80 rounded-3xl p-8 md:p-12 relative overflow-hidden group hover:border-zinc-700 transition-colors">
            <div className="absolute top-0 right-0 w-64 h-64 bg-[#635BFF]/10 rounded-full blur-3xl -translate-y-1/2 translate-x-1/2 group-hover:bg-[#635BFF]/20 transition-colors" />
            <div className="relative z-10 h-full flex flex-col justify-between">
              <div>
                <div className="w-12 h-12 bg-zinc-800 rounded-2xl flex items-center justify-center mb-6 text-[#635BFF]">
                  <Database className="w-6 h-6" />
                </div>
                <h3 className="text-2xl font-bold text-white mb-3">Results Space</h3>
                <p className="text-zinc-400 font-medium max-w-md">Our No-Code Dataset Builder allows organizations to securely publish structured records like exam results, merit lists, or financial data.</p>
              </div>
            </div>
          </div>

          {/* Voting Hub */}
          <div className="col-span-1 bg-gradient-to-br from-zinc-900 to-zinc-950 border border-zinc-800/80 rounded-3xl p-8 relative overflow-hidden group hover:border-zinc-700 transition-colors">
            <div className="relative z-10">
              <div className="w-12 h-12 bg-zinc-800 rounded-2xl flex items-center justify-center mb-6 text-emerald-400">
                <CheckSquare className="w-6 h-6" />
              </div>
              <h3 className="text-xl font-bold text-white mb-3">Voting Hub</h3>
              <p className="text-zinc-400 font-medium text-sm">Run public, private, or password-protected community polls with real-time participation analytics.</p>
            </div>
          </div>

          {/* Complaint Box */}
          <div className="col-span-1 bg-gradient-to-br from-zinc-900 to-zinc-950 border border-zinc-800/80 rounded-3xl p-8 relative overflow-hidden group hover:border-zinc-700 transition-colors">
            <div className="relative z-10">
              <div className="w-12 h-12 bg-zinc-800 rounded-2xl flex items-center justify-center mb-6 text-amber-400">
                <MessageSquareWarning className="w-6 h-6" />
              </div>
              <h3 className="text-xl font-bold text-white mb-3">Complaint Box</h3>
              <p className="text-zinc-400 font-medium text-sm">A dedicated portal to receive, manage, and resolve public complaints or civic issues securely.</p>
            </div>
          </div>

          {/* Organization Portal */}
          <div className="md:col-span-2 bg-gradient-to-br from-zinc-900 to-zinc-950 border border-zinc-800/80 rounded-3xl p-8 md:p-12 relative overflow-hidden group hover:border-zinc-700 transition-colors">
            <div className="absolute top-0 right-0 w-64 h-64 bg-purple-500/10 rounded-full blur-3xl -translate-y-1/2 translate-x-1/2 group-hover:bg-purple-500/20 transition-colors" />
            <div className="relative z-10 h-full flex flex-col justify-between">
              <div>
                <div className="w-12 h-12 bg-zinc-800 rounded-2xl flex items-center justify-center mb-6 text-purple-400">
                  <BarChart3 className="w-6 h-6" />
                </div>
                <h3 className="text-2xl font-bold text-white mb-3">Organization Portal</h3>
                <p className="text-zinc-400 font-medium max-w-md">Your secure administrative command center. Manage RBAC teams, view executive analytics, monitor audit logs, and configure Webhooks.</p>
              </div>
            </div>
          </div>

        </div>
      </section>

      {/* 4. ENTERPRISE ARCHITECTURE SECTION */}
      <section id="architecture" className="py-24 px-6 max-w-7xl mx-auto border-t border-zinc-900">
        <div className="flex flex-col md:flex-row gap-16 items-center">
          <div className="flex-1 space-y-6">
            <span className="text-[#635BFF] font-bold text-sm tracking-widest uppercase">Built for Scale</span>
            <h2 className="text-3xl md:text-4xl font-black text-white tracking-tight">Enterprise-grade architecture by default.</h2>
            <p className="text-zinc-400 font-medium text-lg leading-relaxed">
              ResultHub doesn't cut corners. Our backend is powered by <strong className="text-white">Java 21</strong> and <strong className="text-white">Spring Boot 3.5</strong>. 
              We utilize a highly optimized <strong className="text-white">PostgreSQL 16</strong> engine leveraging generic <strong className="text-white">JSONB</strong> data structures and GIN indexing for lightning-fast search across billions of dynamic records.
            </p>
            <div className="grid grid-cols-2 gap-4 pt-4">
              <div className="flex items-center gap-3"><Server className="w-5 h-5 text-zinc-500" /> <span className="font-bold text-sm">Multi-tenant Architecture</span></div>
              <div className="flex items-center gap-3"><ShieldCheck className="w-5 h-5 text-zinc-500" /> <span className="font-bold text-sm">Bucket4j Rate Limiting</span></div>
              <div className="flex items-center gap-3"><Code2 className="w-5 h-5 text-zinc-500" /> <span className="font-bold text-sm">100% API Ready</span></div>
              <div className="flex items-center gap-3"><Layers className="w-5 h-5 text-zinc-500" /> <span className="font-bold text-sm">Docker & Testcontainers</span></div>
            </div>
          </div>
          <div className="flex-1 w-full relative">
            <div className="absolute inset-0 bg-gradient-to-tr from-[#635BFF]/20 to-purple-600/20 blur-3xl rounded-full" />
            <div className="bg-zinc-950 border border-zinc-800 rounded-2xl p-6 font-mono text-xs text-zinc-300 relative z-10 shadow-2xl overflow-hidden">
              <div className="flex gap-2 mb-4 border-b border-zinc-800 pb-4">
                <span className="text-emerald-400">~/resulthub/backend</span>
                <span className="text-zinc-500">$ docker-compose up -d</span>
              </div>
              <div className="space-y-1 opacity-80">
                <p>Starting postgres_db_1 ... <span className="text-emerald-400">done</span></p>
                <p>Starting redis_cache_1 ... <span className="text-emerald-400">done</span></p>
                <p>Starting spring_boot_api ... <span className="text-emerald-400">done</span></p>
                <p className="text-purple-400 pt-2">ResultHub Engine v3.5.0 initialized successfully.</p>
                <p className="text-zinc-500">Listening on port 8080...</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* 5. GLOBAL FOOTER */}
      <footer className="border-t border-zinc-900 bg-zinc-950/50">
        <div className="max-w-7xl mx-auto px-6 py-16 md:py-24">
          <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-5 gap-8 mb-12">
            <div className="col-span-2 lg:col-span-2">
              <Link href="/" className="flex items-center gap-2 mb-6">
                <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-[#635BFF] to-purple-600 flex items-center justify-center">
                  <span className="text-white font-black text-sm">RH</span>
                </div>
                <span className="font-extrabold text-lg tracking-tight text-white">ResultHub</span>
              </Link>
              <p className="text-zinc-500 text-sm font-medium max-w-xs mb-6">
                The secure multi-tenant data publishing platform for organizations and enterprises.
              </p>
              <div className="flex items-center gap-4 text-zinc-500">
                <Globe2 className="w-5 h-5 hover:text-white cursor-pointer transition-colors" />
                <Code2 className="w-5 h-5 hover:text-white cursor-pointer transition-colors" />
              </div>
            </div>
            
            <div>
              <h4 className="font-bold text-white mb-4 text-sm">Product</h4>
              <ul className="space-y-3 text-sm font-medium text-zinc-500">
                <li><a href="#" className="hover:text-white transition-colors">Results Space</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Complaint Box</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Voting Hub</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Security Center</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Pricing</a></li>
              </ul>
            </div>

            <div>
              <h4 className="font-bold text-white mb-4 text-sm">Developers</h4>
              <ul className="space-y-3 text-sm font-medium text-zinc-500">
                <li><a href="#" className="hover:text-white transition-colors">API Documentation</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Webhooks</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Java SDK</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Status</a></li>
              </ul>
            </div>

            <div>
              <h4 className="font-bold text-white mb-4 text-sm">Company</h4>
              <ul className="space-y-3 text-sm font-medium text-zinc-500">
                <li><a href="#" className="hover:text-white transition-colors">About Us</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Careers</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Privacy Policy</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Terms of Service</a></li>
              </ul>
            </div>
          </div>
          
          <div className="border-t border-zinc-900 pt-8 flex flex-col md:flex-row items-center justify-between gap-4 text-sm font-medium text-zinc-600">
            <p>© {new Date().getFullYear()} ResultHub Inc. All rights reserved.</p>
            <div className="flex gap-6">
              <span className="flex items-center gap-2"><div className="w-2 h-2 rounded-full bg-emerald-500" /> All systems operational</span>
            </div>
          </div>
        </div>
      </footer>

    </div>
  );
}
