"use client";

import { useState, useEffect } from "react";
import { useParams, useRouter } from "next/navigation";
import { api } from "@/lib/api";
import FollowersModal from "@/components/profile/FollowersModal";
import Link from "next/link";

type Tab = "posts" | "followers" | "following" | "about";

interface PublicProfile {
  id: string;
  name: string;
  profilePictureBase64?: string;
  organizationType?: string;
  bio?: string;
  website?: string;
  followerCount: number;
  followingCount: number;
  postCount: number;
  isFollowing: boolean;
}

/* ─── helpers ─────────────────────────────────────────── */
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

/* ─── skeleton ────────────────────────────────────────── */
function Skeleton() {
  return (
    <div className="w-full animate-pulse">
      <div className="h-56 lg:h-64 w-full bg-zinc-200" />
      <div className="max-w-[1100px] mx-auto px-4 lg:px-8">
        <div className="flex items-end gap-4 -mt-16 mb-6">
          <div className="w-32 h-32 rounded-full bg-zinc-300 ring-4 ring-white shrink-0" />
          <div className="flex-1 pb-2 space-y-2">
            <div className="h-6 w-52 bg-zinc-200 rounded-full" />
            <div className="h-4 w-36 bg-zinc-100 rounded-full" />
          </div>
          <div className="flex gap-2 mb-2">
            <div className="w-28 h-10 bg-zinc-200 rounded-full" />
            <div className="w-10 h-10 bg-zinc-100 rounded-full" />
          </div>
        </div>
        <div className="grid grid-cols-1 lg:grid-cols-[280px_1fr] gap-6">
          <div className="space-y-3">
            {[1,2,3,4].map(i => <div key={i} className="h-10 bg-zinc-100 rounded-2xl" />)}
          </div>
          <div className="space-y-4">
            <div className="h-12 bg-zinc-100 rounded-2xl" />
            {[1,2].map(i => <div key={i} className="h-32 bg-zinc-100 rounded-2xl" />)}
          </div>
        </div>
      </div>
    </div>
  );
}

