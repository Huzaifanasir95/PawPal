package main

import (
	"context"
	"fmt"
	"log"
	"os"
	
	"github.com/jackc/pgx/v5/pgxpool"
)

func main() {
	ctx := context.Background()
	
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		dbURL = "postgres://avnadmin:AVNS_xpRzMFolxNQFBRWgpHn@pg-1e105d4-hamzasheikh1228-50b4.c.aivencloud.com:21894/defaultdb?sslmode=require"
	}
	
	pool, err := pgxpool.New(ctx, dbURL)
	if err != nil {
		log.Fatal("Unable to connect to database:", err)
	}
	defer pool.Close()
	
	// Execute the migration
	sql := `ALTER TABLE vet_profiles ALTER COLUMN availability_hours TYPE TEXT;`
	
	_, err = pool.Exec(ctx, sql)
	if err != nil {
		log.Fatal("Migration failed:", err)
	}
	
	fmt.Println("✅ Migration 004 completed successfully!")
	fmt.Println("Changed availability_hours column from JSONB to TEXT")
}
