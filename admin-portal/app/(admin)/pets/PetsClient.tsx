'use client';

import { useState, useTransition } from 'react';
import Badge from '@/components/Badge';
import { Search, Eye, Trash2, X, ShieldCheck } from 'lucide-react';
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

function InfoItem({ label, value }: { label: string; value: string | null | undefined }) {
  return (
    <div>
      <p className="text-xs text-gray-400">{label}</p>
      <p className="text-sm font-medium text-gray-700">{value || '—'}</p>
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

      {/* Search + Type Filter */}
      <div className="mb-4 flex flex-wrap items-center gap-3">
        <div className="relative flex-1 min-w-[220px]">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search name, breed, color, owner…"
            className="w-full rounded-xl border border-gray-200 bg-white py-2 pl-10 pr-4 text-sm focus:border-[#2C6E69] focus:outline-none focus:ring-1 focus:ring-[#2C6E69]"
          />
        </div>
        {TYPE_OPTIONS.map((t) => (
          <button
            key={t}
            onClick={() => setTypeFilter(t)}
            className={`rounded-lg px-3 py-1.5 text-xs font-medium transition-colors ${
              typeFilter === t
                ? 'bg-[#2C6E69] text-white'
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            {t === 'all' ? 'All' : t === 'dog' ? '🐕 Dogs' : '🐈 Cats'} ({counts[t]})
          </button>
        ))}
      </div>

      {/* Verified Filter */}
      <div className="mb-4 flex flex-wrap gap-2">
        {(['all', 'verified', 'unverified'] as const).map((v) => (
          <button
            key={v}
            onClick={() => setVerifiedFilter(v)}
            className={`rounded-lg px-3 py-1.5 text-xs font-medium transition-colors ${
              verifiedFilter === v
                ? 'bg-[#2C6E69] text-white'
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            {v === 'all' ? `All (${counts.all})` : v === 'verified' ? `✅ Verified (${counts.verified})` : `Unverified (${counts.unverified})`}
          </button>
        ))}
      </div>

      {/* Table */}
      <div className="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-100 bg-gray-50/60">
                {['Pet', 'Type', 'Breed', 'Age', 'Owner', 'Verified', 'Status', 'Added', 'Actions'].map((h) => (
                  <th key={h} className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr>
                  <td colSpan={9} className="py-16 text-center text-sm text-gray-400">
                    No pets found
                  </td>
                </tr>
              ) : (
                filtered.map((pet) => (
                  <tr key={pet.id} className="border-b border-gray-50 last:border-0 hover:bg-gray-50/50 transition-colors">
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-3">
                        {pet.image_url ? (
                          <img src={pet.image_url} alt={pet.name} className="h-9 w-9 rounded-full object-cover" />
                        ) : (
                          <div className="flex h-9 w-9 items-center justify-center rounded-full bg-[#B3E0DB] text-sm font-bold text-[#2C6E69]">
                            {pet.type === 'dog' ? '🐕' : '🐈'}
                          </div>
                        )}
                        <div>
                          <p className="font-medium text-gray-800">{pet.name}</p>
                          <p className="text-xs text-gray-400 capitalize">{pet.gender} · {pet.color}</p>
                        </div>
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      <Badge variant={pet.type === 'dog' ? 'warning' : 'default'}>
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
                      {pet.is_verified ? (
                        <Badge variant="success">
                          <ShieldCheck className="mr-1 inline h-3 w-3" />
                          Verified
                        </Badge>
                      ) : (
                        <Badge variant="default">Unverified</Badge>
                      )}
                    </td>
                    <td className="px-4 py-3">
                      {pet.is_adopted ? (
                        <Badge variant="warning">Adopted</Badge>
                      ) : (
                        <Badge variant="success">Active</Badge>
                      )}
                    </td>
                    <td className="px-4 py-3 text-xs text-gray-400">{timeAgo(pet.created_at)}</td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-1">
                        <button onClick={() => setSelectedPet(pet)} className="rounded-lg p-1.5 text-gray-400 hover:bg-gray-100 hover:text-[#2C6E69]">
                          <Eye className="h-4 w-4" />
                        </button>
                        <button onClick={() => setDeleteTarget(pet)} className="rounded-lg p-1.5 text-gray-400 hover:bg-red-50 hover:text-red-500">
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
      {selectedPet && (
        <div className="fixed inset-0 z-50 flex justify-end">
          <div className="absolute inset-0 bg-black/20" onClick={() => setSelectedPet(null)} />
          <div className="relative w-full max-w-lg overflow-y-auto bg-white shadow-2xl">
            <div className="sticky top-0 z-10 flex items-center justify-between border-b bg-white px-6 py-4">
              <div>
                <h2 className="text-lg font-bold text-gray-900">{selectedPet.name}</h2>
                <div className="mt-1 flex items-center gap-2">
                  <Badge variant={selectedPet.type === 'dog' ? 'warning' : 'default'}>
                    {selectedPet.type === 'dog' ? '🐕 Dog' : '🐈 Cat'}
                  </Badge>
                  {selectedPet.is_verified && (
                    <Badge variant="success">
                      <ShieldCheck className="mr-1 inline h-3 w-3" />
                      Verified
                    </Badge>
                  )}
                  {selectedPet.is_adopted && <Badge variant="warning">Adopted</Badge>}
                </div>
              </div>
              <button onClick={() => setSelectedPet(null)} className="rounded-lg p-2 hover:bg-gray-100">
                <X className="h-5 w-5" />
              </button>
            </div>

            <div className="space-y-6 p-6">
              {/* Image */}
              {(selectedPet.image_url || (selectedPet.image_urls && selectedPet.image_urls.length > 0)) && (
                <div className="grid grid-cols-2 gap-2">
                  {selectedPet.image_url && (
                    <img src={selectedPet.image_url} alt={selectedPet.name} className="h-40 w-full rounded-lg object-cover" />
                  )}
                  {selectedPet.image_urls?.map((url, i) => (
                    <img key={i} src={url} alt={`Photo ${i + 1}`} className="h-40 w-full rounded-lg object-cover" />
                  ))}
                </div>
              )}

              {/* Bio */}
              {selectedPet.bio && (
                <div>
                  <p className="mb-1 text-xs font-semibold uppercase text-gray-400">Bio</p>
                  <p className="rounded-lg bg-gray-50 p-3 text-sm text-gray-700 whitespace-pre-wrap">{selectedPet.bio}</p>
                </div>
              )}

              {/* Info Grid */}
              <div className="grid grid-cols-2 gap-4">
                <InfoItem label="Breed" value={selectedPet.breed} />
                <InfoItem label="Age" value={`${selectedPet.age} ${selectedPet.age_unit}`} />
                <InfoItem label="Gender" value={selectedPet.gender} />
                <InfoItem label="Color" value={selectedPet.color} />
                <InfoItem label="Weight" value={`${selectedPet.weight} ${selectedPet.weight_unit}`} />
                <InfoItem label="Owner" value={selectedPet.owner?.name || selectedPet.owner?.email || 'Unknown'} />
                <InfoItem label="Added" value={formatDateTime(selectedPet.created_at)} />
                <InfoItem label="Updated" value={formatDateTime(selectedPet.updated_at)} />
              </div>

              {/* Verification Info */}
              {selectedPet.is_verified && (
                <div>
                  <p className="mb-2 text-xs font-semibold uppercase text-gray-400">AI Verification</p>
                  <div className="grid grid-cols-2 gap-4">
                    <InfoItem label="Verified Breed" value={selectedPet.verified_breed} />
                    <InfoItem
                      label="Confidence"
                      value={
                        selectedPet.verification_confidence != null
                          ? `${(selectedPet.verification_confidence * 100).toFixed(1)}%`
                          : null
                      }
                    />
                  </div>
                </div>
              )}

              {/* Meta */}
              <p className="text-xs text-gray-300">ID: {selectedPet.id}</p>

              {/* Delete */}
              <button
                onClick={() => { setSelectedPet(null); setDeleteTarget(selectedPet); }}
                className="w-full rounded-xl bg-red-50 py-2.5 text-sm font-medium text-red-600 hover:bg-red-100 transition-colors"
              >
                Delete Pet
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Delete Modal */}
      {deleteTarget && (
        <div className="fixed inset-0 z-50 flex items-center justify-center">
          <div className="absolute inset-0 bg-black/30" onClick={() => setDeleteTarget(null)} />
          <div className="relative w-full max-w-sm rounded-2xl bg-white p-6 shadow-2xl">
            <h3 className="text-lg font-bold text-gray-900">Delete Pet</h3>
            <p className="mt-2 text-sm text-gray-500">
              Permanently delete <strong>{deleteTarget.name}</strong> ({deleteTarget.breed})? This will also remove associated health records. This cannot be undone.
            </p>
            <div className="mt-5 flex gap-3">
              <button onClick={() => setDeleteTarget(null)} className="flex-1 rounded-xl border border-gray-200 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50">
                Cancel
              </button>
              <button
                disabled={isPending}
                onClick={() => handleDelete(deleteTarget.id)}
                className="flex-1 rounded-xl bg-red-600 py-2 text-sm font-medium text-white hover:bg-red-700 disabled:opacity-50"
              >
                {isPending ? 'Deleting…' : 'Delete'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
