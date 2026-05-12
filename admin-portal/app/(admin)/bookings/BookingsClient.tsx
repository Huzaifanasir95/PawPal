'use client';

import { useState, useMemo, useTransition, useEffect, type ReactNode } from 'react';
import { AnimatePresence, motion, useAnimation } from 'framer-motion';
import {
  Search,
  Eye,
  Trash2,
  X,
  DollarSign,
  Calendar,
  User,
  Briefcase,
  AlertTriangle,
  Package,
  Shield,
} from 'lucide-react';
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
  pet_owner_id: string;
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
  pet_owner: { id: string; display_name: string | null; email: string | null; avatar_url: string | null } | null;
  caregiver: {
    id: string;
    city: string | null;
    owner: { id: string; display_name: string | null; email: string | null; avatar_url: string | null } | null;
  } | null;
  service: {
    id: string;
    rate_amount: number | null;
    currency: string | null;
    rate_type: string | null;
    service_type: { display_name: string } | null;
  } | null;
}

const STATUS_OPTIONS = [
  'all',
  'pending',
  'accepted',
  'in_progress',
  'completed',
  'declined',
  'cancelled_owner',
  'cancelled_caregiver',
  'disputed',
] as const;

const EASE_OUT = [0.16, 1, 0.3, 1] as const;
const EASE_IN = [0.7, 0, 0.84, 0] as const;

const drawerVariants = {
  hidden: { x: '100%', opacity: 0 },
  show: {
    x: 0,
    opacity: 1,
    transition: { type: 'spring' as const, stiffness: 280, damping: 28, mass: 0.9 },
  },
  exit: { x: '100%', opacity: 0, transition: { duration: 0.22, ease: EASE_IN } },
};

const drawerItemVariants = {
  hidden: { opacity: 0, x: 18 },
  show: { opacity: 1, x: 0, transition: { duration: 0.28, ease: EASE_OUT } },
};

const drawerContentVariants = {
  show: { transition: { staggerChildren: 0.07, delayChildren: 0.08 } },
};

const backdropVariants = {
  hidden: { opacity: 0 },
  show: { opacity: 1, transition: { duration: 0.25, ease: EASE_OUT } },
  exit: { opacity: 0, transition: { duration: 0.2, ease: EASE_IN } },
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

const fadeUp = { hidden: { opacity: 0, y: 12 }, show: { opacity: 1, y: 0 } };

function userInitial(name: string | null | undefined, email: string | null | undefined) {
  return (name || email || '?')[0].toUpperCase();
}

const rowVariants = {
  hidden: { opacity: 0, y: 6 },
  show: (i: number) => ({
    opacity: 1,
    y: 0,
    transition: { duration: 0.22, ease: EASE_OUT, delay: i * 0.03 },
  }),
};

function statusVariant(status: string): 'success' | 'warning' | 'danger' | 'info' | 'purple' | 'default' {
  switch (status) {
    case 'completed':
      return 'success';
    case 'accepted':
      return 'info';
    case 'in_progress':
      return 'purple';
    case 'pending':
      return 'warning';
    case 'declined':
    case 'cancelled_owner':
    case 'cancelled_caregiver':
    case 'disputed':
      return 'danger';
    default:
      return 'default';
  }
}

function statusLabel(status: string) {
  return status.replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());
}

