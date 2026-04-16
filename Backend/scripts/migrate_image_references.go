//go:build ignore
// +build ignore

package main

import (
	"context"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"log"
	"os"
	"regexp"
	"sort"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"pawpal-backend/internal/utils"
)

type columnMeta struct {
	TableName  string
	ColumnName string
	DataType   string
}

type tablePK struct {
	TableName string
	PKColumn  string
}

type stats struct {
	Total       int
	HTTPURL     int
	DataURI     int
	RawBase64   int
	OtherString int
}

var base64Like = regexp.MustCompile(`^[A-Za-z0-9+/=\r\n]+$`)

func main() {
	apply := flag.Bool("apply", false, "Apply migration and write URLs back to DB")
	limit := flag.Int("limit", 0, "Limit rows per column in apply mode (0 = no limit)")
	flag.Parse()

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Minute)
	defer cancel()

	connStr := os.Getenv("SupabaseConnectionString")
	if strings.TrimSpace(connStr) == "" {
		connStr = os.Getenv("SUPABASE_CONNECTION_STRING")
	}
	if strings.TrimSpace(connStr) == "" {
		log.Fatal("SupabaseConnectionString/SUPABASE_CONNECTION_STRING not set")
	}

	cfg, err := pgxpool.ParseConfig(connStr)
	if err != nil {
		log.Fatalf("failed to parse connection string: %v", err)
	}
	cfg.ConnConfig.DefaultQueryExecMode = pgx.QueryExecModeSimpleProtocol

	pool, err := pgxpool.NewWithConfig(ctx, cfg)
	if err != nil {
		log.Fatalf("failed to create db pool: %v", err)
	}
	defer pool.Close()

	if err := pool.Ping(ctx); err != nil {
		log.Fatalf("failed to ping db: %v", err)
	}

	cols, err := discoverImageColumns(ctx, pool)
	if err != nil {
		log.Fatalf("discover columns failed: %v", err)
	}
	if len(cols) == 0 {
		fmt.Println("No image-related columns found.")
		return
	}

	pkMap, err := discoverPrimaryKeys(ctx, pool)
	if err != nil {
		log.Fatalf("discover primary keys failed: %v", err)
	}

	fmt.Println("=== Image Field Scan ===")
	for _, col := range cols {
		s, err := scanColumnStats(ctx, pool, col)
		if err != nil {
			fmt.Printf("%s.%s (%s): scan error: %v\n", col.TableName, col.ColumnName, col.DataType, err)
			continue
		}
		fmt.Printf("%s.%s (%s): total=%d, url=%d, data_uri=%d, raw_base64=%d, other=%d\n",
			col.TableName, col.ColumnName, col.DataType,
			s.Total, s.HTTPURL, s.DataURI, s.RawBase64, s.OtherString)
	}

	if !*apply {
		fmt.Println("\nDry run only. Re-run with --apply to migrate byte/data-uri fields to Supabase Storage URLs.")
		return
	}

	type tableColumn struct {
		table  string
		column string
	}
	migrated := 0
	errorsCount := 0
	byColumnMigrated := map[tableColumn]int{}
	byColumnErrors := map[tableColumn]int{}

	fmt.Println("\n=== Applying Migration ===")
	for _, col := range cols {
		pk, ok := pkMap[col.TableName]
		if !ok || pk == "" {
			fmt.Printf("Skipping %s.%s: no primary key discovered\n", col.TableName, col.ColumnName)
			continue
		}

		m, e := migrateColumn(ctx, pool, col, pk, *limit)
		migrated += m
		errorsCount += e
		key := tableColumn{table: col.TableName, column: col.ColumnName}
		byColumnMigrated[key] = m
		byColumnErrors[key] = e
	}

	fmt.Println("\n=== Migration Summary ===")
	keys := make([]tableColumn, 0, len(byColumnMigrated))
	for k := range byColumnMigrated {
		keys = append(keys, k)
	}
	sort.Slice(keys, func(i, j int) bool {
		if keys[i].table == keys[j].table {
			return keys[i].column < keys[j].column
		}
		return keys[i].table < keys[j].table
	})
	for _, k := range keys {
		fmt.Printf("%s.%s: migrated=%d, errors=%d\n", k.table, k.column, byColumnMigrated[k], byColumnErrors[k])
	}
	fmt.Printf("\nTotal migrated values: %d\n", migrated)
	fmt.Printf("Total errors: %d\n", errorsCount)
}

