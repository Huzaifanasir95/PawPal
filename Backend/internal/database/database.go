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
	fmt.Println("✅ Successfully connected to Supabase PostgreSQL database")
	return nil
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
