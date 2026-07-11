"use client";

import Link from "next/link";
import { useEffect, useState, useCallback } from "react";
import { api } from "@/lib/api";

// ─── Helpers ────────────────────────────────────────────────────────────────
function formatNumber(num: number) {
  if (num >= 1_000_000) return (num / 1_000_000).toFixed(1) + "M";
  if (num >= 1_000) return (num / 1_000).toFixed(1) + "k";
  return num.toString();
}

const CATEGORY_MAP: Record<string, { color: string; bg: string; border: string; icon: string }> = {
  Infrastructure: { color: "text-orange-600", bg: "bg-orange-50",  border: "border-orange-200", icon: "🏗️" },
  Transport:      { color: "text-blue-600",   bg: "bg-blue-50",    border: "border-blue-200",   icon: "🚌" },
  Sanitation:     { color: "text-green-600",  bg: "bg-green-50",   border: "border-green-200",  icon: "🧹" },
  Utilities:      { color: "text-cyan-600",   bg: "bg-cyan-50",    border: "border-cyan-200",   icon: "⚡" },
  Education:      { color: "text-violet-600", bg: "bg-violet-50",  border: "border-violet-200", icon: "📚" },
  Health:         { color: "text-red-600",    bg: "bg-red-50",     border: "border-red-200",    icon: "🏥" },
  Government:     { color: "text-zinc-600",   bg: "bg-zinc-50",    border: "border-zinc-200",   icon: "🏛️" },
  General:        { color: "text-zinc-500",   bg: "bg-zinc-50",    border: "border-zinc-200",   icon: "📌" },
};

const ORG_GRADIENTS = [
  "from-violet-500 to-purple-600",
  "from-blue-500 to-cyan-600",
  "from-emerald-500 to-teal-600",
  "from-rose-500 to-pink-600",
  "from-amber-500 to-orange-500",
  "from-indigo-500 to-blue-600",
];

const RANK_RING = [
  "ring-2 ring-amber-400 ring-offset-1",   // gold
  "ring-2 ring-slate-400 ring-offset-1",   // silver
  "ring-2 ring-orange-400 ring-offset-1",  // bronze
  "",                                        // others
];

const RANK_NUM_BG = [
  "bg-gradient-to-br from-amber-400 to-yellow-300 text-amber-900 shadow-amber-200",
  "bg-gradient-to-br from-slate-400 to-slate-300 text-slate-800 shadow-slate-200",
  "bg-gradient-to-br from-orange-400 to-amber-300 text-orange-900 shadow-orange-200",
  "bg-zinc-100 text-zinc-500 shadow-zinc-100",
];

// ─── Skeleton ────────────────────────────────────────────────────────────────
function TrendingSkeleton() {
  return (
    <div className="space-y-3 p-4 animate-pulse">
      {[1, 2, 3, 4].map(i => (
        <div key={i} className="flex items-center gap-3">
          <div className="w-7 h-7 rounded-full bg-muted shrink-0" />
          <div className="flex-1 space-y-1.5">
            <div className="h-2.5 bg-muted rounded w-1/4" />
            <div className="h-3 bg-muted rounded w-3/4" />
            <div className="h-1.5 bg-muted rounded-full w-full mt-1" />
          </div>
        </div>
      ))}
    </div>
  );
}

function PublisherSkeleton() {
  return (
    <div className="space-y-3 p-4 animate-pulse">
      {[1, 2, 3].map(i => (
        <div key={i} className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-xl bg-muted shrink-0" />
          <div className="flex-1 space-y-1.5">
            <div className="h-3 bg-muted rounded w-2/3" />
            <div className="h-2 bg-muted rounded w-1/2" />
          </div>
          <div className="w-16 h-7 rounded-full bg-muted" />
        </div>
      ))}
    </div>
  );
}

