'use client';

import { useState, useMemo, useTransition } from 'react';
import { Search, Eye, Trash2, X, CheckCircle, XCircle, Star, Shield } from 'lucide-react';
import Badge from '@/components/Badge';
import { formatDateTime, timeAgo } from '@/lib/utils';
import { updateCaregiverVerification, deleteCaregiver } from '@/lib/admin-actions';

interface Caregiver {
  id: string;
  bio: string | null;
  headline: string | null;
  years_of_experience: number | null;
  city: string | null;
  state: string | null;
  country: string | null;
  service_radius_km: number | null;
  is_verified: boolean;
  verification_date: string | null;
  background_check_status: string | null;
  id_verified: boolean;
  pet_first_aid_certified: boolean;
  insurance_verified: boolean;
  accepted_pet_types: string[] | null;
  accepted_pet_sizes: string[] | null;
  average_rating: number;
  total_reviews: number;
  total_bookings: number;
  completion_rate: number;
  is_active: boolean;
  is_accepting_bookings: boolean;
  created_at: string;
  updated_at: string;
  owner: { id: string; display_name: string | null; email: string | null; avatar_url: string | null } | null;
}

function InfoItem({ label, value }: { label: string; value: string | null | undefined }) {
  return (
    <div>
      <p className="text-xs text-gray-400">{label}</p>
      <p className="text-sm font-medium text-gray-700">{value || '—'}</p>
    </div>
  );
}

function bgCheckVariant(status: string | null): 'success' | 'warning' | 'danger' | 'default' {
  switch (status) {
    case 'approved': return 'success';
    case 'in_progress': return 'warning';
    case 'rejected':
    case 'expired': return 'danger';
    default: return 'default';
  }
}

