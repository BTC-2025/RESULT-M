"use client";

import { useState, useEffect } from "react";
import RightSidebar from "@/components/feed/RightSidebar";
import PostCard from "@/components/feed/PostCard";
import CreatePostModal from "@/components/feed/CreatePostModal";
import { api, getAuthToken } from "@/lib/api";
import { useRouter } from "next/navigation";

// Helper function for relative time
function getTimeAgo(dateStr: string | null) {
  if (!dateStr) return "Recently";
  const date = new Date(dateStr);
  const seconds = Math.floor((new Date().getTime() - date.getTime()) / 1000);
  
  if (seconds < 60) return `${Math.max(1, seconds)}s ago`;
  const minutes = Math.floor(seconds / 60);
  if (minutes < 60) return `${minutes}m ago`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours}h ago`;
  const days = Math.floor(hours / 24);
  if (days < 7) return `${days}d ago`;
  const weeks = Math.floor(days / 7);
  if (weeks < 4) return `${weeks}w ago`;
  
  return date.toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
}

export default function HomeFeedPage() {
  const router = useRouter();
  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);
  const [modalDefaultType, setModalDefaultType] = useState<"UPDATE" | "COMPLAINT" | "POLL">("UPDATE");
  const [posts, setPosts] = useState<any[]>([]);
  const [liveStories, setLiveStories] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isLoadingMore, setIsLoadingMore] = useState(false);
  const [nextCursor, setNextCursor] = useState<string | null>(null);
  const [hasMore, setHasMore] = useState(false);

  useEffect(() => {
    fetchFeed();
  }, []);

  const fetchFeed = async (cursor?: string) => {
    try {
      if (cursor) {
        setIsLoadingMore(true);
      } else {
        setIsLoading(true);
      }
      
      const res = await api.feed.getTimeline(cursor, 20);
      
      if (!cursor) {
        let stories = res.liveStories || [];
        try {
          const [cRes, fRes] = await Promise.all([
            fetch('/api/sports/cricket?endpoint=currentMatches'),
            fetch('/api/sports/football?status=inprogress')
          ]);
          
          let cricketStories = [];
          if (cRes.ok) {
            const cData = await cRes.json();
            if (cData.status === 'success' && cData.data) {
              cricketStories = cData.data.filter((m: any) => m.matchStarted && !m.matchEnded).map((m: any) => {
                const teamA = m.teams?.[0] || 'TBA';
                const teamB = m.teams?.[1] || 'TBA';
                return {
                  id: `cricket-${m.id}`,
                  title: `${teamA.substring(0,3)} v ${teamB.substring(0,3)}`.toUpperCase(),
                  hasUnread: true,
                  avatarText: '🏏',
                  bgColor: 'bg-emerald-100',
                  href: '/results/sports/cricket'
                };
              });
            }
          }

          let footballStories: any[] = [];
          if (fRes.ok) {
            const fData = await fRes.json();
            if (fData.success && fData.data) {
              fData.data.forEach((league: any) => {
                if (league.matches) {
                  league.matches.forEach((m: any) => {
                    footballStories.push({
                      id: `fb-${m.id}`,
                      title: `${(m.teams?.home?.name || 'H').substring(0,3)} v ${(m.teams?.away?.name || 'A').substring(0,3)}`.toUpperCase(),
                      hasUnread: true,
                      avatarText: '⚽',
                      bgColor: 'bg-blue-100',
                      href: '/results/sports/football'
                    });
                  });
                }
              });
            }
          }

          stories = [...footballStories, ...cricketStories, ...stories];
        } catch (e) {
          console.error("Failed to fetch sports stories", e);
        }
        setLiveStories(stories);
      }
      
      // Map backend DTO to frontend structure
      const mappedPosts = (res.items || res.content || []).map((p: any) => ({
        id: p.id,
        type: p.postType || p.type || "DISCUSSION", // COMPLAINT, POLL, DISCUSSION, UPDATE, IMAGE, VIDEO, RESULT
        author: { 
          name: p.authorName || "Unknown", 
          handle: p.authorHandle || "@user", 
          initials: (p.authorName || "U")[0], 
          color: "bg-blue-100 text-blue-600", 
          isVerified: p.isAuthorVerified || false 
        },
        timeAgo: getTimeAgo(p.createdAt),
        location: p.payload?.locationName || null,
        title: p.payload?.title || p.payload?.question || (p.postType === 'COMPLAINT' ? 'Complaint' : 'Update'),
        description: p.payload?.description || p.payload?.content || p.payload?.text,
        pollOptions: p.payload?.options,
        mediaUrls: p.payload?.mediaUrls || [],
        stats: { upvotes: p.payload?.upvotes || p.likeCount || 0, comments: p.commentCount || 0 },
        isBookmarked: p.isBookmarked,
        isUpvoted: p.isLiked || false,
        payload: p.payload
      }));
      
      setPosts(prev => cursor ? [...prev, ...mappedPosts] : mappedPosts);
      setNextCursor(res.nextCursor);
      setHasMore(res.hasMore);
      
    } catch (error) {
      console.error("Failed to fetch feed:", error);
      if (!cursor) {
        setLiveStories([]);
        setPosts([]);
        setHasMore(false);
      }
    } finally {
      setIsLoading(false);
      setIsLoadingMore(false);
    }
  };

  const openCreateModal = (type: "UPDATE" | "COMPLAINT" | "POLL") => {
    if (!getAuthToken()) {
      router.push('/login');
      return;
    }
    setModalDefaultType(type);
    setIsCreateModalOpen(true);
  };

  return (
    <div className="flex lg:gap-12 w-full">
      
      {/* Center Feed */}
      <div className="flex-1 min-w-0 transition-all duration-300">
          
          {/* Live Events (Story Balls) */}
          <div className="mb-6">
            <h2 className="text-sm font-bold text-foreground mb-3 px-1">Live Matches and Updates Results</h2>
            <div className="flex gap-4 overflow-x-auto pb-2 hide-scrollbar items-center">
              {liveStories.map(story => (
              <div key={story.id} onClick={() => story.href ? router.push(story.href) : null} className="flex flex-col items-center gap-1.5 cursor-pointer shrink-0 transition-transform active:scale-95 group/story relative">
                <div className="relative rounded-full p-[3px]">
                  {/* Rotating gradient background on hover */}
                  <div className={`absolute inset-0 rounded-full transition-all duration-500 ease-in-out ${story.hasUnread ? (story.avatarText === '🏏' ? 'bg-gradient-to-tr from-emerald-400 via-emerald-500 to-teal-400' : 'bg-gradient-to-tr from-primary via-secondary to-accent') : 'bg-muted'} group-hover/story:animate-[spin_3s_linear_infinite]`}></div>
                  
                  {/* Inner content */}
                  <div className={`relative z-10 w-14 h-14 rounded-full border-[3px] border-background flex items-center justify-center font-black text-lg ${story.bgColor || 'bg-zinc-100'} text-zinc-600`}>
                    {story.avatarText || (story.title || "U").substring(0, 2).toUpperCase()}
                  </div>
                  
                  {/* LIVE pill */}
                  {story.avatarText === '🏏' && (
                    <div className="absolute -bottom-0.5 left-1/2 -translate-x-1/2 z-20 bg-red-500 text-white text-[8px] font-black tracking-widest px-1.5 py-0.5 rounded-full border-2 border-background shadow-sm">
                      LIVE
                    </div>
                  )}
                </div>
                <span className="text-[11px] font-bold text-foreground/80 truncate max-w-[64px] text-center">{story.title}</span>
              </div>
            ))}
            {liveStories.length === 0 && !isLoading && (
              <div className="text-sm font-medium text-muted-foreground ml-2">No active live events right now.</div>
            )}
            </div>
          </div>
          {/* Create Post Input */}
          <div className="bg-background rounded-2xl shadow-sm border border-muted p-4 mb-6">
            <div className="flex gap-4 items-center">
              <div className="w-10 h-10 rounded-full bg-primary/20 flex items-center justify-center text-primary font-bold shrink-0">
                A
              </div>
              <div 
                onClick={() => openCreateModal("UPDATE")}
                className="flex-1 bg-muted/50 rounded-full px-4 py-3 cursor-text hover:bg-muted transition-colors"
              >
                 <span className="text-muted-foreground font-medium text-sm">Post a complaint, poll, or discussion...</span>
              </div>
            </div>
            <div className="flex gap-4 mt-4 ml-14 border-t border-muted/50 pt-3">
               <button 
                 onClick={() => openCreateModal("COMPLAINT")}
                 className="flex items-center gap-2 text-primary font-semibold text-sm hover:bg-primary/5 px-3 py-1.5 rounded-lg transition-colors group"
               >
                 <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" opacity="0.9" className="group-hover:scale-110 transition-transform"><path d="M12 22c1.1 0 2-.9 2-2h-4c0 1.1.89 2 2 2zm6-6v-5c0-3.07-1.64-5.64-4.5-6.32V4c0-.83-.67-1.5-1.5-1.5s-1.5.67-1.5 1.5v.68C7.63 5.36 6 7.92 6 11v5l-2 2v1h16v-1l-2-2z"/></svg>
                 Complaint
               </button>
               <button 
                 onClick={() => openCreateModal("POLL")}
                 className="flex items-center gap-2 text-accent font-semibold text-sm hover:bg-accent/5 px-3 py-1.5 rounded-lg transition-colors group"
               >
                 <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" opacity="0.9" className="group-hover:scale-110 transition-transform"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zM9 17H7v-7h2v7zm4 0h-2V7h2v10zm4 0h-2v-4h2v4z"/></svg>
                 Poll
               </button>
            </div>
          </div>

          {/* Feed Posts */}
          <div className="space-y-4 mb-12">
            {isLoading && !isLoadingMore ? (
              <div className="space-y-4">
                {[1,2,3].map(i => (
                  <div key={i} className="bg-background rounded-2xl border border-muted p-5 animate-pulse">
                    <div className="flex items-center gap-3 mb-4">
                      <div className="w-10 h-10 rounded-full bg-muted" />
                      <div className="flex-1 space-y-2">
                        <div className="h-3 bg-muted rounded w-1/3" />
                        <div className="h-2.5 bg-muted rounded w-1/4" />
                      </div>
                      <div className="h-5 w-16 bg-muted rounded-full" />
                    </div>
                    <div className="space-y-2 mb-4">
                      <div className="h-4 bg-muted rounded w-4/5" />
                      <div className="h-3 bg-muted rounded w-full" />
                      <div className="h-3 bg-muted rounded w-3/4" />
                    </div>
                    <div className="flex gap-4 pt-3 border-t border-muted/50">
                      <div className="h-5 w-12 bg-muted rounded" />
                      <div className="h-5 w-12 bg-muted rounded" />
                    </div>
                  </div>
                ))}
              </div>
            ) : posts.length > 0 ? (
              <>
                {posts.map(post => (
                   <PostCard key={post.id} post={post} />
                ))}
                {hasMore && (
                  <div className="flex justify-center pt-4">
                     <button 
                       onClick={() => fetchFeed(nextCursor!)}
                       disabled={isLoadingMore}
                       className="px-6 py-2.5 rounded-full font-bold text-primary bg-primary/10 hover:bg-primary/20 transition-colors disabled:opacity-50"
                     >
                       {isLoadingMore ? "Loading..." : "Load More"}
                     </button>
                  </div>
                )}
              </>
            ) : null}
            {posts.length === 0 && !isLoading && !isLoadingMore && (
              <div className="flex flex-col items-center justify-center py-20 text-center">
                <div className="w-20 h-20 bg-muted/50 rounded-full flex items-center justify-center mb-6 text-muted-foreground/60 shadow-inner">
                  <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5"><path d="M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z"></path></svg>
                </div>
                <h3 className="text-xl font-bold text-foreground mb-2">Your feed is quiet</h3>
                <p className="text-muted-foreground max-w-sm">
                  Follow organizations, explore topics, or post your own updates to populate your feed.
                </p>
                <button 
                  onClick={() => setIsCreateModalOpen(true)}
                  className="mt-6 px-6 py-2 bg-primary text-white font-bold rounded-full hover:bg-primary/90 transition-colors shadow-sm"
                >
                  Create a Post
                </button>
              </div>
            )}
          </div>
        </div>

        {/* Right Sidebar */}
      <RightSidebar />

      <CreatePostModal 
        isOpen={isCreateModalOpen} 
        onClose={() => setIsCreateModalOpen(false)} 
        defaultType={modalDefaultType} 
        onPostCreated={fetchFeed}
      />
    </div>
  );
}
