#!/usr/bin/env pwsh
# PawPal Backend - RAG Chatbot Test Script
# Tests AI-powered veterinary assistant chatbot

$baseUrl = "http://localhost:8081"

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "PawPal Backend - RAG Chatbot Test" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Backend URL: $baseUrl"
Write-Host "Test Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

# Check if FastAPI server is running
Write-Host "`n============================================================" -ForegroundColor Yellow
Write-Host "STEP 0: Check FastAPI Server Status" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow

try {
    $healthResponse = Invoke-WebRequest -Uri "http://localhost:8000/health" -Method GET -TimeoutSec 2
    if ($healthResponse.StatusCode -eq 200) {
        Write-Host "✅ FastAPI chatbot server is running (HTTP mode - FAST)" -ForegroundColor Green
        Write-Host "Response time will be ~300-800ms" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠️  FastAPI chatbot server is NOT running (Exec mode - SLOW)" -ForegroundColor Yellow
    Write-Host "Response time will be ~5-10 seconds" -ForegroundColor Yellow
    Write-Host "`n💡 To enable fast mode, run in another terminal:" -ForegroundColor Cyan
    Write-Host "   cd AI_Chatbot" -ForegroundColor White
    Write-Host "   python chatbot_fastapi_server.py" -ForegroundColor White
    Write-Host "`nContinuing with exec mode..." -ForegroundColor Yellow
}

# TEST 1: Simple Health Question
Write-Host "`n============================================================" -ForegroundColor Yellow
Write-Host "TEST 1: Simple Health Question" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow

$query1 = @{
    message = "What are the symptoms of kennel cough in dogs?"
} | ConvertTo-Json

Write-Host "POST $baseUrl/api/v1/chatbot/query"
Write-Host "Query: What are the symptoms of kennel cough in dogs?" -ForegroundColor Cyan

try {
    $startTime = Get-Date
    $response = Invoke-WebRequest -Uri "$baseUrl/api/v1/chatbot/query" `
        -Method POST `
        -Body $query1 `
        -ContentType "application/json" `
        -TimeoutSec 60

    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalMilliseconds

    Write-Host "`nStatus Code: $($response.StatusCode)" -ForegroundColor Green
    $data = $response.Content | ConvertFrom-Json
    
    if ($data.success) {
        Write-Host "✅ PASS - Chatbot responded successfully!" -ForegroundColor Green
        Write-Host "Response Time: $($duration.ToString('F0')) ms" -ForegroundColor Gray
        Write-Host "`n--- Answer ---" -ForegroundColor Cyan
        Write-Host $data.answer -ForegroundColor White
        
        if ($data.sources -and $data.sources.Count -gt 0) {
            Write-Host "`n--- Sources (Top 3) ---" -ForegroundColor Cyan
            $sourceCount = [Math]::Min(3, $data.sources.Count)
            for ($i = 0; $i -lt $sourceCount; $i++) {
                Write-Host "$($i + 1). Source: $($data.sources[$i].source)" -ForegroundColor Gray
            }
        }
    } else {
        Write-Host "❌ FAIL - Chatbot query failed" -ForegroundColor Red
    }
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    $errorBody = $_.ErrorDetails.Message
    Write-Host "`nStatus Code: $statusCode" -ForegroundColor Red
    Write-Host "Error: $errorBody" -ForegroundColor Red
    Write-Host "❌ FAIL - Request failed" -ForegroundColor Red
}

# TEST 2: Question with Pet Profile
Write-Host "`n============================================================" -ForegroundColor Yellow
Write-Host "TEST 2: Question with Pet Profile" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow

$query2 = @{
    message = "What should I feed my puppy?"
    pet_profile = @{
        name = "Buddy"
        type = "dog"
        breed = "Golden Retriever"
        age = 6
        age_unit = "months"
        weight = 15.5
        weight_unit = "kg"
    }
} | ConvertTo-Json

Write-Host "POST $baseUrl/api/v1/chatbot/query"
Write-Host "Query: What should I feed my puppy?" -ForegroundColor Cyan
Write-Host "Pet Profile: 6-month-old Golden Retriever, 15.5 kg" -ForegroundColor Cyan

try {
    $startTime = Get-Date
    $response = Invoke-WebRequest -Uri "$baseUrl/api/v1/chatbot/query" `
        -Method POST `
        -Body $query2 `
        -ContentType "application/json" `
        -TimeoutSec 60

    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalMilliseconds

    Write-Host "`nStatus Code: $($response.StatusCode)" -ForegroundColor Green
    $data = $response.Content | ConvertFrom-Json
    
    if ($data.success) {
        Write-Host "✅ PASS - Personalized response received!" -ForegroundColor Green
        Write-Host "Response Time: $($duration.ToString('F0')) ms" -ForegroundColor Gray
        Write-Host "`n--- Answer ---" -ForegroundColor Cyan
        Write-Host $data.answer -ForegroundColor White
        
        # Check if answer mentions the breed or age
        if ($data.answer -match "Golden Retriever|puppy|6.month|15") {
            Write-Host "`n✨ Response is personalized based on pet profile!" -ForegroundColor Green
        }
    } else {
        Write-Host "❌ FAIL - Chatbot query failed" -ForegroundColor Red
    }
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    $errorBody = $_.ErrorDetails.Message
    Write-Host "`nStatus Code: $statusCode" -ForegroundColor Red
    Write-Host "Error: $errorBody" -ForegroundColor Red
    Write-Host "❌ FAIL - Request failed" -ForegroundColor Red
}

# TEST 3: Emergency Question
Write-Host "`n============================================================" -ForegroundColor Yellow
Write-Host "TEST 3: Emergency Assessment" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow

$query3 = @{
    message = "My dog ate chocolate, what should I do?"
    pet_profile = @{
        name = "Max"
        type = "dog"
        weight = 25
        weight_unit = "kg"
    }
} | ConvertTo-Json

Write-Host "POST $baseUrl/api/v1/chatbot/query"
Write-Host "Query: My dog ate chocolate, what should I do?" -ForegroundColor Cyan
Write-Host "Pet Profile: 25 kg dog" -ForegroundColor Cyan

try {
    $startTime = Get-Date
    $response = Invoke-WebRequest -Uri "$baseUrl/api/v1/chatbot/query" `
        -Method POST `
        -Body $query3 `
        -ContentType "application/json" `
        -TimeoutSec 60

    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalMilliseconds

    Write-Host "`nStatus Code: $($response.StatusCode)" -ForegroundColor Green
    $data = $response.Content | ConvertFrom-Json
    
    if ($data.success) {
        Write-Host "✅ PASS - Emergency response received!" -ForegroundColor Green
        Write-Host "Response Time: $($duration.ToString('F0')) ms" -ForegroundColor Gray
        Write-Host "`n--- Answer ---" -ForegroundColor Cyan
        Write-Host $data.answer -ForegroundColor White
        
        # Check if answer mentions emergency/vet/urgent
        if ($data.answer -match "emergency|vet|urgent|immediately|contact") {
            Write-Host "`n⚠️  Response correctly identifies this as an emergency!" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ FAIL - Chatbot query failed" -ForegroundColor Red
    }
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    $errorBody = $_.ErrorDetails.Message
    Write-Host "`nStatus Code: $statusCode" -ForegroundColor Red
    Write-Host "Error: $errorBody" -ForegroundColor Red
    Write-Host "❌ FAIL - Request failed" -ForegroundColor Red
}

# TEST 4: Breed-Specific Question
Write-Host "`n============================================================" -ForegroundColor Yellow
Write-Host "TEST 4: Breed-Specific Health Question" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow

$query4 = @{
    message = "What health issues are common in German Shepherds?"
    pet_profile = @{
        type = "dog"
        breed = "German Shepherd"
        age = 5
        age_unit = "years"
    }
} | ConvertTo-Json

Write-Host "POST $baseUrl/api/v1/chatbot/query"
Write-Host "Query: What health issues are common in German Shepherds?" -ForegroundColor Cyan

try {
    $startTime = Get-Date
    $response = Invoke-WebRequest -Uri "$baseUrl/api/v1/chatbot/query" `
        -Method POST `
        -Body $query4 `
        -ContentType "application/json" `
        -TimeoutSec 60

    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalMilliseconds

    Write-Host "`nStatus Code: $($response.StatusCode)" -ForegroundColor Green
    $data = $response.Content | ConvertFrom-Json
    
    if ($data.success) {
        Write-Host "✅ PASS - Breed-specific information retrieved!" -ForegroundColor Green
        Write-Host "Response Time: $($duration.ToString('F0')) ms" -ForegroundColor Gray
        Write-Host "`n--- Answer ---" -ForegroundColor Cyan
        Write-Host $data.answer -ForegroundColor White
        
        if ($data.enhanced_query) {
            Write-Host "`n--- Enhanced Query ---" -ForegroundColor Cyan
            Write-Host $data.enhanced_query -ForegroundColor Gray
        }
    } else {
        Write-Host "❌ FAIL - Chatbot query failed" -ForegroundColor Red
    }
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    $errorBody = $_.ErrorDetails.Message
    Write-Host "`nStatus Code: $statusCode" -ForegroundColor Red
    Write-Host "Error: $errorBody" -ForegroundColor Red
    Write-Host "❌ FAIL - Request failed" -ForegroundColor Red
}

# TEST 5: Nutrition Question
Write-Host "`n============================================================" -ForegroundColor Yellow
Write-Host "TEST 5: Nutrition & Diet Question" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow

$query5 = @{
    message = "What foods are toxic to dogs?"
} | ConvertTo-Json

Write-Host "POST $baseUrl/api/v1/chatbot/query"
Write-Host "Query: What foods are toxic to dogs?" -ForegroundColor Cyan

try {
    $startTime = Get-Date
    $response = Invoke-WebRequest -Uri "$baseUrl/api/v1/chatbot/query" `
        -Method POST `
        -Body $query5 `
        -ContentType "application/json" `
        -TimeoutSec 60

    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalMilliseconds

    Write-Host "`nStatus Code: $($response.StatusCode)" -ForegroundColor Green
    $data = $response.Content | ConvertFrom-Json
    
    if ($data.success) {
        Write-Host "✅ PASS - Nutrition information retrieved!" -ForegroundColor Green
        Write-Host "Response Time: $($duration.ToString('F0')) ms" -ForegroundColor Gray
        Write-Host "`n--- Answer ---" -ForegroundColor Cyan
        Write-Host $data.answer -ForegroundColor White
        
        # Check if answer mentions common toxic foods
        if ($data.answer -match "chocolate|grapes|onion|garlic|xylitol") {
            Write-Host "`n✅ Response includes common toxic foods!" -ForegroundColor Green
        }
    } else {
        Write-Host "❌ FAIL - Chatbot query failed" -ForegroundColor Red
    }
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    $errorBody = $_.ErrorDetails.Message
    Write-Host "`nStatus Code: $statusCode" -ForegroundColor Red
    Write-Host "Error: $errorBody" -ForegroundColor Red
    Write-Host "❌ FAIL - Request failed" -ForegroundColor Red
}

# TEST 6: Cat-Specific Question
Write-Host "`n============================================================" -ForegroundColor Yellow
Write-Host "TEST 6: Cat Health Question" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow

$query6 = @{
    message = "How often should I take my cat to the vet?"
    pet_profile = @{
        type = "cat"
        breed = "Persian"
        age = 3
        age_unit = "years"
    }
} | ConvertTo-Json

Write-Host "POST $baseUrl/api/v1/chatbot/query"
Write-Host "Query: How often should I take my cat to the vet?" -ForegroundColor Cyan
Write-Host "Pet Profile: 3-year-old Persian cat" -ForegroundColor Cyan

try {
    $startTime = Get-Date
    $response = Invoke-WebRequest -Uri "$baseUrl/api/v1/chatbot/query" `
        -Method POST `
        -Body $query6 `
        -ContentType "application/json" `
        -TimeoutSec 60

    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalMilliseconds

    Write-Host "`nStatus Code: $($response.StatusCode)" -ForegroundColor Green
    $data = $response.Content | ConvertFrom-Json
    
    if ($data.success) {
        Write-Host "✅ PASS - Cat care information retrieved!" -ForegroundColor Green
        Write-Host "Response Time: $($duration.ToString('F0')) ms" -ForegroundColor Gray
        Write-Host "`n--- Answer ---" -ForegroundColor Cyan
        Write-Host $data.answer -ForegroundColor White
    } else {
        Write-Host "❌ FAIL - Chatbot query failed" -ForegroundColor Red
    }
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    $errorBody = $_.ErrorDetails.Message
    Write-Host "`nStatus Code: $statusCode" -ForegroundColor Red
    Write-Host "Error: $errorBody" -ForegroundColor Red
    Write-Host "❌ FAIL - Request failed" -ForegroundColor Red
}

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "TEST COMPLETE" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

Write-Host "`nSummary:" -ForegroundColor Cyan
Write-Host "- Test 1: General health question" -ForegroundColor White
Write-Host "- Test 2: Personalized with pet profile" -ForegroundColor White
Write-Host "- Test 3: Emergency assessment" -ForegroundColor White
Write-Host "- Test 4: Breed-specific information" -ForegroundColor White
Write-Host "- Test 5: Nutrition and toxic foods" -ForegroundColor White
Write-Host "- Test 6: Cat-specific care" -ForegroundColor White

Write-Host "`nNext Steps:" -ForegroundColor Cyan
Write-Host "1. Try streaming responses: http://localhost:8081/test/chatbot_stream" -ForegroundColor White
Write-Host "2. Test with HTML interface: http://localhost:8081/test/chatbot" -ForegroundColor White
Write-Host "3. For faster responses, run FastAPI server:" -ForegroundColor White
Write-Host "   cd AI_Chatbot; python chatbot_fastapi_server.py" -ForegroundColor Gray
Write-Host "4. Integrate chatbot in Flutter app using provided examples" -ForegroundColor White
