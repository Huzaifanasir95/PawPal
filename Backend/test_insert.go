//go:build ignore

package main

import (
	"context"
	"fmt"
	"log"
	"github.com/jackc/pgx/v5/pgxpool"
)

func main() {
	ctx := context.Background()
	
	connStr := "postgresql://postgres.uicsjgjpvzajvbnvaygb:hz5L8q-5c5z_2UL@aws-1-ap-northeast-2.pooler.supabase.com:6543/postgres"
	
	pool, err := pgxpool.New(ctx, connStr)
	if err != nil {
		log.Fatal("Unable to connect:", err)
	}
	defer pool.Close()
	
	// Test inserting an array
	specializations := []string{"General Practice", "Emergency Care"}
	
	var result []string
	err = pool.QueryRow(ctx, "SELECT $1::text[]", specializations).Scan(&result)
	if err != nil {
		log.Fatal("Query failed:", err)
	}
	
	fmt.Printf("Success! Array: %v\n", result)
}
