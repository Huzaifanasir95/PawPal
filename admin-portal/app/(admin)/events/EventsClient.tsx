'use client';

import { useState, useMemo, useTransition } from 'react';
import { Search, Trash2, Eye, X, MapPin, Users, Calendar } from 'lucide-react';
import { formatDateTime, timeAgo } from '@/lib/utils';
import Badge from '@/components/Badge';
import { deleteEvent, updateEventStatus } from '@/lib/admin-actions';

interface RSVP {
  id: string;
  user_name: string;
  status: string;
  created_at: string;
}

interface Event {
  id: string;
  title: string;
  description: string | null;
  event_type: string | null;
  location: string | null;
  start_date: string | null;
  end_date: string | null;
  max_attendees: number | null;
  rsvp_count: number | null;
  status: string | null;
  created_at: string;
  organizer_id: string;
  organizer: { name: string | null; email: string | null } | null;
  rsvps: RSVP[];
}

type StatusFilter = 'all' | 'upcoming' | 'past' | 'cancelled';

function getEventStatus(startDate: string | null, status?: string | null) {
  if (status === 'cancelled') return { label: 'Cancelled', variant: 'danger' as const };
  if (!startDate) return { label: 'Unknown', variant: 'default' as const };
  const now = new Date();
  const date = new Date(startDate);
  if (date < now) return { label: 'Past', variant: 'default' as const };
  const diff = date.getTime() - now.getTime();
  if (diff < 86400000 * 3) return { label: 'Soon', variant: 'warning' as const };
  return { label: 'Upcoming', variant: 'success' as const };
}

