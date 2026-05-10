'use client';

import { useState, useMemo, useTransition } from 'react';
import { Search, Eye, Trash2, X, DollarSign } from 'lucide-react';
import Badge from '@/components/Badge';
import { timeAgo, formatDateTime } from '@/lib/utils';
import { updateBookingStatus, deleteBooking } from '@/lib/admin-actions';

export interface Payment {
  id: string;
  booking_id: string;
  amount: number;
  payment_type: string;
  payment_method: string | null;
  status: string;
  payout_status: string;
  created_at: string;
}

export interface Booking {
  id: string;
  booking_number: string;
  status: string;
  start_datetime: string;
  end_datetime: string;
  total_amount: number;
  currency: string;
  base_amount: number;
  service_fee: number;
  special_instructions: string | null;
  cancellation_reason: string | null;
  requested_at: string;
  created_at: string;
  updated_at: string;
  pet_owner: { id: string; display_name: string | null; email: string | null } | null;
  caregiver: {
    id: string;
    city: string | null;
    owner: { display_name: string | null; email: string | null } | null;
  } | null;
  service: {
    id: string;
    service_type: { display_name: string } | null;
  } | null;
}

const STATUS_OPTIONS = ['all', 'pending', 'accepted', 'in_progress', 'completed', 'declined', 'cancelled_owner', 'cancelled_caregiver', 'disputed'] as const;

function statusVariant(status: string): 'success' | 'warning' | 'danger' | 'info' | 'purple' | 'default' {
  switch (status) {
    case 'completed': return 'success';
    case 'accepted': return 'info';
    case 'in_progress': return 'purple';
    case 'pending': return 'warning';
    case 'declined':
    case 'cancelled_owner':
    case 'cancelled_caregiver':
    case 'disputed': return 'danger';
    default: return 'default';
  }
}

function statusLabel(status: string) {
  return status.replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());
}

function InfoItem({ label, value }: { label: string; value: string | null | undefined }) {
  return (
    <div>
      <p className="text-xs text-gray-400">{label}</p>
      <p className="text-sm font-medium text-gray-700">{value || '—'}</p>
    </div>
  );
}

