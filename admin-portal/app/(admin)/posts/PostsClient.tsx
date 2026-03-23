'use client';

import { useState, useMemo, useTransition } from 'react';
import { Search, Trash2, MessageSquare, Heart, Eye, X, Image as ImageIcon } from 'lucide-react';
import { timeAgo, truncate, formatDateTime } from '@/lib/utils';
import Badge from '@/components/Badge';
import { deletePost, deleteComment } from '@/lib/admin-actions';

const CATEGORIES = ['all', 'general', 'dogs', 'cats', 'health', 'training', 'nutrition', 'funny', 'questions'];

const categoryBadgeVariant: Record<string, 'default' | 'success' | 'warning' | 'danger' | 'info' | 'purple' | 'teal'> = {
  general: 'default',
  dogs: 'warning',
  cats: 'info',
  health: 'success',
  training: 'info',
  nutrition: 'purple',
  funny: 'warning',
  questions: 'teal',
};

interface Comment {
  id: string;
  content: string;
  likes_count: number;
  created_at: string;
  author: string;
}

interface Post {
  id: string;
  content: string;
  category: string | null;
  likes_count: number | null;
  comments_count: number | null;
  image_urls: string[] | null;
  created_at: string;
  user_id: string;
  profiles: { full_name: string | null; email: string | null } | null;
  comments: Comment[];
}

