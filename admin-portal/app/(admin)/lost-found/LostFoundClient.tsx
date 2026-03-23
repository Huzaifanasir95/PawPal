'use client';

import { useState, useTransition } from 'react';
import Badge from '@/components/Badge';
import { Search, Eye, Trash2, X, MapPin, Phone, Mail, AlertTriangle } from 'lucide-react';
import { timeAgo, formatDateTime } from '@/lib/utils';
import { updateLostFoundStatus, deleteLostFound } from '@/lib/admin-actions';

interface LostFoundItem {
  id: string;
  type: string;
  pet_name: string | null;
  pet_type: string | null;
  breed: string | null;
  description: string | null;
  last_seen_location: string | null;
  status: string;
  urgency: string | null;
  contact_phone: string | null;
  contact_email: string | null;
  image_urls: string[] | null;
  created_at: string;
  user_id: string;
  reporter: { name: string | null; email: string | null } | null;
}

const TYPE_OPTIONS = ['all', 'lost', 'found'] as const;
const STATUS_OPTIONS = ['all', 'open', 'resolved', 'closed'] as const;

const urgencyMap: Record<string, { label: string; variant: 'danger' | 'warning' | 'default' }> = {
  critical: { label: 'Critical', variant: 'danger' },
  high: { label: 'High', variant: 'warning' },
  medium: { label: 'Medium', variant: 'default' },
  low: { label: 'Low', variant: 'default' },
};

const statusMap: Record<string, { label: string; variant: 'success' | 'warning' | 'default' }> = {
  open: { label: 'Open', variant: 'warning' },
  resolved: { label: 'Resolved', variant: 'success' },
  closed: { label: 'Closed', variant: 'default' },
};

function InfoItem({ label, value }: { label: string; value: string | null | undefined }) {
  return (
    <div>
      <p className="text-xs text-gray-400">{label}</p>
      <p className="text-sm font-medium text-gray-700">{value || '—'}</p>
    </div>
  );
}

