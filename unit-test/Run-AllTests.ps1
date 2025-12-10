# ============================================
# PawPal Backend - Unit Test Runner
# ============================================
# Master script to run all unit tests
# ============================================

param(
    [string]$BaseURL = "https://transudatory-fecklessly-karisa.ngrok-free.dev",
    [switch]$Verbose,
    [string]$TestSuite = "All"  # Options: All, Auth, Breeds, Pets, Vets, Chat
)

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    PawPal Backend Unit Tests" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Base URL: $BaseURL" -ForegroundColor Yellow
Write-Host "Test Suite: $TestSuite" -ForegroundColor Yellow
Write-Host "Verbose Mode: $Verbose`n" -ForegroundColor Yellow

$allTestResults = @{
    TotalTests = 0
    PassedTests = 0
    FailedTests = 0
    TestSuites = @()
}

function Run-TestSuite {
    param(
        [string]$ScriptPath,
        [string]$SuiteName
    )
    
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  Running: $SuiteName" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    
    $startTime = Get-Date
    
    try {
        if ($Verbose) {
            & $ScriptPath -BaseURL $BaseURL -Verbose
        } else {
            & $ScriptPath -BaseURL $BaseURL
        }
        
        $exitCode = $LASTEXITCODE
        $endTime = Get-Date
        $duration = ($endTime - $startTime).TotalSeconds
        
        $suiteResult = @{
            Name = $SuiteName
            ExitCode = $exitCode
            Duration = [math]::Round($duration, 2)
            Passed = ($exitCode -eq 0)
        }
        
        $script:allTestResults.TestSuites += $suiteResult
        
        if ($exitCode -eq 0) {
            Write-Host "`n✅ $SuiteName completed successfully ($duration seconds)" -ForegroundColor Green
        } else {
            Write-Host "`n❌ $SuiteName failed ($duration seconds)" -ForegroundColor Red
        }
        
        return $exitCode -eq 0
        
    } catch {
        Write-Host "`n❌ Error running $SuiteName : $_" -ForegroundColor Red
        return $false
    }
}

# ============================================
# Run Test Suites
# ============================================

$testSuitesPath = "unit-test"
$suitesPassed = 0
$suitesRun = 0

# Authentication Tests
if ($TestSuite -eq "All" -or $TestSuite -eq "Auth") {
    $suitesRun++
    if (Run-TestSuite -ScriptPath "$testSuitesPath\Test-Authentication.ps1" -SuiteName "Authentication Tests") {
        $suitesPassed++
    }
}

# Breed Identification Tests
if ($TestSuite -eq "All" -or $TestSuite -eq "Breeds") {
    $suitesRun++
    if (Run-TestSuite -ScriptPath "$testSuitesPath\Test-BreedIdentification.ps1" -SuiteName "Breed Identification Tests") {
        $suitesPassed++
    }
}

# TODO: Add more test suites
# if ($TestSuite -eq "All" -or $TestSuite -eq "Pets") {
#     $suitesRun++
#     if (Run-TestSuite -ScriptPath "$testSuitesPath\Test-Pets.ps1" -SuiteName "Pet Management Tests") {
#         $suitesPassed++
#     }
# }

# Final Summary
# ============================================

Write-Host "`n`n" -NoNewline
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "       OVERALL TEST SUMMARY" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

Write-Host "`nTest Suites Run:    $suitesRun" -ForegroundColor White
Write-Host "Suites Passed:      $suitesPassed" -ForegroundColor Green
Write-Host "Suites Failed:      $($suitesRun - $suitesPassed)" -ForegroundColor Red

$passRate = if ($suitesRun -gt 0) { [math]::Round(($suitesPassed / $suitesRun) * 100, 2) } else { 0 }
Write-Host "Pass Rate:          $passRate%" -ForegroundColor $(if ($passRate -ge 80) { "Green" } elseif ($passRate -ge 50) { "Yellow" } else { "Red" })

# Individual suite results
Write-Host "`nIndividual Suite Results:" -ForegroundColor Cyan
foreach ($suite in $allTestResults.TestSuites) {
    $status = if ($suite.Passed) { "✅ PASS" } else { "❌ FAIL" }
    $color = if ($suite.Passed) { "Green" } else { "Red" }
    Write-Host "  $status - $($suite.Name) ($($suite.Duration)s)" -ForegroundColor $color
}

# Export summary
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$summaryPath = "unit-test\test-summary_$timestamp.json"
$allTestResults | ConvertTo-Json -Depth 3 | Out-File -FilePath $summaryPath -Encoding UTF8
Write-Host "`nSummary saved to: $summaryPath" -ForegroundColor Cyan

# Final message
Write-Host "`n"
if ($suitesRun -eq $suitesPassed) {
    Write-Host "🎉 All test suites passed! Your backend is working correctly!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "⚠️  Some test suites failed. Please review the results above." -ForegroundColor Yellow
    exit 1
}
