# Script to insert Community Hub test data into Supabase database

Write-Host "=== Community Hub Test Data Insertion ===" -ForegroundColor Cyan
Write-Host ""

# Load environment variables
$envFile = Join-Path (Join-Path $PSScriptRoot "..") ".env"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^([^=]+)=(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            [Environment]::SetEnvironmentVariable($key, $value, "Process")
        }
    }
}

$connectionString = $env:SUPABASE_CONNECTION_STRING

if (-not $connectionString) {
    Write-Host "ERROR: SUPABASE_CONNECTION_STRING not found in .env file" -ForegroundColor Red
    exit 1
}

Write-Host "Connection string loaded from .env" -ForegroundColor Green
Write-Host ""

# Check if psql is available
$psqlPath = Get-Command psql -ErrorAction SilentlyContinue
if (-not $psqlPath) {
    Write-Host "ERROR: psql is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install PostgreSQL client tools or use the Supabase SQL Editor" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "=== Alternative: Use Supabase SQL Editor ===" -ForegroundColor Cyan
    Write-Host "1. Go to: https://supabase.com/dashboard/project/uicsjgjpvzajvbnvaygb/sql" -ForegroundColor White
    Write-Host "2. First, run this query to get a user ID:" -ForegroundColor White
    Write-Host "   SELECT id, email FROM users LIMIT 5;" -ForegroundColor Gray
    Write-Host "3. Copy one of the user IDs" -ForegroundColor White
    Write-Host "4. Open: Backend\scripts\insert_community_test_data.sql" -ForegroundColor White
    Write-Host "5. Replace all 'YOUR_USER_ID_HERE' with the copied user ID" -ForegroundColor White
    Write-Host "6. Copy the entire SQL content and paste into Supabase SQL Editor" -ForegroundColor White
    Write-Host "7. Click 'Run' to execute" -ForegroundColor White
    exit 1
}

Write-Host "Step 1: Getting a valid user ID from database..." -ForegroundColor Yellow

# Get a user ID
$getUserQuery = "SELECT id FROM users LIMIT 1;"
$userId = & psql $connectionString -t -c $getUserQuery 2>$null

if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($userId)) {
    Write-Host "ERROR: Could not fetch user ID. Make sure you have users in the database." -ForegroundColor Red
    Write-Host "You need to register at least one user in the app first." -ForegroundColor Yellow
    exit 1
}

$userId = $userId.Trim()
Write-Host "Found user ID: $userId" -ForegroundColor Green
Write-Host ""

Write-Host "Step 2: Preparing SQL with user ID..." -ForegroundColor Yellow

# Read SQL file and replace placeholder
$sqlFile = Join-Path $PSScriptRoot "insert_community_test_data.sql"
if (-not (Test-Path $sqlFile)) {
    Write-Host "ERROR: SQL file not found: $sqlFile" -ForegroundColor Red
    exit 1
}

$sqlContent = Get-Content $sqlFile -Raw
$sqlContent = $sqlContent -replace 'YOUR_USER_ID_HERE', $userId

# Create temporary file with replaced content
$tempSqlFile = Join-Path $env:TEMP "community_test_data_temp.sql"
$sqlContent | Out-File -FilePath $tempSqlFile -Encoding UTF8
Write-Host "SQL prepared successfully" -ForegroundColor Green
Write-Host ""

Write-Host "Step 3: Inserting test data into database..." -ForegroundColor Yellow
Write-Host ""

# Execute SQL
& psql $connectionString -f $tempSqlFile

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "SUCCESS! Test data inserted successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Inserted data:" -ForegroundColor Cyan
    Write-Host "  - 3 Lost & Found posts" -ForegroundColor White
    Write-Host "  - 4 Adoption listings (dog, cat, dog, bird)" -ForegroundColor White
    Write-Host "  - 5 Events (meetup, adoption drive, training, competition, charity)" -ForegroundColor White
    Write-Host ""
    Write-Host "You can now launch the Flutter app and navigate to Community Hub!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "ERROR: Failed to insert data" -ForegroundColor Red
    Write-Host "Check the error messages above" -ForegroundColor Yellow
}

# Cleanup
Remove-Item $tempSqlFile -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "=== Done ===" -ForegroundColor Cyan
