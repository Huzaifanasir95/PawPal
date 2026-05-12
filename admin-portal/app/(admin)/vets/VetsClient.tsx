'use client';

import { useState, useMemo, useTransition, useEffect, useRef, type ReactNode } from 'react';
import { AnimatePresence, motion, useAnimation } from 'framer-motion';
import {
  Search,
  CheckCircle,
  XCircle,
  Star,
  Eye,
  Trash2,
  X,
  Stethoscope,
  Building2,
  Shield,
  User,
  AlertTriangle,
  ShieldCheck,
  Check,
  Phone,
  Award,
  DollarSign,
} from 'lucide-react';
import Badge from '@/components/Badge';
import { updateVetVerification, deleteVet } from '@/lib/admin-actions';
import { formatDateTime } from '@/lib/utils';
import { prefetchVetForModal, type PrefetchedVet } from './actions';

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

export type Vet = PrefetchedVet;

function vetInitials(name: string) {
  const parts = name.trim().split(/\s+/).filter(Boolean);
  if (parts.length === 0) return '?';
  if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
  return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
}

function specializationAsText(s: unknown): string {
  if (s == null) return '';
  if (Array.isArray(s)) return s.map((x) => String(x).trim()).filter(Boolean).join(', ');
  if (typeof s === 'object') { try { return JSON.stringify(s); } catch { return String(s); } }
  return String(s).trim();
}

function specializationTags(s: unknown): string[] {
  const text = specializationAsText(s);
  if (!text) return [];
  return text.split(/[,;]/).map((x) => x.trim()).filter(Boolean);
}

function formatConsultationFee(fee: number | null, currency: string | null) {
  if (fee == null) return '—';
  const c = (currency || 'USD').toUpperCase();
  try { return new Intl.NumberFormat('en-US', { style: 'currency', currency: c }).format(fee); }
  catch { return `${c} ${fee}`; }
}