export default function LostFoundClient({ items: initialItems }: { items: LostFoundItem[] }) {
  const [items, setItems] = useState(initialItems);
  const [search, setSearch] = useState('');
  const [typeFilter, setTypeFilter] = useState<string>('all');
  const [statusFilter, setStatusFilter] = useState<string>('all');
  const [selectedItem, setSelectedItem] = useState<LostFoundItem | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<LostFoundItem | null>(null);
  const [isPending, startTransition] = useTransition();

  const filtered = items.filter((item) => {
    const q = search.toLowerCase();
    const matchesSearch =
      !q ||
      (item.pet_name ?? '').toLowerCase().includes(q) ||
      (item.pet_type ?? '').toLowerCase().includes(q) ||
      (item.breed ?? '').toLowerCase().includes(q) ||
      (item.last_seen_location ?? '').toLowerCase().includes(q) ||
      (item.reporter?.name ?? '').toLowerCase().includes(q);
    const matchesType = typeFilter === 'all' || item.type === typeFilter;
    const matchesStatus = statusFilter === 'all' || item.status === statusFilter;
    return matchesSearch && matchesType && matchesStatus;
  });

  const counts = {
    type: { all: items.length, lost: items.filter((i) => i.type === 'lost').length, found: items.filter((i) => i.type === 'found').length },
    status: { all: items.length, open: items.filter((i) => i.status === 'open').length, resolved: items.filter((i) => i.status === 'resolved').length, closed: items.filter((i) => i.status === 'closed').length },
  };

  function handleStatusChange(id: string, status: string) {
    startTransition(async () => {
      const res = await updateLostFoundStatus(id, status);
      if (res.success) {
        setItems((prev) => prev.map((i) => (i.id === id ? { ...i, status } : i)));
        if (selectedItem?.id === id) setSelectedItem((p) => (p ? { ...p, status } : p));
      }
    });
  }

  function handleDelete(id: string) {
    startTransition(async () => {
      const res = await deleteLostFound(id);
      if (res.success) {
        setItems((prev) => prev.filter((i) => i.id !== id));
        setDeleteTarget(null);
        if (selectedItem?.id === id) setSelectedItem(null);
      }
    });
  }

  return (
    <div className="p-8">
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Lost & Found</h1>
        <p className="mt-1 text-sm text-gray-500">
          {items.length} reports — {counts.type.lost} lost, {counts.type.found} found, {counts.status.open} still open
        </p>
      </div>

      {/* Search + Type Filter */}
      <div className="mb-4 flex flex-wrap items-center gap-3">
        <div className="relative flex-1 min-w-[220px]">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search pet name, breed, location, reporter…"
            className="w-full rounded-xl border border-gray-200 bg-white py-2 pl-10 pr-4 text-sm focus:border-[#2C6E69] focus:outline-none focus:ring-1 focus:ring-[#2C6E69]"
          />
        </div>
        {TYPE_OPTIONS.map((t) => (
          <button
            key={t}
            onClick={() => setTypeFilter(t)}
            className={`rounded-lg px-3 py-1.5 text-xs font-medium transition-colors ${
              typeFilter === t
                ? 'bg-[#2C6E69] text-white'
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            {t === 'all' ? 'All' : t === 'lost' ? '🔍 Lost' : '📢 Found'} ({counts.type[t]})
          </button>
        ))}
      </div>

      {/* Status Filter */}
      <div className="mb-4 flex flex-wrap gap-2">
        {STATUS_OPTIONS.map((s) => (
          <button
            key={s}
            onClick={() => setStatusFilter(s)}
            className={`rounded-lg px-3 py-1.5 text-xs font-medium transition-colors ${
              statusFilter === s
                ? 'bg-[#2C6E69] text-white'
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            {s.charAt(0).toUpperCase() + s.slice(1)} ({counts.status[s as keyof typeof counts.status] ?? 0})
          </button>
        ))}
      </div>

      {/* Table */}
      <div className="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-100 bg-gray-50/60">
                {['Type', 'Pet', 'Last Seen', 'Reported By', 'Urgency', 'Status', 'Time', 'Actions'].map((h) => (
                  <th key={h} className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr>
                  <td colSpan={8} className="py-16 text-center text-sm text-gray-400">
                    No reports found
                  </td>
                </tr>
              ) : (
                filtered.map((item) => {
                  const urgency = urgencyMap[item.urgency ?? ''] ?? { label: item.urgency || '—', variant: 'default' as const };
                  const status = statusMap[item.status] ?? { label: item.status || '—', variant: 'default' as const };
                  return (
                    <tr key={item.id} className="border-b border-gray-50 last:border-0 hover:bg-gray-50/50 transition-colors">
                      <td className="px-4 py-3">
                        <Badge variant={item.type === 'lost' ? 'danger' : 'success'}>
                          {item.type === 'lost' ? '🔍 Lost' : '📢 Found'}
                        </Badge>
                      </td>
                      <td className="px-4 py-3">
                        <p className="font-medium text-gray-800">{item.pet_name || '?'}</p>
                        <p className="text-xs text-gray-400 capitalize">
                          {item.pet_type || ''}{item.breed ? ` · ${item.breed}` : ''}
                        </p>
                      </td>
                      <td className="px-4 py-3 text-xs text-gray-500 max-w-[180px]">
                        {item.last_seen_location ? (
                          <span className="flex items-center gap-1">
                            <MapPin className="h-3 w-3 shrink-0" />
                            <span className="truncate">{item.last_seen_location}</span>
                          </span>
                        ) : '—'}
                      </td>
                      <td className="px-4 py-3 text-xs text-gray-600">
                        {item.reporter?.name || item.reporter?.email || 'Unknown'}
                      </td>
                      <td className="px-4 py-3">
                        <Badge variant={urgency.variant}>{urgency.label}</Badge>
                      </td>
                      <td className="px-4 py-3">
                        <Badge variant={status.variant}>{status.label}</Badge>
                      </td>
                      <td className="px-4 py-3 text-xs text-gray-400">{timeAgo(item.created_at)}</td>
                      <td className="px-4 py-3">
                        <div className="flex items-center gap-1">
                          <button onClick={() => setSelectedItem(item)} className="rounded-lg p-1.5 text-gray-400 hover:bg-gray-100 hover:text-[#2C6E69]">
                            <Eye className="h-4 w-4" />
                          </button>
                          <button onClick={() => setDeleteTarget(item)} className="rounded-lg p-1.5 text-gray-400 hover:bg-red-50 hover:text-red-500">
                            <Trash2 className="h-4 w-4" />
                          </button>
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
      {selectedItem && (
        <div className="fixed inset-0 z-50 flex justify-end">
          <div className="absolute inset-0 bg-black/20" onClick={() => setSelectedItem(null)} />
          <div className="relative w-full max-w-lg overflow-y-auto bg-white shadow-2xl">
            <div className="sticky top-0 z-10 flex items-center justify-between border-b bg-white px-6 py-4">
              <div>
                <h2 className="text-lg font-bold text-gray-900">{selectedItem.pet_name || 'Unknown Pet'}</h2>
                <div className="mt-1 flex items-center gap-2">
                  <Badge variant={selectedItem.type === 'lost' ? 'danger' : 'success'}>
                    {selectedItem.type === 'lost' ? '🔍 Lost' : '📢 Found'}
                  </Badge>
                  {selectedItem.urgency && (
                    <Badge variant={urgencyMap[selectedItem.urgency]?.variant ?? 'default'}>
                      <AlertTriangle className="mr-1 inline h-3 w-3" />
                      {urgencyMap[selectedItem.urgency]?.label ?? selectedItem.urgency}
                    </Badge>
                  )}
                  <Badge variant={statusMap[selectedItem.status]?.variant ?? 'default'}>
                    {statusMap[selectedItem.status]?.label ?? selectedItem.status}
                  </Badge>
                </div>
              </div>
              <button onClick={() => setSelectedItem(null)} className="rounded-lg p-2 hover:bg-gray-100">
                <X className="h-5 w-5" />
              </button>
            </div>

            <div className="space-y-6 p-6">
              {/* Images */}
              {selectedItem.image_urls && selectedItem.image_urls.length > 0 && (
                <div className="grid grid-cols-2 gap-2">
                  {selectedItem.image_urls.map((url, i) => (
                    <img key={i} src={url} alt={`Photo ${i + 1}`} className="h-40 w-full rounded-lg object-cover" />
                  ))}
                </div>
              )}

              {/* Description */}
              {selectedItem.description && (
                <div>
                  <p className="mb-1 text-xs font-semibold uppercase text-gray-400">Description</p>
                  <p className="rounded-lg bg-gray-50 p-3 text-sm text-gray-700 whitespace-pre-wrap">{selectedItem.description}</p>
                </div>
              )}

              {/* Info Grid */}
              <div className="grid grid-cols-2 gap-4">
                <InfoItem label="Pet Type" value={selectedItem.pet_type} />
                <InfoItem label="Breed" value={selectedItem.breed} />
                <InfoItem label="Last Seen Location" value={selectedItem.last_seen_location} />
                <InfoItem label="Reported By" value={selectedItem.reporter?.name || selectedItem.reporter?.email || 'Unknown'} />
                <InfoItem label="Reported" value={formatDateTime(selectedItem.created_at)} />
                <InfoItem label="Urgency" value={selectedItem.urgency} />
              </div>

              {/* Contact Info */}
              <div>
                <p className="mb-2 text-xs font-semibold uppercase text-gray-400">Contact Information</p>
                <div className="space-y-2">
                  {selectedItem.contact_phone && (
                    <div className="flex items-center gap-2 text-sm text-gray-600">
                      <Phone className="h-4 w-4 text-gray-400" />
                      {selectedItem.contact_phone}
                    </div>
                  )}
                  {selectedItem.contact_email && (
                    <div className="flex items-center gap-2 text-sm text-gray-600">
                      <Mail className="h-4 w-4 text-gray-400" />
                      {selectedItem.contact_email}
                    </div>
                  )}
                  {!selectedItem.contact_phone && !selectedItem.contact_email && (
                    <p className="text-sm text-gray-400">No contact information provided</p>
                  )}
                </div>
              </div>

              {/* Status Change */}
              <div>
                <p className="mb-2 text-xs font-semibold uppercase text-gray-400">Change Status</p>
                <div className="flex flex-wrap gap-2">
                  {['open', 'resolved', 'closed'].map((s) => (
                    <button
                      key={s}
                      disabled={isPending || selectedItem.status === s}
                      onClick={() => handleStatusChange(selectedItem.id, s)}
                      className={`rounded-lg px-3 py-1.5 text-xs font-medium transition-colors ${
                        selectedItem.status === s
                          ? 'bg-[#2C6E69] text-white'
                          : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                      } disabled:opacity-50`}
                    >
                      {s.charAt(0).toUpperCase() + s.slice(1)}
                    </button>
                  ))}
                </div>
              </div>

              {/* Meta */}
              <p className="text-xs text-gray-300">ID: {selectedItem.id}</p>

              {/* Delete */}
              <button
                onClick={() => { setSelectedItem(null); setDeleteTarget(selectedItem); }}
                className="w-full rounded-xl bg-red-50 py-2.5 text-sm font-medium text-red-600 hover:bg-red-100 transition-colors"
              >
                Delete Report
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Delete Modal */}
      {deleteTarget && (
        <div className="fixed inset-0 z-50 flex items-center justify-center">
          <div className="absolute inset-0 bg-black/30" onClick={() => setDeleteTarget(null)} />
          <div className="relative w-full max-w-sm rounded-2xl bg-white p-6 shadow-2xl">
            <h3 className="text-lg font-bold text-gray-900">Delete Report</h3>
            <p className="mt-2 text-sm text-gray-500">
              Permanently delete the {deleteTarget.type} report for <strong>{deleteTarget.pet_name || 'Unknown'}</strong>? This cannot be undone.
            </p>
            <div className="mt-5 flex gap-3">
              <button onClick={() => setDeleteTarget(null)} className="flex-1 rounded-xl border border-gray-200 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50">
                Cancel
              </button>
              <button
                disabled={isPending}
                onClick={() => handleDelete(deleteTarget.id)}
                className="flex-1 rounded-xl bg-red-600 py-2 text-sm font-medium text-white hover:bg-red-700 disabled:opacity-50"
              >
                {isPending ? 'Deleting…' : 'Delete'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
