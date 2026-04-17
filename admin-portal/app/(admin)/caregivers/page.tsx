export const dynamic = 'force-dynamic';

import { createClient } from '@supabase/supabase-js';
import CaregiversClient from './CaregiversClient';

async function getCaregivers() {
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { auth: { persistSession: false } }
  );

  const { data: caregivers } = await supabase
    .from('caregiver_profiles')
    .select(`
      id,
      bio,
      headline,
      years_of_experience,
      city,
      state,
      country,
      service_radius_km,
      is_verified,
      verification_date,
      background_check_status,
      id_verified,
      pet_first_aid_certified,
      insurance_verified,
      accepted_pet_types,
      accepted_pet_sizes,
      average_rating,
      total_reviews,
      total_bookings,
      completion_rate,
      is_active,
      is_accepting_bookings,
      created_at,
      updated_at,
      owner:users!caregiver_profiles_user_id_fkey(id, display_name, email, avatar_url)
    `)
    .order('created_at', { ascending: false });

  return caregivers ?? [];
}

export default async function CaregiversPage() {
  const caregivers = await getCaregivers();
  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Caregivers</h1>
        <p className="mt-1 text-sm text-gray-500">
          {caregivers.length} registered caregivers · {caregivers.filter((c: any) => !c.is_verified).length} pending verification
        </p>
      </div>
      <CaregiversClient caregivers={caregivers as any} />
    </div>
  );
}
