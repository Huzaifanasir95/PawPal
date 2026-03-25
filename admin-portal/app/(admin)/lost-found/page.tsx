import { createClient } from '@supabase/supabase-js';
import LostFoundClient from './LostFoundClient';

export const dynamic = 'force-dynamic';

async function getLostFound() {
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { auth: { persistSession: false } }
  );

  const { data, error } = await supabase
    .from('lost_found_posts')
    .select('id, type, pet_name, pet_type, breed, description, last_seen_location, status, urgency, contact_phone, contact_email, image_urls, created_at, user_id')
    .order('created_at', { ascending: false })
    .limit(200);

  if (error) throw error;

  const userIds = Array.from(new Set((data ?? []).map((i: { user_id: string }) => i.user_id)));
  const { data: users } = await supabase
    .from('users')
    .select('id, display_name, email')
    .in('id', userIds);
  const userMap = Object.fromEntries(
    (users ?? []).map((u: { id: string; display_name: string | null; email: string | null }) => [
      u.id,
      { name: u.display_name, email: u.email },
    ])
  );

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return (data ?? []).map((i: any) => ({
    ...i,
    reporter: userMap[i.user_id] ?? null,
  }));
}

export default async function LostFoundPage() {
  const items = await getLostFound();
  return <LostFoundClient items={items} />;
}
