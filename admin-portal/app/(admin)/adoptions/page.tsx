import { createClient } from '@supabase/supabase-js';
import AdoptionsClient from './AdoptionsClient';

export const dynamic = 'force-dynamic';

async function getAdoptions() {
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { auth: { persistSession: false } }
  );

  const { data, error } = await supabase
    .from('adoption_listings')
    .select('id, pet_name, pet_type, breed, age, gender, size, description, status, contact_phone, contact_email, location, adoption_fee, image_urls, created_at, user_id')
    .order('created_at', { ascending: false })
    .limit(200);

  if (error) throw error;

  const userIds = Array.from(new Set((data ?? []).map((a: { user_id: string }) => a.user_id)));
  const { data: users } = await supabase
    .from('users')
    .select('id, display_name, email')
    .in('id', userIds);
  const userMap = Object.fromEntries((users ?? []).map((u: { id: string; display_name: string | null; email: string | null }) => [u.id, { name: u.display_name, email: u.email }]));

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return (data ?? []).map((a: any) => ({
    ...a,
    lister: userMap[a.user_id] ?? null,
  }));
}

export default async function AdoptionsPage() {
  const adoptions = await getAdoptions();

  return <AdoptionsClient adoptions={adoptions} />;
}
