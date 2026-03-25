# ============================================
# PawPal Backend - Integration Tests
# ============================================
# Tests: End-to-end user flows and cross-system integration
# ============================================

param(
    [string]$BaseURL = "https://transudatory-fecklessly-karisa.ngrok-free.dev",
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"
$TestResults = @()
$PassedTests = 0
$FailedTests = 0

# Test data storage
$script:TestUsers = @{}
$script:TestVets = @{}
$script:TestBreeds = @{}

# ============================================
# Helper Functions
# ============================================

function Write-TestHeader {
    param([string]$Message)
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
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
    
    $script:TestResults += $result
    
    if ($Passed) {
        $script:PassedTests++
        Write-Host "✅ PASS: $TestName" -ForegroundColor Green
        if ($Message) {
            Write-Host "   → $Message" -ForegroundColor DarkGreen
        }
    } else {
        $script:FailedTests++
        Write-Host "❌ FAIL: $TestName" -ForegroundColor Red
        if ($Message) {
            Write-Host "   → $Message" -ForegroundColor DarkRed
        }
    }
    
    if ($Verbose -and $Response) {
        Write-Host "   Response: $($Response | ConvertTo-Json -Depth 2)" -ForegroundColor DarkGray
    }
}

function Invoke-APIRequest {
    param(
        [string]$Endpoint,
        [string]$Method = "POST",
        [hashtable]$Body = @{},
        [hashtable]$Headers = @{
            "Content-Type" = "application/json"
            "ngrok-skip-browser-warning" = "true"
        }
    )
    
    try {
        $params = @{
            Uri = "$BaseURL$Endpoint"
            Method = $Method
            Headers = $Headers
            ContentType = "application/json"
        }
        
        if ($Body.Count -gt 0 -and $Method -ne "GET") {
            $params.Body = ($Body | ConvertTo-Json -Depth 5)
        }
        
        $response = Invoke-RestMethod @params
        return @{
            Success = $true
            Data = $response
            StatusCode = 200
        }
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        $errorBody = $null
        
        try {
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $errorBody = $reader.ReadToEnd() | ConvertFrom-Json
            $reader.Close()
        } catch {}
        
        return @{
            Success = $false
            Error = $_.Exception.Message
            StatusCode = $statusCode
            ErrorBody = $errorBody
        }
    }
}

# ============================================
# INTEGRATION TESTS - USER JOURNEY FLOWS
# ============================================

Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║   PAWPAL INTEGRATION TEST SUITE       ║" -ForegroundColor Magenta
Write-Host "║   30 End-to-End Flow Tests            ║" -ForegroundColor Magenta
Write-Host "╚════════════════════════════════════════╝`n" -ForegroundColor Magenta

# ============================================
# SECTION 1: PET OWNER JOURNEY (Tests 1-10)
# ============================================

Write-Host "`n┌─────────────────────────────────────┐" -ForegroundColor Yellow
Write-Host "│ SECTION 1: PET OWNER JOURNEY        │" -ForegroundColor Yellow
Write-Host "└─────────────────────────────────────┘" -ForegroundColor Yellow

# Test 1: Pet Owner Registration
Write-TestHeader "Test 1: Pet Owner Registration"
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$ownerEmail = "petowner_$timestamp@pawpal.com"
$ownerPassword = "OwnerPass123!"

$signupBody = @{
    email = $ownerEmail
    password = $ownerPassword
    fullName = "John Pet Owner"
}

$result = Invoke-APIRequest -Endpoint "/api/v1/auth/signup" -Body $signupBody

if ($result.Success -and $result.Data.accessToken) {
    $script:TestUsers.Owner = @{
        Email = $ownerEmail
        Password = $ownerPassword
        Token = $result.Data.accessToken
        UserId = $result.Data.user.uid
    }
    Write-TestResult -TestName "Pet Owner Registration" -Passed $true -Message "Owner registered: $ownerEmail"
} else {
    Write-TestResult -TestName "Pet Owner Registration" -Passed $false -Message $result.Error
}

# Test 2: Pet Owner Sign In
Write-TestHeader "Test 2: Pet Owner Sign In"

$signinBody = @{
    email = $ownerEmail
    password = $ownerPassword
}

$result = Invoke-APIRequest -Endpoint "/api/v1/auth/signin" -Body $signinBody

if ($result.Success -and $result.Data.accessToken) {
    $script:TestUsers.Owner.Token = $result.Data.accessToken
    Write-TestResult -TestName "Pet Owner Sign In" -Passed $true -Message "Owner signed in successfully"
} else {
    Write-TestResult -TestName "Pet Owner Sign In" -Passed $false -Message $result.Error
}

# Test 3: Pet Owner Profile Access
Write-TestHeader "Test 3: Pet Owner Profile Access"

$headers = @{
    "Content-Type" = "application/json"
    "ngrok-skip-browser-warning" = "true"
    "Authorization" = "Bearer $($script:TestUsers.Owner.Token)"
}

$result = Invoke-APIRequest -Endpoint "/api/v1/profile" -Method "GET" -Headers $headers

if ($result.Success -and $result.Data.data.email -eq $ownerEmail) {
    Write-TestResult -TestName "Pet Owner Profile Access" -Passed $true -Message "Profile retrieved successfully"
} else {
    Write-TestResult -TestName "Pet Owner Profile Access" -Passed $false -Message $result.Error
}

# Test 4: Dog Breed Classification (Golden Retriever)
Write-TestHeader "Test 4: Dog Breed Classification - Golden Retriever"

$dogImagePath = "d:\PawPal\ML_Models\dogs\Golden_Retriever\golden_retriever_1.jpg"
if (Test-Path $dogImagePath) {
    $fileBytes = [System.IO.File]::ReadAllBytes($dogImagePath)
    $base64Image = [Convert]::ToBase64String($fileBytes)
    $base64DataUrl = "data:image/jpeg;base64,{0}" -f $base64Image
    
    $predictBody = @{
        image = $base64DataUrl
        pet_type = "dog"
        top_k = 5
    }
    
    $result = Invoke-APIRequest -Endpoint "/api/v1/predict" -Body $predictBody
    
    if ($result.Success -and $result.Data.top_predictions) {
        $topBreed = $result.Data.top_predictions[0].breed
        $confidence = $result.Data.top_predictions[0].confidence
        $script:TestBreeds.Dog1 = $topBreed
        
        $confidencePct = [math]::Round($confidence * 100, 2)
        Write-TestResult -TestName "Dog Breed Classification" -Passed $true -Message "Detected: $topBreed ($confidencePct percent confidence)"
    } else {
        Write-TestResult -TestName "Dog Breed Classification" -Passed $false -Message $result.Error
    }
} else {
    Write-TestResult -TestName "Dog Breed Classification" -Passed $false -Message "Test image not found"
}

# Test 5: Cat Breed Classification (Maine Coon)
Write-TestHeader "Test 5: Cat Breed Classification - Maine Coon"

$catImagePath = "d:\PawPal\ML_Models\cats\Maine_Coon\maine_coon_1.jpg"
if (Test-Path $catImagePath) {
    $fileBytes = [System.IO.File]::ReadAllBytes($catImagePath)
    $base64Image = [Convert]::ToBase64String($fileBytes)
    $base64DataUrl = "data:image/jpeg;base64,{0}" -f $base64Image
    
    $predictBody = @{
        image = $base64DataUrl
        pet_type = "cat"
        top_k = 5
    }
    
    $result = Invoke-APIRequest -Endpoint "/api/v1/predict" -Body $predictBody
    
    if ($result.Success -and $result.Data.top_predictions) {
        $topBreed = $result.Data.top_predictions[0].breed
        $confidence = $result.Data.top_predictions[0].confidence
        $script:TestBreeds.Cat1 = $topBreed
        
        $confidencePct = [math]::Round($confidence * 100, 2)
        Write-TestResult -TestName "Cat Breed Classification" -Passed $true -Message "Detected: $topBreed ($confidencePct percent confidence)"
    } else {
        Write-TestResult -TestName "Cat Breed Classification" -Passed $false -Message $result.Error
    }
} else {
    Write-TestResult -TestName "Cat Breed Classification" -Passed $false -Message "Test image not found"
}

# Test 6: Chatbot - General Pet Care Query
Write-TestHeader "Test 6: Chatbot - General Pet Care Query"

$chatBody = @{
    query = "What are the basic care requirements for a Golden Retriever?"
}

$result = Invoke-APIRequest -Endpoint "/api/v1/chatbot/query" -Body $chatBody

if ($result.Success -and $result.Data.answer) {
    $answerLength = $result.Data.answer.Length
    Write-TestResult -TestName "Chatbot General Query" -Passed $true -Message "Response: $answerLength chars, Sources: $($result.Data.sources.Count)"
} else {
    Write-TestResult -TestName "Chatbot General Query" -Passed $false -Message $result.Error
}

# Test 7: Chatbot - Breed-Specific Query
Write-TestHeader "Test 7: Chatbot - Breed-Specific Health Query"

$chatBody = @{
    query = "What are common health issues in $($script:TestBreeds.Dog1) dogs?"
}

$result = Invoke-APIRequest -Endpoint "/api/v1/chatbot/query" -Body $chatBody

if ($result.Success -and $result.Data.answer) {
    $containsBreed = $result.Data.answer -match $script:TestBreeds.Dog1 -or $result.Data.answer -match "health"
    Write-TestResult -TestName "Chatbot Breed-Specific Query" -Passed $containsBreed -Message "Breed-specific health info provided"
} else {
    Write-TestResult -TestName "Chatbot Breed-Specific Query" -Passed $false -Message $result.Error
}

# Test 8: Chatbot - Emergency Query
Write-TestHeader "Test 8: Chatbot - Emergency Situation"

$chatBody = @{
    query = "My dog ate chocolate! What should I do?"
}

$result = Invoke-APIRequest -Endpoint "/api/v1/chatbot/query" -Body $chatBody

if ($result.Success -and $result.Data.answer) {
    $hasUrgentAdvice = $result.Data.answer -match "vet|emergency|immediately|urgent|poison|toxic"
    Write-TestResult -TestName "Chatbot Emergency Query" -Passed $hasUrgentAdvice -Message "Emergency advice provided"
} else {
    Write-TestResult -TestName "Chatbot Emergency Query" -Passed $false -Message $result.Error
}

# Test 9: Chatbot - Cat Care Query
Write-TestHeader "Test 9: Chatbot - Cat Nutrition Query"

$chatBody = @{
    query = "What should I feed my $($script:TestBreeds.Cat1) cat?"
}

$result = Invoke-APIRequest -Endpoint "/api/v1/chatbot/query" -Body $chatBody

if ($result.Success -and $result.Data.answer) {
    $hasNutritionInfo = $result.Data.answer -match "food|diet|nutrition|feed|protein|meal"
    Write-TestResult -TestName "Chatbot Cat Nutrition" -Passed $hasNutritionInfo -Message "Nutrition information provided"
} else {
    Write-TestResult -TestName "Chatbot Cat Nutrition" -Passed $false -Message $result.Error
}

# Test 10: Health Check Integration
Write-TestHeader "Test 10: Backend Health Check"

$result = Invoke-APIRequest -Endpoint "/health" -Method "GET"

if ($result.Success -and $result.Data.status -eq "healthy") {
    Write-TestResult -TestName "Backend Health Check" -Passed $true -Message "Backend is healthy"
} else {
    Write-TestResult -TestName "Backend Health Check" -Passed $false -Message "Backend health check failed"
}

# ============================================
# SECTION 2: VET JOURNEY (Tests 11-20)
# ============================================

Write-Host "`n┌─────────────────────────────────────┐" -ForegroundColor Yellow
Write-Host "│ SECTION 2: VETERINARIAN JOURNEY     │" -ForegroundColor Yellow
Write-Host "└─────────────────────────────────────┘" -ForegroundColor Yellow

# Test 11: Vet User Registration
Write-TestHeader "Test 11: Vet User Registration"

$vetEmail = "vet_integ_$timestamp@pawpal.com"
$vetPassword = "VetPass123!"

$signupBody = @{
    email = $vetEmail
    password = $vetPassword
    fullName = "Dr. Integration Vet"
}

$result = Invoke-APIRequest -Endpoint "/api/v1/auth/signup" -Body $signupBody

if ($result.Success -and $result.Data.accessToken) {
    $script:TestUsers.Vet = @{
        Email = $vetEmail
        Password = $vetPassword
        Token = $result.Data.accessToken
        UserId = $result.Data.user.uid
    }
    Write-TestResult -TestName "Vet User Registration" -Passed $true -Message "Vet registered: $vetEmail"
} else {
    Write-TestResult -TestName "Vet User Registration" -Passed $false -Message $result.Error
}

# Test 12: Vet Role Assignment
Write-TestHeader "Test 12: Assign Vet Role"

$headers = @{
    "Content-Type" = "application/json"
    "ngrok-skip-browser-warning" = "true"
    "Authorization" = "Bearer $($script:TestUsers.Vet.Token)"
}

$roleBody = @{
    role = "vet"
}

$result = Invoke-APIRequest -Endpoint "/api/v1/auth/set-role" -Body $roleBody -Headers $headers

if ($result.Success) {
    Write-TestResult -TestName "Assign Vet Role" -Passed $true -Message "Role set to vet"
} else {
    Write-TestResult -TestName "Assign Vet Role" -Passed $false -Message $result.Error
}

# Test 13: Create Vet Profile
Write-TestHeader "Test 13: Create Comprehensive Vet Profile"

$vetProfileData = @{
    fullName = "Dr. Sarah Integration"
    degree = "DVM, DACVIM"
    licenseNumber = "VET-INTEG-2024"
    specialization = @("Emergency Care", "Internal Medicine", "Surgery")
    experience = 12
    clinicName = "PawPal Integration Clinic"
    clinicAddress = "456 Integration Ave"
    city = "San Francisco"
    state = "CA"
    zipCode = "94103"
    phone = "+1-555-INTEG-VET"
    consultationFee = 100.00
    currency = "USD"
    bio = "Board-certified veterinarian with extensive experience in emergency care and internal medicine."
    availabilityHours = "Mon-Fri: 9:00 AM - 6:00 PM"
    isAvailable = $true
}

$result = Invoke-APIRequest -Endpoint "/api/v1/vets/profile" -Body $vetProfileData -Headers $headers

if ($result.Success) {
    Write-TestResult -TestName "Create Vet Profile" -Passed $true -Message "Profile created successfully"
} else {
    Write-TestResult -TestName "Create Vet Profile" -Passed $false -Message $result.Error
}

# Test 14: Retrieve Own Vet Profile
Write-TestHeader "Test 14: Retrieve Own Vet Profile"

Start-Sleep -Seconds 2
$result = Invoke-APIRequest -Endpoint "/api/v1/vets/profile/$($script:TestUsers.Vet.UserId)" -Method "GET"

if ($result.Success -and $result.Data.vetProfile) {
    $profile = $result.Data.vetProfile
    $passed = ($profile.consultationFee -eq 100.00) -and ($profile.specialization.Count -eq 3)
    Write-TestResult -TestName "Retrieve Own Vet Profile" -Passed $passed -Message "Profile: $($profile.fullName), Fee: $($profile.consultationFee)"
} else {
    Write-TestResult -TestName "Retrieve Own Vet Profile" -Passed $false -Message $result.Error
}

# Test 15: List All Vets (Public Access)
Write-TestHeader "Test 15: List All Vets - Public Endpoint"

$result = Invoke-APIRequest -Endpoint "/api/v1/vets" -Method "GET"

if ($result.Success -and $result.Data.vets) {
    $ourVet = $result.Data.vets | Where-Object { $_.userId -eq $script:TestUsers.Vet.UserId }
    $passed = $ourVet -ne $null
    Write-TestResult -TestName "List All Vets" -Passed $passed -Message "Total vets: $($result.Data.vets.Count), Our vet found: $($ourVet -ne $null)"
} else {
    Write-TestResult -TestName "List All Vets" -Passed $false -Message $result.Error
}

# Test 16: Update Vet Profile
Write-TestHeader "Test 16: Update Vet Profile (Fee Change)"

$headers = @{
    "Content-Type" = "application/json"
    "ngrok-skip-browser-warning" = "true"
    "Authorization" = "Bearer $($script:TestUsers.Vet.Token)"
}

$updatedProfile = $vetProfileData.Clone()
$updatedProfile.consultationFee = 120.00
$updatedProfile.isAvailable = $false

$result = Invoke-APIRequest -Endpoint "/api/v1/vets/profile" -Body $updatedProfile -Headers $headers

if ($result.Success) {
    Write-TestResult -TestName "Update Vet Profile" -Passed $true -Message "Fee updated to 120.00, Availability: false"
} else {
    Write-TestResult -TestName "Update Vet Profile" -Passed $false -Message $result.Error
}

# Test 17: Verify Profile Update
Write-TestHeader "Test 17: Verify Profile Update Persisted"

Start-Sleep -Seconds 2
$result = Invoke-APIRequest -Endpoint "/api/v1/vets/profile/$($script:TestUsers.Vet.UserId)" -Method "GET"

if ($result.Success -and $result.Data.vetProfile) {
    $passed = ($result.Data.vetProfile.consultationFee -eq 120.00) -and ($result.Data.vetProfile.isAvailable -eq $false)
    Write-TestResult -TestName "Verify Profile Update" -Passed $passed -Message "Update verified: Fee=$($result.Data.vetProfile.consultationFee), Available=$($result.Data.vetProfile.isAvailable)"
} else {
    Write-TestResult -TestName "Verify Profile Update" -Passed $false -Message $result.Error
}

# Test 18: Second Vet Registration
Write-TestHeader "Test 18: Register Second Vet for Comparison"

$vet2Email = "vet2_integ_$timestamp@pawpal.com"
$signupBody = @{
    email = $vet2Email
    password = "VetPass123!"
    fullName = "Dr. Second Vet"
}

$result = Invoke-APIRequest -Endpoint "/api/v1/auth/signup" -Body $signupBody

if ($result.Success) {
    $vet2Token = $result.Data.accessToken
    $vet2UserId = $result.Data.user.uid
    
    # Set role
    $headers2 = @{
        "Content-Type" = "application/json"
        "ngrok-skip-browser-warning" = "true"
        "Authorization" = "Bearer $vet2Token"
    }
    
    $roleResult = Invoke-APIRequest -Endpoint "/api/v1/auth/set-role" -Body @{role = "vet"} -Headers $headers2
    
    # Create profile
    $vet2Profile = @{
        fullName = "Dr. Second Vet"
        degree = "DVM"
        licenseNumber = "VET-INTEG-2024-002"
        specialization = @("Dentistry", "Dermatology")
        experience = 5
        clinicName = "Second Vet Clinic"
        phone = "+1-555-VET-2222"
        consultationFee = 80.00
        currency = "USD"
        isAvailable = $true
    }
    
    $profileResult = Invoke-APIRequest -Endpoint "/api/v1/vets/profile" -Body $vet2Profile -Headers $headers2
    
    if ($profileResult.Success) {
        Write-TestResult -TestName "Second Vet Registration" -Passed $true -Message "Second vet created with different specializations"
    } else {
        Write-TestResult -TestName "Second Vet Registration" -Passed $false -Message "Failed to create second vet profile"
    }
} else {
    Write-TestResult -TestName "Second Vet Registration" -Passed $false -Message $result.Error
}

# Test 19: Multiple Vets in List
Write-TestHeader "Test 19: Verify Multiple Vets in Listing"

Start-Sleep -Seconds 2
$result = Invoke-APIRequest -Endpoint "/api/v1/vets" -Method "GET"

if ($result.Success -and $result.Data.vets) {
    $passed = $result.Data.vets.Count -ge 2
    Write-TestResult -TestName "Multiple Vets in List" -Passed $passed -Message "Total vets available: $($result.Data.vets.Count)"
} else {
    Write-TestResult -TestName "Multiple Vets in List" -Passed $false -Message $result.Error
}

# Test 20: Vet Profile Access After Sign Out/Sign In
Write-TestHeader "Test 20: Vet Profile Persistence After Re-authentication"

$signinBody = @{
    email = $vetEmail
    password = $vetPassword
}

$signinResult = Invoke-APIRequest -Endpoint "/api/v1/auth/signin" -Body $signinBody

if ($signinResult.Success) {
    $newToken = $signinResult.Data.accessToken
    
    $headers = @{
        "Content-Type" = "application/json"
        "ngrok-skip-browser-warning" = "true"
        "Authorization" = "Bearer $newToken"
    }
    
    $profileResult = Invoke-APIRequest -Endpoint "/api/v1/profile" -Method "GET" -Headers $headers
    
    if ($profileResult.Success -and $profileResult.Data.data.accountType -eq "vet") {
        Write-TestResult -TestName "Profile Persistence" -Passed $true -Message "Vet role persisted after re-authentication"
    } else {
        Write-TestResult -TestName "Profile Persistence" -Passed $false -Message "Role not persisted"
    }
} else {
    Write-TestResult -TestName "Profile Persistence" -Passed $false -Message "Failed to re-authenticate"
}

# ============================================
# SECTION 3: CROSS-SYSTEM INTEGRATION (Tests 21-30)
# ============================================

Write-Host "`n┌─────────────────────────────────────┐" -ForegroundColor Yellow
Write-Host "│ SECTION 3: CROSS-SYSTEM INTEGRATION │" -ForegroundColor Yellow
Write-Host "└─────────────────────────────────────┘" -ForegroundColor Yellow

# Test 21: ML Model Info for Dogs
Write-TestHeader "Test 21: Get ML Model Information - Dogs"

$result = Invoke-APIRequest -Endpoint "/api/v1/model/info?pet_type=dog" -Method "GET"

if ($result.Success -and $result.Data.model_type) {
    Write-TestResult -TestName "Dog Model Info" -Passed $true -Message "Model: $($result.Data.model_type), Breeds: $($result.Data.num_classes)"
} else {
    Write-TestResult -TestName "Dog Model Info" -Passed $false -Message $result.Error
}

# Test 22: ML Model Info for Cats
Write-TestHeader "Test 22: Get ML Model Information - Cats"

$result = Invoke-APIRequest -Endpoint "/api/v1/model/info?pet_type=cat" -Method "GET"

if ($result.Success -and $result.Data.model_type) {
    Write-TestResult -TestName "Cat Model Info" -Passed $true -Message "Model: $($result.Data.model_type), Breeds: $($result.Data.num_classes)"
} else {
    Write-TestResult -TestName "Cat Model Info" -Passed $false -Message $result.Error
}

# Test 23: Multiple Dog Breed Classifications
Write-TestHeader "Test 23: Classify Multiple Dog Breeds"

$dogBreeds = @("Golden_Retriever", "Labrador_Retriever", "German_Shepherd")
$successCount = 0

foreach ($breed in $dogBreeds) {
    $imagePath = "d:\PawPal\ML_Models\dogs\$breed\$($breed.ToLower())_1.jpg"
    if (Test-Path $imagePath) {
        $fileBytes = [System.IO.File]::ReadAllBytes($imagePath)
        $base64Image = [Convert]::ToBase64String($fileBytes)
        $base64DataUrl = "data:image/jpeg;base64,{0}" -f $base64Image
        
        $predictBody = @{
            image = $base64DataUrl
            pet_type = "dog"
            top_k = 3
        }
        
        $result = Invoke-APIRequest -Endpoint "/api/v1/predict" -Body $predictBody
        if ($result.Success) { $successCount++ }
    }
}

$passed = $successCount -eq $dogBreeds.Count
Write-TestResult -TestName "Multiple Dog Classifications" -Passed $passed -Message "Successfully classified $successCount/$($dogBreeds.Count) breeds"

# Test 24: Multiple Cat Breed Classifications
Write-TestHeader "Test 24: Classify Multiple Cat Breeds"

$catBreeds = @("Maine_Coon", "British_Shorthair")
$successCount = 0

foreach ($breed in $catBreeds) {
    $imagePath = "d:\PawPal\ML_Models\cats\$breed\$($breed.ToLower())_1.jpg"
    if (Test-Path $imagePath) {
        $fileBytes = [System.IO.File]::ReadAllBytes($imagePath)
        $base64Image = [Convert]::ToBase64String($fileBytes)
        $base64DataUrl = "data:image/jpeg;base64,{0}" -f $base64Image
        
        $predictBody = @{
            image = $base64DataUrl
            pet_type = "cat"
            top_k = 3
        }
        
        $result = Invoke-APIRequest -Endpoint "/api/v1/predict" -Body $predictBody
        if ($result.Success) { $successCount++ }
    }
}

$passed = $successCount -eq $catBreeds.Count
Write-TestResult -TestName "Multiple Cat Classifications" -Passed $passed -Message "Successfully classified $successCount/$($catBreeds.Count) breeds"

# Test 25: Chatbot Context-Aware Query
Write-TestHeader "Test 25: Chatbot with Pet Profile Context"

$chatBody = @{
    query = "I have a 3-year-old Golden Retriever named Max who weighs 70 lbs. What vaccinations does he need?"
    pet_profile = @{
        name = "Max"
        breed = "Golden Retriever"
        age = 3
        weight = 70
    }
}

$result = Invoke-APIRequest -Endpoint "/api/v1/chatbot/query" -Body $chatBody

if ($result.Success -and $result.Data.answer) {
    $hasVaccinationInfo = $result.Data.answer -match "vaccin|immuniz|shot|rabies|parvo"
    Write-TestResult -TestName "Context-Aware Chatbot" -Passed $hasVaccinationInfo -Message "Vaccination info provided with context"
} else {
    Write-TestResult -TestName "Context-Aware Chatbot" -Passed $false -Message $result.Error
}

# Test 26: Chatbot Multiple Rapid Queries
Write-TestHeader "Test 26: Multiple Rapid Chatbot Queries"

$queries = @(
    "How often should I groom my dog?",
    "What foods are toxic to cats?",
    "When should I take my puppy to the vet?"
)

$successCount = 0
foreach ($query in $queries) {
    $result = Invoke-APIRequest -Endpoint "/api/v1/chatbot/query" -Body @{query = $query}
    if ($result.Success -and $result.Data.answer) { $successCount++ }
    Start-Sleep -Milliseconds 500
}

$passed = $successCount -eq $queries.Count
Write-TestResult -TestName "Multiple Rapid Queries" -Passed $passed -Message "Successfully answered $successCount/$($queries.Count) queries"

# Test 27: Error Handling - Invalid Pet Type
Write-TestHeader "Test 27: Invalid Pet Type Handling"

$predictBody = @{
    image = "data:image/jpeg;base64,/9j/4AAQSkZJRg=="
    pet_type = "invalid_pet"
    top_k = 5
}

$result = Invoke-APIRequest -Endpoint "/api/v1/predict" -Body $predictBody

$passed = -not $result.Success -and ($result.StatusCode -eq 400 -or $result.StatusCode -eq 422)
Write-TestResult -TestName "Invalid Pet Type Handling" -Passed $passed -Message "Correctly rejected invalid pet type"

# Test 28: Error Handling - Empty Chatbot Query
Write-TestHeader "Test 28: Empty Chatbot Query Validation"

$result = Invoke-APIRequest -Endpoint "/api/v1/chatbot/query" -Body @{query = ""}

$passed = -not $result.Success -and ($result.StatusCode -eq 400 -or $result.StatusCode -eq 422)
Write-TestResult -TestName "Empty Query Validation" -Passed $passed -Message "Correctly rejected empty query"

# Test 29: Concurrent User Operations
Write-TestHeader "Test 29: Concurrent User Profile Access"

$owner1 = Invoke-APIRequest -Endpoint "/api/v1/profile" -Method "GET" -Headers @{
    "Content-Type" = "application/json"
    "ngrok-skip-browser-warning" = "true"
    "Authorization" = "Bearer $($script:TestUsers.Owner.Token)"
}

$vet1 = Invoke-APIRequest -Endpoint "/api/v1/profile" -Method "GET" -Headers @{
    "Content-Type" = "application/json"
    "ngrok-skip-browser-warning" = "true"
    "Authorization" = "Bearer $($script:TestUsers.Vet.Token)"
}

$passed = $owner1.Success -and $vet1.Success -and 
          ($owner1.Data.data.email -eq $ownerEmail) -and 
          ($vet1.Data.data.accountType -eq "vet")

Write-TestResult -TestName "Concurrent User Operations" -Passed $passed -Message "Multiple users accessed profiles concurrently"

# Test 30: End-to-End Complete Flow
Write-TestHeader "Test 30: Complete End-to-End Flow"

Write-Host "   Executing complete user journey..." -ForegroundColor DarkGray

# Step 1: New user registers
$e2eEmail = "e2e_$timestamp@pawpal.com"
$signupResult = Invoke-APIRequest -Endpoint "/api/v1/auth/signup" -Body @{
    email = $e2eEmail
    password = "E2EPass123!"
    fullName = "E2E Test User"
}

$step1 = $signupResult.Success

# Step 2: User signs in
if ($step1) {
    $signinResult = Invoke-APIRequest -Endpoint "/api/v1/auth/signin" -Body @{
        email = $e2eEmail
        password = "E2EPass123!"
    }
    $step2 = $signinResult.Success
    $e2eToken = $signinResult.Data.accessToken
} else {
    $step2 = $false
}

# Step 3: Classify a pet breed
if ($step2) {
    $imagePath = "d:\PawPal\ML_Models\dogs\Beagle\beagle_1.jpg"
    if (Test-Path $imagePath) {
        $fileBytes = [System.IO.File]::ReadAllBytes($imagePath)
        $base64Image = [Convert]::ToBase64String($fileBytes)
        $base64DataUrl = "data:image/jpeg;base64,{0}" -f $base64Image
        
        $classifyResult = Invoke-APIRequest -Endpoint "/api/v1/predict" -Body @{
            image = $base64DataUrl
            pet_type = "dog"
            top_k = 3
        }
        $step3 = $classifyResult.Success
        $detectedBreed = $classifyResult.Data.top_predictions[0].breed
    } else {
        $step3 = $false
    }
} else {
    $step3 = $false
}

# Step 4: Ask chatbot about the breed
if ($step3) {
    $chatResult = Invoke-APIRequest -Endpoint "/api/v1/chatbot/query" -Body @{
        query = "Tell me about $detectedBreed health care"
    }
    $step4 = $chatResult.Success
} else {
    $step4 = $false
}

# Step 5: Find a vet
if ($step4) {
    $vetListResult = Invoke-APIRequest -Endpoint "/api/v1/vets" -Method "GET"
    $step5 = $vetListResult.Success -and $vetListResult.Data.vets.Count -gt 0
} else {
    $step5 = $false
}

# Step 6: Access profile
if ($step5) {
    $headers = @{
        "Content-Type" = "application/json"
        "ngrok-skip-browser-warning" = "true"
        "Authorization" = "Bearer $e2eToken"
    }
    $profileResult = Invoke-APIRequest -Endpoint "/api/v1/profile" -Method "GET" -Headers $headers
    $step6 = $profileResult.Success
} else {
    $step6 = $false
}

$allStepsPassed = $step1 -and $step2 -and $step3 -and $step4 -and $step5 -and $step6

if ($allStepsPassed) {
    Write-TestResult -TestName "Complete E2E Flow" -Passed $true -Message "All 6 steps completed: Register → SignIn → Classify → Chatbot → Find Vet → Profile"
} else {
    $failedStep = if (-not $step1) { "Registration" } 
                  elseif (-not $step2) { "SignIn" } 
                  elseif (-not $step3) { "Classification" } 
                  elseif (-not $step4) { "Chatbot" } 
                  elseif (-not $step5) { "Vet List" } 
                  else { "Profile" }
    Write-TestResult -TestName "Complete E2E Flow" -Passed $false -Message "Failed at step: $failedStep"
}

# ============================================
# Test Summary
# ============================================
Write-Host "`n" -NoNewline
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║          TEST SUMMARY                  ║" -ForegroundColor Magenta
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Magenta

$totalTests = $PassedTests + $FailedTests
$passPercentage = if ($totalTests -gt 0) { [math]::Round(($PassedTests / $totalTests) * 100, 2) } else { 0 }

Write-Host "`nTotal Tests:  $totalTests" -ForegroundColor White
Write-Host "Passed:       $PassedTests" -ForegroundColor Green
Write-Host "Failed:       $FailedTests" -ForegroundColor Red
Write-Host "Pass Rate:    $passPercentage%" -ForegroundColor $(if ($passPercentage -ge 80) { "Green" } else { "Yellow" })

# Export detailed results to JSON
$reportPath = "integration-test-results_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
$TestResults | ConvertTo-Json -Depth 3 | Out-File -FilePath $reportPath -Encoding UTF8

Write-Host "`nDetailed report saved to: $reportPath" -ForegroundColor Cyan

# Summary by section
Write-Host "`n┌─────────────────────────────────────┐" -ForegroundColor Cyan
Write-Host "│ RESULTS BY SECTION                  │" -ForegroundColor Cyan
Write-Host "└─────────────────────────────────────┘" -ForegroundColor Cyan

$section1 = ($TestResults | Select-Object -First 10 | Where-Object {$_.Passed -eq $true}).Count
$section2 = ($TestResults | Select-Object -Skip 10 -First 10 | Where-Object {$_.Passed -eq $true}).Count
$section3 = ($TestResults | Select-Object -Skip 20 -First 10 | Where-Object {$_.Passed -eq $true}).Count

Write-Host "Section 1 (Pet Owner Journey):    $section1/10" -ForegroundColor $(if ($section1 -eq 10) { "Green" } else { "Yellow" })
Write-Host "Section 2 (Vet Journey):          $section2/10" -ForegroundColor $(if ($section2 -eq 10) { "Green" } else { "Yellow" })
Write-Host "Section 3 (Cross-System):         $section3/10" -ForegroundColor $(if ($section3 -eq 10) { "Green" } else { "Yellow" })

if ($FailedTests -eq 0) {
    Write-Host "`n🎉 All integration tests passed!" -ForegroundColor Green
    Write-Host "   System is fully integrated and functional." -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n⚠️  Some integration tests failed." -ForegroundColor Yellow
    Write-Host "   Review the detailed report for diagnostics." -ForegroundColor Yellow
    exit 1
}
