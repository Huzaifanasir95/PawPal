-- Migration 012: Link adoption listings to pets and prevent duplicate active listings per pet

ALTER TABLE adoption_listings
  ADD COLUMN IF NOT EXISTS pet_id UUID REFERENCES pets(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_adoption_pet_id ON adoption_listings(pet_id);

-- Enforce one active listing (available/pending) per pet.
CREATE UNIQUE INDEX IF NOT EXISTS uq_adoption_pet_active
  ON adoption_listings(pet_id)
  WHERE pet_id IS NOT NULL AND status IN ('available', 'pending');
