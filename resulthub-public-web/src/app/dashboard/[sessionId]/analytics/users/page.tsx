"use client";

import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { 
  Users, UserPlus, ShieldAlert, ShieldCheck, Heart, 
  MapPin, Clock, Fingerprint, Activity, Globe2
} from 'lucide-react';
import { 
  AreaChart, Area, BarChart, Bar, XAxis, YAxis, CartesianGrid, 
  Tooltip, ResponsiveContainer, RadarChart, PolarGrid, PolarAngleAxis, 
  PolarRadiusAxis, Radar
} from 'recharts';

import { api } from '@/lib/api';
import { useWorkspace } from '../../WorkspaceContext';

export default function UserAnalyticsPage() {
  const { activeWorkspace } = useWorkspace();
  const [data, setData] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    if (!activeWorkspace?.id) return;
    setIsLoading(true);
    api.analytics.getUsers(activeWorkspace.id)
      .then(res => setData(res))
      .catch(err => console.error("Failed to load user metrics", err))
      .finally(() => setIsLoading(false));
  }, [activeWorkspace?.id]);

  if (isLoading) {
    return (
      <div className="flex flex-col gap-6 animate-pulse p-4">
        <div className="h-10 bg-zinc-200 rounded-xl w-64 mb-4"></div>
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
          {[...Array(6)].map((_, i) => <div key={i} className="h-28 bg-zinc-200 rounded-2xl"></div>)}
        </div>
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mt-4">
          <div className="h-80 bg-zinc-200 rounded-3xl"></div>
          <div className="h-80 bg-zinc-200 rounded-3xl"></div>
        </div>
      </div>
    );
  }

  const kpis = [
    { label: 'Total Visitors', value: data?.totalVisitors?.toLocaleString(), icon: Users, color: 'text-blue-500' },
    { label: 'Returning', value: data?.returningVisitors?.toLocaleString(), icon: Activity, color: 'text-emerald-500' },
    { label: 'New Users', value: data?.newUsers?.toLocaleString(), icon: UserPlus, color: 'text-amber-500' },
    { label: 'Followers', value: data?.followers?.toLocaleString() || '0', icon: Heart, color: 'text-pink-500' },
    { label: 'Anonymous', value: data?.anonymousUsers?.toLocaleString(), icon: ShieldAlert, color: 'text-zinc-500' },
    { label: 'Authenticated', value: data?.loggedUsers?.toLocaleString(), icon: ShieldCheck, color: 'text-purple-500' },
  ];

  return (
    <div className="space-y-6 pb-20">
      
      <div className="mb-8">
        <h1 className="text-3xl font-extrabold text-zinc-900 tracking-tight">User Analytics</h1>
        <p className="text-zinc-500 font-medium mt-1">Understand your audience demographics, retention, and cohorts.</p>
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

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mt-6">
        
        {/* Retention Curve */}
        <motion.div 
          initial={{ opacity: 0, scale: 0.98 }}
          animate={{ opacity: 1, scale: 1 }}
          className="bg-white border border-zinc-200 rounded-3xl p-6 shadow-sm flex flex-col"
        >
          <div className="flex justify-between items-center mb-6">
            <h3 className="text-lg font-bold text-zinc-900 flex items-center gap-2"><Fingerprint className="w-5 h-5 text-indigo-500"/> User Retention</h3>
          </div>
          <div className="flex-1 min-h-[300px]">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={data?.retention || []} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                <defs>
                  <linearGradient id="colorRetention" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#6366F1" stopOpacity={0.3}/>
                    <stop offset="95%" stopColor="#6366F1" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#E4E4E7" />
                <XAxis dataKey="label" axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#71717A', fontWeight: 600 }} dy={10} />
                <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#71717A', fontWeight: 600 }} tickFormatter={(val) => `${val}%`} />
                <Tooltip 
                  contentStyle={{ borderRadius: '12px', border: '1px solid #E4E4E7' }}
                />
                <Area type="monotone" dataKey="value" stroke="#6366F1" strokeWidth={3} fill="url(#colorRetention)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </motion.div>

        {/* Age Distribution */}
        <motion.div 
          initial={{ opacity: 0, scale: 0.98 }}
          animate={{ opacity: 1, scale: 1 }}
          className="bg-white border border-zinc-200 rounded-3xl p-6 shadow-sm flex flex-col"
        >
          <div className="flex justify-between items-center mb-6">
            <h3 className="text-lg font-bold text-zinc-900 flex items-center gap-2"><Users className="w-5 h-5 text-amber-500"/> Age Demographics</h3>
          </div>
          <div className="flex-1 min-h-[300px]">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={data?.ageDistribution || []} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#E4E4E7" />
                <XAxis dataKey="label" axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#71717A', fontWeight: 600 }} dy={10} />
                <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#71717A', fontWeight: 600 }} tickFormatter={(val) => `${val/1000}k`} />
                <Tooltip 
                  cursor={{fill: '#F4F4F5'}}
                  contentStyle={{ borderRadius: '12px', border: '1px solid #E4E4E7' }}
                />
                <Bar dataKey="value" fill="#F59E0B" radius={[4, 4, 0, 0]} barSize={40} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </motion.div>

        {/* Geographic Distribution (Map abstraction via Horizontal Bars) */}
        <motion.div 
          initial={{ opacity: 0, scale: 0.98 }}
          animate={{ opacity: 1, scale: 1 }}
          className="bg-white border border-zinc-200 rounded-3xl p-6 shadow-sm flex flex-col"
        >
          <div className="flex justify-between items-center mb-6">
            <h3 className="text-lg font-bold text-zinc-900 flex items-center gap-2"><Globe2 className="w-5 h-5 text-emerald-500"/> Geographic Distribution</h3>
          </div>
          <div className="flex-1 min-h-[300px]">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={data?.countries || []} layout="vertical" margin={{ top: 0, right: 30, left: 20, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" horizontal={true} vertical={false} stroke="#E4E4E7" />
                <XAxis type="number" axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#71717A', fontWeight: 600 }} />
                <YAxis dataKey="label" type="category" axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#18181B', fontWeight: 600 }} />
                <Tooltip 
                  cursor={{fill: '#F4F4F5'}}
                  contentStyle={{ borderRadius: '12px', border: '1px solid #E4E4E7' }}
                />
                <Bar dataKey="value" fill="#10B981" radius={[0, 4, 4, 0]} barSize={24} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </motion.div>

        {/* User Engagement Radar */}
        <motion.div 
          initial={{ opacity: 0, scale: 0.98 }}
          animate={{ opacity: 1, scale: 1 }}
          className="bg-white border border-zinc-200 rounded-3xl p-6 shadow-sm flex flex-col items-center justify-center"
        >
          <div className="flex justify-between items-center mb-2 w-full">
            <h3 className="text-lg font-bold text-zinc-900 flex items-center gap-2"><Activity className="w-5 h-5 text-rose-500"/> Behavioral Radar</h3>
          </div>
          <div className="w-full h-72">
            <ResponsiveContainer width="100%" height="100%">
              <RadarChart cx="50%" cy="50%" outerRadius="80%" data={[
                { subject: 'Browsing', A: data?.behaviorRadar?.browsing || 0, fullMark: 150 },
                { subject: 'Searching', A: data?.behaviorRadar?.searching || 0, fullMark: 150 },
                { subject: 'Downloading', A: data?.behaviorRadar?.downloading || 0, fullMark: 150 },
                { subject: 'Commenting', A: data?.behaviorRadar?.commenting || 0, fullMark: 150 },
                { subject: 'Voting', A: data?.behaviorRadar?.voting || 0, fullMark: 150 },
                { subject: 'Sharing', A: data?.behaviorRadar?.sharing || 0, fullMark: 150 },
              ]}>
                <PolarGrid stroke="#E4E4E7" />
                <PolarAngleAxis dataKey="subject" tick={{ fill: '#71717A', fontSize: 11, fontWeight: 600 }} />
                <Radar name="Activity" dataKey="A" stroke="#F43F5E" fill="#F43F5E" fillOpacity={0.3} />
                <Tooltip />
              </RadarChart>
            </ResponsiveContainer>
          </div>
        </motion.div>

      </div>
    </div>
  );
}
