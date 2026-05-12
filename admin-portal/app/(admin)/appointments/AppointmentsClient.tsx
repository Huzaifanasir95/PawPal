'use client';

import { useState, useMemo, useTransition, useEffect } from 'react';
import { AnimatePresence, motion, useAnimation } from 'framer-motion';
import { Search, Eye, Trash2, X, Video, MapPin, MessageSquare, Clock, AlertTriangle, Stethoscope, User, Calendar } from 'lucide-react';
import Badge from '@/components/Badge';
import { formatDateTime, timeAgo } from '@/lib/utils';
import { updateVetAppointmentStatus, deleteVetAppointment } from '@/lib/admin-actions';

export interface Appointment {
  id: string;
  appointment_number: string;
  reason: string;
  symptoms: string | null;
  owner_notes: string | null;
  appointment_datetime: string;
  duration_minutes: number;
  meeting_type: string;
  clinic_address: string | null;
  meeting_link: string | null;
  fee_amount: number;
  currency: string;
  status: string;
  response_note: string | null;
  responded_at: string | null;
  cancelled_at: string | null;
  completed_at: string | null;
  created_at: string;
  updated_at: string;
  owner: { id: string; display_name: string | null; email: string | null } | null;
  vet: { id: string; display_name: string | null; email: string | null } | null;
  pet: { id: string; name: string; type: string; breed: string } | null;
}

const ALL_STATUSES = ['requested', 'confirmed', 'completed', 'declined', 'cancelled_owner', 'cancelled_vet'];

function statusVariant(status: string): 'success' | 'info' | 'warning' | 'danger' | 'default' {
  switch (status) {
    case 'completed': return 'success';
    case 'confirmed': return 'info';
    case 'requested': return 'warning';
    case 'declined':
    case 'cancelled_owner':
    case 'cancelled_vet': return 'danger';
    default: return 'default';
  }
}

function statusLabel(s: string) {
  return s.replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());
}

function meetingIcon(type: string) {
  switch (type) {
    case 'video': return <Video className="h-3.5 w-3.5" />;
    case 'chat': return <MessageSquare className="h-3.5 w-3.5" />;
    default: return <MapPin className="h-3.5 w-3.5" />;
  }
}

// ── Animation constants ──────────────────────────────────────────────────────

const EASE_OUT = [0.16, 1, 0.3, 1] as const;
const EASE_IN  = [0.7, 0, 0.84, 0] as const;

const fadeUp = { hidden: { opacity: 0, y: 12 }, show: { opacity: 1, y: 0 } };

const backdropVariants = {
  hidden: { opacity: 0 },
  show:   { opacity: 1, transition: { duration: 0.25, ease: EASE_OUT } },
  exit:   { opacity: 0, transition: { duration: 0.2,  ease: EASE_IN  } },
};

const drawerVariants = {
  hidden: { x: '100%', opacity: 0 },
  show:   { x: 0, opacity: 1, transition: { type: 'spring' as const, stiffness: 280, damping: 28, mass: 0.9 } },
  exit:   { x: '100%', opacity: 0, transition: { duration: 0.22, ease: EASE_IN } },
};

const drawerItemVariants = {
  hidden: { opacity: 0, x: 18 },
  show:   { opacity: 1, x: 0, transition: { duration: 0.28, ease: EASE_OUT } },
};

const drawerContentVariants = {
  show: { transition: { staggerChildren: 0.07, delayChildren: 0.08 } },
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
    opacity: 1, scale: 1, y: 0, rotateZ: 0,
    transition: { type: 'spring' as const, stiffness: 520, damping: 26, mass: 0.7 },
  },
  exit: { opacity: 0, scale: 0.92, y: 16, transition: { duration: 0.2 } },
};

const deleteContentVariants = {
  show: { transition: { staggerChildren: 0.08, delayChildren: 0.05 } },
};

const deleteItemVariants = {
  hidden: { opacity: 0, y: 8 },
  show:   { opacity: 1, y: 0, transition: { duration: 0.22, ease: EASE_OUT } },
};

