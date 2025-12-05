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
// It attempts to connect in this order: Aiven -> Supabase -> Local PostgreSQL
func Initialize() error {
	// Load .env file
	if err := godotenv.Load(); err != nil {
		fmt.Println("Warning: .env file not found, using environment variables")
	}

	// Try Aiven first
	aivenConnString := os.Getenv("aivenConnectionString")
	if aivenConnString != "" {
		pool, err := tryConnect(aivenConnString, "Aiven")
		if err == nil {
			DB = pool
			fmt.Println("✅ Successfully connected to Aiven PostgreSQL database")
			return nil
		}
		fmt.Printf("⚠️  Failed to connect to Aiven: %v\n", err)
	}

	// Try Supabase second
	supabaseConnString := os.Getenv("SupabaseConnectionString")
	if supabaseConnString != "" {
		pool, err := tryConnect(supabaseConnString, "Supabase")
		if err == nil {
			DB = pool
			fmt.Println("✅ Successfully connected to Supabase PostgreSQL database")
			return nil
		}
		fmt.Printf("⚠️  Failed to connect to Supabase: %v\n", err)
	}

	// Fallback to local PostgreSQL
	localConnString := os.Getenv("DATABASE_URL")
	if localConnString == "" {
		// Build local connection string from environment variables or use defaults
		user := os.Getenv("DB_USER")
		if user == "" {
			user = "postgres"
		}
		password := os.Getenv("DB_PASSWORD")
		host := os.Getenv("DB_HOST")
		if host == "" {
			host = "localhost"
		}
		port := os.Getenv("DB_PORT")
		if port == "" {
			port = "5432"
		}
		dbname := os.Getenv("DB_NAME")
		if dbname == "" {
			dbname = "pawpal"
		}

		// Build PostgreSQL connection string
		if password != "" {
			localConnString = fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable", user, password, host, port, dbname)
		} else {
			localConnString = fmt.Sprintf("postgres://%s@%s:%s/%s?sslmode=disable", user, host, port, dbname)
		}
	}

	pool, err := tryConnect(localConnString, "Local PostgreSQL")
	if err != nil {
		return fmt.Errorf("failed to connect to all databases (Aiven, Supabase, Local PostgreSQL): %w", err)
	}

	DB = pool
	fmt.Println("✅ Successfully connected to local PostgreSQL database")
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
