# Simple script to insert adoption listings into PawPal
$baseUrl = "http://localhost:8081/api/v1"

Write-Host "`n=== PawPal Adoption Listings Insertion ===" -ForegroundColor Cyan

# Step 1: Register user
Write-Host "`nStep 1: Registering shelter user..." -ForegroundColor Yellow
$registerBody = '{"email":"shelter@pawpal.com","password":"Shelter123!","fullName":"Happy Paws Shelter","phoneNumber":"+923001234567"}'

try {
    Invoke-RestMethod -Uri "$baseUrl/auth/signup" -Method POST -Body $registerBody -ContentType "application/json" | Out-Null
    Write-Host "User registered" -ForegroundColor Green
} catch {
    Write-Host "User may already exist (continuing...)" -ForegroundColor Cyan
}

# Step 2: Login
Write-Host "`nStep 2: Logging in..." -ForegroundColor Yellow
$loginBody = '{"email":"shelter@pawpal.com","password":"Shelter123!"}'
$loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/signin" -Method POST -Body $loginBody -ContentType "application/json"
$token = $loginResponse.accessToken
Write-Host "Login successful" -ForegroundColor Green
Write-Host "Token: $($token.Substring(0, [Math]::Min(30, $token.Length)))..." -ForegroundColor Gray

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Adoption 1: Buddy - Friendly Labrador
Write-Host "`nCreating Adoption 1: Buddy - Labrador Retriever..." -ForegroundColor Cyan
$adoption1 = @{
    petName = "Buddy"
    petType = "Dog"
    breed = "Labrador Retriever"
    age = "2 years"
    gender = "male"
    size = "large"
    color = "Golden Yellow"
    description = "Meet Buddy, a lovable 2-year-old Labrador who's full of energy and affection! He loves playing fetch, going for walks, and cuddling on the couch. Buddy is great with children and other pets, making him the perfect family companion. He's fully vaccinated, neutered, and house-trained. Looking for his forever home!"
    medicalInfo = "Fully vaccinated, dewormed, healthy"
    isVaccinated = $true
    isNeutered = $true
    isTrained = $true
    goodWithKids = $true
    goodWithPets = $true
    imageUrls = @(
        "https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=500",
        "https://images.unsplash.com/photo-1558788353-f76d92427f16?w=500"
    )
    location = "Happy Paws Shelter, Gulshan-e-Iqbal, Karachi"
    contactPhone = "+923001234567"
    contactEmail = "shelter@pawpal.com"
    adoptionFee = 5000.00
} | ConvertTo-Json -Depth 10

$a1 = Invoke-RestMethod -Uri "$baseUrl/adoptions" -Method POST -Headers $headers -Body $adoption1
Write-Host "✅ Created: $($a1.listing.petName) ($($a1.listing.petType)) - PKR $($a1.listing.adoptionFee)" -ForegroundColor Green

# Adoption 2: Whiskers - Playful Kitten
Write-Host "`nCreating Adoption 2: Whiskers - Persian Kitten..." -ForegroundColor Cyan
$adoption2 = @{
    petName = "Whiskers"
    petType = "Cat"
    breed = "Persian Mix"
    age = "6 months"
    gender = "female"
    size = "small"
    color = "White & Grey"
    description = "Whiskers is an adorable 6-month-old kitten with the softest fur and the sweetest personality! She's playful, curious, and loves to chase toys. Whiskers is litter-trained and gets along well with other cats. She's been vaccinated and is ready to bring joy to her new family. Perfect for apartment living!"
    medicalInfo = "Vaccinated, dewormed, spayed, healthy"
    isVaccinated = $true
    isNeutered = $true
    isTrained = $true
    goodWithKids = $true
    goodWithPets = $true
    imageUrls = @(
        "https://images.unsplash.com/photo-1495360010541-f48722b34f7d?w=500",
        "https://images.unsplash.com/photo-1574158622682-e40e69881006?w=500"
    )
    location = "Happy Paws Shelter, Gulshan-e-Iqbal, Karachi"
    contactPhone = "+923001234567"
    contactEmail = "shelter@pawpal.com"
    adoptionFee = 3000.00
} | ConvertTo-Json -Depth 10

$a2 = Invoke-RestMethod -Uri "$baseUrl/adoptions" -Method POST -Headers $headers -Body $adoption2
Write-Host "✅ Created: $($a2.listing.petName) ($($a2.listing.petType)) - PKR $($a2.listing.adoptionFee)" -ForegroundColor Green

# Adoption 3: Charlie - Energetic Husky
Write-Host "`nCreating Adoption 3: Charlie - Siberian Husky..." -ForegroundColor Cyan
$adoption3 = @{
    petName = "Charlie"
    petType = "Dog"
    breed = "Siberian Husky"
    age = "3 years"
    gender = "male"
    size = "large"
    color = "Grey & White"
    description = "Charlie is a stunning 3-year-old Siberian Husky with beautiful blue eyes and a gentle soul. Despite his large size, he's incredibly gentle and loves attention. Charlie enjoys long walks and outdoor activities. He's well-trained, friendly, and would thrive in an active household. Fully vaccinated and neutered."
    medicalInfo = "Fully vaccinated, neutered, recent check-up clear"
    isVaccinated = $true
    isNeutered = $true
    isTrained = $true
    goodWithKids = $true
    goodWithPets = $true
    imageUrls = @(
        "https://images.unsplash.com/photo-1605568427561-40dd23c2acea?w=500",
        "https://images.unsplash.com/photo-1568572933382-74d440642117?w=500"
    )
    location = "Happy Paws Shelter, Gulshan-e-Iqbal, Karachi"
    contactPhone = "+923001234567"
    contactEmail = "shelter@pawpal.com"
    adoptionFee = 8000.00
} | ConvertTo-Json -Depth 10

$a3 = Invoke-RestMethod -Uri "$baseUrl/adoptions" -Method POST -Headers $headers -Body $adoption3
Write-Host "✅ Created: $($a3.listing.petName) ($($a3.listing.petType)) - PKR $($a3.listing.adoptionFee)" -ForegroundColor Green

Write-Host "`n=== SUCCESS: 3 adoption listings inserted! ===" -ForegroundColor Green
Write-Host "`nAdoption Details:" -ForegroundColor Yellow
Write-Host "1. Buddy (Labrador Retriever) - 2 years - PKR 5,000" -ForegroundColor Gray
Write-Host "   ID: $($a1.listing.id)" -ForegroundColor DarkGray
Write-Host "2. Whiskers (Persian Mix Kitten) - 6 months - PKR 3,000" -ForegroundColor Gray
Write-Host "   ID: $($a2.listing.id)" -ForegroundColor DarkGray
Write-Host "3. Charlie (Siberian Husky) - 3 years - PKR 8,000" -ForegroundColor Gray
Write-Host "   ID: $($a3.listing.id)" -ForegroundColor DarkGray

Write-Host "`nAll pets are vaccinated, neutered/spayed, and ready for adoption!" -ForegroundColor Cyan
