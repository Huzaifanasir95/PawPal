'use client';

import { useState, useMemo, useTransition, useEffect } from 'react';
import { AnimatePresence, motion, useAnimation } from 'framer-motion';
import { Search, Trash2, Eye, X, AlertTriangle, User, MapPin, Phone, Mail, Heart } from 'lucide-react';
import { timeAgo, formatDateTime } from '@/lib/utils';
import Badge from '@/components/Badge';
import { deleteAdoption, updateAdoptionStatus } from '@/lib/admin-actions';

const STATUS_OPTIONS = ['available', 'pending', 'adopted', 'cancelled'] as const;
const statusMap: Record<string, { label: string; variant: 'success' | 'warning' | 'default' | 'danger' }> = {
  available: { label: 'Available', variant: 'success' },
  pending:   { label: 'Pending',   variant: 'warning' },
  adopted:   { label: 'Adopted',   variant: 'default' },
  cancelled: { label: 'Cancelled', variant: 'danger'  },
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
  lister: { name: string | null; email: string | null; avatar_url: string | null } | null;
}

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

const fadeUp = { hidden: { opacity: 0, y: 12 }, show: { opacity: 1, y: 0 } };

const rowVariants = {
  hidden: { opacity: 0, y: 6 },
  show: (i: number) => ({
    opacity: 1,
    y: 0,
    transition: { duration: 0.22, ease: EASE_OUT, delay: i * 0.03 },
  }),
};

// ── Main component ───────────────────────────────────────────────────────────

