import { createClient } from '@supabase/supabase-js';
import PetsClient from './PetsClient';

export const dynamic = 'force-dynamic';

async function getPets() {
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { auth: { persistSession: false } }
  );

  const { data, error } = await supabase
    .from('pets')
    .select('id, owner_id, name, type, breed, age, age_unit, gender, color, weight, weight_unit, image_url, image_urls, is_verified, verification_confidence, verified_breed, bio, is_adopted, created_at, updated_at')
    .order('created_at', { ascending: false })
    .limit(300);

  if (error) throw error;

  // Enrich with owner data
  const ownerIds = Array.from(new Set((data ?? []).map((p: { owner_id: string }) => p.owner_id)));
  const { data: users } = await supabase
    .from('users')
    .select('id, display_name, email')
    .in('id', ownerIds);
  const userMap = Object.fromEntries(
    (users ?? []).map((u: { id: string; display_name: string | null; email: string | null }) => [
      u.id,
      { name: u.display_name, email: u.email },
    ])
  );

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return (data ?? []).map((p: any) => ({
    ...p,
    owner: userMap[p.owner_id] ?? null,
  }));
}

export default async function PetsPage() {
  const pets = await getPets();
  return <PetsClient pets={pets} />;
}
