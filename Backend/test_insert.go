package main

import (
	"context"
	"fmt"
	"log"
	"github.com/jackc/pgx/v5/pgxpool"
)

func main() {
	ctx := context.Background()
	
	connStr := "postgresql://avnadmin:AVNS_5fPLf9WbwTNqPUz_HtO@pawpal-firebase-pawpal-firebase.l.aivencloud.com:13812/pawpal-firebase?sslmode=require"
	
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
