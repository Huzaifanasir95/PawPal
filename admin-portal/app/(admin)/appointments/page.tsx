export const dynamic = 'force-dynamic';

import { createClient } from '@supabase/supabase-js';
import AppointmentsClient, { type Appointment } from './AppointmentsClient';

async function getAppointments() {
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { auth: { persistSession: false } }
  );

  const { data: appointments } = await supabase
    .from('vet_appointments')
    .select(`
      id,
      appointment_number,
      reason,
      symptoms,
      owner_notes,
      appointment_datetime,
      duration_minutes,
      meeting_type,
      clinic_address,
      meeting_link,
      fee_amount,
      currency,
      status,
      response_note,
      responded_at,
      cancelled_at,
      completed_at,
      created_at,
      updated_at,
      owner:users!vet_appointments_pet_owner_id_fkey(id, display_name, email),
      vet:users!vet_appointments_vet_user_id_fkey(id, display_name, email),
      pet:pets!vet_appointments_pet_id_fkey(id, name, type, breed)
    `)
    .order('appointment_datetime', { ascending: false });

  return appointments ?? [];
}

export default async function AppointmentsPage() {
  const appointments = await getAppointments();
  return (
    <div className="p-8">
      <div
        className="mb-6 overflow-hidden rounded-2xl shadow-md ring-1 ring-black/5"
        style={{
          background: 'linear-gradient(135deg, #0B1629 0%, #1a3a38 50%, #2C6E69 100%)',
        }}
      >
        <div className="px-6 py-5 sm:px-8 sm:py-6">
          <h1 className="text-2xl font-bold tracking-tight text-white sm:text-[1.75rem]">
            Vet Appointments
          </h1>
          <p className="mt-1.5 text-sm text-white/70">
            {appointments.length} total appointments
          </p>
        </div>
      </div>
      <AppointmentsClient appointments={appointments as unknown as Appointment[]} />
    </div>
  );
}
