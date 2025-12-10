# ============================================
# PawPal Backend - Vet Registration Tests
# ============================================
# Tests: Vet profile creation and management
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

function Invoke-SignUp {
    param(
        [string]$Email,
        [string]$Password,
        [string]$FullName
    )
    
    try {
        $body = @{
            email = $Email
            password = $Password
            fullName = $FullName
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "$BaseURL/api/v1/auth/signup" `
            -Method POST `
            -Headers @{
                "Content-Type" = "application/json"
                "ngrok-skip-browser-warning" = "true"
            } `
            -Body $body
        
        return @{
            Success = $true
            Data = $response
        }
    }
    catch {
        return @{
            Success = $false
            Error = $_.Exception.Message
            StatusCode = $_.Exception.Response.StatusCode.value__
        }
    }
}

function Invoke-SignIn {
    param(
        [string]$Email,
        [string]$Password
    )
    
    try {
        $body = @{
            email = $Email
            password = $Password
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "$BaseURL/api/v1/auth/signin" `
            -Method POST `
            -Headers @{
                "Content-Type" = "application/json"
                "ngrok-skip-browser-warning" = "true"
            } `
            -Body $body
        
        return @{
            Success = $true
            Data = $response
            Token = $response.accessToken
        }
    }
    catch {
        return @{
            Success = $false
            Error = $_.Exception.Message
            StatusCode = $_.Exception.Response.StatusCode.value__
        }
    }
}

function Invoke-SetUserRole {
    param(
        [string]$Token,
        [string]$Role
    )
    
    try {
        $body = @{
            role = $Role
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "$BaseURL/api/v1/auth/set-role" `
            -Method POST `
            -Headers @{
                "Content-Type" = "application/json"
                "Authorization" = "Bearer $Token"
                "ngrok-skip-browser-warning" = "true"
            } `
            -Body $body -ErrorAction Stop
        
        return @{
            Success = $true
            Data = $response
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

function Invoke-CreateVetProfile {
    param(
        [string]$Token,
        [hashtable]$VetData
    )
    
    try {
        $body = $VetData | ConvertTo-Json -Depth 3
        
        $response = Invoke-RestMethod -Uri "$BaseURL/api/v1/vets/profile" `
            -Method POST `
            -Headers @{
                "Content-Type" = "application/json"
                "Authorization" = "Bearer $Token"
                "ngrok-skip-browser-warning" = "true"
            } `
            -Body $body
        
        return @{
            Success = $true
            Data = $response
        }
    }
    catch {
        $errorBody = $null
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $errorBody = $reader.ReadToEnd()
        }
        
        return @{
            Success = $false
            Error = $_.Exception.Message
            StatusCode = $_.Exception.Response.StatusCode.value__
            ErrorBody = $errorBody
        }
    }
}

function Invoke-GetVetProfile {
    param(
        [string]$UserID,
        [string]$Token = $null
    )
    
    try {
        $headers = @{
            "ngrok-skip-browser-warning" = "true"
        }
        
        if ($Token) {
            $headers["Authorization"] = "Bearer $Token"
        }
        
        $response = Invoke-RestMethod -Uri "$BaseURL/api/v1/vets/profile/$UserID" `
            -Method GET `
            -Headers $headers
        
        return @{
            Success = $true
            Data = $response
        }
    }
    catch {
        return @{
            Success = $false
            Error = $_.Exception.Message
            StatusCode = $_.Exception.Response.StatusCode.value__
        }
    }
}

function Invoke-ListVets {
    try {
        $response = Invoke-RestMethod -Uri "$BaseURL/api/v1/vets" `
            -Method GET `
            -Headers @{
                "ngrok-skip-browser-warning" = "true"
            }
        
        return @{
            Success = $true
            Data = $response
        }
    }
    catch {
        return @{
            Success = $false
            Error = $_.Exception.Message
            StatusCode = $_.Exception.Response.StatusCode.value__
        }
    }
}

# ============================================
# VET REGISTRATION TESTS
# ============================================

Write-TestHeader "VET REGISTRATION TESTS"

# Test 1: Create test user
Write-TestHeader "Test 1: Create Test Vet User"
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$testEmail = "vet.test.$timestamp@pawpal.com"
$testPassword = "VetPass123!"
$testFullName = "Dr. Test Veterinarian"

$signupResult = Invoke-SignUp -Email $testEmail -Password $testPassword -FullName $testFullName

if ($signupResult.Success) {
    Write-TestResult -TestName "Create Test Vet User" -Passed $true `
        -Message "User created: $testEmail"
    $testUserID = $signupResult.Data.user.uid
    Write-Host "   User ID: $testUserID" -ForegroundColor DarkGray
} else {
    Write-TestResult -TestName "Create Test Vet User" -Passed $false `
        -Message $signupResult.Error
    Write-Host "⚠️  Cannot continue without user. Exiting." -ForegroundColor Yellow
    exit 1
}

# Test 2: Sign in to get token
Write-TestHeader "Test 2: Sign In Test User"
$signinResult = Invoke-SignIn -Email $testEmail -Password $testPassword

if ($signinResult.Success -and $signinResult.Token) {
    Write-TestResult -TestName "Sign In Test User" -Passed $true `
        -Message "Token obtained: $($signinResult.Token.Substring(0,20))..."
    $testToken = $signinResult.Token
} else {
    Write-TestResult -TestName "Sign In Test User" -Passed $false `
        -Message $signinResult.Error
    Write-Host "⚠️  Cannot continue without token. Exiting." -ForegroundColor Yellow
    exit 1
}

# Test 3: Set user role to vet
Write-TestHeader "Test 3: Set User Role to Vet"
$roleResult = Invoke-SetUserRole -Token $testToken -Role "vet"

if ($roleResult.Success) {
    Write-TestResult -TestName "Set User Role to Vet" -Passed $true `
        -Message "User role set to vet"
} else {
    Write-TestResult -TestName "Set User Role to Vet" -Passed $false `
        -Message $roleResult.Error
    Write-Host "⚠️  Cannot continue without vet role. Exiting." -ForegroundColor Yellow
    exit 1
}

# Test 4: Create vet profile with complete data
Write-TestHeader "Test 4: Create Complete Vet Profile"
$vetData = @{
    fullName = "Dr. Sarah Johnson"
    degree = "DVM, PhD"
    licenseNumber = "VET-2024-001234"
    specialization = @("Internal Medicine", "Surgery", "Emergency Care")
    experience = 8
    clinicName = "PawPal Veterinary Clinic"
    clinicAddress = "123 Pet Street"
    city = "San Francisco"
    state = "CA"
    zipCode = "94102"
    phone = "+1-555-VET-CARE"
    consultationFee = 75.00
    currency = "USD"
    bio = "Experienced veterinarian specializing in internal medicine and emergency care. Passionate about providing compassionate care to all pets."
    profilePhotoUrl = "https://example.com/dr-sarah-johnson.jpg"
    availabilityHours = "Mon-Fri: 9:00 AM - 6:00 PM, Sat: 10:00 AM - 4:00 PM"
    isAvailable = $true
}

$createResult = Invoke-CreateVetProfile -Token $testToken -VetData $vetData

if ($createResult.Success) {
    Write-TestResult -TestName "Create Complete Vet Profile" -Passed $true `
        -Message "Vet profile created successfully" -Response $createResult.Data
} else {
    Write-TestResult -TestName "Create Complete Vet Profile" -Passed $false `
        -Message "$($createResult.Error) - $($createResult.ErrorBody)"
}

# Test 5: Retrieve vet profile
Write-TestHeader "Test 5: Retrieve Vet Profile"
Start-Sleep -Seconds 2  # Longer delay to ensure data is committed

Write-Host "   Retrieving profile for user ID: $testUserID" -ForegroundColor DarkGray
$getResult = Invoke-GetVetProfile -UserID $testUserID

if ($getResult.Success -and $getResult.Data.vetProfile) {
    $profile = $getResult.Data.vetProfile
    $passed = ($profile.fullName -eq "Dr. Sarah Johnson") -and 
              ($profile.degree -eq "DVM, PhD") -and
              ($profile.consultationFee -eq 75.00)
    
    Write-TestResult -TestName "Retrieve Vet Profile" -Passed $passed `
        -Message "Profile retrieved: $($profile.fullName), Fee: $($profile.consultationFee) $($profile.currency)"
} else {
    Write-TestResult -TestName "Retrieve Vet Profile" -Passed $false `
        -Message $getResult.Error
}

# Test 6: Update vet profile
Write-TestHeader "Test 6: Update Vet Profile"
$updatedVetData = @{
    fullName = "Dr. Sarah Johnson"
    degree = "DVM, PhD, DACVIM"
    licenseNumber = "VET-2024-001234"
    specialization = @("Internal Medicine", "Surgery", "Emergency Care", "Cardiology")
    experience = 9
    clinicName = "PawPal Veterinary Clinic"
    clinicAddress = "123 Pet Street"
    city = "San Francisco"
    state = "CA"
    zipCode = "94102"
    phone = "+1-555-VET-CARE"
    consultationFee = 85.00
    currency = "USD"
    bio = "Board-certified veterinarian specializing in internal medicine, surgery, and cardiology. Over 9 years of experience providing exceptional care."
    profilePhotoUrl = "https://example.com/dr-sarah-johnson-updated.jpg"
    availabilityHours = "Mon-Fri: 8:00 AM - 7:00 PM, Sat: 9:00 AM - 5:00 PM"
    isAvailable = $true
}

$updateResult = Invoke-CreateVetProfile -Token $testToken -VetData $updatedVetData

if ($updateResult.Success) {
    Write-TestResult -TestName "Update Vet Profile" -Passed $true `
        -Message "Profile updated: Fee changed to $($updatedVetData.consultationFee), Specializations: $($updatedVetData.specialization.Count)"
} else {
    Write-TestResult -TestName "Update Vet Profile" -Passed $false `
        -Message "$($updateResult.Error) - $($updateResult.ErrorBody)"
}

# Test 7: Verify profile update
Write-TestHeader "Test 7: Verify Profile Update"
Start-Sleep -Seconds 2
Write-Host "   Retrieving updated profile for user ID: $testUserID" -ForegroundColor DarkGray
$verifyResult = Invoke-GetVetProfile -UserID $testUserID

if ($verifyResult.Success -and $verifyResult.Data.vetProfile) {
    $profile = $verifyResult.Data.vetProfile
    $passed = ($profile.consultationFee -eq 85.00) -and 
              ($profile.specialization.Count -eq 4) -and
              ($profile.experience -eq 9)
    
    Write-TestResult -TestName "Verify Profile Update" -Passed $passed `
        -Message "Updated fee: $($profile.consultationFee), Experience: $($profile.experience) years, Specializations: $($profile.specialization.Count)"
} else {
    Write-TestResult -TestName "Verify Profile Update" -Passed $false `
        -Message $verifyResult.Error
}

# Test 8: List all vets (public endpoint)
Write-TestHeader "Test 8: List All Vets"
Start-Sleep -Seconds 1
$listResult = Invoke-ListVets

if ($listResult.Success -and $listResult.Data.vets) {
    $vetCount = $listResult.Data.vets.Count
    Write-Host "   Searching for user ID: $testUserID in $vetCount vets" -ForegroundColor DarkGray
    $ourVet = $listResult.Data.vets | Where-Object { $_.userId -eq $testUserID }
    $passed = ($vetCount -gt 0) -and ($ourVet -ne $null)
    
    if ($ourVet) {
        Write-TestResult -TestName "List All Vets" -Passed $passed `
            -Message "Total vets: $vetCount, Our vet found: $($ourVet.fullName)"
    } else {
        Write-TestResult -TestName "List All Vets" -Passed $false `
            -Message "Total vets: $vetCount, Our vet NOT found (ID: $testUserID)"
    }
} else {
    Write-TestResult -TestName "List All Vets" -Passed $false `
        -Message $listResult.Error
}

# Test 9: Create profile with minimal data
Write-TestHeader "Test 9: Minimal Vet Profile"
$timestamp2 = Get-Date -Format "yyyyMMddHHmmss"
$testEmail2 = "vet.minimal.$timestamp2@pawpal.com"

# Create second vet user
$signupResult2 = Invoke-SignUp -Email $testEmail2 -Password "VetPass123!" -FullName "Dr. Minimal Vet"
if ($signupResult2.Success) {
    $signinResult2 = Invoke-SignIn -Email $testEmail2 -Password "VetPass123!"
    if ($signinResult2.Success) {
        $roleResult2 = Invoke-SetUserRole -Token $signinResult2.Token -Role "vet"
        
        $minimalVetData = @{
            fullName = "Dr. Minimal Vet"
            degree = "DVM"
            specialization = @()
            experience = 1
            phone = "+1-555-1234"
            consultationFee = 50.00
            currency = "USD"
            isAvailable = $true
        }
        
        $minimalResult = Invoke-CreateVetProfile -Token $signinResult2.Token -VetData $minimalVetData
        
        if ($minimalResult.Success) {
            Write-TestResult -TestName "Minimal Vet Profile" -Passed $true `
                -Message "Minimal profile created with required fields only"
        } else {
            Write-TestResult -TestName "Minimal Vet Profile" -Passed $false `
                -Message "$($minimalResult.Error) - $($minimalResult.ErrorBody)"
        }
    } else {
        Write-TestResult -TestName "Minimal Vet Profile" -Passed $false `
            -Message "Failed to sign in second user"
    }
} else {
    Write-TestResult -TestName "Minimal Vet Profile" -Passed $false `
        -Message "Failed to create second user"
}

# Test 10: Non-vet user cannot create vet profile
Write-TestHeader "Test 10: Non-Vet User Restriction"
$timestamp3 = Get-Date -Format "yyyyMMddHHmmss"
$testEmail3 = "regular.user.$timestamp3@pawpal.com"

$signupResult3 = Invoke-SignUp -Email $testEmail3 -Password "RegularPass123!" -FullName "Regular User"
if ($signupResult3.Success) {
    $signinResult3 = Invoke-SignIn -Email $testEmail3 -Password "RegularPass123!"
    if ($signinResult3.Success) {
        # Try to create vet profile without vet role
        $unauthorizedResult = Invoke-CreateVetProfile -Token $signinResult3.Token -VetData $vetData
        
        $passed = -not $unauthorizedResult.Success -and ($unauthorizedResult.StatusCode -eq 403)
        
        if ($passed) {
            Write-TestResult -TestName "Non-Vet User Restriction" -Passed $true `
                -Message "Correctly rejected non-vet user (403 Forbidden)"
        } else {
            Write-TestResult -TestName "Non-Vet User Restriction" -Passed $false `
                -Message "Should have rejected non-vet user with 403"
        }
    } else {
        Write-TestResult -TestName "Non-Vet User Restriction" -Passed $false `
            -Message "Failed to sign in third user"
    }
} else {
    Write-TestResult -TestName "Non-Vet User Restriction" -Passed $false `
        -Message "Failed to create third user"
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

# Export detailed results to JSON
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$reportPath = "vet-test-results_$timestamp.json"
$TestResults | ConvertTo-Json -Depth 3 | Out-File -FilePath $reportPath -Encoding UTF8

Write-Host "`nDetailed report saved to: $reportPath" -ForegroundColor Cyan

if ($FailedTests -gt 0) {
    Write-Host "`n⚠️  Some tests failed. Please review." -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "`n✅ All tests passed!" -ForegroundColor Green
    exit 0
}
