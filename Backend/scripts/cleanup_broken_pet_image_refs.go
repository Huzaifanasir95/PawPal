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
)

type petRow struct {
	ID         uuid.UUID
	ImageURL   *string
	ImageLocal *string
	ImageURLs  []string
}

func main() {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Minute)
	defer cancel()

	connStr := strings.TrimSpace(os.Getenv("SupabaseConnectionString"))
	if connStr == "" {
		connStr = strings.TrimSpace(os.Getenv("SUPABASE_CONNECTION_STRING"))
	}
	if connStr == "" {
		log.Fatal("SupabaseConnectionString/SUPABASE_CONNECTION_STRING not set")
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

	rows, err := pool.Query(ctx, `SELECT id, image_url, image_local_path, image_urls FROM pets`)
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()

	updatedRows := 0
	clearedLocal := 0
	clearedArray := 0
	for rows.Next() {
		var p petRow
		if err := rows.Scan(&p.ID, &p.ImageURL, &p.ImageLocal, &p.ImageURLs); err != nil {
			log.Printf("scan failed: %v", err)
			continue
		}

		changed := false

		if p.ImageLocal != nil && isBrokenRef(*p.ImageLocal) {
			p.ImageLocal = nil
			clearedLocal++
			changed = true
		}

		if len(p.ImageURLs) > 0 {
			filtered := make([]string, 0, len(p.ImageURLs))
			for _, v := range p.ImageURLs {
				if isBrokenRef(v) {
					clearedArray++
					changed = true
					continue
				}
				filtered = append(filtered, v)
			}
			p.ImageURLs = filtered
		}

		if changed {
			_, err := pool.Exec(ctx,
				`UPDATE pets SET image_local_path = $1, image_urls = $2, updated_at = NOW() WHERE id = $3`,
				p.ImageLocal, p.ImageURLs, p.ID,
			)
			if err != nil {
				log.Printf("update failed for %s: %v", p.ID, err)
				continue
			}
			updatedRows++
		}
	}

	if err := rows.Err(); err != nil {
		log.Fatal(err)
	}

	fmt.Printf("pet_rows_updated=%d\n", updatedRows)
	fmt.Printf("broken_local_refs_cleared=%d\n", clearedLocal)
	fmt.Printf("broken_array_refs_cleared=%d\n", clearedArray)
}

func isBrokenRef(v string) bool {
	trimmed := strings.ToLower(strings.TrimSpace(v))
	if trimmed == "" {
		return false
	}
	if strings.HasPrefix(trimmed, "blob:") {
		return true
	}
	if strings.Contains(trimmed, "/data/user/") {
		return true
	}
	if strings.HasPrefix(trimmed, "/storage/emulated/") {
		return true
	}
	return false
}
