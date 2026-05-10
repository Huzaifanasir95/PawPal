'use client';

import { useState, useMemo, useTransition, useEffect } from 'react';
import { AnimatePresence, motion, useAnimation } from 'framer-motion';
import { Search, Trash2, MessageSquare, Heart, Eye, X, Image as ImageIcon, AlertTriangle } from 'lucide-react';
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

const fadeUp = {
  hidden: { opacity: 0, y: 12 },
  show: { opacity: 1, y: 0 },
};

const EASE_OUT = [0.16, 1, 0.3, 1] as const;
const EASE_IN = [0.7, 0, 0.84, 0] as const;

const backdropVariants = {
  hidden: { opacity: 0 },
  show: { opacity: 1, transition: { duration: 0.25, ease: EASE_OUT } },
  exit: { opacity: 0, transition: { duration: 0.2, ease: EASE_IN } },
};

const modalVariants = {
  hidden: { opacity: 0, scale: 0.82, y: 26, rotateX: -12, rotateZ: -1 },
  show: {
    opacity: 1,
    scale: 1,
    y: 0,
    rotateX: 0,
    rotateZ: 0,
    transition: { type: 'spring' as const, stiffness: 260, damping: 22, mass: 0.8 },
  },
  exit: { opacity: 0, scale: 0.9, y: 18, rotateX: 6, rotateZ: 1, transition: { duration: 0.2 } },
};

const modalContentVariants = {
  show: { transition: { staggerChildren: 0.08, delayChildren: 0.05 } },
};

const modalItemVariants = {
  hidden: { opacity: 0, y: 10 },
  show: { opacity: 1, y: 0, transition: { duration: 0.25, ease: EASE_OUT } },
};

const deleteBackdropVariants = {
  hidden: { opacity: 0, backgroundColor: 'rgba(220, 38, 38, 0.0)' },
  show: {
    opacity: 1,
    backgroundColor: ['rgba(220, 38, 38, 0.05)', 'rgba(220, 38, 38, 0.2)', 'rgba(220, 38, 38, 0.12)'],
    transition: { duration: 0.45, ease: EASE_OUT },
  },
  exit: { opacity: 0, backgroundColor: 'rgba(220, 38, 38, 0.0)', transition: { duration: 0.2 } },
};

const deleteModalVariants = {
  hidden: { opacity: 0, scale: 0.86, y: -8, rotateZ: -1 },
  show: {
    opacity: 1,
    scale: 1,
    y: 0,
    rotateZ: 0,
    transition: { type: 'spring' as const, stiffness: 520, damping: 26, mass: 0.7 },
  },
  exit: { opacity: 0, scale: 0.92, y: 16, transition: { duration: 0.2 } },
};

const deleteContentVariants = {
  show: { transition: { staggerChildren: 0.08, delayChildren: 0.05 } },
};

