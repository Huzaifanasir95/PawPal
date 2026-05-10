'use client';

import { useState, useMemo, useTransition } from 'react';
import { Search, Eye, Trash2, X, Video, MapPin, MessageSquare, Clock } from 'lucide-react';
import Badge from '@/components/Badge';
import { formatDateTime, timeAgo } from '@/lib/utils';
import { updateVetAppointmentStatus, deleteVetAppointment } from '@/lib/admin-actions';

export interface Appointment {
  id: string;
  appointment_number: string;
  reason: string;
  symptoms: string | null;
  owner_notes: string | null;
  appointment_datetime: string;
  duration_minutes: number;
  meeting_type: string;
  clinic_address: string | null;
  meeting_link: string | null;
  fee_amount: number;
  currency: string;
  status: string;
  response_note: string | null;
  responded_at: string | null;
  cancelled_at: string | null;
  completed_at: string | null;
  created_at: string;
  updated_at: string;
  owner: { id: string; display_name: string | null; email: string | null } | null;
  vet: { id: string; display_name: string | null; email: string | null } | null;
  pet: { id: string; name: string; type: string; breed: string } | null;
}

const ALL_STATUSES = ['requested', 'confirmed', 'completed', 'declined', 'cancelled_owner', 'cancelled_vet'];

function statusVariant(status: string): 'success' | 'info' | 'warning' | 'danger' | 'default' {
  switch (status) {
    case 'completed': return 'success';
    case 'confirmed': return 'info';
    case 'requested': return 'warning';
    case 'declined':
    case 'cancelled_owner':
    case 'cancelled_vet': return 'danger';
    default: return 'default';
  }
}

function statusLabel(s: string) {
  return s.replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());
}

function meetingIcon(type: string) {
  switch (type) {
    case 'video': return <Video className="h-3.5 w-3.5" />;
    case 'chat': return <MessageSquare className="h-3.5 w-3.5" />;
    default: return <MapPin className="h-3.5 w-3.5" />;
  }
}

function InfoItem({ label, value }: { label: string; value: string | null | undefined }) {
  return (
    <div>
      <p className="text-xs text-gray-400">{label}</p>
      <p className="text-sm font-medium text-gray-700">{value || '—'}</p>
    </div>
  );
}

