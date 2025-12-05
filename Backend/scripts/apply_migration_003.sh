#!/bin/bash

# Script to apply migration 003 (fix chat schema)
# This fixes the last_message_time -> last_message_at rename issue

echo "Applying migration 003: Fix chat schema..."

# Read database credentials from environment or use defaults
DB_HOST="${DB_HOST:-your-db-host.aiven.com}"
DB_PORT="${DB_PORT:-12345}"
DB_NAME="${DB_NAME:-defaultdb}"
DB_USER="${DB_USER:-avnadmin}"
DB_PASSWORD="${DB_PASSWORD}"

# Check if we have the DATABASE_URL
if [ -n "$DATABASE_URL" ]; then
    echo "Using DATABASE_URL from environment"
    psql "$DATABASE_URL" -f internal/database/migrations/003_fix_chat_schema.sql
else
    echo "Please set DATABASE_URL environment variable"
    echo "Example: export DATABASE_URL='postgres://user:pass@host:port/dbname?sslmode=require'"
    exit 1
fi

echo "Migration 003 applied successfully!"
