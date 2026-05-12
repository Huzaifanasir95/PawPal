export const dynamic = 'force-dynamic';

import { createClient } from '@supabase/supabase-js';
import LostFoundClient from './LostFoundClient';

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
    .limit(300);

  if (error) throw error;

  const userIds = Array.from(new Set((data ?? []).map((i: { user_id: string }) => i.user_id)));
  const { data: users } = await supabase
    .from('users')
    .select('id, display_name, email, avatar_url')
    .in('id', userIds);
  const userMap = Object.fromEntries(
    (users ?? []).map((u: { id: string; display_name: string | null; email: string | null; avatar_url: string | null }) => [
      u.id,
      { name: u.display_name, email: u.email, avatar_url: u.avatar_url },
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

  const lost   = items.filter((i) => i.type === 'lost').length;
  const found  = items.filter((i) => i.type === 'found').length;
  const open   = items.filter((i) => i.status === 'open').length;

  return (
    <div className="p-8">
      <div
        className="mb-6 overflow-hidden rounded-2xl shadow-md ring-1 ring-black/5"
        style={{ background: 'linear-gradient(135deg, #0B1629 0%, #1a3a38 50%, #2C6E69 100%)' }}
      >
        <div className="px-6 py-5 sm:px-8 sm:py-6">
          <h1 className="text-2xl font-bold tracking-tight text-white sm:text-[1.75rem]">
            Lost &amp; Found
          </h1>
          <p className="mt-1.5 text-sm text-white/70">
            {items.length} reports · {lost} lost · {found} found · {open} still open
          </p>
        </div>
      </div>
      <LostFoundClient items={items} />
    </div>
  );
}
