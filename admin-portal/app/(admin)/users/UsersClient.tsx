'use client';

import { useState, useMemo, useTransition, type ReactNode } from 'react';
import { motion } from 'framer-motion';
import { Search, Trash2, Eye, X, UserRound } from 'lucide-react';
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
        transition={{ duration: 0.35, ease: 'easeOut' }}
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
        transition={{ duration: 0.35, ease: 'easeOut', delay: 0.05 }}
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
                filtered.map((u, i) => (
                  <motion.tr
                    key={u.id}
                    className="border-b border-gray-50 last:border-0 hover:bg-gray-50/50 transition-colors"
                    initial={{ opacity: 0, x: -12 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ duration: 0.25, ease: 'easeOut', delay: i * 0.04 }}
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
                        <button onClick={() => setSelectedUser(u)} className="rounded-lg p-1.5 text-gray-400 hover:bg-gray-100 hover:text-[#2C6E69] transition-colors" title="View details">
                          <Eye className="h-4 w-4" />
                        </button>
                        <button onClick={() => setDeleteTarget(u)} className="rounded-lg p-1.5 text-gray-400 hover:bg-red-50 hover:text-red-500 transition-colors" title="Delete user">
                          <Trash2 className="h-4 w-4" />
                        </button>
                      </div>
                    </td>
                  </motion.tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </motion.div>

      {/* Detail Modal */}
      {selectedUser && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6">
          <div
            className="absolute inset-0 bg-black/30 backdrop-blur-[1px]"
            onClick={() => setSelectedUser(null)}
          />
          <div className="relative w-full max-w-2xl overflow-hidden rounded-3xl bg-white shadow-2xl ring-1 ring-black/5">
            <div className="flex items-start justify-between gap-4 border-b border-gray-100 px-6 py-5">
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
            </div>

            <div className="max-h-[70vh] overflow-y-auto p-6">
              <div className="grid gap-4 sm:grid-cols-2">
                <section className="rounded-2xl border border-gray-100 bg-gray-50/70 p-4">
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
                  </div>
                </section>

                <section className="rounded-2xl border border-gray-100 bg-gray-50/70 p-4">
                  <h3 className="text-[11px] font-semibold uppercase tracking-widest text-gray-400">
                    Engagement
                  </h3>
                  <div className="mt-3 grid grid-cols-2 gap-3">
                    <InfoItem label="Pets" value={String(selectedUser.pets_count)} />
                    <InfoItem label="Posts" value={String(selectedUser.posts_count)} />
                  </div>
                </section>

                <section className="rounded-2xl border border-gray-100 bg-gray-50/70 p-4 sm:col-span-2">
                  <h3 className="text-[11px] font-semibold uppercase tracking-widest text-gray-400">
                    Identifiers
                  </h3>
                  <div className="mt-3">
                    <p className="text-xs font-medium text-gray-400">User ID</p>
                    <p className="mt-1 text-sm font-medium text-gray-700 break-all">
                      {selectedUser.id}
                    </p>
                  </div>
                </section>
              </div>
            </div>

            <div className="flex flex-wrap items-center justify-between gap-3 border-t border-gray-100 bg-white/80 px-6 py-4">
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
            </div>
          </div>
        </div>
      )}

      {/* Delete Confirmation Modal */}
      {deleteTarget && (
        <div className="fixed inset-0 z-[60] flex items-center justify-center">
          <div className="absolute inset-0 bg-black/30" onClick={() => !isPending && setDeleteTarget(null)} />
          <div className="relative w-full max-w-sm rounded-2xl bg-white p-6 shadow-xl">
            <h3 className="text-lg font-semibold text-gray-800">Delete User?</h3>
            <p className="mt-2 text-sm text-gray-500">
              This will permanently delete <strong>{deleteTarget.display_name || deleteTarget.email}</strong> and all their associated data (pets, posts, comments, etc.). This cannot be undone.
            </p>
            <div className="mt-6 flex gap-3">
              <button
                disabled={isPending}
                onClick={() => setDeleteTarget(null)}
                className="flex-1 rounded-xl border border-gray-200 py-2.5 text-sm font-medium text-gray-600 hover:bg-gray-50 transition-colors disabled:opacity-50"
              >
                Cancel
              </button>
              <button
                disabled={isPending}
                onClick={() => handleDelete(deleteTarget)}
                className="flex-1 rounded-xl bg-red-500 py-2.5 text-sm font-medium text-white hover:bg-red-600 transition-colors disabled:opacity-50"
              >
                {isPending ? 'Deleting...' : 'Delete'}
              </button>
            </div>
          </div>
        </div>
      )}
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
