-- Migration: Add missing pet_id column to chats table and fix unread counts
-- Date: 2025-12-06

-- Add pet_id column to chats table
ALTER TABLE chats ADD COLUMN IF NOT EXISTS pet_id UUID REFERENCES pets(id) ON DELETE SET NULL;

-- Drop old unread_count column and add separate counts for owner and vet
ALTER TABLE chats DROP COLUMN IF EXISTS unread_count;
ALTER TABLE chats ADD COLUMN IF NOT EXISTS unread_count_owner INTEGER DEFAULT 0;
ALTER TABLE chats ADD COLUMN IF NOT EXISTS unread_count_vet INTEGER DEFAULT 0;

-- Rename last_message_time to last_message_at for consistency
ALTER TABLE chats RENAME COLUMN last_message_time TO last_message_at;

-- Create index on pet_id
CREATE INDEX IF NOT EXISTS idx_chats_pet_id ON chats(pet_id);

-- Drop the old sender_role column from messages (not needed)
ALTER TABLE messages DROP COLUMN IF EXISTS sender_role;

-- Update the trigger for chat updates to use new column names
DROP TRIGGER IF EXISTS update_chat_on_message ON messages;

CREATE OR REPLACE FUNCTION update_chat_on_new_message()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE chats
    SET last_message = NEW.content,
        last_message_at = NEW.created_at,
        updated_at = NEW.created_at,
        unread_count_owner = CASE 
            WHEN NEW.sender_id = vet_id THEN unread_count_owner + 1 
            ELSE unread_count_owner 
        END,
        unread_count_vet = CASE 
            WHEN NEW.sender_id = pet_owner_id THEN unread_count_vet + 1 
            ELSE unread_count_vet 
        END
    WHERE id = NEW.chat_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_chat_on_message
AFTER INSERT ON messages
FOR EACH ROW
EXECUTE FUNCTION update_chat_on_new_message();
