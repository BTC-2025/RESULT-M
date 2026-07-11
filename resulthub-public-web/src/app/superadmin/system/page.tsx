"use client";

import { useEffect, useState } from "react";
import { api } from "@/lib/api";
import { RefreshCw, Server, Database, Cpu, Clock, Activity, CheckCircle2, XCircle } from "lucide-react";

function MetricCard({ label, value, icon: Icon, color, sub }: any) {
  return (
    <div className="bg-white/[0.03] border border-white/[0.06] rounded-2xl p-5">
      <div className="flex items-center gap-3 mb-4">
        <div className={`w-9 h-9 rounded-xl flex items-center justify-center ${color}`}>
          <Icon className="w-4 h-4 text-white" />
        </div>
        <div>
          <p className="text-[12px] font-black text-white/40 uppercase tracking-wider">{label}</p>
          {sub && <p className="text-[10px] text-white/20">{sub}</p>}
        </div>
      </div>
      <div className="text-2xl font-black text-white">{value ?? "—"}</div>
    </div>
  );
}

function MemoryGauge({ used, max, label }: { used: number; max: number; label: string }) {
  const pct = max > 0 ? Math.round((used / max) * 100) : 0;
  const barColor = pct > 80 ? "bg-red-500" : pct > 60 ? "bg-amber-500" : "bg-emerald-500";

  return (
    <div className="space-y-2">
      <div className="flex justify-between items-center">
        <span className="text-[12px] font-bold text-white/50">{label}</span>
        <span className="text-[12px] font-black text-white">{pct}%</span>
      </div>
      <div className="h-2.5 rounded-full bg-white/5 overflow-hidden">
        <div className={`h-full rounded-full ${barColor} transition-all duration-700`} style={{ width: `${pct}%` }} />
      </div>
      <div className="flex justify-between text-[11px] text-white/20 font-medium">
        <span>{Math.round(used / 1_048_576)}MB used</span>
        <span>{Math.round(max / 1_048_576)}MB max</span>
      </div>
    </div>
  );
}

export default function SystemHealthPage() {
  const [health, setHealth] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [refreshed, setRefreshed] = useState<Date | null>(null);

  const fetchHealth = async () => {
    setLoading(true);
    const h = await api.admin.getSystemHealth().catch(() => null);
    setHealth(h);
    setRefreshed(new Date());
    setLoading(false);
  };

  useEffect(() => { fetchHealth(); }, []);

  const uptimeHours = health ? Math.floor(health.uptimeMs / 3_600_000) : 0;
  const uptimeMins  = health ? Math.floor((health.uptimeMs % 3_600_000) / 60_000) : 0;
  const uptimeSecs  = health ? Math.floor((health.uptimeMs % 60_000) / 1_000) : 0;

  return (
    <div className="p-8 space-y-8">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-black text-white tracking-tight">System Health</h1>
          <p className="text-white/40 text-sm font-medium mt-1">
            {refreshed ? `Last refreshed: ${refreshed.toLocaleTimeString()}` : "Loading..."}
          </p>
        </div>
        <button onClick={fetchHealth} disabled={loading}
          className="flex items-center gap-2 px-4 py-2 rounded-xl bg-white/5 border border-white/10 text-white/60 hover:text-white hover:bg-white/10 transition-all text-sm font-semibold disabled:opacity-50">
          <RefreshCw className={`w-4 h-4 ${loading ? "animate-spin" : ""}`} /> Refresh
        </button>
      </div>

      {/* DB Status Banner */}
      <div className={`flex items-center gap-3 px-5 py-4 rounded-2xl border ${
        health?.databaseConnected !== false
          ? "bg-emerald-500/10 border-emerald-500/20"
          : "bg-red-500/10 border-red-500/20"
      }`}>
        {health?.databaseConnected !== false
          ? <CheckCircle2 className="w-5 h-5 text-emerald-400 shrink-0" />
          : <XCircle className="w-5 h-5 text-red-400 shrink-0" />
        }
        <div>
          <p className={`text-sm font-black ${health?.databaseConnected !== false ? "text-emerald-400" : "text-red-400"}`}>
            Database {health?.databaseConnected !== false ? "Connected & Healthy" : "Connection Error"}
          </p>
          <p className="text-[11px] text-white/30 font-medium">PostgreSQL via Spring Data JPA</p>
        </div>
      </div>

      {/* Key Metrics */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <MetricCard label="Uptime"           value={loading ? "—" : `${uptimeHours}h ${uptimeMins}m ${uptimeSecs}s`}  icon={Clock}     color="bg-blue-500/30" />
        <MetricCard label="Active Threads"   value={loading ? "—" : health?.activeThreads}                            icon={Cpu}       color="bg-violet-500/30" />
        <MetricCard label="Total Users"      value={loading ? "—" : health?.totalUsers?.toLocaleString()}             icon={Activity}  color="bg-emerald-500/30" />
        <MetricCard label="Total Datasets"   value={loading ? "—" : health?.totalDatasets?.toLocaleString()}          icon={Database}  color="bg-cyan-500/30" />
      </div>

      {/* Memory Gauges */}
      <div className="bg-white/[0.03] border border-white/[0.06] rounded-2xl p-6 space-y-6">
        <div className="flex items-center gap-3 mb-2">
          <div className="w-9 h-9 rounded-xl bg-cyan-500/20 flex items-center justify-center">
            <Server className="w-4 h-4 text-cyan-400" />
          </div>
          <h2 className="text-[15px] font-black text-white">JVM Heap Memory</h2>
        </div>

        {loading ? (
          <div className="animate-pulse space-y-6">
            <div className="space-y-2">
              <div className="h-3 bg-white/10 rounded w-1/4" />
              <div className="h-2.5 bg-white/5 rounded-full" />
            </div>
            <div className="space-y-2">
              <div className="h-3 bg-white/10 rounded w-1/4" />
              <div className="h-2.5 bg-white/5 rounded-full" />
            </div>
          </div>
        ) : (
          <>
            <MemoryGauge
              label="Heap Used (vs Max)"
              used={health?.jvmTotalMemoryBytes - health?.jvmFreeMemoryBytes}
              max={health?.jvmMaxMemoryBytes}
            />
            <MemoryGauge
              label="Allocated Heap (vs Max)"
              used={health?.jvmTotalMemoryBytes}
              max={health?.jvmMaxMemoryBytes}
            />
          </>
        )}
      </div>

      {/* Platform Stats */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        {[
          { label: "Total Users",         value: health?.totalUsers?.toLocaleString() },
          { label: "Total Organizations", value: health?.totalOrganizations?.toLocaleString() },
          { label: "Total Workspaces",    value: health?.totalWorkspaces?.toLocaleString() },
          { label: "Total Datasets",      value: health?.totalDatasets?.toLocaleString() },
        ].map(({ label, value }) => (
          <div key={label} className="bg-white/[0.03] border border-white/[0.06] rounded-2xl p-5 text-center">
            <p className="text-2xl font-black text-white">{loading ? "—" : (value ?? "0")}</p>
            <p className="text-[11px] text-white/30 font-bold uppercase tracking-wider mt-1">{label}</p>
          </div>
        ))}
      </div>
    </div>
  );
}