function BkField({ icon, label, value }: { icon: ReactNode; label: string; value: ReactNode }) {
  return (
    <div className="min-w-0">
      <div className="mb-1 flex items-center gap-1">
        <span className="text-[#0B1629]/50">{icon}</span>
        <p className="text-[11px] font-semibold uppercase tracking-widest text-gray-400">{label}</p>
      </div>
      <div className="break-words text-sm font-semibold text-gray-800">{value}</div>
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
        if (selectedBooking?.id === id) {
          setSelectedBooking((prev) => (prev ? { ...prev, status } : null));
        }
      } else {
        alert('Failed to update status: ' + res.error);
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
      } else {
        alert('Failed to delete: ' + res.error);
      }
    });
  }

  return (
    <>
      <motion.div
        className="mb-4 flex flex-wrap items-center gap-3"
        initial="hidden" animate="show" variants={fadeUp}
        transition={{ duration: 0.35, ease: EASE_OUT }}
      >
        <div className="relative flex-1 min-w-[220px]">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search booking #, owner, caregiver, service…"
            className="w-full rounded-xl border border-gray-200 bg-white py-2 pl-10 pr-4 text-sm focus:border-[#0B1629] focus:outline-none focus:ring-1 focus:ring-[#0B1629]"
          />
        </div>
      </motion.div>

      <motion.div
        className="mb-4 flex flex-wrap gap-2"
        initial="hidden" animate="show" variants={fadeUp}
        transition={{ duration: 0.35, ease: EASE_OUT, delay: 0.03 }}
      >
        {STATUS_OPTIONS.map((s) => (
          <button
            key={s}
            type="button"
            onClick={() => setStatusFilter(s)}
            className={`rounded-lg px-3 py-1.5 text-xs font-medium transition-colors ${
              statusFilter === s ? 'bg-[#0B1629] text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            {s === 'all' ? 'All' : statusLabel(s)} ({counts[s] ?? 0})
          </button>
        ))}
      </motion.div>

      <motion.div
        className="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm"
        initial="hidden" animate="show" variants={fadeUp}
        transition={{ duration: 0.35, ease: EASE_OUT, delay: 0.06 }}
      >
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-100 bg-[#0B1629]">
                {['Booking #', 'Service', 'Owner', 'Caregiver', 'Schedule', 'Amount', 'Status', 'Actions'].map(
                  (h) => (
                    <th
                      key={h}
                      className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-widest text-white"
                    >
                      {h}
                    </th>
                  )
                )}
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr>
                  <td colSpan={8} className="py-16 text-center text-sm text-gray-400">
                    No bookings found
                  </td>
                </tr>
              ) : (
                filtered.map((b, i) => (
                  <motion.tr
                    key={b.id}
                    custom={i}
                    variants={rowVariants}
                    initial="hidden"
                    animate="show"
                    className="border-b border-gray-50 last:border-0 transition-colors hover:bg-[#0B1629]/5"
                  >
                    <td className="px-4 py-3">
                      <p className="font-mono text-xs font-semibold text-[#0B1629]">{b.booking_number}</p>
                      <p className="text-xs text-gray-400">{timeAgo(b.created_at)}</p>
                    </td>
                    <td className="px-4 py-3 text-gray-700">
                      {b.service?.service_type?.display_name || '—'}
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-2">
                        {b.pet_owner?.avatar_url ? (
                          <img src={b.pet_owner.avatar_url} alt="" className="h-7 w-7 flex-shrink-0 rounded-full object-cover" />
                        ) : (
                          <div className="flex h-7 w-7 flex-shrink-0 items-center justify-center rounded-full bg-blue-100 text-xs font-bold text-blue-600">
                            {userInitial(b.pet_owner?.display_name, b.pet_owner?.email)}
                          </div>
                        )}
                        <div className="min-w-0">
                          <p className="text-sm font-medium text-gray-800 truncate">{b.pet_owner?.display_name || '—'}</p>
                          <p className="text-xs text-gray-400 truncate">{b.pet_owner?.email}</p>
                        </div>
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-2">
                        {b.caregiver?.owner?.avatar_url ? (
                          <img src={b.caregiver.owner.avatar_url} alt="" className="h-7 w-7 flex-shrink-0 rounded-full object-cover" />
                        ) : (
                          <div className="flex h-7 w-7 flex-shrink-0 items-center justify-center rounded-full bg-[#0B1629]/10 text-xs font-bold text-[#0B1629]">
                            {userInitial(b.caregiver?.owner?.display_name, b.caregiver?.owner?.email)}
                          </div>
                        )}
                        <div className="min-w-0">
                          <p className="text-sm font-medium text-gray-800 truncate">{b.caregiver?.owner?.display_name || '—'}</p>
                          <p className="text-xs text-gray-400 truncate">{b.caregiver?.city || b.caregiver?.owner?.email}</p>
                        </div>
                      </div>
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
                        <motion.button
                          type="button"
                          onClick={() => setSelectedBooking(b)}
                          className="rounded-lg p-1.5 text-gray-400 transition-colors hover:bg-gray-100 hover:text-[#0B1629]"
                          title="View details"
                          whileHover={{ scale: 1.08, y: -1 }}
                          whileTap={{ scale: 0.96 }}
                        >
                          <Eye className="h-4 w-4" />
                        </motion.button>
                        <motion.button
                          type="button"
                          onClick={() => setDeleteTarget(b)}
                          className="rounded-lg p-1.5 text-gray-400 transition-colors hover:bg-red-50 hover:text-red-500"
                          title="Delete"
                          whileHover={{ x: [0, -1.5, 1.5, -1, 1, 0] }}
                          whileTap={{ scale: 0.95 }}
                          transition={{ duration: 0.35 }}
                        >
                          <Trash2 className="h-4 w-4" />
                        </motion.button>
                      </div>
                    </td>
                  </motion.tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </motion.div>

      {/* Right-side animated drawer */}
      <AnimatePresence>
        {selectedBooking && (
          <>
            <motion.div
              className="fixed inset-0 z-40 bg-black/40 backdrop-blur-[3px]"
              variants={backdropVariants}
              initial="hidden"
              animate="show"
              exit="exit"
              onClick={() => setSelectedBooking(null)}
            />
            <motion.aside
              className="fixed inset-y-0 right-0 z-50 flex w-full max-w-md flex-col bg-white shadow-2xl"
              variants={drawerVariants}
              initial="hidden"
              animate="show"
              exit="exit"
            >
              {/* Gradient header */}
              <div
                className="relative flex-shrink-0 overflow-hidden px-6 pb-6 pt-7"
                style={{ background: 'linear-gradient(135deg, #0B1629 0%, #1a3a38 55%, #2C6E69 100%)' }}
              >
                <motion.div
                  className="pointer-events-none absolute inset-0 skew-x-[-20deg] bg-white/5"
                  animate={{ x: ['-120%', '220%'] }}
                  transition={{ duration: 4, repeat: Infinity, ease: 'easeInOut', repeatDelay: 3 }}
                />
                <div className="pointer-events-none absolute -right-10 -top-10 h-48 w-48 rounded-full bg-white/5" />

                <button
                  type="button"
                  onClick={() => setSelectedBooking(null)}
                  className="absolute right-4 top-4 rounded-xl p-2 text-white/60 transition hover:bg-white/10 hover:text-white"
                  aria-label="Close"
                >
                  <X className="h-5 w-5" />
                </button>

                <div className="relative flex items-start gap-4">
                  <div
                    className="flex h-14 w-14 flex-shrink-0 items-center justify-center rounded-2xl bg-white/15 text-white shadow-lg ring-2 ring-white/25"
                    aria-hidden
                  >
                    <Package className="h-7 w-7 opacity-90" />
                  </div>
                  <div className="min-w-0 flex-1 pr-8">
                    <p className="font-mono text-lg font-black tracking-tight text-white">
                      {selectedBooking.booking_number}
                    </p>
                    <p className="mt-0.5 text-sm text-white/60">
                      {selectedBooking.service?.service_type?.display_name || 'Service booking'}
                    </p>
                    <div className="mt-2.5 flex flex-wrap items-center gap-2">
                      <Badge
                        variant={statusVariant(selectedBooking.status)}
                        className="border-0 bg-white/20 text-white ring-1 ring-white/25"
                      >
                        {statusLabel(selectedBooking.status)}
                      </Badge>
                      <span className="inline-flex items-center gap-1 rounded-full bg-white/10 px-2.5 py-1 text-[11px] font-semibold text-white ring-1 ring-white/15">
                        <DollarSign className="h-3 w-3" />
                        {selectedBooking.currency} {selectedBooking.total_amount.toLocaleString()}
                      </span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Scrollable body */}
              <motion.div
                className="flex-1 overflow-y-auto"
                variants={drawerContentVariants}
                initial="hidden"
                animate="show"
              >
                <div className="space-y-4 p-6">

                  {/* Parties */}
                  <motion.div className="grid grid-cols-1 gap-3 sm:grid-cols-2" variants={drawerItemVariants}>
                    <div className="rounded-xl bg-[#0B1629]/5 p-4 ring-1 ring-[#0B1629]/10" style={{ borderLeft: '3px solid #0B1629' }}>
                      <p className="mb-2 flex items-center gap-1.5 text-[11px] font-bold uppercase tracking-widest text-[#0B1629]/70">
                        <User className="h-3.5 w-3.5" />
                        Pet Owner
                      </p>
                      <div className="flex items-center gap-2">
                        {selectedBooking.pet_owner?.avatar_url ? (
                          <img src={selectedBooking.pet_owner.avatar_url} alt="" className="h-8 w-8 flex-shrink-0 rounded-full object-cover" />
                        ) : (
                          <div className="flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-full bg-blue-100 text-xs font-bold text-blue-600">
                            {userInitial(selectedBooking.pet_owner?.display_name, selectedBooking.pet_owner?.email)}
                          </div>
                        )}
                        <div className="min-w-0">
                          <p className="truncate text-sm font-bold text-gray-900">{selectedBooking.pet_owner?.display_name || '—'}</p>
                          <p className="truncate text-xs text-gray-500">{selectedBooking.pet_owner?.email}</p>
                        </div>
                      </div>
                    </div>
                    <div className="rounded-xl bg-[#0B1629]/5 p-4 ring-1 ring-[#0B1629]/10" style={{ borderLeft: '3px solid #0B1629' }}>
                      <p className="mb-2 flex items-center gap-1.5 text-[11px] font-bold uppercase tracking-widest text-[#0B1629]/70">
                        <Briefcase className="h-3.5 w-3.5" />
                        Caregiver
                      </p>
                      <div className="flex items-center gap-2">
                        {selectedBooking.caregiver?.owner?.avatar_url ? (
                          <img src={selectedBooking.caregiver.owner.avatar_url} alt="" className="h-8 w-8 flex-shrink-0 rounded-full object-cover" />
                        ) : (
                          <div className="flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-full bg-[#0B1629]/10 text-xs font-bold text-[#0B1629]">
                            {userInitial(selectedBooking.caregiver?.owner?.display_name, selectedBooking.caregiver?.owner?.email)}
                          </div>
                        )}
                        <div className="min-w-0">
                          <p className="truncate text-sm font-bold text-gray-900">{selectedBooking.caregiver?.owner?.display_name || '—'}</p>
                          <p className="truncate text-xs text-gray-500">{selectedBooking.caregiver?.city || selectedBooking.caregiver?.owner?.email || '—'}</p>
                        </div>
                      </div>
                    </div>
                  </motion.div>

                  {/* Schedule */}
                  <motion.section
                    className="overflow-hidden rounded-2xl border border-[#0B1629]/15 bg-[#0B1629]/5 p-4 shadow-sm"
                    style={{ borderLeft: '3px solid #0B1629' }}
                    variants={drawerItemVariants}
                  >
                    <div className="mb-3 flex items-center gap-2">
                      <div className="flex h-6 w-6 items-center justify-center rounded-lg bg-[#0B1629]/10">
                        <Calendar className="h-3.5 w-3.5 text-[#0B1629]" />
                      </div>
                      <h3 className="text-[11px] font-bold uppercase tracking-widest text-[#0B1629]">
                        Schedule &amp; Service
                      </h3>
                    </div>
                    <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
                      <BkField
                        icon={<Package className="h-3 w-3" />}
                        label="Service"
                        value={selectedBooking.service?.service_type?.display_name || '—'}
                      />
                      <BkField
                        icon={<Shield className="h-3 w-3" />}
                        label="Currency"
                        value={selectedBooking.currency}
                      />
                      <BkField
                        icon={<Calendar className="h-3 w-3" />}
                        label="Start"
                        value={formatDateTime(selectedBooking.start_datetime)}
                      />
                      <BkField
                        icon={<Calendar className="h-3 w-3" />}
                        label="End"
                        value={formatDateTime(selectedBooking.end_datetime)}
                      />
                    </div>
                  </motion.section>

                  {/* Pricing */}
                  <motion.section
                    className="overflow-hidden rounded-2xl border border-[#0B1629]/15 bg-[#0B1629]/5 p-4 shadow-sm"
                    style={{ borderLeft: '3px solid #0B1629' }}
                    variants={drawerItemVariants}
                  >
                    <div className="mb-2 flex items-center gap-2">
                      <DollarSign className="h-4 w-4 text-[#0B1629]" />
                      <h3 className="text-[11px] font-bold uppercase tracking-widest text-[#0B1629]">
                        Pricing
                      </h3>
                    </div>
                    <div className="divide-y divide-gray-100 rounded-xl border border-gray-100 bg-white/80">
                      <div className="flex justify-between px-4 py-2 text-sm">
                        <span className="text-gray-500">Base amount</span>
                        <span className="font-medium">
                          {selectedBooking.currency} {selectedBooking.base_amount?.toLocaleString()}
                        </span>
                      </div>
                      <div className="flex justify-between px-4 py-2 text-sm">
                        <span className="text-gray-500">Platform fee</span>
                        <span className="font-medium">
                          {selectedBooking.currency} {selectedBooking.service_fee?.toLocaleString()}
                        </span>
                      </div>
                      <div className="flex justify-between px-4 py-2 text-sm font-bold text-gray-900">
                        <span>Total</span>
                        <span>
                          {selectedBooking.currency} {selectedBooking.total_amount?.toLocaleString()}
                        </span>
                      </div>
                    </div>
                  </motion.section>

                  {/* Payments */}
                  {bookingPayments(selectedBooking).length > 0 && (
                    <motion.section variants={drawerItemVariants}>
                      <p className="mb-2 text-[11px] font-bold uppercase tracking-widest text-[#0B1629]">
                        Payments
                      </p>
                      <div className="space-y-2">
                        {bookingPayments(selectedBooking).map((p) => (
                          <div
                            key={p.id}
                            className="flex items-center justify-between rounded-xl bg-gray-50 px-3 py-2 text-xs"
                          >
                            <div className="flex items-center gap-2">
                              <DollarSign className="h-3.5 w-3.5 text-gray-400" />
                              <span className="capitalize text-gray-700">
                                {p.payment_type} · {p.payment_method || 'N/A'}
                              </span>
                            </div>
                            <div className="flex items-center gap-2">
                              <span className="font-semibold text-gray-800">
                                {selectedBooking.currency} {p.amount.toLocaleString()}
                              </span>
                              <Badge
                                variant={
                                  p.status === 'completed'
                                    ? 'success'
                                    : p.status === 'failed'
                                      ? 'danger'
                                      : 'warning'
                                }
                              >
                                {p.status}
                              </Badge>
                            </div>
                          </div>
                        ))}
                      </div>
                    </motion.section>
                  )}

                  {/* Special instructions */}
                  {selectedBooking.special_instructions && (
                    <motion.div
                      className="rounded-2xl border border-[#0B1629]/15 bg-[#0B1629]/5 p-4"
                      style={{ borderLeft: '3px solid #0B1629' }}
                      variants={drawerItemVariants}
                    >
                      <p className="mb-1 text-[11px] font-bold uppercase tracking-widest text-[#0B1629]">
                        Special Instructions
                      </p>
                      <p className="text-sm text-gray-700 leading-relaxed">
                        {selectedBooking.special_instructions}
                      </p>
                    </motion.div>
                  )}

                  {/* Cancellation reason */}
                  {selectedBooking.cancellation_reason && (
                    <motion.div
                      className="rounded-xl border border-red-100 bg-red-50/60 p-3"
                      variants={drawerItemVariants}
                    >
                      <p className="mb-1 text-xs font-semibold uppercase text-red-600">
                        Cancellation Reason
                      </p>
                      <p className="text-sm text-red-800">{selectedBooking.cancellation_reason}</p>
                    </motion.div>
                  )}

                  {/* Change status */}
                  <motion.section variants={drawerItemVariants}>
                    <p className="mb-2 text-[11px] font-bold uppercase tracking-widest text-gray-400">
                      Change Status
                    </p>
                    <div className="flex flex-wrap gap-2">
                      {(
                        [
                          'pending',
                          'accepted',
                          'in_progress',
                          'completed',
                          'declined',
                          'disputed',
                        ] as const
                      ).map((s) => (
                        <button
                          key={s}
                          type="button"
                          disabled={isPending || selectedBooking.status === s}
                          onClick={() => handleStatusChange(selectedBooking.id, s)}
                          className={`rounded-lg px-3 py-1.5 text-xs font-medium transition-colors disabled:opacity-40 ${
                            selectedBooking.status === s
                              ? 'bg-[#0B1629] text-white'
                              : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                          }`}
                        >
                          {statusLabel(s)}
                        </button>
                      ))}
                    </div>
                  </motion.section>
                </div>
              </motion.div>

              {/* Sticky footer */}
              <div className="flex flex-shrink-0 flex-wrap items-center justify-between gap-3 border-t border-gray-100 bg-gray-50/60 px-6 py-4">
                <motion.button
                  type="button"
                  onClick={() => setSelectedBooking(null)}
                  className="rounded-xl border border-gray-200 bg-white px-5 py-2.5 text-sm font-medium text-gray-600 transition hover:bg-gray-100"
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.97 }}
                >
                  Close
                </motion.button>
                <motion.button
                  type="button"
                  onClick={() => {
                    const b = selectedBooking;
                    setSelectedBooking(null);
                    setDeleteTarget(b);
                  }}
                  className="flex items-center gap-2 rounded-xl bg-red-500 px-5 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-red-600"
                  whileHover={{ scale: 1.02, x: [0, -2, 2, -1, 1, 0] }}
                  whileTap={{ scale: 0.97 }}
                  transition={{ duration: 0.35 }}
                >
                  <Trash2 className="h-4 w-4" />
                  Delete
                </motion.button>
              </div>
            </motion.aside>
          </>
        )}
      </AnimatePresence>

      <DeleteBookingConfirmModal
        booking={deleteTarget}
        open={!!deleteTarget}
        isPending={isPending}
        onCancel={() => !isPending && setDeleteTarget(null)}
        onConfirm={() => deleteTarget && handleDelete(deleteTarget.id)}
      />
    </>
  );
}

function DeleteBookingConfirmModal({
  booking,
  open,
  isPending,
  onCancel,
  onConfirm,
}: {
  booking: Booking | null;
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
      {open && booking && (
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
                  <h3 className="text-lg font-semibold text-gray-900">Delete booking?</h3>
                  <p className="mt-1 text-sm text-gray-500">
                    Permanently delete booking <strong>{booking.booking_number}</strong>? Associated
                    payments and tracking data will be removed.
                  </p>
                </div>
              </motion.div>

              <motion.div
                className="mt-4 flex items-center gap-3 rounded-2xl border border-red-100 bg-red-50/40 p-3"
                variants={deleteItemVariants}
              >
                <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-white font-mono text-xs font-bold text-[#0B1629] ring-1 ring-red-100">
                  #
                </div>
                <div className="min-w-0">
                  <p className="truncate font-mono text-sm font-semibold text-gray-900">
                    {booking.booking_number}
                  </p>
                  <p className="truncate text-xs text-gray-500">
                    {booking.pet_owner?.display_name || booking.service?.service_type?.display_name || '—'}
                  </p>
                </div>
              </motion.div>

              <motion.div className="mt-5 flex gap-3" variants={deleteItemVariants}>
                <button
                  type="button"
                  disabled={isPending}
                  onClick={onCancel}
                  className="flex-1 rounded-xl border border-gray-200 bg-white py-2.5 text-sm font-medium text-gray-600 transition hover:bg-gray-50 disabled:opacity-50"
                >
                  Cancel
                </button>
                <motion.button
                  type="button"
                  disabled={isPending}
                  onClick={onConfirm}
                  className="flex-1 rounded-xl bg-red-500 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-red-600 disabled:opacity-50"
                  whileHover={!isPending ? { scale: 1.02 } : {}}
                  whileTap={!isPending ? { scale: 0.98 } : {}}
                >
                  {isPending ? (
                    <span className="inline-flex items-center justify-center gap-2">
                      <span className="h-4 w-4 animate-spin rounded-full border-2 border-white/70 border-t-transparent" />
                      Deleting…
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