export default function PostsClient({ posts: initialPosts }: { posts: Post[] }) {
  const [search, setSearch] = useState('');
  const [category, setCategory] = useState('all');
  const [posts, setPosts] = useState(initialPosts);
  const [isPending, startTransition] = useTransition();
  const [selectedPost, setSelectedPost] = useState<Post | null>(null);

  const filtered = useMemo(
    () =>
      posts.filter((p) => {
        const matchesSearch =
          p.content.toLowerCase().includes(search.toLowerCase()) ||
          (p.profiles?.full_name?.toLowerCase() ?? '').includes(search.toLowerCase());
        const matchesCat =
          category === 'all' || (p.category ?? 'general') === category;
        return matchesSearch && matchesCat;
      }),
    [posts, search, category]
  );

  function handleDelete(id: string) {
    if (!confirm('Delete this post? This cannot be undone.')) return;
    startTransition(async () => {
      const result = await deletePost(id);
      if (result.success) {
        setPosts((prev) => prev.filter((p) => p.id !== id));
        if (selectedPost?.id === id) setSelectedPost(null);
      } else {
        alert('Failed to delete post: ' + result.error);
      }
    });
  }

  function handleDeleteComment(commentId: string) {
    if (!confirm('Delete this comment?')) return;
    startTransition(async () => {
      const result = await deleteComment(commentId);
      if (result.success) {
        setPosts((prev) =>
          prev.map((p) => ({
            ...p,
            comments: p.comments.filter((c) => c.id !== commentId),
            comments_count: (p.comments_count ?? 0) > 0 ? (p.comments_count ?? 0) - 1 : 0,
          }))
        );
        if (selectedPost) {
          setSelectedPost((prev) =>
            prev ? { ...prev, comments: prev.comments.filter((c) => c.id !== commentId), comments_count: (prev.comments_count ?? 0) > 0 ? (prev.comments_count ?? 0) - 1 : 0 } : null
          );
        }
      } else {
        alert('Failed to delete comment: ' + result.error);
      }
    });
  }

  return (
    <>
      {/* Filters */}
      <div className="mb-4 flex flex-wrap items-center gap-3">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
          <input
            type="text"
            placeholder="Search posts..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-64 rounded-xl border border-gray-200 bg-white py-2 pl-9 pr-4 text-sm text-gray-700 outline-none focus:border-[#2C6E69] focus:ring-1 focus:ring-[#2C6E69]"
          />
        </div>
        <div className="flex flex-wrap gap-1.5">
          {CATEGORIES.map((cat) => (
            <button
              key={cat}
              onClick={() => setCategory(cat)}
              className={`rounded-full px-3 py-1 text-xs font-medium transition-colors capitalize ${
                category === cat
                  ? 'bg-[#2C6E69] text-white'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              {cat}
            </button>
          ))}
        </div>
      </div>

      {/* Table */}
      <div className="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-100 bg-gray-50/60">
                <th className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">Author</th>
                <th className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">Content</th>
                <th className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">Category</th>
                <th className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">Engagement</th>
                <th className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">Posted</th>
                <th className="px-4 py-3 text-center text-xs font-semibold uppercase tracking-wide text-gray-500">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr>
                  <td colSpan={6} className="py-16 text-center text-sm text-gray-400">No posts found</td>
                </tr>
              ) : (
                filtered.map((p) => {
                  const cat = p.category ?? 'general';
                  return (
                    <tr key={p.id} className="border-b border-gray-50 last:border-0 hover:bg-gray-50/50 transition-colors">
                      <td className="px-4 py-3">
                        <div className="flex items-center gap-2">
                          <div className="flex h-7 w-7 flex-shrink-0 items-center justify-center rounded-full bg-[#B3E0DB] text-[#2C6E69] text-[10px] font-bold uppercase">
                            {(p.profiles?.full_name || p.profiles?.email || '?')[0]}
                          </div>
                          <span className="text-xs text-gray-600">
                            {p.profiles?.full_name || p.profiles?.email || 'Unknown'}
                          </span>
                        </div>
                      </td>
                      <td className="px-4 py-3 text-gray-700 max-w-xs">
                        <div className="flex items-center gap-2">
                          {truncate(p.content, 80)}
                          {p.image_urls && p.image_urls.length > 0 && (
                            <ImageIcon className="h-3.5 w-3.5 text-gray-400 flex-shrink-0" />
                          )}
                        </div>
                      </td>
                      <td className="px-4 py-3">
                        <Badge variant={categoryBadgeVariant[cat] ?? 'default'}>{cat}</Badge>
                      </td>
                      <td className="px-4 py-3">
                        <div className="flex items-center gap-3 text-gray-500">
                          <span className="flex items-center gap-1"><Heart className="h-3.5 w-3.5" />{p.likes_count ?? 0}</span>
                          <span className="flex items-center gap-1"><MessageSquare className="h-3.5 w-3.5" />{p.comments_count ?? 0}</span>
                        </div>
                      </td>
                      <td className="px-4 py-3 text-xs text-gray-500 whitespace-nowrap">{timeAgo(p.created_at)}</td>
                      <td className="px-4 py-3">
                        <div className="flex items-center justify-center gap-1">
                          <button onClick={() => setSelectedPost(p)} className="rounded-lg p-1.5 text-gray-400 hover:bg-gray-100 hover:text-[#2C6E69] transition-colors" title="View details">
                            <Eye className="h-4 w-4" />
                          </button>
                          <button onClick={() => handleDelete(p.id)} disabled={isPending} className="rounded-lg p-1.5 text-gray-400 hover:bg-red-50 hover:text-red-500 transition-colors disabled:opacity-50" title="Delete post">
                            <Trash2 className="h-4 w-4" />
                          </button>
                        </div>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Detail Drawer */}
      {selectedPost && (
        <div className="fixed inset-0 z-50 flex justify-end">
          <div className="absolute inset-0 bg-black/20" onClick={() => setSelectedPost(null)} />
          <div className="relative w-full max-w-lg bg-white shadow-xl overflow-y-auto">
            <div className="sticky top-0 flex items-center justify-between border-b bg-white px-6 py-4 z-10">
              <h2 className="text-lg font-semibold text-gray-800">Post Details</h2>
              <button onClick={() => setSelectedPost(null)} className="rounded-lg p-1.5 hover:bg-gray-100 transition-colors">
                <X className="h-5 w-5 text-gray-500" />
              </button>
            </div>
            <div className="p-6 space-y-6">
              {/* Author */}
              <div className="flex items-center gap-3">
                <div className="flex h-10 w-10 items-center justify-center rounded-full bg-[#B3E0DB] text-[#2C6E69] text-sm font-bold uppercase">
                  {(selectedPost.profiles?.full_name || selectedPost.profiles?.email || '?')[0]}
                </div>
                <div>
                  <p className="font-medium text-gray-800">{selectedPost.profiles?.full_name || 'Unknown'}</p>
                  <p className="text-xs text-gray-400">{selectedPost.profiles?.email || '—'} · {formatDateTime(selectedPost.created_at)}</p>
                </div>
              </div>

              {/* Category + Stats */}
              <div className="flex items-center gap-3">
                <Badge variant={categoryBadgeVariant[selectedPost.category ?? 'general'] ?? 'default'}>
                  {selectedPost.category ?? 'general'}
                </Badge>
                <span className="flex items-center gap-1 text-sm text-gray-500"><Heart className="h-4 w-4" />{selectedPost.likes_count ?? 0}</span>
                <span className="flex items-center gap-1 text-sm text-gray-500"><MessageSquare className="h-4 w-4" />{selectedPost.comments_count ?? 0}</span>
              </div>

              {/* Full Content */}
              <div className="rounded-xl bg-gray-50 p-4">
                <p className="text-sm text-gray-700 whitespace-pre-wrap">{selectedPost.content}</p>
              </div>

              {/* Images */}
              {selectedPost.image_urls && selectedPost.image_urls.length > 0 && (
                <div>
                  <p className="text-xs font-medium text-gray-400 uppercase tracking-wide mb-2">Images</p>
                  <div className="grid grid-cols-2 gap-2">
                    {selectedPost.image_urls.map((url, i) => (
                      <img key={i} src={url} alt={`Post image ${i + 1}`} className="rounded-lg object-cover w-full h-32" />
                    ))}
                  </div>
                </div>
              )}

              {/* Comments */}
              <div>
                <p className="text-xs font-medium text-gray-400 uppercase tracking-wide mb-3">
                  Comments ({selectedPost.comments.length})
                </p>
                {selectedPost.comments.length === 0 ? (
                  <p className="text-sm text-gray-400">No comments yet</p>
                ) : (
                  <div className="space-y-3">
                    {selectedPost.comments.map((c) => (
                      <div key={c.id} className="rounded-lg border border-gray-100 p-3">
                        <div className="flex items-center justify-between mb-1">
                          <div className="flex items-center gap-2">
                            <span className="text-xs font-medium text-gray-700">{c.author}</span>
                            <span className="text-xs text-gray-400">{timeAgo(c.created_at)}</span>
                            {c.likes_count > 0 && (
                              <span className="flex items-center gap-0.5 text-xs text-gray-400"><Heart className="h-3 w-3" />{c.likes_count}</span>
                            )}
                          </div>
                          <button
                            onClick={() => handleDeleteComment(c.id)}
                            disabled={isPending}
                            className="rounded p-1 text-gray-300 hover:bg-red-50 hover:text-red-500 transition-colors disabled:opacity-50"
                            title="Delete comment"
                          >
                            <Trash2 className="h-3.5 w-3.5" />
                          </button>
                        </div>
                        <p className="text-sm text-gray-600">{c.content}</p>
                      </div>
                    ))}
                  </div>
                )}
              </div>

              <div className="text-xs text-gray-400 break-all">
                <span className="font-medium text-gray-500">ID:</span> {selectedPost.id}
              </div>

              {/* Delete Button */}
              <button
                onClick={() => handleDelete(selectedPost.id)}
                disabled={isPending}
                className="w-full rounded-xl border border-red-200 py-2.5 text-sm font-medium text-red-600 hover:bg-red-50 transition-colors disabled:opacity-50"
              >
                {isPending ? 'Deleting...' : 'Delete Post'}
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
