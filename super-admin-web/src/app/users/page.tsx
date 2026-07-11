"use client";

import React, { useState, useEffect } from 'react';
import { useAuth } from '@/context/AuthContext';
import Header from '@/components/Header';
import { 
  Users2, 
  Search, 
  Settings2, 
  ShieldAlert, 
  UserX, 
  UserCheck, 
  KeyRound, 
  AlertTriangle,
  X,
  Sliders,
  ChevronLeft,
  ChevronRight,
  UserPlus
} from 'lucide-react';

interface UserItem {
  id: string;
  email: string;
  name: string;
  role: 'USER' | 'ADMIN' | 'ORGANIZATION';
  phoneNumber?: string;
  organizationType?: string;
  website?: string;
  city?: string;
  workspaceQuota: number;
  createdAt: string;
  suspended: boolean;
}

export default function UsersManagementPage() {
  const { apiFetch } = useAuth();
  
  // Table state
  const [users, setUsers] = useState<UserItem[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedRole, setSelectedRole] = useState<string>('');
  const [page, setPage] = useState(0);
  const [size] = useState(10);
  const [totalPages, setTotalPages] = useState(0);
  const [totalElements, setTotalElements] = useState(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Modal states
  const [selectedUser, setSelectedUser] = useState<UserItem | null>(null);
  const [quotaModalOpen, setQuotaModalOpen] = useState(false);
  const [newQuota, setNewQuota] = useState(5);
  const [resetPassModalOpen, setResetPassModalOpen] = useState(false);
  const [newPassword, setNewPassword] = useState('');
  const [modalLoading, setModalLoading] = useState(false);
  const [modalMessage, setModalMessage] = useState<string | null>(null);

  const fetchUsers = async () => {
    setLoading(true);
    setError(null);
    try {
      let url = `/api/v1/admin/users?page=${page}&size=${size}`;
      if (searchQuery) url += `&query=${encodeURIComponent(searchQuery)}`;
      if (selectedRole) url += `&role=${encodeURIComponent(selectedRole)}`;

      const res = await apiFetch(url);
      if (!res.ok) {
        throw new Error("Unable to fetch user list.");
      }
      const data = await res.json();
      setUsers(data.content || []);
      setTotalPages(data.totalPages || 0);
      setTotalElements(data.totalElements || 0);
    } catch (err: any) {
      setError(err.message || "An unexpected error occurred while loading users.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, [page, selectedRole]);

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setPage(0);
    fetchUsers();
  };

  // Toggle user suspension state
  const handleToggleSuspend = async (user: UserItem) => {
    const shouldSuspend = !user.suspended;
    try {
      const res = await apiFetch(`/api/v1/admin/users/${user.id}/suspend?suspend=${shouldSuspend}`, {
        method: 'PUT'
      });
      if (!res.ok) {
        throw new Error(`Failed to ${shouldSuspend ? 'suspend' : 'activate'} user account.`);
      }
      
      // Update local state
      setUsers(users.map(u => u.id === user.id ? { ...u, suspended: shouldSuspend } : u));
    } catch (err: any) {
      alert(err.message || "Operation failed.");
    }
  };

  // Save updated quota limit
  const handleSaveQuota = async () => {
    if (!selectedUser) return;
    setModalLoading(true);
    setModalMessage(null);
    try {
      const res = await apiFetch(`/api/v1/admin/users/${selectedUser.id}/quota`, {
        method: 'PUT',
        body: JSON.stringify({ workspaceQuota: newQuota })
      });
      if (!res.ok) {
        throw new Error("Failed to update workspace quota limit.");
      }
      
      // Update local state
      setUsers(users.map(u => u.id === selectedUser.id ? { ...u, workspaceQuota: newQuota } : u));
      setQuotaModalOpen(false);
      setSelectedUser(null);
    } catch (err: any) {
      setModalMessage(err.message || "Failed to update quota.");
    } finally {
      setModalLoading(false);
    }
  };

  // Save new password
  const handleResetPassword = async () => {
    if (!selectedUser) return;
    setModalLoading(true);
    setModalMessage(null);
    try {
      const res = await apiFetch(`/api/v1/admin/users/${selectedUser.id}/reset-password`, {
        method: 'POST',
        body: JSON.stringify({ newPassword })
      });
      if (!res.ok) {
        throw new Error("Failed to reset password.");
      }
      
      setResetPassModalOpen(false);
      setNewPassword('');
      setSelectedUser(null);
      alert("Password has been reset successfully.");
    } catch (err: any) {
      setModalMessage(err.message || "Failed to reset password.");
    } finally {
      setModalLoading(false);
    }
  };

  return (
    <div className="flex flex-col min-h-screen">
      <Header title="User & Org Management" />

      <main className="flex-1 p-8 space-y-8 mt-20 ml-64">
        {/* Statistics and Actions */}
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 glass-panel p-6 rounded-3xl border border-white/5">
          <div className="flex items-center gap-4">
            <div className="bg-accentIndigo/10 p-3 rounded-2xl border border-accentIndigo/30 text-accentIndigo">
              <Users2 className="w-6 h-6" />
            </div>
            <div>
              <h3 className="text-lg font-bold text-white">Platform Users Directory</h3>
              <p className="text-xs text-textSecondary mt-0.5 font-medium">Total Registered: {totalElements} | Manage login rights, credentials, and org quotas.</p>
            </div>
          </div>
        </div>

        {/* Filter bar */}
        <form onSubmit={handleSearchSubmit} className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div className="md:col-span-2 relative">
            <Search className="absolute left-4 top-3.5 w-5 h-5 text-textSecondary" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search by name or email..."
              className="w-full bg-panelBg border border-borderDark pl-12 pr-4 py-3 rounded-2xl text-sm text-textPrimary placeholder:text-textSecondary/50 focus:outline-none focus:border-accentPurple transition-all"
            />
          </div>

          <div>
            <select
              value={selectedRole}
              onChange={(e) => {
                setSelectedRole(e.target.value);
                setPage(0);
              }}
              className="w-full bg-panelBg border border-borderDark px-4 py-3.5 rounded-2xl text-sm text-textPrimary focus:outline-none focus:border-accentPurple transition-all"
            >
              <option value="">All Account Roles</option>
              <option value="USER">End Users</option>
              <option value="ORGANIZATION">Organizations</option>
              <option value="ADMIN">Platform Admins</option>
            </select>
          </div>

          <button
            type="submit"
            className="bg-accentPurple text-white font-extrabold text-sm uppercase tracking-wider py-3 px-6 rounded-2xl transition-all hover:opacity-90 shadow-glow"
          >
            Apply Filters
          </button>
        </form>

        {/* Users Table */}
        <div className="glass-panel rounded-3xl overflow-hidden border border-white/5">
          {loading ? (
            <div className="p-20 flex justify-center">
              <div className="w-10 h-10 border-4 border-accentPurple border-t-transparent rounded-full animate-spin"></div>
            </div>
          ) : error ? (
            <div className="p-20 text-center space-y-4">
              <AlertTriangle className="w-12 h-12 text-accentRose mx-auto animate-bounce" />
              <p className="text-textSecondary text-sm font-semibold">{error}</p>
            </div>
          ) : users.length === 0 ? (
            <div className="p-20 text-center text-textSecondary">
              <Users2 className="w-12 h-12 opacity-30 mx-auto mb-2" />
              <p className="text-sm font-semibold">No accounts match the current query criteria.</p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse">
                <thead>
                  <tr className="border-b border-borderDark text-xs font-bold text-textSecondary uppercase tracking-wider bg-black/30">
                    <th className="py-4 px-6">Name / Organization</th>
                    <th className="py-4 px-6">Contact / Email</th>
                    <th className="py-4 px-6">Platform Role</th>
                    <th className="py-4 px-6">Quota Limit</th>
                    <th className="py-4 px-6">Account Status</th>
                    <th className="py-4 px-6 text-right">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-borderDark text-sm">
                  {users.map((user) => (
                    <tr key={user.id} className="hover:bg-white/5 transition-colors">
                      <td className="py-4 px-6">
                        <div className="font-bold text-white">{user.name}</div>
                        {user.organizationType && (
                          <div className="text-[10px] text-accentPurple font-bold uppercase mt-0.5 tracking-wider">
                            Type: {user.organizationType}
                          </div>
                        )}
                        {user.city && <div className="text-xs text-textSecondary">{user.city}</div>}
                      </td>
                      <td className="py-4 px-6">
                        <div className="text-textPrimary">{user.email}</div>
                        {user.phoneNumber && <div className="text-xs text-textSecondary mt-0.5">{user.phoneNumber}</div>}
                      </td>
                      <td className="py-4 px-6">
                        <span className={`inline-block px-3 py-1 rounded-full text-[10px] font-bold tracking-wider ${
                          user.role === 'ADMIN' 
                            ? 'bg-green/15 text-green border border-green/20' 
                            : user.role === 'ORGANIZATION'
                            ? 'bg-accentPurple/15 text-accentPurple border border-accentPurple/20'
                            : 'bg-white/5 text-textSecondary border border-white/5'
                        }`}>
                          {user.role}
                        </span>
                      </td>
                      <td className="py-4 px-6 font-bold text-white">
                        {user.role === 'ORGANIZATION' ? `${user.workspaceQuota} Ws` : '—'}
                      </td>
                      <td className="py-4 px-6">
                        <span className={`inline-block px-3 py-1 rounded-full text-[10px] font-bold tracking-wider ${
                          user.suspended 
                            ? 'bg-accentRose/15 text-accentRose border border-accentRose/20' 
                            : 'bg-green/15 text-green border border-green/20'
                        }`}>
                          {user.suspended ? 'SUSPENDED' : 'ACTIVE'}
                        </span>
                      </td>
                      <td className="py-4 px-6 text-right space-x-2">
                        {/* Status Toggle Button */}
                        <button
                          onClick={() => handleToggleSuspend(user)}
                          title={user.suspended ? 'Activate Account' : 'Suspend Account'}
                          className={`p-2 rounded-xl border transition-all ${
                            user.suspended 
                              ? 'border-green/30 text-green hover:bg-green/10' 
                              : 'border-accentRose/30 text-accentRose hover:bg-accentRose/10'
                          }`}
                        >
                          {user.suspended ? <UserCheck className="w-4 h-4" /> : <UserX className="w-4 h-4" />}
                        </button>

                        {/* Quota Button (Only relevant for Organizations) */}
                        {user.role === 'ORGANIZATION' && (
                          <button
                            onClick={() => {
                              setSelectedUser(user);
                              setNewQuota(user.workspaceQuota);
                              setQuotaModalOpen(true);
                            }}
                            title="Update Workspace Quota"
                            className="p-2 rounded-xl border border-accentPurple/30 text-accentPurple hover:bg-accentPurple/10 transition-all"
                          >
                            <Sliders className="w-4 h-4" />
                          </button>
                        )}

                        {/* Force Reset Password Button */}
                        <button
                          onClick={() => {
                            setSelectedUser(user);
                            setResetPassModalOpen(true);
                          }}
                          title="Force Password Reset"
                          className="p-2 rounded-xl border border-white/10 text-textSecondary hover:bg-white/5 transition-all"
                        >
                          <KeyRound className="w-4 h-4" />
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}

          {/* Pagination */}
          {totalPages > 1 && (
            <div className="flex items-center justify-between px-6 py-4 border-t border-borderDark bg-black/20">
              <div className="text-xs text-textSecondary font-medium">
                Showing page {page + 1} of {totalPages} ({totalElements} accounts)
              </div>
              <div className="flex gap-2">
                <button
                  disabled={page === 0}
                  onClick={() => setPage(page - 1)}
                  className="p-2 rounded-xl border border-borderDark text-textSecondary hover:text-white disabled:opacity-30 disabled:cursor-not-allowed transition-all"
                >
                  <ChevronLeft className="w-5 h-5" />
                </button>
                <button
                  disabled={page === totalPages - 1}
                  onClick={() => setPage(page + 1)}
                  className="p-2 rounded-xl border border-borderDark text-textSecondary hover:text-white disabled:opacity-30 disabled:cursor-not-allowed transition-all"
                >
                  <ChevronRight className="w-5 h-5" />
                </button>
              </div>
            </div>
          )}
        </div>

        {/* Modal: Quota Modification */}
        {quotaModalOpen && selectedUser && (
          <div className="fixed inset-0 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm z-50 animate-fadeIn">
            <div className="glass-panel w-full max-w-md p-6 rounded-3xl border border-white/5 relative">
              <button 
                onClick={() => { setQuotaModalOpen(false); setSelectedUser(null); }}
                className="absolute top-4 right-4 text-textSecondary hover:text-white"
              >
                <X className="w-5 h-5" />
              </button>

              <h4 className="text-lg font-bold text-white mb-2">Modify Workspace Quota</h4>
              <p className="text-xs text-textSecondary mb-4">
                Update the maximum active workspaces allowed for organization <strong className="text-accentPurple">{selectedUser.name}</strong>.
              </p>

              {modalMessage && (
                <div className="bg-accentRose/15 border border-accentRose/30 p-3 rounded-xl text-accentRose text-xs font-semibold mb-4">
                  {modalMessage}
                </div>
              )}

              <div className="space-y-4">
                <div className="space-y-2">
                  <label className="text-xs font-bold text-textSecondary uppercase tracking-wider block">Quota limit (Workspaces)</label>
                  <input
                    type="number"
                    min={0}
                    value={newQuota}
                    onChange={(e) => setNewQuota(parseInt(e.target.value) || 0)}
                    className="w-full bg-black/40 border border-borderDark px-4 py-3 rounded-2xl text-sm text-textPrimary focus:outline-none focus:border-accentPurple transition-all"
                  />
                </div>

                <button
                  onClick={handleSaveQuota}
                  disabled={modalLoading}
                  className="w-full bg-accentPurple text-white py-3 rounded-2xl font-extrabold text-sm uppercase tracking-wider hover:opacity-90 transition-all flex items-center justify-center gap-2"
                >
                  {modalLoading ? <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div> : "Apply Changes"}
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Modal: Password Reset */}
        {resetPassModalOpen && selectedUser && (
          <div className="fixed inset-0 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm z-50">
            <div className="glass-panel w-full max-w-md p-6 rounded-3xl border border-white/5 relative">
              <button 
                onClick={() => { setResetPassModalOpen(false); setSelectedUser(null); }}
                className="absolute top-4 right-4 text-textSecondary hover:text-white"
              >
                <X className="w-5 h-5" />
              </button>

              <h4 className="text-lg font-bold text-white mb-2">Force Password Reset</h4>
              <p className="text-xs text-textSecondary mb-4">
                Override security credentials and set a new password for account <strong className="text-accentPurple">{selectedUser.email}</strong>.
              </p>

              {modalMessage && (
                <div className="bg-accentRose/15 border border-accentRose/30 p-3 rounded-xl text-accentRose text-xs font-semibold mb-4">
                  {modalMessage}
                </div>
              )}

              <div className="space-y-4">
                <div className="space-y-2">
                  <label className="text-xs font-bold text-textSecondary uppercase tracking-wider block">New Password</label>
                  <input
                    type="password"
                    value={newPassword}
                    onChange={(e) => setNewPassword(e.target.value)}
                    placeholder="Enter at least 6 characters"
                    className="w-full bg-black/40 border border-borderDark px-4 py-3 rounded-2xl text-sm text-textPrimary placeholder:text-textSecondary/50 focus:outline-none focus:border-accentPurple transition-all"
                  />
                </div>

                <button
                  onClick={handleResetPassword}
                  disabled={modalLoading || newPassword.length < 6}
                  className="w-full bg-accentPurple text-white py-3 rounded-2xl font-extrabold text-sm uppercase tracking-wider hover:opacity-90 transition-all flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {modalLoading ? <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div> : "Reset Credentials"}
                </button>
              </div>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}
