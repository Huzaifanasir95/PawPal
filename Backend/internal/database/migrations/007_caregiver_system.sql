-- Migration: 007_caregiver_system.sql
-- Description: Pet Caregiver Services Module
-- Features: Caregiver profiles, service bookings, payments, reviews, tracking, incidents

-- =====================================================
-- 1. UPDATE USER ROLE CONSTRAINT TO INCLUDE CAREGIVER
-- =====================================================

-- Drop existing constraint and add new one with caregiver role
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_user_role_check;
ALTER TABLE users ADD CONSTRAINT users_user_role_check 
    CHECK (user_role IN ('petowner', 'vet', 'caregiver'));

-- =====================================================
-- 2. SERVICE TYPES ENUM TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS caregiver_service_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) NOT NULL UNIQUE,
    display_name VARCHAR(100) NOT NULL,
    description TEXT,
    base_hourly_rate DECIMAL(10, 2) DEFAULT 0,
    icon_name VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Insert default service types
INSERT INTO caregiver_service_types (name, display_name, description, icon_name) VALUES
    ('dog_walking', 'Dog Walking', 'Professional dog walking services', 'directions_walk'),
    ('pet_sitting', 'Pet Sitting', 'In-home pet sitting while you''re away', 'house'),
    ('pet_boarding', 'Pet Boarding', 'Overnight care at caregiver''s home', 'hotel'),
    ('day_care', 'Day Care', 'Daytime supervision and care', 'wb_sunny'),
    ('grooming', 'Grooming', 'Basic grooming and hygiene services', 'content_cut'),
    ('training', 'Training', 'Basic obedience training sessions', 'school'),
    ('vet_taxi', 'Vet Taxi', 'Transportation to and from vet appointments', 'local_taxi'),
    ('medication_admin', 'Medication Administration', 'Administering prescribed medications', 'medical_services')
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- 3. CAREGIVER PROFILES TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS caregiver_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    
    -- Basic Info
    bio TEXT,
    years_of_experience INTEGER DEFAULT 0,
    headline VARCHAR(200),
    
    -- Location
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'Pakistan',
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    service_radius_km INTEGER DEFAULT 10,
    
    -- Verification & Background Check
    is_verified BOOLEAN DEFAULT FALSE,
    verification_date TIMESTAMP WITH TIME ZONE,
    background_check_status VARCHAR(20) DEFAULT 'pending' CHECK (background_check_status IN ('pending', 'in_progress', 'approved', 'rejected', 'expired')),
    background_check_date TIMESTAMP WITH TIME ZONE,
    background_check_expiry TIMESTAMP WITH TIME ZONE,
    id_verified BOOLEAN DEFAULT FALSE,
    id_document_url TEXT,
    
    -- Certifications & Training
    certifications TEXT[], -- Array of certification names
    pet_first_aid_certified BOOLEAN DEFAULT FALSE,
    insurance_verified BOOLEAN DEFAULT FALSE,
    insurance_policy_number VARCHAR(100),
    insurance_expiry TIMESTAMP WITH TIME ZONE,
    
    -- Preferences
    accepted_pet_types TEXT[] DEFAULT ARRAY['dog', 'cat'],
    accepted_pet_sizes TEXT[] DEFAULT ARRAY['small', 'medium', 'large'],
    max_pets_at_once INTEGER DEFAULT 3,
    has_fenced_yard BOOLEAN DEFAULT FALSE,
    has_own_transport BOOLEAN DEFAULT FALSE,
    smoke_free_home BOOLEAN DEFAULT TRUE,
    has_children BOOLEAN DEFAULT FALSE,
    has_other_pets BOOLEAN DEFAULT FALSE,
    other_pets_description TEXT,
    
    -- Ratings (cached/aggregated)
    average_rating DECIMAL(3, 2) DEFAULT 0,
    total_reviews INTEGER DEFAULT 0,
    total_bookings INTEGER DEFAULT 0,
    completion_rate DECIMAL(5, 2) DEFAULT 100,
    response_time_hours INTEGER DEFAULT 24,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    is_accepting_bookings BOOLEAN DEFAULT TRUE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index for location-based queries
