import { createClient } from '@supabase/supabase-js';
import VetsClient from './VetsClient';

export const dynamic = 'force-dynamic';

async function getVets() {
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { auth: { persistSession: false } }
  );

  const { data, error } = await supabase
    .from('vet_profiles')
    .select('id, user_id, full_name, phone, specialization, clinic_name, clinic_address, experience, license_number, is_verified, is_available, rating, consultation_fee, created_at')
    .order('created_at', { ascending: false })
    .limit(200);

  if (error) throw error;

  // Enrich with user emails
  const userIds = Array.from(new Set((data ?? []).map((v: { user_id: string }) => v.user_id)));
  const { data: users } = await supabase
    .from('users')
    .select('id, email')
    .in('id', userIds);
  const userMap = Object.fromEntries((users ?? []).map((u: { id: string; email: string | null }) => [u.id, u.email]));

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return (data ?? []).map((v: any) => ({
    ...v,
    name: v.full_name,
    email: userMap[v.user_id] ?? null,
    years_of_experience: v.experience,
  }));
}

export default async function VetsPage() {
  const vets = await getVets();

  const verified = vets.filter((v) => v.is_verified).length;
  const pending = vets.filter((v) => !v.is_verified).length;

  return (
    <div className="p-8">
      <div className="mb-6 flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Veterinarians</h1>
          <p className="mt-1 text-sm text-gray-500">{vets.length} total vets</p>
        </div>
        <div className="flex items-center gap-3">
          <div className="rounded-xl bg-green-50 px-4 py-2 text-sm">
            <span className="font-semibold text-green-700">{verified}</span>
            <span className="ml-1 text-green-600">verified</span>
          </div>
          <div className="rounded-xl bg-yellow-50 px-4 py-2 text-sm">
            <span className="font-semibold text-yellow-700">{pending}</span>
            <span className="ml-1 text-yellow-600">pending</span>
          </div>
        </div>
      </div>

      <VetsClient vets={vets} />
    </div>
  );
}
