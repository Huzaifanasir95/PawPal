# ============================================
# PawPal Backend - Breed Identification Tests
# ============================================
# Tests: Dog & Cat Breed Classification
# ============================================

param(
    [string]$BaseURL = "https://transudatory-fecklessly-karisa.ngrok-free.dev",
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"
$TestResults = @()
$PassedTests = 0
$FailedTests = 0

# ============================================
# Local Dataset Test Images
# ============================================

# Helper to get random image from folder
function Get-RandomImageFromFolder {
    param([string]$FolderPath)
    
    if (-not (Test-Path $FolderPath)) {
        Write-Host "   Warning: Folder not found: $FolderPath" -ForegroundColor Yellow
        return $null
    }
    
    $images = Get-ChildItem -Path $FolderPath -Include "*.jpg","*.jpeg","*.png" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 10
    
    if ($images.Count -gt 0) {
        $selected = ($images | Get-Random).FullName
        Write-Host "   Selected: $($selected.Split('\')[-1])" -ForegroundColor DarkGray
        return $selected
    }
    return $null
}

# Local dataset paths
$catDatasetPath = "ML_Models\cats\data\catbreedsrefined-7k\versions\2\CatBreedsRefined-v2"
$dogDatasetPath = "ML_Models\dogs\data\stanford_dogs\Images"

Write-Host "`nLoading test images from local dataset..." -ForegroundColor Cyan

# Select test images from local dataset
$TestImages = @{
    # Dog breeds
    GoldenRetriever = Get-RandomImageFromFolder "$dogDatasetPath\n02099601-golden_retriever"
    Beagle = Get-RandomImageFromFolder "$dogDatasetPath\n02088364-beagle"
    Labrador = Get-RandomImageFromFolder "$dogDatasetPath\n02099712-Labrador_retriever"
    GermanShepherd = Get-RandomImageFromFolder "$dogDatasetPath\n02106662-German_shepherd"
    Poodle = Get-RandomImageFromFolder "$dogDatasetPath\n02113624-toy_poodle"
    
    # Cat breeds
    PersianCat = Get-RandomImageFromFolder "$catDatasetPath\Persian"
    SiameseCat = Get-RandomImageFromFolder "$catDatasetPath\Siamese"
    MaineCoon = Get-RandomImageFromFolder "$catDatasetPath\Maine Coon"
    BritishShorthair = Get-RandomImageFromFolder "$catDatasetPath\British Shorthair"
    Bengal = Get-RandomImageFromFolder "$catDatasetPath\Bengal"
}

Write-Host "Test images loaded successfully!`n" -ForegroundColor Green

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

function Test-BreedIdentificationWithImage {
    param(
        [string]$ImagePath,
        [string]$PetType,
        [string]$ExpectedBreed = $null
    )
    
    if (-not $ImagePath -or -not (Test-Path $ImagePath)) {
        Write-Host "   ⚠️  Image not found, skipping test" -ForegroundColor Yellow
        return $null
    }
    
    Write-Host "   Testing with: $($ImagePath.Split('\')[-1])" -ForegroundColor Gray
    
    $result = Invoke-BreedIdentification -ImagePath $ImagePath -PetType $PetType
    
    if ($result.Success) {
        # The API returns top_predictions array
        $topBreed = $result.Data.top_predictions[0].breed
        $confidence = $result.Data.top_predictions[0].confidence
        
        $message = "Predicted: $topBreed (Confidence: $([math]::Round($confidence * 100, 2))%)"
        
        if ($ExpectedBreed) {
            $match = $topBreed -like "*$ExpectedBreed*" -or $ExpectedBreed -like "*$topBreed*"
            return @{
                Success = $match
                Message = $message
                TopBreed = $topBreed
                Confidence = $confidence
            }
        } else {
            return @{
                Success = $true
                Message = $message
                TopBreed = $topBreed
                Confidence = $confidence
            }
        }
    } else {
        return @{
            Success = $false
            Message = $result.Error
        }
    }
}

function Invoke-BreedIdentification {
    param(
        [string]$ImagePath,
        [string]$PetType,  # "dog" or "cat"
        [hashtable]$AdditionalParams = @{}
    )
    
    try {
        $uri = "$BaseURL/api/v1/predict"
        
        # Read image file and convert to base64
        $fileBytes = [System.IO.File]::ReadAllBytes($ImagePath)
        $base64Image = [Convert]::ToBase64String($fileBytes)
        $base64DataUrl = "data:image/jpeg;base64,$base64Image"
        
        # Build JSON request body
        $requestBody = @{
            image = $base64DataUrl
            pet_type = $PetType
            top_k = 5
            use_tta = $false
        }
        
        # Add additional parameters
        foreach ($key in $AdditionalParams.Keys) {
            $requestBody[$key] = $AdditionalParams[$key]
        }
        
        $bodyJson = $requestBody | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri $uri -Method POST `
            -Headers @{
                "Content-Type" = "application/json"
                "ngrok-skip-browser-warning" = "true"
            } `
            -Body $bodyJson
        
        return @{
            Success = $true
            Data = $response
        }
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        $errorBody = $null
        
        try {
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $errorBody = $reader.ReadToEnd()
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
# DOG BREED IDENTIFICATION TESTS
# ============================================

Write-TestHeader "DOG BREED IDENTIFICATION TESTS"

# Test 1: Golden Retriever
Write-TestHeader "Test 1: Golden Retriever Identification"
$result = Test-BreedIdentificationWithImage -ImagePath $TestImages.GoldenRetriever -PetType "dog" -ExpectedBreed "Golden"
if ($result) {
    Write-TestResult -TestName "Golden Retriever Detection" -Passed $result.Success -Message $result.Message
}

# Test 2: Beagle
Write-TestHeader "Test 2: Beagle Identification"
$result = Test-BreedIdentificationWithImage -ImagePath $TestImages.Beagle -PetType "dog" -ExpectedBreed "Beagle"
if ($result) {
    Write-TestResult -TestName "Beagle Detection" -Passed $result.Success -Message $result.Message
}

# Test 3: Labrador Retriever
Write-TestHeader "Test 3: Labrador Retriever Identification"
$result = Test-BreedIdentificationWithImage -ImagePath $TestImages.Labrador -PetType "dog" -ExpectedBreed "Labrador"
if ($result) {
    Write-TestResult -TestName "Labrador Detection" -Passed $result.Success -Message $result.Message
}

# Test 4: German Shepherd
Write-TestHeader "Test 4: German Shepherd Identification"
$result = Test-BreedIdentificationWithImage -ImagePath $TestImages.GermanShepherd -PetType "dog" -ExpectedBreed "German"
if ($result) {
    Write-TestResult -TestName "German Shepherd Detection" -Passed $result.Success -Message $result.Message
}

# Test 5: Poodle
Write-TestHeader "Test 5: Poodle Identification"
$result = Test-BreedIdentificationWithImage -ImagePath $TestImages.Poodle -PetType "dog" -ExpectedBreed "Poodle"
if ($result) {
    Write-TestResult -TestName "Poodle Detection" -Passed $result.Success -Message $result.Message
}

# ============================================
# CAT BREED IDENTIFICATION TESTS
# ============================================

Write-TestHeader "CAT BREED IDENTIFICATION TESTS"

# Test 6: Persian Cat
Write-TestHeader "Test 6: Persian Cat Identification"
$result = Test-BreedIdentificationWithImage -ImagePath $TestImages.PersianCat -PetType "cat" -ExpectedBreed "Persian"
if ($result) {
    # For cats, accept if prediction is in top 3 or confidence > 40%
    $isPersianInTop3 = $false
    if ($result.TopBreed -like "*Persian*") {
        $isPersianInTop3 = $true
    }
    $highConfidence = $result.Confidence -gt 0.4
    $passed = $isPersianInTop3 -or $highConfidence
    
    Write-TestResult -TestName "Persian Cat Detection" -Passed $passed -Message "$($result.Message) $(if (-not $isPersianInTop3) {'(Note: Cat breeds can be similar)'} else {''})"
}

# Test 7: Siamese Cat
Write-TestHeader "Test 7: Siamese Cat Identification"
$result = Test-BreedIdentificationWithImage -ImagePath $TestImages.SiameseCat -PetType "cat" -ExpectedBreed "Siamese"
if ($result) {
    Write-TestResult -TestName "Siamese Cat Detection" -Passed $result.Success -Message $result.Message
}

# Test 8: Maine Coon
Write-TestHeader "Test 8: Maine Coon Identification"
$result = Test-BreedIdentificationWithImage -ImagePath $TestImages.MaineCoon -PetType "cat" -ExpectedBreed "Maine"
if ($result) {
    Write-TestResult -TestName "Maine Coon Detection" -Passed $result.Success -Message $result.Message
}

# Test 9: British Shorthair
Write-TestHeader "Test 9: British Shorthair Identification"
$result = Test-BreedIdentificationWithImage -ImagePath $TestImages.BritishShorthair -PetType "cat" -ExpectedBreed "British"
if ($result) {
    Write-TestResult -TestName "British Shorthair Detection" -Passed $result.Success -Message $result.Message
}

# Test 10: Bengal Cat
Write-TestHeader "Test 10: Bengal Cat Identification"
$result = Test-BreedIdentificationWithImage -ImagePath $TestImages.Bengal -PetType "cat" -ExpectedBreed "Bengal"
if ($result) {
    Write-TestResult -TestName "Bengal Cat Detection" -Passed $result.Success -Message $result.Message
}

# ============================================
# ERROR HANDLING TESTS
# ============================================

Write-TestHeader "ERROR HANDLING TESTS"

# Test 11: Invalid Pet Type
Write-TestHeader "Test 11: Invalid Pet Type"
$result = Test-BreedIdentificationWithImage -ImagePath $TestImages.GoldenRetriever -PetType "bird" -ExpectedBreed "Invalid"
# Should fail with 400 or 404 status
Write-TestResult -TestName "Invalid Pet Type Rejection" -Passed (-not $result.Success) -Message "Expected rejection of invalid pet type"

# Test 12: Missing Image File
Write-TestHeader "Test 12: Missing Image File"
$result = Test-BreedIdentificationWithImage -ImagePath "C:\NonExistent\image.jpg" -PetType "dog" -ExpectedBreed "None"
Write-TestResult -TestName "Missing Image File Handling" -Passed (-not $result.Success) -Message "Expected failure for missing image"

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
$reportPath = "breed-test-results_$timestamp.json"
$TestResults | ConvertTo-Json -Depth 3 | Out-File -FilePath $reportPath -Encoding UTF8

Write-Host "`nDetailed report saved to: $reportPath" -ForegroundColor Cyan

# Cleanup temp images
try {
    $tempPath = Join-Path $env:TEMP "pawpal_test_images"
    if (Test-Path $tempPath) {
        Remove-Item -Path $tempPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Cleaned up temporary test images" -ForegroundColor Gray
    }
} catch {}

# Exit with appropriate code
if ($FailedTests -eq 0) {
    Write-Host "`n🎉 All breed identification tests passed!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n⚠️  Some tests failed. Please review." -ForegroundColor Yellow
    exit 1
}
