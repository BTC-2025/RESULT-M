"use client";

import { useCallback, useEffect, useState } from "react";
import { api } from "@/lib/api";
import {
  Search, RefreshCw, UserX, UserCheck, Trash2,
  KeyRound, ChevronLeft, ChevronRight, Shield, Users
} from "lucide-react";

const ROLES = ["", "USER", "ORGANIZATION", "ADMIN"];
const ROLE_BADGE: Record<string, string> = {
  USER:         "bg-blue-500/20 text-blue-400 border-blue-500/30",
  ORGANIZATION: "bg-violet-500/20 text-violet-400 border-violet-500/30",
  ADMIN:        "bg-red-500/20 text-red-400 border-red-500/30",
};

function ConfirmModal({ title, desc, onConfirm, onCancel }: any) {
  return (
    <div className="fixed inset-0 bg-black/70 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div className="bg-[#141420] border border-white/10 rounded-2xl p-6 max-w-sm w-full shadow-2xl">
        <h3 className="text-lg font-black text-white mb-2">{title}</h3>
        <p className="text-sm text-white/50 mb-6">{desc}</p>
        <div className="flex gap-3 justify-end">
          <button onClick={onCancel} className="px-4 py-2 rounded-xl text-sm font-bold text-white/60 hover:text-white hover:bg-white/5 transition-all">
            Cancel
          </button>
          <button onClick={onConfirm} className="px-4 py-2 rounded-xl text-sm font-bold bg-red-500 hover:bg-red-400 text-white transition-all">
            Confirm
          </button>
        </div>
      </div>
    </div>
  );
}

function ResetPasswordModal({ user, onClose }: any) {
  const [password, setPassword] = useState("");
  const [loading, setLoading]   = useState(false);
  const [done, setDone]         = useState(false);

  const submit = async () => {
    if (!password || password.length < 6) return;
    setLoading(true);
    await api.admin.resetUserPassword(user.id, password).catch(() => null);
    setLoading(false);
    setDone(true);
  };

  return (
    <div className="fixed inset-0 bg-black/70 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div className="bg-[#141420] border border-white/10 rounded-2xl p-6 max-w-sm w-full shadow-2xl">
        <h3 className="text-lg font-black text-white mb-1">Reset Password</h3>
        <p className="text-sm text-white/40 mb-4">Force reset password for <span className="text-white font-semibold">{user.name}</span></p>
        {done ? (
          <div className="text-center py-4">
            <div className="text-3xl mb-2">✅</div>
            <p className="text-sm font-semibold text-emerald-400">Password reset successfully</p>
          </div>
        ) : (
          <>
            <input
              type="password"
              value={password}
              onChange={e => setPassword(e.target.value)}
              placeholder="New password (min 6 chars)"
              className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-2.5 text-sm text-white placeholder:text-white/30 focus:outline-none focus:border-red-500/50 mb-4"
            />
            <div className="flex gap-3 justify-end">
              <button onClick={onClose} className="px-4 py-2 rounded-xl text-sm font-bold text-white/60 hover:text-white hover:bg-white/5 transition-all">
                Cancel
              </button>
              <button onClick={submit} disabled={loading} className="px-4 py-2 rounded-xl text-sm font-bold bg-red-500 hover:bg-red-400 text-white transition-all disabled:opacity-50">
                {loading ? "Resetting..." : "Reset"}
              </button>
            </div>
          </>
        )}
        {done && (
          <button onClick={onClose} className="w-full mt-4 px-4 py-2 rounded-xl text-sm font-bold bg-white/5 hover:bg-white/10 text-white transition-all">
            Close
          </button>
        )}
      </div>
    </div>
  );
}

export default function UsersAdminPage() {
  const [users, setUsers]     = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [query, setQuery]     = useState("");
  const [role, setRole]       = useState("");
  const [page, setPage]       = useState(0);
  const [totalPages, setTotalPages] = useState(0);
  const [totalItems, setTotalItems] = useState(0);

  const [confirm, setConfirm]     = useState<any>(null);
  const [resetUser, setResetUser] = useState<any>(null);
  const [toast, setToast]         = useState<string | null>(null);

  const showToast = (msg: string) => {
    setToast(msg);
    setTimeout(() => setToast(null), 3000);
  };

  const fetchUsers = useCallback(async () => {
    setLoading(true);
    const res = await api.admin.getUsers(query, role, page, 20).catch(() => null);
    if (res) {
      setUsers(res.content || []);
      setTotalPages(res.totalPages || 0);
      setTotalItems(res.totalElements || 0);
    }
    setLoading(false);
  }, [query, role, page]);

  useEffect(() => { fetchUsers(); }, [fetchUsers]);

  const handleSuspend = async (user: any) => {
    const toggled = !user.suspended;
    setConfirm({
      title: toggled ? "Suspend User?" : "Restore User?",
      desc: `This will ${toggled ? "disable" : "re-enable"} the account for ${user.name}.`,
      onConfirm: async () => {
        setConfirm(null);
        await api.admin.suspendUser(user.id, toggled).catch(() => null);
        showToast(`User ${toggled ? "suspended" : "restored"} successfully`);
        fetchUsers();
      },
      onCancel: () => setConfirm(null),
    });
  };

  const handleDelete = (user: any) => {
    setConfirm({
      title: "Delete User?",
      desc: `This permanently deletes ${user.name}. This action CANNOT be undone.`,
      onConfirm: async () => {
        setConfirm(null);
        await api.admin.deleteUser(user.id).catch(() => null);
        showToast("User permanently deleted");
        fetchUsers();
      },
      onCancel: () => setConfirm(null),
    });
  };

  return (
    <div className="p-8 space-y-6">
      {/* Toast */}
      {toast && (
        <div className="fixed top-6 right-6 z-50 bg-emerald-500 text-white text-sm font-bold px-5 py-3 rounded-xl shadow-lg shadow-emerald-900/30 animate-in slide-in-from-top-2">
          {toast}
        </div>
      )}

      {/* Modals */}
      {confirm && <ConfirmModal {...confirm} />}
      {resetUser && <ResetPasswordModal user={resetUser} onClose={() => { setResetUser(null); fetchUsers(); }} />}

      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-black text-white tracking-tight">User Management</h1>
          <p className="text-white/40 text-sm font-medium mt-1">{totalItems.toLocaleString()} total users</p>
        </div>
        <button onClick={fetchUsers} className="flex items-center gap-2 px-4 py-2 rounded-xl bg-white/5 border border-white/10 text-white/60 hover:text-white hover:bg-white/10 transition-all text-sm font-semibold">
          <RefreshCw className="w-4 h-4" /> Refresh
        </button>
      </div>

      {/* Filters */}
      <div className="flex gap-3 flex-wrap">
        <div className="relative flex-1 min-w-[200px]">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-white/30" />
          <input
            value={query}
            onChange={e => { setQuery(e.target.value); setPage(0); }}
            placeholder="Search name or email..."
            className="w-full bg-white/5 border border-white/10 rounded-xl pl-10 pr-4 py-2.5 text-sm text-white placeholder:text-white/30 focus:outline-none focus:border-white/20"
          />
        </div>
        <select
          value={role}
          onChange={e => { setRole(e.target.value); setPage(0); }}
          className="bg-white/5 border border-white/10 rounded-xl px-4 py-2.5 text-sm text-white focus:outline-none focus:border-white/20"
        >
          {ROLES.map(r => <option key={r} value={r} className="bg-[#141420]">{r || "All Roles"}</option>)}
        </select>
      </div>

      {/* Table */}
      <div className="bg-white/[0.02] border border-white/[0.06] rounded-2xl overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead>
              <tr className="border-b border-white/[0.06]">
                {["User", "Email", "Role", "City", "Quota", "Joined", "Status", "Actions"].map(h => (
                  <th key={h} className="px-4 py-3.5 text-[10px] font-black text-white/30 uppercase tracking-widest whitespace-nowrap">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-white/[0.04]">
              {loading ? (
                [...Array(8)].map((_, i) => (
                  <tr key={i} className="animate-pulse">
                    {[...Array(8)].map((__, j) => (
                      <td key={j} className="px-4 py-4"><div className="h-3 bg-white/5 rounded w-full" /></td>
                    ))}
                  </tr>
                ))
              ) : users.length === 0 ? (
                <tr>
                  <td colSpan={8} className="px-4 py-16 text-center">
                    <Users className="w-12 h-12 text-white/10 mx-auto mb-3" />
                    <p className="text-white/30 text-sm font-semibold">No users found</p>
                  </td>
                </tr>
              ) : users.map(user => (
                <tr key={user.id} className="hover:bg-white/[0.02] transition-colors group">
                  <td className="px-4 py-3.5">
                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-blue-500/40 to-violet-500/40 flex items-center justify-center text-xs font-black text-white shrink-0">
                        {user.name?.[0]?.toUpperCase()}
                      </div>
                      <span className="text-[13px] font-semibold text-white truncate max-w-[140px]">{user.name}</span>
                    </div>
                  </td>
                  <td className="px-4 py-3.5 text-[12px] text-white/50 font-medium">{user.email}</td>
                  <td className="px-4 py-3.5">
                    <span className={`inline-flex items-center text-[10px] font-black px-2 py-0.5 rounded-full border ${ROLE_BADGE[user.role] || "bg-white/5 text-white/40 border-white/10"}`}>
                      {user.role}
                    </span>
                  </td>
                  <td className="px-4 py-3.5 text-[12px] text-white/40">{user.city || "—"}</td>
                  <td className="px-4 py-3.5 text-[12px] text-white/40 text-center">{user.workspaceQuota}</td>
                  <td className="px-4 py-3.5 text-[12px] text-white/40 whitespace-nowrap">
                    {user.createdAt ? new Date(user.createdAt).toLocaleDateString() : "—"}
                  </td>
                  <td className="px-4 py-3.5">
                    <span className={`inline-flex items-center text-[10px] font-black px-2 py-0.5 rounded-full border ${
                      user.suspended
                        ? "bg-red-500/20 text-red-400 border-red-500/30"
                        : "bg-emerald-500/20 text-emerald-400 border-emerald-500/30"
                    }`}>
                      {user.suspended ? "Suspended" : "Active"}
                    </span>
                  </td>
                  <td className="px-4 py-3.5">
                    <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                      <button
                        onClick={() => handleSuspend(user)}
                        title={user.suspended ? "Restore" : "Suspend"}
                        className="p-1.5 rounded-lg hover:bg-white/5 text-white/40 hover:text-amber-400 transition-all"
                      >
                        {user.suspended ? <UserCheck className="w-4 h-4" /> : <UserX className="w-4 h-4" />}
                      </button>
                      <button
                        onClick={() => setResetUser(user)}
                        title="Reset Password"
                        className="p-1.5 rounded-lg hover:bg-white/5 text-white/40 hover:text-blue-400 transition-all"
                      >
                        <KeyRound className="w-4 h-4" />
                      </button>
                      <button
                        onClick={() => handleDelete(user)}
                        title="Delete User"
                        className="p-1.5 rounded-lg hover:bg-white/5 text-white/40 hover:text-red-400 transition-all"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        {totalPages > 1 && (
          <div className="flex items-center justify-between px-4 py-3 border-t border-white/[0.06]">
            <p className="text-[12px] text-white/30 font-medium">
              Page {page + 1} of {totalPages}
            </p>
            <div className="flex gap-2">
              <button
                disabled={page === 0}
                onClick={() => setPage(p => p - 1)}
                className="p-2 rounded-lg bg-white/5 text-white/40 hover:text-white hover:bg-white/10 disabled:opacity-30 disabled:cursor-not-allowed transition-all"
              >
                <ChevronLeft className="w-4 h-4" />
              </button>
              <button
                disabled={page >= totalPages - 1}
                onClick={() => setPage(p => p + 1)}
                className="p-2 rounded-lg bg-white/5 text-white/40 hover:text-white hover:bg-white/10 disabled:opacity-30 disabled:cursor-not-allowed transition-all"
              >
                <ChevronRight className="w-4 h-4" />
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
