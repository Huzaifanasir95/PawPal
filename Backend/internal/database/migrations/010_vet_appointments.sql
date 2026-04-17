-- Migration 010: Dedicated Vet Appointment Booking/Scheduling

CREATE TABLE IF NOT EXISTS vet_appointments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    appointment_number VARCHAR(24) UNIQUE,

    pet_owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    vet_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    pet_id UUID NOT NULL REFERENCES pets(id) ON DELETE CASCADE,

    reason TEXT NOT NULL,
    symptoms TEXT,
    owner_notes TEXT,

    appointment_datetime TIMESTAMP WITH TIME ZONE NOT NULL,
    duration_minutes INTEGER NOT NULL DEFAULT 30 CHECK (duration_minutes > 0 AND duration_minutes <= 240),

    meeting_type VARCHAR(20) NOT NULL DEFAULT 'in_person' CHECK (meeting_type IN ('in_person', 'video', 'chat')),
    clinic_address TEXT,
    meeting_link TEXT,

    fee_amount DECIMAL(10, 2) NOT NULL DEFAULT 0,
    currency VARCHAR(3) NOT NULL DEFAULT 'PKR',

    status VARCHAR(20) NOT NULL DEFAULT 'requested' CHECK (
        status IN ('requested', 'confirmed', 'declined', 'cancelled_owner', 'cancelled_vet', 'completed')
    ),

    response_note TEXT,
    responded_at TIMESTAMP WITH TIME ZONE,
    cancelled_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_vet_appointments_owner ON vet_appointments(pet_owner_id);
CREATE INDEX IF NOT EXISTS idx_vet_appointments_vet ON vet_appointments(vet_user_id);
CREATE INDEX IF NOT EXISTS idx_vet_appointments_pet ON vet_appointments(pet_id);
CREATE INDEX IF NOT EXISTS idx_vet_appointments_status ON vet_appointments(status);
CREATE INDEX IF NOT EXISTS idx_vet_appointments_datetime ON vet_appointments(appointment_datetime);

CREATE OR REPLACE FUNCTION generate_vet_appointment_number()
RETURNS TRIGGER AS $$
BEGIN
    NEW.appointment_number := 'VA' || TO_CHAR(NOW(), 'YYMMDD') || '-' || LPAD(FLOOR(RANDOM() * 10000)::TEXT, 4, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_generate_vet_appointment_number ON vet_appointments;
CREATE TRIGGER trigger_generate_vet_appointment_number
    BEFORE INSERT ON vet_appointments
    FOR EACH ROW
    WHEN (NEW.appointment_number IS NULL)
    EXECUTE FUNCTION generate_vet_appointment_number();
