'use client';

import { useState, useMemo, useTransition } from 'react';
import { Search, CheckCircle, XCircle, Star, Eye, Trash2, X } from 'lucide-react';
import Badge from '@/components/Badge';
import { updateVetVerification, deleteVet } from '@/lib/admin-actions';
import { formatDateTime } from '@/lib/utils';

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
  const [selectedVet, setSelectedVet] = useState<Vet | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<Vet | null>(null);

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
        if (selectedVet?.id === id) setSelectedVet((prev) => prev ? { ...prev, is_verified: newValue } : null);
      } else {
        alert('Failed to update: ' + result.error);
      }
    });
  }

  function handleDelete(vet: Vet) {
    startTransition(async () => {
      const res = await deleteVet(vet.id);
      if (res.success) {
        setVets((prev) => prev.filter((v) => v.id !== vet.id));
        setDeleteTarget(null);
        setSelectedVet(null);
      } else {
        alert('Failed to delete vet: ' + res.error);
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
                      <div className="flex items-center gap-1">
                        <button onClick={() => setSelectedVet(v)} className="rounded-lg p-1.5 text-gray-400 hover:bg-gray-100 hover:text-[#2C6E69] transition-colors" title="View details">
                          <Eye className="h-4 w-4" />
                        </button>
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
                          {v.is_verified ? <XCircle className="h-4 w-4" /> : <CheckCircle className="h-4 w-4" />}
                        </button>
                        <button onClick={() => setDeleteTarget(v)} className="rounded-lg p-1.5 text-gray-400 hover:bg-red-50 hover:text-red-500 transition-colors" title="Delete vet">
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
      {selectedVet && (
        <div className="fixed inset-0 z-50 flex justify-end">
          <div className="absolute inset-0 bg-black/20" onClick={() => setSelectedVet(null)} />
          <div className="relative w-full max-w-md bg-white shadow-xl overflow-y-auto">
            <div className="sticky top-0 flex items-center justify-between border-b bg-white px-6 py-4 z-10">
              <h2 className="text-lg font-semibold text-gray-800">Vet Details</h2>
              <button onClick={() => setSelectedVet(null)} className="rounded-lg p-1.5 hover:bg-gray-100 transition-colors">
                <X className="h-5 w-5 text-gray-500" />
              </button>
            </div>
            <div className="p-6 space-y-6">
              <div>
                <p className="text-xl font-bold text-gray-900">{selectedVet.name}</p>
                <p className="text-sm text-gray-500">{selectedVet.email || '—'}</p>
                <div className="mt-2 flex items-center gap-2">
                  <Badge variant={selectedVet.is_verified ? 'success' : 'warning'}>
                    {selectedVet.is_verified ? 'Verified' : 'Pending'}
                  </Badge>
                  <Badge variant={selectedVet.is_available ? 'success' : 'default'}>
                    {selectedVet.is_available ? 'Available' : 'Unavailable'}
                  </Badge>
                  {selectedVet.rating != null && (
                    <span className="flex items-center gap-1 text-sm text-amber-600">
                      <Star className="h-4 w-4 fill-amber-400 text-amber-400" />
                      {selectedVet.rating.toFixed(1)}
                    </span>
                  )}
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <VetInfo label="Phone" value={selectedVet.phone || '—'} />
                <VetInfo label="License #" value={selectedVet.license_number || '—'} />
                <VetInfo label="Clinic" value={selectedVet.clinic_name || '—'} />
                <VetInfo label="Address" value={selectedVet.clinic_address || '—'} />
                <VetInfo label="Specialization" value={Array.isArray(selectedVet.specialization) ? selectedVet.specialization.join(', ') : selectedVet.specialization || '—'} />
                <VetInfo label="Experience" value={selectedVet.years_of_experience != null ? `${selectedVet.years_of_experience} years` : '—'} />
                <VetInfo label="Consultation Fee" value={selectedVet.consultation_fee != null ? `$${selectedVet.consultation_fee}` : '—'} />
                <VetInfo label="Joined" value={formatDateTime(selectedVet.created_at)} />
              </div>

              <div className="text-xs text-gray-400 break-all">
                <span className="font-medium text-gray-500">ID:</span> {selectedVet.id}
              </div>

              <div className="flex gap-3">
                <button
                  onClick={() => handleToggleVerify(selectedVet.id, selectedVet.is_verified)}
                  disabled={isPending}
                  className={`flex-1 rounded-xl border py-2.5 text-sm font-medium transition-colors disabled:opacity-50 ${
                    selectedVet.is_verified
                      ? 'border-yellow-200 text-yellow-600 hover:bg-yellow-50'
                      : 'border-green-200 text-green-600 hover:bg-green-50'
                  }`}
                >
                  {selectedVet.is_verified ? 'Revoke Verification' : 'Approve Vet'}
                </button>
                <button
                  onClick={() => { setSelectedVet(null); setDeleteTarget(selectedVet); }}
                  className="flex-1 rounded-xl border border-red-200 py-2.5 text-sm font-medium text-red-600 hover:bg-red-50 transition-colors"
                >
                  Delete Vet
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Delete Confirmation */}
      {deleteTarget && (
        <div className="fixed inset-0 z-[60] flex items-center justify-center">
          <div className="absolute inset-0 bg-black/30" onClick={() => !isPending && setDeleteTarget(null)} />
          <div className="relative w-full max-w-sm rounded-2xl bg-white p-6 shadow-xl">
            <h3 className="text-lg font-semibold text-gray-800">Delete Vet?</h3>
            <p className="mt-2 text-sm text-gray-500">
              This will permanently delete <strong>{deleteTarget.name}</strong>&apos;s profile. This cannot be undone.
            </p>
            <div className="mt-6 flex gap-3">
              <button disabled={isPending} onClick={() => setDeleteTarget(null)} className="flex-1 rounded-xl border border-gray-200 py-2.5 text-sm font-medium text-gray-600 hover:bg-gray-50 transition-colors disabled:opacity-50">Cancel</button>
              <button disabled={isPending} onClick={() => handleDelete(deleteTarget)} className="flex-1 rounded-xl bg-red-500 py-2.5 text-sm font-medium text-white hover:bg-red-600 transition-colors disabled:opacity-50">{isPending ? 'Deleting...' : 'Delete'}</button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}

function VetInfo({ label, value }: { label: string; value: string }) {
  return (
    <div>
      <p className="text-xs font-medium text-gray-400 uppercase tracking-wide">{label}</p>
      <p className="mt-0.5 text-sm text-gray-700">{value}</p>
    </div>
  );
}
