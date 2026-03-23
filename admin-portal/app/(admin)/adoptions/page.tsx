import { createClient } from '@supabase/supabase-js';
import { timeAgo } from '@/lib/utils';

export const dynamic = 'force-dynamic';
import Badge from '@/components/Badge';

async function getAdoptions() {
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { auth: { persistSession: false } }
  );

  const { data, error } = await supabase
    .from('adoption_listings')
    .select('id, pet_name, pet_type, breed, age, gender, description, status, contact_phone, contact_email, location, created_at, user_id')
    .order('created_at', { ascending: false })
    .limit(200);

  if (error) throw error;

  // Enrich with user data
  const userIds = Array.from(new Set((data ?? []).map((a: { user_id: string }) => a.user_id)));
  const { data: users } = await supabase
    .from('users')
    .select('id, display_name, email')
    .in('id', userIds);
  const userMap = Object.fromEntries((users ?? []).map((u: { id: string; display_name: string | null; email: string | null }) => [u.id, { full_name: u.display_name, email: u.email }]));

  return (data ?? []).map((a: any) => ({
    ...a,
    species: a.pet_type,
    profiles: userMap[a.user_id] ?? null,
  }));
}

const statusMap: Record<string, { label: string; variant: 'success' | 'warning' | 'default' | 'danger' }> = {
  available: { label: 'Available', variant: 'success' },
  pending: { label: 'Pending', variant: 'warning' },
  adopted: { label: 'Adopted', variant: 'default' },
  cancelled: { label: 'Cancelled', variant: 'danger' },
};

export default async function AdoptionsPage() {
  const adoptions = await getAdoptions();

  const available = adoptions.filter((a) => a.status === 'available').length;
  const pending = adoptions.filter((a) => a.status === 'pending').length;
  const adopted = adoptions.filter((a) => a.status === 'adopted').length;

  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Adoptions</h1>
        <p className="mt-1 text-sm text-gray-500">
          {adoptions.length} listings — {available} available, {pending} pending, {adopted} adopted
        </p>
      </div>

      <div className="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-100 bg-gray-50/60">
                {['Pet', 'Species / Breed', 'Location', 'Contact', 'Listed By', 'Status', 'Listed'].map((h) => (
                  <th key={h} className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {adoptions.length === 0 ? (
                <tr>
                  <td colSpan={7} className="py-16 text-center text-sm text-gray-400">
                    No adoption listings found
                  </td>
                </tr>
              ) : (
                adoptions.map((a) => {
                  const statusInfo = statusMap[a.status] ?? { label: a.status, variant: 'default' as const };
                  const profile = a.profiles as { full_name?: string | null; email?: string | null } | null;
                  return (
                    <tr
                      key={a.id}
                      className="border-b border-gray-50 last:border-0 hover:bg-gray-50/50 transition-colors"
                    >
                      <td className="px-4 py-3">
                        <p className="font-medium text-gray-800">{a.pet_name}</p>
                        <p className="text-xs text-gray-400">
                          {a.age ?? '?'} yr{Number(a.age) !== 1 ? 's' : ''}{a.gender ? ` · ${a.gender}` : ''}
                        </p>
                      </td>
                      <td className="px-4 py-3 text-gray-600 capitalize">
                        <p>{a.species || '—'}</p>
                        <p className="text-xs text-gray-400">{a.breed || ''}</p>
                      </td>
                      <td className="px-4 py-3 text-gray-600">{a.location || '—'}</td>
                      <td className="px-4 py-3 text-xs text-gray-500">
                        <p>{a.contact_phone || '—'}</p>
                        <p className="text-gray-400">{a.contact_email || ''}</p>
                      </td>
                      <td className="px-4 py-3 text-xs text-gray-600">
                        {profile?.full_name || profile?.email || 'Unknown'}
                      </td>
                      <td className="px-4 py-3">
                        <Badge variant={statusInfo.variant}>{statusInfo.label}</Badge>
                      </td>
                      <td className="px-4 py-3 text-xs text-gray-400">
                        {timeAgo(a.created_at)}
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
