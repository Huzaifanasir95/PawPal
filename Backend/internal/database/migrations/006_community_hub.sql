-- Migration 006: Community Hub – Lost & Found, Adoption, Events

-- ─── Lost & Found Pets ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS lost_found_posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(10) NOT NULL CHECK (type IN ('lost', 'found')),
    pet_name VARCHAR(100),
    pet_type VARCHAR(20), -- dog, cat, bird, etc.
    breed VARCHAR(100),
    color VARCHAR(100),
    description TEXT NOT NULL,
    image_urls TEXT[],
    last_seen_location TEXT,
    last_seen_lat DECIMAL(10, 7),
    last_seen_lng DECIMAL(10, 7),
    urgency VARCHAR(10) DEFAULT 'medium' CHECK (urgency IN ('low', 'medium', 'high', 'critical')),
    contact_phone VARCHAR(20),
    contact_email VARCHAR(255),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'resolved', 'expired')),
    user_name VARCHAR(255),
    user_avatar TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_lost_found_user ON lost_found_posts(user_id);
CREATE INDEX IF NOT EXISTS idx_lost_found_type ON lost_found_posts(type);
CREATE INDEX IF NOT EXISTS idx_lost_found_status ON lost_found_posts(status);
CREATE INDEX IF NOT EXISTS idx_lost_found_created ON lost_found_posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_lost_found_urgency ON lost_found_posts(urgency);

-- ─── Adoption Listings ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS adoption_listings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    pet_name VARCHAR(100) NOT NULL,
    pet_type VARCHAR(20) NOT NULL, -- dog, cat, bird, etc.
    breed VARCHAR(100),
    age VARCHAR(50),
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'unknown')),
    size VARCHAR(10) CHECK (size IN ('small', 'medium', 'large', 'xlarge')),
    color VARCHAR(100),
    description TEXT NOT NULL,
    medical_info TEXT,
    is_vaccinated BOOLEAN DEFAULT false,
    is_neutered BOOLEAN DEFAULT false,
    is_trained BOOLEAN DEFAULT false,
    good_with_kids BOOLEAN,
    good_with_pets BOOLEAN,
    image_urls TEXT[],
    location TEXT,
    contact_phone VARCHAR(20),
    contact_email VARCHAR(255),
    adoption_fee DECIMAL(10, 2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'available' CHECK (status IN ('available', 'pending', 'adopted', 'removed')),
    user_name VARCHAR(255),
    user_avatar TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_adoption_user ON adoption_listings(user_id);
CREATE INDEX IF NOT EXISTS idx_adoption_pet_type ON adoption_listings(pet_type);
CREATE INDEX IF NOT EXISTS idx_adoption_status ON adoption_listings(status);
CREATE INDEX IF NOT EXISTS idx_adoption_created ON adoption_listings(created_at DESC);

-- ─── Events / Meetups ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organizer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    event_type VARCHAR(30) DEFAULT 'meetup' CHECK (event_type IN ('meetup', 'adoption_drive', 'training', 'competition', 'charity', 'other')),
    image_url TEXT,
    location TEXT,
    location_lat DECIMAL(10, 7),
    location_lng DECIMAL(10, 7),
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE,
    max_attendees INTEGER,
    is_pet_friendly BOOLEAN DEFAULT true,
    pet_types_allowed TEXT[], -- empty = all types
    status VARCHAR(20) DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'ongoing', 'completed', 'cancelled')),
    organizer_name VARCHAR(255),
    organizer_avatar TEXT,
    rsvp_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_events_organizer ON events(organizer_id);
CREATE INDEX IF NOT EXISTS idx_events_start ON events(start_date);
CREATE INDEX IF NOT EXISTS idx_events_status ON events(status);
CREATE INDEX IF NOT EXISTS idx_events_type ON events(event_type);

-- ─── Event RSVPs ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS event_rsvps (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(15) DEFAULT 'going' CHECK (status IN ('going', 'interested', 'waitlisted')),
    user_name VARCHAR(255),
    user_avatar TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(event_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_rsvps_event ON event_rsvps(event_id);
CREATE INDEX IF NOT EXISTS idx_rsvps_user ON event_rsvps(user_id);
