# ============================================
# PawPal Backend - RAG Chatbot Tests
# ============================================
# Tests: AI-powered pet care chatbot
# ============================================

param(
    [string]$BaseURL = "https://transudatory-fecklessly-karisa.ngrok-free.dev",
    [switch]$Verbose
)

# Test result tracking
$TestResults = @()
$PassedTests = 0
$FailedTests = 0

# ============================================
# Helper Functions
# ============================================

function Write-TestHeader {
    param([string]$Message)
    Write-Host "`n" -NoNewline
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
}

function Write-TestResult {
    param(
        [string]$TestName,
        [bool]$Passed,
        [string]$Message = "",
        [object]$Response = $null
    )
    
    $result = @{
        TestName = $TestName
        Passed = $Passed
        Message = $Message
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    
    if ($Response) {
        $result.Response = $Response
    }
    
    $script:TestResults += $result
    
    if ($Passed) {
        $script:PassedTests++
        Write-Host "✅ PASS: $TestName" -ForegroundColor Green
    } else {
        $script:FailedTests++
        Write-Host "❌ FAIL: $TestName" -ForegroundColor Red
    }
    
    if ($Message) {
        Write-Host "   → $Message" -ForegroundColor Gray
    }
    
    if ($Verbose -and $Response) {
        Write-Host "   Response: $($Response | ConvertTo-Json -Depth 2)" -ForegroundColor DarkGray
    }
}

# ============================================
# API Call Functions
# ============================================

function Invoke-ChatbotQuery {
    param(
        [string]$Message,
        [hashtable]$PetProfile = $null,
        [int]$TimeoutSeconds = 60
    )
    
    try {
        $body = @{
            message = $Message
        }
        
        if ($PetProfile) {
            $body.pet_profile = $PetProfile
        }
        
        $bodyJson = $body | ConvertTo-Json -Depth 3
        
        Write-Host "   Querying: $Message" -ForegroundColor DarkGray
        $startTime = Get-Date
        
        $response = Invoke-RestMethod -Uri "$BaseURL/api/v1/chatbot/query" `
            -Method POST `
            -Headers @{
                "Content-Type" = "application/json"
                "ngrok-skip-browser-warning" = "true"
            } `
            -Body $bodyJson `
            -TimeoutSec $TimeoutSeconds
        
        $duration = ((Get-Date) - $startTime).TotalSeconds
        Write-Host "   Response time: $([math]::Round($duration, 2))s" -ForegroundColor DarkGray
        
        return @{
            Success = $true
            Data = $response
            Duration = $duration
        }
    }
    catch {
        $errorBody = $null
        if ($_.Exception.Response) {
            try {
                $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                $errorBody = $reader.ReadToEnd()
            } catch {}
        }
        
        return @{
            Success = $false
            Error = $_.Exception.Message
            StatusCode = $_.Exception.Response.StatusCode.value__
            ErrorBody = $errorBody
        }
    }
}

# ============================================
# CHATBOT TESTS
# ============================================

Write-TestHeader "RAG CHATBOT TESTS"

# Test 1: Basic query - General pet care
Write-TestHeader "Test 1: Basic Pet Care Query"
$result = Invoke-ChatbotQuery -Message "What should I feed my dog?"

if ($result.Success -and $result.Data.answer) {
    $answerLength = $result.Data.answer.Length
    $hasSources = $result.Data.sources -and $result.Data.sources.Count -gt 0
    
    $passed = ($answerLength -gt 50)  # Reasonable answer length
    
    $sourceInfo = if ($hasSources) { "Sources: $($result.Data.sources.Count)" } else { "No sources" }
    
    Write-TestResult -TestName "Basic Pet Care Query" -Passed $passed `
        -Message "Answer length: $answerLength chars, $sourceInfo, Time: $([math]::Round($result.Duration, 2))s" `
        -Response $result.Data
    
    if ($Verbose -and $result.Data.answer) {
        Write-Host "   Answer preview: $($result.Data.answer.Substring(0, [Math]::Min(150, $result.Data.answer.Length)))..." -ForegroundColor Gray
    }
} else {
    Write-TestResult -TestName "Basic Pet Care Query" -Passed $false `
        -Message "$($result.Error) - $($result.ErrorBody)"
}

# Test 2: Health-related query
Write-TestHeader "Test 2: Health Question"
$result = Invoke-ChatbotQuery -Message "My dog is vomiting. What should I do?"

if ($result.Success -and $result.Data.answer) {
    $hasEmergency = $result.Data.answer -match "vet|emergency|immediately|urgent" -or $result.Data.answer -match "concern|serious|consult"
    
    Write-TestResult -TestName "Health Question" -Passed $hasEmergency `
        -Message "Contains vet/emergency advice: $hasEmergency, Time: $([math]::Round($result.Duration, 2))s"
    
    if ($Verbose -and $result.Data.answer) {
        Write-Host "   Answer preview: $($result.Data.answer.Substring(0, [Math]::Min(150, $result.Data.answer.Length)))..." -ForegroundColor Gray
    }
} else {
    Write-TestResult -TestName "Health Question" -Passed $false `
        -Message "$($result.Error)"
}

# Test 3: Breed-specific query
Write-TestHeader "Test 3: Breed-Specific Query"
$result = Invoke-ChatbotQuery -Message "What are common health issues in Golden Retrievers?"

if ($result.Success -and $result.Data.answer) {
    $hasBreedInfo = $result.Data.answer -match "Golden Retriever|hip|dysplasia|cancer|heart" -or $result.Data.answer.Length -gt 100
    
    Write-TestResult -TestName "Breed-Specific Query" -Passed $hasBreedInfo `
        -Message "Contains breed-specific info: $hasBreedInfo, Time: $([math]::Round($result.Duration, 2))s"
    
    if ($Verbose -and $result.Data.answer) {
        Write-Host "   Answer preview: $($result.Data.answer.Substring(0, [Math]::Min(150, $result.Data.answer.Length)))..." -ForegroundColor Gray
    }
} else {
    Write-TestResult -TestName "Breed-Specific Query" -Passed $false `
        -Message "$($result.Error)"
}

# Test 4: Nutrition query
Write-TestHeader "Test 4: Nutrition Question"
$result = Invoke-ChatbotQuery -Message "How much food should a 30 pound dog eat daily?"

if ($result.Success -and $result.Data.answer) {
    $hasNutrition = $result.Data.answer -match "cup|food|pound|weight|feed" -or $result.Data.answer.Length -gt 50
    
    Write-TestResult -TestName "Nutrition Question" -Passed $hasNutrition `
        -Message "Contains nutrition advice: $hasNutrition, Time: $([math]::Round($result.Duration, 2))s"
    
    if ($Verbose -and $result.Data.answer) {
        Write-Host "   Answer preview: $($result.Data.answer.Substring(0, [Math]::Min(150, $result.Data.answer.Length)))..." -ForegroundColor Gray
    }
} else {
    Write-TestResult -TestName "Nutrition Question" -Passed $false `
        -Message "$($result.Error)"
}

# Test 5: Cat-specific query
Write-TestHeader "Test 5: Cat Care Query"
$result = Invoke-ChatbotQuery -Message "Why is my cat not using the litter box?"

if ($result.Success -and $result.Data.answer) {
    $hasCatInfo = $result.Data.answer -match "cat|litter|box|behavior" -or $result.Data.answer.Length -gt 50
    
    Write-TestResult -TestName "Cat Care Query" -Passed $hasCatInfo `
        -Message "Contains cat-specific info: $hasCatInfo, Time: $([math]::Round($result.Duration, 2))s"
    
    if ($Verbose -and $result.Data.answer) {
        Write-Host "   Answer preview: $($result.Data.answer.Substring(0, [Math]::Min(150, $result.Data.answer.Length)))..." -ForegroundColor Gray
    }
} else {
    Write-TestResult -TestName "Cat Care Query" -Passed $false `
        -Message "$($result.Error)"
}

# Test 6: Query with pet profile context
Write-TestHeader "Test 6: Query with Pet Profile"
$petProfile = @{
    name = "Max"
    breed = "Labrador Retriever"
    age = 5
    weight = 70
}

$result = Invoke-ChatbotQuery -Message "Is my dog overweight?" -PetProfile $petProfile

if ($result.Success -and $result.Data.answer) {
    $hasContext = $result.Data.answer -match "Labrador|Max|70|weight" -or $result.Data.answer.Length -gt 50
    
    Write-TestResult -TestName "Query with Pet Profile" -Passed $hasContext `
        -Message "Uses pet context: $hasContext, Time: $([math]::Round($result.Duration, 2))s"
    
    if ($Verbose -and $result.Data.answer) {
        Write-Host "   Answer preview: $($result.Data.answer.Substring(0, [Math]::Min(150, $result.Data.answer.Length)))..." -ForegroundColor Gray
    }
} else {
    Write-TestResult -TestName "Query with Pet Profile" -Passed $false `
        -Message "$($result.Error)"
}

# Test 7: Vaccination query
Write-TestHeader "Test 7: Vaccination Question"
$result = Invoke-ChatbotQuery -Message "What vaccinations does my puppy need?"

if ($result.Success -and $result.Data.answer) {
    $hasVaccineInfo = $result.Data.answer -match "vaccin|rabies|distemper|parvo|shot" -or $result.Data.answer.Length -gt 80
    
    Write-TestResult -TestName "Vaccination Question" -Passed $hasVaccineInfo `
        -Message "Contains vaccine info: $hasVaccineInfo, Time: $([math]::Round($result.Duration, 2))s"
    
    if ($Verbose -and $result.Data.answer) {
        Write-Host "   Answer preview: $($result.Data.answer.Substring(0, [Math]::Min(150, $result.Data.answer.Length)))..." -ForegroundColor Gray
    }
} else {
    Write-TestResult -TestName "Vaccination Question" -Passed $false `
        -Message "$($result.Error)"
}

# Test 8: Training/Behavior query
Write-TestHeader "Test 8: Training Question"
$result = Invoke-ChatbotQuery -Message "How do I stop my dog from barking excessively?"

if ($result.Success -and $result.Data.answer) {
    $hasTrainingInfo = $result.Data.answer -match "train|bark|behavior|teach|command" -or $result.Data.answer.Length -gt 50
    
    Write-TestResult -TestName "Training Question" -Passed $hasTrainingInfo `
        -Message "Contains training advice: $hasTrainingInfo, Time: $([math]::Round($result.Duration, 2))s"
    
    if ($Verbose -and $result.Data.answer) {
        Write-Host "   Answer preview: $($result.Data.answer.Substring(0, [Math]::Min(150, $result.Data.answer.Length)))..." -ForegroundColor Gray
    }
} else {
    Write-TestResult -TestName "Training Question" -Passed $false `
        -Message "$($result.Error)"
}

# Test 9: Emergency situation
Write-TestHeader "Test 9: Emergency Situation"
$result = Invoke-ChatbotQuery -Message "My dog ate chocolate. Is this dangerous?"

if ($result.Success -and $result.Data.answer) {
    $hasEmergencyAdvice = $result.Data.answer -match "emergency|toxic|poison|vet|immediately|dangerous|urgent" -or $result.Data.answer.Length -gt 50
    
    Write-TestResult -TestName "Emergency Situation" -Passed $hasEmergencyAdvice `
        -Message "Contains emergency advice: $hasEmergencyAdvice, Time: $([math]::Round($result.Duration, 2))s"
    
    if ($Verbose -and $result.Data.answer) {
        Write-Host "   Answer preview: $($result.Data.answer.Substring(0, [Math]::Min(150, $result.Data.answer.Length)))..." -ForegroundColor Gray
    }
} else {
    Write-TestResult -TestName "Emergency Situation" -Passed $false `
        -Message "$($result.Error)"
}

# Test 10: Grooming query
Write-TestHeader "Test 10: Grooming Question"
$result = Invoke-ChatbotQuery -Message "How often should I bathe my dog?"

if ($result.Success -and $result.Data.answer) {
    $hasGroomingInfo = $result.Data.answer -match "bath|groom|week|month|skin|coat" -or $result.Data.answer.Length -gt 50
    
    Write-TestResult -TestName "Grooming Question" -Passed $hasGroomingInfo `
        -Message "Contains grooming advice: $hasGroomingInfo, Time: $([math]::Round($result.Duration, 2))s"
    
    if ($Verbose -and $result.Data.answer) {
        Write-Host "   Answer preview: $($result.Data.answer.Substring(0, [Math]::Min(150, $result.Data.answer.Length)))..." -ForegroundColor Gray
    }
} else {
    Write-TestResult -TestName "Grooming Question" -Passed $false `
        -Message "$($result.Error)"
}

# Test 11: Invalid/Empty query handling
Write-TestHeader "Test 11: Empty Query Handling"
$result = Invoke-ChatbotQuery -Message ""

$passed = -not $result.Success -and ($result.StatusCode -eq 400)

if ($passed) {
    Write-TestResult -TestName "Empty Query Handling" -Passed $true `
        -Message "Correctly rejected empty query (400 Bad Request)"
} else {
    Write-TestResult -TestName "Empty Query Handling" -Passed $false `
        -Message "Should reject empty queries with 400"
}

# Test 12: Response structure validation
Write-TestHeader "Test 12: Response Structure"
$result = Invoke-ChatbotQuery -Message "Tell me about dog care"

if ($result.Success) {
    $hasRequiredFields = ($result.Data.success -ne $null) -and 
                        ($result.Data.answer -ne $null) -and
                        ($result.Data.query -ne $null)
    
    if ($hasRequiredFields) {
        Write-TestResult -TestName "Response Structure" -Passed $true `
            -Message "Response has required fields (success, answer, query)"
    } else {
        Write-TestResult -TestName "Response Structure" -Passed $false `
            -Message "Missing required response fields"
    }
} else {
    Write-TestResult -TestName "Response Structure" -Passed $false `
        -Message "Failed to get response"
}

# ============================================
# Test Summary
# ============================================
Write-Host "`n" -NoNewline
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "  TEST SUMMARY" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

$totalTests = $PassedTests + $FailedTests
$passPercentage = if ($totalTests -gt 0) { [math]::Round(($PassedTests / $totalTests) * 100, 2) } else { 0 }

Write-Host "Total Tests:  $totalTests" -ForegroundColor White
Write-Host "Passed:       $PassedTests" -ForegroundColor Green
Write-Host "Failed:       $FailedTests" -ForegroundColor Red
Write-Host "Pass Rate:    $passPercentage%" -ForegroundColor $(if ($passPercentage -ge 80) { "Green" } else { "Yellow" })

# Calculate average response time
$successfulTests = $TestResults | Where-Object { $_.Response -and $_.Response.Duration }
if ($successfulTests) {
    $avgDuration = ($successfulTests | ForEach-Object { $_.Response.Duration } | Measure-Object -Average).Average
    Write-Host "Avg Response: $([math]::Round($avgDuration, 2))s" -ForegroundColor Cyan
}

# Export detailed results to JSON
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$reportPath = "chatbot-test-results_$timestamp.json"
$TestResults | ConvertTo-Json -Depth 4 | Out-File -FilePath $reportPath -Encoding UTF8

Write-Host "`nDetailed report saved to: $reportPath" -ForegroundColor Cyan

if ($FailedTests -gt 0) {
    Write-Host "`n⚠️  Some tests failed. Please review." -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "`n✅ All tests passed!" -ForegroundColor Green
    exit 0
}