export default function AppointmentsClient({ appointments: initialAppointments }: { appointments: Appointment[] }) {
  const [appointments, setAppointments] = useState(initialAppointments);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [meetingFilter, setMeetingFilter] = useState('all');
  const [selected, setSelected] = useState<Appointment | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<Appointment | null>(null);
  const [isPending, startTransition] = useTransition();

  const filtered = useMemo(() => {
    return appointments.filter((a) => {
      const q = search.toLowerCase();
      const matchesSearch =
        !q ||
        a.appointment_number.toLowerCase().includes(q) ||
        (a.owner?.display_name ?? '').toLowerCase().includes(q) ||
        (a.owner?.email ?? '').toLowerCase().includes(q) ||
        (a.vet?.display_name ?? '').toLowerCase().includes(q) ||
        (a.pet?.name ?? '').toLowerCase().includes(q) ||
        a.reason.toLowerCase().includes(q);
      const matchesStatus = statusFilter === 'all' || a.status === statusFilter;
      const matchesMeeting = meetingFilter === 'all' || a.meeting_type === meetingFilter;
      return matchesSearch && matchesStatus && matchesMeeting;
    });
  }, [appointments, search, statusFilter, meetingFilter]);

  const counts = useMemo(() => {
    const result: Record<string, number> = { all: appointments.length };
    ALL_STATUSES.forEach((s) => { result[s] = appointments.filter((a) => a.status === s).length; });
    return result;
  }, [appointments]);

  function handleStatusChange(id: string, status: string) {
    startTransition(async () => {
      const res = await updateVetAppointmentStatus(id, status);
      if (res.success) {
        setAppointments((prev) => prev.map((a) => a.id === id ? { ...a, status } : a));
        if (selected?.id === id) setSelected((prev) => prev ? { ...prev, status } : null);
      }
    });
  }

  function handleDelete(id: string) {
    startTransition(async () => {
      const res = await deleteVetAppointment(id);
      if (res.success) {
        setAppointments((prev) => prev.filter((a) => a.id !== id));
        setDeleteTarget(null);
        if (selected?.id === id) setSelected(null);
      }
    });
  }

  return (
    <>
      {/* Filters */}
      <div className="mb-4 flex flex-wrap items-center gap-3">
        <div className="relative flex-1 min-w-[220px]">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search appt #, owner, vet, pet, reason…"
            className="w-full rounded-xl border border-gray-200 bg-white py-2 pl-10 pr-4 text-sm focus:border-[#2C6E69] focus:outline-none focus:ring-1 focus:ring-[#2C6E69]"
          />
        </div>
        <div className="flex gap-1.5">
          {(['all', 'in_person', 'video', 'chat'] as const).map((f) => (
            <button
              key={f}
              onClick={() => setMeetingFilter(f)}
              className={`flex items-center gap-1.5 rounded-lg px-3 py-1.5 text-xs font-medium capitalize transition-colors ${meetingFilter === f ? 'bg-[#2C6E69] text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}
            >
              {f !== 'all' && meetingIcon(f)} {f === 'in_person' ? 'In Person' : f}
            </button>
          ))}
        </div>
      </div>

      {/* Status tabs */}
      <div className="mb-4 flex flex-wrap gap-2">
        <button onClick={() => setStatusFilter('all')} className={`rounded-lg px-3 py-1.5 text-xs font-medium transition-colors ${statusFilter === 'all' ? 'bg-[#2C6E69] text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}>
          All ({counts.all})
        </button>
        {ALL_STATUSES.map((s) => (
          <button
            key={s}
            onClick={() => setStatusFilter(s)}
            className={`rounded-lg px-3 py-1.5 text-xs font-medium transition-colors ${statusFilter === s ? 'bg-[#2C6E69] text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}
          >
            {statusLabel(s)} ({counts[s] ?? 0})
          </button>
        ))}
      </div>

      {/* Table */}
      <div className="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-100 bg-gray-50/60">
                {['Appointment', 'Pet', 'Owner', 'Vet', 'Scheduled', 'Type', 'Fee', 'Status', 'Actions'].map((h) => (
                  <th key={h} className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr><td colSpan={9} className="py-16 text-center text-sm text-gray-400">No appointments found</td></tr>
              ) : (
                filtered.map((a) => (
                  <tr key={a.id} className="border-b border-gray-50 last:border-0 hover:bg-gray-50/50 transition-colors">
                    <td className="px-4 py-3">
                      <p className="font-mono text-xs font-semibold text-[#2C6E69]">{a.appointment_number}</p>
                      <p className="text-xs text-gray-400">{timeAgo(a.created_at)}</p>
                    </td>
                    <td className="px-4 py-3 text-xs text-gray-600">
                      <p className="font-medium capitalize">{a.pet?.name || '—'}</p>
                      <p className="text-gray-400 capitalize">{a.pet?.type} · {a.pet?.breed}</p>
                    </td>
                    <td className="px-4 py-3 text-xs text-gray-600">
                      <p className="font-medium">{a.owner?.display_name || '—'}</p>
                      <p className="text-gray-400">{a.owner?.email}</p>
                    </td>
                    <td className="px-4 py-3 text-xs text-gray-600">
                      <p className="font-medium">{a.vet?.display_name || '—'}</p>
                      <p className="text-gray-400">{a.vet?.email}</p>
                    </td>
                    <td className="px-4 py-3 text-xs text-gray-500">
                      <p>{formatDateTime(a.appointment_datetime)}</p>
                      <p className="flex items-center gap-1 text-gray-400"><Clock className="h-3 w-3" /> {a.duration_minutes} min</p>
                    </td>
                    <td className="px-4 py-3">
                      <span className={`flex items-center gap-1.5 text-xs font-medium capitalize ${a.meeting_type === 'video' ? 'text-blue-600' : a.meeting_type === 'chat' ? 'text-purple-600' : 'text-gray-600'}`}>
                        {meetingIcon(a.meeting_type)}
                        {a.meeting_type === 'in_person' ? 'In Person' : a.meeting_type}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-sm font-semibold text-gray-800">
                      {a.currency} {a.fee_amount.toLocaleString()}
                    </td>
                    <td className="px-4 py-3">
                      <Badge variant={statusVariant(a.status)}>{statusLabel(a.status)}</Badge>
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-1">
                        <button onClick={() => setSelected(a)} className="rounded-lg p-1.5 text-gray-400 hover:bg-gray-100 hover:text-[#2C6E69]" title="View">
                          <Eye className="h-4 w-4" />
                        </button>
                        <button onClick={() => setDeleteTarget(a)} className="rounded-lg p-1.5 text-gray-400 hover:bg-red-50 hover:text-red-500" title="Delete">
                          <Trash2 className="h-4 w-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Detail Drawer */}
      {selected && (
        <div className="fixed inset-0 z-50 flex justify-end">
          <div className="absolute inset-0 bg-black/20" onClick={() => setSelected(null)} />
          <div className="relative w-full max-w-lg overflow-y-auto bg-white shadow-2xl">
            <div className="sticky top-0 z-10 flex items-center justify-between border-b bg-white px-6 py-4">
              <div>
                <h2 className="text-lg font-bold text-gray-900">{selected.appointment_number}</h2>
                <div className="mt-1 flex items-center gap-2">
                  <Badge variant={statusVariant(selected.status)}>{statusLabel(selected.status)}</Badge>
                  <span className={`flex items-center gap-1 text-xs font-medium capitalize ${selected.meeting_type === 'video' ? 'text-blue-600' : selected.meeting_type === 'chat' ? 'text-purple-600' : 'text-gray-500'}`}>
                    {meetingIcon(selected.meeting_type)}
                    {selected.meeting_type === 'in_person' ? 'In Person' : selected.meeting_type}
                  </span>
                </div>
              </div>
              <button onClick={() => setSelected(null)} className="rounded-lg p-2 hover:bg-gray-100"><X className="h-5 w-5" /></button>
            </div>
            <div className="space-y-6 p-6">
              {/* Parties */}
              <div className="grid grid-cols-2 gap-3">
                <div className="rounded-xl bg-gray-50 p-3">
                  <p className="mb-1 text-xs font-semibold uppercase text-gray-400">Pet Owner</p>
                  <p className="text-sm font-medium text-gray-800">{selected.owner?.display_name || '—'}</p>
                  <p className="text-xs text-gray-500">{selected.owner?.email}</p>
                </div>
                <div className="rounded-xl bg-gray-50 p-3">
                  <p className="mb-1 text-xs font-semibold uppercase text-gray-400">Veterinarian</p>
                  <p className="text-sm font-medium text-gray-800">{selected.vet?.display_name || '—'}</p>
                  <p className="text-xs text-gray-500">{selected.vet?.email}</p>
                </div>
              </div>

              {/* Pet */}
              {selected.pet && (
                <div className="rounded-xl border border-[#B3E0DB] bg-[#B3E0DB]/10 px-4 py-3">
                  <p className="text-xs font-semibold uppercase text-[#2C6E69]">Pet</p>
                  <p className="mt-1 font-medium text-gray-800 capitalize">{selected.pet.name} · {selected.pet.type} · {selected.pet.breed}</p>
                </div>
              )}

              {/* Schedule */}
              <div className="grid grid-cols-2 gap-4">
                <InfoItem label="Date & Time" value={formatDateTime(selected.appointment_datetime)} />
                <InfoItem label="Duration" value={`${selected.duration_minutes} minutes`} />
                <InfoItem label="Fee" value={`${selected.currency} ${selected.fee_amount.toLocaleString()}`} />
                {selected.clinic_address && <InfoItem label="Clinic Address" value={selected.clinic_address} />}
                {selected.responded_at && <InfoItem label="Responded At" value={formatDateTime(selected.responded_at)} />}
                {selected.completed_at && <InfoItem label="Completed At" value={formatDateTime(selected.completed_at)} />}
                {selected.cancelled_at && <InfoItem label="Cancelled At" value={formatDateTime(selected.cancelled_at)} />}
              </div>

              {/* Reason & Notes */}
              <div>
                <p className="mb-1 text-xs font-semibold uppercase text-gray-400">Reason</p>
                <p className="rounded-xl bg-gray-50 p-3 text-sm text-gray-700">{selected.reason}</p>
              </div>
              {selected.symptoms && (
                <div>
                  <p className="mb-1 text-xs font-semibold uppercase text-gray-400">Symptoms</p>
                  <p className="rounded-xl bg-yellow-50 p-3 text-sm text-yellow-800">{selected.symptoms}</p>
                </div>
              )}
              {selected.owner_notes && (
                <div>
                  <p className="mb-1 text-xs font-semibold uppercase text-gray-400">Owner Notes</p>
                  <p className="rounded-xl bg-gray-50 p-3 text-sm text-gray-700">{selected.owner_notes}</p>
                </div>
              )}
              {selected.response_note && (
                <div>
                  <p className="mb-1 text-xs font-semibold uppercase text-gray-400">Vet Response</p>
                  <p className="rounded-xl bg-blue-50 p-3 text-sm text-blue-800">{selected.response_note}</p>
                </div>
              )}

              {/* Status Change */}
              <div>
                <p className="mb-2 text-xs font-semibold uppercase text-gray-400">Change Status</p>
                <div className="flex flex-wrap gap-2">
                  {ALL_STATUSES.map((s) => (
                    <button
                      key={s}
                      disabled={isPending || selected.status === s}
                      onClick={() => handleStatusChange(selected.id, s)}
                      className={`rounded-lg px-3 py-1.5 text-xs font-medium transition-colors disabled:opacity-40 ${selected.status === s ? 'bg-[#2C6E69] text-white' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'}`}
                    >
                      {statusLabel(s)}
                    </button>
                  ))}
                </div>
              </div>

              <p className="text-xs text-gray-300">ID: {selected.id}</p>
              <button
                onClick={() => { setSelected(null); setDeleteTarget(selected); }}
                className="w-full rounded-xl bg-red-50 py-2.5 text-sm font-medium text-red-600 hover:bg-red-100"
              >
                Delete Appointment
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Delete Confirm */}
      {deleteTarget && (
        <div className="fixed inset-0 z-[60] flex items-center justify-center">
          <div className="absolute inset-0 bg-black/30" onClick={() => !isPending && setDeleteTarget(null)} />
          <div className="relative w-full max-w-sm rounded-2xl bg-white p-6 shadow-2xl">
            <h3 className="text-lg font-bold text-gray-900">Delete Appointment?</h3>
            <p className="mt-2 text-sm text-gray-500">
              Permanently delete appointment <strong>{deleteTarget.appointment_number}</strong>? This cannot be undone.
            </p>
            <div className="mt-5 flex gap-3">
              <button onClick={() => setDeleteTarget(null)} disabled={isPending} className="flex-1 rounded-xl border border-gray-200 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:opacity-50">Cancel</button>
              <button onClick={() => handleDelete(deleteTarget.id)} disabled={isPending} className="flex-1 rounded-xl bg-red-600 py-2 text-sm font-medium text-white hover:bg-red-700 disabled:opacity-50">{isPending ? 'Deleting…' : 'Delete'}</button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
