"use client";

import { useState, useEffect } from "react";
import { api } from "@/lib/api";
import Link from "next/link";

interface FollowUser {
  id: string;
  name: string;
  profilePictureBase64?: string;
  bio?: string;
  isFollowing: boolean;
}

interface FollowersModalProps {
  isOpen: boolean;
  onClose: () => void;
  userId: string;
  mode: "followers" | "following";
  title: string;
}

function UserRow({ user, onFollowChange }: { user: FollowUser; onFollowChange: (id: string, following: boolean) => void }) {
  const [isFollowing, setIsFollowing] = useState(user.isFollowing);
  const [isLoading, setIsLoading] = useState(false);

  const initials = user.name?.split(" ").map(w => w[0]).join("").slice(0, 2).toUpperCase() || "?";
  const gradients = ["from-violet-500 to-indigo-500", "from-rose-500 to-pink-500", "from-amber-500 to-orange-500", "from-emerald-500 to-teal-500", "from-blue-500 to-cyan-500"];
  const gradient = gradients[user.name?.charCodeAt(0) % gradients.length] || gradients[0];

  const handleToggleFollow = async () => {
    if (isLoading) return;
    setIsLoading(true);
    try {
      if (isFollowing) {
        await api.users.unfollow(user.id);
        setIsFollowing(false);
        onFollowChange(user.id, false);
      } else {
        await api.users.follow(user.id);
        setIsFollowing(true);
        onFollowChange(user.id, true);
      }
    } catch (err) {
      console.error("Follow action failed", err);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="flex items-center gap-3 px-5 py-3.5 hover:bg-zinc-50 transition-colors group">
      <Link href={`/profile/${user.id}`} className="shrink-0">
        <div className={`w-11 h-11 rounded-full overflow-hidden bg-gradient-to-br ${gradient} text-white font-black text-base flex items-center justify-center ring-2 ring-white shadow-sm`}>
          {user.profilePictureBase64 ? (
            <img src={`data:image/jpeg;base64,${user.profilePictureBase64}`} alt={user.name} className="w-full h-full object-cover" />
          ) : initials}
        </div>
      </Link>

      <div className="flex-1 min-w-0">
        <Link href={`/profile/${user.id}`}>
          <p className="text-sm font-bold text-zinc-900 truncate group-hover:text-[#635BFF] transition-colors">{user.name}</p>
        </Link>
        {user.bio && <p className="text-xs text-zinc-500 truncate mt-0.5">{user.bio}</p>}
      </div>

      <button
        onClick={handleToggleFollow}
        disabled={isLoading}
        className={`shrink-0 px-4 py-1.5 rounded-full text-xs font-bold transition-all border ${
          isFollowing
            ? "border-zinc-200 text-zinc-600 hover:border-red-200 hover:text-red-500 hover:bg-red-50"
            : "bg-[#635BFF] text-white border-[#635BFF] hover:bg-[#5249E5]"
        } disabled:opacity-50`}
      >
        {isLoading ? "..." : isFollowing ? "Following" : "Follow"}
      </button>
    </div>
  );
}

export default function FollowersModal({ isOpen, onClose, userId, mode, title }: FollowersModalProps) {
  const [users, setUsers] = useState<FollowUser[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    if (!isOpen || !userId) return;
    const fetchUsers = async () => {
      setIsLoading(true);
      setError("");
      try {
        const data = mode === "followers"
          ? await api.users.getFollowers(userId)
          : await api.users.getFollowing(userId);
        setUsers(data || []);
      } catch (err: any) {
        setError("Failed to load users.");
      } finally {
        setIsLoading(false);
      }
    };
    fetchUsers();
  }, [isOpen, userId, mode]);

  useEffect(() => {
    if (isOpen) document.body.style.overflow = "hidden";
    else document.body.style.overflow = "";
    return () => { document.body.style.overflow = ""; };
  }, [isOpen]);

  const handleFollowChange = (id: string, following: boolean) => {
    setUsers(prev => prev.map(u => u.id === id ? { ...u, isFollowing: following } : u));
  };

  if (!isOpen) return null;

  return (
    <>
      <div className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50" onClick={onClose} />
      <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center p-0 sm:p-4">
        <div className="bg-white w-full sm:w-[440px] rounded-t-3xl sm:rounded-3xl shadow-2xl flex flex-col max-h-[80vh] overflow-hidden">

          {/* Header */}
          <div className="flex items-center justify-between px-5 py-4 border-b border-zinc-100 shrink-0">
            <h3 className="text-base font-black text-zinc-900">{title}</h3>
            <button
              onClick={onClose}
              className="w-8 h-8 rounded-full bg-zinc-100 hover:bg-zinc-200 flex items-center justify-center transition-colors"
            >
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round">
                <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
              </svg>
            </button>
          </div>

          {/* Body */}
          <div className="flex-1 overflow-y-auto">
            {isLoading && (
              <div className="flex flex-col gap-3 p-5">
                {[1, 2, 3, 4].map(i => (
                  <div key={i} className="flex items-center gap-3 animate-pulse">
                    <div className="w-11 h-11 rounded-full bg-zinc-200 shrink-0" />
                    <div className="flex-1 space-y-2">
                      <div className="h-3 bg-zinc-200 rounded-full w-2/3" />
                      <div className="h-2.5 bg-zinc-100 rounded-full w-1/2" />
                    </div>
                    <div className="w-16 h-7 rounded-full bg-zinc-200 shrink-0" />
                  </div>
                ))}
              </div>
            )}

            {!isLoading && error && (
              <div className="p-10 text-center">
                <p className="text-sm text-zinc-500 font-medium">{error}</p>
              </div>
            )}

            {!isLoading && !error && users.length === 0 && (
              <div className="p-10 text-center">
                <div className="w-14 h-14 bg-zinc-100 rounded-full flex items-center justify-center mx-auto mb-4">
                  <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="text-zinc-400">
                    <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>
                  </svg>
                </div>
                <p className="text-sm font-bold text-zinc-600">No {mode} yet</p>
                <p className="text-xs text-zinc-400 mt-1">When people {mode === "followers" ? "follow this account" : "are followed"}, they'll appear here.</p>
              </div>
            )}

            {!isLoading && users.map(user => (
              <UserRow key={user.id} user={user} onFollowChange={handleFollowChange} />
            ))}
          </div>
        </div>
      </div>
    </>
  );
}
