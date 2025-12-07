#!/usr/bin/env pwsh
# PawPal Backend - Pet Management Test Script
# Tests pet CRUD operations using PowerShell and curl

$baseUrl = "http://localhost:8081"
$testEmail = "petowner_$(Get-Date -UFormat %s)@pawpal.com"
$testPassword = "TestPassword123!"

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "PawPal Backend - Pet Management Test" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Backend URL: $baseUrl"
Write-Host "Test Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

# Variables
$accessToken = ""
$petId = ""

# Step 1: Register and Login
Write-Host "`n============================================================" -ForegroundColor Yellow
Write-Host "STEP 1: User Registration & Login" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow

$signupBody = @{
    email = $testEmail
    password = $testPassword
    displayName = "Pet Owner Test"
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/v1/auth/signup" `
        -Method POST `
        -Body $signupBody `
        -ContentType "application/json" `
        -TimeoutSec 10

    $data = $response.Content | ConvertFrom-Json
    $accessToken = $data.accessToken
    Write-Host "User registered and logged in successfully!" -ForegroundColor Green
    Write-Host "Access Token: $($accessToken.Substring(0, 30))..." -ForegroundColor Gray
} catch {
    Write-Host "Failed to register user" -ForegroundColor Red
    exit 1
}

# Test 1: Create Pet
Write-Host "`n============================================================" -ForegroundColor Yellow
Write-Host "TEST 1: Create Pet" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow

$createPetBody = @{
    name = "Buddy"
    type = "dog"
    breed = "Golden Retriever"
    age = 3
    ageUnit = "years"
    gender = "male"
    color = "golden"
    weight = 30.5
    weightUnit = "kg"
    bio = "Friendly and energetic golden retriever"
} | ConvertTo-Json

Write-Host "POST $baseUrl/api/v1/pets"
Write-Host "Body: $createPetBody"

try {
    $headers = @{
        "Authorization" = "Bearer $accessToken"
    }
    
    $response = Invoke-WebRequest -Uri "$baseUrl/api/v1/pets" `
        -Method POST `
        -Headers $headers `
        -Body $createPetBody `
        -ContentType "application/json" `
        -TimeoutSec 10

    Write-Host "`nStatus Code: $($response.StatusCode)" -ForegroundColor Green
    $data = $response.Content | ConvertFrom-Json
    Write-Host "Response: $($response.Content)" -ForegroundColor White
    
    if ($data.success) {
        $petId = $data.pet.id
        Write-Host "PASS - Pet created successfully!" -ForegroundColor Green
        Write-Host "Pet ID: $petId" -ForegroundColor Gray
        Write-Host "Pet Name: $($data.pet.name)" -ForegroundColor Gray
        Write-Host "Pet Breed: $($data.pet.breed)" -ForegroundColor Gray
    } else {
        Write-Host "FAIL - Create pet failed" -ForegroundColor Red
    }
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    $errorBody = $_.ErrorDetails.Message
    Write-Host "`nStatus Code: $statusCode" -ForegroundColor Red
    Write-Host "Response: $errorBody" -ForegroundColor Red
    Write-Host "FAIL - Create pet failed" -ForegroundColor Red
}

# Test 2: Get All Pets
Write-Host "`n============================================================" -ForegroundColor Yellow
Write-Host "TEST 2: Get All User's Pets" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow

Write-Host "GET $baseUrl/api/v1/pets"

try {
    $headers = @{
        "Authorization" = "Bearer $accessToken"
    }
    
    $response = Invoke-WebRequest -Uri "$baseUrl/api/v1/pets" `
        -Method GET `
        -Headers $headers `
        -TimeoutSec 10

    Write-Host "`nStatus Code: $($response.StatusCode)" -ForegroundColor Green
    $data = $response.Content | ConvertFrom-Json
    Write-Host "Response: $($response.Content)" -ForegroundColor White
    
    if ($response.StatusCode -eq 200) {
        Write-Host "PASS - Pets retrieved successfully!" -ForegroundColor Green
        Write-Host "Total Pets: $($data.pets.Count)" -ForegroundColor Gray
    } else {
        Write-Host "FAIL - Get pets failed" -ForegroundColor Red
    }
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "`nStatus Code: $statusCode" -ForegroundColor Red
    Write-Host "FAIL - Get pets failed" -ForegroundColor Red
}

# Test 3: Get Single Pet
Write-Host "`n============================================================" -ForegroundColor Yellow
Write-Host "TEST 3: Get Single Pet by ID" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow

Write-Host "GET $baseUrl/api/v1/pets/$petId"

try {
    $headers = @{
        "Authorization" = "Bearer $accessToken"
    }
    
    $response = Invoke-WebRequest -Uri "$baseUrl/api/v1/pets/$petId" `
        -Method GET `
        -Headers $headers `
        -TimeoutSec 10

    Write-Host "`nStatus Code: $($response.StatusCode)" -ForegroundColor Green
    $data = $response.Content | ConvertFrom-Json
    Write-Host "Response: $($response.Content)" -ForegroundColor White
    
    if ($response.StatusCode -eq 200) {
        Write-Host "PASS - Pet retrieved successfully!" -ForegroundColor Green
        Write-Host "Pet Name: $($data.pet.name)" -ForegroundColor Gray
        Write-Host "Pet Breed: $($data.pet.breed)" -ForegroundColor Gray
    } else {
        Write-Host "FAIL - Get pet failed" -ForegroundColor Red
    }
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "`nStatus Code: $statusCode" -ForegroundColor Red
    Write-Host "FAIL - Get pet failed" -ForegroundColor Red
}

# Test 4: Update Pet
Write-Host "`n============================================================" -ForegroundColor Yellow
Write-Host "TEST 4: Update Pet" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow

$updatePetBody = @{
    name = "Buddy Updated"
    age = 4
    bio = "Updated bio: Very friendly golden retriever"
} | ConvertTo-Json

Write-Host "PUT $baseUrl/api/v1/pets/$petId"
Write-Host "Body: $updatePetBody"

try {
    $headers = @{
        "Authorization" = "Bearer $accessToken"
    }
    
    $response = Invoke-WebRequest -Uri "$baseUrl/api/v1/pets/$petId" `
        -Method PUT `
        -Headers $headers `
        -Body $updatePetBody `
        -ContentType "application/json" `
        -TimeoutSec 10

    Write-Host "`nStatus Code: $($response.StatusCode)" -ForegroundColor Green
    $data = $response.Content | ConvertFrom-Json
    Write-Host "Response: $($response.Content)" -ForegroundColor White
    
    if ($data.success) {
        Write-Host "PASS - Pet updated successfully!" -ForegroundColor Green
        Write-Host "Updated Name: $($data.pet.name)" -ForegroundColor Gray
        Write-Host "Updated Age: $($data.pet.age)" -ForegroundColor Gray
    } else {
        Write-Host "FAIL - Update pet failed" -ForegroundColor Red
    }
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    $errorBody = $_.ErrorDetails.Message
    Write-Host "`nStatus Code: $statusCode" -ForegroundColor Red
    Write-Host "Response: $errorBody" -ForegroundColor Red
    Write-Host "FAIL - Update pet failed" -ForegroundColor Red
}

# Test 5: Delete Pet
Write-Host "`n============================================================" -ForegroundColor Yellow
Write-Host "TEST 5: Delete Pet" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow

Write-Host "DELETE $baseUrl/api/v1/pets/$petId"

try {
    $headers = @{
        "Authorization" = "Bearer $accessToken"
    }
    
    $response = Invoke-WebRequest -Uri "$baseUrl/api/v1/pets/$petId" `
        -Method DELETE `
        -Headers $headers `
        -TimeoutSec 10

    Write-Host "`nStatus Code: $($response.StatusCode)" -ForegroundColor Green
    $data = $response.Content | ConvertFrom-Json
    
    if ($data.success) {
        Write-Host "PASS - Pet deleted successfully!" -ForegroundColor Green
    } else {
        Write-Host "FAIL - Delete pet failed" -ForegroundColor Red
    }
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "`nStatus Code: $statusCode" -ForegroundColor Red
    Write-Host "FAIL - Delete pet failed" -ForegroundColor Red
}

# Verify deletion
Write-Host "`nVerifying deletion..."
try {
    $headers = @{
        "Authorization" = "Bearer $accessToken"
    }
    
    $response = Invoke-WebRequest -Uri "$baseUrl/api/v1/pets/$petId" `
        -Method GET `
        -Headers $headers `
        -TimeoutSec 10

    Write-Host "FAIL - Pet still exists!" -ForegroundColor Red
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 404) {
        Write-Host "PASS - Pet successfully deleted (404 confirmed)" -ForegroundColor Green
    } else {
        Write-Host "Unexpected status code: $statusCode" -ForegroundColor Yellow
    }
}

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "TEST COMPLETE" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
