'use client';

import { useState, useMemo, useTransition, useEffect, type ReactNode } from 'react';
import { AnimatePresence, motion, useAnimation } from 'framer-motion';
import {
  Search,
  Eye,
  Trash2,
  X,
  CheckCircle,
  XCircle,
  Star,
  Shield,
  ShieldCheck,
  AlertTriangle,
  Check,
  Briefcase,
  User,
  MapPin,
  Calendar,
  Award,
  Heart,
  Home,
  Car,
  Users,
} from 'lucide-react';
import Badge from '@/components/Badge';
import { formatDateTime } from '@/lib/utils';
import { updateCaregiverVerification, deleteCaregiver } from '@/lib/admin-actions';

export interface Caregiver {
  id: string;
  user_id: string;
  bio: string | null;
  headline: string | null;
  years_of_experience: number | null;
  address: string | null;
  city: string | null;
  state: string | null;
  postal_code: string | null;
  country: string | null;
  service_radius_km: number | null;
  is_verified: boolean;
  verification_date: string | null;
  background_check_status: string | null;
  background_check_date: string | null;
  background_check_expiry: string | null;
  id_verified: boolean;
  pet_first_aid_certified: boolean;
  insurance_verified: boolean;
  insurance_policy_number: string | null;
  accepted_pet_types: string[] | null;
  accepted_pet_sizes: string[] | null;
  max_pets_at_once: number | null;
  has_fenced_yard: boolean;
  has_own_transport: boolean;
  smoke_free_home: boolean;
  average_rating: number;
  total_reviews: number;
  total_bookings: number;
  completion_rate: number;
  response_time_hours: number | null;
  is_active: boolean;
  is_accepting_bookings: boolean;
  created_at: string;
  updated_at: string;
  owner: { id: string; display_name: string | null; email: string | null; avatar_url: string | null } | null;
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

// ── Helpers ──────────────────────────────────────────────────────────────────

function CgField({ icon, label, value }: { icon: ReactNode; label: string; value: ReactNode }) {
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

function bgCheckVariant(status: string | null): 'success' | 'warning' | 'danger' | 'default' {
  switch (status) {
    case 'approved': return 'success';
    case 'in_progress': return 'warning';
    case 'rejected':
    case 'expired': return 'danger';
    default: return 'default';
  }
}

function initials(name: string | null | undefined, email: string | null | undefined) {
  const s = (name || email || '?').trim();
  if (!s || s === '?') return '?';
  const parts = s.split(/\s+/);
  if (parts.length >= 2) return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  return s.slice(0, 2).toUpperCase();
}

// ── Main component ───────────────────────────────────────────────────────────

export default function CaregiversClient({ caregivers: initialCaregivers }: { caregivers: Caregiver[] }) {
  const [caregivers, setCaregivers] = useState(initialCaregivers);
  const [search, setSearch] = useState('');
  const [filter, setFilter] = useState<'all' | 'verified' | 'pending'>('all');
  const [selected, setSelected] = useState<Caregiver | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<Caregiver | null>(null);
  const [isPending, startTransition] = useTransition();
  const [modalApproving, setModalApproving] = useState(false);

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

  const counts = useMemo(
    () => ({
      all: caregivers.length,
      verified: caregivers.filter((c) => c.is_verified).length,
      pending: caregivers.filter((c) => !c.is_verified).length,
    }),
    [caregivers]
  );

  function syncPatch(id: string, patch: Partial<Caregiver>) {
    setCaregivers((prev) => prev.map((c) => (c.id === id ? { ...c, ...patch } : c)));
    setSelected((prev) => (prev && prev.id === id ? { ...prev, ...patch } : prev));
  }

  function handleToggleVerify(id: string, current: boolean) {
    const next = !current;
    startTransition(async () => {
      const res = await updateCaregiverVerification(id, next);
      if (res.success) syncPatch(id, { is_verified: next });
      else alert('Failed: ' + res.error);
    });
  }

  async function handleModalToggleVerify(newValue: boolean) {
    if (!selected) return;
    setModalApproving(true);
    const res = await updateCaregiverVerification(selected.id, newValue);
    setModalApproving(false);
    if (res.success) syncPatch(selected.id, { is_verified: newValue });
    else alert('Failed: ' + res.error);
  }

  function handleDelete(id: string) {
    startTransition(async () => {
      const res = await deleteCaregiver(id);
      if (res.success) {
        setCaregivers((prev) => prev.filter((c) => c.id !== id));
        setDeleteTarget(null);
        if (selected?.id === id) setSelected(null);
      } else {
        alert('Failed: ' + res.error);
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
            placeholder="Search name, email, city, headline…"
            className="w-full rounded-xl border border-gray-200 bg-white py-2 pl-10 pr-4 text-sm focus:border-[#0B1629] focus:outline-none focus:ring-1 focus:ring-[#0B1629]"
          />
        </div>
        <div className="flex gap-1 rounded-xl border border-gray-200 bg-white p-1">
          {(['all', 'verified', 'pending'] as const).map((f) => (
            <button
              key={f}
              type="button"
              onClick={() => setFilter(f)}
              className={`rounded-lg px-3 py-1.5 text-xs font-medium capitalize transition-colors ${
                filter === f ? 'bg-[#0B1629] text-white' : 'text-gray-500 hover:text-gray-700'
              }`}
            >
              {f === 'all' ? 'All' : f === 'verified' ? '✅ Verified' : '⏳ Pending'} ({counts[f]})
            </button>
          ))}
        </div>
      </motion.div>

      {/* Table */}
      <motion.div
        className="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm"
        initial="hidden"
        animate="show"
        variants={fadeUp}
        transition={{ duration: 0.35, ease: EASE_OUT, delay: 0.05 }}
      >
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-100 bg-[#0B1629]">
                {['Caregiver', 'Location', 'Experience', 'Rating', 'Bookings', 'Bg Check', 'Status', 'Actions'].map((h) => (
                  <th key={h} className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-widest text-white">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr>
                  <td colSpan={8} className="py-16 text-center text-sm text-gray-400">No caregivers found</td>
                </tr>
              ) : (
                filtered.map((c, i) => (
                  <motion.tr
                    key={c.id}
                    className="border-b border-gray-50 last:border-0 transition-colors hover:bg-[#0B1629]/5"
                    initial={{ opacity: 0, x: -12 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ duration: 0.25, ease: EASE_OUT, delay: i * 0.04 }}
                  >
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-3">
                        {c.owner?.avatar_url ? (
                          <img src={c.owner.avatar_url} alt="" className="h-9 w-9 rounded-full object-cover" />
                        ) : (
                          <div className="flex h-9 w-9 items-center justify-center rounded-full bg-[#0B1629]/10 text-xs font-bold text-[#0B1629]">
                            {(c.owner?.display_name || c.owner?.email || '?')[0].toUpperCase()}
                          </div>
                        )}
                        <div>
                          <p className="font-medium text-gray-800">{c.owner?.display_name || '—'}</p>
                          <p className="text-xs text-gray-400">{c.owner?.email}</p>
                          {c.headline && <p className="line-clamp-1 text-xs italic text-gray-500">{c.headline}</p>}
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
                      <span className="flex items-center gap-1 text-xs text-amber-600">
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
                        <motion.button
                          type="button"
                          onClick={() => setSelected(c)}
                          className="rounded-lg p-1.5 text-gray-400 transition-colors hover:bg-[#0B1629]/5 hover:text-[#0B1629]"
                          title="View details"
                          whileHover={{ scale: 1.08, y: -1 }}
                          whileTap={{ scale: 0.96 }}
                        >
                          <Eye className="h-4 w-4" />
                        </motion.button>
                        <motion.button
                          type="button"
                          onClick={() => handleToggleVerify(c.id, c.is_verified)}
                          disabled={isPending}
                          title={c.is_verified ? 'Revoke verification' : 'Approve caregiver'}
                          className={`rounded-lg p-1.5 transition-colors disabled:opacity-50 ${
                            c.is_verified
                              ? 'text-gray-400 hover:bg-red-50 hover:text-red-500'
                              : 'text-gray-400 hover:bg-green-50 hover:text-green-600'
                          }`}
                          whileHover={{ scale: 1.08 }}
                          whileTap={{ scale: 0.96 }}
                        >
                          {c.is_verified ? <XCircle className="h-4 w-4" /> : <CheckCircle className="h-4 w-4" />}
                        </motion.button>
                        <motion.button
                          type="button"
                          onClick={() => setDeleteTarget(c)}
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
                  <div className="relative flex-shrink-0">
                    {display.owner?.avatar_url ? (
                      <img src={display.owner.avatar_url} alt="" className="h-14 w-14 rounded-full object-cover shadow-lg ring-4 ring-white/30" />
                    ) : (
                      <div
                        className="flex h-14 w-14 items-center justify-center rounded-full text-sm font-black text-white shadow-lg ring-4 ring-white/30"
                        style={{ background: 'linear-gradient(135deg, #1a4a45, #3d8f89)' }}
                      >
                        {initials(display.owner?.display_name, display.owner?.email)}
                      </div>
                    )}
                  </div>
                  <div className="min-w-0 flex-1 pr-8">
                    <p className="truncate text-lg font-black leading-tight text-white">
                      {display.owner?.display_name || 'Caregiver'}
                    </p>
                    <p className="mt-0.5 truncate text-sm text-white/55">{display.owner?.email || '—'}</p>
                    {(display.city || display.country) && (
                      <div className="mt-1.5 inline-flex items-center gap-1.5 rounded-full bg-white/10 px-2.5 py-0.5 text-[11px] font-semibold text-white ring-1 ring-white/15">
                        <MapPin className="h-3 w-3 shrink-0" />
                        {[display.city, display.state, display.country].filter(Boolean).join(', ')}
                      </div>
                    )}
                    <div className="mt-2 flex flex-wrap items-center gap-2">
                      {display.is_verified ? (
                        <span className="inline-flex items-center gap-1 rounded-full bg-emerald-400/25 px-2.5 py-0.5 text-[11px] font-bold text-emerald-100 ring-1 ring-emerald-300/40">
                          <ShieldCheck className="h-3 w-3" />
                          Verified
                        </span>
                      ) : (
                        <span className="inline-flex items-center gap-1 rounded-full bg-amber-400/20 px-2.5 py-0.5 text-[11px] font-bold text-amber-100 ring-1 ring-amber-300/35">
                          <AlertTriangle className="h-3 w-3" />
                          Pending
                        </span>
                      )}
                      <span className="inline-flex items-center gap-1 rounded-full bg-white/10 px-2.5 py-0.5 text-[11px] font-semibold text-white ring-1 ring-white/15">
                        {display.is_active ? 'Active' : 'Inactive'}
                      </span>
                      {display.is_accepting_bookings && (
                        <span className="inline-flex items-center gap-1 rounded-full bg-white/10 px-2.5 py-0.5 text-[11px] font-semibold text-white ring-1 ring-white/15">
                          Accepting bookings
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

                  {display.headline && (
                    <motion.p className="text-sm font-medium italic text-gray-600" variants={drawerItemVariants}>
                      &ldquo;{display.headline}&rdquo;
                    </motion.p>
                  )}

                  {display.bio && (
                    <motion.div
                      className="rounded-2xl border border-[#0B1629]/10 bg-[#0B1629]/5 p-4"
                      style={{ borderLeft: '3px solid #0B1629' }}
                      variants={drawerItemVariants}
                    >
                      <p className="mb-1 text-[11px] font-bold uppercase tracking-widest text-[#0B1629]/70">Bio</p>
                      <p className="text-sm leading-relaxed text-gray-700">{display.bio}</p>
                    </motion.div>
                  )}

                  {/* Profile */}
                  <motion.section
                    className="overflow-hidden rounded-2xl border border-[#0B1629]/10 bg-[#0B1629]/5 p-4 shadow-sm"
                    style={{ borderLeft: '3px solid #0B1629' }}
                    variants={drawerItemVariants}
                  >
                    <div className="mb-3 flex items-center gap-2">
                      <div className="flex h-6 w-6 items-center justify-center rounded-lg bg-[#0B1629]/10">
                        <Briefcase className="h-3.5 w-3.5 text-[#0B1629]" />
                      </div>
                      <h3 className="text-[11px] font-bold uppercase tracking-widest text-[#0B1629]/70">Profile</h3>
                    </div>
                    <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
                      <CgField icon={<Award className="h-3 w-3" />} label="Experience" value={display.years_of_experience != null ? `${display.years_of_experience} years` : '—'} />
                      <CgField icon={<Star className="h-3 w-3" />} label="Rating" value={`${display.average_rating?.toFixed(1) ?? '0'} (${display.total_reviews} reviews)`} />
                      <CgField icon={<Calendar className="h-3 w-3" />} label="Total bookings" value={String(display.total_bookings)} />
                      <CgField icon={<Award className="h-3 w-3" />} label="Completion rate" value={`${display.completion_rate?.toFixed(1) ?? '0'}%`} />
                      <CgField icon={<MapPin className="h-3 w-3" />} label="Service radius" value={display.service_radius_km != null ? `${display.service_radius_km} km` : '—'} />
                      <CgField icon={<Calendar className="h-3 w-3" />} label="Joined" value={formatDateTime(display.created_at)} />
                    </div>
                  </motion.section>

                  {/* Credentials */}
                  <motion.section
                    className="overflow-hidden rounded-2xl border border-[#0B1629]/10 bg-[#0B1629]/5 p-4 shadow-sm"
                    style={{ borderLeft: '3px solid #0B1629' }}
                    variants={drawerItemVariants}
                  >
                    <div className="mb-3 flex items-center gap-2">
                      <div className="flex h-6 w-6 items-center justify-center rounded-lg bg-[#0B1629]/10">
                        <Shield className="h-3.5 w-3.5 text-[#0B1629]" />
                      </div>
                      <h3 className="text-[11px] font-bold uppercase tracking-widest text-[#0B1629]/70">Credentials</h3>
                    </div>
                    <div className="flex flex-wrap gap-2">
                      <Badge variant={display.id_verified ? 'success' : 'default'}>
                        ID {display.id_verified ? 'verified' : 'not verified'}
                      </Badge>
                      <Badge variant={display.pet_first_aid_certified ? 'success' : 'default'}>
                        First aid {display.pet_first_aid_certified ? 'yes' : 'no'}
                      </Badge>
                      <Badge variant={display.insurance_verified ? 'success' : 'default'}>
                        Insurance {display.insurance_verified ? 'yes' : 'no'}
                      </Badge>
                      <Badge variant={bgCheckVariant(display.background_check_status)}>
                        BG: {display.background_check_status?.replace(/_/g, ' ') || 'pending'}
                      </Badge>
                    </div>
                  </motion.section>

                  {/* Pet preferences */}
                  {(display.accepted_pet_types?.length || display.accepted_pet_sizes?.length) ? (
                    <motion.section
                      className="overflow-hidden rounded-2xl border border-[#0B1629]/10 bg-[#0B1629]/5 p-4 shadow-sm"
                      style={{ borderLeft: '3px solid #0B1629' }}
                      variants={drawerItemVariants}
                    >
                      <div className="mb-3 flex items-center gap-2">
                        <div className="flex h-6 w-6 items-center justify-center rounded-lg bg-[#0B1629]/10">
                          <Heart className="h-3.5 w-3.5 text-[#0B1629]" />
                        </div>
                        <h3 className="text-[11px] font-bold uppercase tracking-widest text-[#0B1629]/70">Pet Preferences</h3>
                      </div>
                      <div className="flex flex-wrap gap-1.5">
                        {display.accepted_pet_types?.map((t) => (
                          <Badge key={t} variant="teal" className="capitalize">{t}</Badge>
                        ))}
                        {display.accepted_pet_sizes?.map((s) => (
                          <Badge key={s} variant="info" className="capitalize">{s}</Badge>
                        ))}
                      </div>
                    </motion.section>
                  ) : null}

                  {/* Home environment */}
                  <motion.section
                    className="overflow-hidden rounded-2xl border border-[#0B1629]/10 bg-[#0B1629]/5 p-4 shadow-sm"
                    style={{ borderLeft: '3px solid #0B1629' }}
                    variants={drawerItemVariants}
                  >
                    <div className="mb-3 flex items-center gap-2">
                      <div className="flex h-6 w-6 items-center justify-center rounded-lg bg-[#0B1629]/10">
                        <Home className="h-3.5 w-3.5 text-[#0B1629]" />
                      </div>
                      <h3 className="text-[11px] font-bold uppercase tracking-widest text-[#0B1629]/70">Home Environment</h3>
                    </div>
                    <div className="flex flex-wrap gap-2">
                      {[
                        { label: 'Fenced yard',    value: display.has_fenced_yard,     icon: <Home className="h-3 w-3" /> },
                        { label: 'Own transport',  value: display.has_own_transport,   icon: <Car className="h-3 w-3" /> },
                        { label: 'Smoke-free',     value: display.smoke_free_home,     icon: <Shield className="h-3 w-3" /> },
                      ].map(({ label, value, icon }) => (
                        <span
                          key={label}
                          className={`inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-[11px] font-medium ring-1 ${
                            value
                              ? 'bg-emerald-50 text-emerald-700 ring-emerald-200'
                              : 'bg-gray-100 text-gray-400 ring-gray-200'
                          }`}
                        >
                          {icon}
                          {label}: {value ? 'Yes' : 'No'}
                        </span>
                      ))}
                      {display.max_pets_at_once != null && (
                        <span className="inline-flex items-center gap-1.5 rounded-full bg-blue-50 px-2.5 py-1 text-[11px] font-medium text-blue-700 ring-1 ring-blue-200">
                          <Users className="h-3 w-3" />
                          Max {display.max_pets_at_once} pets
                        </span>
                      )}
                      {display.response_time_hours != null && (
                        <span className="inline-flex items-center gap-1.5 rounded-full bg-purple-50 px-2.5 py-1 text-[11px] font-medium text-purple-700 ring-1 ring-purple-200">
                          <Calendar className="h-3 w-3" />
                          Responds in {display.response_time_hours}h
                        </span>
                      )}
                    </div>
                  </motion.section>

                  {/* Linked account */}
                  <motion.section
                    className="overflow-hidden rounded-2xl border border-[#0B1629]/10 bg-[#0B1629]/5 p-4 shadow-sm"
                    style={{ borderLeft: '3px solid #0B1629' }}
                    variants={drawerItemVariants}
                  >
                    <div className="mb-3 flex items-center gap-2">
                      <div className="flex h-6 w-6 items-center justify-center rounded-lg bg-[#0B1629]/10">
                        <User className="h-3.5 w-3.5 text-[#0B1629]" />
                      </div>
                      <h3 className="text-[11px] font-bold uppercase tracking-widest text-[#0B1629]/70">Linked Account</h3>
                    </div>
                    <div className="flex items-center gap-3 rounded-xl bg-white/70 px-4 py-3 shadow-sm">
                      {display.owner?.avatar_url ? (
                        <img src={display.owner.avatar_url} alt="" className="h-10 w-10 flex-shrink-0 rounded-xl object-cover shadow-sm" />
                      ) : (
                        <div
                          className="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-xl text-sm font-black text-white shadow-sm"
                          style={{ background: 'linear-gradient(135deg, #0B1629, #1a3a5c)' }}
                        >
                          {initials(display.owner?.display_name, display.owner?.email)}
                        </div>
                      )}
                      <div className="min-w-0">
                        <p className="truncate text-sm font-bold text-gray-900">{display.owner?.display_name || 'Unknown'}</p>
                        <p className="truncate text-xs text-gray-400">{display.owner?.email || '—'}</p>
                      </div>
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
                <div className="flex flex-wrap items-center gap-2">
                  {display.is_verified ? (
                    <motion.button
                      type="button"
                      disabled={modalApproving}
                      onClick={() => void handleModalToggleVerify(false)}
                      className="flex items-center gap-2 rounded-xl bg-amber-500 px-5 py-2.5 text-sm font-semibold text-white shadow-sm disabled:opacity-50 hover:bg-amber-600"
                      whileHover={!modalApproving ? { scale: 1.02 } : {}}
                      whileTap={!modalApproving ? { scale: 0.97 } : {}}
                    >
                      {modalApproving ? (
                        <>
                          <span className="h-4 w-4 animate-spin rounded-full border-2 border-white/70 border-t-transparent" />
                          Revoking…
                        </>
                      ) : (
                        <>
                          <XCircle className="h-4 w-4" />
                          Revoke
                        </>
                      )}
                    </motion.button>
                  ) : (
                    <motion.button
                      type="button"
                      disabled={modalApproving}
                      onClick={() => void handleModalToggleVerify(true)}
                      className="flex items-center gap-2 rounded-xl bg-emerald-500 px-5 py-2.5 text-sm font-semibold text-white shadow-sm disabled:opacity-50 hover:bg-emerald-600"
                      whileHover={!modalApproving ? { scale: 1.02 } : {}}
                      whileTap={!modalApproving ? { scale: 0.97 } : {}}
                    >
                      {modalApproving ? (
                        <>
                          <span className="h-4 w-4 animate-spin rounded-full border-2 border-white/70 border-t-transparent" />
                          Approving…
                        </>
                      ) : (
                        <>
                          <Check className="h-4 w-4" />
                          Approve
                        </>
                      )}
                    </motion.button>
                  )}
                  <motion.button
                    type="button"
                    onClick={() => { const cg = display; setSelected(null); setDeleteTarget(cg); }}
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

      <DeleteCaregiverConfirmModal
        caregiver={deleteTarget}
        open={!!deleteTarget}
        isPending={isPending}
        onCancel={() => !isPending && setDeleteTarget(null)}
        onConfirm={() => deleteTarget && handleDelete(deleteTarget.id)}
      />
    </>
  );
}

// ── Animated delete confirmation ─────────────────────────────────────────────

function DeleteCaregiverConfirmModal({
  caregiver,
  open,
  isPending,
  onCancel,
  onConfirm,
}: {
  caregiver: Caregiver | null;
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
      {open && caregiver && (
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
                  <h3 className="text-lg font-semibold text-gray-900">Delete caregiver?</h3>
                  <p className="mt-1 text-sm text-gray-500">
                    This will permanently remove this caregiver profile. This cannot be undone.
                  </p>
                </div>
              </motion.div>

              <motion.div
                className="mt-4 flex items-center gap-3 rounded-2xl border border-red-100 bg-red-50/40 p-3"
                variants={deleteItemVariants}
              >
                {caregiver.owner?.avatar_url ? (
                  <img src={caregiver.owner.avatar_url} alt="" className="h-10 w-10 rounded-xl object-cover" />
                ) : (
                  <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-white text-sm font-black text-[#0B1629] ring-1 ring-red-100">
                    {initials(caregiver.owner?.display_name, caregiver.owner?.email)}
                  </div>
                )}
                <div className="min-w-0">
                  <p className="truncate text-sm font-semibold text-gray-900">
                    {caregiver.owner?.display_name || caregiver.owner?.email || '—'}
                  </p>
                  <p className="truncate text-xs text-gray-500">{caregiver.owner?.email || caregiver.city || '—'}</p>
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
