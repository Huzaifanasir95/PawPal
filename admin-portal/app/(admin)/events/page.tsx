import { createClient } from '@supabase/supabase-js';
import EventsClient from './EventsClient';

export const dynamic = 'force-dynamic';

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
    .limit(200);

  if (error) throw error;

  // Enrich with organizer data
  const organizerIds = Array.from(new Set((data ?? []).map((e: { organizer_id: string }) => e.organizer_id)));
  const { data: organizers } = await supabase
    .from('users')
    .select('id, display_name, email')
    .in('id', organizerIds);
  const organizerMap = Object.fromEntries((organizers ?? []).map((o: { id: string; display_name: string | null; email: string | null }) => [o.id, { name: o.display_name, email: o.email }]));

  // Fetch RSVPs
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
      .select('id, display_name, email')
      .in('id', missingUserIds);
    (moreUsers ?? []).forEach((u: { id: string; display_name: string | null; email: string | null }) => {
      organizerMap[u.id] = { name: u.display_name, email: u.email };
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

  return <EventsClient events={events} />;
}
