#!/usr/bin/env pwsh
# PawPal Backend - Simple Authentication Test Script
# Tests authentication using PowerShell and curl

$baseUrl = "http://localhost:8081"
$testEmail = "test_$(Get-Date -UFormat %s)@pawpal.com"
$testPassword = "TestPassword123!"

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "PawPal Backend - Authentication Test" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Backend URL: $baseUrl"
Write-Host "Test Email: $testEmail"
Write-Host "Test Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

# Variables to store tokens
$accessToken = ""
$refreshToken = ""

# Test 1: User Registration
Write-Host "`n============================================================" -ForegroundColor Yellow
Write-Host "TEST 1: User Registration (Sign Up)" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow

$signupBody = @{
    email = $testEmail
    password = $testPassword
    displayName = "Test User"
} | ConvertTo-Json

Write-Host "POST $baseUrl/api/v1/auth/signup"
Write-Host "Body: $signupBody"

try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/v1/auth/signup" `
        -Method POST `
        -Body $signupBody `
        -ContentType "application/json" `
        -TimeoutSec 10

    Write-Host "`nStatus Code: $($response.StatusCode)" -ForegroundColor Green
    $data = $response.Content | ConvertFrom-Json
    Write-Host "Response: $($response.Content)" -ForegroundColor White
    
    if ($data.success) {
        $accessToken = $data.accessToken
        $refreshToken = $data.refreshToken
        Write-Host "✅ PASS - User registered successfully!" -ForegroundColor Green
        Write-Host "Access Token: $($accessToken.Substring(0, 30))..." -ForegroundColor Gray
        Write-Host "Refresh Token: $($refreshToken.Substring(0, 30))..." -ForegroundColor Gray
    } else {
        Write-Host "❌ FAIL - Registration failed: $($data.message)" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ FAIL - Cannot connect to backend server" -ForegroundColor Red
    Write-Host "Make sure the backend is running: cd Backend && go run cmd/api/main.go" -ForegroundColor Yellow
    exit 1
}

# Test 2: User Login
Write-Host "`n============================================================" -ForegroundColor Yellow
Write-Host "TEST 2: User Login (Sign In)" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow

$signinBody = @{
    email = $testEmail
    password = $testPassword
} | ConvertTo-Json

Write-Host "POST $baseUrl/api/v1/auth/signin"
Write-Host "Body: $signinBody"

try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/v1/auth/signin" `
        -Method POST `
        -Body $signinBody `
        -ContentType "application/json" `
        -TimeoutSec 10

    Write-Host "`nStatus Code: $($response.StatusCode)" -ForegroundColor Green
    $data = $response.Content | ConvertFrom-Json
    Write-Host "Response: $($response.Content)" -ForegroundColor White
    
    if ($data.success) {
        $accessToken = $data.accessToken
        $refreshToken = $data.refreshToken
        Write-Host "✅ PASS - User logged in successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ FAIL - Login failed: $($data.message)" -ForegroundColor Red
    }
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    $errorBody = $_.ErrorDetails.Message
    Write-Host "`nStatus Code: $statusCode" -ForegroundColor Red
    Write-Host "Response: $errorBody" -ForegroundColor Red
    Write-Host "❌ FAIL - Login failed with status $statusCode" -ForegroundColor Red
}

# Test 3: Get User Profile
Write-Host "`n============================================================" -ForegroundColor Yellow
Write-Host "TEST 3: Get User Profile (Protected Route)" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow

Write-Host "GET $baseUrl/api/v1/profile"
Write-Host "Authorization: Bearer $($accessToken.Substring(0, 30))..."

try {
    $headers = @{
        "Authorization" = "Bearer $accessToken"
    }
    
    $response = Invoke-WebRequest -Uri "$baseUrl/api/v1/profile" `
        -Method GET `
        -Headers $headers `
        -TimeoutSec 10

    Write-Host "`nStatus Code: $($response.StatusCode)" -ForegroundColor Green
    $data = $response.Content | ConvertFrom-Json
    Write-Host "Response: $($response.Content)" -ForegroundColor White
    
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ PASS - Profile retrieved successfully!" -ForegroundColor Green
        Write-Host "Email: $($data.data.email)" -ForegroundColor Gray
        Write-Host "Display Name: $($data.data.displayName)" -ForegroundColor Gray
    } else {
        Write-Host "❌ FAIL - Get profile failed" -ForegroundColor Red
    }
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "`nStatus Code: $statusCode" -ForegroundColor Red
    Write-Host "❌ FAIL - Get profile failed" -ForegroundColor Red
}

# Test 4: Update User Profile
Write-Host "`n============================================================" -ForegroundColor Yellow
Write-Host "TEST 4: Update User Profile" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow

$updateBody = @{
    displayName = "Updated Test User"
} | ConvertTo-Json

Write-Host "PUT $baseUrl/api/v1/profile"
Write-Host "Body: $updateBody"

try {
    $headers = @{
        "Authorization" = "Bearer $accessToken"
    }
    
    $response = Invoke-WebRequest -Uri "$baseUrl/api/v1/profile" `
        -Method PUT `
        -Headers $headers `
        -Body $updateBody `
        -ContentType "application/json" `
        -TimeoutSec 10

    Write-Host "`nStatus Code: $($response.StatusCode)" -ForegroundColor Green
    $data = $response.Content | ConvertFrom-Json
    Write-Host "Response: $($response.Content)" -ForegroundColor White
    
    if ($data.success) {
        Write-Host "✅ PASS - Profile updated successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ FAIL - Update profile failed" -ForegroundColor Red
    }
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "`nStatus Code: $statusCode" -ForegroundColor Red
    Write-Host "❌ FAIL - Update profile failed" -ForegroundColor Red
}

# Test 5: Logout
Write-Host "`n============================================================" -ForegroundColor Yellow
Write-Host "TEST 5: User Logout (Sign Out)" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow

$logoutBody = @{
    refreshToken = $refreshToken
} | ConvertTo-Json

Write-Host "POST $baseUrl/api/v1/auth/signout"

try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/v1/auth/signout" `
        -Method POST `
        -Body $logoutBody `
        -ContentType "application/json" `
        -TimeoutSec 10

    Write-Host "`nStatus Code: $($response.StatusCode)" -ForegroundColor Green
    
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ PASS - User logged out successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ FAIL - Logout failed" -ForegroundColor Red
    }
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "`nStatus Code: $statusCode" -ForegroundColor Red
    Write-Host "❌ FAIL - Logout failed" -ForegroundColor Red
}

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "TEST COMPLETE" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
