"use client";

import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { 
  AlertCircle, CheckCircle2, Clock, XCircle, Timer, TrendingUp
} from 'lucide-react';
import { 
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer
} from 'recharts';

import { api } from '@/lib/api';
import { useWorkspace } from '../../WorkspaceContext';

export default function ComplaintAnalyticsPage() {
  const { activeWorkspace } = useWorkspace();
  const [data, setData] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    if (!activeWorkspace?.id) return;
    setIsLoading(true);
    api.analytics.getComplaints(activeWorkspace.id)
      .then(res => setData(res))
      .catch(err => console.error("Failed to load complaint metrics", err))
      .finally(() => setIsLoading(false));
  }, [activeWorkspace?.id]);

  if (isLoading) {
    return (
      <div className="flex flex-col gap-6 animate-pulse p-4">
        <div className="h-10 bg-zinc-200 rounded-xl w-64 mb-4"></div>
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4">
          {[...Array(5)].map((_, i) => <div key={i} className="h-28 bg-zinc-200 rounded-2xl"></div>)}
        </div>
        <div className="grid grid-cols-1 gap-6 mt-4">
          <div className="h-80 bg-zinc-200 rounded-3xl"></div>
        </div>
      </div>
    );
  }

  const kpis = [
    { label: 'Total Complaints', value: data?.totalComplaints?.toLocaleString(), icon: AlertCircle, color: 'text-indigo-500' },
    { label: 'Resolved', value: data?.resolved?.toLocaleString(), icon: CheckCircle2, color: 'text-emerald-500' },
    { label: 'Pending', value: data?.pending?.toLocaleString(), icon: Clock, color: 'text-amber-500' },
    { label: 'Rejected', value: data?.rejected?.toLocaleString(), icon: XCircle, color: 'text-red-500' },
    { label: 'Avg Resolution Time', value: data?.avgResolutionTime, icon: Timer, color: 'text-purple-500' },
  ];

  return (
    <div className="space-y-6 pb-20">
      
      <div className="mb-8">
        <h1 className="text-3xl font-extrabold text-zinc-900 tracking-tight">Complaint Analytics</h1>
        <p className="text-zinc-500 font-medium mt-1">Civic analytics, resolution trends, and response metrics.</p>
      </div>

      {/* KPI GRID */}
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4">
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
        
        {/* Resolution Trend */}
        <motion.div 
          initial={{ opacity: 0, scale: 0.98 }}
          animate={{ opacity: 1, scale: 1 }}
          className="bg-white border border-zinc-200 rounded-3xl p-6 shadow-sm flex flex-col"
        >
          <div className="flex justify-between items-center mb-6">
            <h3 className="text-lg font-bold text-zinc-900 flex items-center gap-2"><TrendingUp className="w-5 h-5 text-emerald-500"/> Resolution Trend</h3>
          </div>
          <div className="flex-1 min-h-[350px]">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={data?.resolutionTrend || []} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#E4E4E7" />
                <XAxis dataKey="label" axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#71717A', fontWeight: 600 }} dy={10} />
                <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#71717A', fontWeight: 600 }} />
                <Tooltip 
                  cursor={{fill: '#F4F4F5'}}
                  contentStyle={{ borderRadius: '12px', border: '1px solid #E4E4E7' }}
                />
                <Bar dataKey="value" fill="#10B981" radius={[4, 4, 0, 0]} barSize={40} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </motion.div>
      </div>
    </div>
  );
}
