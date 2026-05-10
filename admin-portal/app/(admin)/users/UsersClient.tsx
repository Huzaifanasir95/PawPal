'use client';

import { useState, useMemo, useTransition, useEffect, type ReactNode } from 'react';
import { AnimatePresence, motion, useAnimation } from 'framer-motion';
import { Search, Trash2, Eye, X, UserRound, AlertTriangle } from 'lucide-react';
import { formatDateTime } from '@/lib/utils';
import { deleteUser } from '@/lib/admin-actions';

interface User {
  id: string;
  display_name: string | null;
  email: string | null;
  account_type: string | null;
  user_role: string | null;
  avatar_url: string | null;
  is_active: boolean | null;
  pets_count: number;
  posts_count: number;
  created_at: string;
  updated_at: string | null;
}

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

export default function UsersClient({ users: initialUsers }: { users: User[] }) {
  const [users, setUsers] = useState(initialUsers);
  const [search, setSearch] = useState('');
  const [roleFilter, setRoleFilter] = useState<string>('all');
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [isPending, startTransition] = useTransition();
  const [deleteTarget, setDeleteTarget] = useState<User | null>(null);

  const filtered = useMemo(() => {
    return users.filter((u) => {
      const matchesSearch =
        (u.display_name?.toLowerCase() ?? '').includes(search.toLowerCase()) ||
        (u.email?.toLowerCase() ?? '').includes(search.toLowerCase());
      const matchesRole =
        roleFilter === 'all' ||
        (roleFilter === 'vet' && u.account_type === 'vet') ||
        (roleFilter === 'user' && u.account_type !== 'vet') ||
        (roleFilter === 'admin' && u.user_role === 'admin');
      return matchesSearch && matchesRole;
    });
  }, [users, search, roleFilter]);

  const handleDelete = (user: User) => {
    startTransition(async () => {
      const res = await deleteUser(user.id);
      if (res.success) {
        setUsers((prev) => prev.filter((u) => u.id !== user.id));
        setDeleteTarget(null);
        setSelectedUser(null);
      } else {
        alert('Failed to delete user: ' + res.error);
      }
    });
  };

  const roleCounts = useMemo(() => {
    const all = users.length;
    const vets = users.filter((u) => u.account_type === 'vet').length;
    const admins = users.filter((u) => u.user_role === 'admin').length;
    const regular = all - vets;
    return { all, vets, admins, regular };
  }, [users]);

  const roleButtons = [
    { key: 'all', label: `All (${roleCounts.all})` },
    { key: 'user', label: `Users (${roleCounts.regular})` },
    { key: 'vet', label: `Vets (${roleCounts.vets})` },
    { key: 'admin', label: `Admins (${roleCounts.admins})` },
  ];

  return (
    <>
      {/* Filters */}
      <motion.div
        className="mb-4 flex flex-wrap items-center gap-3"
        initial="hidden"
        animate="show"
        variants={fadeUp}
        transition={{ duration: 0.35, ease: EASE_OUT }}
      >
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
          <input
            type="text"
            placeholder="Search users..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-64 rounded-xl border border-gray-200 bg-white py-2 pl-9 pr-4 text-sm text-gray-700 outline-none focus:border-[#2C6E69] focus:ring-1 focus:ring-[#2C6E69]"
          />
        </div>
        <div className="flex gap-1 rounded-xl border border-gray-200 bg-white p-1">
          {roleButtons.map((btn) => (
            <button
              key={btn.key}
              onClick={() => setRoleFilter(btn.key)}
              className={`rounded-lg px-3 py-1.5 text-xs font-medium transition-colors ${
                roleFilter === btn.key
                  ? 'bg-[#0B1629] text-white'
                  : 'text-gray-500 hover:text-gray-700'
              }`}
            >
              {btn.label}
            </button>
          ))}
        </div>
      </motion.div>

      {/* Table */}
      <motion.div
        className="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm"
        initial="hidden"
        animate="show"
        variants={fadeUp}
        transition={{ duration: 0.35, ease: EASE_OUT, delay: 0.05 }}
      >
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-100 bg-[#0B1629]">
                <th className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-widest text-white">User</th>
                <th className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-widest text-white">Role</th>
                <th className="px-4 py-3 text-center text-xs font-semibold uppercase tracking-widest text-white">Pets</th>
                <th className="px-4 py-3 text-center text-xs font-semibold uppercase tracking-widest text-white">Posts</th>
                <th className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-widest text-white">Joined</th>
                <th className="px-4 py-3 text-center text-xs font-semibold uppercase tracking-widest text-white">Status</th>
                <th className="px-4 py-3 text-center text-xs font-semibold uppercase tracking-widest text-white">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr>
                  <td colSpan={7} className="py-16 text-center text-sm text-gray-400">No users found</td>
                </tr>
              ) : (
                <AnimatePresence initial={false}>
                  {filtered.map((u, i) => (
                    <motion.tr
                      key={u.id}
                      className="border-b border-gray-50 last:border-0 hover:bg-gray-50/50 transition-colors"
                      initial={{ opacity: 0, x: -12 }}
                      animate={{ opacity: 1, x: 0 }}
                      exit={{ opacity: 0, x: -16, transition: { duration: 0.2 } }}
                      transition={{ duration: 0.25, ease: EASE_OUT, delay: i * 0.04 }}
                    >
                    <td className="px-4 py-3">
                      <div>
                        <p className="font-medium text-gray-800">{u.display_name || '—'}</p>
                        <p className="text-xs text-gray-400">{u.email || '—'}</p>
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      <span className={`inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium ${
                        u.account_type === 'vet'
                          ? 'bg-purple-100 text-purple-700'
                          : u.user_role === 'admin'
                          ? 'bg-red-100 text-red-700'
                          : 'bg-gray-100 text-gray-600'
                      }`}>
                        {u.account_type === 'vet' ? 'Vet' : u.user_role === 'admin' ? 'Admin' : 'User'}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-center text-gray-600">{u.pets_count}</td>
                    <td className="px-4 py-3 text-center text-gray-600">{u.posts_count}</td>
                    <td className="px-4 py-3 text-gray-600 whitespace-nowrap">{formatDateTime(u.created_at)}</td>
                    <td className="px-4 py-3 text-center">
                      <span className={`inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium ${
                        u.is_active === false ? 'bg-red-100 text-red-700' : 'bg-green-100 text-green-700'
                      }`}>
                        {u.is_active === false ? 'Inactive' : 'Active'}
                      </span>
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center justify-center gap-1">
                        <motion.button
                          onClick={() => setSelectedUser(u)}
                          className="rounded-lg p-1.5 text-gray-400 hover:bg-gray-100 hover:text-[#0B1629] transition-colors"
                          title="View details"
                          whileHover={{ scale: 1.08, y: -1 }}
                          whileTap={{ scale: 0.96 }}
                        >
                          <Eye className="h-4 w-4" />
                        </motion.button>
                        <motion.button
                          onClick={() => setDeleteTarget(u)}
                          className="rounded-lg p-1.5 text-gray-400 hover:bg-red-50 hover:text-red-500 transition-colors"
                          title="Delete user"
                          whileHover={{ x: [0, -1.5, 1.5, -1, 1, 0] }}
                          whileTap={{ scale: 0.95 }}
                          transition={{ duration: 0.35 }}
                        >
                          <Trash2 className="h-4 w-4" />
                        </motion.button>
                      </div>
                    </td>
                  </motion.tr>
                  ))}
                </AnimatePresence>
              )}
            </tbody>
          </table>
        </div>
      </motion.div>

      {/* Detail Modal */}
      <AnimatePresence>
        {selectedUser && (
          <motion.div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6">
            <motion.div
              className="absolute inset-0 bg-black/35 backdrop-blur-[2px]"
              onClick={() => setSelectedUser(null)}
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
                <div className="flex items-center gap-4">
                  {selectedUser.avatar_url ? (
                    <img
                      src={selectedUser.avatar_url}
                      alt=""
                      className="h-14 w-14 rounded-2xl object-cover"
                    />
                  ) : (
                    <div className="flex h-14 w-14 items-center justify-center rounded-2xl bg-gradient-to-br from-slate-100 to-slate-200 text-slate-400">
                      <UserRound className="h-6 w-6" />
                    </div>
                  )}
                  <div>
                    <p className="text-lg font-semibold text-gray-900">{selectedUser.display_name || '—'}</p>
                    <p className="text-sm text-gray-500">{selectedUser.email || '—'}</p>
                    <div className="mt-2 flex flex-wrap items-center gap-2 text-[11px]">
                      <span className="rounded-full bg-gray-100 px-2.5 py-1 font-semibold text-gray-600">
                        {selectedUser.account_type || 'user'}
                      </span>
                      <span className="rounded-full bg-gray-100 px-2.5 py-1 font-semibold text-gray-600">
                        {selectedUser.user_role || 'user'}
                      </span>
                      <span
                        className={`rounded-full px-2.5 py-1 font-semibold ${
                          selectedUser.is_active === false
                            ? 'bg-red-50 text-red-600'
                            : 'bg-emerald-50 text-emerald-600'
                        }`}
                      >
                        {selectedUser.is_active === false ? 'Inactive' : 'Active'}
                      </span>
                    </div>
                  </div>
                </div>
                <button
                  onClick={() => setSelectedUser(null)}
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
                <div className="grid gap-4 sm:grid-cols-2">
                  <motion.section
                    className="rounded-2xl border border-gray-100 bg-gray-50/70 p-4"
                    variants={modalItemVariants}
                  >
                    <h3 className="text-[11px] font-semibold uppercase tracking-widest text-gray-400">
                      Account
                    </h3>
                    <div className="mt-3 grid grid-cols-2 gap-3">
                      <InfoItem label="Account Type" value={selectedUser.account_type || 'user'} />
                      <InfoItem label="Role" value={selectedUser.user_role || 'user'} />
                      <InfoItem
                        label="Status"
                        value={selectedUser.is_active === false ? 'Inactive' : 'Active'}
                      />
                      <InfoItem label="Joined" value={formatDateTime(selectedUser.created_at)} />
                      <InfoItem
                        label="Last Active"
                        value={selectedUser.updated_at ? formatDateTime(selectedUser.updated_at) : '—'}
                      />
                    </div>
                  </motion.section>

                  <motion.section
                    className="rounded-2xl border border-gray-100 bg-gray-50/70 p-4"
                    variants={modalItemVariants}
                  >
                    <h3 className="text-[11px] font-semibold uppercase tracking-widest text-gray-400">
                      Engagement
                    </h3>
                    <div className="mt-3 grid grid-cols-2 gap-3">
                      <InfoItem label="Pets" value={String(selectedUser.pets_count)} />
                      <InfoItem label="Posts" value={String(selectedUser.posts_count)} />
                    </div>
                  </motion.section>

                  <motion.section
                    className="rounded-2xl border border-gray-100 bg-gray-50/70 p-4 sm:col-span-2"
                    variants={modalItemVariants}
                  >
                    <h3 className="text-[11px] font-semibold uppercase tracking-widest text-gray-400">
                      Identifiers
                    </h3>
                    <div className="mt-3">
                      <p className="text-xs font-medium text-gray-400">User ID</p>
                      <p className="mt-1 text-sm font-medium text-gray-700 break-all">
                        {selectedUser.id}
                      </p>
                    </div>
                  </motion.section>
                </div>
              </motion.div>

              <motion.div
                className="flex flex-wrap items-center justify-between gap-3 border-t border-gray-100 bg-white/80 px-6 py-4"
                variants={modalItemVariants}
                initial="hidden"
                animate="show"
              >
                <button
                  onClick={() => setSelectedUser(null)}
                  className="rounded-xl border border-gray-200 bg-white px-4 py-2 text-sm font-medium text-gray-700 transition hover:bg-gray-50"
                >
                  Close
                </button>
                <div className="flex items-center gap-2">
                  <button
                    type="button"
                    disabled
                    title="Edit coming soon"
                    className="rounded-xl border border-[#0B1629]/20 bg-[#0B1629]/10 px-4 py-2 text-sm font-semibold text-[#0B1629] opacity-60"
                  >
                    Edit
                  </button>
                  <button
                    onClick={() => { setSelectedUser(null); setDeleteTarget(selectedUser); }}
                    className="rounded-xl border border-red-200 bg-red-50 px-4 py-2 text-sm font-semibold text-red-600 transition hover:bg-red-100"
                  >
                    Delete
                  </button>
                </div>
              </motion.div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Delete Confirmation Modal */}
      <DeleteUserModal
        user={deleteTarget}
        open={!!deleteTarget}
        isPending={isPending}
        onCancel={() => !isPending && setDeleteTarget(null)}
        onConfirm={() => deleteTarget && handleDelete(deleteTarget)}
      />
    </>
  );
}

