"use client";

import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { 
  Database, Eye, Download, Share2, Bookmark, MessageSquare, 
  ArrowUpRight, BarChart2
} from 'lucide-react';
import { 
  AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer
} from 'recharts';

import { api } from '@/lib/api';
import { useWorkspace } from '../../WorkspaceContext';

export default function DatasetAnalyticsPage() {
  const { activeWorkspace } = useWorkspace();
  const [data, setData] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    if (!activeWorkspace?.id) return;
    setIsLoading(true);
    api.analytics.getDatasets(activeWorkspace.id)
      .then(res => setData(res))
      .catch(err => console.error("Failed to load dataset metrics", err))
      .finally(() => setIsLoading(false));
  }, [activeWorkspace?.id]);

  if (isLoading) {
    return (
      <div className="flex flex-col gap-6 animate-pulse p-4">
        <div className="h-10 bg-zinc-200 rounded-xl w-64 mb-4"></div>
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
          {[...Array(6)].map((_, i) => <div key={i} className="h-28 bg-zinc-200 rounded-2xl"></div>)}
        </div>
        <div className="h-96 bg-zinc-200 rounded-3xl mt-4"></div>
      </div>
    );
  }

  const kpis = [
    { label: 'Published', value: data?.datasetsPublished?.toLocaleString(), icon: Database, color: 'text-indigo-500' },
    { label: 'Views', value: data?.totalViews?.toLocaleString(), icon: Eye, color: 'text-blue-500' },
    { label: 'Downloads', value: data?.totalDownloads?.toLocaleString(), icon: Download, color: 'text-emerald-500' },
    { label: 'Shares', value: data?.totalShares?.toLocaleString(), icon: Share2, color: 'text-amber-500' },
    { label: 'Bookmarks', value: data?.totalBookmarks?.toLocaleString(), icon: Bookmark, color: 'text-pink-500' },
    { label: 'Comments', value: data?.totalComments?.toLocaleString(), icon: MessageSquare, color: 'text-purple-500' },
  ];

  return (
    <div className="space-y-6 pb-20">
      
      <div className="mb-8">
        <h1 className="text-3xl font-extrabold text-zinc-900 tracking-tight">Dataset Analytics</h1>
        <p className="text-zinc-500 font-medium mt-1">Monitor the performance and engagement of your published datasets.</p>
      </div>

      {/* KPI GRID */}
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
        {kpis.map((kpi, i) => (
          <motion.div 
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: i * 0.05 }}
            key={i} 
            className="bg-white border border-zinc-200 p-5 rounded-2xl shadow-sm hover:shadow-md transition-shadow"
          >
            <div className={`p-2.5 rounded-lg bg-zinc-50 border border-zinc-100 w-fit mb-3 ${kpi.color}`}>
              <kpi.icon className="w-5 h-5" />
            </div>
            <div className="text-2xl font-black text-zinc-900">{kpi.value || '0'}</div>
            <div className="text-xs font-bold text-zinc-500 uppercase tracking-wider mt-1">{kpi.label}</div>
          </motion.div>
        ))}
      </div>

      <div className="grid grid-cols-1 gap-6 mt-6">
        
        {/* Top Datasets Table */}
        <motion.div 
          initial={{ opacity: 0, scale: 0.98 }}
          animate={{ opacity: 1, scale: 1 }}
          className="bg-white border border-zinc-200 rounded-3xl p-6 shadow-sm flex flex-col"
        >
          <div className="flex justify-between items-center mb-6">
            <h3 className="text-lg font-bold text-zinc-900 flex items-center gap-2"><BarChart2 className="w-5 h-5 text-indigo-500"/> Global Dataset Performance</h3>
            <button className="text-sm font-semibold text-zinc-500 hover:text-zinc-900 transition-colors">Export Table</button>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="border-b border-zinc-200 text-xs font-bold text-zinc-500 uppercase tracking-wider">
                  <th className="pb-3 px-4">Dataset</th>
                  <th className="pb-3 px-4 text-right">Views</th>
                  <th className="pb-3 px-4 text-right">Followers</th>
                  <th className="pb-3 px-4 text-right">Avg View Time</th>
                  <th className="pb-3 px-4 text-right">Search Rank</th>
                  <th className="pb-3 px-4 text-right">CTR</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-zinc-100">
                {data?.topDatasets?.map((ds: any, i: number) => (
                  <tr key={i} className="hover:bg-zinc-50 transition-colors group">
                    <td className="py-4 px-4">
                      <div className="text-sm font-bold text-zinc-900 group-hover:text-indigo-600 transition-colors flex items-center gap-2">
                        {ds.name}
                        <ArrowUpRight className="w-3 h-3 opacity-0 group-hover:opacity-100" />
                      </div>
                    </td>
                    <td className="py-4 px-4 text-right text-sm font-medium text-zinc-600">{ds.views?.toLocaleString()}</td>
                    <td className="py-4 px-4 text-right text-sm font-medium text-zinc-600">{ds.followers?.toLocaleString()}</td>
                    <td className="py-4 px-4 text-right text-sm font-medium text-zinc-600">{ds.avgTime}</td>
                    <td className="py-4 px-4 text-right text-sm font-medium text-zinc-600">#{ds.rank}</td>
                    <td className="py-4 px-4 text-right">
                      <span className="px-2 py-1 bg-emerald-50 text-emerald-600 rounded text-xs font-bold border border-emerald-100">
                        {(ds.ctr * 100).toFixed(1)}%
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </motion.div>
      </div>
    </div>
  );
}