CREATE INDEX IF NOT EXISTS idx_caregiver_profiles_location ON caregiver_profiles(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_caregiver_profiles_city ON caregiver_profiles(city);
CREATE INDEX IF NOT EXISTS idx_caregiver_profiles_active ON caregiver_profiles(is_active, is_accepting_bookings);

-- =====================================================
-- 4. CAREGIVER SERVICES (Services offered by each caregiver)
-- =====================================================

CREATE TABLE IF NOT EXISTS caregiver_services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    caregiver_id UUID NOT NULL REFERENCES caregiver_profiles(id) ON DELETE CASCADE,
    service_type_id UUID NOT NULL REFERENCES caregiver_service_types(id) ON DELETE CASCADE,
    
    -- Pricing
    rate_type VARCHAR(20) DEFAULT 'hourly' CHECK (rate_type IN ('hourly', 'per_visit', 'daily', 'per_walk')),
    rate_amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'PKR',
    
    -- Service Details
    description TEXT,
    duration_minutes INTEGER, -- For services like walks
    includes TEXT[], -- What's included
    additional_pet_rate DECIMAL(10, 2) DEFAULT 0, -- Extra charge per additional pet
    
    -- Availability
    is_available BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(caregiver_id, service_type_id)
);

-- =====================================================
-- 5. CAREGIVER AVAILABILITY (Weekly schedule)
-- =====================================================

CREATE TABLE IF NOT EXISTS caregiver_availability (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    caregiver_id UUID NOT NULL REFERENCES caregiver_profiles(id) ON DELETE CASCADE,
    
    day_of_week INTEGER NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6), -- 0=Sunday, 6=Saturday
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(caregiver_id, day_of_week, start_time)
);

-- =====================================================
-- 6. CAREGIVER BLOCKED DATES (Vacations, unavailable dates)
-- =====================================================

CREATE TABLE IF NOT EXISTS caregiver_blocked_dates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    caregiver_id UUID NOT NULL REFERENCES caregiver_profiles(id) ON DELETE CASCADE,
    
    blocked_date DATE NOT NULL,
    reason VARCHAR(200),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(caregiver_id, blocked_date)
);

-- =====================================================
-- 7. SERVICE BOOKINGS
-- =====================================================

