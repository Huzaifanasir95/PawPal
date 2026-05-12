export const dynamic = 'force-dynamic';

import { createClient } from '@supabase/supabase-js';
import BookingsClient, { type Booking, type Payment } from './BookingsClient';

async function getBookings() {
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { auth: { persistSession: false } }
  );

  const { data: bookings, error } = await supabase
    .from('service_bookings')
    .select(`
      id,
      booking_number,
      pet_owner_id,
      status,
      start_datetime,
      end_datetime,
      total_amount,
      currency,
      base_amount,
      service_fee,
      special_instructions,
      cancellation_reason,
      requested_at,
      created_at,
      updated_at,
      pet_owner:users!service_bookings_pet_owner_id_fkey(id, display_name, email, avatar_url),
      caregiver:caregiver_profiles!service_bookings_caregiver_id_fkey(
        id,
        city,
        owner:users!caregiver_profiles_user_id_fkey(id, display_name, email, avatar_url)
      ),
      service:caregiver_services!service_bookings_service_id_fkey(
        id,
        rate_amount,
        currency,
        rate_type,
        service_type:caregiver_service_types!caregiver_services_service_type_id_fkey(display_name)
      )
    `)
    .order('created_at', { ascending: false })
    .limit(300);

  if (error) throw error;

  const { data: payments } = await supabase
    .from('booking_payments')
    .select('id, booking_id, amount, payment_type, payment_method, status, payout_status, created_at')
    .order('created_at', { ascending: false });

  return {
    bookings: bookings ?? [],
    payments: payments ?? [],
  };
}

export default async function BookingsPage() {
  const data = await getBookings();

  const byStatus = (s: string) => data.bookings.filter((b) => b.status === s).length;
  const pending    = byStatus('pending');
  const active     = byStatus('accepted') + byStatus('in_progress');
  const completed  = byStatus('completed');

  return (
    <div className="p-8">
      <div
        className="mb-6 overflow-hidden rounded-2xl shadow-md ring-1 ring-black/5"
        style={{ background: 'linear-gradient(135deg, #0B1629 0%, #1a3a38 50%, #2C6E69 100%)' }}
      >
        <div className="px-6 py-5 sm:px-8 sm:py-6">
          <h1 className="text-2xl font-bold tracking-tight text-white sm:text-[1.75rem]">
            Bookings
          </h1>
          <p className="mt-1.5 text-sm text-white/70">
            {data.bookings.length} total · {pending} pending · {active} active · {completed} completed
          </p>
        </div>
      </div>
      <BookingsClient
        bookings={data.bookings as unknown as Booking[]}
        payments={data.payments as unknown as Payment[]}
      />
    </div>
  );
}