export default function EventsClient({ events: initialEvents }: { events: Event[] }) {
  const [events, setEvents] = useState(initialEvents);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<StatusFilter>('all');
  const [selectedEvent, setSelectedEvent] = useState<Event | null>(null);
  const [isPending, startTransition] = useTransition();
  const [deleteTarget, setDeleteTarget] = useState<Event | null>(null);

  const filtered = useMemo(() => {
    return events.filter((e) => {
      const matchesSearch =
        e.title.toLowerCase().includes(search.toLowerCase()) ||
        (e.location?.toLowerCase() ?? '').includes(search.toLowerCase()) ||
        (e.organizer?.name?.toLowerCase() ?? '').includes(search.toLowerCase());
      if (!matchesSearch) return false;
      if (statusFilter === 'all') return true;
      const s = getEventStatus(e.start_date, e.status);
      if (statusFilter === 'cancelled') return s.label === 'Cancelled';
      if (statusFilter === 'past') return s.label === 'Past';
      if (statusFilter === 'upcoming') return s.label === 'Upcoming' || s.label === 'Soon';
      return true;
    });
  }, [events, search, statusFilter]);

  function handleDelete(event: Event) {
    startTransition(async () => {
      const res = await deleteEvent(event.id);
      if (res.success) {
        setEvents((prev) => prev.filter((e) => e.id !== event.id));
        setDeleteTarget(null);
        setSelectedEvent(null);
      } else {
        alert('Failed to delete event: ' + res.error);
      }
    });
  }

  function handleStatusChange(eventId: string, newStatus: string) {
    startTransition(async () => {
      const res = await updateEventStatus(eventId, newStatus);
      if (res.success) {
        setEvents((prev) => prev.map((e) => (e.id === eventId ? { ...e, status: newStatus } : e)));
        if (selectedEvent?.id === eventId) {
          setSelectedEvent((prev) => prev ? { ...prev, status: newStatus } : null);
        }
      } else {
        alert('Failed to update status: ' + res.error);
      }
    });
  }

  const filterButtons: { key: StatusFilter; label: string }[] = [
    { key: 'all', label: `All (${events.length})` },
    { key: 'upcoming', label: 'Upcoming' },
    { key: 'past', label: 'Past' },
    { key: 'cancelled', label: 'Cancelled' },
  ];

  return (
    <>
      {/* Filters */}
      <div className="mb-4 flex flex-wrap items-center gap-3">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
          <input
            type="text"
            placeholder="Search events..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-64 rounded-xl border border-gray-200 bg-white py-2 pl-9 pr-4 text-sm text-gray-700 outline-none focus:border-[#2C6E69] focus:ring-1 focus:ring-[#2C6E69]"
          />
        </div>
        <div className="flex gap-1 rounded-xl border border-gray-200 bg-white p-1">
          {filterButtons.map((btn) => (
            <button
              key={btn.key}
              onClick={() => setStatusFilter(btn.key)}
              className={`rounded-lg px-3 py-1.5 text-xs font-medium transition-colors ${
                statusFilter === btn.key ? 'bg-[#2C6E69] text-white' : 'text-gray-500 hover:text-gray-700'
              }`}
            >
              {btn.label}
            </button>
          ))}
        </div>
      </div>

      {/* Card Grid */}
      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
        {filtered.length === 0 && (
          <p className="col-span-3 py-16 text-center text-sm text-gray-400">No events found</p>
        )}
        {filtered.map((e) => {
          const status = getEventStatus(e.start_date, e.status);
          const attendees = e.rsvp_count ?? 0;
          const max = e.max_attendees;
          const fillPct = max ? Math.min((attendees / max) * 100, 100) : 0;

          return (
            <div key={e.id} className="rounded-2xl border border-gray-100 bg-white p-5 shadow-sm hover:shadow-md transition-shadow">
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
                  {e.start_date ? formatDateTime(e.start_date) : '—'}
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
                    <div className="h-full rounded-full bg-[#2C6E69] transition-all" style={{ width: `${fillPct}%` }} />
                  </div>
                  <p className="mt-1 text-right text-[10px] text-gray-400">{Math.round(fillPct)}% full</p>
                </div>
              ) : null}

              <div className="mt-3 border-t border-gray-50 pt-3 flex items-center justify-between">
                <p className="text-[11px] text-gray-400">
                  Organizer: <span className="font-medium text-gray-600">{e.organizer?.name || e.organizer?.email || 'Unknown'}</span>
                </p>
                <div className="flex gap-1">
                  <button onClick={() => setSelectedEvent(e)} className="rounded-lg p-1.5 text-gray-400 hover:bg-gray-100 hover:text-[#2C6E69] transition-colors" title="View details">
                    <Eye className="h-4 w-4" />
                  </button>
                  <button onClick={() => setDeleteTarget(e)} className="rounded-lg p-1.5 text-gray-400 hover:bg-red-50 hover:text-red-500 transition-colors" title="Delete event">
                    <Trash2 className="h-4 w-4" />
                  </button>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {/* Detail Drawer */}
      {selectedEvent && (
        <div className="fixed inset-0 z-50 flex justify-end">
          <div className="absolute inset-0 bg-black/20" onClick={() => setSelectedEvent(null)} />
          <div className="relative w-full max-w-lg bg-white shadow-xl overflow-y-auto">
            <div className="sticky top-0 flex items-center justify-between border-b bg-white px-6 py-4 z-10">
              <h2 className="text-lg font-semibold text-gray-800">Event Details</h2>
              <button onClick={() => setSelectedEvent(null)} className="rounded-lg p-1.5 hover:bg-gray-100 transition-colors">
                <X className="h-5 w-5 text-gray-500" />
              </button>
            </div>
            <div className="p-6 space-y-6">
              <div>
                <h3 className="text-xl font-bold text-gray-900">{selectedEvent.title}</h3>
                <div className="mt-2 flex items-center gap-2">
                  <Badge variant={getEventStatus(selectedEvent.start_date, selectedEvent.status).variant}>
                    {getEventStatus(selectedEvent.start_date, selectedEvent.status).label}
                  </Badge>
                  {selectedEvent.event_type && (
                    <Badge variant="info">{selectedEvent.event_type}</Badge>
                  )}
                </div>
              </div>

              {selectedEvent.description && (
                <div className="rounded-xl bg-gray-50 p-4">
                  <p className="text-sm text-gray-700 whitespace-pre-wrap">{selectedEvent.description}</p>
                </div>
              )}

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <p className="text-xs font-medium text-gray-400 uppercase tracking-wide">Start</p>
                  <p className="mt-0.5 text-sm text-gray-700">{selectedEvent.start_date ? formatDateTime(selectedEvent.start_date) : '—'}</p>
                </div>
                <div>
                  <p className="text-xs font-medium text-gray-400 uppercase tracking-wide">End</p>
                  <p className="mt-0.5 text-sm text-gray-700">{selectedEvent.end_date ? formatDateTime(selectedEvent.end_date) : '—'}</p>
                </div>
                <div>
                  <p className="text-xs font-medium text-gray-400 uppercase tracking-wide">Location</p>
                  <p className="mt-0.5 text-sm text-gray-700">{selectedEvent.location || '—'}</p>
                </div>
                <div>
                  <p className="text-xs font-medium text-gray-400 uppercase tracking-wide">Organizer</p>
                  <p className="mt-0.5 text-sm text-gray-700">{selectedEvent.organizer?.name || selectedEvent.organizer?.email || 'Unknown'}</p>
                </div>
                <div>
                  <p className="text-xs font-medium text-gray-400 uppercase tracking-wide">Attendees</p>
                  <p className="mt-0.5 text-sm text-gray-700">{selectedEvent.rsvp_count ?? 0}{selectedEvent.max_attendees ? ` / ${selectedEvent.max_attendees}` : ''}</p>
                </div>
                <div>
                  <p className="text-xs font-medium text-gray-400 uppercase tracking-wide">Created</p>
                  <p className="mt-0.5 text-sm text-gray-700">{formatDateTime(selectedEvent.created_at)}</p>
                </div>
              </div>

              {/* Status Change */}
              <div>
                <p className="text-xs font-medium text-gray-400 uppercase tracking-wide mb-2">Change Status</p>
                <div className="flex gap-2">
                  {['active', 'cancelled'].map((s) => (
                    <button
                      key={s}
                      disabled={isPending || selectedEvent.status === s}
                      onClick={() => handleStatusChange(selectedEvent.id, s)}
                      className={`rounded-lg px-3 py-1.5 text-xs font-medium transition-colors capitalize disabled:opacity-40 ${
                        selectedEvent.status === s
                          ? 'bg-[#2C6E69] text-white'
                          : 'border border-gray-200 text-gray-600 hover:bg-gray-50'
                      }`}
                    >
                      {s}
                    </button>
                  ))}
                </div>
              </div>

              {/* RSVPs */}
              <div>
                <p className="text-xs font-medium text-gray-400 uppercase tracking-wide mb-3">
                  RSVPs ({selectedEvent.rsvps.length})
                </p>
                {selectedEvent.rsvps.length === 0 ? (
                  <p className="text-sm text-gray-400">No RSVPs yet</p>
                ) : (
                  <div className="space-y-2 max-h-60 overflow-y-auto">
                    {selectedEvent.rsvps.map((r) => (
                      <div key={r.id} className="flex items-center justify-between rounded-lg border border-gray-100 px-3 py-2">
                        <span className="text-sm text-gray-700">{r.user_name}</span>
                        <div className="flex items-center gap-2">
                          <Badge variant={r.status === 'confirmed' ? 'success' : r.status === 'cancelled' ? 'danger' : 'default'}>{r.status}</Badge>
                          <span className="text-xs text-gray-400">{timeAgo(r.created_at)}</span>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>

              <div className="text-xs text-gray-400 break-all">
                <span className="font-medium text-gray-500">ID:</span> {selectedEvent.id}
              </div>

              <button
                onClick={() => { setSelectedEvent(null); setDeleteTarget(selectedEvent); }}
                className="w-full rounded-xl border border-red-200 py-2.5 text-sm font-medium text-red-600 hover:bg-red-50 transition-colors"
              >
                Delete Event
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Delete Confirmation */}
      {deleteTarget && (
        <div className="fixed inset-0 z-[60] flex items-center justify-center">
          <div className="absolute inset-0 bg-black/30" onClick={() => !isPending && setDeleteTarget(null)} />
          <div className="relative w-full max-w-sm rounded-2xl bg-white p-6 shadow-xl">
            <h3 className="text-lg font-semibold text-gray-800">Delete Event?</h3>
            <p className="mt-2 text-sm text-gray-500">
              This will permanently delete <strong>{deleteTarget.title}</strong> and all RSVPs. This cannot be undone.
            </p>
            <div className="mt-6 flex gap-3">
              <button disabled={isPending} onClick={() => setDeleteTarget(null)} className="flex-1 rounded-xl border border-gray-200 py-2.5 text-sm font-medium text-gray-600 hover:bg-gray-50 transition-colors disabled:opacity-50">Cancel</button>
              <button disabled={isPending} onClick={() => handleDelete(deleteTarget)} className="flex-1 rounded-xl bg-red-500 py-2.5 text-sm font-medium text-white hover:bg-red-600 transition-colors disabled:opacity-50">{isPending ? 'Deleting...' : 'Delete'}</button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
