package database

import (
	"context"
	"fmt"
	"os"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
)

var DB *pgxpool.Pool

// Config holds database configuration
type Config struct {
	ConnectionString string
	MaxConns         int32
	MinConns         int32
	MaxConnLifetime  time.Duration
	MaxConnIdleTime  time.Duration
}

// Initialize initializes the database connection pool using Supabase
func Initialize() error {
	// Load .env file
	if err := godotenv.Load(); err != nil {
		fmt.Println("Warning: .env file not found, using environment variables")
	}

	connString := os.Getenv("SupabaseConnectionString")
	if connString == "" {
		connString = os.Getenv("SUPABASE_CONNECTION_STRING")
	}
	if connString == "" {
		return fmt.Errorf("SupabaseConnectionString is not set in environment")
	}

	pool, err := tryConnect(connString, "Supabase")
	if err != nil {
		return fmt.Errorf("failed to connect to Supabase: %w", err)
	}

	DB = pool
	if err := ensureChatCompatibility(context.Background(), DB); err != nil {
		fmt.Printf("Warning: chat compatibility repair failed: %v\n", err)
	}
	fmt.Println("✅ Successfully connected to Supabase PostgreSQL database")
	return nil
}

func ensureChatCompatibility(ctx context.Context, db *pgxpool.Pool) error {
	compatSQL := `
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

ALTER TABLE chats ADD COLUMN IF NOT EXISTS last_message_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE chats ADD COLUMN IF NOT EXISTS unread_count_owner INTEGER DEFAULT 0;
ALTER TABLE chats ADD COLUMN IF NOT EXISTS unread_count_vet INTEGER DEFAULT 0;

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

CREATE TRIGGER update_chat_on_message
AFTER INSERT ON messages
FOR EACH ROW
EXECUTE FUNCTION sync_chat_on_new_message();`

	_, err := db.Exec(ctx, compatSQL)
	return err
}

// tryConnect attempts to establish a database connection with the given connection string
func tryConnect(connString, dbName string) (*pgxpool.Pool, error) {
	config, err := pgxpool.ParseConfig(connString)
	if err != nil {
		return nil, fmt.Errorf("failed to parse %s connection string: %w", dbName, err)
	}

	// Configure pool settings
	config.MaxConns = 25
	config.MinConns = 5
	config.MaxConnLifetime = time.Hour
	config.MaxConnIdleTime = 30 * time.Minute

	// Use simple protocol to avoid prepared statement conflicts with Supabase transaction pooler
	config.ConnConfig.DefaultQueryExecMode = pgx.QueryExecModeSimpleProtocol

	// Create the connection pool
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	pool, err := pgxpool.NewWithConfig(ctx, config)
	if err != nil {
		return nil, fmt.Errorf("failed to create %s connection pool: %w", dbName, err)
	}

	// Verify connection
	if err := pool.Ping(ctx); err != nil {
		pool.Close()
		return nil, fmt.Errorf("failed to ping %s: %w", dbName, err)
	}

	return pool, nil
}

// Close closes the database connection pool
func Close() {
	if DB != nil {
		DB.Close()
		fmt.Println("Database connection pool closed")
	}
}

// GetDB returns the database connection pool
func GetDB() *pgxpool.Pool {
	return DB
}
