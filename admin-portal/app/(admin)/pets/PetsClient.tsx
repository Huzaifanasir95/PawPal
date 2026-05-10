'use client';

import { useState, useTransition, useEffect, type ReactNode } from 'react';
import { AnimatePresence, motion, useAnimation } from 'framer-motion';
import Badge from '@/components/Badge';
import { Search, Eye, Trash2, X, ShieldCheck, AlertTriangle, User, PawPrint, Camera, Ruler, Weight, Palette, Shield, Heart, Edit } from 'lucide-react';
import { timeAgo, formatDateTime } from '@/lib/utils';
import { deletePet } from '@/lib/admin-actions';

interface Pet {
  id: string;
  owner_id: string;
  name: string;
  type: string;
  breed: string;
  age: number;
  age_unit: string;
  gender: string;
  color: string;
  weight: number;
  weight_unit: string;
  image_url: string | null;
  image_urls: string[] | null;
  is_verified: boolean;
  verification_confidence: number | null;
  verified_breed: string | null;
  bio: string | null;
  is_adopted: boolean;
  created_at: string;
  updated_at: string;
  owner: { name: string | null; email: string | null } | null;
}

const TYPE_OPTIONS = ['all', 'dog', 'cat'] as const;

const fadeUp = {
  hidden: { opacity: 0, y: 12 },
  show: { opacity: 1, y: 0 },
};

const EASE_OUT = [0.16, 1, 0.3, 1] as const;
const EASE_IN = [0.7, 0, 0.84, 0] as const;

const backdropVariants = {
  hidden: { opacity: 0 },
  show: { opacity: 1, transition: { duration: 0.25, ease: EASE_OUT } },
  exit: { opacity: 0, transition: { duration: 0.2, ease: EASE_IN } },
};

const modalVariants = {
  hidden: { opacity: 0, scale: 0.82, y: 26, rotateX: -12, rotateZ: -1 },
  show: {
    opacity: 1,
    scale: 1,
    y: 0,
    rotateX: 0,
    rotateZ: 0,
    transition: { type: 'spring' as const, stiffness: 260, damping: 22, mass: 0.8 },
  },
  exit: { opacity: 0, scale: 0.9, y: 18, rotateX: 6, rotateZ: 1, transition: { duration: 0.2 } },
};

const modalContentVariants = {
  show: { transition: { staggerChildren: 0.08, delayChildren: 0.05 } },
};

