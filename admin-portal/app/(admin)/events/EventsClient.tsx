'use client';

import { useState, useMemo, useTransition, useEffect } from 'react';
import { AnimatePresence, motion, useAnimation } from 'framer-motion';
import {
  Search, Trash2, Eye, X, MapPin, Users, Calendar,
  AlertTriangle, User, Edit,
} from 'lucide-react';
import { formatDateTime, timeAgo } from '@/lib/utils';
import Badge from '@/components/Badge';
import { deleteEvent, updateEventStatus } from '@/lib/admin-actions';

interface RSVP {
  id: string;
  user_name: string;
  status: string;
  created_at: string;
}

interface Event {
  id: string;
  title: string;
  description: string | null;
  event_type: string | null;
  location: string | null;
  start_date: string | null;
  end_date: string | null;
  max_attendees: number | null;
  rsvp_count: number | null;
  status: string | null;
  created_at: string;
  organizer_id: string;
  organizer: { name: string | null; email: string | null } | null;
  rsvps: RSVP[];
}

type StatusFilter = 'all' | 'upcoming' | 'past' | 'cancelled';

// ── Animation constants ──────────────────────────────────────────────────────

const EASE_OUT = [0.16, 1, 0.3, 1] as const;
const EASE_IN  = [0.7, 0, 0.84, 0] as const;

const drawerVariants = {
  hidden: { x: '100%', opacity: 0 },
  show:   { x: 0, opacity: 1, transition: { type: 'spring' as const, stiffness: 280, damping: 28, mass: 0.9 } },
  exit:   { x: '100%', opacity: 0, transition: { duration: 0.22, ease: EASE_IN } },
};

