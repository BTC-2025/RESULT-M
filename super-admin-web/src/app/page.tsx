"use client";

import React, { useState, useEffect } from 'react';
import { useAuth } from '@/context/AuthContext';
import Header from '@/components/Header';
import { 
  FolderLock, 
  FileSpreadsheet, 
  Database, 
  Eye, 
  Search, 
  ArrowUpRight, 
  Sparkles, 
  AlertTriangle 
} from 'lucide-react';
import { 
  AreaChart, 
  Area, 
  XAxis, 
  YAxis, 
  Tooltip, 
  ResponsiveContainer,
  CartesianGrid
} from 'recharts';

interface GlobalAnalytics {
  totalWorkspaces: number;
  totalDatasets: number;
  totalRecords: number;
  totalViews: number;
  totalSearches: number;
  totalUploads: number;
  dailyViews: Array<{ date: string; value: number }>;
}

export default function DashboardPage() {
  const { apiFetch } = useAuth();
  const [data, setData] = useState<GlobalAnalytics | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchGlobalAnalytics = async () => {
      try {
        const res = await apiFetch('/api/v1/analytics/global');
        if (!res.ok) {
          throw new Error("Unable to fetch global platform statistics.");
        }
        const analytics = await res.json();
        setData({
          totalWorkspaces: analytics.totalWorkspaces || 0,
          totalDatasets: analytics.totalDatasets || 0,
          totalRecords: analytics.totalRecords || 0,
          totalViews: analytics.totalViews || 0,
          totalSearches: analytics.totalSearches || 0,
          totalUploads: analytics.totalUploads || 0,
          dailyViews: analytics.dailyViews?.map((dp: any) => ({
            date: dp.label,
            views: dp.value
          })) || []
        });
      } catch (err: any) {
        setError(err.message || "An unexpected error occurred while loading dashboard metrics.");
      } finally {
        setLoading(false);
      }
    };

    fetchGlobalAnalytics();
  }, []);

  if (loading) {
    return (
      <div className="flex flex-col min-h-screen">
        <Header title="Overview Dashboard" />
        <div className="flex-1 flex items-center justify-center p-8">
          <div className="w-12 h-12 border-4 border-accentPurple border-t-transparent rounded-full animate-spin"></div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex flex-col min-h-screen">
        <Header title="Overview Dashboard" />
        <div className="flex-1 p-8">
          <div className="glass-panel border border-accentRose/20 p-8 rounded-3xl flex flex-col items-center justify-center max-w-xl mx-auto mt-20 text-center">
            <AlertTriangle className="w-16 h-16 text-accentRose mb-4 animate-bounce" />
            <h3 className="text-xl font-extrabold text-white mb-2">Metrics Load Error</h3>
            <p className="text-textSecondary text-sm mb-6">{error}</p>
            <button 
              onClick={() => window.location.reload()}
              className="bg-accentPurple px-6 py-2.5 rounded-xl text-white font-bold text-xs uppercase tracking-wider hover:opacity-90 transition-all shadow-glow"
            >
              Retry Connection
            </button>
          </div>
        </div>
      </div>
    );
  }

  const statCards = [
    { name: 'Total Workspaces', value: data?.totalWorkspaces, icon: FolderLock, color: 'from-accentIndigo to-accentPurple' },
    { name: 'Total Datasets', value: data?.totalDatasets, icon: FileSpreadsheet, color: 'from-accentPurple to-accentRose' },
    { name: 'Total Records', value: data?.totalRecords, icon: Database, color: 'from-accentRose to-yellow' },
    { name: 'Platform Views', value: data?.totalViews, icon: Eye, color: 'from-accentIndigo to-green' },
  ];

  return (
    <div className="flex flex-col min-h-screen">
      <Header title="Overview Dashboard" />
      
      <main className="flex-1 p-8 space-y-8 mt-20 ml-64">
        {/* Welcome Banner */}
        <div className="glass-panel p-6 rounded-3xl flex items-center justify-between overflow-hidden relative border border-white/5">
          <div className="absolute top-0 right-0 w-[300px] h-[300px] bg-accentPurple/10 rounded-full blur-[80px] pointer-events-none"></div>
          <div className="flex items-center gap-4">
            <div className="bg-accentPurple/10 p-3 rounded-2xl border border-accentPurple/30 text-accentPurple">
              <Sparkles className="w-6 h-6" />
            </div>
            <div>
              <h3 className="text-lg font-bold text-white">ResultHub Control Center</h3>
              <p className="text-xs text-textSecondary mt-0.5 font-medium">Global platform usage, analytics aggregates, system statistics monitoring.</p>
            </div>
          </div>
          <div className="flex items-center gap-1.5 text-xs text-accentPurple font-bold bg-accentPurple/15 px-4 py-2 rounded-xl border border-accentPurple/25">
            Realtime Analytics Active <ArrowUpRight className="w-4 h-4" />
          </div>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {statCards.map((card, i) => {
            const Icon = card.icon;
            return (
              <div key={i} className="glass-panel glass-panel-hover p-6 rounded-3xl flex items-center justify-between">
                <div className="space-y-2">
                  <span className="text-xs font-bold text-textSecondary uppercase tracking-wider block">{card.name}</span>
                  <span className="text-3xl font-extrabold text-white block">
                    {card.value !== undefined ? card.value.toLocaleString() : '0'}
                  </span>
                </div>
                <div className={`bg-gradient-to-tr ${card.color} p-4 rounded-2xl text-white shadow-glow`}>
                  <Icon className="w-6 h-6" />
                </div>
              </div>
            );
          })}
        </div>

        {/* Main Analytics Graph */}
        <div className="grid grid-cols-1 gap-6">
          <div className="glass-panel p-6 rounded-3xl flex flex-col space-y-6">
            <div>
              <h3 className="text-base font-extrabold text-white">Daily Traffic Overview</h3>
              <p className="text-xs text-textSecondary mt-0.5">Aggregate request views registered by visitors globally over the last 30 days.</p>
            </div>

            <div className="h-[350px] w-full">
              {data && data.dailyViews.length > 0 ? (
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={data.dailyViews} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                    <defs>
                      <linearGradient id="viewsGlow" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#8B5CF6" stopOpacity={0.4}/>
                        <stop offset="95%" stopColor="#8B5CF6" stopOpacity={0.0}/>
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" stroke="rgba(31, 41, 55, 0.4)" vertical={false} />
                    <XAxis 
                      dataKey="date" 
                      stroke="#9CA3AF" 
                      fontSize={11} 
                      tickLine={false} 
                      axisLine={false}
                      dy={10}
                    />
                    <YAxis 
                      stroke="#9CA3AF" 
                      fontSize={11} 
                      tickLine={false} 
                      axisLine={false} 
                      dx={-5}
                    />
                    <Tooltip 
                      contentStyle={{ 
                        background: 'rgba(17, 24, 39, 0.95)', 
                        borderColor: 'rgba(139, 92, 246, 0.4)', 
                        borderRadius: '16px',
                        boxShadow: '0 10px 30px rgba(0, 0, 0, 0.5)',
                        color: '#F3F4F6'
                      }} 
                    />
                    <Area 
                      type="monotone" 
                      dataKey="views" 
                      stroke="#8B5CF6" 
                      strokeWidth={3} 
                      fillOpacity={1} 
                      fill="url(#viewsGlow)" 
                    />
                  </AreaChart>
                </ResponsiveContainer>
              ) : (
                <div className="h-full flex flex-col items-center justify-center text-textSecondary gap-2">
                  <Database className="w-12 h-12 opacity-35" />
                  <p className="text-sm font-semibold">No analytics data recorded for the selected timeline.</p>
                </div>
              )}
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
