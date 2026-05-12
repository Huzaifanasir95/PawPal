'use client';

import { useState, useTransition, useEffect, type ReactNode } from 'react';
import { AnimatePresence, motion, useAnimation } from 'framer-motion';
import Badge from '@/components/Badge';
import {
  Search, Eye, Trash2, X, MapPin, Phone, Mail,
  AlertTriangle, PawPrint, User, Edit,
} from 'lucide-react';
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
  high:     { label: 'High',     variant: 'warning' },
  medium:   { label: 'Medium',   variant: 'default' },
  low:      { label: 'Low',      variant: 'default' },
};

const statusMap: Record<string, { label: string; variant: 'success' | 'warning' | 'default' }> = {
  open:     { label: 'Open',     variant: 'warning' },
  resolved: { label: 'Resolved', variant: 'success' },
  closed:   { label: 'Closed',   variant: 'default' },
};

// ── Animation constants ──────────────────────────────────────────────────────

const EASE_OUT = [0.16, 1, 0.3, 1] as const;
const EASE_IN  = [0.7, 0, 0.84, 0] as const;

const backdropVariants = {
  hidden: { opacity: 0 },
  show:   { opacity: 1, transition: { duration: 0.25, ease: EASE_OUT } },
  exit:   { opacity: 0, transition: { duration: 0.2,  ease: EASE_IN  } },
};

const modalVariants = {
  hidden: { opacity: 0, scale: 0.82, y: 26, rotateX: -12, rotateZ: -1 },
  show: {
    opacity: 1, scale: 1, y: 0, rotateX: 0, rotateZ: 0,
    transition: { type: 'spring' as const, stiffness: 260, damping: 22, mass: 0.8 },
  },
  exit: { opacity: 0, scale: 0.9, y: 18, rotateX: 6, rotateZ: 1, transition: { duration: 0.2 } },
};

const modalContentVariants = {
  show: { transition: { staggerChildren: 0.08, delayChildren: 0.05 } },
};