const backdropVariants = {
  hidden: { opacity: 0 },
  show:   { opacity: 1, transition: { duration: 0.25, ease: EASE_OUT } },
  exit:   { opacity: 0, transition: { duration: 0.2,  ease: EASE_IN  } },
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

// ── Helpers ──────────────────────────────────────────────────────────────────

function getEventStatus(startDate: string | null, status?: string | null) {
  if (status === 'cancelled') return { label: 'Cancelled', variant: 'danger' as const };
  if (!startDate) return { label: 'Unknown', variant: 'default' as const };
  const now  = new Date();
  const date = new Date(startDate);
  if (date < now) return { label: 'Past', variant: 'default' as const };
  if (date.getTime() - now.getTime() < 86400000 * 3) return { label: 'Soon', variant: 'warning' as const };
  return { label: 'Upcoming', variant: 'success' as const };
}

// ── Main component ───────────────────────────────────────────────────────────

export default function EventsClient({ events: initialEvents }: { events: Event[] }) {
  const [events, setEvents] = useState(initialEvents);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<StatusFilter>('all');
  const [selectedEvent, setSelectedEvent] = useState<Event | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<Event | null>(null);
  const [isPending, startTransition] = useTransition();

  const filtered = useMemo(() => {
    return events.filter((e) => {
      const matchesSearch =
        e.title.toLowerCase().includes(search.toLowerCase()) ||
        (e.location?.toLowerCase() ?? '').includes(search.toLowerCase()) ||
        (e.organizer?.name?.toLowerCase() ?? '').includes(search.toLowerCase());
      if (!matchesSearch) return false;
      if (statusFilter === 'all') return true;
      const s = getEventStatus(e.start_date, e.status);
      if (statusFilter === 'cancelled') return s.label === 'Cancelled';
      if (statusFilter === 'past')      return s.label === 'Past';
      if (statusFilter === 'upcoming')  return s.label === 'Upcoming' || s.label === 'Soon';
      return true;
    });
  }, [events, search, statusFilter]);

  function handleDelete(event: Event) {
    startTransition(async () => {
      const res = await deleteEvent(event.id);
      if (res.success) {
        setEvents((prev) => prev.filter((e) => e.id !== event.id));
        setDeleteTarget(null);
        setSelectedEvent(null);
      } else {
        alert('Failed to delete event: ' + res.error);
      }
    });
  }

  function handleStatusChange(eventId: string, newStatus: string) {
    startTransition(async () => {
      const res = await updateEventStatus(eventId, newStatus);
      if (res.success) {
        setEvents((prev) => prev.map((e) => (e.id === eventId ? { ...e, status: newStatus } : e)));
        if (selectedEvent?.id === eventId)
          setSelectedEvent((prev) => prev ? { ...prev, status: newStatus } : null);
      } else {
        alert('Failed to update status: ' + res.error);
      }
    });
  }

  const filterButtons: { key: StatusFilter; label: string }[] = [
    { key: 'all',       label: `All (${events.length})` },
    { key: 'upcoming',  label: 'Upcoming' },
    { key: 'past',      label: 'Past' },
    { key: 'cancelled', label: 'Cancelled' },
  ];

  const display = selectedEvent;

  return (
    <>
      {/* Filters */}
      <div className="mb-4 flex flex-wrap items-center gap-3">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
          <input
            type="text"
            placeholder="Search events…"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-64 rounded-xl border border-gray-200 bg-white py-2 pl-9 pr-4 text-sm text-gray-700 outline-none focus:border-[#0B1629] focus:ring-1 focus:ring-[#0B1629]"
          />
        </div>
        <div className="flex gap-1 rounded-xl border border-gray-200 bg-white p-1">
          {filterButtons.map((btn) => (
            <button
              key={btn.key}
              onClick={() => setStatusFilter(btn.key)}
              className={`rounded-lg px-3 py-1.5 text-xs font-medium transition-colors ${statusFilter === btn.key ? 'bg-[#0B1629] text-white' : 'text-gray-500 hover:text-gray-700'}`}
            >
              {btn.label}
            </button>
          ))}
        </div>
      </div>

      {/* Card Grid */}
      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
        {filtered.length === 0 && (
          <p className="col-span-3 py-16 text-center text-sm text-gray-400">No events found</p>
        )}
        {filtered.map((e) => {
          const status    = getEventStatus(e.start_date, e.status);
          const attendees = e.rsvp_count ?? 0;
          const max       = e.max_attendees;
          const fillPct   = max ? Math.min((attendees / max) * 100, 100) : 0;

          return (
            <motion.div
              key={e.id}
              className="rounded-2xl border border-gray-100 bg-white p-5 shadow-sm hover:shadow-md transition-shadow"
              whileHover={{ y: -2 }}
              transition={{ duration: 0.2 }}
            >
              <div className="mb-3 flex items-start justify-between gap-2">
                <h3 className="font-semibold text-gray-900 leading-snug">{e.title}</h3>
                <Badge variant={status.variant}>{status.label}</Badge>
              </div>

              {e.description && (
                <p className="mb-3 text-xs text-gray-500 line-clamp-2">{e.description}</p>
              )}

              <div className="space-y-2 text-xs text-gray-500">
                <div className="flex items-center gap-1.5">
                  <Calendar className="h-3.5 w-3.5 flex-shrink-0 text-[#0B1629]/50" />
                  {e.start_date ? formatDateTime(e.start_date) : '—'}
                </div>
                {e.location && (
                  <div className="flex items-center gap-1.5">
                    <MapPin className="h-3.5 w-3.5 flex-shrink-0 text-[#0B1629]/50" />
                    {e.location}
                  </div>
                )}
                <div className="flex items-center gap-1.5">
                  <Users className="h-3.5 w-3.5 flex-shrink-0 text-[#0B1629]/50" />
                  {attendees}{max ? ` / ${max}` : ''} attendees
                </div>
              </div>

              {max ? (
                <div className="mt-3">
                  <div className="h-1.5 w-full overflow-hidden rounded-full bg-gray-100">
                    <div className="h-full rounded-full bg-[#0B1629] transition-all" style={{ width: `${fillPct}%` }} />
                  </div>
                  <p className="mt-1 text-right text-[10px] text-gray-400">{Math.round(fillPct)}% full</p>
                </div>
              ) : null}

              <div className="mt-3 border-t border-gray-100 pt-3 flex items-center justify-between">
                <p className="text-[11px] text-gray-400">
                  <span className="font-medium text-gray-600">{e.organizer?.name || e.organizer?.email || 'Unknown'}</span>
                </p>
                <div className="flex gap-1">
                  <motion.button
                    type="button"
                    onClick={() => setSelectedEvent(e)}
                    className="rounded-lg p-1.5 text-gray-400 hover:bg-[#0B1629]/5 hover:text-[#0B1629] transition-colors"
                    title="View details"
                    whileHover={{ scale: 1.08, y: -1 }}
                    whileTap={{ scale: 0.96 }}
                  >
                    <Eye className="h-4 w-4" />
                  </motion.button>
                  <motion.button
                    type="button"
                    onClick={() => setDeleteTarget(e)}
                    className="rounded-lg p-1.5 text-gray-400 hover:bg-red-50 hover:text-red-500 transition-colors"
                    title="Delete event"
                    whileHover={{ x: [0, -1.5, 1.5, -1, 1, 0] }}
                    whileTap={{ scale: 0.95 }}
                    transition={{ duration: 0.35 }}
                  >
                    <Trash2 className="h-4 w-4" />
                  </motion.button>
                </div>
              </div>
            </motion.div>
          );
        })}
      </div>

      {/* ── Right-side Detail Drawer ── */}
      <AnimatePresence>
        {display && (
          <motion.div className="fixed inset-0 z-50 flex justify-end">
            {/* Backdrop */}
            <motion.div
              className="absolute inset-0 bg-black/40 backdrop-blur-[2px]"
              onClick={() => setSelectedEvent(null)}
              variants={backdropVariants}
              initial="hidden"
              animate="show"
              exit="exit"
            />

            {/* Drawer panel */}
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
                {/* Shimmer */}
                <motion.div
                  className="pointer-events-none absolute inset-0 skew-x-[-20deg] bg-white/5"
                  animate={{ x: ['-120%', '220%'] }}
                  transition={{ duration: 4, repeat: Infinity, ease: 'easeInOut', repeatDelay: 3 }}
                />
                <div className="pointer-events-none absolute -right-8 -top-8 h-40 w-40 rounded-full bg-white/5" />

                <button
                  type="button"
                  onClick={() => setSelectedEvent(null)}
                  className="absolute right-4 top-4 rounded-xl p-2 text-white/60 transition hover:bg-white/10 hover:text-white"
                  aria-label="Close"
                >
                  <X className="h-5 w-5" />
                </button>

                <div className="relative flex items-start gap-4">
                  <div className="flex h-14 w-14 flex-shrink-0 items-center justify-center rounded-2xl bg-white/15 text-white shadow-lg ring-2 ring-white/20">
                    <Calendar className="h-7 w-7 opacity-90" />
                  </div>
                  <div className="min-w-0 flex-1 pr-8">
                    <p className="text-lg font-black leading-tight text-white line-clamp-2">{display.title}</p>
                    <p className="mt-0.5 text-sm text-white/55 truncate">
                      {display.organizer?.name || display.organizer?.email || 'Unknown organizer'}
                    </p>
                    <div className="mt-2 flex flex-wrap items-center gap-2">
                      <span className={`inline-flex items-center rounded-full bg-white/15 px-2.5 py-0.5 text-[11px] font-semibold text-white ring-1 ring-white/20`}>
                        {getEventStatus(display.start_date, display.status).label}
                      </span>
                      {display.event_type && (
                        <span className="inline-flex items-center rounded-full bg-white/15 px-2.5 py-0.5 text-[11px] font-semibold capitalize text-white ring-1 ring-white/20">
                          {display.event_type}
                        </span>
                      )}
                      <span className="inline-flex items-center gap-1 rounded-full bg-white/15 px-2.5 py-0.5 text-[11px] font-semibold text-white ring-1 ring-white/20">
                        <Users className="h-3 w-3" />
                        {display.rsvp_count ?? 0}{display.max_attendees ? ` / ${display.max_attendees}` : ''}
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

                  {/* Description */}
                  {display.description && (
                    <motion.div
                      className="rounded-2xl border border-[#0B1629]/10 bg-[#0B1629]/5 p-4"
                      style={{ borderLeft: '3px solid #0B1629' }}
                      variants={drawerItemVariants}
                    >
                      <p className="mb-1 text-[11px] font-bold uppercase tracking-widest text-[#0B1629]/70">Description</p>
                      <p className="text-sm text-gray-700 whitespace-pre-wrap leading-relaxed">{display.description}</p>
                    </motion.div>
                  )}

                  {/* Event details */}
                  <motion.section
                    className="overflow-hidden rounded-2xl border border-[#0B1629]/10 bg-[#0B1629]/5 p-4 shadow-sm"
                    style={{ borderLeft: '3px solid #0B1629' }}
                    variants={drawerItemVariants}
                  >
                    <div className="mb-3 flex items-center gap-2">
                      <div className="flex h-6 w-6 items-center justify-center rounded-lg bg-[#0B1629]/10">
                        <Calendar className="h-3.5 w-3.5 text-[#0B1629]" />
                      </div>
                      <h3 className="text-[11px] font-bold uppercase tracking-widest text-[#0B1629]/70">Event Details</h3>
                    </div>
                    <div className="grid grid-cols-2 gap-x-6 gap-y-3">
                      <div>
                        <p className="text-[11px] font-semibold uppercase tracking-widest text-gray-400">Start</p>
                        <p className="mt-0.5 text-sm font-semibold text-gray-800">{display.start_date ? formatDateTime(display.start_date) : '—'}</p>
                      </div>
                      <div>
                        <p className="text-[11px] font-semibold uppercase tracking-widest text-gray-400">End</p>
                        <p className="mt-0.5 text-sm font-semibold text-gray-800">{display.end_date ? formatDateTime(display.end_date) : '—'}</p>
                      </div>
                      <div>
                        <p className="text-[11px] font-semibold uppercase tracking-widest text-gray-400">Location</p>
                        <p className="mt-0.5 text-sm font-semibold text-gray-800">{display.location || '—'}</p>
                      </div>
                      <div>
                        <p className="text-[11px] font-semibold uppercase tracking-widest text-gray-400">Capacity</p>
                        <p className="mt-0.5 text-sm font-semibold text-gray-800">
                          {display.max_attendees ? `${display.rsvp_count ?? 0} / ${display.max_attendees}` : `${display.rsvp_count ?? 0} attending`}
                        </p>
                      </div>
                    </div>
                    {display.max_attendees ? (
                      <div className="mt-4">
                        <div className="h-1.5 w-full overflow-hidden rounded-full bg-gray-200">
                          <div
                            className="h-full rounded-full bg-[#0B1629] transition-all"
                            style={{ width: `${Math.min(((display.rsvp_count ?? 0) / display.max_attendees) * 100, 100)}%` }}
                          />
                        </div>
                        <p className="mt-1 text-right text-[10px] text-gray-400">
                          {Math.round(((display.rsvp_count ?? 0) / display.max_attendees) * 100)}% full
                        </p>
                      </div>
                    ) : null}
                  </motion.section>

                  {/* Organizer */}
                  <motion.section
                    className="overflow-hidden rounded-2xl border border-[#0B1629]/10 bg-[#0B1629]/5 p-4 shadow-sm"
                    style={{ borderLeft: '3px solid #0B1629' }}
                    variants={drawerItemVariants}
                  >
                    <div className="mb-3 flex items-center gap-2">
                      <div className="flex h-6 w-6 items-center justify-center rounded-lg bg-[#0B1629]/10">
                        <User className="h-3.5 w-3.5 text-[#0B1629]" />
                      </div>
                      <h3 className="text-[11px] font-bold uppercase tracking-widest text-[#0B1629]/70">Organizer</h3>
                    </div>
                    <div className="flex items-center gap-3 rounded-xl bg-white/70 px-4 py-3 shadow-sm">
                      <div
                        className="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-xl text-sm font-black text-white shadow-sm"
                        style={{ background: 'linear-gradient(135deg, #0B1629, #1a3a38)' }}
                      >
                        {(display.organizer?.name || display.organizer?.email || '?')[0].toUpperCase()}
                      </div>
                      <div className="min-w-0">
                        <p className="font-bold text-gray-900 text-sm truncate">{display.organizer?.name || 'Unknown'}</p>
                        <p className="text-xs text-gray-400 truncate">{display.organizer?.email || '—'}</p>
                      </div>
                    </div>
                  </motion.section>

                  {/* RSVPs */}
                  {display.rsvps.length > 0 && (
                    <motion.section variants={drawerItemVariants}>
                      <p className="mb-2 text-[11px] font-bold uppercase tracking-widest text-[#0B1629]/70">
                        RSVPs ({display.rsvps.length})
                      </p>
                      <div className="space-y-2">
                        {display.rsvps.map((r) => (
                          <div key={r.id} className="flex items-center justify-between rounded-xl border border-gray-100 bg-gray-50 px-3 py-2 text-xs">
                            <span className="font-medium text-gray-700">{r.user_name}</span>
                            <div className="flex items-center gap-2">
                              <Badge variant={r.status === 'confirmed' ? 'success' : r.status === 'cancelled' ? 'danger' : 'default'}>
                                {r.status}
                              </Badge>
                              <span className="text-gray-400">{timeAgo(r.created_at)}</span>
                            </div>
                          </div>
                        ))}
                      </div>
                    </motion.section>
                  )}

                  {/* Change status */}
                  <motion.section variants={drawerItemVariants}>
                    <p className="mb-2 text-[11px] font-bold uppercase tracking-widest text-gray-400">Change Status</p>
                    <div className="flex flex-wrap gap-2">
                      {(['active', 'cancelled'] as const).map((s) => (
                        <button
                          key={s}
                          type="button"
                          disabled={isPending || display.status === s}
                          onClick={() => handleStatusChange(display.id, s)}
                          className={`rounded-lg px-3 py-1.5 text-xs font-medium capitalize transition-colors disabled:opacity-40 ${display.status === s ? 'bg-[#0B1629] text-white' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'}`}
                        >
                          {s}
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
                  onClick={() => setSelectedEvent(null)}
                  className="rounded-xl border border-gray-200 bg-white px-5 py-2.5 text-sm font-medium text-gray-600 transition hover:bg-gray-100"
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.97 }}
                >
                  Close
                </motion.button>
                <div className="flex flex-wrap items-center gap-2">
                  <motion.button
                    type="button"
                    disabled
                    title="Edit coming soon"
                    className="flex items-center gap-2 rounded-xl bg-[#0B1629] px-5 py-2.5 text-sm font-semibold text-white opacity-50 shadow-sm"
                    whileHover={{ scale: 1.02 }}
                    whileTap={{ scale: 0.97 }}
                  >
                    <Edit className="h-4 w-4" />
                    Edit
                  </motion.button>
                  <motion.button
                    type="button"
                    onClick={() => { setSelectedEvent(null); setDeleteTarget(display); }}
                    className="flex items-center gap-2 rounded-xl bg-red-500 px-5 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-red-600"
                    whileHover={{ scale: 1.02, x: [0, -2, 2, -1, 1, 0] }}
                    whileTap={{ scale: 0.97 }}
                    transition={{ duration: 0.35 }}
                  >
                    <Trash2 className="h-4 w-4" />
                    Delete
                  </motion.button>
                </div>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* ── Delete Modal ── */}
      <DeleteEventModal
        event={deleteTarget}
        open={!!deleteTarget}
        isPending={isPending}
        onCancel={() => !isPending && setDeleteTarget(null)}
        onConfirm={() => deleteTarget && handleDelete(deleteTarget)}
      />
    </>
  );
}

// ── Animated delete confirmation ─────────────────────────────────────────────

function DeleteEventModal({
  event,
  open,
  isPending,
  onCancel,
  onConfirm,
}: {
  event: Event | null;
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
      {open && event && (
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
                  <h3 className="text-lg font-semibold text-gray-900">Delete event?</h3>
                  <p className="mt-1 text-sm text-gray-500">
                    Permanently delete <strong>{event.title}</strong> and all RSVPs? This cannot be undone.
                  </p>
                </div>
              </motion.div>

              <motion.div
                className="mt-4 flex items-center gap-3 rounded-2xl border border-red-100 bg-red-50/40 p-3"
                variants={deleteItemVariants}
              >
                <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-white text-[#0B1629] ring-1 ring-red-100">
                  <Calendar className="h-5 w-5" />
                </div>
                <div className="min-w-0">
                  <p className="truncate text-sm font-semibold text-gray-900">{event.title}</p>
                  <p className="truncate text-xs text-gray-500">
                    {event.start_date ? formatDateTime(event.start_date) : '—'} · {event.rsvp_count ?? 0} RSVPs
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
