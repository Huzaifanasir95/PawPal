-- Migration 013: Add appointment context to chats

ALTER TABLE chats
    ADD COLUMN IF NOT EXISTS appointment_id UUID REFERENCES vet_appointments(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_chats_appointment ON chats(appointment_id);