const modalItemVariants = {
  hidden: { opacity: 0, y: 10 },
  show:   { opacity: 1, y: 0, transition: { duration: 0.25, ease: EASE_OUT } },
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

// ── Helper ───────────────────────────────────────────────────────────────────

function LFField({ icon, label, value }: { icon: ReactNode; label: string; value: ReactNode }) {
  return (
    <div className="min-w-0">
      <div className="mb-1 flex items-center gap-1">
        <span className="text-[#2C6E69]/60">{icon}</span>
        <p className="text-[11px] font-semibold uppercase tracking-widest text-gray-400">{label}</p>
      </div>
      <div className="break-words text-sm font-semibold text-gray-800">{value || '—'}</div>
    </div>
  );
}

// ── Main component ───────────────────────────────────────────────────────────

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
    type:   { all: items.length, lost: items.filter((i) => i.type === 'lost').length, found: items.filter((i) => i.type === 'found').length },
    status: { all: items.length, open: items.filter((i) => i.status === 'open').length, resolved: items.filter((i) => i.status === 'resolved').length, closed: items.filter((i) => i.status === 'closed').length },
  };

  function handleStatusChange(id: string, status: string) {
    startTransition(async () => {
      const res = await updateLostFoundStatus(id, status);
      if (res.success) {
        setItems((prev) => prev.map((i) => (i.id === id ? { ...i, status } : i)));
        if (selectedItem?.id === id) setSelectedItem((p) => (p ? { ...p, status } : p));
      } else {
        alert('Failed to update status: ' + res.error);
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
      } else {
        alert('Failed to delete: ' + res.error);
      }
    });
  }

  const display = selectedItem;

  return (
    <div className="p-8">
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Lost &amp; Found</h1>
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
            className={`rounded-lg px-3 py-1.5 text-xs font-medium transition-colors ${typeFilter === t ? 'bg-[#2C6E69] text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}
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
            className={`rounded-lg px-3 py-1.5 text-xs font-medium transition-colors ${statusFilter === s ? 'bg-[#2C6E69] text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}
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
              <tr className="border-b border-gray-100 bg-[#0B1629]">
                {['Type', 'Pet', 'Last Seen', 'Reported By', 'Urgency', 'Status', 'Time', 'Actions'].map((h) => (
                  <th key={h} className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-widest text-white">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr><td colSpan={8} className="py-16 text-center text-sm text-gray-400">No reports found</td></tr>
              ) : (
                filtered.map((item) => {
                  const urgency = urgencyMap[item.urgency ?? ''] ?? { label: item.urgency || '—', variant: 'default' as const };
                  const status  = statusMap[item.status]          ?? { label: item.status  || '—', variant: 'default' as const };
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
                          <motion.button
                            type="button"
                            onClick={() => setSelectedItem(item)}
                            className="rounded-lg p-1.5 text-gray-400 hover:bg-gray-100 hover:text-[#0B1629] transition-colors"
                            title="View details"
                            whileHover={{ scale: 1.08, y: -1 }}
                            whileTap={{ scale: 0.96 }}
                          >
                            <Eye className="h-4 w-4" />
                          </motion.button>
                          <motion.button
                            type="button"
                            onClick={() => setDeleteTarget(item)}
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
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* ── Detail Modal ── */}
      <AnimatePresence>
        {display && (
          <motion.div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6">
            <motion.div
              className="absolute inset-0 bg-black/40 backdrop-blur-[3px]"
              onClick={() => setSelectedItem(null)}
              variants={backdropVariants}
              initial="hidden"
              animate="show"
              exit="exit"
            />
            <motion.div
              className="relative w-full max-w-xl overflow-hidden rounded-3xl bg-white shadow-2xl ring-1 ring-black/5"
              variants={modalVariants}
              initial="hidden"
              animate="show"
              exit="exit"
              style={{ transformOrigin: '50% 10%', transformPerspective: 1200 }}
            >
              {/* Gradient header */}
              <motion.div
                className="relative overflow-hidden px-6 pb-6 pt-7"
                style={{ background: 'linear-gradient(135deg, #0B1629 0%, #1a3a38 50%, #2C6E69 100%)' }}
                variants={modalItemVariants}
                initial="hidden"
                animate="show"
              >
                <motion.div
                  className="pointer-events-none absolute inset-0 skew-x-[-20deg] bg-white/5"
                  animate={{ x: ['-120%', '220%'] }}
                  transition={{ duration: 4, repeat: Infinity, ease: 'easeInOut', repeatDelay: 3 }}
                />
                <div className="pointer-events-none absolute -right-10 -top-10 h-48 w-48 rounded-full bg-white/5" />

                <button
                  type="button"
                  onClick={() => setSelectedItem(null)}
                  className="absolute right-4 top-4 rounded-xl p-2 text-white/60 transition hover:bg-white/10 hover:text-white"
                  aria-label="Close"
                >
                  <X className="h-5 w-5" />
                </button>

                <div className="relative flex items-start gap-5">
                  {/* Avatar / photo */}
                  <div className="relative flex-shrink-0">
                    {display.image_urls?.[0] ? (
                      <img
                        src={display.image_urls[0]}
                        alt={display.pet_name || 'Pet'}
                        className="h-16 w-16 rounded-2xl object-cover ring-2 ring-white/30 shadow-lg"
                      />
                    ) : (
                      <div
                        className="flex h-16 w-16 items-center justify-center rounded-2xl text-2xl ring-2 ring-white/30 shadow-lg"
                        style={{ background: 'linear-gradient(135deg, #1a4a45, #3d8f89)' }}
                      >
                        🐾
                      </div>
                    )}
                  </div>

                  <div className="min-w-0 flex-1 pr-8">
                    <p className="text-xl font-black text-white leading-tight truncate">
                      {display.pet_name || 'Unknown Pet'}
                    </p>
                    <p className="mt-0.5 text-sm text-white/55 capitalize truncate">
                      {display.pet_type || ''}{display.breed ? ` · ${display.breed}` : ''}
                    </p>
                    <div className="mt-2.5 flex flex-wrap items-center gap-2">
                      <Badge
                        variant={display.type === 'lost' ? 'danger' : 'success'}
                        className="border-0 bg-white/20 text-white ring-1 ring-white/25"
                      >
                        {display.type === 'lost' ? '🔍 Lost' : '📢 Found'}
                      </Badge>
                      {display.urgency && (
                        <Badge
                          variant={urgencyMap[display.urgency]?.variant ?? 'default'}
                          className="border-0 bg-white/20 text-white ring-1 ring-white/25"
                        >
                          {urgencyMap[display.urgency]?.label ?? display.urgency}
                        </Badge>
                      )}
                      <Badge
                        variant={statusMap[display.status]?.variant ?? 'default'}
                        className="border-0 bg-white/20 text-white ring-1 ring-white/25"
                      >
                        {statusMap[display.status]?.label ?? display.status}
                      </Badge>
                    </div>
                  </div>
                </div>
              </motion.div>

              {/* Scrollable body */}
              <motion.div
                className="max-h-[60vh] overflow-y-auto"
                variants={modalContentVariants}
                initial="hidden"
                animate="show"
              >
                <div className="space-y-4 p-6">

                  {/* Photos */}
                  {display.image_urls && display.image_urls.length > 0 && (
                    <motion.section variants={modalItemVariants}>
                      <p className="mb-2 text-[11px] font-bold uppercase tracking-widest text-[#2C6E69]">Photos</p>
                      <div className={`grid gap-2 ${display.image_urls.length === 1 ? 'grid-cols-1' : 'grid-cols-2'}`}>
                        {display.image_urls.map((url, i) => (
                          <motion.div
                            key={i}
                            className="overflow-hidden rounded-xl shadow-sm"
                            initial={{ opacity: 0, scale: 0.95 }}
                            animate={{ opacity: 1, scale: 1 }}
                            transition={{ duration: 0.3, delay: 0.1 + i * 0.07, ease: EASE_OUT }}
                            whileHover={{ scale: 1.02 }}
                          >
                            <img src={url} alt={`Photo ${i + 1}`} className="h-36 w-full object-cover" />
                          </motion.div>
                        ))}
                      </div>
                    </motion.section>
                  )}

                  {/* Description */}
                  {display.description && (
                    <motion.div
                      className="rounded-2xl border border-[#2C6E69]/15 bg-[#2C6E69]/5 p-4"
                      style={{ borderLeft: '3px solid #2C6E69' }}
                      variants={modalItemVariants}
                    >
                      <p className="mb-1 text-[11px] font-bold uppercase tracking-widest text-[#2C6E69]">Description</p>
                      <p className="text-sm text-gray-700 whitespace-pre-wrap leading-relaxed">{display.description}</p>
                    </motion.div>
                  )}

                  {/* Pet details */}
                  <motion.section
                    className="overflow-hidden rounded-2xl border border-[#2C6E69]/15 bg-[#2C6E69]/5 p-4 shadow-sm"
                    style={{ borderLeft: '3px solid #2C6E69' }}
                    variants={modalItemVariants}
                  >
                    <div className="mb-3 flex items-center gap-2">
                      <div className="flex h-6 w-6 items-center justify-center rounded-lg bg-[#2C6E69]/15">
                        <PawPrint className="h-3.5 w-3.5 text-[#2C6E69]" />
                      </div>
                      <h3 className="text-[11px] font-bold uppercase tracking-widest text-[#2C6E69]">Pet Details</h3>
                    </div>
                    <div className="grid grid-cols-2 gap-x-6 gap-y-3">
                      <LFField icon={<PawPrint className="h-3 w-3" />} label="Type" value={display.pet_type} />
                      <LFField icon={<PawPrint className="h-3 w-3" />} label="Breed" value={display.breed} />
                      <LFField icon={<MapPin className="h-3 w-3" />} label="Last Seen" value={display.last_seen_location} />
                      <LFField icon={<AlertTriangle className="h-3 w-3" />} label="Urgency" value={urgencyMap[display.urgency ?? '']?.label ?? display.urgency} />
                    </div>
                  </motion.section>

                  {/* Reporter */}
                  <motion.section
                    className="overflow-hidden rounded-2xl border border-[#2C6E69]/15 bg-[#2C6E69]/5 p-4 shadow-sm"
                    style={{ borderLeft: '3px solid #2C6E69' }}
                    variants={modalItemVariants}
                  >
                    <div className="mb-3 flex items-center gap-2">
                      <div className="flex h-6 w-6 items-center justify-center rounded-lg bg-[#2C6E69]/15">
                        <User className="h-3.5 w-3.5 text-[#2C6E69]" />
                      </div>
                      <h3 className="text-[11px] font-bold uppercase tracking-widest text-[#2C6E69]">Reporter &amp; Contact</h3>
                    </div>
                    <div className="flex items-center gap-3 rounded-xl bg-white/70 px-4 py-3 shadow-sm mb-3">
                      <div
                        className="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-xl text-sm font-black text-white shadow-sm"
                        style={{ background: 'linear-gradient(135deg, #1a3a38, #2C6E69)' }}
                      >
                        {(display.reporter?.name || display.reporter?.email || '?')[0].toUpperCase()}
                      </div>
                      <div className="min-w-0">
                        <p className="font-bold text-gray-900 text-sm truncate">{display.reporter?.name || 'Unknown'}</p>
                        <p className="text-xs text-gray-400 truncate">{display.reporter?.email || '—'}</p>
                      </div>
                    </div>
                    <div className="space-y-2">
                      {display.contact_phone && (
                        <div className="flex items-center gap-2 rounded-lg bg-white/60 px-3 py-2 text-sm text-gray-600">
                          <Phone className="h-3.5 w-3.5 text-gray-400" />
                          {display.contact_phone}
                        </div>
                      )}
                      {display.contact_email && (
                        <div className="flex items-center gap-2 rounded-lg bg-white/60 px-3 py-2 text-sm text-gray-600">
                          <Mail className="h-3.5 w-3.5 text-gray-400" />
                          {display.contact_email}
                        </div>
                      )}
                      {!display.contact_phone && !display.contact_email && (
                        <p className="text-sm text-gray-400 italic">No contact information provided</p>
                      )}
                    </div>
                  </motion.section>

                  {/* Change status */}
                  <motion.section variants={modalItemVariants}>
                    <p className="mb-2 text-[11px] font-bold uppercase tracking-widest text-gray-400">Change Status</p>
                    <div className="flex flex-wrap gap-2">
                      {(['open', 'resolved', 'closed'] as const).map((s) => (
                        <button
                          key={s}
                          type="button"
                          disabled={isPending || display.status === s}
                          onClick={() => handleStatusChange(display.id, s)}
                          className={`rounded-lg px-3 py-1.5 text-xs font-medium transition-colors disabled:opacity-40 ${display.status === s ? 'bg-[#2C6E69] text-white' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'}`}
                        >
                          {s.charAt(0).toUpperCase() + s.slice(1)}
                        </button>
                      ))}
                    </div>
                  </motion.section>

                  <p className="text-xs text-gray-300">ID: {display.id} · {formatDateTime(display.created_at)}</p>
                </div>
              </motion.div>

              {/* Footer */}
              <motion.div
                className="flex flex-wrap items-center justify-between gap-3 border-t border-gray-100 bg-gray-50/60 px-6 py-4"
                variants={modalItemVariants}
                initial="hidden"
                animate="show"
              >
                <motion.button
                  type="button"
                  onClick={() => setSelectedItem(null)}
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
                    className="flex items-center gap-2 rounded-xl bg-[#2C6E69] px-5 py-2.5 text-sm font-semibold text-white opacity-50 shadow-sm"
                    whileHover={{ scale: 1.02 }}
                    whileTap={{ scale: 0.97 }}
                  >
                    <Edit className="h-4 w-4" />
                    Edit
                  </motion.button>
                  <motion.button
                    type="button"
                    onClick={() => { setSelectedItem(null); setDeleteTarget(display); }}
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
          </motion.div>
        )}
      </AnimatePresence>

      {/* ── Delete Modal ── */}
      <DeleteLostFoundModal
        item={deleteTarget}
        open={!!deleteTarget}
        isPending={isPending}
        onCancel={() => !isPending && setDeleteTarget(null)}
        onConfirm={() => deleteTarget && handleDelete(deleteTarget.id)}
      />
    </div>
  );
}

// ── Animated delete confirmation ─────────────────────────────────────────────

function DeleteLostFoundModal({
  item,
  open,
  isPending,
  onCancel,
  onConfirm,
}: {
  item: LostFoundItem | null;
  open: boolean;
  isPending: boolean;
  onCancel: () => void;
  onConfirm: () => void;
}) {
  const warningControls = useAnimation();
  const avatarUrl = item?.image_urls?.[0] ?? null;

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
      {open && item && (
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
                  <h3 className="text-lg font-semibold text-gray-900">Delete report?</h3>
                  <p className="mt-1 text-sm text-gray-500">
                    Permanently delete the <strong>{item.type}</strong> report for{' '}
                    <strong>{item.pet_name || 'Unknown'}</strong>? This cannot be undone.
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
                    🐾
                  </div>
                )}
                <div className="min-w-0">
                  <p className="truncate text-sm font-semibold text-gray-900">{item.pet_name || 'Unknown'}</p>
                  <p className="truncate text-xs text-gray-500">
                    {item.type === 'lost' ? '🔍 Lost' : '📢 Found'}{item.breed ? ` · ${item.breed}` : ''}
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
