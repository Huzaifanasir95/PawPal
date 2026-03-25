'use client';

import { useState, useMemo, useTransition } from 'react';
import { Search, Trash2, Eye, X } from 'lucide-react';
import { timeAgo, formatDateTime } from '@/lib/utils';
import Badge from '@/components/Badge';
import { deleteAdoption, updateAdoptionStatus } from '@/lib/admin-actions';

const STATUS_OPTIONS = ['available', 'pending', 'adopted', 'cancelled'] as const;
const statusMap: Record<string, { label: string; variant: 'success' | 'warning' | 'default' | 'danger' }> = {
  available: { label: 'Available', variant: 'success' },
  pending: { label: 'Pending', variant: 'warning' },
  adopted: { label: 'Adopted', variant: 'default' },
  cancelled: { label: 'Cancelled', variant: 'danger' },
};

interface Adoption {
  id: string;
  pet_name: string;
  pet_type: string | null;
  breed: string | null;
  age: number | null;
  gender: string | null;
  size: string | null;
  description: string | null;
  status: string;
  contact_phone: string | null;
  contact_email: string | null;
  location: string | null;
  adoption_fee: number | null;
  image_urls: string[] | null;
  created_at: string;
  user_id: string;
  lister: { name: string | null; email: string | null } | null;
}

