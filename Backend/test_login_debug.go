package main

import (
	"context"
	"fmt"
	"log"

	"pawpal-backend/internal/database"
	"pawpal-backend/internal/repositories"

	"github.com/joho/godotenv"
	"golang.org/x/crypto/bcrypt"
)

func main() {
	// Load .env
	if err := godotenv.Load(); err != nil {
		log.Printf("Warning: .env file not found")
	}

	// Initialize database
	if err := database.Initialize(); err != nil {
		log.Fatalf("Database init failed: %v", err)
	}

	repo := repositories.NewUserRepositorySupabase(database.Supabase)
	ctx := context.Background()
	
	// Use the latest test email from the PowerShell test
	email := "test_1765106654.21814@pawpal.com"
	password := "TestPassword123!"
	
	fmt.Printf("Testing Login Flow for: %s\n", email)
	fmt.Printf("Password: %s\n\n", password)
	
	// Step 1: Get user
	fmt.Println("Step 1: Getting user by email...")
	user, err := repo.GetByEmail(ctx, email)
	if err != nil {
		log.Fatalf("❌ Error getting user: %v", err)
	}
	
	if user == nil {
		log.Fatalf("❌ User not found")
	}
	
	fmt.Printf("✅ User found!\n")
	fmt.Printf("   Email: %s\n", user.Email)
	fmt.Printf("   Is Active: %v\n", user.IsActive)
	fmt.Printf("   Password Hash Length: %d\n", len(user.PasswordHash))
	
	if len(user.PasswordHash) == 0 {
		fmt.Printf("\n❌❌❌ PASSWORD HASH IS EMPTY! ❌❌❌\n")
		fmt.Printf("This is why login fails!\n")
		return
	}
	
	fmt.Printf("   Password Hash: %s...\n", user.PasswordHash[:20])
	
	// Step 2: Verify password
	fmt.Println("\nStep 2: Verifying password...")
	err = bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(password))
	if err != nil {
		fmt.Printf("❌ Password verification FAILED: %v\n", err)
		fmt.Printf("This is the problem with login!\n")
	} else {
		fmt.Printf("✅ Password verification PASSED!\n")
		fmt.Printf("Login SHOULD work - there's something else wrong!\n")
	}
}