// ─── Main ────────────────────────────────────────────────────────────────────
export default function RightSidebar() {
  const [trending, setTrending]           = useState<any[]>([]);
  const [publishers, setPublishers]       = useState<any[]>([]);
  const [isLoading, setIsLoading]         = useState(true);
  const [followed, setFollowed]           = useState<Set<string>>(new Set());
  const [showAllTrending, setShowAllTrending] = useState(false);

  const fetchData = useCallback(async () => {
    try {
      const [complaintsRes, workspacesRes] = await Promise.all([
        api.complaints.getComplaints("trending").catch(() => ({ content: [] })),
        api.workspaces.getPublic(0, 8).catch(() => ({ content: [] })),
      ]);
      if (complaintsRes.content) setTrending(complaintsRes.content.slice(0, 8));
      if (workspacesRes.content) setPublishers(workspacesRes.content.slice(0, 5));
    } catch (err) {
      console.error("Sidebar fetch error", err);
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => { fetchData(); }, [fetchData]);

  const visibleTrending = showAllTrending ? trending : trending.slice(0, 4);
  const maxUpvotes = trending.length > 0 ? Math.max(...trending.map(t => t.upvotes || 0)) : 1;

  const handleFollow = (slug: string) => {
    setFollowed(prev => {
      const next = new Set(prev);
      next.has(slug) ? next.delete(slug) : next.add(slug);
      return next;
    });
  };

  return (
    <aside className="sticky bottom-4 h-fit hidden xl:flex flex-col gap-4 w-[300px] pt-5 pb-2">

      {/* ── Search ──────────────────────────────────────────────────── */}
      <Link href="/search" className="shrink-0 group flex items-center gap-3 px-4 py-2.5 rounded-2xl bg-zinc-50 border border-zinc-200/80 hover:border-primary/40 hover:bg-white transition-all shadow-sm">
        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" className="text-zinc-400 group-hover:text-primary transition-colors shrink-0">
          <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
        </svg>
        <span className="text-sm font-medium text-zinc-400 group-hover:text-zinc-600 transition-colors">Search ResultHub...</span>
        <kbd className="ml-auto hidden sm:inline-flex items-center gap-1 px-1.5 py-0.5 text-[10px] font-bold text-zinc-400 border border-zinc-200 rounded-md bg-white">⌘K</kbd>
      </Link>

      {/* ── Trending ────────────────────────────────────────────────── */}
      <div className="shrink-0 rounded-2xl border border-zinc-200/80 bg-white overflow-hidden shadow-sm">
        {/* Card Header */}
        <div className="flex items-center justify-between px-4 py-3 border-b border-zinc-100">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-xl bg-gradient-to-br from-orange-500 to-red-500 flex items-center justify-center shadow-md shadow-orange-200">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="white">
                <path d="M12 2C8.5 7 6 9.5 6 13a6 6 0 0012 0c0-3.5-2.5-6-6-11z"/>
              </svg>
            </div>
            <div>
              <h3 className="text-[13px] font-black text-zinc-900 leading-tight">Trending Issues</h3>
              <p className="text-[10px] text-zinc-400 font-medium leading-tight">Most upvoted complaints</p>
            </div>
          </div>
          <span className="flex items-center gap-1 text-[10px] font-black text-red-500 bg-red-50 border border-red-100 px-2 py-1 rounded-full">
            <span className="w-1.5 h-1.5 bg-red-500 rounded-full animate-pulse"/>
            LIVE
          </span>
        </div>

        {/* Trending List */}
        {isLoading ? <TrendingSkeleton /> : (
          <div className="divide-y divide-zinc-50">
            {visibleTrending.length > 0 ? visibleTrending.map((item, i) => {
              const cat = CATEGORY_MAP[item.category] || CATEGORY_MAP["General"];
              const pct = Math.round(((item.upvotes || 0) / maxUpvotes) * 100);
              const isHot = (item.upvotes || 0) > 100;

              return (
                <Link
                  key={item.id || i}
                  href="/results"
                  className="group flex items-start gap-3 px-4 py-3 hover:bg-zinc-50/80 transition-colors"
                >
                  {/* Rank number */}
                  <span className={`shrink-0 w-6 h-6 rounded-full text-[10px] font-black flex items-center justify-center shadow-sm mt-0.5 ${RANK_NUM_BG[Math.min(i, 3)]}`}>
                    {i + 1}
                  </span>

                  {/* Main content */}
                  <div className="flex-1 min-w-0">
                    {/* Category chip */}
                    <span className={`inline-flex items-center gap-1 text-[10px] font-bold px-1.5 py-0.5 rounded-md border ${cat.bg} ${cat.color} ${cat.border} mb-1`}>
                      {cat.icon} {item.category || "General"}
                    </span>

                    {/* Title */}
                    <p className="text-[13px] font-bold text-zinc-800 group-hover:text-primary transition-colors leading-snug truncate">
                      {item.title}
                    </p>

                    {/* Upvote bar + count */}
                    <div className="mt-1.5 flex items-center gap-2">
                      <div className="flex-1 h-1 rounded-full bg-zinc-100 overflow-hidden">
                        <div
                          className={`h-full rounded-full transition-all duration-700 ${i === 0 ? "bg-gradient-to-r from-amber-400 to-orange-500" : i === 1 ? "bg-gradient-to-r from-slate-400 to-slate-500" : i === 2 ? "bg-gradient-to-r from-orange-400 to-amber-500" : "bg-gradient-to-r from-primary to-secondary"}`}
                          style={{ width: `${pct}%` }}
                        />
                      </div>
                      <span className="text-[11px] font-bold text-zinc-500 whitespace-nowrap">
                        {formatNumber(item.upvotes || 0)}
                        {isHot && <span className="ml-1 text-orange-500">🔥</span>}
                      </span>
                    </div>
                  </div>
                </Link>
              );
            }) : (
              <div className="py-10 text-center">
                <p className="text-3xl mb-2">📭</p>
                <p className="text-xs text-zinc-400 font-medium">No trending topics yet</p>
              </div>
            )}
          </div>
        )}

        {/* Show more toggle */}
        {!isLoading && trending.length > 4 && (
          <button
            onClick={() => setShowAllTrending(v => !v)}
            className="w-full flex items-center justify-center gap-1.5 text-primary text-xs font-bold py-2.5 border-t border-zinc-100 hover:bg-primary/5 transition-colors"
          >
            {showAllTrending ? "Show less" : `Show ${trending.length - 4} more`}
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" className={`transition-transform duration-200 ${showAllTrending ? "rotate-180" : ""}`}>
              <polyline points="6 9 12 15 18 9"/>
            </svg>
          </button>
        )}
      </div>

      {/* ── Suggested Publishers ─────────────────────────────────────── */}
      <div className="shrink-0 rounded-2xl border border-zinc-200/80 bg-white overflow-hidden shadow-sm">
        <div className="flex items-center justify-between px-4 py-3 border-b border-zinc-100">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-xl bg-gradient-to-br from-primary to-secondary flex items-center justify-center shadow-md shadow-primary/20">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2.3">
                <path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/>
                <path d="M23 21v-2a4 4 0 00-3-3.87"/><path d="M16 3.13a4 4 0 010 7.75"/>
              </svg>
            </div>
            <div>
              <h3 className="text-[13px] font-black text-zinc-900 leading-tight">Who to Follow</h3>
              <p className="text-[10px] text-zinc-400 font-medium leading-tight">Suggested publishers</p>
            </div>
          </div>
        </div>

        {isLoading ? <PublisherSkeleton /> : (
          <div className="divide-y divide-zinc-50">
            {publishers.length > 0 ? publishers.map((org, i) => {
              const slug = org.slug || org.name?.toLowerCase().replace(/\s+/g, "-");
              const isFollowed = followed.has(slug);
              const gradient = ORG_GRADIENTS[i % ORG_GRADIENTS.length];
              const initials = (org.name || "?").split(" ").slice(0, 2).map((w: string) => w[0]).join("").toUpperCase();

              return (
                <div key={org.id || i} className="flex items-center gap-3 px-4 py-3 hover:bg-zinc-50/80 transition-colors group">
                  {/* Gradient avatar */}
                  <div className={`w-9 h-9 rounded-xl bg-gradient-to-br ${gradient} flex items-center justify-center text-white text-xs font-black shadow-sm shrink-0 ${RANK_RING[Math.min(i, 3)]}`}>
                    {initials}
                  </div>

                  {/* Info */}
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-1">
                      <span className="text-[13px] font-bold text-zinc-900 truncate leading-tight">{org.name}</span>
                      {org.verified && (
                        <svg width="12" height="12" viewBox="0 0 24 24" fill="#6C5CE7" stroke="white" strokeWidth="1.5" className="shrink-0">
                          <polygon points="12 2 15.09 5.09 19.5 5.5 19.91 9.91 23 12 19.91 14.09 19.5 18.5 15.09 18.91 12 22 8.91 18.91 4.5 18.5 4.09 14.09 1 12 4.09 9.91 4.5 5.5 8.91 5.09 12 2"/>
                        </svg>
                      )}
                    </div>
                    <p className="text-[11px] text-zinc-400 font-medium truncate">@{slug}</p>
                  </div>

                  {/* Follow / Following */}
                  <button
                    onClick={() => handleFollow(slug)}
                    className={`shrink-0 text-[11px] font-bold px-3 py-1.5 rounded-full border transition-all duration-150 active:scale-95 ${
                      isFollowed
                        ? "border-zinc-200 bg-white text-zinc-500 hover:border-red-300 hover:text-red-500 hover:bg-red-50"
                        : "border-zinc-900 bg-zinc-900 text-white hover:bg-zinc-700"
                    }`}
                  >
                    {isFollowed ? "Following" : "Follow"}
                  </button>
                </div>
              );
            }) : (
              <div className="py-10 text-center">
                <p className="text-3xl mb-2">🏢</p>
                <p className="text-xs text-zinc-400 font-medium">No publishers found</p>
              </div>
            )}
          </div>
        )}

        <Link
          href="/results"
          className="flex items-center justify-center gap-1.5 text-primary text-xs font-bold py-2.5 border-t border-zinc-100 hover:bg-primary/5 transition-colors"
        >
          Explore all publishers
          <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
            <line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/>
          </svg>
        </Link>
      </div>


      {/* ── Footer ──────────────────────────────────────────────────── */}
      <div className="shrink-0 flex flex-wrap gap-x-3 gap-y-1 px-1 text-[10.5px] font-medium text-zinc-400">
        {["Terms", "Privacy", "Guidelines", "Contact"].map(l => (
          <Link key={l} href={`/${l.toLowerCase()}`} className="hover:text-zinc-700 transition-colors">{l}</Link>
        ))}
        <span className="w-full text-[10px] mt-0.5">© 2026 ResultHub Corp.</span>
      </div>

    </aside>
  );
}