export default function BookingsClient({
  bookings: initialBookings,
  payments,
}: {
  bookings: Booking[];
  payments: Payment[];
}) {
  const [bookings, setBookings] = useState(initialBookings);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [selectedBooking, setSelectedBooking] = useState<Booking | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<Booking | null>(null);
  const [isPending, startTransition] = useTransition();

  const filtered = useMemo(() => {
    return bookings.filter((b) => {
      const q = search.toLowerCase();
      const matchesSearch =
        !q ||
        b.booking_number.toLowerCase().includes(q) ||
        (b.pet_owner?.display_name ?? '').toLowerCase().includes(q) ||
        (b.pet_owner?.email ?? '').toLowerCase().includes(q) ||
        (b.caregiver?.owner?.display_name ?? '').toLowerCase().includes(q) ||
        (b.service?.service_type?.display_name ?? '').toLowerCase().includes(q);
      const matchesStatus = statusFilter === 'all' || b.status === statusFilter;
      return matchesSearch && matchesStatus;
    });
  }, [bookings, search, statusFilter]);

  const counts = useMemo(() => {
    const result: Record<string, number> = { all: bookings.length };
    STATUS_OPTIONS.slice(1).forEach((s) => {
      result[s] = bookings.filter((b) => b.status === s).length;
    });
    return result;
  }, [bookings]);

  const bookingPayments = (b: Booking) => payments.filter((p) => p.booking_id === b.id);

  function handleStatusChange(id: string, status: string) {
    startTransition(async () => {
      const res = await updateBookingStatus(id, status);
      if (res.success) {
        setBookings((prev) => prev.map((b) => (b.id === id ? { ...b, status } : b)));
        if (selectedBooking?.id === id) setSelectedBooking((prev) => prev ? { ...prev, status } : null);
      }
    });
  }

  function handleDelete(id: string) {
    startTransition(async () => {
      const res = await deleteBooking(id);
      if (res.success) {
        setBookings((prev) => prev.filter((b) => b.id !== id));
        setDeleteTarget(null);
        if (selectedBooking?.id === id) setSelectedBooking(null);
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
            placeholder="Search booking #, owner, caregiver, service…"
            className="w-full rounded-xl border border-gray-200 bg-white py-2 pl-10 pr-4 text-sm focus:border-[#2C6E69] focus:outline-none focus:ring-1 focus:ring-[#2C6E69]"
          />
        </div>
      </div>

      {/* Status tabs */}
      <div className="mb-4 flex flex-wrap gap-2">
        {STATUS_OPTIONS.map((s) => (
          <button
            key={s}
            onClick={() => setStatusFilter(s)}
            className={`rounded-lg px-3 py-1.5 text-xs font-medium transition-colors ${
              statusFilter === s ? 'bg-[#2C6E69] text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            {s === 'all' ? 'All' : statusLabel(s)} ({counts[s] ?? 0})
          </button>
        ))}
      </div>

      {/* Table */}
      <div className="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-100 bg-gray-50/60">
                {['Booking #', 'Service', 'Owner', 'Caregiver', 'Schedule', 'Amount', 'Status', 'Actions'].map((h) => (
                  <th key={h} className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr>
                  <td colSpan={8} className="py-16 text-center text-sm text-gray-400">No bookings found</td>
                </tr>
              ) : (
                filtered.map((b) => (
                  <tr key={b.id} className="border-b border-gray-50 last:border-0 hover:bg-gray-50/50 transition-colors">
                    <td className="px-4 py-3">
                      <p className="font-mono text-xs font-semibold text-[#2C6E69]">{b.booking_number}</p>
                      <p className="text-xs text-gray-400">{timeAgo(b.created_at)}</p>
                    </td>
                    <td className="px-4 py-3 text-gray-700">{b.service?.service_type?.display_name || '—'}</td>
                    <td className="px-4 py-3 text-xs text-gray-600">
                      <p className="font-medium">{b.pet_owner?.display_name || '—'}</p>
                      <p className="text-gray-400">{b.pet_owner?.email}</p>
                    </td>
                    <td className="px-4 py-3 text-xs text-gray-600">
                      <p className="font-medium">{b.caregiver?.owner?.display_name || '—'}</p>
                      <p className="text-gray-400">{b.caregiver?.city || b.caregiver?.owner?.email}</p>
                    </td>
                    <td className="px-4 py-3 text-xs text-gray-500">
                      <p>{formatDateTime(b.start_datetime)}</p>
                      <p className="text-gray-400">→ {formatDateTime(b.end_datetime)}</p>
                    </td>
                    <td className="px-4 py-3 text-sm font-semibold text-gray-800">
                      {b.currency} {b.total_amount.toLocaleString()}
                    </td>
                    <td className="px-4 py-3">
                      <Badge variant={statusVariant(b.status)}>{statusLabel(b.status)}</Badge>
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-1">
                        <button onClick={() => setSelectedBooking(b)} className="rounded-lg p-1.5 text-gray-400 hover:bg-gray-100 hover:text-[#2C6E69]" title="View">
                          <Eye className="h-4 w-4" />
                        </button>
                        <button onClick={() => setDeleteTarget(b)} className="rounded-lg p-1.5 text-gray-400 hover:bg-red-50 hover:text-red-500" title="Delete">
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
      {selectedBooking && (
        <div className="fixed inset-0 z-50 flex justify-end">
          <div className="absolute inset-0 bg-black/20" onClick={() => setSelectedBooking(null)} />
          <div className="relative w-full max-w-lg overflow-y-auto bg-white shadow-2xl">
            <div className="sticky top-0 z-10 flex items-center justify-between border-b bg-white px-6 py-4">
              <div>
                <h2 className="text-lg font-bold text-gray-900">{selectedBooking.booking_number}</h2>
                <Badge variant={statusVariant(selectedBooking.status)}>{statusLabel(selectedBooking.status)}</Badge>
              </div>
              <button onClick={() => setSelectedBooking(null)} className="rounded-lg p-2 hover:bg-gray-100">
                <X className="h-5 w-5" />
              </button>
            </div>

            <div className="space-y-6 p-6">
              {/* Parties */}
              <div className="grid grid-cols-2 gap-4">
                <div className="rounded-xl bg-gray-50 p-3">
                  <p className="mb-1 text-xs font-semibold uppercase text-gray-400">Pet Owner</p>
                  <p className="text-sm font-medium text-gray-800">{selectedBooking.pet_owner?.display_name || '—'}</p>
                  <p className="text-xs text-gray-500">{selectedBooking.pet_owner?.email}</p>
                </div>
                <div className="rounded-xl bg-gray-50 p-3">
                  <p className="mb-1 text-xs font-semibold uppercase text-gray-400">Caregiver</p>
                  <p className="text-sm font-medium text-gray-800">{selectedBooking.caregiver?.owner?.display_name || '—'}</p>
                  <p className="text-xs text-gray-500">{selectedBooking.caregiver?.city || selectedBooking.caregiver?.owner?.email}</p>
                </div>
              </div>

              {/* Service + Schedule */}
              <div className="grid grid-cols-2 gap-4">
                <InfoItem label="Service" value={selectedBooking.service?.service_type?.display_name} />
                <InfoItem label="Currency" value={selectedBooking.currency} />
                <InfoItem label="Start" value={formatDateTime(selectedBooking.start_datetime)} />
                <InfoItem label="End" value={formatDateTime(selectedBooking.end_datetime)} />
              </div>

              {/* Pricing */}
              <div>
                <p className="mb-2 text-xs font-semibold uppercase text-gray-400">Pricing</p>
                <div className="rounded-xl border border-gray-100 divide-y divide-gray-100">
                  <div className="flex justify-between px-4 py-2 text-sm">
                    <span className="text-gray-500">Base amount</span>
                    <span className="font-medium">{selectedBooking.currency} {selectedBooking.base_amount?.toLocaleString()}</span>
                  </div>
                  <div className="flex justify-between px-4 py-2 text-sm">
                    <span className="text-gray-500">Platform fee</span>
                    <span className="font-medium">{selectedBooking.currency} {selectedBooking.service_fee?.toLocaleString()}</span>
                  </div>
                  <div className="flex justify-between px-4 py-2 text-sm font-bold text-gray-900">
                    <span>Total</span>
                    <span>{selectedBooking.currency} {selectedBooking.total_amount?.toLocaleString()}</span>
                  </div>
                </div>
              </div>

              {/* Payments */}
              {bookingPayments(selectedBooking).length > 0 && (
                <div>
                  <p className="mb-2 text-xs font-semibold uppercase text-gray-400">Payments</p>
                  <div className="space-y-2">
                    {bookingPayments(selectedBooking).map((p) => (
                      <div key={p.id} className="flex items-center justify-between rounded-xl bg-gray-50 px-3 py-2 text-xs">
                        <div className="flex items-center gap-2">
                          <DollarSign className="h-3.5 w-3.5 text-gray-400" />
                          <span className="capitalize text-gray-700">{p.payment_type} · {p.payment_method || 'N/A'}</span>
                        </div>
                        <div className="flex items-center gap-2">
                          <span className="font-semibold text-gray-800">{selectedBooking.currency} {p.amount.toLocaleString()}</span>
                          <Badge variant={p.status === 'completed' ? 'success' : p.status === 'failed' ? 'danger' : 'warning'}>
                            {p.status}
                          </Badge>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Special Instructions */}
              {selectedBooking.special_instructions && (
                <div>
                  <p className="mb-1 text-xs font-semibold uppercase text-gray-400">Special Instructions</p>
                  <p className="rounded-xl bg-gray-50 p-3 text-sm text-gray-700">{selectedBooking.special_instructions}</p>
                </div>
              )}

              {/* Cancellation reason */}
              {selectedBooking.cancellation_reason && (
                <div>
                  <p className="mb-1 text-xs font-semibold uppercase text-gray-400">Cancellation Reason</p>
                  <p className="rounded-xl bg-red-50 p-3 text-sm text-red-700">{selectedBooking.cancellation_reason}</p>
                </div>
              )}

              {/* Status Change */}
              <div>
                <p className="mb-2 text-xs font-semibold uppercase text-gray-400">Change Status</p>
                <div className="flex flex-wrap gap-2">
                  {(['pending', 'accepted', 'in_progress', 'completed', 'declined', 'disputed'] as const).map((s) => (
                    <button
                      key={s}
                      disabled={isPending || selectedBooking.status === s}
                      onClick={() => handleStatusChange(selectedBooking.id, s)}
                      className={`rounded-lg px-3 py-1.5 text-xs font-medium transition-colors disabled:opacity-40 ${
                        selectedBooking.status === s
                          ? 'bg-[#2C6E69] text-white'
                          : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                      }`}
                    >
                      {statusLabel(s)}
                    </button>
                  ))}
                </div>
              </div>

              <p className="text-xs text-gray-300">ID: {selectedBooking.id}</p>

              <button
                onClick={() => { setSelectedBooking(null); setDeleteTarget(selectedBooking); }}
                className="w-full rounded-xl bg-red-50 py-2.5 text-sm font-medium text-red-600 hover:bg-red-100 transition-colors"
              >
                Delete Booking
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Delete Confirm */}
      {deleteTarget && (
        <div className="fixed inset-0 z-[60] flex items-center justify-center">
          <div className="absolute inset-0 bg-black/30" onClick={() => !isPending && setDeleteTarget(null)} />
          <div className="relative w-full max-w-sm rounded-2xl bg-white p-6 shadow-2xl">
            <h3 className="text-lg font-bold text-gray-900">Delete Booking?</h3>
            <p className="mt-2 text-sm text-gray-500">
              Permanently delete booking <strong>{deleteTarget.booking_number}</strong>? This will also remove associated payments and tracking data.
            </p>
            <div className="mt-5 flex gap-3">
              <button onClick={() => setDeleteTarget(null)} disabled={isPending} className="flex-1 rounded-xl border border-gray-200 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:opacity-50">Cancel</button>
              <button onClick={() => handleDelete(deleteTarget.id)} disabled={isPending} className="flex-1 rounded-xl bg-red-600 py-2 text-sm font-medium text-white hover:bg-red-700 disabled:opacity-50">
                {isPending ? 'Deleting…' : 'Delete'}
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
