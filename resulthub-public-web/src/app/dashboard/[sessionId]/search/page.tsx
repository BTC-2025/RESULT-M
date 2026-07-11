"use client";

import { motion } from "framer-motion";
import { Search, TrendingUp, AlertCircle, BarChart2, Hash, ArrowUpRight, ChevronRight, Activity } from "lucide-react";

export default function SearchCenterPage() {
  const popularSearches = [
    { query: "Computer Science Results 2026", count: 12450, trend: "+12%" },
    { query: "Engineering Admissions", count: 8320, trend: "+5%" },
    { query: "Data Science Syllabus", count: 6200, trend: "-2%" },
    { query: "Q1 Financial Report", count: 4100, trend: "+24%" },
    { query: "Staff Directory", count: 3800, trend: "+1%" },
  ];

  const noResultSearches = [
    { query: "Physics 2027 Schedule", count: 420 },
    { query: "AI Lab Timings", count: 315 },
    { query: "Hostel Rules PDF", count: 280 },
    { query: "Medical Claim Form", count: 150 },
  ];

  return (
    <div className="max-w-7xl mx-auto w-full space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
      
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 text-[#635BFF] mb-2">
            <Search size={20} />
            <h2 className="text-sm font-bold uppercase tracking-widest">Search Center</h2>
          </div>
          <h1 className="text-3xl sm:text-4xl font-black text-zinc-950 tracking-tight">
            Search Analytics
          </h1>
          <p className="text-zinc-500 font-medium mt-1">
            Understand what your users are looking for and optimize discovery.
          </p>
        </div>
        <button className="flex items-center gap-2 bg-white border border-zinc-200 text-zinc-700 px-4 py-2 rounded-xl font-bold hover:bg-zinc-50 transition-colors shadow-sm text-sm">
          <ArrowUpRight size={16} /> Export Report
        </button>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {[
          { title: "Total Searches (30d)", value: "142.5K", icon: BarChart2, color: "text-blue-600", bg: "bg-blue-50" },
          { title: "Click-Through Rate", value: "68.2%", icon: Activity, color: "text-emerald-600", bg: "bg-emerald-50" },
          { title: "No-Result Queries", value: "3.4%", icon: AlertCircle, color: "text-red-600", bg: "bg-red-50" },
          { title: "Trending Keywords", value: "24", icon: TrendingUp, color: "text-orange-600", bg: "bg-orange-50" },
        ].map((kpi, i) => (
          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: i * 0.1 }}
            key={i} 
            className="bg-white border border-zinc-200 rounded-2xl p-5 shadow-sm flex flex-col justify-between"
          >
            <div className="flex items-center gap-3 mb-4">
              <div className={`p-2 rounded-xl ${kpi.bg}`}>
                <kpi.icon size={20} className={kpi.color} />
              </div>
              <span className="text-sm font-bold text-zinc-500">{kpi.title}</span>
            </div>
            <div className="text-3xl font-black text-zinc-950">{kpi.value}</div>
          </motion.div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        
        {/* Popular Searches */}
        <div className="lg:col-span-2 bg-white border border-zinc-200 rounded-3xl shadow-sm overflow-hidden flex flex-col">
          <div className="p-6 border-b border-zinc-100 flex items-center justify-between">
            <h3 className="font-bold text-lg text-zinc-950 flex items-center gap-2">
              <TrendingUp size={20} className="text-[#635BFF]" /> Top Performing Queries
            </h3>
            <span className="text-sm font-medium text-zinc-400">Last 30 days</span>
          </div>
          <div className="flex-1 overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="bg-zinc-50/50">
                  <th className="px-6 py-4 text-xs font-bold text-zinc-500 uppercase tracking-wider">Search Query</th>
                  <th className="px-6 py-4 text-xs font-bold text-zinc-500 uppercase tracking-wider">Volume</th>
                  <th className="px-6 py-4 text-xs font-bold text-zinc-500 uppercase tracking-wider">Trend</th>
                  <th className="px-6 py-4 text-xs font-bold text-zinc-500 uppercase tracking-wider text-right">Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-zinc-100">
                {popularSearches.map((item, i) => (
                  <tr key={i} className="hover:bg-zinc-50 transition-colors group">
                    <td className="px-6 py-4 text-sm font-bold text-zinc-900">{item.query}</td>
                    <td className="px-6 py-4 text-sm font-semibold text-zinc-600">{item.count.toLocaleString()}</td>
                    <td className="px-6 py-4 text-sm font-bold">
                      <span className={`px-2 py-1 rounded-full ${item.trend.startsWith('+') ? 'bg-emerald-50 text-emerald-600' : 'bg-red-50 text-red-600'}`}>
                        {item.trend}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-right">
                      <button className="text-[#635BFF] font-bold text-sm opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-end gap-1 w-full">
                        View Logs <ChevronRight size={16} />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* No Result Searches */}
        <div className="bg-white border border-zinc-200 rounded-3xl shadow-sm overflow-hidden flex flex-col">
          <div className="p-6 border-b border-zinc-100">
            <h3 className="font-bold text-lg text-zinc-950 flex items-center gap-2">
              <AlertCircle size={20} className="text-red-500" /> Action Required
            </h3>
            <p className="text-xs font-medium text-zinc-500 mt-1">Queries yielding zero results</p>
          </div>
          <div className="p-4 space-y-3 flex-1 overflow-y-auto">
            {noResultSearches.map((item, i) => (
              <div key={i} className="flex items-center justify-between p-3 rounded-xl border border-zinc-100 hover:border-zinc-300 transition-colors">
                <div className="flex items-center gap-3">
                  <div className="w-8 h-8 rounded-full bg-red-50 flex items-center justify-center text-red-500">
                    <Hash size={14} />
                  </div>
                  <div>
                    <div className="text-sm font-bold text-zinc-900">{item.query}</div>
                    <div className="text-xs font-semibold text-zinc-500">{item.count} searches</div>
                  </div>
                </div>
                <button className="text-xs font-bold text-[#635BFF] hover:underline">Fix</button>
              </div>
            ))}
            
            <button className="w-full py-3 mt-4 text-sm font-bold text-zinc-500 hover:text-zinc-900 bg-zinc-50 rounded-xl transition-colors">
              View All Missed Queries
            </button>
          </div>
        </div>

      </div>
    </div>
  );
}