export default function AdoptionsClient({ adoptions: initialAdoptions }: { adoptions: Adoption[] }) {
  const [adoptions, setAdoptions] = useState(initialAdoptions);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [selectedAdoption, setSelectedAdoption] = useState<Adoption | null>(null);
  const [isPending, startTransition] = useTransition();
  const [deleteTarget, setDeleteTarget] = useState<Adoption | null>(null);

  const filtered = useMemo(() => {
    return adoptions.filter((a) => {
      const matchesSearch =
        a.pet_name.toLowerCase().includes(search.toLowerCase()) ||
        (a.breed?.toLowerCase() ?? '').includes(search.toLowerCase()) ||
        (a.location?.toLowerCase() ?? '').includes(search.toLowerCase());
      const matchesStatus = statusFilter === 'all' || a.status === statusFilter;
      return matchesSearch && matchesStatus;
    });
  }, [adoptions, search, statusFilter]);

  function handleDelete(adoption: Adoption) {
    startTransition(async () => {
      const res = await deleteAdoption(adoption.id);
      if (res.success) {
        setAdoptions((prev) => prev.filter((a) => a.id !== adoption.id));
        setDeleteTarget(null);
        setSelectedAdoption(null);
      } else {
        alert('Failed to delete: ' + res.error);
      }
    });
  }

  function handleStatusChange(id: string, newStatus: string) {
    startTransition(async () => {
      const res = await updateAdoptionStatus(id, newStatus);
      if (res.success) {
        setAdoptions((prev) => prev.map((a) => (a.id === id ? { ...a, status: newStatus } : a)));
        if (selectedAdoption?.id === id) setSelectedAdoption((prev) => prev ? { ...prev, status: newStatus } : null);
      } else {
        alert('Failed to update status: ' + res.error);
      }
    });
  }

  const counts = useMemo(() => {
    const c: Record<string, number> = { all: adoptions.length };
    STATUS_OPTIONS.forEach((s) => { c[s] = adoptions.filter((a) => a.status === s).length; });
    return c;
  }, [adoptions]);

  return (
    <>
      {/* Filters */}
      <div className="mb-4 flex flex-wrap items-center gap-3">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
          <input type="text" placeholder="Search adoptions..." value={search} onChange={(e) => setSearch(e.target.value)} className="w-64 rounded-xl border border-gray-200 bg-white py-2 pl-9 pr-4 text-sm text-gray-700 outline-none focus:border-[#2C6E69] focus:ring-1 focus:ring-[#2C6E69]" />
        </div>
        <div className="flex gap-1 rounded-xl border border-gray-200 bg-white p-1">
          {['all', ...STATUS_OPTIONS].map((s) => (
            <button key={s} onClick={() => setStatusFilter(s)} className={`rounded-lg px-3 py-1.5 text-xs font-medium transition-colors capitalize ${statusFilter === s ? 'bg-[#2C6E69] text-white' : 'text-gray-500 hover:text-gray-700'}`}>
              {s} ({counts[s] ?? 0})
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
                <th className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">Pet</th>
                <th className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">Type / Breed</th>
                <th className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">Location</th>
                <th className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">Listed By</th>
                <th className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">Status</th>
                <th className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">Listed</th>
                <th className="px-4 py-3 text-center text-xs font-semibold uppercase tracking-wide text-gray-500">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr><td colSpan={7} className="py-16 text-center text-sm text-gray-400">No listings found</td></tr>
              ) : (
                filtered.map((a) => {
                  const si = statusMap[a.status] ?? { label: a.status, variant: 'default' as const };
                  return (
                    <tr key={a.id} className="border-b border-gray-50 last:border-0 hover:bg-gray-50/50 transition-colors">
                      <td className="px-4 py-3">
                        <p className="font-medium text-gray-800">{a.pet_name}</p>
                        <p className="text-xs text-gray-400">{a.age ?? '?'} yr{Number(a.age) !== 1 ? 's' : ''}{a.gender ? ` · ${a.gender}` : ''}{a.size ? ` · ${a.size}` : ''}</p>
                      </td>
                      <td className="px-4 py-3 text-gray-600 capitalize">
                        <p>{a.pet_type || '—'}</p>
                        <p className="text-xs text-gray-400">{a.breed || ''}</p>
                      </td>
                      <td className="px-4 py-3 text-gray-600 text-sm">{a.location || '—'}</td>
                      <td className="px-4 py-3 text-xs text-gray-600">{a.lister?.name || a.lister?.email || 'Unknown'}</td>
                      <td className="px-4 py-3"><Badge variant={si.variant}>{si.label}</Badge></td>
                      <td className="px-4 py-3 text-xs text-gray-400 whitespace-nowrap">{timeAgo(a.created_at)}</td>
                      <td className="px-4 py-3">
                        <div className="flex items-center justify-center gap-1">
                          <button onClick={() => setSelectedAdoption(a)} className="rounded-lg p-1.5 text-gray-400 hover:bg-gray-100 hover:text-[#2C6E69] transition-colors" title="View"><Eye className="h-4 w-4" /></button>
                          <button onClick={() => setDeleteTarget(a)} className="rounded-lg p-1.5 text-gray-400 hover:bg-red-50 hover:text-red-500 transition-colors" title="Delete"><Trash2 className="h-4 w-4" /></button>
                        </div>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Detail Drawer */}
      {selectedAdoption && (
        <div className="fixed inset-0 z-50 flex justify-end">
          <div className="absolute inset-0 bg-black/20" onClick={() => setSelectedAdoption(null)} />
          <div className="relative w-full max-w-md bg-white shadow-xl overflow-y-auto">
            <div className="sticky top-0 flex items-center justify-between border-b bg-white px-6 py-4 z-10">
              <h2 className="text-lg font-semibold text-gray-800">Adoption Details</h2>
              <button onClick={() => setSelectedAdoption(null)} className="rounded-lg p-1.5 hover:bg-gray-100 transition-colors"><X className="h-5 w-5 text-gray-500" /></button>
            </div>
            <div className="p-6 space-y-6">
              <div>
                <h3 className="text-xl font-bold text-gray-900">{selectedAdoption.pet_name}</h3>
                <div className="mt-2 flex items-center gap-2">
                  <Badge variant={statusMap[selectedAdoption.status]?.variant ?? 'default'}>{statusMap[selectedAdoption.status]?.label ?? selectedAdoption.status}</Badge>
                  {selectedAdoption.pet_type && <Badge variant="info">{selectedAdoption.pet_type}</Badge>}
                </div>
              </div>

              {selectedAdoption.image_urls && selectedAdoption.image_urls.length > 0 && (
                <div className="grid grid-cols-2 gap-2">
                  {selectedAdoption.image_urls.map((url, i) => (
                    <img key={i} src={url} alt={`${selectedAdoption.pet_name} ${i + 1}`} className="rounded-lg object-cover w-full h-32" />
                  ))}
                </div>
              )}

              {selectedAdoption.description && (
                <div className="rounded-xl bg-gray-50 p-4">
                  <p className="text-sm text-gray-700 whitespace-pre-wrap">{selectedAdoption.description}</p>
                </div>
              )}

              <div className="grid grid-cols-2 gap-4">
                <InfoItem label="Breed" value={selectedAdoption.breed || '—'} />
                <InfoItem label="Age" value={selectedAdoption.age != null ? `${selectedAdoption.age} years` : '—'} />
                <InfoItem label="Gender" value={selectedAdoption.gender || '—'} />
                <InfoItem label="Size" value={selectedAdoption.size || '—'} />
                <InfoItem label="Location" value={selectedAdoption.location || '—'} />
                <InfoItem label="Fee" value={selectedAdoption.adoption_fee != null ? `$${selectedAdoption.adoption_fee}` : 'Free'} />
                <InfoItem label="Phone" value={selectedAdoption.contact_phone || '—'} />
                <InfoItem label="Email" value={selectedAdoption.contact_email || '—'} />
                <InfoItem label="Listed By" value={selectedAdoption.lister?.name || selectedAdoption.lister?.email || 'Unknown'} />
                <InfoItem label="Listed" value={formatDateTime(selectedAdoption.created_at)} />
              </div>

              {/* Status Change */}
              <div>
                <p className="text-xs font-medium text-gray-400 uppercase tracking-wide mb-2">Change Status</p>
                <div className="flex flex-wrap gap-2">
                  {STATUS_OPTIONS.map((s) => (
                    <button key={s} disabled={isPending || selectedAdoption.status === s} onClick={() => handleStatusChange(selectedAdoption.id, s)} className={`rounded-lg px-3 py-1.5 text-xs font-medium transition-colors capitalize disabled:opacity-40 ${selectedAdoption.status === s ? 'bg-[#2C6E69] text-white' : 'border border-gray-200 text-gray-600 hover:bg-gray-50'}`}>
                      {s}
                    </button>
                  ))}
                </div>
              </div>

              <div className="text-xs text-gray-400 break-all"><span className="font-medium text-gray-500">ID:</span> {selectedAdoption.id}</div>

              <button onClick={() => { setSelectedAdoption(null); setDeleteTarget(selectedAdoption); }} className="w-full rounded-xl border border-red-200 py-2.5 text-sm font-medium text-red-600 hover:bg-red-50 transition-colors">Delete Listing</button>
            </div>
          </div>
        </div>
      )}

      {/* Delete Confirmation */}
      {deleteTarget && (
        <div className="fixed inset-0 z-[60] flex items-center justify-center">
          <div className="absolute inset-0 bg-black/30" onClick={() => !isPending && setDeleteTarget(null)} />
          <div className="relative w-full max-w-sm rounded-2xl bg-white p-6 shadow-xl">
            <h3 className="text-lg font-semibold text-gray-800">Delete Listing?</h3>
            <p className="mt-2 text-sm text-gray-500">This will permanently delete the listing for <strong>{deleteTarget.pet_name}</strong>. This cannot be undone.</p>
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

function InfoItem({ label, value }: { label: string; value: string }) {
  return (
    <div>
      <p className="text-xs font-medium text-gray-400 uppercase tracking-wide">{label}</p>
      <p className="mt-0.5 text-sm text-gray-700">{value}</p>
    </div>
  );
}
