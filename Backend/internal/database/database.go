package database

import (
	"context"
	"fmt"
	"os"
	"time"

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

// Initialize initializes the database connection pool
func Initialize() error {
	// Load .env file
	if err := godotenv.Load(); err != nil {
		fmt.Println("Warning: .env file not found, using environment variables")
	}

	connString := os.Getenv("SupabaseConnectionString")
	if connString == "" {
		return fmt.Errorf("SupabaseConnectionString environment variable not set")
	}

	config, err := pgxpool.ParseConfig(connString)
	if err != nil {
		return fmt.Errorf("failed to parse connection string: %w", err)
	}

	// Configure pool settings
	config.MaxConns = 25
	config.MinConns = 5
	config.MaxConnLifetime = time.Hour
	config.MaxConnIdleTime = 30 * time.Minute

	// Create the connection pool
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	pool, err := pgxpool.NewWithConfig(ctx, config)
	if err != nil {
		return fmt.Errorf("failed to create connection pool: %w", err)
	}

	// Verify connection
	if err := pool.Ping(ctx); err != nil {
		return fmt.Errorf("failed to ping database: %w", err)
	}

	DB = pool
	fmt.Println("✅ Successfully connected to Supabase PostgreSQL database")
	return nil
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
