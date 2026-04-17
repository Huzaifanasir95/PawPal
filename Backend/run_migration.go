package main

import (
	"context"
	"fmt"
	"log"
	"os"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
)

func main() {
	ctx := context.Background()

	// Load .env file
	if err := godotenv.Load(); err != nil {
		fmt.Println("Warning: .env file not found, using environment variables")
	}

	dbURL := os.Getenv("SupabaseConnectionString")
	if dbURL == "" {
		log.Fatal("SupabaseConnectionString not set in environment")
	}

	fmt.Println("Connecting to Supabase...")
	pool, err := pgxpool.New(ctx, dbURL)
	if err != nil {
		log.Fatal("Unable to connect to database:", err)
	}
	defer pool.Close()

	if err := pool.Ping(ctx); err != nil {
		log.Fatal("Database ping failed:", err)
	}
	fmt.Println("✅ Connected to Supabase PostgreSQL")

	migrations := []struct {
		name string
		file string
	}{
		{"001 - Initial Schema", "internal/database/migrations/001_initial_schema.sql"},
		{"002 - Vet and Chat System", "internal/database/migrations/002_add_vet_and_chat_system.sql"},
		{"003 - Fix Chat Schema", "internal/database/migrations/003_fix_chat_schema.sql"},
		{"004 - Fix Availability Hours", "internal/database/migrations/004_fix_availability_hours.sql"},
		{"005 - Marketplace", "internal/database/migrations/005_marketplace.sql"},
		{"006 - Community Hub", "internal/database/migrations/006_community_hub.sql"},
		{"007 - Caregiver System", "internal/database/migrations/007_caregiver_system.sql"},
		{"008 - User Roles", "internal/database/migrations/008_user_roles.sql"},
		{"009 - Fix Chat Last Message Trigger", "internal/database/migrations/009_fix_chat_last_message_trigger.sql"},
		{"010 - Vet Appointments", "internal/database/migrations/010_vet_appointments.sql"},
		{"011 - Community Advanced Features", "internal/database/migrations/011_community_advanced_features.sql"},
		{"012 - Adoption Pet Link and Uniqueness", "internal/database/migrations/012_adoption_pet_link_and_uniqueness.sql"},
		{"013 - Chat Appointment Context", "internal/database/migrations/013_chat_appointment_context.sql"},
	}

	for _, m := range migrations {
		fmt.Printf("\nRunning migration: %s...\n", m.name)
		sql, err := os.ReadFile(m.file)
		if err != nil {
			log.Fatalf("Failed to read migration file %s: %v", m.file, err)
		}

		_, err = pool.Exec(ctx, string(sql))
		if err != nil {
			log.Fatalf("Migration %s failed: %v", m.name, err)
		}
		fmt.Printf("✅ Migration %s completed\n", m.name)
	}

	fmt.Println("\n🎉 All migrations completed successfully!")
}
