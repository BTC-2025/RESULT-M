"use client";

import PostCard from "@/components/feed/PostCard";
import Link from "next/link";
import { useEffect, useState } from "react";
import { api } from "@/lib/api";
import { useParams } from "next/navigation";

export default function PostDetailPage() {
  const params = useParams();
  const postId = params.postId as string;
  
  const [mainPost, setMainPost] = useState<any>(null);
  const [comments, setComments] = useState<any[]>([]);
  const [newComment, setNewComment] = useState("");
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    if (postId) {
      fetchPostAndComments();
    }
  }, [postId]);

  const fetchPostAndComments = async () => {
    setIsLoading(true);
    try {
      const postRes = await api.posts.get(postId);
      setMainPost(postRes);
      const commentsRes = await api.posts.getComments(postId);
      setComments(commentsRes || []);
    } catch (error) {
      console.error("Failed to load post details", error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleReply = async () => {
    if (!newComment.trim() || isSubmitting || !postId) return;
    setIsSubmitting(true);
    try {
      await api.posts.addComment(postId, newComment.trim());
      setNewComment("");
      const commentsRes = await api.posts.getComments(postId);
      setComments(commentsRes || []);
    } catch (error) {
      console.error("Failed to post comment", error);
    } finally {
      setIsSubmitting(false);
    }
  };

  if (isLoading) {
    return (
      <div className="w-full flex justify-center items-center py-32">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-[#635BFF]"></div>
      </div>
    );
  }

  if (!mainPost) {
    return (
      <div className="w-full flex flex-col items-center justify-center py-32">
        <h2 className="text-xl font-black text-zinc-800 mb-2">Post not found</h2>
        <p className="text-zinc-500 font-medium mb-6">This post may have been deleted.</p>
        <Link href="/" className="px-6 py-2.5 bg-zinc-100 text-zinc-700 font-bold rounded-full hover:bg-zinc-200 transition-colors">
          Go back home
        </Link>
      </div>
    );
  }

  return (
    <div className="w-full pt-4 pb-24 lg:pb-8">
      
      {/* Back Button */}
      <Link href="/" className="flex items-center gap-3 text-zinc-500 hover:text-zinc-900 font-bold mb-6 transition-colors w-fit group">
        <div className="w-8 h-8 rounded-full bg-white border border-zinc-200 flex items-center justify-center group-hover:border-zinc-300 shadow-sm transition-all">
           <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><polyline points="15 18 9 12 15 6"></polyline></svg>
        </div>
        Back to Feed
      </Link>

      <div className="grid grid-cols-1 lg:grid-cols-[minmax(0,1fr)_400px] xl:grid-cols-[minmax(0,1fr)_450px] gap-6 items-start">
        
        {/* Post Detail (Middle) */}
        <div className="min-w-0 flex flex-col gap-6">
           <div className="shadow-sm rounded-2xl overflow-hidden bg-white border border-zinc-100">
             <PostCard post={mainPost} />
           </div>
        </div>

        {/* Comments Sidebar (Right) */}
        <div className="bg-white rounded-2xl shadow-sm border border-zinc-100 flex flex-col lg:sticky lg:top-5 lg:h-[calc(100vh-2.5rem)] overflow-hidden">
           
           {/* Header */}
           <div className="px-5 py-4 border-b border-zinc-100 flex items-center justify-between bg-white shrink-0">
             <h3 className="font-black text-lg text-zinc-800">Comments</h3>
             <span className="bg-zinc-100 text-zinc-600 text-xs font-bold px-2.5 py-1 rounded-full">
               {mainPost.commentCount || comments.length}
             </span>
           </div>

           {/* Comments List */}
           <div className="flex-1 overflow-y-auto p-5 space-y-5 hide-scrollbar">
             {comments.length === 0 && (
               <div className="text-sm font-medium text-zinc-400 text-center py-10">
                 No comments yet. Be the first to reply!
               </div>
             )}
             {comments.map(comment => (
               <div key={comment.id} className="flex gap-3 group">
                 <div className="w-9 h-9 rounded-full flex items-center justify-center font-bold text-sm shrink-0 bg-indigo-50 text-indigo-600 border border-indigo-100">
                   {comment.authorName?.substring(0, 1).toUpperCase() || "?"}
                 </div>
                 <div className="flex-1 min-w-0">
                    <div className="bg-zinc-50 border border-zinc-100 rounded-2xl rounded-tl-sm p-3.5 transition-colors group-hover:bg-zinc-100/50">
                       <div className="flex items-center gap-2 mb-1.5">
                         <h4 className="font-bold text-[13px] text-zinc-900 truncate">
                           {comment.authorName || "User"}
                         </h4>
                         <span className="text-[11px] font-semibold text-zinc-400 shrink-0 ml-auto">
                           {new Date(comment.createdAt).toLocaleDateString()}
                         </span>
                       </div>
                       <p className="text-[13px] leading-relaxed text-zinc-700 whitespace-pre-wrap word-break-word">
                         {comment.content}
                       </p>
                    </div>
                    <div className="flex items-center gap-4 mt-2 ml-2">
                       <button className="flex items-center gap-1.5 text-[11px] font-bold text-zinc-400 hover:text-[#635BFF] transition-colors">
                         <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M14 9V5a3 3 0 0 0-3-3l-4 9v11h11.28a2 2 0 0 0 2-1.7l1.38-9a2 2 0 0 0-2-2.3zM7 22H4a2 2 0 0 1-2-2v-7a2 2 0 0 1 2-2h3"></path></svg>
                         {comment.likeCount || 0}
                       </button>
                       <button className="flex items-center gap-1 text-[11px] font-bold text-zinc-400 hover:text-zinc-700 transition-colors">
                         Reply
                       </button>
                    </div>
                 </div>
               </div>
             ))}
           </div>

           {/* Comment Input */}
           <div className="p-4 border-t border-zinc-100 bg-zinc-50/50 shrink-0">
              <div className="flex gap-2">
                <input 
                  type="text" 
                  placeholder="Write a comment..." 
                  value={newComment}
                  onChange={(e) => setNewComment(e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && handleReply()}
                  className="flex-1 bg-white border border-zinc-200 focus:border-[#635BFF] focus:ring-1 focus:ring-[#635BFF] rounded-full px-4 py-2.5 text-[13px] font-medium outline-none transition-all shadow-sm"
                />
                <button 
                  onClick={handleReply} 
                  disabled={isSubmitting || !newComment.trim()} 
                  className="bg-[#635BFF] text-white text-[13px] font-bold px-4 py-2.5 rounded-full hover:bg-opacity-90 disabled:opacity-50 transition-colors shadow-sm flex items-center gap-1.5 shrink-0"
                >
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><line x1="22" y1="2" x2="11" y2="13"></line><polygon points="22 2 15 22 11 13 2 9 22 2"></polygon></svg>
                  Reply
                </button>
              </div>
           </div>
        </div>

      </div>
    </div>
  );
}
