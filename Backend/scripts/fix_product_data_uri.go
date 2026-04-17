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

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"pawpal-backend/internal/utils"
)

func main() {
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Minute)
	defer cancel()

	connStr := os.Getenv("SupabaseConnectionString")
	if strings.TrimSpace(connStr) == "" {
		connStr = os.Getenv("SUPABASE_CONNECTION_STRING")
	}
	if strings.TrimSpace(connStr) == "" {
		log.Fatal("missing Supabase connection string")
	}

	cfg, err := pgxpool.ParseConfig(connStr)
	if err != nil {
		log.Fatal(err)
	}
	cfg.ConnConfig.DefaultQueryExecMode = pgx.QueryExecModeSimpleProtocol

	pool, err := pgxpool.NewWithConfig(ctx, cfg)
	if err != nil {
		log.Fatal(err)
	}
	defer pool.Close()

	rows, err := pool.Query(ctx, `
		SELECT id, images
		FROM products
		WHERE images IS NOT NULL
	`)
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()

	totalFound := 0
	totalUpdated := 0
	for rows.Next() {
		var id uuid.UUID
		var images []string
		if err := rows.Scan(&id, &images); err != nil {
			log.Printf("scan error: %v", err)
			continue
		}

		changed := false
		for i := range images {
			v := strings.TrimSpace(images[i])
			if !strings.HasPrefix(strings.ToLower(v), "data:image/") {
				continue
			}
			totalFound++
			url, err := utils.ResolveImageReference(ctx, v, fmt.Sprintf("migration/products/images/%s/%d", id.String(), i))
			if err != nil {
				log.Printf("upload failed for product=%s index=%d err=%v", id, i, err)
				continue
			}
			images[i] = url
			changed = true
		}

		if !changed {
			continue
		}

		if _, err := pool.Exec(ctx, `UPDATE products SET images = $1, updated_at = NOW() WHERE id = $2`, images, id); err != nil {
			log.Printf("update failed for product=%s err=%v", id, err)
			continue
		}
		totalUpdated++
	}

	if err := rows.Err(); err != nil {
		log.Fatal(err)
	}

	fmt.Printf("data_uri_found=%d products_updated=%d\n", totalFound, totalUpdated)
}
