export const dynamic = 'force-dynamic';

import { createClient } from '@supabase/supabase-js';
import CaregiversClient, { type Caregiver } from './CaregiversClient';

async function getCaregivers() {
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { auth: { persistSession: false } }
  );

  const { data: caregivers, error } = await supabase
    .from('caregiver_profiles')
    .select(`
      id,
      user_id,
      bio,
      headline,
      years_of_experience,
      address,
      city,
      state,
      postal_code,
      country,
      service_radius_km,
      is_verified,
      verification_date,
      background_check_status,
      background_check_date,
      background_check_expiry,
      id_verified,
      pet_first_aid_certified,
      insurance_verified,
      insurance_policy_number,
      accepted_pet_types,
      accepted_pet_sizes,
      max_pets_at_once,
      has_fenced_yard,
      has_own_transport,
      smoke_free_home,
      average_rating,
      total_reviews,
      total_bookings,
      completion_rate,
      response_time_hours,
      is_active,
      is_accepting_bookings,
      created_at,
      updated_at,
      owner:users!caregiver_profiles_user_id_fkey(id, display_name, email, avatar_url)
    `)
    .order('created_at', { ascending: false })
    .limit(300);

  if (error) throw error;
  return caregivers ?? [];
}

export default async function CaregiversPage() {
  const caregivers = await getCaregivers();

  const verified = caregivers.filter((c) => c.is_verified).length;
  const pending  = caregivers.filter((c) => !c.is_verified).length;
  const active   = caregivers.filter((c) => c.is_active).length;

  return (
    <div className="p-8">
      <div
        className="mb-6 overflow-hidden rounded-2xl shadow-md ring-1 ring-black/5"
        style={{ background: 'linear-gradient(135deg, #0B1629 0%, #1a3a38 50%, #2C6E69 100%)' }}
      >
        <div className="px-6 py-5 sm:px-8 sm:py-6">
          <h1 className="text-2xl font-bold tracking-tight text-white sm:text-[1.75rem]">
            Caregivers
          </h1>
          <p className="mt-1.5 text-sm text-white/70">
            {caregivers.length} registered · {verified} verified · {pending} pending · {active} active
          </p>
        </div>
      </div>
      <CaregiversClient caregivers={caregivers as unknown as Caregiver[]} />
    </div>
  );
}
