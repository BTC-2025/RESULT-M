"use client";

import { useState, useEffect, ReactNode } from "react";
import { api, clearAuthToken } from "@/lib/api";
import { useRouter } from "next/navigation";
import EditProfileDrawer from "@/components/profile/EditProfileDrawer";
import FollowersModal from "@/components/profile/FollowersModal";
import CreatePostModal from "@/components/feed/CreatePostModal";
import Link from "next/link";

type Tab = "posts" | "followers" | "following" | "about";

interface UserProfile {
  id: string;
  name: string;
  email: string;
  phoneNumber?: string;
  role?: string;
  bio?: string;
  website?: string;
  city?: string;
  profilePictureBase64?: string;
  coverPictureBase64?: string;
  organizationType?: string;
  followerCount?: number;
  followingCount?: number;
  postCount?: number;
}

const fmtNum = (n: number) =>
  n >= 1_000_000 ? `${(n / 1_000_000).toFixed(1)}M` : n >= 1000 ? `${(n / 1000).toFixed(1)}K` : String(n);

const GRADIENTS = [
  "from-violet-600 to-indigo-700",
  "from-rose-500 to-pink-700",
  "from-amber-500 to-orange-700",
  "from-emerald-500 to-teal-700",
  "from-blue-500 to-cyan-700",
];
const pickGradient = (name = "") => GRADIENTS[(name.charCodeAt(0) || 0) % GRADIENTS.length];

