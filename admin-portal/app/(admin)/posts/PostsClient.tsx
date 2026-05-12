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
const EASE_IN  = [0.7, 0, 0.84, 0] as const;

const backdropVariants = {
  hidden: { opacity: 0 },
  show:   { opacity: 1, transition: { duration: 0.25, ease: EASE_OUT } },
  exit:   { opacity: 0, transition: { duration: 0.2,  ease: EASE_IN  } },
};

const drawerVariants = {
  hidden: { x: '100%', opacity: 0 },
  show:   { x: 0, opacity: 1, transition: { type: 'spring' as const, stiffness: 280, damping: 28, mass: 0.9 } },
  exit:   { x: '100%', opacity: 0, transition: { duration: 0.22, ease: EASE_IN } },
};

const drawerItemVariants = {
  hidden: { opacity: 0, x: 18 },
  show:   { opacity: 1, x: 0, transition: { duration: 0.28, ease: EASE_OUT } },
};

const drawerContentVariants = {
  show: { transition: { staggerChildren: 0.07, delayChildren: 0.08 } },
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
    opacity: 1, scale: 1, y: 0, rotateZ: 0,
    transition: { type: 'spring' as const, stiffness: 520, damping: 26, mass: 0.7 },
  },
  exit: { opacity: 0, scale: 0.92, y: 16, transition: { duration: 0.2 } },
};

const deleteContentVariants = {
  show: { transition: { staggerChildren: 0.08, delayChildren: 0.05 } },
};

const deleteItemVariants = {
  hidden: { opacity: 0, y: 8 },
  show:   { opacity: 1, y: 0, transition: { duration: 0.22, ease: EASE_OUT } },
};

interface Comment {
  id: string;
  content: string;
  likes_count: number;
  created_at: string;
  author: string;
  author_email: string | null;
  is_reply: boolean;
}

interface Post {
  id: string;
  title: string | null;
  content: string;
  category: string | null;
  likes_count: number | null;
  comments_count: number | null;
  image_urls: string[] | null;
  created_at: string;
  user_id: string;
  author: { display_name: string | null; email: string | null; avatar_url: string | null } | null;
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
          (p.author?.display_name?.toLowerCase() ?? '').includes(search.toLowerCase());
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

  const display = selectedPost;

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
                        <p className="text-sm font-medium text-gray-800">{p.author?.display_name || p.author?.email || 'Unknown'}</p>
                        {p.author?.display_name && p.author?.email && (
                          <p className="text-xs text-gray-400">{p.author.email}</p>
                        )}
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
                        <Badge variant={categoryBadgeVariant[cat] ?? 'default'}>
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

