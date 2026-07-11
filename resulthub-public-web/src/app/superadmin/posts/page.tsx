"use client";

import { useCallback, useEffect, useState } from "react";
import { api } from "@/lib/api";
import { RefreshCw, Trash2, FileText, ChevronLeft, ChevronRight } from "lucide-react";

function ConfirmModal({ title, desc, onConfirm, onCancel }: any) {
  return (
    <div className="fixed inset-0 bg-black/70 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div className="bg-[#141420] border border-white/10 rounded-2xl p-6 max-w-sm w-full shadow-2xl">
        <h3 className="text-lg font-black text-white mb-2">{title}</h3>
        <p className="text-sm text-white/50 mb-6">{desc}</p>
        <div className="flex gap-3 justify-end">
          <button onClick={onCancel} className="px-4 py-2 rounded-xl text-sm font-bold text-white/60 hover:text-white hover:bg-white/5 transition-all">Cancel</button>
          <button onClick={onConfirm} className="px-4 py-2 rounded-xl text-sm font-bold bg-red-500 hover:bg-red-400 text-white transition-all">Delete</button>
        </div>
      </div>
    </div>
  );
}

export default function PostsAdminPage() {
  const [posts, setPosts]         = useState<any[]>([]);
  const [loading, setLoading]     = useState(true);
  const [page, setPage]           = useState(0);
  const [totalPages, setTotalPages] = useState(0);
  const [totalItems, setTotalItems] = useState(0);
  const [confirm, setConfirm]     = useState<any>(null);
  const [toast, setToast]         = useState<string | null>(null);

  const showToast = (msg: string) => { setToast(msg); setTimeout(() => setToast(null), 3000); };

  const fetchPosts = useCallback(async () => {
    setLoading(true);
    const res = await api.admin.getPosts(page, 20).catch(() => null);
    if (res) {
      setPosts(res.content || []);
      setTotalPages(res.totalPages || 0);
      setTotalItems(res.totalElements || 0);
    }
    setLoading(false);
  }, [page]);

  useEffect(() => { fetchPosts(); }, [fetchPosts]);

  const handleDelete = (post: any) => {
    setConfirm({
      title: "Delete Post?",
      desc: "This permanently removes the post from the platform.",
      onConfirm: async () => {
        setConfirm(null);
        await api.admin.deletePost(post.id).catch(() => null);
        showToast("Post deleted");
        fetchPosts();
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
          <h1 className="text-3xl font-black text-white tracking-tight">Post Moderation</h1>
          <p className="text-white/40 text-sm font-medium mt-1">{totalItems.toLocaleString()} total posts</p>
        </div>
        <button onClick={fetchPosts} className="flex items-center gap-2 px-4 py-2 rounded-xl bg-white/5 border border-white/10 text-white/60 hover:text-white hover:bg-white/10 transition-all text-sm font-semibold">
          <RefreshCw className="w-4 h-4" /> Refresh
        </button>
      </div>

      <div className="bg-white/[0.02] border border-white/[0.06] rounded-2xl overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead>
              <tr className="border-b border-white/[0.06]">
                {["Content", "Type", "Likes", "Comments", "Created", "Action"].map(h => (
                  <th key={h} className="px-4 py-3.5 text-[10px] font-black text-white/30 uppercase tracking-widest whitespace-nowrap">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-white/[0.04]">
              {loading ? (
                [...Array(8)].map((_, i) => (
                  <tr key={i} className="animate-pulse">
                    {[...Array(6)].map((__, j) => (
                      <td key={j} className="px-4 py-4"><div className="h-3 bg-white/5 rounded w-full" /></td>
                    ))}
                  </tr>
                ))
              ) : posts.length === 0 ? (
                <tr>
                  <td colSpan={6} className="px-4 py-16 text-center">
                    <FileText className="w-12 h-12 text-white/10 mx-auto mb-3" />
                    <p className="text-white/30 text-sm font-semibold">No posts found</p>
                  </td>
                </tr>
              ) : posts.map(post => (
                <tr key={post.id} className="hover:bg-white/[0.02] transition-colors group">
                  <td className="px-4 py-3.5 text-[13px] text-white/70 max-w-[300px]">
                    <p className="truncate">{post.content || post.textContent || "—"}</p>
                  </td>
                  <td className="px-4 py-3.5">
                    <span className="text-[11px] font-bold text-white/50 bg-white/5 border border-white/10 px-2 py-0.5 rounded-md">
                      {post.postType || post.type || "POST"}
                    </span>
                  </td>
                  <td className="px-4 py-3.5 text-[12px] text-white/50 font-semibold">{post.likeCount ?? 0}</td>
                  <td className="px-4 py-3.5 text-[12px] text-white/50 font-semibold">{post.commentCount ?? 0}</td>
                  <td className="px-4 py-3.5 text-[12px] text-white/40 whitespace-nowrap">
                    {post.createdAt ? new Date(post.createdAt).toLocaleDateString() : "—"}
                  </td>
                  <td className="px-4 py-3.5">
                    <button onClick={() => handleDelete(post)} title="Delete"
                      className="p-1.5 rounded-lg hover:bg-white/5 text-white/30 hover:text-red-400 transition-all opacity-0 group-hover:opacity-100">
                      <Trash2 className="w-4 h-4" />
                    </button>
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
                className="p-2 rounded-lg bg-white/5 text-white/40 hover:text-white hover:bg-white/10 disabled:opacity-30 disabled:cursor-not-allowed">
                <ChevronLeft className="w-4 h-4" />
              </button>
              <button disabled={page >= totalPages - 1} onClick={() => setPage(p => p + 1)}
                className="p-2 rounded-lg bg-white/5 text-white/40 hover:text-white hover:bg-white/10 disabled:opacity-30 disabled:cursor-not-allowed">
                <ChevronRight className="w-4 h-4" />
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
