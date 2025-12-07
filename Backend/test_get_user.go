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
		log.Printf("Warning: %v", err)
	}

	repo := repositories.NewUserRepositorySupabase(database.Supabase)
	ctx := context.Background()
	
	// Test GetByEmail
	email := "test_1765087972.371836@pawpal.com"
	fmt.Printf("Testing GetByEmail for: %s\n", email)
	
	user, err := repo.GetByEmail(ctx, email)
	if err != nil {
		log.Fatalf("Error: %v", err)
	}
	
	if user == nil {
		fmt.Println("❌ User not found")
	} else {
		fmt.Printf("✅ User found!\n")
		fmt.Printf("   Email: %s\n", user.Email)
		fmt.Printf("   Password Hash Length: %d\n", len(user.PasswordHash))
		if len(user.PasswordHash) > 0 {
			fmt.Printf("   Password Hash starts with: %s...\n", user.PasswordHash[:10])
		} else {
			fmt.Printf("   ❌ PASSWORD HASH IS EMPTY!\n")
		}
	}
}
