'use client';

import { useState, useMemo, useTransition } from 'react';
import { Search, Trash2, MessageSquare, Heart } from 'lucide-react';
import { timeAgo, truncate } from '@/lib/utils';
import Badge from '@/components/Badge';
import { deletePost } from './actions';

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

interface Post {
  id: string;
  content: string;
  category: string | null;
  likes_count: number | null;
  comments_count: number | null;
  created_at: string;
  user_id: string;
  profiles: { full_name: string | null; email: string | null } | null;
}

export default function PostsClient({ posts: initialPosts }: { posts: Post[] }) {
  const [search, setSearch] = useState('');
  const [category, setCategory] = useState('all');
  const [posts, setPosts] = useState(initialPosts);
  const [isPending, startTransition] = useTransition();

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
      } else {
        alert('Failed to delete post: ' + result.error);
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
                <th className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">
                  Author
                </th>
                <th className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">
                  Content
                </th>
                <th className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">
                  Category
                </th>
                <th className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">
                  Engagement
                </th>
                <th className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">
                  Posted
                </th>
                <th className="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-500">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr>
                  <td colSpan={6} className="py-16 text-center text-sm text-gray-400">
                    No posts found
                  </td>
                </tr>
              ) : (
                filtered.map((p) => {
                  const cat = p.category ?? 'general';
                  return (
                    <tr
                      key={p.id}
                      className="border-b border-gray-50 last:border-0 hover:bg-gray-50/50 transition-colors"
                    >
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
                        {truncate(p.content, 80)}
                      </td>
                      <td className="px-4 py-3">
                        <Badge variant={categoryBadgeVariant[cat] ?? 'default'}>
                          {cat}
                        </Badge>
                      </td>
                      <td className="px-4 py-3">
                        <div className="flex items-center gap-3 text-gray-500">
                          <span className="flex items-center gap-1">
                            <Heart className="h-3.5 w-3.5" />
                            {p.likes_count ?? 0}
                          </span>
                          <span className="flex items-center gap-1">
                            <MessageSquare className="h-3.5 w-3.5" />
                            {p.comments_count ?? 0}
                          </span>
                        </div>
                      </td>
                      <td className="px-4 py-3 text-xs text-gray-500">
                        {timeAgo(p.created_at)}
                      </td>
                      <td className="px-4 py-3 text-center">
                        <button
                          onClick={() => handleDelete(p.id)}
                          disabled={isPending}
                          className="rounded-lg p-1.5 text-gray-400 transition-colors hover:bg-red-50 hover:text-red-500 disabled:opacity-50"
                          title="Delete post"
                        >
                          <Trash2 className="h-4 w-4" />
                        </button>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>
    </>
  );
}
