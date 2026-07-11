"use client";

import Link from "next/link";

interface PostCardProps {
  id: string;
  type: "COMPLAINT" | "POLL" | "DISCUSSION" | "UPDATE" | "IMAGE" | "VIDEO" | "RESULT" | string;
  author: {
    name: string;
    handle: string;
    initials: string;
    color: string;
    isVerified?: boolean;
  };
  timeAgo: string;
  location?: string;
  title: string;
  description?: string;
  pollOptions?: { label: string; percentage: number; isWinner: boolean }[];
  stats: {
    upvotes: number;
    comments: number;
  };
  isBookmarked?: boolean;
  isUpvoted?: boolean;
  mediaUrls?: string[];
}

import { useState } from "react";
import { api, API_BASE_URL } from "@/lib/api";

export default function PostCard({ post }: { post: PostCardProps }) {
  const [isUpvoted, setIsUpvoted] = useState(post.isUpvoted || false);
  const [upvotes, setUpvotes] = useState(post.stats.upvotes || 0);
  const [isBookmarked, setIsBookmarked] = useState(post.isBookmarked || false);
  const [isLoading, setIsLoading] = useState(false);

  const handleUpvote = async (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    if (isLoading) return;
    
    try {
      setIsLoading(true);
      
      if (post.type === "COMPLAINT") {
        if (isUpvoted) {
          await api.complaints.removeUpvote(post.id);
        } else {
          await api.complaints.upvote(post.id);
        }
      } else if (post.type === "DISCUSSION") {
        if (isUpvoted) {
          await api.posts.removeUpvote(post.id);
        } else {
          await api.posts.upvote(post.id);
        }
      }
      
      // We don't have upvotes for POLL and RESULT mapped yet
      setUpvotes(prev => isUpvoted ? prev - 1 : prev + 1);
      setIsUpvoted(!isUpvoted);
    } catch (err) {
      console.error("Failed to toggle upvote", err);
    } finally {
      setIsLoading(false);
    }
  };

  const handleBookmark = async (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    if (isLoading) return;

    try {
      setIsLoading(true);
      
      if (post.type === "COMPLAINT") {
        if (isBookmarked) {
          await api.complaints.removeBookmark(post.id);
        } else {
          await api.complaints.bookmark(post.id);
        }
      } else {
        if (isBookmarked) {
          await api.posts.removeBookmark(post.id);
        } else {
          await api.posts.bookmark(post.id);
        }
      }
      
      setIsBookmarked(!isBookmarked);
    } catch (err) {
      console.error("Failed to toggle bookmark", err);
    } finally {
      setIsLoading(false);
    }
  };

  const typeColors: Record<string, string> = {
    COMPLAINT: "bg-amber-100 text-amber-800",
    POLL: "bg-primary/10 text-primary",
    DISCUSSION: "bg-blue-100 text-blue-800",
    UPDATE: "bg-zinc-100 text-zinc-800",
    IMAGE: "bg-pink-100 text-pink-800",
    VIDEO: "bg-purple-100 text-purple-800",
    RESULT: "bg-emerald-100 text-emerald-800"
  };

  return (
    <article className="bg-background rounded-2xl shadow-sm border border-muted p-5 hover:border-primary/30 transition-colors cursor-pointer block relative">
      <Link href={`/post/${post.id}`} className="absolute inset-0 z-0" aria-label="View post" />
      
      <div className="relative z-10 flex items-center justify-between mb-4">
         <div className="flex items-center gap-3">
           <div className={`w-10 h-10 rounded-full flex items-center justify-center font-bold ${post.author.color}`}>
             {post.author.initials}
           </div>
           <div>
             <div className="flex items-center gap-1">
               <h4 className="font-bold text-sm">{post.author.name}</h4>
               {post.author.isVerified && <svg width="14" height="14" viewBox="0 0 24 24" fill="#3b82f6" stroke="white" strokeWidth="2"><polygon points="12 2 15.09 5.09 19.5 5.5 19.91 9.91 23 12 19.91 14.09 19.5 18.5 15.09 18.91 12 22 8.91 18.91 4.5 18.5 4.09 14.09 1 12 4.09 9.91 4.5 5.5 8.91 5.09 12 2"></polygon></svg>}
             </div>
             <p className="text-[11px] text-muted-foreground">{post.location ? `${post.location} • ` : ""}{post.timeAgo}</p>
           </div>
         </div>
         <span className={`${typeColors[post.type] || typeColors["UPDATE"]} text-[10px] font-bold px-2 py-1 rounded-full tracking-wider`}>
           {post.type}
         </span>
      </div>

      <div className="relative z-10">
        <h3 className="font-black text-[17px] mb-2 leading-tight">{post.title}</h3>
        {post.description && (
          <p className="text-sm text-foreground/80 mb-4 line-clamp-3 leading-relaxed">{post.description}</p>
        )}

        {post.mediaUrls && post.mediaUrls.length > 0 && (
          <div className={`grid gap-2 mb-4 rounded-xl overflow-hidden ${post.mediaUrls.length === 1 ? 'grid-cols-1' : post.mediaUrls.length === 2 ? 'grid-cols-2' : post.mediaUrls.length === 3 ? 'grid-cols-2' : 'grid-cols-2 grid-rows-2'}`}>
            {post.mediaUrls.map((url, i) => (
              <div key={i} className={`relative w-full min-h-[150px] max-h-[300px] bg-muted/30 ${post.mediaUrls && post.mediaUrls.length === 3 && i === 0 ? "col-span-2 row-span-2" : ""}`}>
                <img 
                  src={url.startsWith('http') ? url : `${API_BASE_URL}${url}`} 
                  alt="Post media" 
                  className="w-full h-full object-cover rounded-lg border border-muted" 
                />
              </div>
            ))}
          </div>
        )}

        {post.type === "POLL" && post.pollOptions && (
          <div className="space-y-2 mb-4 pointer-events-none">
             {post.pollOptions.map((opt, i) => (
               <div key={i} className={`relative h-10 border rounded-lg overflow-hidden flex items-center px-4 ${opt.isWinner ? 'bg-primary/10 border-primary/20 text-primary' : 'bg-muted/30 border-muted'}`}>
                 <div className={`absolute top-0 left-0 bottom-0 z-0 ${opt.isWinner ? 'bg-primary/20' : 'bg-muted'}`} style={{ width: `${opt.percentage}%` }}></div>
                 <span className="relative z-10 font-bold text-sm">{opt.label}</span>
                 <span className="relative z-10 ml-auto font-bold text-sm">{opt.percentage}%</span>
               </div>
             ))}
          </div>
        )}
      </div>

      <div className="relative z-20 flex items-center gap-6 border-t border-muted/50 pt-3 mt-2">
         <button 
           onClick={handleUpvote}
           disabled={isLoading}
           className={`flex items-center gap-1.5 transition-colors group ${isUpvoted ? 'text-success' : 'text-muted-foreground hover:text-success'}`}
         >
           <div className={`p-1.5 rounded-full ${isUpvoted ? 'bg-success/10' : 'group-hover:bg-success/10'}`}>
             <svg width="18" height="18" viewBox="0 0 24 24" fill={isUpvoted ? "currentColor" : "none"} stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M12 19V5"></path><path d="M5 12l7-7 7 7"></path></svg>
           </div>
           <span className="font-bold text-sm">{upvotes}</span>
         </button>
         
         <button className="flex items-center gap-1.5 text-muted-foreground hover:text-primary transition-colors group">
           <div className="p-1.5 rounded-full group-hover:bg-primary/10">
             <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path></svg>
           </div>
           <span className="font-bold text-sm">{post.stats.comments}</span>
         </button>

         <button className="flex items-center gap-1.5 text-muted-foreground hover:text-blue-500 transition-colors group">
           <div className="p-1.5 rounded-full group-hover:bg-blue-500/10">
             <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><circle cx="18" cy="5" r="3"></circle><circle cx="6" cy="12" r="3"></circle><circle cx="18" cy="19" r="3"></circle><line x1="8.59" y1="13.51" x2="15.42" y2="17.49"></line><line x1="15.41" y1="6.51" x2="8.59" y2="10.49"></line></svg>
           </div>
         </button>

         <button 
           onClick={handleBookmark}
           disabled={isLoading}
           className={`flex items-center gap-1.5 ml-auto transition-colors group ${isBookmarked ? 'text-amber-500' : 'text-muted-foreground hover:text-amber-500'}`}
         >
           <div className={`p-1.5 rounded-full ${isBookmarked ? 'bg-amber-500/10' : 'group-hover:bg-amber-500/10'}`}>
             <svg width="18" height="18" viewBox="0 0 24 24" fill={isBookmarked ? "currentColor" : "none"} stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"></path></svg>
           </div>
         </button>
      </div>
    </article>
  );
}
