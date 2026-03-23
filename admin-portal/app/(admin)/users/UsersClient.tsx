'use client';

import { useState, useMemo, useTransition } from 'react';
import { Search, Trash2, Eye, X } from 'lucide-react';
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
      <div className="mb-4 flex flex-wrap items-center gap-3">
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
                  ? 'bg-[#2C6E69] text-white'
                  : 'text-gray-500 hover:text-gray-700'
              }`}
            >
              {btn.label}
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
                <th className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">User</th>
                <th className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">Role</th>
                <th className="px-4 py-3 text-center text-xs font-semibold uppercase tracking-wide text-gray-500">Pets</th>
                <th className="px-4 py-3 text-center text-xs font-semibold uppercase tracking-wide text-gray-500">Posts</th>
                <th className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">Joined</th>
                <th className="px-4 py-3 text-center text-xs font-semibold uppercase tracking-wide text-gray-500">Status</th>
                <th className="px-4 py-3 text-center text-xs font-semibold uppercase tracking-wide text-gray-500">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr>
                  <td colSpan={7} className="py-16 text-center text-sm text-gray-400">No users found</td>
                </tr>
              ) : (
                filtered.map((u) => (
                  <tr key={u.id} className="border-b border-gray-50 last:border-0 hover:bg-gray-50/50 transition-colors">
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-3">
                        {u.avatar_url ? (
                          <img src={u.avatar_url} alt="" className="h-8 w-8 rounded-full object-cover" />
                        ) : (
                          <div className="flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-full bg-[#B3E0DB] text-[#2C6E69] text-xs font-bold uppercase">
                            {(u.display_name || u.email || '?')[0]}
                          </div>
                        )}
                        <div>
                          <p className="font-medium text-gray-800">{u.display_name || '—'}</p>
                          <p className="text-xs text-gray-400">{u.email || '—'}</p>
                        </div>
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
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Detail Drawer */}
      {selectedUser && (
        <div className="fixed inset-0 z-50 flex justify-end">
          <div className="absolute inset-0 bg-black/20" onClick={() => setSelectedUser(null)} />
          <div className="relative w-full max-w-md bg-white shadow-xl overflow-y-auto">
            <div className="sticky top-0 flex items-center justify-between border-b bg-white px-6 py-4">
              <h2 className="text-lg font-semibold text-gray-800">User Details</h2>
              <button onClick={() => setSelectedUser(null)} className="rounded-lg p-1.5 hover:bg-gray-100 transition-colors">
                <X className="h-5 w-5 text-gray-500" />
              </button>
            </div>
            <div className="p-6 space-y-6">
              {/* Avatar + Name */}
              <div className="flex items-center gap-4">
                {selectedUser.avatar_url ? (
                  <img src={selectedUser.avatar_url} alt="" className="h-16 w-16 rounded-full object-cover" />
                ) : (
                  <div className="flex h-16 w-16 items-center justify-center rounded-full bg-[#B3E0DB] text-[#2C6E69] text-xl font-bold uppercase">
                    {(selectedUser.display_name || selectedUser.email || '?')[0]}
                  </div>
                )}
                <div>
                  <p className="text-lg font-semibold text-gray-800">{selectedUser.display_name || '—'}</p>
                  <p className="text-sm text-gray-500">{selectedUser.email || '—'}</p>
                </div>
              </div>

              {/* Info Grid */}
              <div className="grid grid-cols-2 gap-4">
                <InfoItem label="Account Type" value={selectedUser.account_type || 'user'} />
                <InfoItem label="Role" value={selectedUser.user_role || 'user'} />
                <InfoItem label="Status" value={selectedUser.is_active === false ? 'Inactive' : 'Active'} />
                <InfoItem label="Joined" value={formatDateTime(selectedUser.created_at)} />
                <InfoItem label="Pets" value={String(selectedUser.pets_count)} />
                <InfoItem label="Posts" value={String(selectedUser.posts_count)} />
              </div>

              <div className="text-xs text-gray-400 break-all">
                <span className="font-medium text-gray-500">ID:</span> {selectedUser.id}
              </div>

              {/* Delete Button */}
              <button
                onClick={() => { setSelectedUser(null); setDeleteTarget(selectedUser); }}
                className="w-full rounded-xl border border-red-200 py-2.5 text-sm font-medium text-red-600 hover:bg-red-50 transition-colors"
              >
                Delete User
              </button>
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

function InfoItem({ label, value }: { label: string; value: string }) {
  return (
    <div>
      <p className="text-xs font-medium text-gray-400 uppercase tracking-wide">{label}</p>
      <p className="mt-0.5 text-sm text-gray-700">{value}</p>
    </div>
  );
}