const modalItemVariants = {
  hidden: { opacity: 0, y: 10 },
  show: { opacity: 1, y: 0, transition: { duration: 0.25, ease: EASE_OUT } },
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

function PetInfoItem({ icon, label, value }: { icon: ReactNode; label: string; value: ReactNode }) {
  return (
    <div className="min-w-0">
      <div className="flex items-center gap-1 mb-1">
        <span className="text-[#2C6E69]/60">{icon}</span>
        <p className="text-[11px] font-semibold uppercase tracking-widest text-gray-400">{label}</p>
      </div>
      <div className="text-sm font-medium text-gray-800 capitalize break-words">{value}</div>
    </div>
  );
}

export default function PetsClient({ pets: initialPets }: { pets: Pet[] }) {
  const [pets, setPets] = useState(initialPets);
  const [search, setSearch] = useState('');
  const [typeFilter, setTypeFilter] = useState<string>('all');
  const [verifiedFilter, setVerifiedFilter] = useState<string>('all');
  const [selectedPet, setSelectedPet] = useState<Pet | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<Pet | null>(null);
  const [isPending, startTransition] = useTransition();
  const selectedImages = selectedPet
    ? [selectedPet.image_url, ...(selectedPet.image_urls ?? [])].filter((url): url is string => Boolean(url))
    : [];

  const filtered = pets.filter((pet) => {
    const q = search.toLowerCase();
    const matchesSearch =
      !q ||
      pet.name.toLowerCase().includes(q) ||
      pet.breed.toLowerCase().includes(q) ||
      pet.color.toLowerCase().includes(q) ||
      (pet.owner?.name ?? '').toLowerCase().includes(q) ||
      (pet.owner?.email ?? '').toLowerCase().includes(q);
    const matchesType = typeFilter === 'all' || pet.type === typeFilter;
    const matchesVerified =
      verifiedFilter === 'all' ||
      (verifiedFilter === 'verified' && pet.is_verified) ||
      (verifiedFilter === 'unverified' && !pet.is_verified);
    return matchesSearch && matchesType && matchesVerified;
  });

  const counts = {
    all: pets.length,
    dog: pets.filter((p) => p.type === 'dog').length,
    cat: pets.filter((p) => p.type === 'cat').length,
    verified: pets.filter((p) => p.is_verified).length,
    unverified: pets.filter((p) => !p.is_verified).length,
  };

  function handleDelete(id: string) {
    startTransition(async () => {
      const res = await deletePet(id);
      if (res.success) {
        setPets((prev) => prev.filter((p) => p.id !== id));
        setDeleteTarget(null);
        if (selectedPet?.id === id) setSelectedPet(null);
      }
    });
  }

  return (
    <div className="p-8">
      {/* Header */}
      <motion.div
        className="mb-6"
        initial="hidden"
        animate="show"
        variants={fadeUp}
        transition={{ duration: 0.35, ease: EASE_OUT }}
      >
        <h1 className="text-2xl font-bold text-gray-900">Pets</h1>
        <p className="mt-1 text-sm text-gray-500">
          {pets.length} pets — {counts.dog} dogs, {counts.cat} cats, {counts.verified} verified
        </p>
      </motion.div>

      {/* Filters */}
      <motion.div
        className="mb-5 rounded-2xl border border-gray-100 bg-white p-4 shadow-sm"
        initial="hidden"
        animate="show"
        variants={fadeUp}
        transition={{ duration: 0.35, ease: EASE_OUT }}
      >
        <div className="flex flex-wrap items-center gap-3">
          <div className="relative flex-1 min-w-[220px]">
            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
            <input
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search name, breed, color, owner…"
              className="w-full rounded-2xl border border-gray-200 bg-white py-2.5 pl-10 pr-4 text-sm shadow-sm focus:border-[#0B1629] focus:outline-none focus:ring-1 focus:ring-[#0B1629]"
            />
          </div>
          {TYPE_OPTIONS.map((t) => (
            <button
              key={t}
              onClick={() => setTypeFilter(t)}
              className={`rounded-xl px-3.5 py-1.5 text-xs font-semibold transition-colors ${
                typeFilter === t
                  ? 'bg-[#0B1629] text-white shadow-sm'
                  : 'bg-gray-100 text-gray-600 hover:bg-[#0B1629]/5 hover:text-[#0B1629]'
              }`}
            >
              {t === 'all' ? 'All' : t === 'dog' ? '🐕 Dogs' : '🐈 Cats'} ({counts[t]})
            </button>
          ))}
        </div>

        <div className="mt-3 flex flex-wrap gap-2">
          {(['all', 'verified', 'unverified'] as const).map((v) => (
            <button
              key={v}
              onClick={() => setVerifiedFilter(v)}
              className={`rounded-xl px-3.5 py-1.5 text-xs font-semibold transition-colors ${
                verifiedFilter === v
                  ? 'bg-[#0B1629] text-white shadow-sm'
                  : 'bg-gray-100 text-gray-600 hover:bg-[#0B1629]/5 hover:text-[#0B1629]'
              }`}
            >
              {v === 'all' ? `All (${counts.all})` : v === 'verified' ? `Verified (${counts.verified})` : `Unverified (${counts.unverified})`}
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
                {['Pet', 'Type', 'Breed', 'Age', 'Owner', 'Status', 'Added', 'Actions'].map((h) => (
                  <th key={h} className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-widest text-white">
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr>
                  <td colSpan={8} className="py-16 text-center text-sm text-gray-400">
                    No pets found
                  </td>
                </tr>
              ) : (
                <AnimatePresence initial={false}>
                  {filtered.map((pet, i) => (
                    <motion.tr
                      key={pet.id}
                      className="border-b border-gray-50 last:border-0 hover:bg-[#0B1629]/5 transition-colors"
                      initial={{ opacity: 0, x: -12 }}
                      animate={{ opacity: 1, x: 0 }}
                      exit={{ opacity: 0, x: -16, transition: { duration: 0.2 } }}
                      transition={{ duration: 0.25, ease: EASE_OUT, delay: i * 0.04 }}
                    >
                      <td className="px-4 py-3">
                        <div>
                          <p className="font-medium text-gray-800">{pet.name}</p>
                          <p className="text-xs text-gray-400 capitalize">{pet.gender} · {pet.color}</p>
                        </div>
                      </td>
                      <td className="px-4 py-3">
                        <Badge variant={pet.type === 'dog' ? 'warning' : 'default'} className="bg-[#0B1629]/10 text-[#0B1629]">
                          {pet.type === 'dog' ? '🐕 Dog' : '🐈 Cat'}
                        </Badge>
                      </td>
                      <td className="px-4 py-3 text-sm text-gray-600 capitalize">{pet.breed || '—'}</td>
                      <td className="px-4 py-3 text-sm text-gray-600">
                        {pet.age} {pet.age_unit}
                      </td>
                      <td className="px-4 py-3 text-xs text-gray-600">
                        {pet.owner?.name || pet.owner?.email || 'Unknown'}
                      </td>
                      <td className="px-4 py-3">
                        {pet.is_adopted ? (
                          <Badge variant="warning" className="bg-[#0B1629]/10 text-[#0B1629]">Adopted</Badge>
                        ) : (
                          <Badge variant="success" className="bg-[#0B1629]/10 text-[#0B1629]">Active</Badge>
                        )}
                      </td>
                      <td className="px-4 py-3 text-xs text-gray-400">{timeAgo(pet.created_at)}</td>
                      <td className="px-4 py-3">
                        <div className="flex items-center justify-center gap-1">
                          <motion.button
                            onClick={() => setSelectedPet(pet)}
                            className="rounded-lg p-1.5 text-gray-400 hover:bg-gray-100 hover:text-[#0B1629] transition-colors"
                            title="View details"
                            whileHover={{ scale: 1.08, y: -1 }}
                            whileTap={{ scale: 0.96 }}
                          >
                            <Eye className="h-4 w-4" />
                          </motion.button>
                          <motion.button
                            onClick={() => setDeleteTarget(pet)}
                            className="rounded-lg p-1.5 text-gray-400 hover:bg-red-50 hover:text-red-500 transition-colors"
                            title="Delete pet"
                            whileHover={{ x: [0, -1.5, 1.5, -1, 1, 0] }}
                            whileTap={{ scale: 0.95 }}
                            transition={{ duration: 0.35 }}
                          >
                            <Trash2 className="h-4 w-4" />
                          </motion.button>
                        </div>
                      </td>
                    </motion.tr>
                  ))}
                </AnimatePresence>
              )}
            </tbody>
          </table>
        </div>
      </motion.div>

      {/* Detail Modal */}
      <AnimatePresence>
        {selectedPet && (
          <motion.div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6">
            {/* Backdrop */}
            <motion.div
              className="absolute inset-0 bg-black/40 backdrop-blur-[3px]"
              onClick={() => setSelectedPet(null)}
              variants={backdropVariants}
              initial="hidden"
              animate="show"
              exit="exit"
            />

            {/* Modal */}
            <motion.div
              className="relative w-full max-w-xl overflow-hidden rounded-3xl bg-white shadow-2xl ring-1 ring-black/5"
              variants={modalVariants}
              initial="hidden"
              animate="show"
              exit="exit"
              style={{ transformOrigin: '50% 10%', transformPerspective: 1200 }}
            >
              {/* ── Branded Gradient Header ── */}
              <motion.div
                className="relative overflow-hidden px-6 pt-7 pb-6"
                style={{ background: 'linear-gradient(135deg, #0B1629 0%, #1a3a38 50%, #2C6E69 100%)' }}
                variants={modalItemVariants}
                initial="hidden"
                animate="show"
              >
                {/* Shimmer sweep */}
                <motion.div
                  className="pointer-events-none absolute inset-0 skew-x-[-20deg] bg-white/5"
                  animate={{ x: ['-120%', '220%'] }}
                  transition={{ duration: 4, repeat: Infinity, ease: 'easeInOut', repeatDelay: 3 }}
                />
                {/* Decorative circles */}
                <div className="pointer-events-none absolute -right-10 -top-10 h-48 w-48 rounded-full bg-white/5" />
                <div className="pointer-events-none absolute right-8 top-12 h-24 w-24 rounded-full bg-white/5" />

                {/* Close button */}
                <button
                  onClick={() => setSelectedPet(null)}
                  className="absolute right-4 top-4 rounded-xl p-2 text-white/60 transition hover:bg-white/10 hover:text-white"
                  aria-label="Close"
                >
                  <X className="h-5 w-5" />
                </button>

                {/* Avatar + identity */}
                <div className="relative flex items-center gap-5">
                  {/* Pet avatar */}
                  <div className="relative flex-shrink-0">
                    {selectedImages[0] ? (
                      <img
                        src={selectedImages[0]}
                        alt={selectedPet.name}
                        className="h-16 w-16 rounded-2xl object-cover ring-2 ring-white/30 shadow-lg"
                      />
                    ) : (
                      <div
                        className="flex h-16 w-16 items-center justify-center rounded-2xl text-2xl ring-2 ring-white/30 shadow-lg"
                        style={{ background: 'linear-gradient(135deg, #1a4a45, #3d8f89)' }}
                      >
                        {selectedPet.type === 'dog' ? '🐕' : '🐈'}
                      </div>
                    )}
                  </div>

                  {/* Name / breed / owner */}
                  <div className="min-w-0 flex-1 pr-8">
                    <p className="text-xl font-black text-white leading-tight truncate">
                      {selectedPet.name}
                    </p>
                    <p className="mt-0.5 text-sm text-white/55 capitalize truncate">
                      {selectedPet.breed || '—'} · {selectedPet.type}
                    </p>
                    <div className="mt-2.5 flex flex-wrap items-center gap-2">
                      {/* Species pill */}
                      <span className="inline-flex items-center gap-1 rounded-full bg-white/10 px-2.5 py-1 text-[11px] font-semibold capitalize text-white ring-1 ring-white/15">
                        <PawPrint className="h-3 w-3" />
                        {selectedPet.type === 'dog' ? 'Dog' : 'Cat'}
                      </span>
                      {/* Owner pill */}
                      <span className="inline-flex items-center gap-1 rounded-full bg-white/10 px-2.5 py-1 text-[11px] font-semibold text-white ring-1 ring-white/15">
                        <User className="h-3 w-3" />
                        {selectedPet.owner?.name || selectedPet.owner?.email || 'Unknown'}
                      </span>
                      {/* Verified badge */}
                      {selectedPet.is_verified && (
                        <span className="inline-flex items-center gap-1 rounded-full bg-emerald-500/20 px-2.5 py-1 text-[11px] font-bold text-emerald-200 ring-1 ring-emerald-400/30">
                          <ShieldCheck className="h-3 w-3" />
                          Verified
                        </span>
                      )}
                    </div>
                  </div>
                </div>
              </motion.div>

              {/* ── Scrollable Body ── */}
              <motion.div
                className="max-h-[60vh] overflow-y-auto"
                variants={modalContentVariants}
                initial="hidden"
                animate="show"
              >
                <div className="space-y-4 p-6">

                  {/* ── Pet Photos ── */}
                  {selectedImages.length > 0 && (
                    <motion.section variants={modalItemVariants}>
                      <div className="mb-2.5 flex items-center gap-2">
                        <div className="flex h-6 w-6 items-center justify-center rounded-lg bg-[#2C6E69]/15">
                          <Camera className="h-3.5 w-3.5 text-[#2C6E69]" />
                        </div>
                        <h3 className="text-[11px] font-bold uppercase tracking-widest text-[#2C6E69]">Pet Photos</h3>
                      </div>
                      <div className={`grid gap-2 ${selectedImages.length === 1 ? 'grid-cols-1' : 'grid-cols-2'}`}>
                        {selectedImages.map((url, i) => (
                          <motion.div
                            key={`${url}-${i}`}
                            className="overflow-hidden rounded-xl shadow-sm"
                            initial={{ opacity: 0, scale: 0.95 }}
                            animate={{ opacity: 1, scale: 1 }}
                            transition={{ duration: 0.3, delay: 0.1 + i * 0.07, ease: EASE_OUT }}
                            whileHover={{ scale: 1.02 }}
                          >
                            <img
                              src={url}
                              alt={`${selectedPet.name} photo ${i + 1}`}
                              className="h-32 w-full object-cover transition-transform duration-300 hover:scale-105"
                            />
                          </motion.div>
                        ))}
                      </div>
                    </motion.section>
                  )}

                  {/* ── Bio ── */}
                  {selectedPet.bio && (
                    <motion.div
                      className="rounded-2xl border border-[#2C6E69]/15 bg-[#2C6E69]/5 p-4"
                      style={{ borderLeft: '3px solid #2C6E69' }}
                      variants={modalItemVariants}
                    >
                      <p className="mb-1 text-[11px] font-bold uppercase tracking-widest text-[#2C6E69]">Bio</p>
                      <p className="text-sm text-gray-700 whitespace-pre-wrap leading-relaxed">{selectedPet.bio}</p>
                    </motion.div>
                  )}

                  {/* ── Pet Details ── */}
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
                    <div className="grid grid-cols-2 gap-x-6 gap-y-3 sm:grid-cols-3">
                      <PetInfoItem icon={<PawPrint className="h-3 w-3" />} label="Species" value={selectedPet.type === 'dog' ? 'Dog' : 'Cat'} />
                      <PetInfoItem icon={<PawPrint className="h-3 w-3" />} label="Breed" value={selectedPet.breed || '—'} />
                      <PetInfoItem icon={<Ruler className="h-3 w-3" />} label="Age" value={selectedPet.age != null ? `${selectedPet.age} ${selectedPet.age_unit}` : '—'} />
                      <PetInfoItem icon={<User className="h-3 w-3" />} label="Gender" value={selectedPet.gender || '—'} />
                      <PetInfoItem icon={<Palette className="h-3 w-3" />} label="Color" value={selectedPet.color || '—'} />
                      <PetInfoItem icon={<Weight className="h-3 w-3" />} label="Weight" value={selectedPet.weight != null ? `${selectedPet.weight} ${selectedPet.weight_unit}` : '—'} />
                    </div>
                  </motion.section>

                  {/* ── Owner Card ── */}
                  <motion.section
                    className="overflow-hidden rounded-2xl border border-[#2C6E69]/15 bg-[#2C6E69]/5 p-4 shadow-sm"
                    style={{ borderLeft: '3px solid #2C6E69' }}
                    variants={modalItemVariants}
                  >
                    <div className="mb-3 flex items-center gap-2">
                      <div className="flex h-6 w-6 items-center justify-center rounded-lg bg-[#2C6E69]/15">
                        <User className="h-3.5 w-3.5 text-[#2C6E69]" />
                      </div>
                      <h3 className="text-[11px] font-bold uppercase tracking-widest text-[#2C6E69]">Owner</h3>
                    </div>
                    <div className="flex items-center gap-3 rounded-xl bg-white/70 px-4 py-3 shadow-sm transition-shadow hover:shadow-md">
                      <div
                        className="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-xl text-sm font-black text-white shadow-sm"
                        style={{ background: 'linear-gradient(135deg, #1a3a38, #2C6E69)' }}
                      >
                        {(selectedPet.owner?.name || selectedPet.owner?.email || '?')[0].toUpperCase()}
                      </div>
                      <div className="min-w-0">
                        <p className="font-bold text-gray-900 text-sm truncate">
                          {selectedPet.owner?.name || 'Unknown'}
                        </p>
                        <p className="text-xs text-gray-400 truncate">
                          {selectedPet.owner?.email || '—'}
                        </p>
                      </div>
                    </div>
                  </motion.section>

                  {/* ── Status Card ── */}
                  <motion.section
                    className="overflow-hidden rounded-2xl border border-[#2C6E69]/15 bg-[#2C6E69]/5 p-4 shadow-sm"
                    style={{ borderLeft: '3px solid #2C6E69' }}
                    variants={modalItemVariants}
                  >
                    <div className="mb-3 flex items-center gap-2">
                      <div className="flex h-6 w-6 items-center justify-center rounded-lg bg-[#2C6E69]/15">
                        <Shield className="h-3.5 w-3.5 text-[#2C6E69]" />
                      </div>
                      <h3 className="text-[11px] font-bold uppercase tracking-widest text-[#2C6E69]">Status</h3>
                    </div>
                    <div className="grid grid-cols-2 gap-3">
                      {/* Verification */}
                      <div>
                        <p className="mb-1.5 text-[11px] font-semibold uppercase tracking-widest text-gray-400">Verification</p>
                        {selectedPet.is_verified ? (
                          <span className="inline-flex items-center gap-1.5 rounded-full bg-emerald-50 px-3 py-1 text-xs font-bold text-emerald-600 ring-1 ring-emerald-200">
                            <span className="h-1.5 w-1.5 rounded-full bg-emerald-500" />
                            Verified
                          </span>
                        ) : (
                          <span className="inline-flex items-center gap-1.5 rounded-full bg-amber-50 px-3 py-1 text-xs font-bold text-amber-600 ring-1 ring-amber-200">
                            <AlertTriangle className="h-3 w-3" />
                            Unverified
                          </span>
                        )}
                      </div>
                      {/* Adoption */}
                      <div>
                        <p className="mb-1.5 text-[11px] font-semibold uppercase tracking-widest text-gray-400">Adoption</p>
                        {selectedPet.is_adopted ? (
                          <span className="inline-flex items-center gap-1.5 rounded-full bg-blue-50 px-3 py-1 text-xs font-bold text-blue-600 ring-1 ring-blue-200">
                            <Heart className="h-3 w-3 fill-blue-400" />
                            Adopted
                          </span>
                        ) : (
                          <span className="inline-flex items-center gap-1.5 rounded-full bg-emerald-50 px-3 py-1 text-xs font-bold text-emerald-600 ring-1 ring-emerald-200">
                            <span className="h-1.5 w-1.5 rounded-full bg-emerald-500" />
                            Active
                          </span>
                        )}
                      </div>
                      {/* Verified Breed */}
                      <div>
                        <p className="mb-1 text-[11px] font-semibold uppercase tracking-widest text-gray-400">Verified Breed</p>
                        <p className="text-sm font-medium text-gray-800 capitalize">
                          {selectedPet.verified_breed || <span className="text-gray-300 italic text-xs">Not available</span>}
                        </p>
                      </div>
                      {/* Confidence */}
                      <div>
                        <p className="mb-1 text-[11px] font-semibold uppercase tracking-widest text-gray-400">Confidence</p>
                        <p className="text-sm font-medium text-gray-800">
                          {selectedPet.verification_confidence != null
                            ? `${(selectedPet.verification_confidence * 100).toFixed(1)}%`
                            : <span className="text-gray-300 italic text-xs">Not available</span>}
                        </p>
                      </div>
                      {/* Added */}
                      <div>
                        <p className="mb-1 text-[11px] font-semibold uppercase tracking-widest text-gray-400">Added</p>
                        <p className="text-sm font-medium text-gray-800">{formatDateTime(selectedPet.created_at)}</p>
                      </div>
                      {/* Updated */}
                      <div>
                        <p className="mb-1 text-[11px] font-semibold uppercase tracking-widest text-gray-400">Updated</p>
                        <p className="text-sm font-medium text-gray-800">{formatDateTime(selectedPet.updated_at)}</p>
                      </div>
                    </div>
                  </motion.section>

                </div>
              </motion.div>

              {/* ── Footer Action Bar ── */}
              <motion.div
                className="flex items-center justify-between gap-3 border-t border-gray-100 bg-gray-50/60 px-6 py-4"
                variants={modalItemVariants}
                initial="hidden"
                animate="show"
              >
                <motion.button
                  onClick={() => setSelectedPet(null)}
                  className="rounded-xl border border-gray-200 bg-white px-5 py-2.5 text-sm font-medium text-gray-600 transition hover:bg-gray-100"
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.97 }}
                >
                  Close
                </motion.button>
                <div className="flex items-center gap-2">
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
                    onClick={() => { setSelectedPet(null); setDeleteTarget(selectedPet); }}
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

      {/* Delete Confirmation Modal */}
      <DeletePetModal
        pet={deleteTarget}
        open={!!deleteTarget}
        isPending={isPending}
        onCancel={() => !isPending && setDeleteTarget(null)}
        onConfirm={() => deleteTarget && handleDelete(deleteTarget.id)}
      />
    </div>
  );
}

function DeletePetModal({
  pet,
  open,
  isPending,
  onCancel,
  onConfirm,
}: {
  pet: Pet | null;
  open: boolean;
  isPending: boolean;
  onCancel: () => void;
  onConfirm: () => void;
}) {
  const warningControls = useAnimation();
  const avatarUrl = pet?.image_url || pet?.image_urls?.[0] || null;

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
      {open && pet && (
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
                  <h3 className="text-lg font-semibold text-gray-900">Delete pet?</h3>
                  <p className="mt-1 text-sm text-gray-500">
                    Are you sure you want to delete this pet? This action cannot be undone.
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
                  <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-white text-red-400 ring-1 ring-red-100">
                    {pet.type === 'dog' ? '🐕' : '🐈'}
                  </div>
                )}
                <div className="min-w-0">
                  <p className="text-sm font-semibold text-gray-900 truncate">
                    {pet.name || 'Unknown'}
                  </p>
                  <p className="text-xs text-gray-500 truncate">{pet.breed || '—'}</p>
                </div>
              </motion.div>

              <motion.div className="mt-5 flex gap-3" variants={deleteItemVariants}>
                <button
                  disabled={isPending}
                  onClick={onCancel}
                  className="flex-1 rounded-xl border border-gray-200 bg-white py-2.5 text-sm font-medium text-gray-600 transition hover:bg-gray-50 disabled:opacity-50"
                >
                  Cancel
                </button>
                <motion.button
                  disabled={isPending}
                  onClick={onConfirm}
                  className="flex-1 rounded-xl bg-red-500 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-red-600 disabled:opacity-50"
                  whileHover={!isPending ? { scale: 1.02 } : {}}
                  whileTap={!isPending ? { scale: 0.98 } : {}}
                >
                  {isPending ? (
                    <span className="inline-flex items-center gap-2">
                      <span className="h-4 w-4 animate-spin rounded-full border-2 border-white/70 border-t-transparent" />
                      Deleting...
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