func discoverImageColumns(ctx context.Context, pool *pgxpool.Pool) ([]columnMeta, error) {
	query := `
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND (
	lower(column_name) LIKE '%image%'
	OR lower(column_name) LIKE '%avatar%'
	OR lower(column_name) LIKE '%photo%'
  )
  AND data_type IN ('text', 'character varying', 'jsonb', 'ARRAY')
ORDER BY table_name, column_name;`

	rows, err := pool.Query(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	cols := make([]columnMeta, 0)
	for rows.Next() {
		var c columnMeta
		if err := rows.Scan(&c.TableName, &c.ColumnName, &c.DataType); err != nil {
			return nil, err
		}
		cols = append(cols, c)
	}
	return cols, rows.Err()
}

func discoverPrimaryKeys(ctx context.Context, pool *pgxpool.Pool) (map[string]string, error) {
	query := `
SELECT tc.table_name, kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
 AND tc.table_schema = kcu.table_schema
WHERE tc.table_schema = 'public'
  AND tc.constraint_type = 'PRIMARY KEY'
ORDER BY tc.table_name, kcu.ordinal_position;`

	rows, err := pool.Query(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	pkMap := map[string]string{}
	for rows.Next() {
		var t, c string
		if err := rows.Scan(&t, &c); err != nil {
			return nil, err
		}
		if _, exists := pkMap[t]; !exists {
			pkMap[t] = c
		}
	}
	return pkMap, rows.Err()
}

func scanColumnStats(ctx context.Context, pool *pgxpool.Pool, col columnMeta) (stats, error) {
	if col.DataType == "jsonb" {
		return scanJSONBStats(ctx, pool, col)
	}
	if col.DataType == "ARRAY" {
		return scanArrayStats(ctx, pool, col)
	}
	return scanTextStats(ctx, pool, col)
}

func scanTextStats(ctx context.Context, pool *pgxpool.Pool, col columnMeta) (stats, error) {
	query := fmt.Sprintf(`SELECT %s FROM %s WHERE %s IS NOT NULL`, pgx.Identifier{col.ColumnName}.Sanitize(), pgx.Identifier{col.TableName}.Sanitize(), pgx.Identifier{col.ColumnName}.Sanitize())
	rows, err := pool.Query(ctx, query)
	if err != nil {
		return stats{}, err
	}
	defer rows.Close()

	s := stats{}
	for rows.Next() {
		var v string
		if err := rows.Scan(&v); err != nil {
			return stats{}, err
		}
		kind := classify(v)
		s.Total++
		switch kind {
		case "url":
			s.HTTPURL++
		case "data_uri":
			s.DataURI++
		case "raw_base64":
			s.RawBase64++
		default:
			s.OtherString++
		}
	}
	return s, rows.Err()
}

func scanJSONBStats(ctx context.Context, pool *pgxpool.Pool, col columnMeta) (stats, error) {
	query := fmt.Sprintf(`SELECT %s FROM %s WHERE %s IS NOT NULL`, pgx.Identifier{col.ColumnName}.Sanitize(), pgx.Identifier{col.TableName}.Sanitize(), pgx.Identifier{col.ColumnName}.Sanitize())
	rows, err := pool.Query(ctx, query)
	if err != nil {
		return stats{}, err
	}
	defer rows.Close()

	s := stats{}
	for rows.Next() {
		var raw []byte
		if err := rows.Scan(&raw); err != nil {
			return stats{}, err
		}

		vals, err := jsonArrayStrings(raw)
		if err != nil {
			continue
		}
		for _, v := range vals {
			kind := classify(v)
			s.Total++
			switch kind {
			case "url":
				s.HTTPURL++
			case "data_uri":
				s.DataURI++
			case "raw_base64":
				s.RawBase64++
			default:
				s.OtherString++
			}
		}
	}
	return s, rows.Err()
}

func scanArrayStats(ctx context.Context, pool *pgxpool.Pool, col columnMeta) (stats, error) {
	query := fmt.Sprintf(`SELECT %s FROM %s WHERE %s IS NOT NULL`, pgx.Identifier{col.ColumnName}.Sanitize(), pgx.Identifier{col.TableName}.Sanitize(), pgx.Identifier{col.ColumnName}.Sanitize())
	rows, err := pool.Query(ctx, query)
	if err != nil {
		return stats{}, err
	}
	defer rows.Close()

	s := stats{}
	for rows.Next() {
		var vals []string
		if err := rows.Scan(&vals); err != nil {
			return stats{}, err
		}

		for _, v := range vals {
			kind := classify(v)
			s.Total++
			switch kind {
			case "url":
				s.HTTPURL++
			case "data_uri":
				s.DataURI++
			case "raw_base64":
				s.RawBase64++
			default:
				s.OtherString++
			}
		}
	}
	return s, rows.Err()
}

func migrateColumn(ctx context.Context, pool *pgxpool.Pool, col columnMeta, pkColumn string, limit int) (int, int) {
	if col.DataType == "jsonb" {
		return migrateJSONBColumn(ctx, pool, col, pkColumn, limit)
	}
	if col.DataType == "ARRAY" {
		return migrateArrayColumn(ctx, pool, col, pkColumn, limit)
	}
	return migrateTextColumn(ctx, pool, col, pkColumn, limit)
}

func migrateTextColumn(ctx context.Context, pool *pgxpool.Pool, col columnMeta, pkColumn string, limit int) (int, int) {
	limitClause := ""
	if limit > 0 {
		limitClause = fmt.Sprintf(" LIMIT %d", limit)
	}

	query := fmt.Sprintf(
		"SELECT %s, %s FROM %s WHERE %s IS NOT NULL%s",
		pgx.Identifier{pkColumn}.Sanitize(),
		pgx.Identifier{col.ColumnName}.Sanitize(),
		pgx.Identifier{col.TableName}.Sanitize(),
		pgx.Identifier{col.ColumnName}.Sanitize(),
		limitClause,
	)

	rows, err := pool.Query(ctx, query)
	if err != nil {
		fmt.Printf("Error reading %s.%s: %v\n", col.TableName, col.ColumnName, err)
		return 0, 1
	}
	defer rows.Close()

	migrated := 0
	errorsCount := 0
	for rows.Next() {
		var id any
		var v string
		if err := rows.Scan(&id, &v); err != nil {
			errorsCount++
			continue
		}

		kind := classify(v)
		if kind != "data_uri" && kind != "raw_base64" {
			continue
		}

		newURL, err := utils.ResolveImageReference(ctx, v, fmt.Sprintf("migration/%s/%s", col.TableName, col.ColumnName))
		if err != nil || strings.TrimSpace(newURL) == "" {
			errorsCount++
			continue
		}

		updateSQL := fmt.Sprintf(
			"UPDATE %s SET %s = $1 WHERE %s = $2",
			pgx.Identifier{col.TableName}.Sanitize(),
			pgx.Identifier{col.ColumnName}.Sanitize(),
			pgx.Identifier{pkColumn}.Sanitize(),
		)
		if _, err := pool.Exec(ctx, updateSQL, newURL, id); err != nil {
			errorsCount++
			continue
		}
		migrated++
	}

	if err := rows.Err(); err != nil {
		errorsCount++
	}
	return migrated, errorsCount
}

func migrateJSONBColumn(ctx context.Context, pool *pgxpool.Pool, col columnMeta, pkColumn string, limit int) (int, int) {
	limitClause := ""
	if limit > 0 {
		limitClause = fmt.Sprintf(" LIMIT %d", limit)
	}

	query := fmt.Sprintf(
		"SELECT %s, %s FROM %s WHERE %s IS NOT NULL%s",
		pgx.Identifier{pkColumn}.Sanitize(),
		pgx.Identifier{col.ColumnName}.Sanitize(),
		pgx.Identifier{col.TableName}.Sanitize(),
		pgx.Identifier{col.ColumnName}.Sanitize(),
		limitClause,
	)

	rows, err := pool.Query(ctx, query)
	if err != nil {
		fmt.Printf("Error reading %s.%s: %v\n", col.TableName, col.ColumnName, err)
		return 0, 1
	}
	defer rows.Close()

	migrated := 0
	errorsCount := 0
	for rows.Next() {
		var id any
		var raw []byte
		if err := rows.Scan(&id, &raw); err != nil {
			errorsCount++
			continue
		}

		vals, err := jsonArrayStrings(raw)
		if err != nil || len(vals) == 0 {
			continue
		}

		changed := false
		for i := range vals {
			kind := classify(vals[i])
			if kind != "data_uri" && kind != "raw_base64" {
				continue
			}
			newURL, err := utils.ResolveImageReference(ctx, vals[i], fmt.Sprintf("migration/%s/%s", col.TableName, col.ColumnName))
			if err != nil || strings.TrimSpace(newURL) == "" {
				errorsCount++
				continue
			}
			vals[i] = newURL
			changed = true
			migrated++
		}

		if !changed {
			continue
		}

		updatedRaw, err := json.Marshal(vals)
		if err != nil {
			errorsCount++
			continue
		}

		updateSQL := fmt.Sprintf(
			"UPDATE %s SET %s = $1::jsonb WHERE %s = $2",
			pgx.Identifier{col.TableName}.Sanitize(),
			pgx.Identifier{col.ColumnName}.Sanitize(),
			pgx.Identifier{pkColumn}.Sanitize(),
		)
		if _, err := pool.Exec(ctx, updateSQL, string(updatedRaw), id); err != nil {
			errorsCount++
			continue
		}
	}

	if err := rows.Err(); err != nil {
		errorsCount++
	}
	return migrated, errorsCount
}

func migrateArrayColumn(ctx context.Context, pool *pgxpool.Pool, col columnMeta, pkColumn string, limit int) (int, int) {
	limitClause := ""
	if limit > 0 {
		limitClause = fmt.Sprintf(" LIMIT %d", limit)
	}

	query := fmt.Sprintf(
		"SELECT %s, %s FROM %s WHERE %s IS NOT NULL%s",
		pgx.Identifier{pkColumn}.Sanitize(),
		pgx.Identifier{col.ColumnName}.Sanitize(),
		pgx.Identifier{col.TableName}.Sanitize(),
		pgx.Identifier{col.ColumnName}.Sanitize(),
		limitClause,
	)

	rows, err := pool.Query(ctx, query)
	if err != nil {
		fmt.Printf("Error reading %s.%s: %v\n", col.TableName, col.ColumnName, err)
		return 0, 1
	}
	defer rows.Close()

	migrated := 0
	errorsCount := 0
	for rows.Next() {
		var id any
		var vals []string
		if err := rows.Scan(&id, &vals); err != nil {
			errorsCount++
			continue
		}

		changed := false
		for i := range vals {
			kind := classify(vals[i])
			if kind != "data_uri" && kind != "raw_base64" {
				continue
			}
			newURL, err := utils.ResolveImageReference(ctx, vals[i], fmt.Sprintf("migration/%s/%s", col.TableName, col.ColumnName))
			if err != nil || strings.TrimSpace(newURL) == "" {
				errorsCount++
				continue
			}
			vals[i] = newURL
			changed = true
			migrated++
		}

		if !changed {
			continue
		}

		updateSQL := fmt.Sprintf(
			"UPDATE %s SET %s = $1 WHERE %s = $2",
			pgx.Identifier{col.TableName}.Sanitize(),
			pgx.Identifier{col.ColumnName}.Sanitize(),
			pgx.Identifier{pkColumn}.Sanitize(),
		)
		if _, err := pool.Exec(ctx, updateSQL, vals, id); err != nil {
			errorsCount++
			continue
		}
	}

	if err := rows.Err(); err != nil {
		errorsCount++
	}
	return migrated, errorsCount
}

func jsonArrayStrings(raw []byte) ([]string, error) {
	if len(raw) == 0 {
		return nil, nil
	}

	var arr []string
	if err := json.Unmarshal(raw, &arr); err == nil {
		return arr, nil
	}

	var single string
	if err := json.Unmarshal(raw, &single); err == nil {
		if strings.TrimSpace(single) == "" {
			return nil, nil
		}
		return []string{single}, nil
	}

	return nil, errors.New("json value is not string array")
}

func classify(v string) string {
	trimmed := strings.TrimSpace(v)
	if trimmed == "" {
		return "other"
	}
	lower := strings.ToLower(trimmed)
	if strings.HasPrefix(lower, "http://") || strings.HasPrefix(lower, "https://") {
		return "url"
	}
	if strings.HasPrefix(lower, "data:image/") {
		return "data_uri"
	}

	compact := strings.ReplaceAll(strings.ReplaceAll(trimmed, "\n", ""), "\r", "")
	if len(compact) >= 100 && base64Like.MatchString(compact) {
		return "raw_base64"
	}
	return "other"
}
