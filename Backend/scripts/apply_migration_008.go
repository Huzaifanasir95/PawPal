package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
)

func main() {
	ctx := context.Background()

	_ = godotenv.Load()

	dbURL := strings.TrimSpace(os.Getenv("SupabaseConnectionString"))
	if dbURL == "" {
		dbURL = strings.TrimSpace(os.Getenv("SUPABASE_CONNECTION_STRING"))
	}
	if dbURL == "" {
		log.Fatal("SupabaseConnectionString/SUPABASE_CONNECTION_STRING is not set")
	}

	pool, err := pgxpool.New(ctx, dbURL)
	if err != nil {
		log.Fatalf("failed to create db pool: %v", err)
	}
	defer pool.Close()

	if err := pool.Ping(ctx); err != nil {
		log.Fatalf("database ping failed: %v", err)
	}

	sqlBytes, err := os.ReadFile("internal/database/migrations/008_user_roles.sql")
	if err != nil {
		log.Fatalf("failed to read migration 008 file: %v", err)
	}

	fmt.Println("Applying migration 008_user_roles.sql ...")
	if _, err := pool.Exec(ctx, string(sqlBytes)); err != nil {
		log.Fatalf("migration 008 failed: %v", err)
	}
	fmt.Println("Migration 008 applied successfully")

	verifyAndPrint(ctx, pool)
}

func verifyAndPrint(ctx context.Context, pool *pgxpool.Pool) {
	var tableExists bool
	err := pool.QueryRow(ctx, `
		SELECT EXISTS (
			SELECT 1
			FROM information_schema.tables
			WHERE table_schema = 'public' AND table_name = 'user_roles'
		)
	`).Scan(&tableExists)
	if err != nil {
		log.Fatalf("failed to check table existence: %v", err)
	}

	var idxUserIDExists bool
	err = pool.QueryRow(ctx, `
		SELECT EXISTS (
			SELECT 1
			FROM pg_indexes
			WHERE schemaname = 'public'
			  AND tablename = 'user_roles'
			  AND indexname = 'idx_user_roles_user_id'
		)
	`).Scan(&idxUserIDExists)
	if err != nil {
		log.Fatalf("failed to check idx_user_roles_user_id: %v", err)
	}

	var idxRoleExists bool
	err = pool.QueryRow(ctx, `
		SELECT EXISTS (
			SELECT 1
			FROM pg_indexes
			WHERE schemaname = 'public'
			  AND tablename = 'user_roles'
			  AND indexname = 'idx_user_roles_role'
		)
	`).Scan(&idxRoleExists)
	if err != nil {
		log.Fatalf("failed to check idx_user_roles_role: %v", err)
	}

	var totalUsers int64
	err = pool.QueryRow(ctx, `SELECT COUNT(*) FROM users`).Scan(&totalUsers)
	if err != nil {
		log.Fatalf("failed to count users: %v", err)
	}

	var totalRoleRows int64
	err = pool.QueryRow(ctx, `SELECT COUNT(*) FROM user_roles`).Scan(&totalRoleRows)
	if err != nil {
		log.Fatalf("failed to count user_roles rows: %v", err)
	}

	var usersWithoutRole int64
	err = pool.QueryRow(ctx, `
		SELECT COUNT(*)
		FROM users u
		WHERE NOT EXISTS (
			SELECT 1 FROM user_roles ur WHERE ur.user_id = u.id
		)
	`).Scan(&usersWithoutRole)
	if err != nil {
		log.Fatalf("failed to check users without roles: %v", err)
	}

	fmt.Println("--- Verification ---")
	fmt.Printf("user_roles table exists: %v\n", tableExists)
	fmt.Printf("idx_user_roles_user_id exists: %v\n", idxUserIDExists)
	fmt.Printf("idx_user_roles_role exists: %v\n", idxRoleExists)
	fmt.Printf("users count: %d\n", totalUsers)
	fmt.Printf("user_roles rows: %d\n", totalRoleRows)
	fmt.Printf("users without any role row: %d\n", usersWithoutRole)
	if usersWithoutRole == 0 {
		fmt.Println("Backfill verification passed: every user has at least one role")
	} else {
		fmt.Println("Backfill verification warning: some users are still missing role rows")
	}
}
