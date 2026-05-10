'use client';

import { useState, useTransition, useEffect, type ReactNode } from 'react';
import { AnimatePresence, motion, useAnimation } from 'framer-motion';
import Badge from '@/components/Badge';
import { Search, Eye, Trash2, X, ShieldCheck, AlertTriangle } from 'lucide-react';
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

function InfoItem({ label, value }: { label: string; value: ReactNode }) {
  return (
    <div className="min-w-0">
      <p className="text-[11px] font-semibold uppercase tracking-widest text-gray-400">{label}</p>
      <div className="mt-1 text-sm font-medium text-gray-800 break-words">{value}</div>
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
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Pets</h1>
        <p className="mt-1 text-sm text-gray-500">
          {pets.length} pets — {counts.dog} dogs, {counts.cat} cats, {counts.verified} verified
        </p>
      </div>

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
            <motion.div
              className="absolute inset-0 bg-black/35 backdrop-blur-[2px]"
              onClick={() => setSelectedPet(null)}
              variants={backdropVariants}
              initial="hidden"
              animate="show"
              exit="exit"
            />
            <motion.div
              className="relative w-full max-w-2xl overflow-hidden rounded-3xl bg-white shadow-2xl ring-1 ring-black/5"
              variants={modalVariants}
              initial="hidden"
              animate="show"
              exit="exit"
              style={{ transformOrigin: '85% 15%', transformPerspective: 1200 }}
            >
              <motion.div
                className="flex items-start justify-between gap-4 border-b border-gray-100 px-6 py-5"
                variants={modalItemVariants}
                initial="hidden"
                animate="show"
              >
                <div className="flex items-center gap-4">
                  {selectedImages[0] ? (
                    <img src={selectedImages[0]} alt="" className="h-14 w-14 rounded-2xl object-cover" />
                  ) : (
                    <div className="flex h-14 w-14 items-center justify-center rounded-2xl bg-gradient-to-br from-slate-100 to-slate-200 text-lg">
                      {selectedPet.type === 'dog' ? '🐕' : '🐈'}
                    </div>
                  )}
                  <div>
                    <p className="text-lg font-semibold text-gray-900">{selectedPet.name}</p>
                    <p className="text-sm text-gray-500 capitalize">
                      {selectedPet.breed || '—'} · {selectedPet.type}
                    </p>
                    <p className="text-xs text-gray-400">
                      {selectedPet.owner?.name || selectedPet.owner?.email || 'Unknown owner'}
                    </p>
                    <div className="mt-2 flex flex-wrap items-center gap-2 text-[11px]">
                      <span className="rounded-full bg-gray-100 px-2.5 py-1 font-semibold text-gray-600">
                        {selectedPet.type === 'dog' ? 'Dog' : 'Cat'}
                      </span>
                    </div>
                  </div>
                </div>
                <button
                  onClick={() => setSelectedPet(null)}
                  className="rounded-xl p-2 text-gray-400 transition hover:bg-gray-100 hover:text-gray-700"
                  aria-label="Close"
                >
                  <X className="h-5 w-5" />
                </button>
              </motion.div>

              <motion.div
                className="max-h-[70vh] overflow-y-auto p-6"
                variants={modalContentVariants}
                initial="hidden"
                animate="show"
              >
                <div className="grid gap-4 sm:grid-cols-2">
                  <motion.section
                    className="rounded-2xl border border-gray-100 bg-gray-50/70 p-4 sm:col-span-2"
                    variants={modalItemVariants}
                  >
                    <h3 className="text-[11px] font-semibold uppercase tracking-widest text-gray-400">
                      Profile
                    </h3>
                    {selectedImages.length > 0 && (
                      <div className="mt-3 grid grid-cols-2 gap-2">
                        {selectedImages.map((url, i) => (
                          <img
                            key={`${url}-${i}`}
                            src={url}
                            alt={
                              selectedPet.name ? `${selectedPet.name} photo ${i + 1}` : `Pet photo ${i + 1}`
                            }
                            className="h-28 w-full rounded-xl object-cover"
                          />
                        ))}
                      </div>
                    )}
                    {selectedPet.bio && (
                      <div className="mt-3">
                        <p className="text-xs font-semibold uppercase text-gray-400">Bio</p>
                        <p className="mt-2 rounded-xl bg-white/70 p-3 text-sm text-gray-700 whitespace-pre-wrap">
                          {selectedPet.bio}
                        </p>
                      </div>
                    )}
                    <div className="mt-3 grid grid-cols-2 gap-3">
                      <InfoItem label="Species" value={selectedPet.type === 'dog' ? 'Dog' : 'Cat'} />
                      <InfoItem label="Breed" value={selectedPet.breed || '—'} />
                      <InfoItem
                        label="Age"
                        value={selectedPet.age != null ? `${selectedPet.age} ${selectedPet.age_unit}` : '—'}
                      />
                      <InfoItem label="Gender" value={selectedPet.gender || '—'} />
                      <InfoItem label="Color" value={selectedPet.color || '—'} />
                      <InfoItem
                        label="Weight"
                        value={selectedPet.weight != null ? `${selectedPet.weight} ${selectedPet.weight_unit}` : '—'}
                      />
                    </div>
                  </motion.section>

                  <motion.section
                    className="rounded-2xl border border-gray-100 bg-gray-50/70 p-4"
                    variants={modalItemVariants}
                  >
                    <h3 className="text-[11px] font-semibold uppercase tracking-widest text-gray-400">
                      Owner
                    </h3>
                    <div className="mt-3 grid grid-cols-2 gap-3">
                      <InfoItem label="Name" value={selectedPet.owner?.name || 'Unknown'} />
                      <InfoItem label="Email" value={selectedPet.owner?.email || '—'} />
                    </div>
                  </motion.section>

                  <motion.section
                    className="rounded-2xl border border-gray-100 bg-gray-50/70 p-4"
                    variants={modalItemVariants}
                  >
                    <h3 className="text-[11px] font-semibold uppercase tracking-widest text-gray-400">
                      Status
                    </h3>
                    <div className="mt-3 grid grid-cols-2 gap-3">
                      <InfoItem label="Verification" value={selectedPet.is_verified ? 'Verified' : 'Unverified'} />
                      <InfoItem label="Adoption" value={selectedPet.is_adopted ? 'Adopted' : 'Active'} />
                      <InfoItem label="Verified Breed" value={selectedPet.verified_breed || '—'} />
                      <InfoItem
                        label="Confidence"
                        value={
                          selectedPet.verification_confidence != null
                            ? `${(selectedPet.verification_confidence * 100).toFixed(1)}%`
                            : '—'
                        }
                      />
                      <InfoItem label="Vaccination Records" value="—" />
                      <InfoItem label="Added" value={formatDateTime(selectedPet.created_at)} />
                      <InfoItem label="Updated" value={formatDateTime(selectedPet.updated_at)} />
                    </div>
                  </motion.section>

                </div>
              </motion.div>

              <motion.div
                className="flex flex-wrap items-center justify-between gap-3 border-t border-gray-100 bg-white/80 px-6 py-4"
                variants={modalItemVariants}
                initial="hidden"
                animate="show"
              >
                <button
                  onClick={() => setSelectedPet(null)}
                  className="rounded-xl border border-gray-200 bg-white px-4 py-2 text-sm font-medium text-gray-700 transition hover:bg-gray-50"
                >
                  Close
                </button>
                <div className="flex items-center gap-2">
                  <button
                    type="button"
                    disabled
                    title="Edit coming soon"
                    className="rounded-xl border border-[#0B1629]/20 bg-[#0B1629]/10 px-4 py-2 text-sm font-semibold text-[#0B1629] opacity-60"
                  >
                    Edit
                  </button>
                  <button
                    onClick={() => { setSelectedPet(null); setDeleteTarget(selectedPet); }}
                    className="rounded-xl border border-red-200 bg-red-50 px-4 py-2 text-sm font-semibold text-red-600 transition hover:bg-red-100"
                  >
                    Delete
                  </button>
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
