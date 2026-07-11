"use client";

import { useEffect, useState } from "react";
import { api } from "@/lib/api";
import {
  Users, Building2, Database, AlertTriangle,
  FileText, TrendingUp, UserCheck, UserX,
  Activity, Server
} from "lucide-react";

function StatCard({ label, value, icon: Icon, color, sub }: any) {
  return (
    <div className="bg-white/[0.03] border border-white/[0.06] rounded-2xl p-5 hover:bg-white/[0.05] transition-all">
      <div className="flex items-start justify-between mb-4">
        <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${color}`}>
          <Icon className="w-5 h-5 text-white" />
        </div>
        {sub !== undefined && (
          <span className="flex items-center gap-1 text-[11px] font-bold text-emerald-400 bg-emerald-500/10 px-2 py-0.5 rounded-full">
            <TrendingUp className="w-3 h-3" /> {sub} today
          </span>
        )}
      </div>
      <div className="text-3xl font-black text-white tracking-tight">
        {value?.toLocaleString() ?? "—"}
      </div>
      <div className="text-[12px] font-semibold text-white/40 mt-1 uppercase tracking-wider">{label}</div>
    </div>
  );
}

function SkeletonCard() {
  return (
    <div className="bg-white/[0.03] border border-white/[0.06] rounded-2xl p-5 animate-pulse">
      <div className="w-10 h-10 rounded-xl bg-white/10 mb-4" />
      <div className="h-8 w-24 bg-white/10 rounded-lg mb-2" />
      <div className="h-3 w-32 bg-white/5 rounded" />
    </div>
  );
}

export default function SuperAdminDashboard() {
  const [stats, setStats] = useState<any>(null);
  const [health, setHealth] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([
      api.admin.getStats().catch(() => null),
      api.admin.getSystemHealth().catch(() => null),
    ]).then(([s, h]) => {
      setStats(s);
      setHealth(h);
      setLoading(false);
    });
  }, []);

  const memUsedPct = health
    ? Math.round(((health.jvmTotalMemoryBytes - health.jvmFreeMemoryBytes) / health.jvmMaxMemoryBytes) * 100)
    : 0;
  const uptimeHours = health ? Math.floor(health.uptimeMs / 3_600_000) : 0;
  const uptimeMins  = health ? Math.floor((health.uptimeMs % 3_600_000) / 60_000) : 0;

  return (
    <div className="p-8 space-y-8">
      {/* Page Header */}
      <div>
        <h1 className="text-3xl font-black text-white tracking-tight">Platform Overview</h1>
        <p className="text-white/40 text-sm font-medium mt-1">Real-time statistics for the ResultHub platform</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-4">
        {loading ? (
          [...Array(10)].map((_, i) => <SkeletonCard key={i} />)
        ) : (
          <>
            <StatCard label="Total Users"         value={stats?.totalUsers}         icon={Users}        color="bg-blue-500/80"    sub={stats?.newUsersToday} />
            <StatCard label="Organizations"       value={stats?.totalOrganizations} icon={Building2}    color="bg-violet-500/80" />
            <StatCard label="Workspaces"          value={stats?.totalWorkspaces}     icon={Database}     color="bg-emerald-500/80" />
            <StatCard label="Datasets"            value={stats?.totalDatasets}       icon={FileText}     color="bg-cyan-500/80" />
            <StatCard label="Complaints"          value={stats?.totalComplaints}     icon={AlertTriangle} color="bg-orange-500/80" />
            <StatCard label="Feed Posts"          value={stats?.totalPosts}          icon={FileText}     color="bg-pink-500/80" />
            <StatCard label="Active Users"        value={stats?.activeUsers}         icon={UserCheck}    color="bg-emerald-600/80" />
            <StatCard label="Suspended"           value={stats?.suspendedUsers}      icon={UserX}        color="bg-red-500/80" />
            <StatCard label="New This Week"       value={stats?.newUsersThisWeek}    icon={TrendingUp}   color="bg-amber-500/80" />
          </>
        )}
      </div>

      {/* System Health */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        {/* JVM Memory */}
        <div className="bg-white/[0.03] border border-white/[0.06] rounded-2xl p-6">
          <div className="flex items-center gap-3 mb-5">
            <div className="w-9 h-9 rounded-xl bg-cyan-500/20 flex items-center justify-center">
              <Server className="w-4.5 h-4.5 text-cyan-400" />
            </div>
            <div>
              <h2 className="text-[14px] font-black text-white">JVM Memory</h2>
              <p className="text-[11px] text-white/40 font-medium">Heap usage</p>
            </div>
            <span className={`ml-auto text-[11px] font-bold px-2.5 py-1 rounded-full ${
              health?.databaseConnected ? "bg-emerald-500/15 text-emerald-400" : "bg-red-500/15 text-red-400"
            }`}>
              DB {health?.databaseConnected ? "Connected" : "Error"}
            </span>
          </div>

          {loading ? (
            <div className="animate-pulse space-y-3">
              <div className="h-4 bg-white/10 rounded-full" />
              <div className="h-3 bg-white/5 rounded w-1/2" />
            </div>
          ) : (
            <>
              <div className="flex justify-between text-[12px] font-semibold text-white/40 mb-2">
                <span>Used: {Math.round((health?.jvmTotalMemoryBytes - health?.jvmFreeMemoryBytes) / 1_048_576)}MB</span>
                <span>Max: {Math.round(health?.jvmMaxMemoryBytes / 1_048_576)}MB</span>
              </div>
              <div className="h-3 rounded-full bg-white/5 overflow-hidden">
                <div
                  className={`h-full rounded-full transition-all ${memUsedPct > 80 ? "bg-red-500" : memUsedPct > 60 ? "bg-amber-500" : "bg-emerald-500"}`}
                  style={{ width: `${memUsedPct}%` }}
                />
              </div>
              <p className="text-[11px] text-white/30 font-medium mt-2">{memUsedPct}% utilized</p>
            </>
          )}
        </div>

        {/* Runtime Info */}
        <div className="bg-white/[0.03] border border-white/[0.06] rounded-2xl p-6">
          <div className="flex items-center gap-3 mb-5">
            <div className="w-9 h-9 rounded-xl bg-emerald-500/20 flex items-center justify-center">
              <Activity className="w-4.5 h-4.5 text-emerald-400" />
            </div>
            <h2 className="text-[14px] font-black text-white">Runtime</h2>
          </div>
          <div className="grid grid-cols-2 gap-4">
            {[
              { label: "Uptime",        value: loading ? "—" : `${uptimeHours}h ${uptimeMins}m` },
              { label: "Active Threads",value: loading ? "—" : health?.activeThreads?.toString() },
              { label: "DB Status",     value: loading ? "—" : health?.databaseConnected ? "Healthy" : "Error" },
              { label: "Platform",      value: "Spring Boot 3" },
            ].map(({ label, value }) => (
              <div key={label} className="bg-white/[0.03] rounded-xl p-3 border border-white/5">
                <p className="text-[10px] text-white/30 font-bold uppercase tracking-wider mb-1">{label}</p>
                <p className="text-[14px] font-black text-white">{value}</p>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