/* ─── Profile Completion Meter ────────────────────────── */
function ProfileCompletion({ profile, onEdit }: { profile: UserProfile; onEdit: () => void }) {
  const fields = [
    { label: "Name", done: !!profile.name },
    { label: "Bio", done: !!profile.bio },
    { label: "Photo", done: !!profile.profilePictureBase64 },
    { label: "Website", done: !!profile.website },
    { label: "Phone", done: !!profile.phoneNumber },
    { label: "City", done: !!profile.city },
  ];
  const done = fields.filter(f => f.done).length;
  const pct = Math.round((done / fields.length) * 100);
  if (pct === 100) return null;

  return (
    <div className="bg-white border border-zinc-100 rounded-2xl overflow-hidden shadow-sm">
      <div className="p-5">
        <div className="flex items-center justify-between mb-3">
          <div>
            <p className="text-sm font-black text-zinc-900">Complete your profile</p>
            <p className="text-xs text-zinc-400 mt-0.5">{done} of {fields.length} fields filled</p>
          </div>
          <div className="w-12 h-12 rounded-xl bg-[#635BFF]/10 flex items-center justify-center">
            <span className="text-sm font-black text-[#635BFF]">{pct}%</span>
          </div>
        </div>
        {/* Bar */}
        <div className="h-2 bg-zinc-100 rounded-full overflow-hidden mb-4">
          <div
            className="h-full bg-gradient-to-r from-[#635BFF] to-violet-500 rounded-full transition-all duration-700"
            style={{ width: `${pct}%` }}
          />
        </div>
        {/* Missing items */}
        <div className="flex flex-wrap gap-2">
          {fields.filter(f => !f.done).map(f => (
            <button
              key={f.label}
              onClick={onEdit}
              className="flex items-center gap-1 px-2.5 py-1 bg-zinc-50 border border-zinc-200 rounded-full text-[11px] font-bold text-zinc-500 hover:border-[#635BFF] hover:text-[#635BFF] hover:bg-[#635BFF]/5 transition-all"
            >
              <svg width="9" height="9" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
              {f.label}
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}



/* ─── Inline followers ──────────────────────────────── */
function FollowInline({ userId, mode }: { userId: string; mode: "followers" | "following" }) {
  const [users, setUsers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    (mode === "followers" ? api.users.getFollowers(userId) : api.users.getFollowing(userId))
      .then(d => setUsers(d || []))
      .catch(() => {})
      .finally(() => setLoading(false));
  }, [userId, mode]);

  if (loading) return (
    <div className="space-y-3 animate-pulse p-4">
      {[1,2,3].map(i => (
        <div key={i} className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-full bg-zinc-200 shrink-0" />
          <div className="flex-1 space-y-1.5"><div className="h-3 bg-zinc-200 rounded-full w-2/5" /><div className="h-2.5 bg-zinc-100 rounded-full w-1/3" /></div>
        </div>
      ))}
    </div>
  );
  if (users.length === 0) return (
    <div className="flex flex-col items-center py-10 text-center px-4">
      <div className="w-12 h-12 rounded-2xl bg-zinc-50 border border-zinc-100 flex items-center justify-center mb-3">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" className="text-zinc-300"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
      </div>
      <p className="text-sm font-bold text-zinc-400">No {mode} yet</p>
      <p className="text-xs text-zinc-300 mt-1">When people {mode === "followers" ? "follow you" : "are followed by you"}, they appear here</p>
    </div>
  );
  return (
    <div className="divide-y divide-zinc-50">
      {users.map(u => {
        const init = u.name?.split(" ").map((w: string) => w[0]).join("").slice(0, 2).toUpperCase() || "?";
        return (
          <Link key={u.id} href={`/profile/${u.id}`} className="flex items-center gap-3 px-4 py-3.5 hover:bg-zinc-50/80 transition-colors group">
            <div className={`w-10 h-10 rounded-full overflow-hidden bg-gradient-to-br ${pickGradient(u.name)} text-white font-black text-sm flex items-center justify-center shrink-0`}>
              {u.profilePictureBase64 ? <img src={`data:image/jpeg;base64,${u.profilePictureBase64}`} className="w-full h-full object-cover" alt="" /> : init}
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-sm font-bold text-zinc-800 truncate group-hover:text-[#635BFF] transition-colors">{u.name}</p>
              {u.bio && <p className="text-xs text-zinc-400 truncate">{u.bio}</p>}
            </div>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" className="text-zinc-200 group-hover:text-[#635BFF] transition-colors shrink-0"><polyline points="9 18 15 12 9 6"/></svg>
          </Link>
        );
      })}
    </div>
  );
}

/* ─── Skeleton ─────────────────────────────────────── */
function Skeleton() {
  return (
    <div className="w-full animate-pulse -mx-2 sm:-mx-4 lg:-mx-6">
      <div className="h-56 lg:h-72 w-full bg-zinc-200" />
      <div className="max-w-[1100px] mx-auto px-4 lg:px-8">
        <div className="flex items-end gap-4 -mt-16 mb-6">
          <div className="w-32 h-32 rounded-full bg-zinc-300 ring-4 ring-white shrink-0" />
          <div className="flex-1 pb-2 space-y-2">
            <div className="h-6 w-52 bg-zinc-200 rounded-full" /><div className="h-4 w-36 bg-zinc-100 rounded-full" />
          </div>
          <div className="w-32 h-10 bg-zinc-200 rounded-full shrink-0 mb-2" />
        </div>
        <div className="grid grid-cols-1 lg:grid-cols-[280px_1fr] gap-6">
          <div className="space-y-3">{[1,2,3,4].map(i => <div key={i} className="h-14 bg-zinc-100 rounded-2xl" />)}</div>
          <div className="space-y-3">{[1,2,3].map(i => <div key={i} className="h-24 bg-zinc-100 rounded-2xl" />)}</div>
        </div>
      </div>
    </div>
  );
}

/* ─── Main ─────────────────────────────────────────── */
export default function ProfilePage() {
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [tab, setTab] = useState<Tab>("posts");
  const [editOpen, setEditOpen] = useState(false);
  const [followModal, setFollowModal] = useState<{ open: boolean; mode: "followers" | "following" }>({ open: false, mode: "followers" });
  const [createPostOpen, setCreatePostOpen] = useState(false);
  const [settingsOpen, setSettingsOpen] = useState(false);
  const router = useRouter();

  const handleSignOut = () => {
    clearAuthToken();
    router.push("/login");
  };

  useEffect(() => {
    api.users.getMe()
      .then(d => setProfile(d))
      .catch(() => setError("Failed to load profile."))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <Skeleton />;
  if (error || !profile) return (
    <div className="flex flex-col items-center justify-center min-h-[60vh] gap-4">
      <p className="text-base font-bold text-zinc-600">{error || "Profile not found."}</p>
      <button onClick={() => window.location.reload()} className="px-6 py-2 bg-[#635BFF] text-white text-sm font-bold rounded-full">Retry</button>
    </div>
  );

  const gr = pickGradient(profile.name);
  const initials = profile.name?.trim().split(" ").map(w => w[0]).join("").slice(0, 2).toUpperCase() || "?";
  const followerCount = profile.followerCount ?? 0;
  const followingCount = profile.followingCount ?? 0;
  const postCount = profile.postCount ?? 0;

  const TABS: { key: Tab; label: string; count?: number }[] = [
    { key: "posts", label: "Posts" },
    { key: "followers", label: "Followers", count: followerCount },
    { key: "following", label: "Following", count: followingCount },
    { key: "about", label: "About" },
  ];

  return (
    <div className="w-full min-h-screen -mx-2 sm:-mx-4 lg:-mx-6">

      {/* ══════════════════════════════════════
          COVER — Rich, Content-filled Banner
          ══════════════════════════════════════ */}
      <div className="relative w-full h-56 lg:h-72 overflow-hidden bg-zinc-900 group">
        {profile.coverPictureBase64 ? (
          <img
            src={`data:image/jpeg;base64,${profile.coverPictureBase64}`}
            alt="Cover"
            className="absolute inset-0 w-full h-full object-cover opacity-80"
          />
        ) : (
          <>
            {/* Base gradient fallback */}
            <div className="absolute inset-0 bg-gradient-to-br from-[#1a1060] via-[#3b2aa0] to-[#635BFF]" />

            {/* Animated radial glows */}
            <div className="absolute top-0 left-0 w-80 h-80 bg-violet-500/30 rounded-full blur-3xl -translate-x-1/3 -translate-y-1/3" />
            <div className="absolute bottom-0 right-0 w-96 h-96 bg-indigo-400/20 rounded-full blur-3xl translate-x-1/4 translate-y-1/4" />
            <div className="absolute top-1/2 left-1/2 w-64 h-64 bg-purple-600/20 rounded-full blur-2xl -translate-x-1/2 -translate-y-1/2" />

            {/* Dot grid pattern */}
            <div className="absolute inset-0 opacity-20" style={{
              backgroundImage: "radial-gradient(circle, rgba(255,255,255,0.4) 1px, transparent 1px)",
              backgroundSize: "28px 28px"
            }} />

            {/* Diagonal stripes */}
            <div className="absolute inset-0 opacity-5" style={{
              backgroundImage: "repeating-linear-gradient(45deg, white 0px, white 1px, transparent 1px, transparent 20px)"
            }} />
          </>
        )}

        {/* Content — positioned in TOP half so avatar ring never covers it */}
        <div className="absolute inset-x-0 top-0 h-[60%] flex flex-col justify-center px-6 lg:px-10">
          <div className="flex items-start justify-between gap-4">
            {/* Name + meta block */}
            <div className="min-w-0">
              <div className="flex items-center gap-2 mb-2 flex-wrap">
                <span className={`px-2.5 py-0.5 rounded-full text-[11px] font-black uppercase tracking-widest ring-1 ring-white/20 backdrop-blur-sm ${
                  profile.role === "ORGANIZATION" ? "bg-amber-400/90 text-amber-900" :
                  profile.role === "ADMIN" ? "bg-red-500/90 text-white" : "bg-white/15 text-white"
                }`}>
                  {profile.role || "User"}
                </span>
                {profile.city && (
                  <span className="flex items-center gap-1 text-white/60 text-xs font-medium">
                    <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><path d="M12 22s8-4.5 8-11.8A8 8 0 0 0 4 10.2C4 17.5 12 22 12 22z"/><circle cx="12" cy="10" r="3"/></svg>
                    {profile.city}
                  </span>
                )}
              </div>
              <h1 className="text-2xl lg:text-4xl font-black text-white tracking-tight drop-shadow-lg leading-tight truncate">
                {profile.name}
              </h1>
              {profile.bio && (
                <p className="text-white/60 text-sm mt-1.5 max-w-lg line-clamp-1 font-medium">{profile.bio}</p>
              )}
            </div>

            {/* Floating mini stats — top-right of cover */}
            <div className="hidden lg:flex items-center gap-3 shrink-0">
              {[
                { val: "0", label: "Posts" },
                { val: fmtNum(followerCount), label: "Followers" },
                { val: fmtNum(followingCount), label: "Following" },
              ].map(s => (
                <div key={s.label} className="text-center bg-white/10 backdrop-blur-sm border border-white/10 rounded-xl px-4 py-2.5">
                  <div className="text-xl font-black text-white tabular-nums">{s.val}</div>
                  <div className="text-[10px] text-white/50 font-semibold uppercase tracking-wider">{s.label}</div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Subtle bottom fade so avatar blends in */}
        <div className="absolute bottom-0 left-0 right-0 h-20 bg-gradient-to-t from-black/60 to-transparent" />

        {/* Top-right edit cover hint (only visible to owner) */}
        <div className="absolute top-4 right-4 opacity-0 group-hover:opacity-100 transition-opacity">
          <button
            onClick={() => setEditOpen(true)}
            className="flex items-center gap-1.5 px-3 py-1.5 bg-black/40 hover:bg-black/60 backdrop-blur-sm border border-white/10 rounded-full text-white text-xs font-bold transition-all shadow-lg"
          >
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/><circle cx="12" cy="13" r="4"/></svg>
            Edit Cover
          </button>
        </div>
      </div>

      {/* ══════════════════════════════════════
          AVATAR ROW
          ══════════════════════════════════════ */}
      <div className="max-w-[1100px] mx-auto px-4 lg:px-8">
        <div className="flex flex-col sm:flex-row sm:items-end gap-4 -mt-14 mb-0 relative z-10">

          {/* Avatar */}
          <div className="relative shrink-0 self-start sm:self-auto">
            <div className={`w-28 h-28 lg:w-32 lg:h-32 rounded-full overflow-hidden bg-gradient-to-br ${gr} text-white font-black text-4xl flex items-center justify-center ring-[5px] ring-white shadow-2xl`}>
              {profile.profilePictureBase64
                ? <img src={`data:image/jpeg;base64,${profile.profilePictureBase64}`} className="w-full h-full object-cover" alt="" />
                : <span>{initials}</span>}
            </div>
            {/* Online indicator */}
            <div className="absolute bottom-2 right-2 w-4 h-4 bg-emerald-400 rounded-full ring-2 ring-white" />
          </div>

          {/* Name row desktop (hidden on mobile since it's on cover) */}
          <div className="flex-1 min-w-0 pb-1 mt-1 sm:mt-0 lg:hidden">
            <h1 className="text-xl font-black text-zinc-900 tracking-tight">{profile.name}</h1>
            <p className="text-sm text-zinc-500 font-medium">{profile.email}</p>
          </div>
          <div className="hidden lg:block flex-1" />

          {/* Action */}
          <div className="shrink-0 pb-1 flex gap-2 relative">
            <button
              onClick={() => setEditOpen(true)}
              className="flex items-center gap-2 px-5 py-2.5 rounded-full bg-white border-2 border-zinc-200 text-sm font-bold text-zinc-700 hover:border-[#635BFF] hover:text-[#635BFF] hover:bg-[#635BFF]/5 transition-all shadow-sm"
            >
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
              Edit Profile
            </button>
            <button
              onClick={() => setSettingsOpen(!settingsOpen)}
              className="w-[42px] h-[42px] flex items-center justify-center rounded-full bg-white border-2 border-zinc-200 text-zinc-700 hover:border-[#635BFF] hover:text-[#635BFF] hover:bg-[#635BFF]/5 transition-all shadow-sm"
            >
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>
            </button>
            {settingsOpen && (
              <>
                {/* Invisible overlay to click out of dropdown */}
                <div className="fixed inset-0 z-40" onClick={() => setSettingsOpen(false)} />
                <div className="absolute top-[52px] right-0 w-48 bg-white border border-zinc-100 rounded-xl shadow-lg py-1.5 z-50 overflow-hidden">
                  <button
                    onClick={handleSignOut}
                    className="w-full flex items-center gap-2.5 px-4 py-2.5 text-sm font-bold text-red-600 hover:bg-red-50 transition-colors text-left"
                  >
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path><polyline points="16 17 21 12 16 7"></polyline><line x1="21" y1="12" x2="9" y2="12"></line></svg>
                    Sign Out
                  </button>
                </div>
              </>
            )}
          </div>
        </div>

        {/* ══════════════════════════════════════
            STATS + TABS BAR
            ══════════════════════════════════════ */}
        <div className="flex items-center mt-4 border-b border-zinc-100 overflow-x-auto hide-scrollbar">
          {/* Mobile stats */}
          <div className="flex items-center gap-5 mr-6 lg:hidden shrink-0">
            {[
              { val: fmtNum(postCount), label: "Posts", fn: undefined },
              { val: fmtNum(followerCount), label: "Followers", fn: () => setFollowModal({ open: true, mode: "followers" }) },
              { val: fmtNum(followingCount), label: "Following", fn: () => setFollowModal({ open: true, mode: "following" }) },
            ].map(s => (
              <button key={s.label} onClick={s.fn} className="flex items-baseline gap-1 py-3.5 group shrink-0">
                <span className="text-lg font-black text-zinc-900 tabular-nums group-hover:text-[#635BFF] transition-colors">{s.val}</span>
                <span className="text-[11px] font-semibold text-zinc-400 uppercase tracking-wider">{s.label}</span>
              </button>
            ))}
          </div>

          {/* Tabs */}
          <div className="flex items-center gap-0 flex-1">
            {TABS.map(t => (
              <button
                key={t.key}
                onClick={() => setTab(t.key)}
                className={`relative px-4 py-3.5 text-sm font-bold transition-colors whitespace-nowrap shrink-0 ${tab === t.key ? "text-[#635BFF]" : "text-zinc-500 hover:text-zinc-900"}`}
              >
                {t.label}
                {t.count !== undefined && t.count > 0 && (
                  <span className="ml-1.5 text-[11px] font-black bg-zinc-100 text-zinc-500 px-1.5 py-0.5 rounded-full">{fmtNum(t.count)}</span>
                )}
                {tab === t.key && <span className="absolute bottom-0 left-2 right-2 h-[2px] bg-[#635BFF] rounded-t-full" />}
              </button>
            ))}
          </div>
        </div>

        {/* ══════════════════════════════════════
            BODY GRID
            ══════════════════════════════════════ */}
        <div className="grid grid-cols-1 lg:grid-cols-[280px_1fr] gap-5 py-5 items-stretch">

          {/* ── LEFT PANEL (sticky) ───────────── */}
          <div className="lg:sticky lg:top-5 flex flex-col gap-4 h-full">

            {/* About card */}
            <div className="bg-white border border-zinc-100 rounded-2xl overflow-hidden shadow-sm">
              <div className="px-4 py-3 border-b border-zinc-50 flex items-center justify-between">
                <p className="text-xs font-black text-zinc-400 uppercase tracking-widest">About</p>
                <button onClick={() => setEditOpen(true)} className="text-[11px] font-bold text-[#635BFF] hover:underline">Edit</button>
              </div>
              <div className="p-4 space-y-2.5">
                {profile.bio ? (
                  <p className="text-sm text-zinc-700 leading-relaxed">{profile.bio}</p>
                ) : (
                  <button onClick={() => setEditOpen(true)} className="flex items-center gap-1.5 text-sm text-zinc-400 hover:text-[#635BFF] transition-colors italic">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    Add a bio
                  </button>
                )}
                <div className="pt-1 space-y-2">
                  <InfoRow icon="mail" val={profile.email} />
                  {profile.website && <InfoRow icon="globe" val={profile.website} isLink />}
                  {profile.city && <InfoRow icon="pin" val={profile.city} />}
                  {profile.phoneNumber && <InfoRow icon="phone" val={profile.phoneNumber} />}
                </div>
                {!profile.website && (
                  <button onClick={() => setEditOpen(true)} className="text-[11px] text-zinc-400 hover:text-[#635BFF] font-semibold transition-colors">
                    + Add website, city, phone...
                  </button>
                )}
              </div>
            </div>

            {/* Profile Completion */}
            <ProfileCompletion profile={profile} onEdit={() => setEditOpen(true)} />

            {/* Followers mini */}
            <div className="bg-white border border-zinc-100 rounded-2xl overflow-hidden shadow-sm flex flex-col flex-1">
              <div className="px-4 py-3 border-b border-zinc-50 flex items-center justify-between shrink-0">
                <p className="text-xs font-black text-zinc-400 uppercase tracking-widest">Followers</p>
                <button onClick={() => setFollowModal({ open: true, mode: "followers" })} className="text-[11px] font-bold text-[#635BFF] hover:underline">See all</button>
              </div>
              <div className="flex-1">
                {profile.id && <FollowInline userId={profile.id} mode="followers" />}
              </div>
            </div>
          </div>

          {/* ── RIGHT PANEL ─────────────────────── */}
          <div className="min-w-0 flex flex-col h-full gap-4">

            {/* POSTS TAB */}
            {tab === "posts" && (
              <>
                {/* Get started hero */}
                <div className="relative bg-[#2D248A] rounded-2xl overflow-hidden shadow-lg">
                  <div className="absolute inset-0 opacity-10" style={{ backgroundImage: "radial-gradient(circle, rgba(255,255,255,0.5) 1px, transparent 1px)", backgroundSize: "20px 20px" }} />
                  <div className="relative z-10 p-6 lg:p-8 flex flex-col sm:flex-row items-center sm:items-start gap-6">
                    <div className="w-16 h-16 rounded-2xl bg-white/15 backdrop-blur-sm border border-white/20 flex items-center justify-center shrink-0">
                      <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="1.5">
                        <path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/>
                      </svg>
                    </div>
                    <div className="text-center sm:text-left">
                      <h3 className="text-xl font-black text-white">Start sharing with the community</h3>
                      <p className="text-white/70 text-sm mt-1.5 leading-relaxed max-w-sm">
                        Post complaints, polls, or updates. Your voice reaches thousands of people on ResultHub.
                      </p>
                      <div className="flex flex-wrap gap-3 mt-5 justify-center sm:justify-start">
                        <button onClick={() => setCreatePostOpen(true)} className="inline-flex items-center gap-2 px-5 py-2.5 bg-white text-[#2D248A] text-sm font-black rounded-full hover:bg-zinc-100 transition-colors shadow-lg">
                          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                          Create Post
                        </button>
                        <Link href="/" className="inline-flex items-center gap-2 px-5 py-2.5 bg-white/15 text-white text-sm font-bold rounded-full hover:bg-white/25 transition-colors border border-white/20">
                          Explore Feed
                        </Link>
                      </div>
                    </div>
                  </div>
                </div>

                <div className="bg-white border border-zinc-100 rounded-2xl shadow-sm overflow-hidden flex flex-col flex-1">
                  <div className="px-5 py-4 border-b border-zinc-50 shrink-0">
                    <p className="text-sm font-black text-zinc-800">Your Activity Overview</p>
                    <p className="text-xs text-zinc-400 mt-0.5">Stats update as you engage with the platform</p>
                  </div>
                  <div className="grid grid-cols-2 divide-zinc-100 divide-x divide-y flex-1">
                    {[
                      {
                        label: "Posts", val: fmtNum(postCount),
                        color: "bg-violet-50 text-[#635BFF]",
                        icon: <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                      },
                      {
                        label: "Followers", val: fmtNum(followerCount),
                        color: "bg-blue-50 text-blue-500",
                        icon: <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                      },
                      {
                        label: "Following", val: fmtNum(followingCount),
                        color: "bg-emerald-50 text-emerald-500",
                        icon: <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><line x1="19" y1="8" x2="19" y2="14"/><line x1="22" y1="11" x2="16" y2="11"/></svg>
                      },
                      {
                        label: "Upvotes", val: "0",
                        color: "bg-amber-50 text-amber-500",
                        icon: <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M14 9V5a3 3 0 0 0-3-3l-4 9v11h11.28a2 2 0 0 0 2-1.7l1.38-9a2 2 0 0 0-2-2.3H14z"/><path d="M7 22H4a2 2 0 0 1-2-2v-7a2 2 0 0 1 2-2h3"/></svg>
                      },
                    ].map(s => (
                      <div key={s.label} className="flex flex-col items-center justify-center gap-3 py-5 px-4">
                        <div className={`w-12 h-12 rounded-2xl ${s.color} flex items-center justify-center shadow-sm`}>
                          {s.icon}
                        </div>
                        <div className="text-center">
                          <div className="text-3xl font-black text-zinc-900 tabular-nums leading-none">{s.val}</div>
                          <div className="text-[11px] font-bold text-zinc-400 uppercase tracking-widest mt-1.5">{s.label}</div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </>
            )}

            {/* FOLLOWERS TAB */}
            {tab === "followers" && profile.id && (
              <div className="bg-white border border-zinc-100 rounded-2xl shadow-sm overflow-hidden">
                <div className="px-5 py-4 border-b border-zinc-50 flex items-center justify-between">
                  <div>
                    <h3 className="text-sm font-black text-zinc-800">People who follow you</h3>
                    <p className="text-xs text-zinc-400 mt-0.5">{fmtNum(followerCount)} follower{followerCount !== 1 ? "s" : ""}</p>
                  </div>
                </div>
                <FollowInline userId={profile.id} mode="followers" />
              </div>
            )}

            {/* FOLLOWING TAB */}
            {tab === "following" && profile.id && (
              <div className="bg-white border border-zinc-100 rounded-2xl shadow-sm overflow-hidden">
                <div className="px-5 py-4 border-b border-zinc-50">
                  <h3 className="text-sm font-black text-zinc-800">People you follow</h3>
                  <p className="text-xs text-zinc-400 mt-0.5">{fmtNum(followingCount)} account{followingCount !== 1 ? "s" : ""}</p>
                </div>
                <FollowInline userId={profile.id} mode="following" />
              </div>
            )}

            {/* ABOUT TAB */}
            {tab === "about" && (
              <div className="space-y-4">
                <div className="bg-white border border-zinc-100 rounded-2xl shadow-sm overflow-hidden">
                  <div className="px-5 py-4 border-b border-zinc-50 flex items-center justify-between">
                    <h3 className="text-sm font-black text-zinc-800">About Me</h3>
                    <button onClick={() => setEditOpen(true)} className="text-xs font-bold text-[#635BFF] hover:underline">Edit</button>
                  </div>
                  {profile.bio && (
                    <div className="px-5 py-4 border-b border-zinc-50">
                      <p className="text-sm text-zinc-700 leading-relaxed">{profile.bio}</p>
                    </div>
                  )}
                  <div className="p-5 grid grid-cols-1 sm:grid-cols-2 gap-3">
                    {[
                      { icon: "mail", label: "Email", val: profile.email },
                      { icon: "role", label: "Account Type", val: profile.role },
                      { icon: "phone", label: "Phone", val: profile.phoneNumber },
                      { icon: "globe", label: "Website", val: profile.website, isLink: true },
                      { icon: "pin", label: "City", val: profile.city },
                    ].filter(r => r.val).map(row => (
                      <div key={row.label} className="flex items-center gap-3 p-3.5 bg-zinc-50 rounded-xl border border-zinc-100">
                        <div className="w-9 h-9 rounded-xl bg-white border border-zinc-200 flex items-center justify-center shrink-0 shadow-sm">
                          <AboutIcon type={row.icon} />
                        </div>
                        <div className="min-w-0 flex-1">
                          <p className="text-[10px] text-zinc-400 font-bold uppercase tracking-wider">{row.label}</p>
                          {row.isLink ? (
                            <a href={row.val} target="_blank" rel="noopener noreferrer" className="text-sm font-semibold text-[#635BFF] hover:underline truncate block mt-0.5">
                              {row.val!.replace(/^https?:\/\//, "")}
                            </a>
                          ) : (
                            <p className="text-sm font-semibold text-zinc-800 mt-0.5 truncate">{row.val}</p>
                          )}
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Edit Drawer */}
      {profile && (
        <EditProfileDrawer
          isOpen={editOpen}
          onClose={() => setEditOpen(false)}
          profile={profile}
          onSaved={p => setProfile(p)}
        />
      )}

      {/* Followers Modal */}
      {profile && (
        <FollowersModal
          isOpen={followModal.open}
          onClose={() => setFollowModal(p => ({ ...p, open: false }))}
          userId={profile.id}
          mode={followModal.mode}
          title={followModal.mode === "followers" ? `Followers (${fmtNum(followerCount)})` : `Following (${fmtNum(followingCount)})`}
        />
      )}

      {/* Create Post Modal */}
      <CreatePostModal
        isOpen={createPostOpen}
        onClose={() => setCreatePostOpen(false)}
      />
    </div>
  );
}

/* ─── Info Row helper ───────────────────────────────── */
function InfoRow({ icon, val, isLink = false }: { icon: string; val: string; isLink?: boolean }) {
  const icons: Record<string, ReactNode> = {
    mail: <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" className="text-zinc-400"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>,
    globe: <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" className="text-zinc-400"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>,
    pin: <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" className="text-zinc-400"><path d="M12 22s8-4.5 8-11.8A8 8 0 0 0 4 10.2C4 17.5 12 22 12 22z"/><circle cx="12" cy="10" r="3"/></svg>,
    phone: <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" className="text-zinc-400"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 13.1 19.79 19.79 0 0 1 1.61 4.5 2 2 0 0 1 3.58 2.4h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L7.91 10a16 16 0 0 0 6.1 6.1l1.96-1.96a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg>,
  };
  return (
    <div className="flex items-center gap-2">
      <span className="shrink-0">{icons[icon]}</span>
      {isLink ? (
        <a href={val} target="_blank" rel="noopener noreferrer" className="text-xs font-semibold text-[#635BFF] hover:underline truncate">{val.replace(/^https?:\/\//, "")}</a>
      ) : (
        <span className="text-xs font-medium text-zinc-500 truncate">{val}</span>
      )}
    </div>
  );
}

/* ─── About Icon helper ─────────────────────────────── */
function AboutIcon({ type }: { type: string }) {
  const cls = "text-zinc-500";
  const icons: Record<string, ReactNode> = {
    mail: <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" className={cls}><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>,
    phone: <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" className={cls}><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 13.1 19.79 19.79 0 0 1 1.61 4.5 2 2 0 0 1 3.58 2.4h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L7.91 10a16 16 0 0 0 6.1 6.1l1.96-1.96a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg>,
    globe: <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" className={cls}><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>,
    pin: <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" className={cls}><path d="M12 22s8-4.5 8-11.8A8 8 0 0 0 4 10.2C4 17.5 12 22 12 22z"/><circle cx="12" cy="10" r="3"/></svg>,
    role: <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" className={cls}><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>,
  };
  return icons[type] || icons.mail;
}
