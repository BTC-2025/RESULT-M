"use client";

import React, { useState, useEffect } from 'react';
import { useAuth } from '@/context/AuthContext';
import Header from '@/components/Header';
import { 
  Activity, 
  Database, 
  Cpu, 
  Timer, 
  Layers, 
  Server,
  AlertTriangle,
  RefreshCw 
} from 'lucide-react';

interface HealthData {
  jvmFreeMemoryBytes: number;
  jvmTotalMemoryBytes: number;
  jvmMaxMemoryBytes: number;
  databaseConnected: boolean;
  activeThreads: number;
  uptimeMs: number;
  totalWorkspaces: number;
  totalDatasets: number;
  totalUsers: number;
  totalOrganizations: number;
}

export default function SystemHealthPage() {
  const { apiFetch } = useAuth();
  const [data, setData] = useState<HealthData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [refreshing, setRefreshing] = useState(false);

  const fetchHealth = async () => {
    setRefreshing(true);
    try {
      const res = await apiFetch('/api/v1/admin/system/health');
      if (!res.ok) {
        throw new Error("Unable to read system health diagnostics.");
      }
      const health = await res.json();
      setData(health);
      setError(null);
    } catch (err: any) {
      setError(err.message || "An unexpected error occurred while contacting diagnostics service.");
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    fetchHealth();
    // Poll every 10 seconds
    const interval = setInterval(fetchHealth, 10000);
    return () => clearInterval(interval);
  }, []);

  const formatUptime = (ms: number) => {
    let seconds = Math.floor(ms / 1000);
    let minutes = Math.floor(seconds / 60);
    seconds = seconds % 60;
    let hours = Math.floor(minutes / 60);
    minutes = minutes % 60;
    const days = Math.floor(hours / 24);
    hours = hours % 24;

    const parts = [];
    if (days > 0) parts.push(`${days}d`);
    if (hours > 0) parts.push(`${hours}h`);
    if (minutes > 0) parts.push(`${minutes}m`);
    parts.push(`${seconds}s`);

    return parts.join(' ');
  };

  const formatBytes = (bytes: number) => {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  };

  if (loading) {
    return (
      <div className="flex flex-col min-h-screen">
        <Header title="System Health Monitoring" />
        <div className="flex-1 flex items-center justify-center p-8">
          <div className="w-12 h-12 border-4 border-accentPurple border-t-transparent rounded-full animate-spin"></div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex flex-col min-h-screen">
        <Header title="System Health Monitoring" />
        <div className="flex-1 p-8">
          <div className="glass-panel border border-accentRose/20 p-8 rounded-3xl flex flex-col items-center justify-center max-w-xl mx-auto mt-20 text-center">
            <AlertTriangle className="w-16 h-16 text-accentRose mb-4 animate-bounce" />
            <h3 className="text-xl font-extrabold text-white mb-2">Diagnostics Unreachable</h3>
            <p className="text-textSecondary text-sm mb-6">{error}</p>
            <button 
              onClick={fetchHealth}
              className="bg-accentPurple px-6 py-2.5 rounded-xl text-white font-bold text-xs uppercase tracking-wider hover:opacity-90 transition-all shadow-glow flex items-center gap-2"
            >
              <RefreshCw className="w-4 h-4" />
              <span>Retry Diagnostic Check</span>
            </button>
          </div>
        </div>
      </div>
    );
  }

  // Calculate Memory percentages
  const totalMem = data?.jvmTotalMemoryBytes || 0;
  const freeMem = data?.jvmFreeMemoryBytes || 0;
  const usedMem = totalMem - freeMem;
  const maxMem = data?.jvmMaxMemoryBytes || 0;
  const memoryUsagePercent = totalMem > 0 ? Math.round((usedMem / totalMem) * 100) : 0;
  const memoryAllocationPercent = maxMem > 0 ? Math.round((totalMem / maxMem) * 100) : 0;

  return (
    <div className="flex flex-col min-h-screen">
      <Header title="System Health Monitoring" />

      <main className="flex-1 p-8 space-y-8 mt-20 ml-64">
        {/* Section Header */}
        <div className="glass-panel p-6 rounded-3xl flex items-center justify-between border border-white/5 relative overflow-hidden">
          <div className="absolute top-0 right-0 w-[250px] h-[250px] bg-accentPurple/5 rounded-full blur-[80px] pointer-events-none"></div>
          <div className="flex items-center gap-4">
            <div className="bg-accentPurple/10 p-3 rounded-2xl border border-accentPurple/30 text-accentPurple">
              <Activity className="w-6 h-6" />
            </div>
            <div>
              <h3 className="text-lg font-bold text-white">Live System Performance</h3>
              <p className="text-xs text-textSecondary mt-0.5 font-medium">Monitoring active JVM resources, database connections, application uptime, and records count.</p>
            </div>
          </div>
          <button
            onClick={fetchHealth}
            disabled={refreshing}
            className="flex items-center gap-2 border border-white/10 px-4 py-2 rounded-xl text-xs font-bold text-textPrimary hover:bg-white/5 transition-all disabled:opacity-50"
          >
            <RefreshCw className={`w-4 h-4 ${refreshing ? 'animate-spin' : ''}`} />
            <span>Refresh Diagnostics</span>
          </button>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* JVM Memory Gauge Card */}
          <div className="glass-panel p-6 rounded-3xl lg:col-span-1 space-y-6">
            <div>
              <h3 className="text-base font-extrabold text-white">JVM Memory Resources</h3>
              <p className="text-xs text-textSecondary mt-0.5">Heap memory allocations for Spring Boot JVM.</p>
            </div>

            {/* Circular Gauge visual representation */}
            <div className="flex justify-center py-4">
              <div className="relative w-36 h-36 flex items-center justify-center">
                <svg className="w-full h-full transform -rotate-90">
                  <circle
                    cx="72"
                    cy="72"
                    r="60"
                    className="stroke-borderDark"
                    strokeWidth="8"
                    fill="transparent"
                  />
                  <circle
                    cx="72"
                    cy="72"
                    r="60"
                    className="stroke-accentPurple glow-purple"
                    strokeWidth="8"
                    fill="transparent"
                    strokeDasharray={2 * Math.PI * 60}
                    strokeDashoffset={2 * Math.PI * 60 * (1 - memoryUsagePercent / 100)}
                    strokeLinecap="round"
                  />
                </svg>
                <div className="absolute flex flex-col items-center justify-center">
                  <span className="text-3xl font-extrabold text-white">{memoryUsagePercent}%</span>
                  <span className="text-[10px] text-textSecondary font-bold uppercase tracking-wider">Used Heap</span>
                </div>
              </div>
            </div>

            {/* Stats list */}
            <div className="space-y-3 pt-2 text-xs">
              <div className="flex items-center justify-between px-3 py-2 bg-white/5 rounded-xl border border-white/5">
                <span className="font-semibold text-textSecondary">Active Used Memory</span>
                <span className="font-extrabold text-white">{formatBytes(usedMem)}</span>
              </div>
              <div className="flex items-center justify-between px-3 py-2 bg-white/5 rounded-xl border border-white/5">
                <span className="font-semibold text-textSecondary">Total Allocated Memory</span>
                <span className="font-extrabold text-white">{formatBytes(totalMem)}</span>
              </div>
              <div className="flex items-center justify-between px-3 py-2 bg-white/5 rounded-xl border border-white/5">
                <span className="font-semibold text-textSecondary">Max Available Memory</span>
                <span className="font-extrabold text-white">{formatBytes(maxMem)}</span>
              </div>
            </div>
          </div>

          {/* Infrastructure Health Status */}
          <div className="glass-panel p-6 rounded-3xl lg:col-span-2 grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="md:col-span-2">
              <h3 className="text-base font-extrabold text-white">Platform Health Indicators</h3>
              <p className="text-xs text-textSecondary mt-0.5">Physical backend state, connectivity, and threads load.</p>
            </div>

            {/* DB Connection */}
            <div className="bg-white/5 border border-borderDark p-5 rounded-2xl flex items-center justify-between">
              <div className="space-y-1">
                <span className="text-xs font-bold text-textSecondary uppercase tracking-wider block">Database Node</span>
                <span className="text-base font-extrabold text-white block">PostgreSQL Database</span>
              </div>
              <div className={`flex items-center gap-1.5 text-xs font-bold px-3.5 py-1.5 rounded-full ${
                data?.databaseConnected 
                  ? 'bg-green/10 text-green border border-green/30 shadow-glow' 
                  : 'bg-accentRose/10 text-accentRose border border-accentRose/30'
              }`}>
                <Database className="w-4 h-4" />
                <span>{data?.databaseConnected ? 'Connected' : 'Disconnected'}</span>
              </div>
            </div>

            {/* System Uptime */}
            <div className="bg-white/5 border border-borderDark p-5 rounded-2xl flex items-center justify-between">
              <div className="space-y-1">
                <span className="text-xs font-bold text-textSecondary uppercase tracking-wider block">System Uptime</span>
                <span className="text-base font-extrabold text-white block truncate">
                  {data ? formatUptime(data.uptimeMs) : 'Loading...'}
                </span>
              </div>
              <div className="bg-accentIndigo/10 border border-accentIndigo/30 p-3.5 rounded-xl text-accentIndigo shadow-glow">
                <Timer className="w-5 h-5" />
              </div>
            </div>

            {/* Active Threads */}
            <div className="bg-white/5 border border-borderDark p-5 rounded-2xl flex items-center justify-between">
              <div className="space-y-1">
                <span className="text-xs font-bold text-textSecondary uppercase tracking-wider block">JVM Threads</span>
                <span className="text-base font-extrabold text-white block">
                  {data?.activeThreads || 0} Threads
                </span>
              </div>
              <div className="bg-accentPurple/10 border border-accentPurple/30 p-3.5 rounded-xl text-accentPurple shadow-glow">
                <Cpu className="w-5 h-5" />
              </div>
            </div>

            {/* Application Environment */}
            <div className="bg-white/5 border border-borderDark p-5 rounded-2xl flex items-center justify-between">
              <div className="space-y-1">
                <span className="text-xs font-bold text-textSecondary uppercase tracking-wider block">Execution Profile</span>
                <span className="text-base font-extrabold text-white block">Native Spring Boot</span>
              </div>
              <div className="bg-accentRose/10 border border-accentRose/30 p-3.5 rounded-xl text-accentRose shadow-glow">
                <Server className="w-5 h-5" />
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
