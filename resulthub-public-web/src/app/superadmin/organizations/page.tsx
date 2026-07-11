"use client";

import { useCallback, useEffect, useState } from "react";
import { api } from "@/lib/api";
import {
  Search, RefreshCw, Trash2, Ban, CheckCircle2,
  ChevronLeft, ChevronRight, Building2
} from "lucide-react";

function ConfirmModal({ title, desc, onConfirm, onCancel }: any) {
  return (
    <div className="fixed inset-0 bg-black/70 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div className="bg-[#141420] border border-white/10 rounded-2xl p-6 max-w-sm w-full shadow-2xl">
        <h3 className="text-lg font-black text-white mb-2">{title}</h3>
        <p className="text-sm text-white/50 mb-6">{desc}</p>
        <div className="flex gap-3 justify-end">
          <button onClick={onCancel} className="px-4 py-2 rounded-xl text-sm font-bold text-white/60 hover:text-white hover:bg-white/5 transition-all">Cancel</button>
          <button onClick={onConfirm} className="px-4 py-2 rounded-xl text-sm font-bold bg-red-500 hover:bg-red-400 text-white transition-all">Confirm</button>
        </div>
      </div>
    </div>
  );
}

export default function OrganizationsAdminPage() {
  const [workspaces, setWorkspaces] = useState<any[]>([]);
  const [loading, setLoading]       = useState(true);
  const [query, setQuery]           = useState("");
  const [page, setPage]             = useState(0);
  const [totalPages, setTotalPages] = useState(0);
  const [totalItems, setTotalItems] = useState(0);
  const [confirm, setConfirm]       = useState<any>(null);
  const [toast, setToast]           = useState<string | null>(null);

  const showToast = (msg: string) => {
    setToast(msg);
    setTimeout(() => setToast(null), 3000);
  };

  const fetchWorkspaces = useCallback(async () => {
    setLoading(true);
    const res = await api.admin.getWorkspaces(query, page, 20).catch(() => null);
    if (res) {
      setWorkspaces(res.content || []);
      setTotalPages(res.totalPages || 0);
      setTotalItems(res.totalElements || 0);
    }
    setLoading(false);
  }, [query, page]);

  useEffect(() => { fetchWorkspaces(); }, [fetchWorkspaces]);

  const handleSuspend = (ws: any) => {
    const toggled = !ws.suspended;
    setConfirm({
      title: toggled ? "Suspend Workspace?" : "Restore Workspace?",
      desc: `This will ${toggled ? "hide" : "restore"} the workspace "${ws.name}".`,
      onConfirm: async () => {
        setConfirm(null);
        await api.admin.suspendWorkspace(ws.id, toggled).catch(() => null);
        showToast(`Workspace ${toggled ? "suspended" : "restored"}`);
        fetchWorkspaces();
      },
      onCancel: () => setConfirm(null),
    });
  };

  const handleDelete = (ws: any) => {
    setConfirm({
      title: "Delete Workspace?",
      desc: `This permanently deletes "${ws.name}" and all its data. Cannot be undone.`,
      onConfirm: async () => {
        setConfirm(null);
        await api.admin.deleteWorkspace(ws.id).catch(() => null);
        showToast("Workspace permanently deleted");
        fetchWorkspaces();
      },
      onCancel: () => setConfirm(null),
    });
  };

  return (
    <div className="p-8 space-y-6">
      {toast && (
        <div className="fixed top-6 right-6 z-50 bg-emerald-500 text-white text-sm font-bold px-5 py-3 rounded-xl shadow-lg animate-in slide-in-from-top-2">{toast}</div>
      )}
      {confirm && <ConfirmModal {...confirm} />}

      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-black text-white tracking-tight">Workspace Management</h1>
          <p className="text-white/40 text-sm font-medium mt-1">{totalItems.toLocaleString()} total workspaces</p>
        </div>
        <button onClick={fetchWorkspaces} className="flex items-center gap-2 px-4 py-2 rounded-xl bg-white/5 border border-white/10 text-white/60 hover:text-white hover:bg-white/10 transition-all text-sm font-semibold">
          <RefreshCw className="w-4 h-4" /> Refresh
        </button>
      </div>

      <div className="relative">
        <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-white/30" />
        <input
          value={query}
          onChange={e => { setQuery(e.target.value); setPage(0); }}
          placeholder="Search workspace name or slug..."
          className="w-full max-w-md bg-white/5 border border-white/10 rounded-xl pl-10 pr-4 py-2.5 text-sm text-white placeholder:text-white/30 focus:outline-none focus:border-white/20"
        />
      </div>

      <div className="bg-white/[0.02] border border-white/[0.06] rounded-2xl overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead>
              <tr className="border-b border-white/[0.06]">
                {["Workspace", "Slug", "Owner", "Datasets", "Status", "Created", "Actions"].map(h => (
                  <th key={h} className="px-4 py-3.5 text-[10px] font-black text-white/30 uppercase tracking-widest whitespace-nowrap">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-white/[0.04]">
              {loading ? (
                [...Array(8)].map((_, i) => (
                  <tr key={i} className="animate-pulse">
                    {[...Array(7)].map((__, j) => (
                      <td key={j} className="px-4 py-4"><div className="h-3 bg-white/5 rounded w-full" /></td>
                    ))}
                  </tr>
                ))
              ) : workspaces.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-4 py-16 text-center">
                    <Building2 className="w-12 h-12 text-white/10 mx-auto mb-3" />
                    <p className="text-white/30 text-sm font-semibold">No workspaces found</p>
                  </td>
                </tr>
              ) : workspaces.map(ws => (
                <tr key={ws.id} className="hover:bg-white/[0.02] transition-colors group">
                  <td className="px-4 py-3.5">
                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-violet-500/40 to-blue-500/40 flex items-center justify-center text-xs font-black text-white shrink-0">
                        {ws.name?.[0]?.toUpperCase()}
                      </div>
                      <span className="text-[13px] font-semibold text-white truncate max-w-[160px]">{ws.name}</span>
                    </div>
                  </td>
                  <td className="px-4 py-3.5 text-[12px] text-white/40 font-mono">@{ws.slug}</td>
                  <td className="px-4 py-3.5">
                    <div className="text-[12px] text-white/60 font-semibold">{ws.ownerName || "—"}</div>
                    <div className="text-[11px] text-white/30">{ws.ownerEmail}</div>
                  </td>
                  <td className="px-4 py-3.5 text-[12px] text-white/40 text-center">{ws.datasetCount ?? 0}</td>
                  <td className="px-4 py-3.5">
                    <span className={`inline-flex items-center text-[10px] font-black px-2 py-0.5 rounded-full border ${
                      ws.suspended
                        ? "bg-red-500/20 text-red-400 border-red-500/30"
                        : "bg-emerald-500/20 text-emerald-400 border-emerald-500/30"
                    }`}>
                      {ws.suspended ? "Suspended" : "Active"}
                    </span>
                  </td>
                  <td className="px-4 py-3.5 text-[12px] text-white/40 whitespace-nowrap">
                    {ws.createdAt ? new Date(ws.createdAt).toLocaleDateString() : "—"}
                  </td>
                  <td className="px-4 py-3.5">
                    <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                      <button onClick={() => handleSuspend(ws)} title={ws.suspended ? "Restore" : "Suspend"}
                        className="p-1.5 rounded-lg hover:bg-white/5 text-white/40 hover:text-amber-400 transition-all">
                        {ws.suspended ? <CheckCircle2 className="w-4 h-4" /> : <Ban className="w-4 h-4" />}
                      </button>
                      <button onClick={() => handleDelete(ws)} title="Delete Workspace"
                        className="p-1.5 rounded-lg hover:bg-white/5 text-white/40 hover:text-red-400 transition-all">
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        {totalPages > 1 && (
          <div className="flex items-center justify-between px-4 py-3 border-t border-white/[0.06]">
            <p className="text-[12px] text-white/30 font-medium">Page {page + 1} of {totalPages}</p>
            <div className="flex gap-2">
              <button disabled={page === 0} onClick={() => setPage(p => p - 1)}
                className="p-2 rounded-lg bg-white/5 text-white/40 hover:text-white hover:bg-white/10 disabled:opacity-30 disabled:cursor-not-allowed transition-all">
                <ChevronLeft className="w-4 h-4" />
              </button>
              <button disabled={page >= totalPages - 1} onClick={() => setPage(p => p + 1)}
                className="p-2 rounded-lg bg-white/5 text-white/40 hover:text-white hover:bg-white/10 disabled:opacity-30 disabled:cursor-not-allowed transition-all">
                <ChevronRight className="w-4 h-4" />
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
