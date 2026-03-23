'use client';

import { useState, useMemo, useTransition } from 'react';
import { Search, CheckCircle, XCircle, Star } from 'lucide-react';
import Badge from '@/components/Badge';
import { updateVetVerification } from './actions';

interface Vet {
  id: string;
  name: string;
  email: string | null;
  phone: string | null;
  specialization: string | null;
  clinic_name: string | null;
  clinic_address: string | null;
  years_of_experience: number | null;
  license_number: string | null;
  is_verified: boolean | null;
  is_available: boolean | null;
  rating: number | null;
  consultation_fee: number | null;
  created_at: string;
}

export default function VetsClient({ vets: initialVets }: { vets: Vet[] }) {
  const [search, setSearch] = useState('');
  const [filter, setFilter] = useState<'all' | 'verified' | 'pending'>('all');
  const [vets, setVets] = useState(initialVets);
  const [isPending, startTransition] = useTransition();

  const filtered = useMemo(
    () =>
      vets.filter((v) => {
        const matchSearch =
          v.name.toLowerCase().includes(search.toLowerCase()) ||
          (v.email?.toLowerCase() ?? '').includes(search.toLowerCase()) ||
          (v.clinic_name?.toLowerCase() ?? '').includes(search.toLowerCase());
        const matchFilter =
          filter === 'all'
            ? true
            : filter === 'verified'
            ? v.is_verified
            : !v.is_verified;
        return matchSearch && matchFilter;
      }),
    [vets, search, filter]
  );

  function handleToggleVerify(id: string, currentValue: boolean | null) {
    const newValue = !currentValue;
    startTransition(async () => {
      const result = await updateVetVerification(id, newValue);
      if (result.success) {
        setVets((prev) =>
          prev.map((v) => (v.id === id ? { ...v, is_verified: newValue } : v))
        );
      } else {
        alert('Failed to update: ' + result.error);
      }
    });
  }

  return (
    <>
      <div className="mb-4 flex flex-wrap items-center gap-3">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
          <input
            type="text"
            placeholder="Search vets..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-64 rounded-xl border border-gray-200 bg-white py-2 pl-9 pr-4 text-sm text-gray-700 outline-none focus:border-[#2C6E69] focus:ring-1 focus:ring-[#2C6E69]"
          />
        </div>
        <div className="flex gap-1.5">
          {(['all', 'verified', 'pending'] as const).map((f) => (
            <button
              key={f}
              onClick={() => setFilter(f)}
              className={`rounded-full px-3 py-1 text-xs font-medium capitalize transition-colors ${
                filter === f
                  ? 'bg-[#2C6E69] text-white'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              {f}
            </button>
          ))}
        </div>
      </div>

      <div className="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-100 bg-gray-50/60">
                {['Vet', 'Clinic', 'Specialization', 'License', 'Fee', 'Rating', 'Status', 'Actions'].map((h) => (
                  <th
                    key={h}
                    className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500"
                  >
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr>
                  <td colSpan={8} className="py-16 text-center text-sm text-gray-400">
                    No vets found
                  </td>
                </tr>
              ) : (
                filtered.map((v) => (
                  <tr
                    key={v.id}
                    className="border-b border-gray-50 last:border-0 hover:bg-gray-50/50 transition-colors"
                  >
                    <td className="px-4 py-3">
                      <p className="font-medium text-gray-800">{v.name}</p>
                      <p className="text-xs text-gray-400">{v.email || '—'}</p>
                    </td>
                    <td className="px-4 py-3 text-gray-600">
                      <p>{v.clinic_name || '—'}</p>
                      <p className="text-xs text-gray-400">{v.clinic_address || ''}</p>
                    </td>
                    <td className="px-4 py-3 text-gray-600">{v.specialization || '—'}</td>
                    <td className="px-4 py-3 text-xs text-gray-500 font-mono">{v.license_number || '—'}</td>
                    <td className="px-4 py-3 text-gray-600">
                      {v.consultation_fee != null ? `$${v.consultation_fee}` : '—'}
                    </td>
                    <td className="px-4 py-3">
                      {v.rating != null ? (
                        <span className="flex items-center gap-1 text-amber-600">
                          <Star className="h-3.5 w-3.5 fill-amber-400 text-amber-400" />
                          {v.rating.toFixed(1)}
                        </span>
                      ) : (
                        <span className="text-gray-400">—</span>
                      )}
                    </td>
                    <td className="px-4 py-3">
                      <Badge variant={v.is_verified ? 'success' : 'warning'}>
                        {v.is_verified ? 'Verified' : 'Pending'}
                      </Badge>
                    </td>
                    <td className="px-4 py-3">
                      <button
                        onClick={() => handleToggleVerify(v.id, v.is_verified)}
                        disabled={isPending}
                        title={v.is_verified ? 'Revoke verification' : 'Approve vet'}
                        className={`rounded-lg p-1.5 transition-colors disabled:opacity-50 ${
                          v.is_verified
                            ? 'text-gray-400 hover:bg-red-50 hover:text-red-500'
                            : 'text-gray-400 hover:bg-green-50 hover:text-green-600'
                        }`}
                      >
                        {v.is_verified ? (
                          <XCircle className="h-4 w-4" />
                        ) : (
                          <CheckCircle className="h-4 w-4" />
                        )}
                      </button>
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
