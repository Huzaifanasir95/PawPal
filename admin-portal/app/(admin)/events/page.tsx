export const dynamic = 'force-dynamic';

import { createClient } from '@supabase/supabase-js';
import EventsClient from './EventsClient';

async function getEvents() {
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { auth: { persistSession: false } }
  );

  const { data, error } = await supabase
    .from('events')
    .select('id, title, description, event_type, location, start_date, end_date, max_attendees, rsvp_count, status, created_at, organizer_id')
    .order('start_date', { ascending: false })
    .limit(300);

  if (error) throw error;

  const organizerIds = Array.from(new Set((data ?? []).map((e: { organizer_id: string }) => e.organizer_id)));
  const { data: organizers } = await supabase
    .from('users')
    .select('id, display_name, email, avatar_url')
    .in('id', organizerIds);
  const organizerMap = Object.fromEntries(
    (organizers ?? []).map((o: { id: string; display_name: string | null; email: string | null; avatar_url: string | null }) => [
      o.id,
      { name: o.display_name, email: o.email, avatar_url: o.avatar_url },
    ])
  );

  const eventIds = (data ?? []).map((e: { id: string }) => e.id);
  const { data: rsvps } = await supabase
    .from('event_rsvps')
    .select('id, event_id, user_id, status, created_at')
    .in('event_id', eventIds);

  const rsvpUserIds = Array.from(new Set((rsvps ?? []).map((r: { user_id: string }) => r.user_id)));
  const missingUserIds = rsvpUserIds.filter((id) => !organizerMap[id]);
  if (missingUserIds.length > 0) {
    const { data: moreUsers } = await supabase
      .from('users')
      .select('id, display_name, email, avatar_url')
      .in('id', missingUserIds);
    (moreUsers ?? []).forEach((u: { id: string; display_name: string | null; email: string | null; avatar_url: string | null }) => {
      organizerMap[u.id] = { name: u.display_name, email: u.email, avatar_url: u.avatar_url };
    });
  }

  const rsvpsByEvent: Record<string, Array<{ id: string; user_name: string; status: string; created_at: string }>> = {};
  (rsvps ?? []).forEach((r: { id: string; event_id: string; user_id: string; status: string | null; created_at: string }) => {
    if (!rsvpsByEvent[r.event_id]) rsvpsByEvent[r.event_id] = [];
    const u = organizerMap[r.user_id];
    rsvpsByEvent[r.event_id].push({
      id: r.id,
      user_name: u?.name || u?.email || 'Unknown',
      status: r.status ?? 'confirmed',
      created_at: r.created_at,
    });
  });

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return (data ?? []).map((e: any) => ({
    ...e,
    organizer: organizerMap[e.organizer_id] ?? null,
    rsvps: rsvpsByEvent[e.id] ?? [],
  }));
}

export default async function EventsPage() {
  const events = await getEvents();

  const upcoming = events.filter((e) => {
    if (e.status === 'cancelled') return false;
    return e.start_date && new Date(e.start_date) >= new Date();
  }).length;
  const cancelled = events.filter((e) => e.status === 'cancelled').length;
  const totalRsvps = events.reduce((sum, e) => sum + (e.rsvp_count ?? 0), 0);

  return (
    <div className="p-8">
      <div
        className="mb-6 overflow-hidden rounded-2xl shadow-md ring-1 ring-black/5"
        style={{ background: 'linear-gradient(135deg, #0B1629 0%, #1a3a38 50%, #2C6E69 100%)' }}
      >
        <div className="px-6 py-5 sm:px-8 sm:py-6">
          <h1 className="text-2xl font-bold tracking-tight text-white sm:text-[1.75rem]">
            Events
          </h1>
          <p className="mt-1.5 text-sm text-white/70">
            {events.length} events · {upcoming} upcoming · {cancelled} cancelled · {totalRsvps} total RSVPs
          </p>
        </div>
      </div>
      <EventsClient events={events} />
    </div>
  );
}
