-- Migration 009: Normalize chat last-message column and message trigger
-- Date: 2025-12-10

BEGIN;

-- If a legacy schema still has last_message_time, rename it when last_message_at is missing.
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'chats'
          AND column_name = 'last_message_time'
    )
    AND NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'chats'
          AND column_name = 'last_message_at'
    ) THEN
        ALTER TABLE chats RENAME COLUMN last_message_time TO last_message_at;
    END IF;
END $$;

-- Ensure modern chat columns exist.
ALTER TABLE chats ADD COLUMN IF NOT EXISTS last_message_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE chats ADD COLUMN IF NOT EXISTS unread_count_owner INTEGER DEFAULT 0;
ALTER TABLE chats ADD COLUMN IF NOT EXISTS unread_count_vet INTEGER DEFAULT 0;

-- If both timestamp columns exist, keep data and remove the legacy one.
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'chats'
          AND column_name = 'last_message_time'
    ) THEN
        UPDATE chats
        SET last_message_at = COALESCE(last_message_at, last_message_time)
        WHERE last_message_time IS NOT NULL;

        ALTER TABLE chats DROP COLUMN IF EXISTS last_message_time;
    END IF;
END $$;

-- Drop the old aggregate unread_count column if it still exists.
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'chats'
          AND column_name = 'unread_count'
    ) THEN
        ALTER TABLE chats DROP COLUMN unread_count;
    END IF;
END $$;

UPDATE chats
SET unread_count_owner = COALESCE(unread_count_owner, 0),
    unread_count_vet = COALESCE(unread_count_vet, 0)
WHERE unread_count_owner IS NULL
   OR unread_count_vet IS NULL;

DROP INDEX IF EXISTS idx_chats_last_message_time;
CREATE INDEX IF NOT EXISTS idx_chats_last_message_at ON chats(last_message_at DESC);

-- Clear any legacy chat-update triggers before installing a canonical one.
DROP TRIGGER IF EXISTS trigger_update_chat_last_message ON messages;
DROP TRIGGER IF EXISTS update_chat_on_message ON messages;

CREATE OR REPLACE FUNCTION sync_chat_on_new_message()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE chats
    SET last_message = NEW.content,
        last_message_at = NEW.created_at,
        updated_at = NEW.created_at,
        unread_count_owner = CASE
            WHEN NEW.sender_id = vet_id THEN COALESCE(unread_count_owner, 0) + 1
            ELSE COALESCE(unread_count_owner, 0)
        END,
        unread_count_vet = CASE
            WHEN NEW.sender_id = pet_owner_id THEN COALESCE(unread_count_vet, 0) + 1
            ELSE COALESCE(unread_count_vet, 0)
        END
    WHERE id = NEW.chat_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Keep compatibility wrappers for any legacy references.
CREATE OR REPLACE FUNCTION update_chat_last_message()
RETURNS TRIGGER AS $$
BEGIN
    RETURN sync_chat_on_new_message();
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_chat_on_new_message()
RETURNS TRIGGER AS $$
BEGIN
    RETURN sync_chat_on_new_message();
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_chat_on_message
AFTER INSERT ON messages
FOR EACH ROW
EXECUTE FUNCTION sync_chat_on_new_message();

COMMIT;