      {/* ── Right-side Detail Drawer ── */}
      <AnimatePresence>
        {display && (
          <motion.div className="fixed inset-0 z-50 flex justify-end">
            {/* Backdrop */}
            <motion.div
              className="absolute inset-0 bg-black/40 backdrop-blur-[2px]"
              onClick={() => setSelectedPost(null)}
              variants={backdropVariants}
              initial="hidden"
              animate="show"
              exit="exit"
            />

            {/* Drawer panel */}
            <motion.div
              className="relative flex h-full w-full max-w-lg flex-col bg-white shadow-2xl"
              variants={drawerVariants}
              initial="hidden"
              animate="show"
              exit="exit"
            >
              {/* Branded header */}
              <div
                className="relative flex-shrink-0 overflow-hidden px-6 pb-5 pt-6"
                style={{ background: 'linear-gradient(135deg, #0B1629 0%, #1a3a38 55%, #2C6E69 100%)' }}
              >
                <motion.div
                  className="pointer-events-none absolute inset-0 skew-x-[-20deg] bg-white/5"
                  animate={{ x: ['-120%', '220%'] }}
                  transition={{ duration: 4, repeat: Infinity, ease: 'easeInOut', repeatDelay: 3 }}
                />
                <div className="pointer-events-none absolute -right-8 -top-8 h-40 w-40 rounded-full bg-white/5" />

                <button
                  type="button"
                  onClick={() => setSelectedPost(null)}
                  className="absolute right-4 top-4 rounded-xl p-2 text-white/60 transition hover:bg-white/10 hover:text-white"
                  aria-label="Close"
                >
                  <X className="h-5 w-5" />
                </button>

                <div className="relative flex items-start gap-4">
                  {/* Author avatar */}
                  <div
                    className="flex h-14 w-14 flex-shrink-0 items-center justify-center rounded-2xl text-xl font-black text-white ring-2 ring-white/30 shadow-lg"
                    style={{ background: 'linear-gradient(135deg, #0B1629, #1a3a5c)' }}
                  >
                    {(display.author?.display_name || display.author?.email || '?')[0].toUpperCase()}
                  </div>
                  <div className="min-w-0 flex-1 pr-8">
                    <p className="text-lg font-black leading-tight text-white truncate">
                      {display.title || 'Post Details'}
                    </p>
                    <p className="mt-0.5 text-sm text-white/55 truncate">
                      by {display.author?.display_name || display.author?.email || 'Unknown'}
                    </p>
                    <div className="mt-2 flex flex-wrap items-center gap-2">
                      <span className="inline-flex items-center rounded-full bg-white/15 px-2.5 py-0.5 text-[11px] font-semibold capitalize text-white ring-1 ring-white/20">
                        {display.category ?? 'general'}
                      </span>
                      <span className="inline-flex items-center gap-1 rounded-full bg-white/10 px-2.5 py-0.5 text-[11px] font-semibold text-white ring-1 ring-white/15">
                        <Heart className="h-3 w-3 fill-white/70" />
                        {display.likes_count ?? 0}
                      </span>
                      <span className="inline-flex items-center gap-1 rounded-full bg-white/10 px-2.5 py-0.5 text-[11px] font-semibold text-white ring-1 ring-white/15">
                        <MessageSquare className="h-3 w-3" />
                        {display.comments_count ?? 0}
                      </span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Scrollable body */}
              <motion.div
                className="flex-1 overflow-y-auto"
                variants={drawerContentVariants}
                initial="hidden"
                animate="show"
              >
                <div className="space-y-4 p-6">

                  {/* Author Card */}
                  <motion.div
                    className="relative overflow-hidden rounded-2xl border border-[#0B1629]/10 bg-[#0B1629]/5 p-4 shadow-sm"
                    style={{ borderLeft: '3px solid #0B1629' }}
                    variants={drawerItemVariants}
                  >
                    <div className="mb-2 flex items-center gap-2">
                      <div className="flex h-6 w-6 items-center justify-center rounded-lg bg-[#0B1629]/10">
                        <MessageSquare className="h-3.5 w-3.5 text-[#0B1629]" />
                      </div>
                      <h3 className="text-[11px] font-bold uppercase tracking-widest text-[#0B1629]/70">Author</h3>
                    </div>
                    <div className="flex items-center gap-3 rounded-xl bg-white/70 px-4 py-3 shadow-sm">
                      <div
                        className="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-xl text-sm font-black text-white shadow-sm"
                        style={{ background: 'linear-gradient(135deg, #0B1629, #1a3a5c)' }}
                      >
                        {(display.author?.display_name || display.author?.email || '?')[0].toUpperCase()}
                      </div>
                      <div className="min-w-0">
                        <p className="font-bold text-gray-900 text-sm truncate">{display.author?.display_name || 'Unknown'}</p>
                        <p className="text-xs text-gray-400 truncate">{display.author?.email || '—'}</p>
                      </div>
                    </div>
                    <p className="mt-2 text-xs text-gray-400 px-1">Posted {formatDateTime(display.created_at)}</p>
                  </motion.div>

                  {/* Post Content */}
                  <motion.div variants={drawerItemVariants}>
                    <p className="mb-2 text-[11px] font-bold uppercase tracking-widest text-[#0B1629]/70">Post Content</p>
                    <div
                      className="rounded-2xl border border-[#0B1629]/10 bg-[#0B1629]/5 p-4"
                      style={{ borderLeft: '3px solid #0B1629' }}
                    >
                      <p className="text-sm leading-relaxed text-gray-700 whitespace-pre-wrap">
                        {display.content}
                      </p>
                    </div>
                  </motion.div>

                  {/* Images */}
                  {display.image_urls && display.image_urls.length > 0 && (
                    <motion.div variants={drawerItemVariants}>
                      <p className="mb-2 text-[11px] font-bold uppercase tracking-widest text-[#0B1629]/70">Images</p>
                      <div className={`grid gap-2 ${display.image_urls.length === 1 ? 'grid-cols-1' : 'grid-cols-2'}`}>
                        {display.image_urls.map((url, i) => (
                          <motion.div
                            key={`${url}-${i}`}
                            className="overflow-hidden rounded-xl shadow-sm"
                            whileHover={{ scale: 1.02 }}
                          >
                            <img src={url} alt={`Post image ${i + 1}`} className="h-32 w-full object-cover" />
                          </motion.div>
                        ))}
                      </div>
                    </motion.div>
                  )}

                  {/* Comments Section */}
                  <motion.div variants={drawerItemVariants}>
                    <div className="mb-3 flex items-center gap-2">
                      <div className="flex h-6 w-6 items-center justify-center rounded-lg bg-[#0B1629]/10">
                        <MessageSquare className="h-3.5 w-3.5 text-[#0B1629]" />
                      </div>
                      <p className="text-sm font-bold text-gray-800">
                        Comments
                        <span className="ml-1.5 rounded-full bg-[#0B1629]/10 px-2 py-0.5 text-xs font-semibold text-[#0B1629]">
                          {display.comments.length}
                        </span>
                      </p>
                    </div>
                    <div className="h-px bg-gradient-to-r from-[#0B1629]/20 to-transparent mb-3" />

                    {display.comments.length === 0 ? (
                      <p className="rounded-xl bg-gray-50 py-6 text-center text-sm text-gray-400">
                        No comments yet
                      </p>
                    ) : (
                      <div className="space-y-2.5">
                        {display.comments.map((c, ci) => (
                          <motion.div
                            key={c.id}
                            className="group relative overflow-hidden rounded-xl border border-gray-100 bg-white p-3.5 shadow-sm transition-shadow hover:shadow-md"
                            style={{ borderLeft: '3px solid #0B1629' }}
                            initial={{ opacity: 0, y: 8 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ duration: 0.22, ease: EASE_OUT, delay: 0.05 + ci * 0.06 }}
                          >
                            <div className="flex items-start justify-between gap-2">
                              <div className="flex items-start gap-2.5 min-w-0">
                                <div
                                  className="flex h-7 w-7 flex-shrink-0 items-center justify-center rounded-full text-[10px] font-black text-white"
                                  style={{ background: `hsl(${(c.author.charCodeAt(0) * 37) % 360}, 55%, 45%)` }}
                                >
                                  {c.author[0]?.toUpperCase() ?? '?'}
                                </div>
                                <div className="min-w-0">
                                  <div className="flex items-center gap-2 flex-wrap">
                                    <span className="text-xs font-bold text-gray-800">{c.author}</span>
                                    {c.author_email && c.author_email !== c.author && (
                                      <span className="text-[10px] text-gray-400">{c.author_email}</span>
                                    )}
                                    <span className="text-[10px] text-gray-400">{timeAgo(c.created_at)}</span>
                                    {c.is_reply && (
                                      <span className="rounded-full bg-blue-50 px-1.5 py-0.5 text-[10px] font-semibold text-blue-400">reply</span>
                                    )}
                                    {c.likes_count > 0 && (
                                      <span className="inline-flex items-center gap-0.5 rounded-full bg-rose-50 px-1.5 py-0.5 text-[10px] font-semibold text-rose-400">
                                        <Heart className="h-2.5 w-2.5 fill-rose-400" />
                                        {c.likes_count}
                                      </span>
                                    )}
                                  </div>
                                  <p className="mt-1 text-sm text-gray-600 leading-snug">{c.content}</p>
                                </div>
                              </div>
                              <motion.button
                                onClick={() => handleDeleteComment(c.id)}
                                disabled={isPending}
                                className="flex-shrink-0 rounded-lg p-1.5 text-gray-300 opacity-0 transition-all group-hover:opacity-100 hover:bg-red-50 hover:text-red-500 disabled:opacity-30"
                                title="Delete comment"
                                whileHover={{ scale: 1.1 }}
                                whileTap={{ scale: 0.9 }}
                              >
                                <Trash2 className="h-3.5 w-3.5" />
                              </motion.button>
                            </div>
                          </motion.div>
                        ))}
                      </div>
                    )}
                  </motion.div>

                </div>
              </motion.div>

              {/* Sticky footer */}
              <div className="flex-shrink-0 flex flex-wrap items-center justify-between gap-3 border-t border-gray-100 bg-gray-50/80 px-6 py-4">
                <motion.button
                  type="button"
                  onClick={() => setSelectedPost(null)}
                  className="rounded-xl border border-gray-200 bg-white px-5 py-2.5 text-sm font-medium text-gray-600 transition hover:bg-gray-100"
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.97 }}
                >
                  Close
                </motion.button>
                <motion.button
                  onClick={() => { setSelectedPost(null); setDeleteTarget(display); }}
                  disabled={isPending}
                  className="flex items-center gap-2 rounded-xl bg-red-500 px-5 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-red-600 disabled:opacity-50"
                  whileHover={!isPending ? { scale: 1.02, x: [0, -2, 2, -1, 1, 0] } : {}}
                  whileTap={!isPending ? { scale: 0.97 } : {}}
                  transition={{ duration: 0.35 }}
                >
                  <Trash2 className="h-4 w-4" />
                  Delete Post
                </motion.button>
              </div>
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
  const author = post?.author?.display_name || post?.author?.email || 'Unknown';
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
                  <p className="text-sm font-semibold text-gray-900 truncate">{author}</p>
                  <p className="text-xs text-gray-500 truncate">{preview || 'No content'}</p>
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
                    <span className="inline-flex items-center justify-center gap-2">
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
