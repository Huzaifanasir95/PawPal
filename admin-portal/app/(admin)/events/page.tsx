import { createClient } from '@supabase/supabase-js';
import { formatDateTime } from '@/lib/utils';

export const dynamic = 'force-dynamic';
import Badge from '@/components/Badge';
import { MapPin, Users, Calendar } from 'lucide-react';

async function getEvents() {
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { auth: { persistSession: false } }
  );

  const { data, error } = await supabase
    .from('events')
    .select('id, title, description, location, event_date, max_attendees, rsvp_count, status, created_at, organizer_id')
    .order('event_date', { ascending: true })
    .limit(100);

  if (error) throw error;

  // Enrich with organizer data
  const organizerIds = Array.from(new Set((data ?? []).map((e: { organizer_id: string }) => e.organizer_id)));
  const { data: organizers } = await supabase
    .from('users')
    .select('id, display_name, email')
    .in('id', organizerIds);
  const organizerMap = Object.fromEntries((organizers ?? []).map((o: { id: string; display_name: string | null; email: string | null }) => [o.id, { full_name: o.display_name, email: o.email }]));

  return (data ?? []).map((e: any) => ({
    ...e,
    profiles: organizerMap[e.organizer_id] ?? null,
  }));
}

function getEventStatus(eventDate: string, status?: string | null) {
  if (status === 'cancelled') return { label: 'Cancelled', variant: 'danger' as const };
  const now = new Date();
  const date = new Date(eventDate);
  if (date < now) return { label: 'Past', variant: 'default' as const };
  const diff = date.getTime() - now.getTime();
  if (diff < 86400000 * 3) return { label: 'Soon', variant: 'warning' as const };
  return { label: 'Upcoming', variant: 'success' as const };
}

export default async function EventsPage() {
  const events = await getEvents();

  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Events</h1>
        <p className="mt-1 text-sm text-gray-500">
          {events.length} total events
        </p>
      </div>

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
        {events.length === 0 && (
          <p className="col-span-3 py-16 text-center text-sm text-gray-400">No events found</p>
        )}
        {events.map((e) => {
          const status = getEventStatus(e.event_date, e.status);
          const attendees = e.rsvp_count ?? 0;
          const max = e.max_attendees;
          const fillPct = max ? Math.min((attendees / max) * 100, 100) : 0;

          return (
            <div
              key={e.id}
              className="rounded-2xl border border-gray-100 bg-white p-5 shadow-sm hover:shadow-md transition-shadow"
            >
              <div className="mb-3 flex items-start justify-between gap-2">
                <h3 className="font-semibold text-gray-900 leading-snug">{e.title}</h3>
                <Badge variant={status.variant}>{status.label}</Badge>
              </div>

              {e.description && (
                <p className="mb-3 text-xs text-gray-500 line-clamp-2">{e.description}</p>
              )}

              <div className="space-y-2 text-xs text-gray-500">
                <div className="flex items-center gap-1.5">
                  <Calendar className="h-3.5 w-3.5 flex-shrink-0" />
                  {formatDateTime(e.event_date)}
                </div>
                {e.location && (
                  <div className="flex items-center gap-1.5">
                    <MapPin className="h-3.5 w-3.5 flex-shrink-0" />
                    {e.location}
                  </div>
                )}
                <div className="flex items-center gap-1.5">
                  <Users className="h-3.5 w-3.5 flex-shrink-0" />
                  {attendees}{max ? ` / ${max}` : ''} attendees
                </div>
              </div>

              {max ? (
                <div className="mt-3">
                  <div className="h-1.5 w-full overflow-hidden rounded-full bg-gray-100">
                    <div
                      className="h-full rounded-full bg-[#2C6E69] transition-all"
                      style={{ width: `${fillPct}%` }}
                    />
                  </div>
                  <p className="mt-1 text-right text-[10px] text-gray-400">
                    {Math.round(fillPct)}% full
                  </p>
                </div>
              ) : null}

              <div className="mt-3 border-t border-gray-50 pt-3">
                <p className="text-[11px] text-gray-400">
                  Organizer:{' '}
                  <span className="font-medium text-gray-600">
                    {(e.profiles as { full_name?: string | null; email?: string | null } | null)?.full_name ||
                      (e.profiles as { full_name?: string | null; email?: string | null } | null)?.email ||
                      'Unknown'}
                  </span>
                </p>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