function InfoItem({ label, value }: { label: string; value: ReactNode }) {
  return (
    <div>
      <p className="text-[11px] font-semibold uppercase tracking-widest text-gray-400">{label}</p>
      <div className="mt-1 text-sm font-medium text-gray-800">{value}</div>
    </div>
  );
}

function DeleteUserModal({
  user,
  open,
  isPending,
  onCancel,
  onConfirm,
}: {
  user: User | null;
  open: boolean;
  isPending: boolean;
  onCancel: () => void;
  onConfirm: () => void;
}) {
  const warningControls = useAnimation();

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
      {open && user && (
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
                  <h3 className="text-lg font-semibold text-gray-900">Delete user?</h3>
                  <p className="mt-1 text-sm text-gray-500">
                    Are you sure you want to delete this user? This action cannot be undone.
                  </p>
                </div>
              </motion.div>

              <motion.div
                className="mt-4 flex items-center gap-3 rounded-2xl border border-red-100 bg-red-50/40 p-3"
                variants={deleteItemVariants}
              >
                {user.avatar_url ? (
                  <img src={user.avatar_url} alt="" className="h-10 w-10 rounded-xl object-cover" />
                ) : (
                  <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-white text-red-400 ring-1 ring-red-100">
                    <UserRound className="h-5 w-5" />
                  </div>
                )}
                <div className="min-w-0">
                  <p className="text-sm font-semibold text-gray-900 truncate">
                    {user.display_name || 'Unknown'}
                  </p>
                  <p className="text-xs text-gray-500 truncate">{user.email || '—'}</p>
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