export default function AdoptionsClient({ adoptions: initialAdoptions }: { adoptions: Adoption[] }) {
  const [adoptions, setAdoptions] = useState(initialAdoptions);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [selectedAdoption, setSelectedAdoption] = useState<Adoption | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<Adoption | null>(null);
  const [isPending, startTransition] = useTransition();

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

  const counts = useMemo(() => {
    const c: Record<string, number> = { all: adoptions.length };
    STATUS_OPTIONS.forEach((s) => { c[s] = adoptions.filter((a) => a.status === s).length; });
    return c;
  }, [adoptions]);

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
        if (selectedAdoption?.id === id)
          setSelectedAdoption((prev) => prev ? { ...prev, status: newStatus } : null);
      } else {
        alert('Failed to update status: ' + res.error);
      }
    });
  }

  const display = selectedAdoption;

  return (
    <>
      {/* Filters */}
      <motion.div
        className="mb-4 flex flex-wrap items-center gap-3"
        initial="hidden" animate="show" variants={fadeUp}
        transition={{ duration: 0.35, ease: EASE_OUT }}
      >
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
          <input
            type="text"
            placeholder="Search adoptions…"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-64 rounded-xl border border-gray-200 bg-white py-2 pl-9 pr-4 text-sm text-gray-700 outline-none focus:border-[#0B1629] focus:ring-1 focus:ring-[#0B1629]"
          />
        </div>
        <div className="flex gap-1 rounded-xl border border-gray-200 bg-white p-1">
          {['all', ...STATUS_OPTIONS].map((s) => (
            <button
              key={s}
              onClick={() => setStatusFilter(s)}
              className={`rounded-lg px-3 py-1.5 text-xs font-medium capitalize transition-colors ${statusFilter === s ? 'bg-[#0B1629] text-white' : 'text-gray-500 hover:text-gray-700'}`}
            >
              {s} ({counts[s] ?? 0})
            </button>
          ))}
        </div>
      </motion.div>

      {/* Table */}
      <motion.div
        className="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm"
        initial="hidden" animate="show" variants={fadeUp}
        transition={{ duration: 0.35, ease: EASE_OUT, delay: 0.06 }}
      >
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-100 bg-[#0B1629]">
                {['Pet', 'Type / Breed', 'Location', 'Listed By', 'Status', 'Listed', 'Actions'].map((h) => (
                  <th key={h} className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-widest text-white">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr><td colSpan={7} className="py-16 text-center text-sm text-gray-400">No listings found</td></tr>
              ) : (
                filtered.map((a, i) => {
                  const si = statusMap[a.status] ?? { label: a.status, variant: 'default' as const };
                  return (
                    <motion.tr
                      key={a.id}
                      custom={i}
                      variants={rowVariants}
                      initial="hidden"
                      animate="show"
                      className="border-b border-gray-50 last:border-0 hover:bg-[#0B1629]/5 transition-colors"
                    >
                      <td className="px-4 py-3">
                        <p className="font-medium text-gray-800">{a.pet_name}</p>
                        <p className="text-xs text-gray-400">
                          {a.age ?? '?'} yr{Number(a.age) !== 1 ? 's' : ''}{a.gender ? ` · ${a.gender}` : ''}{a.size ? ` · ${a.size}` : ''}
                        </p>
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
                          <motion.button
                            type="button"
                            onClick={() => setSelectedAdoption(a)}
                            className="rounded-lg p-1.5 text-gray-400 hover:bg-[#0B1629]/5 hover:text-[#0B1629] transition-colors"
                            title="View"
                            whileHover={{ scale: 1.08, y: -1 }}
                            whileTap={{ scale: 0.96 }}
                          >
                            <Eye className="h-4 w-4" />
                          </motion.button>
                          <motion.button
                            type="button"
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
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </motion.div>

      {/* ── Right-side Detail Drawer ── */}
      <AnimatePresence>
        {display && (
          <motion.div className="fixed inset-0 z-50 flex justify-end">
            {/* Backdrop */}
            <motion.div
              className="absolute inset-0 bg-black/40 backdrop-blur-[2px]"
              onClick={() => setSelectedAdoption(null)}
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
                <motion.div
                  className="pointer-events-none absolute inset-0 skew-x-[-20deg] bg-white/5"
                  animate={{ x: ['-120%', '220%'] }}
                  transition={{ duration: 4, repeat: Infinity, ease: 'easeInOut', repeatDelay: 3 }}
                />
                <div className="pointer-events-none absolute -right-8 -top-8 h-40 w-40 rounded-full bg-white/5" />

                <button
                  type="button"
                  onClick={() => setSelectedAdoption(null)}
                  className="absolute right-4 top-4 rounded-xl p-2 text-white/60 transition hover:bg-white/10 hover:text-white"
                  aria-label="Close"
                >
                  <X className="h-5 w-5" />
                </button>

                <div className="relative flex items-start gap-4">
                  {/* Pet avatar */}
                  <div className="relative flex-shrink-0">
                    {display.image_urls?.[0] ? (
                      <img
                        src={display.image_urls[0]}
                        alt={display.pet_name}
                        className="h-14 w-14 rounded-2xl object-cover ring-2 ring-white/30 shadow-lg"
                      />
                    ) : (
                      <div
                        className="flex h-14 w-14 items-center justify-center rounded-2xl text-2xl ring-2 ring-white/30 shadow-lg"
                        style={{ background: 'linear-gradient(135deg, #1a4a45, #3d8f89)' }}
                      >
                        {display.pet_type === 'cat' ? '🐈' : display.pet_type === 'bird' ? '🦜' : '🐕'}
                      </div>
                    )}
                  </div>
                  <div className="min-w-0 flex-1 pr-8">
                    <p className="text-lg font-black leading-tight text-white truncate">{display.pet_name}</p>
                    <p className="mt-0.5 text-sm text-white/55 capitalize truncate">
                      {display.pet_type || ''}{display.breed ? ` · ${display.breed}` : ''}
                    </p>
                    <div className="mt-2 flex flex-wrap items-center gap-2">
                      <span className="inline-flex items-center rounded-full bg-white/15 px-2.5 py-0.5 text-[11px] font-semibold text-white ring-1 ring-white/20 capitalize">
                        {statusMap[display.status]?.label ?? display.status}
                      </span>
                      {display.adoption_fee != null && (
                        <span className="inline-flex items-center rounded-full bg-white/15 px-2.5 py-0.5 text-[11px] font-semibold text-white ring-1 ring-white/20">
                          ${display.adoption_fee} fee
                        </span>
                      )}
                      {display.size && (
                        <span className="inline-flex items-center rounded-full bg-white/15 px-2.5 py-0.5 text-[11px] font-semibold capitalize text-white ring-1 ring-white/20">
                          {display.size}
                        </span>
                      )}
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

                  {/* Photos */}
                  {display.image_urls && display.image_urls.length > 0 && (
                    <motion.section variants={drawerItemVariants}>
                      <p className="mb-2 text-[11px] font-bold uppercase tracking-widest text-[#0B1629]/70">Photos</p>
                      <div className={`grid gap-2 ${display.image_urls.length === 1 ? 'grid-cols-1' : 'grid-cols-2'}`}>
                        {display.image_urls.map((url, i) => (
                          <motion.div
                            key={i}
                            className="overflow-hidden rounded-xl shadow-sm"
                            whileHover={{ scale: 1.02 }}
                          >
                            <img src={url} alt={`${display.pet_name} ${i + 1}`} className="h-32 w-full object-cover" />
                          </motion.div>
                        ))}
                      </div>
                    </motion.section>
                  )}

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

                  {/* Pet details */}
                  <motion.section
                    className="overflow-hidden rounded-2xl border border-[#0B1629]/10 bg-[#0B1629]/5 p-4 shadow-sm"
                    style={{ borderLeft: '3px solid #0B1629' }}
                    variants={drawerItemVariants}
                  >
                    <div className="mb-3 flex items-center gap-2">
                      <div className="flex h-6 w-6 items-center justify-center rounded-lg bg-[#0B1629]/10">
                        <Heart className="h-3.5 w-3.5 text-[#0B1629]" />
                      </div>
                      <h3 className="text-[11px] font-bold uppercase tracking-widest text-[#0B1629]/70">Pet Details</h3>
                    </div>
                    <div className="grid grid-cols-2 gap-x-6 gap-y-3">
                      {[
                        { label: 'Breed',  value: display.breed   || '—' },
                        { label: 'Age',    value: display.age != null ? `${display.age} years` : '—' },
                        { label: 'Gender', value: display.gender  || '—' },
                        { label: 'Size',   value: display.size    || '—' },
                        { label: 'Fee',    value: display.adoption_fee != null ? `$${display.adoption_fee}` : 'Free' },
                        { label: 'Type',   value: display.pet_type || '—' },
                      ].map(({ label, value }) => (
                        <div key={label}>
                          <p className="text-[11px] font-semibold uppercase tracking-widest text-gray-400">{label}</p>
                          <p className="mt-0.5 text-sm font-semibold capitalize text-gray-800">{value}</p>
                        </div>
                      ))}
                    </div>
                  </motion.section>

                  {/* Location + Contact */}
                  <motion.section
                    className="overflow-hidden rounded-2xl border border-[#0B1629]/10 bg-[#0B1629]/5 p-4 shadow-sm"
                    style={{ borderLeft: '3px solid #0B1629' }}
                    variants={drawerItemVariants}
                  >
                    <div className="mb-3 flex items-center gap-2">
                      <div className="flex h-6 w-6 items-center justify-center rounded-lg bg-[#0B1629]/10">
                        <MapPin className="h-3.5 w-3.5 text-[#0B1629]" />
                      </div>
                      <h3 className="text-[11px] font-bold uppercase tracking-widest text-[#0B1629]/70">Location &amp; Contact</h3>
                    </div>
                    <div className="space-y-2">
                      {display.location && (
                        <div className="flex items-center gap-2 rounded-lg bg-white/60 px-3 py-2 text-sm text-gray-700">
                          <MapPin className="h-3.5 w-3.5 text-gray-400 flex-shrink-0" />
                          {display.location}
                        </div>
                      )}
                      {display.contact_phone && (
                        <div className="flex items-center gap-2 rounded-lg bg-white/60 px-3 py-2 text-sm text-gray-700">
                          <Phone className="h-3.5 w-3.5 text-gray-400 flex-shrink-0" />
                          {display.contact_phone}
                        </div>
                      )}
                      {display.contact_email && (
                        <div className="flex items-center gap-2 rounded-lg bg-white/60 px-3 py-2 text-sm text-gray-700">
                          <Mail className="h-3.5 w-3.5 text-gray-400 flex-shrink-0" />
                          {display.contact_email}
                        </div>
                      )}
                    </div>
                  </motion.section>

                  {/* Lister */}
                  <motion.section
                    className="overflow-hidden rounded-2xl border border-[#0B1629]/10 bg-[#0B1629]/5 p-4 shadow-sm"
                    style={{ borderLeft: '3px solid #0B1629' }}
                    variants={drawerItemVariants}
                  >
                    <div className="mb-3 flex items-center gap-2">
                      <div className="flex h-6 w-6 items-center justify-center rounded-lg bg-[#0B1629]/10">
                        <User className="h-3.5 w-3.5 text-[#0B1629]" />
                      </div>
                      <h3 className="text-[11px] font-bold uppercase tracking-widest text-[#0B1629]/70">Listed By</h3>
                    </div>
                    <div className="flex items-center gap-3 rounded-xl bg-white/70 px-4 py-3 shadow-sm">
                      {display.lister?.avatar_url ? (
                        <img
                          src={display.lister.avatar_url}
                          alt={display.lister.name || ''}
                          className="h-10 w-10 flex-shrink-0 rounded-xl object-cover shadow-sm"
                        />
                      ) : (
                        <div
                          className="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-xl text-sm font-black text-white shadow-sm"
                          style={{ background: 'linear-gradient(135deg, #0B1629, #1a3a38)' }}
                        >
                          {(display.lister?.name || display.lister?.email || '?')[0].toUpperCase()}
                        </div>
                      )}
                      <div className="min-w-0">
                        <p className="font-bold text-gray-900 text-sm truncate">{display.lister?.name || 'Unknown'}</p>
                        <p className="text-xs text-gray-400 truncate">{display.lister?.email || '—'}</p>
                      </div>
                    </div>
                    <p className="mt-2 text-xs text-gray-400 px-1">Listed {formatDateTime(display.created_at)}</p>
                  </motion.section>

                  {/* Change status */}
                  <motion.section variants={drawerItemVariants}>
                    <p className="mb-2 text-[11px] font-bold uppercase tracking-widest text-gray-400">Change Status</p>
                    <div className="flex flex-wrap gap-2">
                      {STATUS_OPTIONS.map((s) => (
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

                  <p className="text-xs text-gray-300">ID: {display.id}</p>
                </div>
              </motion.div>

              {/* Sticky footer */}
              <div className="flex-shrink-0 flex flex-wrap items-center justify-between gap-3 border-t border-gray-100 bg-gray-50/80 px-6 py-4">
                <motion.button
                  type="button"
                  onClick={() => setSelectedAdoption(null)}
                  className="rounded-xl border border-gray-200 bg-white px-5 py-2.5 text-sm font-medium text-gray-600 transition hover:bg-gray-100"
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.97 }}
                >
                  Close
                </motion.button>
                <motion.button
                  type="button"
                  onClick={() => { setSelectedAdoption(null); setDeleteTarget(display); }}
                  className="flex items-center gap-2 rounded-xl bg-red-500 px-5 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-red-600"
                  whileHover={{ scale: 1.02, x: [0, -2, 2, -1, 1, 0] }}
                  whileTap={{ scale: 0.97 }}
                  transition={{ duration: 0.35 }}
                >
                  <Trash2 className="h-4 w-4" />
                  Delete
                </motion.button>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* ── Delete Modal ── */}
      <DeleteAdoptionModal
        adoption={deleteTarget}
        open={!!deleteTarget}
        isPending={isPending}
        onCancel={() => !isPending && setDeleteTarget(null)}
        onConfirm={() => deleteTarget && handleDelete(deleteTarget)}
      />
    </>
  );
}

// ── Animated delete confirmation ─────────────────────────────────────────────

function DeleteAdoptionModal({
  adoption,
  open,
  isPending,
  onCancel,
  onConfirm,
}: {
  adoption: Adoption | null;
  open: boolean;
  isPending: boolean;
  onCancel: () => void;
  onConfirm: () => void;
}) {
  const warningControls = useAnimation();
  const avatarUrl = adoption?.image_urls?.[0] ?? null;

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
      {open && adoption && (
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
                  <h3 className="text-lg font-semibold text-gray-900">Delete listing?</h3>
                  <p className="mt-1 text-sm text-gray-500">
                    Permanently delete the listing for <strong>{adoption.pet_name}</strong>? This cannot be undone.
                  </p>
                </div>
              </motion.div>

              <motion.div
                className="mt-4 flex items-center gap-3 rounded-2xl border border-red-100 bg-red-50/40 p-3"
                variants={deleteItemVariants}
              >
                {avatarUrl ? (
                  <img src={avatarUrl} alt="" className="h-10 w-10 rounded-xl object-cover" />
                ) : (
                  <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-white text-xl ring-1 ring-red-100">
                    {adoption.pet_type === 'cat' ? '🐈' : adoption.pet_type === 'bird' ? '🦜' : '🐕'}
                  </div>
                )}
                <div className="min-w-0">
                  <p className="truncate text-sm font-semibold text-gray-900">{adoption.pet_name}</p>
                  <p className="truncate text-xs text-gray-500 capitalize">
                    {adoption.pet_type || '—'}{adoption.breed ? ` · ${adoption.breed}` : ''}
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
