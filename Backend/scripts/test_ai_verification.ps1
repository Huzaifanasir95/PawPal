#!/usr/bin/env pwsh
# PawPal Backend - AI Breed Verification Test Script
# Tests AI-powered breed verification for pets

$baseUrl = "http://localhost:8081"
$testEmail = "test_verification_$(Get-Date -UFormat %s)@pawpal.com"
$testPassword = "TestPassword123!"

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "PawPal Backend - AI Breed Verification Test" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Backend URL: $baseUrl"
Write-Host "Test Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

# Variables
$accessToken = ""
$petId = ""

# STEP 1: Register and Login
Write-Host "`n============================================================" -ForegroundColor Yellow
Write-Host "STEP 1: User Registration & Login" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow

$signupBody = @{
    email = $testEmail
    password = $testPassword
    displayName = "AI Test User"
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/v1/auth/signup" `
        -Method POST `
        -Body $signupBody `
        -ContentType "application/json" `
        -TimeoutSec 10

    $data = $response.Content | ConvertFrom-Json
    
    if ($data.success) {
        $accessToken = $data.accessToken
        Write-Host "User registered and logged in successfully!" -ForegroundColor Green
        Write-Host "Access Token: $($accessToken.Substring(0, 30))..." -ForegroundColor Gray
    } else {
        Write-Host "Failed to register user" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Failed to register user" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# STEP 2: Create a Pet (without verification)
Write-Host "`n============================================================" -ForegroundColor Yellow
Write-Host "STEP 2: Create Pet (Golden Retriever)" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow

$petBody = @{
    name = "Max"
    type = "dog"
    breed = "Golden Retriever"
    age = 3
    ageUnit = "years"
    gender = "male"
    color = "golden"
    weight = 32.5
    weightUnit = "kg"
    bio = "Friendly golden retriever for AI testing"
} | ConvertTo-Json

Write-Host "POST $baseUrl/api/v1/pets"

try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/v1/pets" `
        -Method POST `
        -Headers @{"Authorization" = "Bearer $accessToken"} `
        -Body $petBody `
        -ContentType "application/json" `
        -TimeoutSec 10

    Write-Host "`nStatus Code: $($response.StatusCode)" -ForegroundColor Green
    $data = $response.Content | ConvertFrom-Json
    
    if ($data.success) {
        $petId = $data.pet.id
        Write-Host "PASS - Pet created successfully!" -ForegroundColor Green
        Write-Host "Pet ID: $petId" -ForegroundColor White
        Write-Host "Pet Name: $($data.pet.name)" -ForegroundColor White
        Write-Host "Breed: $($data.pet.breed)" -ForegroundColor White
        Write-Host "Is Verified: $($data.pet.isVerified)" -ForegroundColor White
    } else {
        Write-Host "FAIL - Failed to create pet" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "FAIL - Failed to create pet" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# STEP 3: Create sample dog image (base64 encoded)
Write-Host "`n============================================================" -ForegroundColor Yellow
Write-Host "STEP 3: Prepare Test Image (Base64 Encoded)" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow

# For testing purposes, we'll use a small placeholder image
# In production, you would encode a real pet image
$sampleImagePath = "sample_dog.jpg"

if (Test-Path $sampleImagePath) {
    Write-Host "Using existing sample image: $sampleImagePath" -ForegroundColor Green
    $imageBytes = [System.IO.File]::ReadAllBytes($sampleImagePath)
    $imageBase64 = [Convert]::ToBase64String($imageBytes)
    Write-Host "Image encoded successfully ($(($imageBase64.Length / 1024).ToString('F2')) KB)" -ForegroundColor Green
} else {
    Write-Host "⚠️  No sample image found. Please provide a dog image named 'sample_dog.jpg'" -ForegroundColor Yellow
    Write-Host "Skipping AI verification test..." -ForegroundColor Yellow
    Write-Host "`nTo test with a real image:" -ForegroundColor Cyan
    Write-Host "1. Place a dog image in: $PWD\sample_dog.jpg" -ForegroundColor Cyan
    Write-Host "2. Run this script again" -ForegroundColor Cyan
    
    Write-Host "`n============================================================" -ForegroundColor Yellow
    Write-Host "ALTERNATIVE TEST: Verify Pet from URL" -ForegroundColor Yellow
    Write-Host "============================================================" -ForegroundColor Yellow
    
    # Use a publicly available dog image for testing
    $testImageUrl = "https://images.unsplash.com/photo-1633722715463-d30f4f325e24?w=400"
    
    Write-Host "Using test image from URL: $testImageUrl" -ForegroundColor Cyan
    
    $verifyUrlBody = @{
        petId = $petId
        imageUrl = $testImageUrl
        useETTA = $false
        topK = 5
    } | ConvertTo-Json

    Write-Host "`nPOST $baseUrl/api/v1/pets/verify/url"
    Write-Host "Body: $verifyUrlBody"

    try {
        $response = Invoke-WebRequest -Uri "$baseUrl/api/v1/pets/verify/url" `
            -Method POST `
            -Headers @{"Authorization" = "Bearer $accessToken"} `
            -Body $verifyUrlBody `
            -ContentType "application/json" `
            -TimeoutSec 30

        Write-Host "`nStatus Code: $($response.StatusCode)" -ForegroundColor Green
        $data = $response.Content | ConvertFrom-Json
        
        if ($data.success) {
            Write-Host "✅ PASS - Pet breed verified from URL!" -ForegroundColor Green
            Write-Host "`n--- Verification Results ---" -ForegroundColor Cyan
            Write-Host "Is Verified: $($data.pet.isVerified)" -ForegroundColor White
            Write-Host "Verified Breed: $($data.pet.verifiedBreed)" -ForegroundColor White
            Write-Host "Confidence: $(($data.pet.verificationConfidence * 100).ToString('F2'))%" -ForegroundColor White
            Write-Host "`n--- AI Prediction Details ---" -ForegroundColor Cyan
            Write-Host "Predicted Breed: $($data.prediction.predicted)" -ForegroundColor White
            Write-Host "Confidence: $(($data.prediction.confidence * 100).ToString('F2'))%" -ForegroundColor White
            Write-Host "Process Time: $($data.prediction.processTime) ms" -ForegroundColor White
            Write-Host "Used TTA: $($data.prediction.usedTTA)" -ForegroundColor White
            
            if ($data.prediction.predictions) {
                Write-Host "`n--- Top Predictions ---" -ForegroundColor Cyan
                foreach ($pred in $data.prediction.predictions) {
                    Write-Host "$($pred.rank). $($pred.breed) - $(($pred.confidence * 100).ToString('F2'))%" -ForegroundColor White
                }
            }
        } else {
            Write-Host "❌ FAIL - Verification failed: $($data.message)" -ForegroundColor Red
        }
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        $errorBody = $_.ErrorDetails.Message
        Write-Host "`nStatus Code: $statusCode" -ForegroundColor Red
        Write-Host "Response: $errorBody" -ForegroundColor Red
        Write-Host "❌ FAIL - Verification failed" -ForegroundColor Red
    }
    
    Write-Host "`n============================================================" -ForegroundColor Cyan
    Write-Host "TEST COMPLETE (URL-based verification)" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    exit 0
}

# STEP 4: Verify Pet Breed with AI (Base64)
Write-Host "`n============================================================" -ForegroundColor Yellow
Write-Host "STEP 4: Verify Pet Breed with AI" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow

$verifyBody = @{
    petId = $petId
    image = $imageBase64
    useETTA = $false
    topK = 5
} | ConvertTo-Json

Write-Host "POST $baseUrl/api/v1/pets/verify"

try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/v1/pets/verify" `
        -Method POST `
        -Headers @{"Authorization" = "Bearer $accessToken"} `
        -Body $verifyBody `
        -ContentType "application/json" `
        -TimeoutSec 30

    Write-Host "`nStatus Code: $($response.StatusCode)" -ForegroundColor Green
    $data = $response.Content | ConvertFrom-Json
    
    if ($data.success) {
        Write-Host "✅ PASS - Pet breed verified!" -ForegroundColor Green
        Write-Host "`n--- Verification Results ---" -ForegroundColor Cyan
        Write-Host "Is Verified: $($data.pet.isVerified)" -ForegroundColor White
        Write-Host "Verified Breed: $($data.pet.verifiedBreed)" -ForegroundColor White
        Write-Host "Confidence: $(($data.pet.verificationConfidence * 100).ToString('F2'))%" -ForegroundColor White
        Write-Host "`n--- AI Prediction Details ---" -ForegroundColor Cyan
        Write-Host "Predicted Breed: $($data.prediction.predicted)" -ForegroundColor White
        Write-Host "Confidence: $(($data.prediction.confidence * 100).ToString('F2'))%" -ForegroundColor White
        Write-Host "Process Time: $($data.prediction.processTime) ms" -ForegroundColor White
        Write-Host "Used TTA: $($data.prediction.usedTTA)" -ForegroundColor White
        
        if ($data.prediction.predictions) {
            Write-Host "`n--- Top $($data.prediction.predictions.Count) Predictions ---" -ForegroundColor Cyan
            foreach ($pred in $data.prediction.predictions) {
                Write-Host "$($pred.rank). $($pred.breed) - $(($pred.confidence * 100).ToString('F2'))%" -ForegroundColor White
            }
        }
    } else {
        Write-Host "❌ FAIL - Verification failed: $($data.message)" -ForegroundColor Red
    }
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    $errorBody = $_.ErrorDetails.Message
    Write-Host "`nStatus Code: $statusCode" -ForegroundColor Red
    Write-Host "Response: $errorBody" -ForegroundColor Red
    Write-Host "❌ FAIL - Verification failed" -ForegroundColor Red
}

# STEP 5: Get Pet and Check Verification Status
Write-Host "`n============================================================" -ForegroundColor Yellow
Write-Host "STEP 5: Get Pet and Verify Status Update" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow

Write-Host "GET $baseUrl/api/v1/pets/$petId"

try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/v1/pets/$petId" `
        -Method GET `
        -Headers @{"Authorization" = "Bearer $accessToken"} `
        -TimeoutSec 10

    Write-Host "`nStatus Code: $($response.StatusCode)" -ForegroundColor Green
    $data = $response.Content | ConvertFrom-Json
    
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ PASS - Pet retrieved successfully!" -ForegroundColor Green
        Write-Host "Name: $($data.pet.name)" -ForegroundColor White
        Write-Host "Original Breed: $($data.pet.breed)" -ForegroundColor White
        Write-Host "Is Verified: $($data.pet.isVerified)" -ForegroundColor White
        
        if ($data.pet.verifiedBreed) {
            Write-Host "Verified Breed: $($data.pet.verifiedBreed)" -ForegroundColor Green
            Write-Host "Verification Confidence: $(($data.pet.verificationConfidence * 100).ToString('F2'))%" -ForegroundColor Green
            
            if ($data.pet.breed -eq $data.pet.verifiedBreed) {
                Write-Host "`n🎉 Breed Matched! The AI confirmed the pet's breed." -ForegroundColor Green
            } else {
                Write-Host "`n⚠️  Breed Mismatch! Original: $($data.pet.breed) | AI Verified: $($data.pet.verifiedBreed)" -ForegroundColor Yellow
            }
        } else {
            Write-Host "Verified Breed: Not verified" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ FAIL - Failed to retrieve pet" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ FAIL - Failed to retrieve pet" -ForegroundColor Red
}

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "TEST COMPLETE" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "`n💡 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Check Supabase database to see verification fields updated" -ForegroundColor White
Write-Host "2. Try verifying other pets with different breeds" -ForegroundColor White
Write-Host "3. Test with cat images by creating a cat pet" -ForegroundColor White
Write-Host "4. Use the HTML test page: http://localhost:8081/web/auth_pet_test.html" -ForegroundColor White
