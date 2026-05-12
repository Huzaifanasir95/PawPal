'use server';

import { createClient } from '@supabase/supabase-js';

function getSupabase() {
  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { auth: { persistSession: false } }
  );
}

export type PrefetchedVet = {
  id: string;
  user_id: string;
  name: string;
  email: string | null;
  phone: string | null;
  /** May be string, string[], or JSON from DB */
  specialization: unknown;
  clinic_name: string | null;
  clinic_address: string | null;
  years_of_experience: number | null;
  license_number: string | null;
  is_verified: boolean;
  is_available: boolean | null;
  rating: number | null;
  consultation_fee: number | null;
  currency: string | null;
  created_at: string;
  linked_user: {
    display_name: string | null;
    email: string | null;
    avatar_url: string | null;
  } | null;
};

/** Hover prefetch for the detail modal (vets-only). */
export async function prefetchVetForModal(vetId: string): Promise<PrefetchedVet | null> {
  try {
    const supabase = getSupabase();
    const { data: row, error } = await supabase
      .from('vet_profiles')
      .select(
        'id, user_id, full_name, phone, specialization, clinic_name, clinic_address, experience, license_number, is_verified, is_available, rating, consultation_fee, currency, created_at'
      )
      .eq('id', vetId)
      .maybeSingle();
    if (error || !row) return null;

    const { data: user } = await supabase
      .from('users')
      .select('id, email, display_name, avatar_url')
      .eq('id', row.user_id)
      .maybeSingle();

    return {
      id: row.id,
      user_id: row.user_id,
      name: row.full_name ?? '—',
      email: user?.email ?? null,
      phone: row.phone ?? null,
      specialization: row.specialization ?? null,
      clinic_name: row.clinic_name ?? null,
      clinic_address: row.clinic_address ?? null,
      years_of_experience: row.experience ?? null,
      license_number: row.license_number ?? null,
      is_verified: row.is_verified === true,
      is_available: row.is_available,
      rating: row.rating ?? null,
      consultation_fee: row.consultation_fee ?? null,
      currency: row.currency ?? null,
      created_at: row.created_at,
      linked_user: user
        ? {
            display_name: user.display_name ?? null,
            email: user.email ?? null,
            avatar_url: user.avatar_url ?? null,
          }
        : null,
    };
  } catch {
    return null;
  }
}
