# ============================================
# PawPal Backend - Authentication Unit Tests
# ============================================
# Tests: SignUp, SignIn, Google SignIn, Token Validation
# ============================================

param(
    [string]$BaseURL = "https://transudatory-fecklessly-karisa.ngrok-free.dev",
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"
$TestResults = @()
$PassedTests = 0
$FailedTests = 0

# Helper Functions
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
        if ($Verbose -and $Message) {
            Write-Host "   → $Message" -ForegroundColor DarkGreen
        }
    } else {
        $script:FailedTests++
        Write-Host "❌ FAIL: $TestName" -ForegroundColor Red
        Write-Host "   → $Message" -ForegroundColor DarkRed
        if ($Verbose -and $Response) {
            Write-Host "   Response: $($Response | ConvertTo-Json -Depth 2)" -ForegroundColor DarkGray
        }
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
        
        if ($Body.Count -gt 0) {
            $params.Body = ($Body | ConvertTo-Json)
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
# Test 1: SignUp - Valid User Registration
# ============================================
Write-TestHeader "Test 1: Valid User SignUp"

$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$testEmail = "testuser_$timestamp@example.com"
$testPassword = "SecurePassword123!"
$testName = "Test User $timestamp"

$signUpBody = @{
    email = $testEmail
    password = $testPassword
    fullName = $testName
}

$result = Invoke-APIRequest -Endpoint "/api/v1/auth/signup" -Body $signUpBody

if ($result.Success -and $result.Data.success -eq $true) {
    $token = $result.Data.accessToken
    $userId = $result.Data.user.uid
    Write-TestResult -TestName "Valid User SignUp" -Passed $true -Message "User created successfully. Token received."
    
    # Save credentials for subsequent tests
    $script:TestUser = @{
        Email = $testEmail
        Password = $testPassword
        Token = $token
        UserId = $userId
    }
} else {
    Write-TestResult -TestName "Valid User SignUp" -Passed $false -Message $result.Error -Response $result.ErrorBody
}

# ============================================
# Test 2: SignUp - Duplicate Email (Should Fail)
# ============================================
Write-TestHeader "Test 2: Duplicate Email SignUp (Should Fail)"

$duplicateBody = @{
    email = $testEmail
    password = "AnotherPassword123!"
    fullName = "Another User"
}

$result = Invoke-APIRequest -Endpoint "/api/v1/auth/signup" -Body $duplicateBody

if (-not $result.Success -and $result.StatusCode -eq 409) {
    Write-TestResult -TestName "Duplicate Email Prevention" -Passed $true -Message "Correctly rejected duplicate email (409 Conflict)"
} else {
    Write-TestResult -TestName "Duplicate Email Prevention" -Passed $false -Message "Should have rejected duplicate email with 409 status"
}

# ============================================
# Test 3: SignUp - Invalid Email Format
# ============================================
Write-TestHeader "Test 3: Invalid Email Format (Should Fail)"

$invalidEmailBody = @{
    email = "not-an-email"
    password = "Password123!"
    fullName = "Test User"
}

$result = Invoke-APIRequest -Endpoint "/api/v1/auth/signup" -Body $invalidEmailBody

if (-not $result.Success -and $result.StatusCode -eq 400) {
    Write-TestResult -TestName "Invalid Email Validation" -Passed $true -Message "Correctly rejected invalid email format (400 Bad Request)"
} else {
    Write-TestResult -TestName "Invalid Email Validation" -Passed $false -Message "Should have rejected invalid email with 400 status"
}

# ============================================
# Test 4: SignUp - Weak Password (Should Fail)
# ============================================
Write-TestHeader "Test 4: Weak Password Validation (Should Fail)"

$weakPasswordBody = @{
    email = "newuser_$(Get-Date -Format 'yyyyMMddHHmmss')@example.com"
    password = "123"
    fullName = "Test User"
}

$result = Invoke-APIRequest -Endpoint "/api/v1/auth/signup" -Body $weakPasswordBody

if (-not $result.Success -and $result.StatusCode -eq 400) {
    Write-TestResult -TestName "Weak Password Validation" -Passed $true -Message "Correctly rejected weak password (400 Bad Request)"
} else {
    Write-TestResult -TestName "Weak Password Validation" -Passed $false -Message "Should have rejected weak password with 400 status"
}

# ============================================
# Test 5: SignIn - Valid Credentials
# ============================================
Write-TestHeader "Test 5: Valid SignIn"

$signInBody = @{
    email = $script:TestUser.Email
    password = $script:TestUser.Password
}

$result = Invoke-APIRequest -Endpoint "/api/v1/auth/signin" -Body $signInBody

if ($result.Success -and $result.Data.success -eq $true) {
    $newToken = $result.Data.accessToken
    Write-TestResult -TestName "Valid SignIn" -Passed $true -Message "User signed in successfully. New token received."
    
    # Update token
    $script:TestUser.Token = $newToken
} else {
    Write-TestResult -TestName "Valid SignIn" -Passed $false -Message $result.Error -Response $result.ErrorBody
}

# ============================================
# Test 6: SignIn - Wrong Password (Should Fail)
# ============================================
Write-TestHeader "Test 6: Wrong Password (Should Fail)"

$wrongPasswordBody = @{
    email = $script:TestUser.Email
    password = "WrongPassword123!"
}

$result = Invoke-APIRequest -Endpoint "/api/v1/auth/signin" -Body $wrongPasswordBody

if (-not $result.Success -and $result.StatusCode -eq 401) {
    Write-TestResult -TestName "Wrong Password Rejection" -Passed $true -Message "Correctly rejected wrong password (401 Unauthorized)"
} else {
    Write-TestResult -TestName "Wrong Password Rejection" -Passed $false -Message "Should have rejected wrong password with 401 status"
}

# ============================================
# Test 7: SignIn - Non-existent User (Should Fail)
# ============================================
Write-TestHeader "Test 7: Non-existent User (Should Fail)"

$nonExistentBody = @{
    email = "nonexistent_$(Get-Date -Format 'yyyyMMddHHmmss')@example.com"
    password = "Password123!"
}

$result = Invoke-APIRequest -Endpoint "/api/v1/auth/signin" -Body $nonExistentBody

if (-not $result.Success -and $result.StatusCode -eq 401) {
    Write-TestResult -TestName "Non-existent User Rejection" -Passed $true -Message "Correctly rejected non-existent user (401 Unauthorized)"
} else {
    Write-TestResult -TestName "Non-existent User Rejection" -Passed $false -Message "Should have rejected non-existent user with 401 status"
}

# ============================================
# Test 8: Token Validation - Get Profile
# ============================================
Write-TestHeader "Test 8: Token Validation (Get Profile)"

$headers = @{
    "Content-Type" = "application/json"
    "ngrok-skip-browser-warning" = "true"
    "Authorization" = "Bearer $($script:TestUser.Token)"
}

$result = Invoke-APIRequest -Endpoint "/api/v1/profile" -Method "GET" -Headers $headers

if ($result.Success -and $result.Data.data.email -eq $script:TestUser.Email) {
    Write-TestResult -TestName "Token Validation" -Passed $true -Message "Token is valid. Profile retrieved successfully."
} else {
    Write-TestResult -TestName "Token Validation" -Passed $false -Message $result.Error -Response $result.ErrorBody
}

# ============================================
# Test 9: Invalid Token (Should Fail)
# ============================================
Write-TestHeader "Test 9: Invalid Token (Should Fail)"

$invalidHeaders = @{
    "Content-Type" = "application/json"
    "ngrok-skip-browser-warning" = "true"
    "Authorization" = "Bearer invalid_token_12345"
}

$result = Invoke-APIRequest -Endpoint "/api/v1/profile" -Method "GET" -Headers $invalidHeaders

if (-not $result.Success -and $result.StatusCode -eq 401) {
    Write-TestResult -TestName "Invalid Token Rejection" -Passed $true -Message "Correctly rejected invalid token (401 Unauthorized)"
} else {
    Write-TestResult -TestName "Invalid Token Rejection" -Passed $false -Message "Should have rejected invalid token with 401 status"
}

# ============================================
# Test 10: Missing Token (Should Fail)
# ============================================
Write-TestHeader "Test 10: Missing Token (Should Fail)"

$noTokenHeaders = @{
    "Content-Type" = "application/json"
    "ngrok-skip-browser-warning" = "true"
}

$result = Invoke-APIRequest -Endpoint "/api/v1/profile" -Method "GET" -Headers $noTokenHeaders

if (-not $result.Success -and $result.StatusCode -eq 401) {
    Write-TestResult -TestName "Missing Token Rejection" -Passed $true -Message "Correctly rejected missing token (401 Unauthorized)"
} else {
    Write-TestResult -TestName "Missing Token Rejection" -Passed $false -Message "Should have rejected missing token with 401 status"
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
$reportPath = "auth-test-results_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
$TestResults | ConvertTo-Json -Depth 3 | Out-File -FilePath $reportPath -Encoding UTF8

Write-Host "`nDetailed report saved to: $reportPath" -ForegroundColor Cyan

# Exit with appropriate code
if ($FailedTests -eq 0) {
    Write-Host "`n🎉 All tests passed!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n⚠️  Some tests failed. Please review." -ForegroundColor Yellow
    exit 1
}
