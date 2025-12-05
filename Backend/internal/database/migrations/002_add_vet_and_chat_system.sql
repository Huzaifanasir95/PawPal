-- Migration 002: Add Vet System and Chat/Messaging Features
-- This adds support for veterinarians, their profiles, and chat functionality

-- Add user_role column to users table
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS user_role VARCHAR(20) DEFAULT 'petowner' 
CHECK (user_role IN ('petowner', 'vet'));

-- Create index on user_role
CREATE INDEX IF NOT EXISTS idx_users_role ON users(user_role);

-- Vet profiles table
CREATE TABLE IF NOT EXISTS vet_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    full_name VARCHAR(255) NOT NULL,
    degree VARCHAR(50) NOT NULL, -- e.g., "DVM", "BVMS"
    license_number VARCHAR(100),
    specialization TEXT[], -- e.g., ["Surgery", "Dermatology", "Internal Medicine"]
    experience INTEGER NOT NULL DEFAULT 0, -- years of experience
    clinic_name VARCHAR(255),
    clinic_address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    zip_code VARCHAR(20),
    phone VARCHAR(50) NOT NULL,
    consultation_fee DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    currency VARCHAR(10) DEFAULT 'USD',
    bio TEXT,
    profile_photo_url TEXT,
    availability_hours JSONB, -- Store availability schedule as JSON
    rating DECIMAL(3, 2) DEFAULT 0.00 CHECK (rating >= 0 AND rating <= 5),
    total_reviews INTEGER DEFAULT 0,
    is_verified BOOLEAN DEFAULT false,
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for vet profiles
CREATE INDEX IF NOT EXISTS idx_vet_profiles_user_id ON vet_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_vet_profiles_city ON vet_profiles(city);
CREATE INDEX IF NOT EXISTS idx_vet_profiles_rating ON vet_profiles(rating);
CREATE INDEX IF NOT EXISTS idx_vet_profiles_is_available ON vet_profiles(is_available);
CREATE INDEX IF NOT EXISTS idx_vet_profiles_specialization ON vet_profiles USING GIN(specialization);

-- Chats table (conversations between pet owners and vets)
CREATE TABLE IF NOT EXISTS chats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pet_owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    vet_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    last_message TEXT,
    last_message_time TIMESTAMP WITH TIME ZONE,
    unread_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT unique_chat_pair UNIQUE(pet_owner_id, vet_id)
);

-- Create indexes for chats
CREATE INDEX IF NOT EXISTS idx_chats_pet_owner_id ON chats(pet_owner_id);
CREATE INDEX IF NOT EXISTS idx_chats_vet_id ON chats(vet_id);
CREATE INDEX IF NOT EXISTS idx_chats_last_message_time ON chats(last_message_time DESC);

-- Messages table
CREATE TABLE IF NOT EXISTS messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    chat_id UUID NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    sender_role VARCHAR(20) NOT NULL CHECK (sender_role IN ('petowner', 'vet')),
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for messages
CREATE INDEX IF NOT EXISTS idx_messages_chat_id ON messages(chat_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at DESC);

-- Vet reviews table
CREATE TABLE IF NOT EXISTS vet_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vet_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT unique_user_vet_review UNIQUE(vet_id, user_id)
);

-- Create indexes for vet reviews
CREATE INDEX IF NOT EXISTS idx_vet_reviews_vet_id ON vet_reviews(vet_id);
CREATE INDEX IF NOT EXISTS idx_vet_reviews_user_id ON vet_reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_vet_reviews_rating ON vet_reviews(rating);

-- Function to update vet rating when a review is added/updated/deleted
CREATE OR REPLACE FUNCTION update_vet_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE vet_profiles
    SET 
        rating = (
            SELECT COALESCE(AVG(rating), 0)
            FROM vet_reviews
            WHERE vet_id = COALESCE(NEW.vet_id, OLD.vet_id)
        ),
        total_reviews = (
            SELECT COUNT(*)
            FROM vet_reviews
            WHERE vet_id = COALESCE(NEW.vet_id, OLD.vet_id)
        ),
        updated_at = NOW()
    WHERE user_id = COALESCE(NEW.vet_id, OLD.vet_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Trigger to update vet rating automatically
DROP TRIGGER IF EXISTS trigger_update_vet_rating ON vet_reviews;
CREATE TRIGGER trigger_update_vet_rating
AFTER INSERT OR UPDATE OR DELETE ON vet_reviews
FOR EACH ROW
EXECUTE FUNCTION update_vet_rating();

-- Function to update chat's last message
CREATE OR REPLACE FUNCTION update_chat_last_message()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE chats
    SET 
        last_message = NEW.content,
        last_message_time = NEW.created_at,
        updated_at = NOW()
    WHERE id = NEW.chat_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update last message in chat
DROP TRIGGER IF EXISTS trigger_update_chat_last_message ON messages;
CREATE TRIGGER trigger_update_chat_last_message
AFTER INSERT ON messages
FOR EACH ROW
EXECUTE FUNCTION update_chat_last_message();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add triggers for updated_at on new tables
DROP TRIGGER IF EXISTS trigger_vet_profiles_updated_at ON vet_profiles;
CREATE TRIGGER trigger_vet_profiles_updated_at
BEFORE UPDATE ON vet_profiles
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS trigger_chats_updated_at ON chats;
CREATE TRIGGER trigger_chats_updated_at
BEFORE UPDATE ON chats
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS trigger_vet_reviews_updated_at ON vet_reviews;
CREATE TRIGGER trigger_vet_reviews_updated_at
BEFORE UPDATE ON vet_reviews
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Grant necessary permissions (adjust as needed for your setup)
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;
-- GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO authenticated;
