package database

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/joho/godotenv"
)

var Supabase *SupabaseClient

// Initialize initializes the Supabase REST API client only
func Initialize() error {
	// Load .env file
	if err := godotenv.Load(); err != nil {
		fmt.Println("Warning: .env file not found, using environment variables")
	}

	// Initialize Supabase REST API client
	Supabase = NewSupabaseClient()
	
	// Test Supabase REST API connection
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	
	if err := Supabase.Health(ctx); err != nil {
		return fmt.Errorf("failed to connect to Supabase REST API: %w", err)
	}
	
	log.Println("✅ Supabase REST API connected successfully!")
	return nil
}

// Close is a no-op for Supabase REST API (HTTP client cleanup is automatic)
func Close() {
	// Nothing to close for REST API
}
