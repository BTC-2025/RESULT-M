"use client";

import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { 
  AlertCircle, Calendar, Filter, Download, RefreshCw, Zap, TrendingUp, Sparkles, X
} from 'lucide-react';
import { useWorkspace } from '../WorkspaceContext';



const AI_INSIGHTS = [
  { text: "Searches increased 18% today.", type: 'positive' },
  { text: "Most users came from Chennai this week.", type: 'info' },
  { text: "Dataset 'TNPSC Results' gained 40% views.", type: 'positive' },
  { text: "Complaints reduced by 22%.", type: 'positive' },
  { text: "API response time spiked at 10 AM.", type: 'warning' },
];

export default function AnalyticsLayout({ children }: { children: React.ReactNode }) {
  const { activeWorkspace } = useWorkspace();
  const [dateRange, setDateRange] = useState('Last 30 Days');
  const [isInsightsOpen, setIsInsightsOpen] = useState(true);



  return (
    <div className="min-h-[calc(100vh-4rem)] flex flex-col bg-zinc-50/50">
      
      {/* Global Filter Bar */}
      <div className="bg-white/80 backdrop-blur-xl border-b border-zinc-200 px-6 py-3 flex flex-wrap items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="flex items-center gap-2 bg-zinc-100/80 px-3 py-1.5 rounded-lg border border-zinc-200/50 cursor-pointer hover:bg-zinc-200/50 transition-colors">
            <Calendar className="w-4 h-4 text-zinc-500" />
            <span className="text-sm font-semibold text-zinc-700">{dateRange}</span>
          </div>
          <div className="flex items-center gap-2 bg-zinc-100/80 px-3 py-1.5 rounded-lg border border-zinc-200/50 cursor-pointer hover:bg-zinc-200/50 transition-colors">
            <Filter className="w-4 h-4 text-zinc-500" />
            <span className="text-sm font-semibold text-zinc-700">Add Filter</span>
          </div>
        </div>
        
        <div className="flex items-center gap-3">
          <button className="flex items-center gap-2 px-3 py-1.5 text-sm font-semibold text-zinc-600 hover:text-zinc-900 transition-colors">
            <RefreshCw className="w-4 h-4" /> Refresh
          </button>
          <button className="flex items-center gap-2 px-3 py-1.5 text-sm font-semibold bg-zinc-900 text-white rounded-lg shadow-sm hover:bg-zinc-800 transition-colors">
            <Download className="w-4 h-4" /> Export
          </button>
        </div>
      </div>

      <div className="flex flex-1 overflow-hidden">
        


        {/* Main Content Area */}
        <main className="flex-1 overflow-y-auto custom-scrollbar p-4 md:p-6">
          <div className="max-w-[1200px] mx-auto">
            {children}
          </div>
        </main>

        {/* Right Sidebar: AI Insights */}
        {isInsightsOpen && (
          <aside className="w-80 shrink-0 border-l border-zinc-200 bg-white/50 backdrop-blur-xl hidden xl:flex flex-col">
            <div className="p-5 border-b border-zinc-200 flex items-center justify-between">
              <div className="flex items-center gap-2">
                <div className="p-1.5 rounded-lg bg-gradient-to-br from-purple-500 to-indigo-600 shadow-sm">
                  <Sparkles className="w-4 h-4 text-white" />
                </div>
                <h3 className="font-bold text-zinc-900">AI Insights</h3>
              </div>
              <button onClick={() => setIsInsightsOpen(false)} className="text-zinc-400 hover:text-zinc-700">
                <X className="w-4 h-4" />
              </button>
            </div>
            
            <div className="flex-1 overflow-y-auto p-5 space-y-4">
              <p className="text-xs font-semibold text-zinc-500 mb-2 uppercase tracking-wider">Generated Just Now</p>
              
              {AI_INSIGHTS.map((insight, i) => (
                <motion.div 
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: i * 0.1 }}
                  key={i} 
                  className="p-4 rounded-xl bg-white border border-zinc-200 shadow-sm relative overflow-hidden group"
                >
                  <div className={`absolute left-0 top-0 bottom-0 w-1 ${
                    insight.type === 'positive' ? 'bg-emerald-500' : 
                    insight.type === 'warning' ? 'bg-amber-500' : 'bg-blue-500'
                  }`} />
                  <div className="flex gap-3">
                    <div className="mt-0.5">
                      {insight.type === 'positive' ? <TrendingUp className="w-4 h-4 text-emerald-500" /> : 
                       insight.type === 'warning' ? <AlertCircle className="w-4 h-4 text-amber-500" /> : 
                       <Zap className="w-4 h-4 text-blue-500" />}
                    </div>
                    <p className="text-sm font-medium text-zinc-700 leading-snug">{insight.text}</p>
                  </div>
                </motion.div>
              ))}

              <div className="mt-8 p-4 bg-gradient-to-br from-purple-50 to-indigo-50 border border-purple-100 rounded-xl">
                <h4 className="text-xs font-bold text-purple-900 uppercase tracking-wider mb-2">Recommendation</h4>
                <p className="text-sm text-purple-800 font-medium leading-relaxed">
                  Traffic from mobile devices dropped 12% over the weekend. Consider running an email campaign with mobile-friendly content links.
                </p>
                <button className="mt-3 text-xs font-bold text-white bg-purple-600 px-3 py-1.5 rounded-lg shadow-sm hover:bg-purple-700 transition-colors w-full">
                  Create Campaign
                </button>
              </div>
            </div>
          </aside>
        )}
      </div>
    </div>
  );
}
