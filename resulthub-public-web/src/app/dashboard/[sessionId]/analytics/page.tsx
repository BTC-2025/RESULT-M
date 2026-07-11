"use client";

import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { 
  Eye, Users, Search, Database, FileText, CheckCircle2, 
  AlertCircle, Heart, Bookmark, MessageSquare, Share2, 
  Clock, TrendingUp, TrendingDown, ArrowUpRight, Activity
} from 'lucide-react';
import { 
  AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer 
} from 'recharts';

import { api } from '@/lib/api';
import { useWorkspace } from '../WorkspaceContext';

export default function AnalyticsDashboardPage() {
  const { activeWorkspace } = useWorkspace();
  const [data, setData] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    if (!activeWorkspace?.id) return;
    setIsLoading(true);
    api.analytics.getDashboard(activeWorkspace.id)
      .then(res => setData(res))
      .catch(err => console.error("Failed to load dashboard metrics", err))
      .finally(() => setIsLoading(false));
  }, [activeWorkspace?.id]);

  if (isLoading) {
    return (
      <div className="flex flex-col gap-6 animate-pulse p-4">
        <div className="h-10 bg-zinc-200 rounded-xl w-64 mb-4"></div>
        <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-5 gap-4">
          {[...Array(10)].map((_, i) => <div key={i} className="h-28 bg-zinc-200 rounded-2xl"></div>)}
        </div>
        <div className="h-96 bg-zinc-200 rounded-3xl mt-4"></div>
      </div>
    );
  }

  const kpis = [
    { label: 'Total Views', value: data?.totalViews?.toLocaleString(), icon: Eye, color: 'text-blue-500' },
    { label: 'Unique Visitors', value: data?.uniqueVisitors?.toLocaleString(), icon: Users, color: 'text-emerald-500' },
    { label: 'Searches', value: data?.searches?.toLocaleString(), icon: Search, color: 'text-purple-500' },
    { label: 'Dataset Views', value: data?.datasetViews?.toLocaleString(), icon: Database, color: 'text-blue-500' },
    { label: 'Published Datasets', value: data?.publishedDatasets?.toLocaleString(), icon: FileText, color: 'text-emerald-500' },
    { label: 'Poll Votes', value: data?.pollVotes?.toLocaleString(), icon: CheckCircle2, color: 'text-amber-500' },
    { label: 'Complaints', value: data?.complaintsSubmitted?.toLocaleString(), icon: AlertCircle, color: 'text-red-500', isDown: true },
    { label: 'Followers', value: data?.followers?.toLocaleString() || '0', icon: Heart, color: 'text-pink-500' },
    { label: 'Bookmarks', value: data?.bookmarks?.toLocaleString(), icon: Bookmark, color: 'text-indigo-500' },
    { label: 'Comments', value: data?.comments?.toLocaleString(), icon: MessageSquare, color: 'text-sky-500' },
    { label: 'Shares', value: data?.shares?.toLocaleString(), icon: Share2, color: 'text-orange-500' },
    { label: 'Engagement Rate', value: `${(data?.engagementRate || 0) * 100}%`, icon: Activity, color: 'text-emerald-500' },
    { label: 'Avg Session', value: data?.avgSession, icon: Clock, color: 'text-purple-500' },
    { label: 'Bounce Rate', value: `${((data?.bounceRate || 0) * 100).toFixed(1)}%`, icon: TrendingDown, color: 'text-emerald-500', isDown: true },
  ];

  return (
    <div className="space-y-6 pb-20">
      
      <div className="mb-8">
        <h1 className="text-3xl font-extrabold text-zinc-900 tracking-tight">Organization Overview</h1>
        <p className="text-zinc-500 font-medium mt-1">High-level intelligence on your workspace performance.</p>
      </div>

      {/* KPI GRID */}
      <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-7 gap-4">
        {kpis.map((kpi, i) => (
          <motion.div 
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: i * 0.05 }}
            key={i} 
            className="bg-white border border-zinc-200 p-4 rounded-2xl shadow-sm hover:shadow-md hover:border-zinc-300 transition-all group"
          >
            <div className="flex justify-between items-start mb-3">
              <div className={`p-2 rounded-lg bg-zinc-50 border border-zinc-100 ${kpi.color}`}>
                <kpi.icon className="w-4 h-4" />
              </div>
              <div className={`flex items-center gap-1 text-[10px] font-bold px-1.5 py-0.5 rounded ${
                kpi.isDown ? 'text-red-500 bg-red-50' : 'text-emerald-600 bg-emerald-50'
              }`}>
                {kpi.isDown ? <TrendingDown className="w-3 h-3" /> : <TrendingUp className="w-3 h-3" />}
              </div>
            </div>
            <div>
              <div className="text-xl font-black text-zinc-900">{kpi.value || '0'}</div>
              <div className="text-[11px] font-bold text-zinc-500 uppercase tracking-wider mt-0.5">{kpi.label}</div>
            </div>
          </motion.div>
        ))}
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-3 gap-6 mt-6">
        
        {/* Main Traffic Graph */}
        <motion.div 
          initial={{ opacity: 0, scale: 0.98 }}
          animate={{ opacity: 1, scale: 1 }}
          className="xl:col-span-2 bg-white border border-zinc-200 rounded-3xl p-6 shadow-sm flex flex-col"
        >
          <div className="flex justify-between items-center mb-6">
            <h3 className="text-lg font-bold text-zinc-900">Overall Traffic</h3>
            <div className="flex gap-4 text-xs font-bold">
              <div className="flex items-center gap-2"><span className="w-3 h-3 rounded-full bg-blue-500"></span> Views</div>
            </div>
          </div>
          <div className="flex-1 min-h-[300px]">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={data?.trafficGraph || []} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                <defs>
                  <linearGradient id="colorViews" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#3B82F6" stopOpacity={0.3}/>
                    <stop offset="95%" stopColor="#3B82F6" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#E4E4E7" />
                <XAxis dataKey="label" axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#71717A', fontWeight: 600 }} dy={10} />
                <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#71717A', fontWeight: 600 }} tickFormatter={(val) => `${val/1000}k`} />
                <Tooltip 
                  contentStyle={{ borderRadius: '12px', border: '1px solid #E4E4E7', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }}
                  labelStyle={{ fontWeight: 'bold', color: '#18181B', marginBottom: '4px' }}
                />
                <Area type="monotone" dataKey="value" stroke="#3B82F6" strokeWidth={3} fillOpacity={1} fill="url(#colorViews)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </motion.div>

        {/* Realtime Activity Feed */}
        <motion.div 
          initial={{ opacity: 0, scale: 0.98 }}
          animate={{ opacity: 1, scale: 1 }}
          className="bg-white border border-zinc-200 rounded-3xl p-6 shadow-sm flex flex-col"
        >
          <div className="flex justify-between items-center mb-6">
            <h3 className="text-lg font-bold text-zinc-900 flex items-center gap-2">
              <span className="w-2 h-2 rounded-full bg-red-500 animate-pulse"></span>
              Realtime Activity
            </h3>
          </div>
          <div className="space-y-4 overflow-y-auto flex-1 pr-2 custom-scrollbar">
            {data?.realtimeActivity?.map((activity: any, i: number) => (
              <div key={i} className="flex gap-4 items-start group">
                <div className="mt-1">
                  {activity.type === 'SEARCH' ? <Search className="w-4 h-4 text-purple-500" /> : 
                   activity.type === 'VIEW' ? <Eye className="w-4 h-4 text-blue-500" /> : 
                   <Activity className="w-4 h-4 text-zinc-400" />}
                </div>
                <div className="flex-1 border-b border-zinc-100 pb-4 group-last:border-0">
                  <p className="text-sm font-semibold text-zinc-900">{activity.action}</p>
                  <p className="text-xs font-medium text-zinc-500 mt-0.5">{activity.details}</p>
                  <span className="text-[10px] font-bold text-zinc-400 mt-1 block">{activity.time}</span>
                </div>
              </div>
            ))}
          </div>
        </motion.div>
      </div>

      {/* Top Performing Content */}
      <motion.div 
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="bg-white border border-zinc-200 rounded-3xl p-6 shadow-sm"
      >
        <h3 className="text-lg font-bold text-zinc-900 mb-6">Top Performing Content</h3>
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="border-b border-zinc-200 text-xs font-bold text-zinc-500 uppercase tracking-wider">
                <th className="pb-3 px-4">Dataset Name</th>
                <th className="pb-3 px-4 text-right">Views</th>
                <th className="pb-3 px-4 text-right">Searches</th>
                <th className="pb-3 px-4 text-right">Bookmarks</th>
                <th className="pb-3 px-4 text-right">Comments</th>
                <th className="pb-3 px-4 text-right">CTR</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-zinc-100">
              {data?.topPerformingContent?.map((content: any, i: number) => (
                <tr key={i} className="hover:bg-zinc-50 transition-colors group">
                  <td className="py-4 px-4">
                    <div className="text-sm font-bold text-zinc-900 group-hover:text-purple-600 transition-colors flex items-center gap-2">
                      {content.name}
                      <ArrowUpRight className="w-3 h-3 opacity-0 group-hover:opacity-100" />
                    </div>
                  </td>
                  <td className="py-4 px-4 text-right text-sm font-medium text-zinc-600">{content.views?.toLocaleString()}</td>
                  <td className="py-4 px-4 text-right text-sm font-medium text-zinc-600">{content.searches?.toLocaleString()}</td>
                  <td className="py-4 px-4 text-right text-sm font-medium text-zinc-600">{content.bookmarks?.toLocaleString()}</td>
                  <td className="py-4 px-4 text-right text-sm font-medium text-zinc-600">{content.comments?.toLocaleString()}</td>
                  <td className="py-4 px-4 text-right">
                    <span className="px-2 py-1 bg-emerald-50 text-emerald-600 rounded text-xs font-bold border border-emerald-100">
                      {(content.ctr * 100).toFixed(1)}%
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </motion.div>

    </div>
  );
}
