//go:build ignore
// +build ignore

package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"strings"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
)

func main() {
	if len(os.Args) < 2 {
		log.Fatal("Usage: go run run_single_migration.go <migration_file>")
	}

	migrationFile := os.Args[1]

	_ = godotenv.Load()

	dbURL := strings.TrimSpace(os.Getenv("SupabaseConnectionString"))
	if dbURL == "" {
		dbURL = strings.TrimSpace(os.Getenv("SUPABASE_CONNECTION_STRING"))
	}
	if dbURL == "" {
		log.Fatal("SupabaseConnectionString/SUPABASE_CONNECTION_STRING not set in environment")
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Minute)
	defer cancel()

	fmt.Println("Connecting to database...")
	pool, err := pgxpool.New(ctx, dbURL)
	if err != nil {
		log.Fatalf("Failed to connect: %v", err)
	}
	defer pool.Close()

	fmt.Println("✅ Connected to database")

	fmt.Printf("\nRunning migration: %s...\n", migrationFile)
	sql, err := os.ReadFile(migrationFile)
	if err != nil {
		log.Fatalf("Failed to read migration file: %v", err)
	}

	_, err = pool.Exec(ctx, string(sql))
	if err != nil {
		log.Fatalf("Migration failed: %v", err)
	}

	fmt.Println("✅ Migration completed successfully!")
}
