import { createClient } from '@supabase/supabase-js';
import { timeAgo } from '@/lib/utils';

export const dynamic = 'force-dynamic';
import Badge from '@/components/Badge';
import { MapPin, Phone } from 'lucide-react';

async function getLostFound() {
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { auth: { persistSession: false } }
  );

  const { data, error } = await supabase
    .from('lost_found_posts')
    .select('id, type, pet_name, pet_type, breed, description, last_seen_location, status, urgency, contact_phone, contact_email, created_at, user_id')
    .order('created_at', { ascending: false })
    .limit(200);

  if (error) throw error;

  // Enrich with user data
  const userIds = Array.from(new Set((data ?? []).map((i: { user_id: string }) => i.user_id)));
  const { data: users } = await supabase
    .from('users')
    .select('id, display_name, email')
    .in('id', userIds);
  const userMap = Object.fromEntries((users ?? []).map((u: { id: string; display_name: string | null; email: string | null }) => [u.id, { full_name: u.display_name, email: u.email }]));

  return (data ?? []).map((i: any) => ({
    ...i,
    species: i.pet_type,
    profiles: userMap[i.user_id] ?? null,
  }));
}

const urgencyMap: Record<string, { label: string; variant: 'danger' | 'warning' | 'default' }> = {
  critical: { label: 'Critical', variant: 'danger' },
  high: { label: 'High', variant: 'warning' },
  medium: { label: 'Medium', variant: 'default' },
  low: { label: 'Low', variant: 'default' },
};

const statusMap: Record<string, { label: string; variant: 'success' | 'warning' | 'default' }> = {
  open: { label: 'Open', variant: 'warning' },
  resolved: { label: 'Resolved', variant: 'success' },
  closed: { label: 'Closed', variant: 'default' },
};

export default async function LostFoundPage() {
  const items = await getLostFound();

  const lost = items.filter((i) => i.type === 'lost').length;
  const found = items.filter((i) => i.type === 'found').length;
  const open = items.filter((i) => i.status === 'open').length;

  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Lost & Found</h1>
        <p className="mt-1 text-sm text-gray-500">
          {items.length} reports — {lost} lost, {found} found, {open} still open
        </p>
      </div>

      <div className="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-100 bg-gray-50/60">
                {['Type', 'Pet', 'Last Seen', 'Contact', 'Reported By', 'Urgency', 'Status', 'Time'].map((h) => (
                  <th key={h} className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {items.length === 0 ? (
                <tr>
                  <td colSpan={8} className="py-16 text-center text-sm text-gray-400">
                    No lost & found reports
                  </td>
                </tr>
              ) : (
                items.map((item) => {
                  const urgency = urgencyMap[item.urgency] ?? { label: item.urgency || '—', variant: 'default' as const };
                  const status = statusMap[item.status] ?? { label: item.status || '—', variant: 'default' as const };
                  const profile = item.profiles as { full_name?: string | null; email?: string | null } | null;
                  return (
                    <tr
                      key={item.id}
                      className="border-b border-gray-50 last:border-0 hover:bg-gray-50/50 transition-colors"
                    >
                      <td className="px-4 py-3">
                        <Badge variant={item.type === 'lost' ? 'danger' : 'success'}>
                          {item.type === 'lost' ? '🔍 Lost' : '📢 Found'}
                        </Badge>
                      </td>
                      <td className="px-4 py-3">
                        <p className="font-medium text-gray-800">{item.pet_name || '?'}</p>
                        <p className="text-xs text-gray-400 capitalize">
                          {item.species || ''}{item.breed ? ` · ${item.breed}` : ''}
                        </p>
                      </td>
                      <td className="px-4 py-3 text-xs text-gray-500">
                        {item.last_seen_location ? (
                          <span className="flex items-center gap-1">
                            <MapPin className="h-3 w-3" />
                            {item.last_seen_location}
                          </span>
                        ) : (
                          '—'
                        )}
                      </td>
                      <td className="px-4 py-3 text-xs text-gray-500">
                        {item.contact_phone ? (
                          <span className="flex items-center gap-1">
                            <Phone className="h-3 w-3" />
                            {item.contact_phone}
                          </span>
                        ) : (
                          item.contact_email || '—'
                        )}
                      </td>
                      <td className="px-4 py-3 text-xs text-gray-600">
                        {profile?.full_name || profile?.email || 'Unknown'}
                      </td>
                      <td className="px-4 py-3">
                        <Badge variant={urgency.variant}>{urgency.label}</Badge>
                      </td>
                      <td className="px-4 py-3">
                        <Badge variant={status.variant}>{status.label}</Badge>
                      </td>
                      <td className="px-4 py-3 text-xs text-gray-400">
                        {timeAgo(item.created_at)}
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