const deleteItemVariants = {
  hidden: { opacity: 0, y: 8 },
  show: { opacity: 1, y: 0, transition: { duration: 0.22, ease: EASE_OUT } },
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
  const [deleteTarget, setDeleteTarget] = useState<Post | null>(null);

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
    startTransition(async () => {
      const result = await deletePost(id);
      if (result.success) {
        setPosts((prev) => prev.filter((p) => p.id !== id));
        if (selectedPost?.id === id) setSelectedPost(null);
        setDeleteTarget(null);
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
      <motion.div
        className="mb-5 rounded-2xl border border-gray-100 bg-white p-4 shadow-sm"
        initial="hidden"
        animate="show"
        variants={fadeUp}
        transition={{ duration: 0.35, ease: 'easeOut' }}
      >
        <div className="flex flex-wrap items-center gap-3">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
            <input
              type="text"
              placeholder="Search posts..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-72 rounded-2xl border border-gray-200 bg-white py-2.5 pl-9 pr-4 text-sm text-gray-700 shadow-sm outline-none focus:border-[#0B1629] focus:ring-1 focus:ring-[#0B1629]"
            />
          </div>
          <div className="flex flex-wrap gap-2">
            {CATEGORIES.map((cat) => (
              <button
                key={cat}
                onClick={() => setCategory(cat)}
                className={`rounded-xl px-3.5 py-1.5 text-xs font-semibold transition-colors capitalize ${
                  category === cat
                    ? 'bg-[#0B1629] text-white shadow-sm'
                    : 'bg-gray-100 text-gray-600 hover:bg-[#0B1629]/5 hover:text-[#0B1629]'
                }`}
              >
                {cat}
              </button>
            ))}
          </div>
        </div>
      </motion.div>

      {/* Table */}
      <motion.div
        className="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm"
        initial="hidden"
        animate="show"
        variants={fadeUp}
        transition={{ duration: 0.35, ease: 'easeOut', delay: 0.05 }}
      >
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-100 bg-[#0B1629]">
                <th className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-widest text-white">Author</th>
                <th className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-widest text-white">Content</th>
                <th className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-widest text-white">Category</th>
                <th className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-widest text-white">Engagement</th>
                <th className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-widest text-white">Posted</th>
                <th className="px-4 py-3 text-center text-xs font-semibold uppercase tracking-widest text-white">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr>
                  <td colSpan={6} className="py-16 text-center text-sm text-gray-400">No posts found</td>
                </tr>
              ) : (
                filtered.map((p, i) => {
                  const cat = p.category ?? 'general';
                  return (
                    <motion.tr
                      key={p.id}
                      className="border-b border-gray-50 last:border-0 hover:bg-[#0B1629]/5 transition-colors"
                      initial={{ opacity: 0, x: -12 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ duration: 0.25, ease: 'easeOut', delay: i * 0.04 }}
                    >
                      <td className="px-4 py-3">
                        <div className="flex items-center gap-2">
                          <div className="flex h-7 w-7 flex-shrink-0 items-center justify-center rounded-full bg-[#0B1629]/10 text-[#0B1629] text-[10px] font-bold uppercase">
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
                        <Badge
                          variant={categoryBadgeVariant[cat] ?? 'default'}
                          className="bg-[#0B1629]/10 text-[#0B1629]"
                        >
                          {cat}
                        </Badge>
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
                          <motion.button
                            onClick={() => setSelectedPost(p)}
                            className="rounded-lg p-1.5 text-gray-400 hover:bg-[#0B1629]/10 hover:text-[#0B1629] transition-colors"
                            title="View details"
                            whileHover={{ scale: 1.08, y: -1 }}
                            whileTap={{ scale: 0.96 }}
                          >
                            <Eye className="h-4 w-4" />
                          </motion.button>
                          <motion.button
                            onClick={() => setDeleteTarget(p)}
                            disabled={isPending}
                            className="rounded-lg p-1.5 text-gray-400 hover:bg-red-50 hover:text-red-500 transition-colors disabled:opacity-50"
                            title="Delete post"
                            whileHover={!isPending ? { x: [0, -1.5, 1.5, -1, 1, 0] } : {}}
                            whileTap={!isPending ? { scale: 0.95 } : {}}
                            transition={{ duration: 0.35 }}
                          >
                            <Trash2 className="h-4 w-4" />
                          </motion.button>
                        </div>
                      </td>
                    </motion.tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </motion.div>

      {/* Detail Modal */}
      <AnimatePresence>
        {selectedPost && (
          <motion.div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6">
            <motion.div
              className="absolute inset-0 bg-black/35 backdrop-blur-[2px]"
              onClick={() => setSelectedPost(null)}
              variants={backdropVariants}
              initial="hidden"
              animate="show"
              exit="exit"
            />
            <motion.div
              className="relative w-full max-w-2xl overflow-hidden rounded-3xl bg-white shadow-2xl ring-1 ring-black/5"
              variants={modalVariants}
              initial="hidden"
              animate="show"
              exit="exit"
              style={{ transformOrigin: '85% 15%', transformPerspective: 1200 }}
            >
              <motion.div
                className="flex items-start justify-between gap-4 border-b border-gray-100 px-6 py-5"
                variants={modalItemVariants}
                initial="hidden"
                animate="show"
              >
                <div>
                  <h2 className="text-lg font-semibold text-gray-900">Post Details</h2>
                  <p className="text-xs text-gray-500">
                    {formatDateTime(selectedPost.created_at)} · {selectedPost.category ?? 'general'}
                  </p>
                </div>
                <button
                  onClick={() => setSelectedPost(null)}
                  className="rounded-xl p-2 text-gray-400 transition hover:bg-gray-100 hover:text-gray-700"
                  aria-label="Close"
                >
                  <X className="h-5 w-5" />
                </button>
              </motion.div>

              <motion.div
                className="max-h-[70vh] overflow-y-auto p-6"
                variants={modalContentVariants}
                initial="hidden"
                animate="show"
              >
                <div className="space-y-6">
                  <motion.div className="flex items-center gap-3" variants={modalItemVariants}>
                    <div className="flex h-10 w-10 items-center justify-center rounded-full bg-[#B3E0DB] text-[#2C6E69] text-sm font-bold uppercase">
                      {(selectedPost.profiles?.full_name || selectedPost.profiles?.email || '?')[0]}
                    </div>
                    <div className="min-w-0">
                      <p className="font-medium text-gray-800">
                        {selectedPost.profiles?.full_name || 'Unknown'}
                      </p>
                      <p className="text-xs text-gray-400 break-words">
                        {selectedPost.profiles?.email || '—'}
                      </p>
                    </div>
                  </motion.div>

                  <motion.div className="flex flex-wrap items-center gap-3" variants={modalItemVariants}>
                    <Badge variant={categoryBadgeVariant[selectedPost.category ?? 'general'] ?? 'default'}>
                      {selectedPost.category ?? 'general'}
                    </Badge>
                    <span className="flex items-center gap-1 text-sm text-gray-500">
                      <Heart className="h-4 w-4" />{selectedPost.likes_count ?? 0}
                    </span>
                    <span className="flex items-center gap-1 text-sm text-gray-500">
                      <MessageSquare className="h-4 w-4" />{selectedPost.comments_count ?? 0}
                    </span>
                  </motion.div>

                  <motion.div className="rounded-xl bg-gray-50 p-4" variants={modalItemVariants}>
                    <p className="text-sm text-gray-700 whitespace-pre-wrap">{selectedPost.content}</p>
                  </motion.div>

                  {selectedPost.image_urls && selectedPost.image_urls.length > 0 && (
                    <motion.div variants={modalItemVariants}>
                      <p className="text-xs font-medium text-gray-400 uppercase tracking-wide mb-2">Images</p>
                      <div className="grid grid-cols-2 gap-2">
                        {selectedPost.image_urls.map((url, i) => (
                          <img key={`${url}-${i}`} src={url} alt={`Post image ${i + 1}`} className="rounded-lg object-cover w-full h-32" />
                        ))}
                      </div>
                    </motion.div>
                  )}

                  <motion.div variants={modalItemVariants}>
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
                                  <span className="flex items-center gap-0.5 text-xs text-gray-400">
                                    <Heart className="h-3 w-3" />{c.likes_count}
                                  </span>
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
                  </motion.div>

                  <motion.button
                    onClick={() => { setSelectedPost(null); setDeleteTarget(selectedPost); }}
                    disabled={isPending}
                    className="w-full rounded-xl border border-red-200 py-2.5 text-sm font-medium text-red-600 hover:bg-red-50 transition-colors disabled:opacity-50"
                    variants={modalItemVariants}
                  >
                    {isPending ? 'Deleting...' : 'Delete Post'}
                  </motion.button>
                </div>
              </motion.div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Delete Confirmation Modal */}
      <DeletePostModal
        post={deleteTarget}
        open={!!deleteTarget}
        isPending={isPending}
        onCancel={() => !isPending && setDeleteTarget(null)}
        onConfirm={() => deleteTarget && handleDelete(deleteTarget.id)}
      />
    </>
  );
}

function DeletePostModal({
  post,
  open,
  isPending,
  onCancel,
  onConfirm,
}: {
  post: Post | null;
  open: boolean;
  isPending: boolean;
  onCancel: () => void;
  onConfirm: () => void;
}) {
  const warningControls = useAnimation();
  const author = post?.profiles?.full_name || post?.profiles?.email || 'Unknown';
  const preview = post ? truncate(post.content, 80) : '';

  useEffect(() => {
    if (open) {
      warningControls.start({
        scale: [1, 1.15, 1],
        rotate: [0, -8, 8, 0],
        transition: { duration: 0.5, ease: EASE_OUT },
      });
    }
  }, [open, warningControls]);

  return (
    <AnimatePresence>
      {open && post && (
        <motion.div className="fixed inset-0 z-[60] flex items-center justify-center p-4">
          <motion.div
            className="absolute inset-0 backdrop-blur-[2px]"
            onClick={onCancel}
            variants={deleteBackdropVariants}
            initial="hidden"
            animate="show"
            exit="exit"
          />
          <motion.div
            className="relative w-full max-w-md overflow-hidden rounded-3xl bg-white shadow-2xl ring-1 ring-red-200/40"
            variants={deleteModalVariants}
            initial="hidden"
            animate="show"
            exit="exit"
            style={{ transformOrigin: '85% 15%', transformPerspective: 1200 }}
          >
            <motion.div
              className="px-6 py-5"
              variants={deleteContentVariants}
              initial="hidden"
              animate="show"
            >
              <motion.div className="flex items-start gap-4" variants={deleteItemVariants}>
                <motion.div
                  className="flex h-12 w-12 items-center justify-center rounded-2xl bg-red-50 text-red-600 ring-1 ring-red-100"
                  animate={warningControls}
                >
                  <AlertTriangle className="h-6 w-6" />
                </motion.div>
                <div>
                  <h3 className="text-lg font-semibold text-gray-900">Delete post?</h3>
                  <p className="mt-1 text-sm text-gray-500">
                    Are you sure you want to delete this post? This action cannot be undone.
                  </p>
                </div>
              </motion.div>

              <motion.div
                className="mt-4 flex items-center gap-3 rounded-2xl border border-red-100 bg-red-50/40 p-3"
                variants={deleteItemVariants}
              >
                <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-white text-red-500 ring-1 ring-red-100 text-xs font-bold uppercase">
                  {author[0] || '?'}
                </div>
                <div className="min-w-0">
                  <p className="text-sm font-semibold text-gray-900 truncate">
                    {author}
                  </p>
                  <p className="text-xs text-gray-500 truncate">
                    {preview || 'No content'}
                  </p>
                </div>
              </motion.div>

              <motion.div className="mt-5 flex gap-3" variants={deleteItemVariants}>
                <button
                  disabled={isPending}
                  onClick={onCancel}
                  className="flex-1 rounded-xl border border-gray-200 bg-white py-2.5 text-sm font-medium text-gray-600 transition hover:bg-gray-50 disabled:opacity-50"
                >
                  Cancel
                </button>
                <motion.button
                  disabled={isPending}
                  onClick={onConfirm}
                  className="flex-1 rounded-xl bg-red-500 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-red-600 disabled:opacity-50"
                  whileHover={!isPending ? { scale: 1.02 } : {}}
                  whileTap={!isPending ? { scale: 0.98 } : {}}
                >
                  {isPending ? (
                    <span className="inline-flex items-center gap-2">
                      <span className="h-4 w-4 animate-spin rounded-full border-2 border-white/70 border-t-transparent" />
                      Deleting...
                    </span>
                  ) : (
                    'Delete'
                  )}
                </motion.button>
              </motion.div>
            </motion.div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