function VetField({ icon, label, value }: { icon: ReactNode; label: string; value: ReactNode }) {
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

export default function VetsClient({ vets: initialVets }: { vets: Vet[] }) {
  const [search, setSearch] = useState('');
  const [filter, setFilter] = useState<'all' | 'verified' | 'pending'>('all');
  const [vets, setVets] = useState(initialVets);
  const [isPending, startTransition] = useTransition();
  const [selectedVet, setSelectedVet] = useState<Vet | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<Vet | null>(null);
  const [detailById, setDetailById] = useState<Partial<Record<string, Vet>>>({});
  const [toast, setToast] = useState<string | null>(null);
  const [modalApproving, setModalApproving] = useState(false);
  const prefetchInFlight = useRef<Set<string>>(new Set());

  const displayVet = selectedVet
    ? { ...selectedVet, ...(detailById[selectedVet.id] ?? {}) }
    : null;

  useEffect(() => {
    if (!toast) return;
    const t = setTimeout(() => setToast(null), 2800);
    return () => clearTimeout(t);
  }, [toast]);

  function requestPrefetch(v: Vet) {
    if (prefetchInFlight.current.has(v.id)) return;
    prefetchInFlight.current.add(v.id);
    prefetchVetForModal(v.id)
      .then((d) => {
        prefetchInFlight.current.delete(v.id);
        if (d) setDetailById((prev) => ({ ...prev, [v.id]: d }));
      })
      .catch(() => prefetchInFlight.current.delete(v.id));
  }

  const filtered = useMemo(
    () =>
      vets.filter((v) => {
        const matchSearch =
          v.name.toLowerCase().includes(search.toLowerCase()) ||
          (v.email?.toLowerCase() ?? '').includes(search.toLowerCase()) ||
          (v.clinic_name?.toLowerCase() ?? '').includes(search.toLowerCase());
        const matchFilter =
          filter === 'all' ? true : filter === 'verified' ? v.is_verified : !v.is_verified;
        return matchSearch && matchFilter;
      }),
    [vets, search, filter]
  );

  function syncVetPatch(id: string, patch: Partial<Vet>) {
    setVets((prev) => prev.map((v) => (v.id === id ? { ...v, ...patch } : v)));
    setDetailById((prev) => (prev[id] ? { ...prev, [id]: { ...prev[id]!, ...patch } } : prev));
    setSelectedVet((prev) => (prev && prev.id === id ? { ...prev, ...patch } : prev));
  }

  function handleToggleVerify(id: string, currentValue: boolean) {
    const newValue = !currentValue;
    startTransition(async () => {
      const result = await updateVetVerification(id, newValue);
      if (result.success) syncVetPatch(id, { is_verified: newValue });
      else alert('Failed to update: ' + result.error);
    });
  }

  async function handleModalToggleVerify(newValue: boolean) {
    if (!displayVet) return;
    setModalApproving(true);
    const result = await updateVetVerification(displayVet.id, newValue);
    setModalApproving(false);
    if (result.success) {
      syncVetPatch(displayVet.id, { is_verified: newValue });
      setToast(newValue ? 'Vet approved' : 'Verification revoked');
    } else {
      alert('Failed to update: ' + result.error);
    }
  }

  function handleDelete(vet: Vet) {
    startTransition(async () => {
      const res = await deleteVet(vet.id);
      if (res.success) {
        setVets((prev) => prev.filter((v) => v.id !== vet.id));
        setDeleteTarget(null);
        setSelectedVet(null);
        setDetailById((prev) => { const next = { ...prev }; delete next[vet.id]; return next; });
      } else {
        alert('Failed to delete vet: ' + res.error);
      }
    });
  }

  const tags = displayVet ? specializationTags(displayVet.specialization) : [];
  const headerAvatar =
    displayVet?.linked_user?.avatar_url && displayVet.linked_user.avatar_url.length > 0
      ? displayVet.linked_user.avatar_url
      : null;

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
        <div className="relative">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
          <input
            type="text"
            placeholder="Search vets..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-64 rounded-xl border border-gray-200 bg-white py-2 pl-9 pr-4 text-sm text-gray-700 outline-none focus:border-[#0B1629] focus:ring-1 focus:ring-[#0B1629]"
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
              {f}
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
                {['Vet', 'Clinic', 'Specialization', 'License', 'Fee', 'Rating', 'Status', 'Actions'].map((h) => (
                  <th key={h} className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-widest text-white">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr><td colSpan={8} className="py-16 text-center text-sm text-gray-400">No vets found</td></tr>
              ) : (
                filtered.map((v, i) => (
                  <motion.tr
                    key={v.id}
                    className="border-b border-gray-50 last:border-0 transition-colors hover:bg-[#0B1629]/5"
                    initial={{ opacity: 0, x: -12 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ duration: 0.25, ease: EASE_OUT, delay: i * 0.04 }}
                  >
                    <td className="px-4 py-3">
                      <p className="font-medium text-gray-800">{v.name}</p>
                      <p className="text-xs text-gray-400">{v.email || '—'}</p>
                    </td>
                    <td className="px-4 py-3 text-gray-600">
                      <p>{v.clinic_name || '—'}</p>
                      <p className="text-xs text-gray-400">{v.clinic_address || ''}</p>
                    </td>
                    <td className="px-4 py-3 text-gray-600">{specializationAsText(v.specialization) || '—'}</td>
                    <td className="px-4 py-3 font-mono text-xs text-gray-500">{v.license_number || '—'}</td>
                    <td className="px-4 py-3 text-gray-600">{formatConsultationFee(v.consultation_fee, v.currency)}</td>
                    <td className="px-4 py-3">
                      {v.rating != null ? (
                        <span className="flex items-center gap-1 text-amber-600">
                          <Star className="h-3.5 w-3.5 fill-amber-400 text-amber-400" />
                          {v.rating.toFixed(1)}
                        </span>
                      ) : (
                        <span className="text-gray-400">—</span>
                      )}
                    </td>
                    <td className="px-4 py-3">
                      <Badge variant={v.is_verified ? 'success' : 'warning'}>
                        {v.is_verified ? 'Verified' : 'Pending'}
                      </Badge>
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-1">
                        <motion.button
                          type="button"
                          onClick={() => setSelectedVet(v)}
                          onMouseEnter={() => requestPrefetch(v)}
                          className="rounded-lg p-1.5 text-gray-400 transition-colors hover:bg-[#0B1629]/5 hover:text-[#0B1629]"
                          title="View details"
                          whileHover={{ scale: 1.08, y: -1 }}
                          whileTap={{ scale: 0.96 }}
                        >
                          <Eye className="h-4 w-4" />
                        </motion.button>
                        <motion.button
                          type="button"
                          onClick={() => handleToggleVerify(v.id, v.is_verified)}
                          disabled={isPending}
                          title={v.is_verified ? 'Revoke verification' : 'Approve vet'}
                          className={`rounded-lg p-1.5 transition-colors disabled:opacity-50 ${
                            v.is_verified
                              ? 'text-gray-400 hover:bg-red-50 hover:text-red-500'
                              : 'text-gray-400 hover:bg-green-50 hover:text-green-600'
                          }`}
                          whileHover={{ scale: 1.08 }}
                          whileTap={{ scale: 0.96 }}
                        >
                          {v.is_verified ? <XCircle className="h-4 w-4" /> : <CheckCircle className="h-4 w-4" />}
                        </motion.button>
                        <motion.button
                          type="button"
                          onClick={() => setDeleteTarget(v)}
                          className="rounded-lg p-1.5 text-gray-400 transition-colors hover:bg-red-50 hover:text-red-500"
                          title="Delete vet"
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
        {displayVet && (
          <motion.div className="fixed inset-0 z-50 flex justify-end">
            <motion.div
              className="absolute inset-0 bg-black/40 backdrop-blur-[2px]"
              onClick={() => setSelectedVet(null)}
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
                  onClick={() => setSelectedVet(null)}
                  className="absolute right-4 top-4 rounded-xl p-2 text-white/60 transition hover:bg-white/10 hover:text-white"
                  aria-label="Close"
                >
                  <X className="h-5 w-5" />
                </button>

                <div className="relative flex items-start gap-4">
                  <div className="relative flex-shrink-0">
                    {headerAvatar ? (
                      <img src={headerAvatar} alt="" className="h-14 w-14 rounded-full object-cover shadow-lg ring-4 ring-white/30" />
                    ) : (
                      <div
                        className="flex h-14 w-14 items-center justify-center rounded-full text-sm font-black text-white shadow-lg ring-4 ring-white/30"
                        style={{ background: 'linear-gradient(135deg, #1a4a45, #3d8f89)' }}
                      >
                        {vetInitials(displayVet.name)}
                      </div>
                    )}
                  </div>

                  <div className="min-w-0 flex-1 pr-8">
                    <p className="truncate text-lg font-black leading-tight text-white">{displayVet.name}</p>
                    <p className="mt-0.5 truncate text-sm text-white/55">{displayVet.email || '—'}</p>
                    {displayVet.clinic_name && (
                      <div className="mt-1.5 inline-flex items-center gap-1.5 rounded-full bg-white/10 px-2.5 py-0.5 text-[11px] font-semibold text-white ring-1 ring-white/15">
                        <Building2 className="h-3 w-3 shrink-0" />
                        {displayVet.clinic_name}
                      </div>
                    )}
                    <div className="mt-2 flex flex-wrap items-center gap-2">
                      {displayVet.is_verified ? (
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
                      {tags.map((tag) => (
                        <span key={tag} className="inline-flex rounded-full bg-white/10 px-2.5 py-0.5 text-[11px] font-semibold capitalize text-white ring-1 ring-white/15">
                          {tag}
                        </span>
                      ))}
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

                  {/* Vet details */}
                  <motion.section
                    className="overflow-hidden rounded-2xl border border-[#0B1629]/10 bg-[#0B1629]/5 p-4 shadow-sm"
                    style={{ borderLeft: '3px solid #0B1629' }}
                    variants={drawerItemVariants}
                  >
                    <div className="mb-3 flex items-center gap-2">
                      <div className="flex h-6 w-6 items-center justify-center rounded-lg bg-[#0B1629]/10">
                        <Stethoscope className="h-3.5 w-3.5 text-[#0B1629]" />
                      </div>
                      <h3 className="text-[11px] font-bold uppercase tracking-widest text-[#0B1629]/70">Vet Details</h3>
                    </div>
                    <div className="grid grid-cols-1 gap-x-6 gap-y-3 sm:grid-cols-2">
                      <VetField icon={<Award className="h-3 w-3" />} label="License number" value={displayVet.license_number || '—'} />
                      <VetField icon={<Stethoscope className="h-3 w-3" />} label="Specializations" value={specializationAsText(displayVet.specialization) || '—'} />
                      <VetField icon={<DollarSign className="h-3 w-3" />} label="Consultation fee" value={formatConsultationFee(displayVet.consultation_fee, displayVet.currency)} />
                      <VetField
                        icon={<Star className="h-3 w-3" />}
                        label="Rating"
                        value={displayVet.rating != null ? (
                          <span className="inline-flex items-center gap-1">
                            <Star className="h-3.5 w-3.5 fill-amber-400 text-amber-400" />
                            {displayVet.rating.toFixed(1)}
                          </span>
                        ) : '—'}
                      />
                      <VetField icon={<User className="h-3 w-3" />} label="Years of experience" value={displayVet.years_of_experience != null ? `${displayVet.years_of_experience} years` : '—'} />
                      <VetField icon={<Phone className="h-3 w-3" />} label="Phone" value={displayVet.phone || '—'} />
                    </div>
                  </motion.section>

                  {/* Clinic details */}
                  <motion.section
                    className="overflow-hidden rounded-2xl border border-[#0B1629]/10 bg-[#0B1629]/5 p-4 shadow-sm"
                    style={{ borderLeft: '3px solid #0B1629' }}
                    variants={drawerItemVariants}
                  >
                    <div className="mb-3 flex items-center gap-2">
                      <div className="flex h-6 w-6 items-center justify-center rounded-lg bg-[#0B1629]/10">
                        <Building2 className="h-3.5 w-3.5 text-[#0B1629]" />
                      </div>
                      <h3 className="text-[11px] font-bold uppercase tracking-widest text-[#0B1629]/70">Clinic Details</h3>
                    </div>
                    <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
                      <VetField icon={<Building2 className="h-3 w-3" />} label="Clinic name" value={displayVet.clinic_name || '—'} />
                      <VetField icon={<Building2 className="h-3 w-3" />} label="Clinic address" value={displayVet.clinic_address || '—'} />
                      <VetField icon={<Phone className="h-3 w-3" />} label="Clinic contact" value={displayVet.phone || '—'} />
                    </div>
                  </motion.section>

                  {/* Linked account */}
                  {displayVet.linked_user && (
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
                        {displayVet.linked_user.avatar_url ? (
                          <img src={displayVet.linked_user.avatar_url} alt="" className="h-10 w-10 flex-shrink-0 rounded-xl object-cover shadow-sm" />
                        ) : (
                          <div
                            className="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-xl text-sm font-black text-white shadow-sm"
                            style={{ background: 'linear-gradient(135deg, #0B1629, #1a3a5c)' }}
                          >
                            {vetInitials(displayVet.linked_user.display_name || displayVet.linked_user.email || '?')}
                          </div>
                        )}
                        <div className="min-w-0">
                          <p className="truncate text-sm font-bold text-gray-900">{displayVet.linked_user.display_name || 'Unknown'}</p>
                          <p className="truncate text-xs text-gray-400">{displayVet.linked_user.email || '—'}</p>
                        </div>
                      </div>
                    </motion.section>
                  )}

                  {/* Status */}
                  <motion.section
                    className="overflow-hidden rounded-2xl border border-[#0B1629]/10 bg-[#0B1629]/5 p-4 shadow-sm"
                    style={{ borderLeft: '3px solid #0B1629' }}
                    variants={drawerItemVariants}
                  >
                    <div className="mb-3 flex items-center gap-2">
                      <div className="flex h-6 w-6 items-center justify-center rounded-lg bg-[#0B1629]/10">
                        <Shield className="h-3.5 w-3.5 text-[#0B1629]" />
                      </div>
                      <h3 className="text-[11px] font-bold uppercase tracking-widest text-[#0B1629]/70">Status</h3>
                    </div>
                    <div className="flex flex-wrap gap-4">
                      <div>
                        <p className="mb-1.5 text-[11px] font-semibold uppercase tracking-widest text-gray-400">Verification</p>
                        {displayVet.is_verified ? (
                          <span className="inline-flex items-center gap-1.5 rounded-full bg-emerald-50 px-3 py-1 text-xs font-bold text-emerald-600 ring-1 ring-emerald-200">
                            <span className="h-1.5 w-1.5 rounded-full bg-emerald-500" />
                            Verified
                          </span>
                        ) : (
                          <span className="inline-flex items-center gap-1.5 rounded-full bg-amber-50 px-3 py-1 text-xs font-bold text-amber-600 ring-1 ring-amber-200">
                            <AlertTriangle className="h-3 w-3" />
                            Pending
                          </span>
                        )}
                      </div>
                      <div>
                        <p className="mb-1.5 text-[11px] font-semibold uppercase tracking-widest text-gray-400">Availability</p>
                        {displayVet.is_available ? (
                          <span className="inline-flex items-center gap-1.5 rounded-full bg-emerald-50 px-3 py-1 text-xs font-bold text-emerald-600 ring-1 ring-emerald-200">
                            <span className="h-1.5 w-1.5 rounded-full bg-emerald-500" />
                            Available
                          </span>
                        ) : (
                          <span className="inline-flex items-center gap-1.5 rounded-full bg-gray-100 px-3 py-1 text-xs font-bold text-gray-600 ring-1 ring-gray-200">
                            Unavailable
                          </span>
                        )}
                      </div>
                      <div>
                        <p className="mb-1.5 text-[11px] font-semibold uppercase tracking-widest text-gray-400">Member Since</p>
                        <p className="text-sm font-semibold text-gray-800">{formatDateTime(displayVet.created_at)}</p>
                      </div>
                    </div>
                  </motion.section>

                </div>
              </motion.div>

              {/* Sticky footer */}
              <div className="flex-shrink-0 flex flex-wrap items-center justify-between gap-3 border-t border-gray-100 bg-gray-50/80 px-6 py-4">
                <motion.button
                  type="button"
                  onClick={() => setSelectedVet(null)}
                  className="rounded-xl border border-gray-200 bg-white px-5 py-2.5 text-sm font-medium text-gray-600 transition hover:bg-gray-100"
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.97 }}
                >
                  Close
                </motion.button>
                <div className="flex flex-wrap items-center gap-2">
                  {displayVet.is_verified ? (
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
                    onClick={() => { const v = displayVet; setSelectedVet(null); setDeleteTarget(v); }}
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

      <DeleteVetConfirmModal
        vet={deleteTarget}
        open={!!deleteTarget}
        isPending={isPending}
        onCancel={() => !isPending && setDeleteTarget(null)}
        onConfirm={() => deleteTarget && handleDelete(deleteTarget)}
      />

      <AnimatePresence>
        {toast && (
          <motion.div
            initial={{ opacity: 0, y: 16 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 8 }}
            className="fixed bottom-6 left-1/2 z-[70] -translate-x-1/2 rounded-xl bg-[#0B1629] px-5 py-2.5 text-sm font-medium text-white shadow-lg ring-1 ring-white/10"
          >
            {toast}
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}

function DeleteVetConfirmModal({
  vet,
  open,
  isPending,
  onCancel,
  onConfirm,
}: {
  vet: Vet | null;
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
      {open && vet && (
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
                  <h3 className="text-lg font-semibold text-gray-900">Delete veterinarian?</h3>
                  <p className="mt-1 text-sm text-gray-500">
                    This will permanently remove this vet profile. This action cannot be undone.
                  </p>
                </div>
              </motion.div>

              <motion.div
                className="mt-4 flex items-center gap-3 rounded-2xl border border-red-100 bg-red-50/40 p-3"
                variants={deleteItemVariants}
              >
                <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-white text-sm font-black text-[#0B1629] ring-1 ring-red-100">
                  {vetInitials(vet.name)}
                </div>
                <div className="min-w-0">
                  <p className="truncate text-sm font-semibold text-gray-900">{vet.name}</p>
                  <p className="truncate text-xs text-gray-500">{vet.clinic_name || vet.email || '—'}</p>
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
