export const dynamic = 'force-dynamic';

import { createClient } from '@supabase/supabase-js';
import BookingsClient from './BookingsClient';

async function getBookings() {
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { auth: { persistSession: false } }
  );

  const { data: bookings } = await supabase
    .from('service_bookings')
    .select(`
      id,
      booking_number,
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
      pet_owner:users!service_bookings_pet_owner_id_fkey(id, display_name, email),
      caregiver:caregiver_profiles!service_bookings_caregiver_id_fkey(
        id,
        city,
        owner:users!caregiver_profiles_user_id_fkey(display_name, email)
      ),
      service:caregiver_services!service_bookings_service_id_fkey(
        id,
        service_type:caregiver_service_types!caregiver_services_service_type_id_fkey(display_name)
      )
    `)
    .order('created_at', { ascending: false });

  const { data: payments } = await supabase
    .from('booking_payments')
    .select('id, booking_id, amount, payment_type, payment_method, status, payout_status, created_at');

  return {
    bookings: bookings ?? [],
    payments: payments ?? [],
  };
}

export default async function BookingsPage() {
  const data = await getBookings();
  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Bookings</h1>
        <p className="mt-1 text-sm text-gray-500">
          {data.bookings.length} caregiver service bookings
        </p>
      </div>
      <BookingsClient bookings={data.bookings as any} payments={data.payments as any} />
    </div>
  );
}