// ── Main component ───────────────────────────────────────────────────────────

export default function AppointmentsClient({ appointments: initialAppointments }: { appointments: Appointment[] }) {
  const [appointments, setAppointments] = useState(initialAppointments);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [meetingFilter, setMeetingFilter] = useState('all');
  const [selected, setSelected] = useState<Appointment | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<Appointment | null>(null);
  const [isPending, startTransition] = useTransition();

  const filtered = useMemo(() => {
    return appointments.filter((a) => {
      const q = search.toLowerCase();
      const matchesSearch =
        !q ||
        a.appointment_number.toLowerCase().includes(q) ||
        (a.owner?.display_name ?? '').toLowerCase().includes(q) ||
        (a.owner?.email ?? '').toLowerCase().includes(q) ||
        (a.vet?.display_name ?? '').toLowerCase().includes(q) ||
        (a.pet?.name ?? '').toLowerCase().includes(q) ||
        a.reason.toLowerCase().includes(q);
      const matchesStatus = statusFilter === 'all' || a.status === statusFilter;
      const matchesMeeting = meetingFilter === 'all' || a.meeting_type === meetingFilter;
      return matchesSearch && matchesStatus && matchesMeeting;
    });
  }, [appointments, search, statusFilter, meetingFilter]);

  const counts = useMemo(() => {
    const result: Record<string, number> = { all: appointments.length };
    ALL_STATUSES.forEach((s) => { result[s] = appointments.filter((a) => a.status === s).length; });
    return result;
  }, [appointments]);

  function handleStatusChange(id: string, status: string) {
    startTransition(async () => {
      const res = await updateVetAppointmentStatus(id, status);
      if (res.success) {
        setAppointments((prev) => prev.map((a) => a.id === id ? { ...a, status } : a));
        if (selected?.id === id) setSelected((prev) => prev ? { ...prev, status } : null);
      }
    });
  }

  function handleDelete(id: string) {
    startTransition(async () => {
      const res = await deleteVetAppointment(id);
      if (res.success) {
        setAppointments((prev) => prev.filter((a) => a.id !== id));
        setDeleteTarget(null);
        if (selected?.id === id) setSelected(null);
      }
    });
  }

  const display = selected;

  return (
    <>
      {/* Filters */}
      <motion.div
        className="mb-4 flex flex-wrap items-center gap-3"
        initial="hidden"
        animate="show"
        variants={fadeUp}
        transition={{ duration: 0.35, ease: EASE_OUT }}
      >
        <div className="relative flex-1 min-w-[220px]">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search appt #, owner, vet, pet, reason…"
            className="w-full rounded-xl border border-gray-200 bg-white py-2 pl-10 pr-4 text-sm focus:border-[#0B1629] focus:outline-none focus:ring-1 focus:ring-[#0B1629]"
          />
        </div>
        <div className="flex gap-1 rounded-xl border border-gray-200 bg-white p-1">
          {(['all', 'in_person', 'video', 'chat'] as const).map((f) => (
            <button
              key={f}
              onClick={() => setMeetingFilter(f)}
              className={`flex items-center gap-1.5 rounded-lg px-3 py-1.5 text-xs font-medium capitalize transition-colors ${meetingFilter === f ? 'bg-[#0B1629] text-white' : 'text-gray-500 hover:text-gray-700'}`}
            >
              {f !== 'all' && meetingIcon(f)}
              {f === 'in_person' ? 'In Person' : f}
            </button>
          ))}
        </div>
      </motion.div>

      {/* Status tabs */}
      <motion.div
        className="mb-4 flex flex-wrap gap-2"
        initial="hidden"
        animate="show"
        variants={fadeUp}
        transition={{ duration: 0.35, ease: EASE_OUT, delay: 0.03 }}
      >
        <button
          onClick={() => setStatusFilter('all')}
          className={`rounded-lg px-3 py-1.5 text-xs font-medium transition-colors ${statusFilter === 'all' ? 'bg-[#0B1629] text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}
        >
          All ({counts.all})
        </button>
        {ALL_STATUSES.map((s) => (
          <button
            key={s}
            onClick={() => setStatusFilter(s)}
            className={`rounded-lg px-3 py-1.5 text-xs font-medium transition-colors ${statusFilter === s ? 'bg-[#0B1629] text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}
          >
            {statusLabel(s)} ({counts[s] ?? 0})
          </button>
        ))}
      </motion.div>

      {/* Table */}
      <motion.div
        className="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm"
        initial="hidden"
        animate="show"
        variants={fadeUp}
        transition={{ duration: 0.35, ease: EASE_OUT, delay: 0.06 }}
      >
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-100 bg-[#0B1629]">
                {['Appointment', 'Pet', 'Owner', 'Vet', 'Scheduled', 'Type', 'Fee', 'Status', 'Actions'].map((h) => (
                  <th key={h} className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-widest text-white">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr><td colSpan={9} className="py-16 text-center text-sm text-gray-400">No appointments found</td></tr>
              ) : (
                filtered.map((a, i) => (
                  <motion.tr
                    key={a.id}
                    className="border-b border-gray-50 last:border-0 hover:bg-[#0B1629]/5 transition-colors"
                    initial={{ opacity: 0, x: -12 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ duration: 0.25, ease: EASE_OUT, delay: i * 0.03 }}
                  >
                    <td className="px-4 py-3">
                      <p className="font-mono text-xs font-semibold text-[#0B1629]">{a.appointment_number}</p>
                      <p className="text-xs text-gray-400">{timeAgo(a.created_at)}</p>
                    </td>
                    <td className="px-4 py-3 text-xs text-gray-600">
                      <p className="font-medium capitalize">{a.pet?.name || '—'}</p>
                      <p className="text-gray-400 capitalize">{a.pet?.type} · {a.pet?.breed}</p>
                    </td>
                    <td className="px-4 py-3 text-xs text-gray-600">
                      <p className="font-medium">{a.owner?.display_name || '—'}</p>
                      <p className="text-gray-400">{a.owner?.email}</p>
                    </td>
                    <td className="px-4 py-3 text-xs text-gray-600">
                      <p className="font-medium">{a.vet?.display_name || '—'}</p>
                      <p className="text-gray-400">{a.vet?.email}</p>
                    </td>
                    <td className="px-4 py-3 text-xs text-gray-500">
                      <p>{formatDateTime(a.appointment_datetime)}</p>
                      <p className="flex items-center gap-1 text-gray-400"><Clock className="h-3 w-3" /> {a.duration_minutes} min</p>
                    </td>
                    <td className="px-4 py-3">
                      <span className={`flex items-center gap-1.5 text-xs font-medium capitalize ${a.meeting_type === 'video' ? 'text-blue-600' : a.meeting_type === 'chat' ? 'text-purple-600' : 'text-gray-600'}`}>
                        {meetingIcon(a.meeting_type)}
                        {a.meeting_type === 'in_person' ? 'In Person' : a.meeting_type}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-sm font-semibold text-gray-800">
                      {a.currency} {a.fee_amount.toLocaleString()}
                    </td>
                    <td className="px-4 py-3">
                      <Badge variant={statusVariant(a.status)}>{statusLabel(a.status)}</Badge>
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-1">
                        <motion.button
                          onClick={() => setSelected(a)}
                          className="rounded-lg p-1.5 text-gray-400 hover:bg-[#0B1629]/5 hover:text-[#0B1629] transition-colors"
                          title="View"
                          whileHover={{ scale: 1.08, y: -1 }}
                          whileTap={{ scale: 0.96 }}
                        >
                          <Eye className="h-4 w-4" />
                        </motion.button>
                        <motion.button
                          onClick={() => setDeleteTarget(a)}
                          className="rounded-lg p-1.5 text-gray-400 hover:bg-red-50 hover:text-red-500 transition-colors"
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

      {/* ── Right-side Detail Drawer ── */}
      <AnimatePresence>
        {display && (
          <motion.div className="fixed inset-0 z-50 flex justify-end">
            <motion.div
              className="absolute inset-0 bg-black/40 backdrop-blur-[2px]"
              onClick={() => setSelected(null)}
              variants={backdropVariants}
              initial="hidden"
              animate="show"
              exit="exit"
            />

            <motion.div
              className="relative flex h-full w-full max-w-lg flex-col bg-white shadow-2xl"
              variants={drawerVariants}
              initial="hidden"
              animate="show"
              exit="exit"
            >
              {/* Branded header */}
              <div
                className="relative flex-shrink-0 overflow-hidden px-6 pb-5 pt-6"
                style={{ background: 'linear-gradient(135deg, #0B1629 0%, #1a3a38 55%, #2C6E69 100%)' }}
              >
                <motion.div
                  className="pointer-events-none absolute inset-0 skew-x-[-20deg] bg-white/5"
                  animate={{ x: ['-120%', '220%'] }}
                  transition={{ duration: 4, repeat: Infinity, ease: 'easeInOut', repeatDelay: 3 }}
                />
                <div className="pointer-events-none absolute -right-8 -top-8 h-40 w-40 rounded-full bg-white/5" />

                <button
                  type="button"
                  onClick={() => setSelected(null)}
                  className="absolute right-4 top-4 rounded-xl p-2 text-white/60 transition hover:bg-white/10 hover:text-white"
                  aria-label="Close"
                >
                  <X className="h-5 w-5" />
                </button>

                <div className="relative flex items-start gap-4">
                  <div
                    className="flex h-14 w-14 flex-shrink-0 items-center justify-center rounded-2xl text-xl ring-2 ring-white/30 shadow-lg"
                    style={{ background: 'linear-gradient(135deg, #1a4a45, #3d8f89)' }}
                  >
                    {display.pet?.type === 'cat' ? '🐈' : '🐕'}
                  </div>
                  <div className="min-w-0 flex-1 pr-8">
                    <p className="font-mono text-base font-black leading-tight text-white truncate">{display.appointment_number}</p>
                    <p className="mt-0.5 text-sm text-white/55 truncate capitalize">
                      {display.pet?.name || '—'} · {display.pet?.type} · {display.pet?.breed}
                    </p>
                    <div className="mt-2 flex flex-wrap items-center gap-2">
                      <Badge variant={statusVariant(display.status)}>{statusLabel(display.status)}</Badge>
                      <span className={`inline-flex items-center gap-1 rounded-full bg-white/10 px-2.5 py-0.5 text-[11px] font-semibold text-white ring-1 ring-white/15 capitalize ${display.meeting_type === 'video' ? '' : ''}`}>
                        {meetingIcon(display.meeting_type)}
                        {display.meeting_type === 'in_person' ? 'In Person' : display.meeting_type}
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
                  <motion.div
                    className="grid grid-cols-2 gap-3"
                    variants={drawerItemVariants}
                  >
                    <div className="rounded-2xl border border-[#0B1629]/10 bg-[#0B1629]/5 p-3" style={{ borderLeft: '3px solid #0B1629' }}>
                      <div className="mb-1.5 flex items-center gap-1.5">
                        <User className="h-3.5 w-3.5 text-[#0B1629]/60" />
                        <p className="text-[11px] font-bold uppercase tracking-widest text-[#0B1629]/70">Pet Owner</p>
                      </div>
                      <p className="text-sm font-semibold text-gray-800 truncate">{display.owner?.display_name || '—'}</p>
                      <p className="text-xs text-gray-400 truncate">{display.owner?.email}</p>
                    </div>
                    <div className="rounded-2xl border border-[#0B1629]/10 bg-[#0B1629]/5 p-3" style={{ borderLeft: '3px solid #0B1629' }}>
                      <div className="mb-1.5 flex items-center gap-1.5">
                        <Stethoscope className="h-3.5 w-3.5 text-[#0B1629]/60" />
                        <p className="text-[11px] font-bold uppercase tracking-widest text-[#0B1629]/70">Veterinarian</p>
                      </div>
                      <p className="text-sm font-semibold text-gray-800 truncate">{display.vet?.display_name || '—'}</p>
                      <p className="text-xs text-gray-400 truncate">{display.vet?.email}</p>
                    </div>
                  </motion.div>

                  {/* Schedule */}
                  <motion.section
                    className="overflow-hidden rounded-2xl border border-[#0B1629]/10 bg-[#0B1629]/5 p-4 shadow-sm"
                    style={{ borderLeft: '3px solid #0B1629' }}
                    variants={drawerItemVariants}
                  >
                    <div className="mb-3 flex items-center gap-2">
                      <div className="flex h-6 w-6 items-center justify-center rounded-lg bg-[#0B1629]/10">
                        <Calendar className="h-3.5 w-3.5 text-[#0B1629]" />
                      </div>
                      <h3 className="text-[11px] font-bold uppercase tracking-widest text-[#0B1629]/70">Schedule</h3>
                    </div>
                    <div className="grid grid-cols-2 gap-x-6 gap-y-3">
                      <div>
                        <p className="text-[11px] font-semibold uppercase tracking-widest text-gray-400">Date & Time</p>
                        <p className="mt-0.5 text-sm font-medium text-gray-800">{formatDateTime(display.appointment_datetime)}</p>
                      </div>
                      <div>
                        <p className="text-[11px] font-semibold uppercase tracking-widest text-gray-400">Duration</p>
                        <p className="mt-0.5 text-sm font-medium text-gray-800">{display.duration_minutes} minutes</p>
                      </div>
                      <div>
                        <p className="text-[11px] font-semibold uppercase tracking-widest text-gray-400">Fee</p>
                        <p className="mt-0.5 text-sm font-medium text-gray-800">{display.currency} {display.fee_amount.toLocaleString()}</p>
                      </div>
                      {display.clinic_address && (
                        <div>
                          <p className="text-[11px] font-semibold uppercase tracking-widest text-gray-400">Clinic Address</p>
                          <p className="mt-0.5 text-sm font-medium text-gray-800">{display.clinic_address}</p>
                        </div>
                      )}
                      {display.responded_at && (
                        <div>
                          <p className="text-[11px] font-semibold uppercase tracking-widest text-gray-400">Responded At</p>
                          <p className="mt-0.5 text-sm font-medium text-gray-800">{formatDateTime(display.responded_at)}</p>
                        </div>
                      )}
                      {display.completed_at && (
                        <div>
                          <p className="text-[11px] font-semibold uppercase tracking-widest text-gray-400">Completed At</p>
                          <p className="mt-0.5 text-sm font-medium text-gray-800">{formatDateTime(display.completed_at)}</p>
                        </div>
                      )}
                    </div>
                  </motion.section>

                  {/* Reason & Notes */}
                  <motion.div variants={drawerItemVariants}>
                    <p className="mb-1.5 text-[11px] font-bold uppercase tracking-widest text-[#0B1629]/70">Reason</p>
                    <div className="rounded-2xl border border-[#0B1629]/10 bg-[#0B1629]/5 p-4" style={{ borderLeft: '3px solid #0B1629' }}>
                      <p className="text-sm text-gray-700 leading-relaxed">{display.reason}</p>
                    </div>
                  </motion.div>

                  {display.symptoms && (
                    <motion.div variants={drawerItemVariants}>
                      <p className="mb-1.5 text-[11px] font-bold uppercase tracking-widest text-gray-400">Symptoms</p>
                      <p className="rounded-2xl bg-amber-50 border border-amber-100 p-4 text-sm text-amber-800 leading-relaxed">{display.symptoms}</p>
                    </motion.div>
                  )}

                  {display.owner_notes && (
                    <motion.div variants={drawerItemVariants}>
                      <p className="mb-1.5 text-[11px] font-bold uppercase tracking-widest text-gray-400">Owner Notes</p>
                      <p className="rounded-2xl bg-gray-50 border border-gray-100 p-4 text-sm text-gray-700 leading-relaxed">{display.owner_notes}</p>
                    </motion.div>
                  )}

                  {display.response_note && (
                    <motion.div variants={drawerItemVariants}>
                      <p className="mb-1.5 text-[11px] font-bold uppercase tracking-widest text-gray-400">Vet Response</p>
                      <p className="rounded-2xl bg-blue-50 border border-blue-100 p-4 text-sm text-blue-800 leading-relaxed">{display.response_note}</p>
                    </motion.div>
                  )}

                  {/* Change Status */}
                  <motion.section variants={drawerItemVariants}>
                    <p className="mb-2 text-[11px] font-bold uppercase tracking-widest text-gray-400">Change Status</p>
                    <div className="flex flex-wrap gap-2">
                      {ALL_STATUSES.map((s) => (
                        <button
                          key={s}
                          disabled={isPending || display.status === s}
                          onClick={() => handleStatusChange(display.id, s)}
                          className={`rounded-lg px-3 py-1.5 text-xs font-medium transition-colors disabled:opacity-40 ${display.status === s ? 'bg-[#0B1629] text-white' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'}`}
                        >
                          {statusLabel(s)}
                        </button>
                      ))}
                    </div>
                  </motion.section>

                </div>
              </motion.div>

              {/* Sticky footer */}
              <div className="flex-shrink-0 flex flex-wrap items-center justify-between gap-3 border-t border-gray-100 bg-gray-50/80 px-6 py-4">
                <motion.button
                  type="button"
                  onClick={() => setSelected(null)}
                  className="rounded-xl border border-gray-200 bg-white px-5 py-2.5 text-sm font-medium text-gray-600 transition hover:bg-gray-100"
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.97 }}
                >
                  Close
                </motion.button>
                <motion.button
                  onClick={() => { setSelected(null); setDeleteTarget(display); }}
                  className="flex items-center gap-2 rounded-xl bg-red-500 px-5 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-red-600"
                  whileHover={{ scale: 1.02, x: [0, -2, 2, -1, 1, 0] }}
                  whileTap={{ scale: 0.97 }}
                  transition={{ duration: 0.35 }}
                >
                  <Trash2 className="h-4 w-4" />
                  Delete Appointment
                </motion.button>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* ── Delete Modal ── */}
      <DeleteAppointmentModal
        appointment={deleteTarget}
        open={!!deleteTarget}
        isPending={isPending}
        onCancel={() => !isPending && setDeleteTarget(null)}
        onConfirm={() => deleteTarget && handleDelete(deleteTarget.id)}
      />
    </>
  );
}

// ── Animated delete confirmation ─────────────────────────────────────────────

function DeleteAppointmentModal({
  appointment,
  open,
  isPending,
  onCancel,
  onConfirm,
}: {
  appointment: Appointment | null;
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
      {open && appointment && (
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
            <motion.div className="px-6 py-5" variants={deleteContentVariants} initial="hidden" animate="show">
              <motion.div className="flex items-start gap-4" variants={deleteItemVariants}>
                <motion.div
                  className="flex h-12 w-12 items-center justify-center rounded-2xl bg-red-50 text-red-600 ring-1 ring-red-100"
                  animate={warningControls}
                >
                  <AlertTriangle className="h-6 w-6" />
                </motion.div>
                <div>
                  <h3 className="text-lg font-semibold text-gray-900">Delete appointment?</h3>
                  <p className="mt-1 text-sm text-gray-500">
                    Permanently delete appointment <strong>{appointment.appointment_number}</strong>? This cannot be undone.
                  </p>
                </div>
              </motion.div>

              <motion.div
                className="mt-4 flex items-center gap-3 rounded-2xl border border-red-100 bg-red-50/40 p-3"
                variants={deleteItemVariants}
              >
                <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-white text-xl ring-1 ring-red-100">
                  {appointment.pet?.type === 'cat' ? '🐈' : '🐕'}
                </div>
                <div className="min-w-0">
                  <p className="font-mono text-sm font-semibold text-gray-900 truncate">{appointment.appointment_number}</p>
                  <p className="text-xs text-gray-500 truncate capitalize">
                    {appointment.pet?.name || '—'} · {appointment.owner?.display_name || '—'}
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
