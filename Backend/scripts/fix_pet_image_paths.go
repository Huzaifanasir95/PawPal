//go:build ignore
// +build ignore

package main

import (
	"context"
	"encoding/base64"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"pawpal-backend/internal/utils"
)

type petRow struct {
	ID            uuid.UUID
	ImageURL      *string
	ImageLocal    *string
	ImageURLArray []string
}

func main() {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Minute)
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
		log.Fatalf("parse config failed: %v", err)
	}
	cfg.ConnConfig.DefaultQueryExecMode = pgx.QueryExecModeSimpleProtocol

	pool, err := pgxpool.NewWithConfig(ctx, cfg)
	if err != nil {
		log.Fatalf("db connect failed: %v", err)
	}
	defer pool.Close()

	rows, err := pool.Query(ctx, `
		SELECT id, image_url, image_local_path, image_urls
		FROM pets
		WHERE image_local_path IS NOT NULL
		   OR (image_urls IS NOT NULL AND cardinality(image_urls) > 0)
	`)
	if err != nil {
		log.Fatalf("query failed: %v", err)
	}
	defer rows.Close()

	backendRoot, _ := os.Getwd()

	totalCandidates := 0
	totalUploaded := 0
	totalUpdated := 0
	totalMissingFiles := 0

	for rows.Next() {
		var p petRow
		if err := rows.Scan(&p.ID, &p.ImageURL, &p.ImageLocal, &p.ImageURLArray); err != nil {
			log.Printf("scan failed: %v", err)
			continue
		}

		updated := false

		for i, img := range p.ImageURLArray {
			img = strings.TrimSpace(img)
			if img == "" || isHTTPURL(img) || isDataURI(img) {
				continue
			}

			totalCandidates++
			resolvedFile := resolveLocalImagePath(backendRoot, img)
			if resolvedFile == "" {
				totalMissingFiles++
				log.Printf("pet=%s image_urls[%d]: file not found for path=%q", p.ID, i, img)
				continue
			}

			b64, err := fileToBase64(resolvedFile)
			if err != nil {
				log.Printf("pet=%s image_urls[%d]: read failed: %v", p.ID, i, err)
				continue
			}

			url, err := utils.ResolveImageReference(ctx, b64, fmt.Sprintf("migration/pets/%s/image_urls/%d", p.ID, i))
			if err != nil || strings.TrimSpace(url) == "" {
				log.Printf("pet=%s image_urls[%d]: upload failed: %v", p.ID, i, err)
				continue
			}

			p.ImageURLArray[i] = url
			totalUploaded++
			updated = true
		}

		if p.ImageLocal != nil {
			localVal := strings.TrimSpace(*p.ImageLocal)
			if localVal != "" && !isHTTPURL(localVal) && !isDataURI(localVal) {
				totalCandidates++
				resolvedFile := resolveLocalImagePath(backendRoot, localVal)
				if resolvedFile == "" {
					totalMissingFiles++
					log.Printf("pet=%s image_local_path: file not found for path=%q", p.ID, localVal)
				} else {
					b64, err := fileToBase64(resolvedFile)
					if err != nil {
						log.Printf("pet=%s image_local_path: read failed: %v", p.ID, err)
					} else {
						url, err := utils.ResolveImageReference(ctx, b64, fmt.Sprintf("migration/pets/%s/image_local_path", p.ID))
						if err != nil || strings.TrimSpace(url) == "" {
							log.Printf("pet=%s image_local_path: upload failed: %v", p.ID, err)
						} else {
							if p.ImageURL == nil || strings.TrimSpace(*p.ImageURL) == "" {
								p.ImageURL = &url
							}
							if !contains(p.ImageURLArray, url) {
								p.ImageURLArray = append(p.ImageURLArray, url)
							}
							p.ImageLocal = nil
							totalUploaded++
							updated = true
						}
					}
				}
			}
		}

		if updated {
			_, err := pool.Exec(ctx,
				`UPDATE pets SET image_url = $1, image_local_path = $2, image_urls = $3, updated_at = NOW() WHERE id = $4`,
				p.ImageURL, p.ImageLocal, p.ImageURLArray, p.ID,
			)
			if err != nil {
				log.Printf("pet=%s update failed: %v", p.ID, err)
				continue
			}
			totalUpdated++
		}
	}

	if err := rows.Err(); err != nil {
		log.Fatalf("rows err: %v", err)
	}

	fmt.Printf("pet_image_candidates=%d\n", totalCandidates)
	fmt.Printf("pet_image_uploaded=%d\n", totalUploaded)
	fmt.Printf("pet_rows_updated=%d\n", totalUpdated)
	fmt.Printf("pet_missing_files=%d\n", totalMissingFiles)
}

func resolveLocalImagePath(backendRoot, raw string) string {
	candidates := []string{}
	v := strings.TrimSpace(raw)
	v = strings.TrimPrefix(v, "file://")

	if filepath.IsAbs(v) {
		candidates = append(candidates, v)
	}

	candidates = append(candidates,
		filepath.Join(backendRoot, v),
		filepath.Join(backendRoot, strings.TrimPrefix(v, "/")),
		filepath.Join(backendRoot, "assets", "uploads", filepath.Base(v)),
	)

	for _, c := range candidates {
		info, err := os.Stat(c)
		if err == nil && !info.IsDir() {
			return c
		}
	}
	return ""
}

func fileToBase64(path string) (string, error) {
	b, err := os.ReadFile(path)
	if err != nil {
		return "", err
	}
	return base64.StdEncoding.EncodeToString(b), nil
}

func isHTTPURL(v string) bool {
	lower := strings.ToLower(strings.TrimSpace(v))
	return strings.HasPrefix(lower, "http://") || strings.HasPrefix(lower, "https://")
}

func isDataURI(v string) bool {
	return strings.HasPrefix(strings.ToLower(strings.TrimSpace(v)), "data:image/")
}

func contains(values []string, target string) bool {
	for _, v := range values {
		if strings.TrimSpace(v) == strings.TrimSpace(target) {
			return true
		}
	}
	return false
}