export default function CaregiversClient({ caregivers: initialCaregivers }: { caregivers: Caregiver[] }) {
  const [caregivers, setCaregivers] = useState(initialCaregivers);
  const [search, setSearch] = useState('');
  const [filter, setFilter] = useState<'all' | 'verified' | 'pending'>('all');
  const [selected, setSelected] = useState<Caregiver | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<Caregiver | null>(null);
  const [isPending, startTransition] = useTransition();

  const filtered = useMemo(() => {
    return caregivers.filter((c) => {
      const q = search.toLowerCase();
      const matchesSearch =
        !q ||
        (c.owner?.display_name ?? '').toLowerCase().includes(q) ||
        (c.owner?.email ?? '').toLowerCase().includes(q) ||
        (c.city ?? '').toLowerCase().includes(q) ||
        (c.headline ?? '').toLowerCase().includes(q);
      const matchesFilter =
        filter === 'all' ||
        (filter === 'verified' && c.is_verified) ||
        (filter === 'pending' && !c.is_verified);
      return matchesSearch && matchesFilter;
    });
  }, [caregivers, search, filter]);

  const counts = useMemo(() => ({
    all: caregivers.length,
    verified: caregivers.filter((c) => c.is_verified).length,
    pending: caregivers.filter((c) => !c.is_verified).length,
  }), [caregivers]);

  function handleToggleVerify(id: string, current: boolean) {
    startTransition(async () => {
      const res = await updateCaregiverVerification(id, !current);
      if (res.success) {
        setCaregivers((prev) => prev.map((c) => c.id === id ? { ...c, is_verified: !current } : c));
        if (selected?.id === id) setSelected((prev) => prev ? { ...prev, is_verified: !current } : null);
      } else {
        alert('Failed: ' + (res as any).error);
      }
    });
  }

  function handleDelete(id: string) {
    startTransition(async () => {
      const res = await deleteCaregiver(id);
      if (res.success) {
        setCaregivers((prev) => prev.filter((c) => c.id !== id));
        setDeleteTarget(null);
        if (selected?.id === id) setSelected(null);
      } else {
        alert('Failed: ' + (res as any).error);
      }
    });
  }

  return (
    <>
      {/* Filters */}
      <div className="mb-4 flex flex-wrap items-center gap-3">
        <div className="relative flex-1 min-w-[220px]">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search name, email, city, headline…"
            className="w-full rounded-xl border border-gray-200 bg-white py-2 pl-10 pr-4 text-sm focus:border-[#2C6E69] focus:outline-none focus:ring-1 focus:ring-[#2C6E69]"
          />
        </div>
        {(['all', 'verified', 'pending'] as const).map((f) => (
          <button
            key={f}
            onClick={() => setFilter(f)}
            className={`rounded-lg px-3 py-1.5 text-xs font-medium transition-colors ${filter === f ? 'bg-[#2C6E69] text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}
          >
            {f === 'all' ? 'All' : f === 'verified' ? '✅ Verified' : '⏳ Pending'} ({counts[f]})
          </button>
        ))}
      </div>

      {/* Table */}
      <div className="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-100 bg-gray-50/60">
                {['Caregiver', 'Location', 'Experience', 'Rating', 'Bookings', 'Bg Check', 'Status', 'Actions'].map((h) => (
                  <th key={h} className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr><td colSpan={8} className="py-16 text-center text-sm text-gray-400">No caregivers found</td></tr>
              ) : (
                filtered.map((c) => (
                  <tr key={c.id} className="border-b border-gray-50 last:border-0 hover:bg-gray-50/50 transition-colors">
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-3">
                        {c.owner?.avatar_url ? (
                          <img src={c.owner.avatar_url} alt="" className="h-9 w-9 rounded-full object-cover" />
                        ) : (
                          <div className="flex h-9 w-9 items-center justify-center rounded-full bg-[#B3E0DB] text-xs font-bold text-[#2C6E69]">
                            {(c.owner?.display_name || c.owner?.email || '?')[0].toUpperCase()}
                          </div>
                        )}
                        <div>
                          <p className="font-medium text-gray-800">{c.owner?.display_name || '—'}</p>
                          <p className="text-xs text-gray-400">{c.owner?.email}</p>
                          {c.headline && <p className="text-xs text-gray-500 italic line-clamp-1">{c.headline}</p>}
                        </div>
                      </div>
                    </td>
                    <td className="px-4 py-3 text-xs text-gray-600">
                      <p>{c.city || '—'}{c.state ? `, ${c.state}` : ''}</p>
                      <p className="text-gray-400">{c.country}</p>
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-600">
                      {c.years_of_experience != null ? `${c.years_of_experience} yrs` : '—'}
                    </td>
                    <td className="px-4 py-3">
                      <span className="flex items-center gap-1 text-amber-600 text-xs">
                        <Star className="h-3 w-3 fill-amber-400 text-amber-400" />
                        {c.average_rating?.toFixed(1) || '0.0'} ({c.total_reviews})
                      </span>
                    </td>
                    <td className="px-4 py-3 text-center text-sm text-gray-700">{c.total_bookings}</td>
                    <td className="px-4 py-3">
                      <Badge variant={bgCheckVariant(c.background_check_status)}>
                        {c.background_check_status?.replace(/_/g, ' ') || 'pending'}
                      </Badge>
                    </td>
                    <td className="px-4 py-3">
                      <Badge variant={c.is_verified ? 'success' : 'warning'}>
                        {c.is_verified ? 'Verified' : 'Pending'}
                      </Badge>
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-1">
                        <button onClick={() => setSelected(c)} className="rounded-lg p-1.5 text-gray-400 hover:bg-gray-100 hover:text-[#2C6E69]" title="View">
                          <Eye className="h-4 w-4" />
                        </button>
                        <button
                          onClick={() => handleToggleVerify(c.id, c.is_verified)}
                          disabled={isPending}
                          title={c.is_verified ? 'Revoke verification' : 'Approve caregiver'}
                          className={`rounded-lg p-1.5 transition-colors disabled:opacity-50 ${c.is_verified ? 'text-gray-400 hover:bg-red-50 hover:text-red-500' : 'text-gray-400 hover:bg-green-50 hover:text-green-600'}`}
                        >
                          {c.is_verified ? <XCircle className="h-4 w-4" /> : <CheckCircle className="h-4 w-4" />}
                        </button>
                        <button onClick={() => setDeleteTarget(c)} className="rounded-lg p-1.5 text-gray-400 hover:bg-red-50 hover:text-red-500" title="Delete">
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
      {selected && (
        <div className="fixed inset-0 z-50 flex justify-end">
          <div className="absolute inset-0 bg-black/20" onClick={() => setSelected(null)} />
          <div className="relative w-full max-w-lg overflow-y-auto bg-white shadow-2xl">
            <div className="sticky top-0 z-10 flex items-center justify-between border-b bg-white px-6 py-4">
              <div>
                <h2 className="text-lg font-bold text-gray-900">{selected.owner?.display_name || '—'}</h2>
                <div className="mt-1 flex items-center gap-2">
                  <Badge variant={selected.is_verified ? 'success' : 'warning'}>{selected.is_verified ? 'Verified' : 'Pending'}</Badge>
                  <Badge variant={selected.is_active ? 'success' : 'default'}>{selected.is_active ? 'Active' : 'Inactive'}</Badge>
                  {selected.is_accepting_bookings && <Badge variant="info">Accepting Bookings</Badge>}
                </div>
              </div>
              <button onClick={() => setSelected(null)} className="rounded-lg p-2 hover:bg-gray-100"><X className="h-5 w-5" /></button>
            </div>
            <div className="space-y-6 p-6">
              {/* Headline + Bio */}
              {selected.headline && (
                <p className="font-medium text-gray-700 italic">"{selected.headline}"</p>
              )}
              {selected.bio && (
                <div>
                  <p className="mb-1 text-xs font-semibold uppercase text-gray-400">Bio</p>
                  <p className="rounded-xl bg-gray-50 p-3 text-sm text-gray-700">{selected.bio}</p>
                </div>
              )}

              {/* Core Info */}
              <div className="grid grid-cols-2 gap-4">
                <InfoItem label="Email" value={selected.owner?.email} />
                <InfoItem label="Experience" value={selected.years_of_experience != null ? `${selected.years_of_experience} years` : undefined} />
                <InfoItem label="City" value={selected.city} />
                <InfoItem label="State" value={selected.state} />
                <InfoItem label="Country" value={selected.country} />
                <InfoItem label="Service Radius" value={selected.service_radius_km != null ? `${selected.service_radius_km} km` : undefined} />
                <InfoItem label="Total Bookings" value={String(selected.total_bookings)} />
                <InfoItem label="Completion Rate" value={`${selected.completion_rate?.toFixed(1)}%`} />
                <InfoItem label="Rating" value={`${selected.average_rating?.toFixed(1)} (${selected.total_reviews} reviews)`} />
                <InfoItem label="Joined" value={formatDateTime(selected.created_at)} />
              </div>

              {/* Verification Badges */}
              <div>
                <p className="mb-2 text-xs font-semibold uppercase text-gray-400">Credentials</p>
                <div className="flex flex-wrap gap-2">
                  <span className={`flex items-center gap-1 rounded-full px-3 py-1 text-xs font-medium ${selected.id_verified ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'}`}>
                    <Shield className="h-3 w-3" /> ID {selected.id_verified ? 'Verified' : 'Not Verified'}
                  </span>
                  <span className={`flex items-center gap-1 rounded-full px-3 py-1 text-xs font-medium ${selected.pet_first_aid_certified ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'}`}>
                    First Aid {selected.pet_first_aid_certified ? 'Certified' : 'Not Certified'}
                  </span>
                  <span className={`flex items-center gap-1 rounded-full px-3 py-1 text-xs font-medium ${selected.insurance_verified ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'}`}>
                    Insurance {selected.insurance_verified ? 'Verified' : 'Not Verified'}
                  </span>
                  <Badge variant={bgCheckVariant(selected.background_check_status)}>
                    BG Check: {selected.background_check_status?.replace(/_/g, ' ') || 'pending'}
                  </Badge>
                </div>
              </div>

              {/* Pet Preferences */}
              {(selected.accepted_pet_types || selected.accepted_pet_sizes) && (
                <div>
                  <p className="mb-2 text-xs font-semibold uppercase text-gray-400">Pet Preferences</p>
                  <div className="flex flex-wrap gap-1.5">
                    {selected.accepted_pet_types?.map((t) => (
                      <Badge key={t} variant="teal" className="capitalize">{t}</Badge>
                    ))}
                    {selected.accepted_pet_sizes?.map((s) => (
                      <Badge key={s} variant="info" className="capitalize">{s}</Badge>
                    ))}
                  </div>
                </div>
              )}

              {/* Actions */}
              <div className="flex gap-3">
                <button
                  onClick={() => handleToggleVerify(selected.id, selected.is_verified)}
                  disabled={isPending}
                  className={`flex-1 rounded-xl border py-2.5 text-sm font-medium transition-colors disabled:opacity-50 ${selected.is_verified ? 'border-yellow-200 text-yellow-700 hover:bg-yellow-50' : 'border-green-200 text-green-700 hover:bg-green-50'}`}
                >
                  {selected.is_verified ? 'Revoke Verification' : 'Approve Caregiver'}
                </button>
                <button
                  onClick={() => { setSelected(null); setDeleteTarget(selected); }}
                  className="flex-1 rounded-xl border border-red-200 py-2.5 text-sm font-medium text-red-600 hover:bg-red-50"
                >
                  Delete
                </button>
              </div>
              <p className="text-xs text-gray-300">ID: {selected.id}</p>
            </div>
          </div>
        </div>
      )}

      {/* Delete Confirm */}
      {deleteTarget && (
        <div className="fixed inset-0 z-[60] flex items-center justify-center">
          <div className="absolute inset-0 bg-black/30" onClick={() => !isPending && setDeleteTarget(null)} />
          <div className="relative w-full max-w-sm rounded-2xl bg-white p-6 shadow-2xl">
            <h3 className="text-lg font-bold text-gray-900">Delete Caregiver?</h3>
            <p className="mt-2 text-sm text-gray-500">
              Permanently delete <strong>{deleteTarget.owner?.display_name || deleteTarget.owner?.email}</strong>'s caregiver profile? This cannot be undone.
            </p>
            <div className="mt-5 flex gap-3">
              <button onClick={() => setDeleteTarget(null)} disabled={isPending} className="flex-1 rounded-xl border border-gray-200 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:opacity-50">Cancel</button>
              <button onClick={() => handleDelete(deleteTarget.id)} disabled={isPending} className="flex-1 rounded-xl bg-red-600 py-2 text-sm font-medium text-white hover:bg-red-700 disabled:opacity-50">{isPending ? 'Deleting…' : 'Delete'}</button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