CREATE TABLE IF NOT EXISTS service_bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_number VARCHAR(20) UNIQUE NOT NULL,
    
    -- Parties
    pet_owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    caregiver_id UUID NOT NULL REFERENCES caregiver_profiles(id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES caregiver_services(id) ON DELETE CASCADE,
    
    -- Pet(s) involved
    pet_ids UUID[] NOT NULL, -- Array of pet IDs
    
    -- Schedule
    start_datetime TIMESTAMP WITH TIME ZONE NOT NULL,
    end_datetime TIMESTAMP WITH TIME ZONE NOT NULL,
    
    -- Location (can be owner's home, caregiver's home, or pickup location)
    service_location_type VARCHAR(20) DEFAULT 'owner_home' CHECK (service_location_type IN ('owner_home', 'caregiver_home', 'pickup_location', 'outdoor')),
    service_address TEXT,
    service_latitude DECIMAL(10, 8),
    service_longitude DECIMAL(11, 8),
    
    -- Special Instructions
    special_instructions TEXT,
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    
    -- Pricing
    base_amount DECIMAL(10, 2) NOT NULL,
    additional_pets_fee DECIMAL(10, 2) DEFAULT 0,
    service_fee DECIMAL(10, 2) DEFAULT 0, -- Platform fee
    discount_amount DECIMAL(10, 2) DEFAULT 0,
    total_amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'PKR',
    
    -- Status
    status VARCHAR(30) DEFAULT 'pending' CHECK (status IN (
        'pending',           -- Initial request
        'accepted',          -- Caregiver accepted
        'declined',          -- Caregiver declined
        'cancelled_owner',   -- Owner cancelled
        'cancelled_caregiver', -- Caregiver cancelled
        'in_progress',       -- Service ongoing
        'completed',         -- Service completed
        'disputed'           -- Dispute raised
    )),
    
    -- Timestamps
    requested_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP WITH TIME ZONE,
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    cancelled_at TIMESTAMP WITH TIME ZONE,
    cancellation_reason TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Generate booking number trigger
CREATE OR REPLACE FUNCTION generate_booking_number()
RETURNS TRIGGER AS $$
BEGIN
    NEW.booking_number := 'BK' || TO_CHAR(NOW(), 'YYMMDD') || '-' || 
                          LPAD(FLOOR(RANDOM() * 10000)::TEXT, 4, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_generate_booking_number ON service_bookings;
CREATE TRIGGER trigger_generate_booking_number
    BEFORE INSERT ON service_bookings
    FOR EACH ROW
    WHEN (NEW.booking_number IS NULL)
    EXECUTE FUNCTION generate_booking_number();

CREATE INDEX IF NOT EXISTS idx_bookings_owner ON service_bookings(pet_owner_id);
CREATE INDEX IF NOT EXISTS idx_bookings_caregiver ON service_bookings(caregiver_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON service_bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_dates ON service_bookings(start_datetime, end_datetime);

-- =====================================================
-- 8. BOOKING PAYMENTS (Escrow system)
-- =====================================================

CREATE TABLE IF NOT EXISTS booking_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES service_bookings(id) ON DELETE CASCADE,
    
    -- Payment Details
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'PKR',
    payment_type VARCHAR(20) NOT NULL CHECK (payment_type IN ('deposit', 'final', 'refund', 'tip')),
    
    -- Payment Method
    payment_method VARCHAR(30) CHECK (payment_method IN ('card', 'wallet', 'bank_transfer', 'cash', 'jazzcash', 'easypaisa')),
    transaction_id VARCHAR(100),
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'refunded', 'held')),
    
    -- Escrow
    escrow_held_at TIMESTAMP WITH TIME ZONE,
    escrow_released_at TIMESTAMP WITH TIME ZONE,
    
    -- Payout to caregiver
    payout_status VARCHAR(20) DEFAULT 'pending' CHECK (payout_status IN ('pending', 'processing', 'completed', 'failed')),
    payout_amount DECIMAL(10, 2),
    platform_fee DECIMAL(10, 2),
    payout_transaction_id VARCHAR(100),
    payout_at TIMESTAMP WITH TIME ZONE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_payments_booking ON booking_payments(booking_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON booking_payments(status);

-- =====================================================
-- 9. SERVICE TRACKING (GPS tracking during service)
-- =====================================================

CREATE TABLE IF NOT EXISTS booking_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES service_bookings(id) ON DELETE CASCADE,
    
    -- Location
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    accuracy_meters DECIMAL(8, 2),
    
    -- Activity
    activity_type VARCHAR(30) CHECK (activity_type IN ('started', 'walking', 'stopped', 'arrived', 'feeding', 'playing', 'resting', 'completed')),
    note TEXT,
    
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_tracking_booking ON booking_tracking(booking_id);
CREATE INDEX IF NOT EXISTS idx_tracking_time ON booking_tracking(recorded_at);

-- =====================================================
-- 10. SERVICE COMPLETION REPORTS
-- =====================================================

CREATE TABLE IF NOT EXISTS booking_completion_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL UNIQUE REFERENCES service_bookings(id) ON DELETE CASCADE,
    
    -- Report Details
    summary TEXT NOT NULL,
    activities_performed TEXT[], -- Array of activities
    feeding_notes TEXT,
    bathroom_notes TEXT,
    behavior_notes TEXT,
    health_observations TEXT,
    
    -- Media
    photo_urls TEXT[], -- Array of photo URLs
    video_urls TEXT[],
    
    -- Duration & Stats
    actual_duration_minutes INTEGER,
    distance_walked_km DECIMAL(5, 2),
    
    -- Timestamps
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    owner_acknowledged_at TIMESTAMP WITH TIME ZONE
);

-- =====================================================
-- 11. SERVICE REVIEWS
-- =====================================================

CREATE TABLE IF NOT EXISTS service_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL UNIQUE REFERENCES service_bookings(id) ON DELETE CASCADE,
    
    -- Review by owner
    owner_rating INTEGER CHECK (owner_rating >= 1 AND owner_rating <= 5),
    owner_review TEXT,
    owner_review_at TIMESTAMP WITH TIME ZONE,
    
    -- Detailed ratings by owner
    communication_rating INTEGER CHECK (communication_rating >= 1 AND communication_rating <= 5),
    reliability_rating INTEGER CHECK (reliability_rating >= 1 AND reliability_rating <= 5),
    care_quality_rating INTEGER CHECK (care_quality_rating >= 1 AND care_quality_rating <= 5),
    
    -- Review by caregiver (for the pet/owner)
    caregiver_rating INTEGER CHECK (caregiver_rating >= 1 AND caregiver_rating <= 5),
    caregiver_review TEXT,
    caregiver_review_at TIMESTAMP WITH TIME ZONE,
    
    -- Pet behavior rating by caregiver
    pet_behavior_rating INTEGER CHECK (pet_behavior_rating >= 1 AND pet_behavior_rating <= 5),
    
    -- Visibility
    is_public BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_reviews_booking ON service_reviews(booking_id);

-- =====================================================
-- 12. SERVICE INCIDENTS
-- =====================================================

CREATE TABLE IF NOT EXISTS service_incidents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    incident_number VARCHAR(20) UNIQUE NOT NULL,
    booking_id UUID NOT NULL REFERENCES service_bookings(id) ON DELETE CASCADE,
    reported_by UUID NOT NULL REFERENCES users(id),
    
    -- Incident Details
    incident_type VARCHAR(50) NOT NULL CHECK (incident_type IN (
        'injury_pet',
        'injury_caregiver', 
        'pet_escape',
        'property_damage',
        'behavioral_issue',
        'medical_emergency',
        'service_quality',
        'safety_concern',
        'other'
    )),
    severity VARCHAR(20) NOT NULL CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    
    description TEXT NOT NULL,
    occurred_at TIMESTAMP WITH TIME ZONE NOT NULL,
    location_description TEXT,
    
    -- Media Evidence
    photo_urls TEXT[],
    video_urls TEXT[],
    
    -- Resolution
    status VARCHAR(30) DEFAULT 'reported' CHECK (status IN ('reported', 'under_review', 'investigating', 'resolved', 'closed', 'escalated')),
    resolution_notes TEXT,
    resolved_at TIMESTAMP WITH TIME ZONE,
    resolved_by UUID REFERENCES users(id),
    
    -- Insurance Claim
    insurance_claim_filed BOOLEAN DEFAULT FALSE,
    insurance_claim_number VARCHAR(100),
    insurance_claim_status VARCHAR(30),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Generate incident number trigger
CREATE OR REPLACE FUNCTION generate_incident_number()
RETURNS TRIGGER AS $$
BEGIN
    NEW.incident_number := 'INC' || TO_CHAR(NOW(), 'YYMMDD') || '-' || 
                           LPAD(FLOOR(RANDOM() * 10000)::TEXT, 4, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_generate_incident_number ON service_incidents;
CREATE TRIGGER trigger_generate_incident_number
    BEFORE INSERT ON service_incidents
    FOR EACH ROW
    WHEN (NEW.incident_number IS NULL)
    EXECUTE FUNCTION generate_incident_number();

CREATE INDEX IF NOT EXISTS idx_incidents_booking ON service_incidents(booking_id);
CREATE INDEX IF NOT EXISTS idx_incidents_status ON service_incidents(status);
CREATE INDEX IF NOT EXISTS idx_incidents_type ON service_incidents(incident_type);

-- =====================================================
-- 13. CAREGIVER-OWNER MESSAGING (extends existing chat system)
-- =====================================================

-- Add booking reference to existing chats table
ALTER TABLE chats ADD COLUMN IF NOT EXISTS booking_id UUID REFERENCES service_bookings(id);
ALTER TABLE chats ADD COLUMN IF NOT EXISTS chat_type VARCHAR(20) DEFAULT 'general' CHECK (chat_type IN ('general', 'vet_consultation', 'booking_inquiry', 'active_booking'));

CREATE INDEX IF NOT EXISTS idx_chats_booking ON chats(booking_id);

-- =====================================================
-- 14. UPDATE FUNCTIONS FOR RATING AGGREGATION
-- =====================================================

CREATE OR REPLACE FUNCTION update_caregiver_ratings()
RETURNS TRIGGER AS $$
DECLARE
    caregiver_profile_id UUID;
    avg_rating DECIMAL(3, 2);
    review_count INTEGER;
BEGIN
    -- Get caregiver profile ID from booking
    SELECT cp.id INTO caregiver_profile_id
    FROM service_bookings sb
    JOIN caregiver_profiles cp ON sb.caregiver_id = cp.id
    WHERE sb.id = NEW.booking_id;
    
    -- Calculate aggregated ratings
    SELECT 
        COALESCE(AVG(owner_rating), 0),
        COUNT(owner_rating)
    INTO avg_rating, review_count
    FROM service_reviews sr
    JOIN service_bookings sb ON sr.booking_id = sb.id
    WHERE sb.caregiver_id = caregiver_profile_id
    AND sr.owner_rating IS NOT NULL;
    
    -- Update caregiver profile
    UPDATE caregiver_profiles
    SET average_rating = avg_rating,
        total_reviews = review_count,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = caregiver_profile_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_caregiver_ratings ON service_reviews;
CREATE TRIGGER trigger_update_caregiver_ratings
    AFTER INSERT OR UPDATE ON service_reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_caregiver_ratings();

-- =====================================================
-- 15. CAREGIVER PORTFOLIO/GALLERY
-- =====================================================

CREATE TABLE IF NOT EXISTS caregiver_gallery (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    caregiver_id UUID NOT NULL REFERENCES caregiver_profiles(id) ON DELETE CASCADE,
    
    image_url TEXT NOT NULL,
    caption TEXT,
    is_primary BOOLEAN DEFAULT FALSE,
    display_order INTEGER DEFAULT 0,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_gallery_caregiver ON caregiver_gallery(caregiver_id);

-- =====================================================
-- GRANT PERMISSIONS (if needed)
-- =====================================================

-- End of migration
