# Backend Test Scripts

This directory contains utility scripts for testing and validating Backend functionality.

## Available Scripts

### 1. Supabase Connection Test
**File:** `test_supabase_connection.go`

Tests the connection to Supabase PostgreSQL database and displays connection information.

**Usage:**
```bash
cd Backend/scripts
go run test_supabase_connection.go
```

**What it tests:**
- Connection to Supabase PostgreSQL
- Database credentials validation
- Connection pool statistics
- Database version and metadata
- List of existing tables

**Expected Output:**
- ✅ Successful connection message
- Connection pool statistics
- PostgreSQL version
- Current database and user
- List of tables in the database

---

## Prerequisites

1. **Environment Variables:** Ensure `.env` file exists in `Backend/` directory
2. **Go Dependencies:** Run `go mod tidy` in Backend directory
3. **Database Access:** Valid Supabase credentials configured

---

## Adding New Scripts

To add a new test script:

1. Create a new `.go` file in this directory
2. Import necessary packages
3. Load environment variables using `godotenv`
4. Document the script in this README

---

## Common Issues

**Issue:** `connection refused`
- **Solution:** Check if DB_HOST and DB_PORT are correct in `.env`

**Issue:** `authentication failed`
- **Solution:** Verify DB_USER and DB_PASSWORD in `.env`

**Issue:** `SSL required`
- **Solution:** Set `DB_SSLMODE=require` in `.env`

---

## Environment Variables Reference

Required variables in `.env`:
```env
SUPABASE_URL=https://your-project.supabase.co
DB_HOST=aws-0-region.pooler.supabase.com
DB_PORT=6543
DB_USER=postgres.your-project
DB_PASSWORD=your_password
DB_NAME=postgres
DB_SSLMODE=require
```