/* ─── inline followers ──────────────────────────────────  */
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
          <div className="flex-1 space-y-1.5">
            <div className="h-3 bg-zinc-200 rounded-full w-2/5" />
            <div className="h-2.5 bg-zinc-100 rounded-full w-1/3" />
          </div>
        </div>
      ))}
    </div>
  );

  if (users.length === 0) return (
    <div className="flex flex-col items-center py-14 text-center">
      <div className="w-12 h-12 rounded-2xl bg-zinc-100 flex items-center justify-center mb-3">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="text-zinc-300">
          <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/>
        </svg>
      </div>
      <p className="text-sm font-bold text-zinc-400">No {mode} yet</p>
    </div>
  );

  return (
    <div className="divide-y divide-zinc-50">
      {users.map(u => {
        const init = u.name?.split(" ").map((w: string) => w[0]).join("").slice(0, 2).toUpperCase() || "?";
        const gr = pickGradient(u.name);
        return (
          <Link key={u.id} href={`/profile/${u.id}`} className="flex items-center gap-3 px-4 py-3.5 hover:bg-zinc-50 transition-colors group">
            <div className={`w-10 h-10 rounded-full overflow-hidden bg-gradient-to-br ${gr} text-white font-black text-sm flex items-center justify-center shrink-0`}>
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

/* ─── main ────────────────────────────────────────────── */
export default function PublicProfilePage() {
  const params = useParams();
  const router = useRouter();
  const userId = params?.userId as string;

  const [profile, setProfile] = useState<PublicProfile | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [tab, setTab] = useState<Tab>("posts");
  const [isFollowing, setIsFollowing] = useState(false);
  const [followerCount, setFollowerCount] = useState(0);
  const [followLoading, setFollowLoading] = useState(false);
  const [followModal, setFollowModal] = useState<{ open: boolean; mode: "followers" | "following" }>({ open: false, mode: "followers" });
  const [moreOpen, setMoreOpen] = useState(false);

  useEffect(() => {
    if (!userId) return;
    api.users.getProfile(userId)
      .then(d => {
        setProfile(d);
        setIsFollowing(d.isFollowing);
        setFollowerCount(d.followerCount);
      })
      .catch(() => setError("Profile not found."))
      .finally(() => setLoading(false));
  }, [userId]);

  const handleFollow = async () => {
    if (followLoading) return;
    setFollowLoading(true);
    const was = isFollowing;
    setIsFollowing(!was);
    setFollowerCount(p => was ? Math.max(0, p - 1) : p + 1);
    try {
      was ? await api.users.unfollow(userId) : await api.users.follow(userId);
    } catch {
      setIsFollowing(was);
      setFollowerCount(p => was ? p + 1 : Math.max(0, p - 1));
    } finally {
      setFollowLoading(false);
    }
  };

  const handleBlock = async () => {
    if (!confirm("Block this user?")) return;
    try { await api.users.block(userId); router.push("/"); } catch {}
  };

  if (loading) return <Skeleton />;
  if (error || !profile) return (
    <div className="flex flex-col items-center justify-center min-h-[60vh] gap-4">
      <div className="w-16 h-16 rounded-full bg-zinc-100 flex items-center justify-center">
        <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="text-zinc-400"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
      </div>
      <p className="text-base font-bold text-zinc-600">{error || "User not found."}</p>
      <Link href="/" className="px-6 py-2 bg-[#635BFF] text-white text-sm font-bold rounded-full">Go Home</Link>
    </div>
  );

  const gr = pickGradient(profile.name);
  const initials = profile.name?.trim().split(" ").map(w => w[0]).join("").slice(0, 2).toUpperCase() || "?";
  const TABS: { key: Tab; label: string; count?: number }[] = [
    { key: "posts", label: "Posts", count: profile.postCount },
    { key: "followers", label: "Followers", count: followerCount },
    { key: "following", label: "Following", count: profile.followingCount },
    { key: "about", label: "About" },
  ];

  return (
    <div className="w-full min-h-screen -mx-2 sm:-mx-4 lg:-mx-6">

      {/* ═══════════════ COVER ═══════════════ */}
      <div className="relative w-full h-52 lg:h-64 overflow-hidden">
        {/* Dark atmospheric cover — differentiated from own profile */}
        <div className="absolute inset-0 bg-gradient-to-br from-zinc-900 via-zinc-800 to-zinc-900" />
        <div className="absolute inset-0 opacity-40" style={{ backgroundImage: "radial-gradient(ellipse at 20% 80%, rgba(99,91,255,0.5) 0%, transparent 55%), radial-gradient(ellipse at 80% 20%, rgba(139,92,246,0.4) 0%, transparent 50%)" }} />
        <div className="absolute inset-0" style={{ backgroundImage: "linear-gradient(rgba(255,255,255,0.02) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.02) 1px, transparent 1px)", backgroundSize: "32px 32px" }} />
        <div className="absolute bottom-0 left-0 right-0 h-24 bg-gradient-to-t from-black/30 to-transparent" />
      </div>

      {/* ═══════════════ AVATAR ROW ═══════════════ */}
      <div className="max-w-[1100px] mx-auto px-4 lg:px-8">
        <div className="flex flex-col sm:flex-row sm:items-end gap-4 -mt-16 mb-0 relative z-10">

          {/* Avatar */}
          <div className="relative shrink-0 self-start sm:self-auto">
            <div className={`w-32 h-32 rounded-full overflow-hidden bg-gradient-to-br ${gr} text-white font-black text-4xl flex items-center justify-center ring-[5px] ring-white shadow-2xl`}>
              {profile.profilePictureBase64
                ? <img src={`data:image/jpeg;base64,${profile.profilePictureBase64}`} className="w-full h-full object-cover" alt="" />
                : <span>{initials}</span>}
            </div>
            {profile.organizationType && (
              <div className="absolute -bottom-1 left-1/2 -translate-x-1/2 px-2.5 py-0.5 rounded-full text-[10px] font-black bg-amber-400 text-amber-900 ring-2 ring-white uppercase tracking-widest whitespace-nowrap">
                Org
              </div>
            )}
          </div>

          {/* Name/bio */}
          <div className="flex-1 min-w-0 pb-1 mt-2 sm:mt-0">
            <div className="flex items-center gap-2 flex-wrap">
              <h1 className="text-2xl lg:text-3xl font-black text-zinc-900 tracking-tight">{profile.name}</h1>
              {profile.organizationType && (
                <span className="px-2 py-0.5 bg-amber-100 text-amber-700 text-[11px] font-black rounded-full uppercase tracking-wider">Verified Org</span>
              )}
            </div>
            {profile.bio && (
              <p className="text-sm text-zinc-500 mt-1.5 leading-relaxed max-w-xl line-clamp-2">{profile.bio}</p>
            )}
          </div>

          {/* Action buttons */}
          <div className="shrink-0 pb-1 flex items-center gap-2">
            <button
              onClick={handleFollow}
              disabled={followLoading}
              className={`flex items-center gap-2 px-5 py-2.5 rounded-full text-sm font-bold transition-all border-2 shadow-sm ${
                isFollowing
                  ? "border-zinc-200 bg-white text-zinc-700 hover:border-red-200 hover:text-red-500 hover:bg-red-50"
                  : "bg-[#635BFF] border-[#635BFF] text-white hover:bg-[#5249E5] shadow-[#635BFF]/25"
              } disabled:opacity-60`}
            >
              {followLoading ? (
                <svg className="animate-spin" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><circle cx="12" cy="12" r="10" strokeOpacity="0.25"/><path d="M12 2a10 10 0 0 1 10 10" strokeLinecap="round"/></svg>
              ) : isFollowing ? (
                <>
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round"><polyline points="20 6 9 17 4 12"/></svg>
                  Following
                </>
              ) : (
                <>
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><line x1="19" y1="8" x2="19" y2="14"/><line x1="22" y1="11" x2="16" y2="11"/></svg>
                  Follow
                </>
              )}
            </button>

            {/* ··· menu */}
            <div className="relative">
              <button
                onClick={() => setMoreOpen(!moreOpen)}
                className="w-10 h-10 rounded-full border-2 border-zinc-200 bg-white flex items-center justify-center text-zinc-600 hover:bg-zinc-50 transition-all"
              >
                <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><circle cx="12" cy="5" r="1.5"/><circle cx="12" cy="12" r="1.5"/><circle cx="12" cy="19" r="1.5"/></svg>
              </button>
              {moreOpen && (
                <>
                  <div className="fixed inset-0 z-30" onClick={() => setMoreOpen(false)} />
                  <div className="absolute right-0 top-12 w-44 bg-white rounded-2xl shadow-xl border border-zinc-100 overflow-hidden z-40 py-1">
                    <button onClick={() => { setMoreOpen(false); handleBlock(); }} className="w-full flex items-center gap-3 px-4 py-2.5 text-sm font-semibold text-red-500 hover:bg-red-50 transition-colors text-left">
                      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>
                      Block User
                    </button>
                    <button onClick={() => setMoreOpen(false)} className="w-full flex items-center gap-3 px-4 py-2.5 text-sm font-semibold text-zinc-600 hover:bg-zinc-50 transition-colors text-left">
                      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round"><path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8"/><polyline points="16 6 12 2 8 6"/><line x1="12" y1="2" x2="12" y2="15"/></svg>
                      Share Profile
                    </button>
                  </div>
                </>
              )}
            </div>
          </div>
        </div>

        {/* ═══════════════ STATS + TABS BAR ═══════════════ */}
        <div className="flex items-center gap-0 mt-5 border-b border-zinc-100">
          <div className="flex items-center gap-6 mr-8">
            {[
              { label: "Posts", val: profile.postCount },
              { label: "Followers", val: followerCount, onClick: () => setFollowModal({ open: true, mode: "followers" }) },
              { label: "Following", val: profile.followingCount, onClick: () => setFollowModal({ open: true, mode: "following" }) },
            ].map(s => (
              <button key={s.label} onClick={s.onClick} className="flex items-center gap-1.5 py-4 group">
                <span className="text-xl font-black text-zinc-900 tabular-nums group-hover:text-[#635BFF] transition-colors">{fmtNum(s.val)}</span>
                <span className="text-xs font-semibold text-zinc-400 uppercase tracking-wider">{s.label}</span>
              </button>
            ))}
          </div>

          <div className="flex items-center gap-1 flex-1">
            {TABS.map(t => (
              <button
                key={t.key}
                onClick={() => setTab(t.key)}
                className={`relative px-4 py-4 text-sm font-bold transition-colors whitespace-nowrap ${tab === t.key ? "text-[#635BFF]" : "text-zinc-500 hover:text-zinc-900"}`}
              >
                {t.label}{t.count !== undefined && t.count > 0 && (
                  <span className="ml-1.5 text-[11px] font-black bg-zinc-100 text-zinc-500 px-1.5 py-0.5 rounded-full">{fmtNum(t.count)}</span>
                )}
                {tab === t.key && <span className="absolute bottom-0 left-0 right-0 h-0.5 bg-[#635BFF] rounded-t-full" />}
              </button>
            ))}
          </div>
        </div>

        {/* ═══════════════ BODY GRID ═══════════════ */}
        <div className="grid grid-cols-1 lg:grid-cols-[280px_1fr] gap-6 py-6 items-start">

          {/* ── LEFT PANEL ────── */}
          <div className="space-y-4 lg:sticky lg:top-6">
            {/* Info card */}
            <div className="bg-white border border-zinc-100 rounded-2xl overflow-hidden shadow-sm">
              <div className="px-4 py-3 border-b border-zinc-50">
                <p className="text-xs font-black text-zinc-400 uppercase tracking-widest">About</p>
              </div>
              <div className="p-4 space-y-3">
                {profile.bio && <p className="text-sm text-zinc-700 leading-relaxed">{profile.bio}</p>}
                <div className="space-y-2 pt-1">
                  {profile.website && (
                    <a href={profile.website} target="_blank" rel="noopener noreferrer" className="flex items-center gap-2.5 text-xs font-semibold text-[#635BFF] hover:underline">
                      <span className="w-5 h-5 flex items-center justify-center shrink-0">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
                      </span>
                      {profile.website.replace(/^https?:\/\//, "")}
                    </a>
                  )}
                  {profile.organizationType && (
                    <div className="flex items-center gap-2.5 text-xs font-medium text-zinc-500">
                      <span className="w-5 h-5 flex items-center justify-center shrink-0">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                      </span>
                      {profile.organizationType}
                    </div>
                  )}
                  {!profile.bio && !profile.website && !profile.organizationType && (
                    <p className="text-xs text-zinc-400 italic">No info provided.</p>
                  )}
                </div>
              </div>
            </div>

            {/* Mutual followers mini panel */}
            <div className="bg-white border border-zinc-100 rounded-2xl overflow-hidden shadow-sm">
              <div className="px-4 py-3 border-b border-zinc-50 flex items-center justify-between">
                <p className="text-xs font-black text-zinc-400 uppercase tracking-widest">Followers</p>
                <button onClick={() => setFollowModal({ open: true, mode: "followers" })} className="text-[11px] font-bold text-[#635BFF] hover:underline">See all</button>
              </div>
              <FollowInline userId={userId} mode="followers" />
            </div>
          </div>

          {/* ── RIGHT PANEL ────── */}
          <div className="min-w-0">
            {/* POSTS */}
            {tab === "posts" && (
              <div className="bg-white border border-zinc-100 rounded-2xl shadow-sm overflow-hidden">
                <div className="flex flex-col items-center py-20 px-8 text-center">
                  <div className="w-20 h-20 rounded-3xl bg-zinc-50 flex items-center justify-center mb-5">
                    <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" className="text-zinc-300">
                      <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/>
                    </svg>
                  </div>
                  <h3 className="text-lg font-black text-zinc-700">No public posts yet</h3>
                  <p className="text-sm text-zinc-400 mt-2 max-w-xs">Posts from {profile.name.split(" ")[0]} will appear here once they share something.</p>
                </div>
              </div>
            )}

            {/* FOLLOWERS */}
            {tab === "followers" && (
              <div className="bg-white border border-zinc-100 rounded-2xl shadow-sm overflow-hidden">
                <div className="px-5 py-4 border-b border-zinc-50">
                  <h3 className="text-sm font-black text-zinc-800">People who follow {profile.name.split(" ")[0]}</h3>
                </div>
                <FollowInline userId={userId} mode="followers" />
              </div>
            )}

            {/* FOLLOWING */}
            {tab === "following" && (
              <div className="bg-white border border-zinc-100 rounded-2xl shadow-sm overflow-hidden">
                <div className="px-5 py-4 border-b border-zinc-50">
                  <h3 className="text-sm font-black text-zinc-800">People {profile.name.split(" ")[0]} follows</h3>
                </div>
                <FollowInline userId={userId} mode="following" />
              </div>
            )}

            {/* ABOUT */}
            {tab === "about" && (
              <div className="bg-white border border-zinc-100 rounded-2xl shadow-sm overflow-hidden">
                <div className="px-5 py-4 border-b border-zinc-50">
                  <h3 className="text-sm font-black text-zinc-800">About {profile.name.split(" ")[0]}</h3>
                </div>
                <div className="p-5 grid grid-cols-1 sm:grid-cols-2 gap-3">
                  {[
                    { icon: "globe", label: "Website", val: profile.website, isLink: true },
                    { icon: "org", label: "Organization Type", val: profile.organizationType },
                  ].filter(r => r.val).map(row => (
                    <div key={row.label} className="flex items-start gap-3 p-3 bg-zinc-50 rounded-xl">
                      <div className="w-8 h-8 rounded-lg bg-white border border-zinc-200 flex items-center justify-center shrink-0">
                        {row.icon === "globe" ? (
                          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" className="text-zinc-500"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
                        ) : (
                          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" className="text-zinc-500"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                        )}
                      </div>
                      <div className="min-w-0">
                        <p className="text-[10px] text-zinc-400 font-bold uppercase tracking-wider">{row.label}</p>
                        {row.isLink ? (
                          <a href={row.val} target="_blank" rel="noopener noreferrer" className="text-sm font-semibold text-[#635BFF] hover:underline truncate block mt-0.5">
                            {row.val!.replace(/^https?:\/\//, "")}
                          </a>
                        ) : (
                          <p className="text-sm font-semibold text-zinc-800 mt-0.5">{row.val}</p>
                        )}
                      </div>
                    </div>
                  ))}

                  {!profile.website && !profile.organizationType && (
                    <div className="col-span-full py-8 text-center">
                      <p className="text-sm text-zinc-400 font-medium">No additional info provided.</p>
                    </div>
                  )}
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Followers/Following Modal */}
      <FollowersModal
        isOpen={followModal.open}
        onClose={() => setFollowModal(p => ({ ...p, open: false }))}
        userId={userId}
        mode={followModal.mode}
        title={followModal.mode === "followers" ? `Followers (${fmtNum(followerCount)})` : `Following (${fmtNum(profile.followingCount)})`}
      />
    </div>
  );
}
