-- Fix availability_hours column type from JSONB to TEXT
ALTER TABLE vet_profiles ALTER COLUMN availability_hours TYPE TEXT;
