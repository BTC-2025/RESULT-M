"use client";

import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { 
  BarChart3, CheckSquare, Users, Percent, Target, Activity 
} from 'lucide-react';
import { 
  PieChart, Pie, Cell, Tooltip, ResponsiveContainer 
} from 'recharts';

import { api } from '@/lib/api';
import { useWorkspace } from '../../WorkspaceContext';

const COLORS = ['#8B5CF6', '#3B82F6', '#10B981', '#F59E0B', '#EF4444'];

export default function PollAnalyticsPage() {
  const { activeWorkspace } = useWorkspace();
  const [data, setData] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    if (!activeWorkspace?.id) return;
    setIsLoading(true);
    api.analytics.getPolls(activeWorkspace.id)
      .then(res => setData(res))
      .catch(err => console.error("Failed to load poll metrics", err))
      .finally(() => setIsLoading(false));
  }, [activeWorkspace?.id]);

  if (isLoading) {
    return (
      <div className="flex flex-col gap-6 animate-pulse p-4">
        <div className="h-10 bg-zinc-200 rounded-xl w-64 mb-4"></div>
        <div className="grid grid-cols-2 md:grid-cols-2 lg:grid-cols-4 gap-4">
          {[...Array(4)].map((_, i) => <div key={i} className="h-28 bg-zinc-200 rounded-2xl"></div>)}
        </div>
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mt-4">
          <div className="h-80 bg-zinc-200 rounded-3xl"></div>
        </div>
      </div>
    );
  }

  const kpis = [
    { label: 'Polls Created', value: data?.pollsCreated?.toLocaleString(), icon: BarChart3, color: 'text-indigo-500' },
    { label: 'Total Votes', value: data?.totalVotes?.toLocaleString(), icon: CheckSquare, color: 'text-emerald-500' },
    { label: 'Participation', value: `${((data?.participationRate || 0) * 100).toFixed(1)}%`, icon: Users, color: 'text-blue-500' },
    { label: 'Completion', value: `${((data?.completionRate || 0) * 100).toFixed(1)}%`, icon: Target, color: 'text-purple-500' },
  ];

  return (
    <div className="space-y-6 pb-20">
      
      <div className="mb-8">
        <h1 className="text-3xl font-extrabold text-zinc-900 tracking-tight">Poll Analytics</h1>
        <p className="text-zinc-500 font-medium mt-1">Deep dive into voting patterns and demographic participation.</p>
      </div>

      {/* KPI GRID */}
      <div className="grid grid-cols-2 md:grid-cols-2 lg:grid-cols-4 gap-4">
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

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mt-6">
        
        {/* Demographics Distribution */}
        <motion.div 
          initial={{ opacity: 0, scale: 0.98 }}
          animate={{ opacity: 1, scale: 1 }}
          className="bg-white border border-zinc-200 rounded-3xl p-6 shadow-sm"
        >
          <div className="flex justify-between items-center mb-6">
            <h3 className="text-lg font-bold text-zinc-900">Voting Demographics (Gender)</h3>
          </div>
          <div className="h-64 relative flex items-center justify-center">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={data?.demographics || []}
                  innerRadius={60}
                  outerRadius={80}
                  paddingAngle={5}
                  dataKey="value"
                  nameKey="label"
                >
                  {(data?.demographics || []).map((entry: any, index: number) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip 
                  contentStyle={{ borderRadius: '12px', border: '1px solid #E4E4E7' }}
                  itemStyle={{ fontWeight: 'bold' }}
                />
              </PieChart>
            </ResponsiveContainer>
            <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
              <span className="text-2xl font-black text-zinc-900">
                {data?.demographics?.[0]?.value || 0}%
              </span>
              <span className="text-xs font-bold text-zinc-500 uppercase">Male</span>
            </div>
          </div>
        </motion.div>
      </div>
    </div>
  );
}
