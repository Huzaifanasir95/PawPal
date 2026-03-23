'use client';

import { useState, useMemo } from 'react';
import { Search } from 'lucide-react';
import { formatDateTime } from '@/lib/utils';

interface User {
  id: string;
  display_name: string | null;
  email: string | null;
  created_at: string;
  updated_at: string | null;
}

export default function UsersClient({ users }: { users: User[] }) {
  const [search, setSearch] = useState('');

  const filtered = useMemo(
    () =>
      users.filter(
        (u) =>
          (u.display_name?.toLowerCase() ?? '').includes(search.toLowerCase()) ||
          (u.email?.toLowerCase() ?? '').includes(search.toLowerCase())
      ),
    [users, search]
  );

  return (
    <>
      {/* Search */}
      <div className="mb-4 relative max-w-sm">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
        <input
          type="text"
          placeholder="Search users..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full rounded-xl border border-gray-200 bg-white py-2 pl-9 pr-4 text-sm text-gray-700 outline-none focus:border-[#2C6E69] focus:ring-1 focus:ring-[#2C6E69]"
        />
      </div>

      {/* Table */}
      <div className="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-100 bg-gray-50/60">
                <th className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">
                  User
                </th>
                <th className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">
                  Joined
                </th>
                <th className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">
                  Last Updated
                </th>
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr>
                  <td colSpan={3} className="py-16 text-center text-sm text-gray-400">
                    No users found
                  </td>
                </tr>
              ) : (
                filtered.map((u) => (
                  <tr
                    key={u.id}
                    className="border-b border-gray-50 last:border-0 hover:bg-gray-50/50 transition-colors"
                  >
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-3">
                        <div className="flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-full bg-[#B3E0DB] text-[#2C6E69] text-xs font-bold uppercase">
                          {(u.display_name || u.email || '?')[0]}
                        </div>
                        <div>
                          <p className="font-medium text-gray-800">
                            {u.display_name || '—'}
                          </p>
                          <p className="text-xs text-gray-400">{u.email || '—'}</p>
                        </div>
                      </div>
                    </td>
                    <td className="px-4 py-3 text-gray-600">
                      {formatDateTime(u.created_at)}
                    </td>
                    <td className="px-4 py-3 text-gray-600">
                      {formatDateTime(u.updated_at)}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </>
  );
}
