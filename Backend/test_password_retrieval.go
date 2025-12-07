package main

import (
	"context"
	"fmt"
	"log"

	"pawpal-backend/internal/database"
	"pawpal-backend/internal/repositories"

	"github.com/joho/godotenv"
)

func main() {
	// Load .env
	if err := godotenv.Load(); err != nil {
		log.Printf("Warning: .env file not found")
	}

	// Initialize database
	if err := database.Initialize(); err != nil {
		log.Printf("Warning: Database initialization had errors: %v", err)
		log.Println("Continuing with Supabase REST API only...")
	}

	// Create Supabase repository
	if database.Supabase == nil {
		log.Fatal("Supabase client not initialized")
	}

	repo := repositories.NewUserRepositorySupabase(database.Supabase)

	// Test GetByEmail (legacy method)
	ctx := context.Background()
	
	// Try to get a user that should exist
	fmt.Println("Testing GetByEmail for test user...")
	user, err := repo.GetByEmail(ctx, "test_1765087269.616778@pawpal.com")
	if err != nil {
		log.Printf("Error: %v", err)
	}
	
	if user == nil {
		fmt.Println("User not found (this is okay if it doesn't exist yet)")
	} else {
		fmt.Printf("✅ User found!\n")
		fmt.Printf("   ID: %s\n", user.ID)
		fmt.Printf("   Email: %s\n", user.Email)
		fmt.Printf("   Display Name: %v\n", user.DisplayName)
		fmt.Printf("   Password Hash Length: %d\n", len(user.PasswordHash))
		if len(user.PasswordHash) > 0 {
			fmt.Printf("   Password Hash Preview: %s...\n", user.PasswordHash[:20])
		} else {
			fmt.Printf("   ❌ PASSWORD HASH IS EMPTY!\n")
		}
	}
}
