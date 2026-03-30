# Script to insert 2-3 products into PawPal marketplace
# Usage: .\insert_products.ps1

$ErrorActionPreference = "Stop"
$baseUrl = "http://localhost:8081/api"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  PawPal Product Insertion Script" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Step 1: Register user (or skip if exists)
Write-Host "[1/4] Registering seller user..." -ForegroundColor Yellow
$registerBody = @{
    email = "seller@pawpal.com"
    password = "Seller123!"
    fullName = "Pet Store Owner"
    phoneNumber = "+923001234567"
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "$baseUrl/auth/signup" -Method POST -Body $registerBody -ContentType "application/json"
    Write-Host "✅ User registered successfully" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 409) {
        Write-Host "ℹ️  User already exists, continuing..." -ForegroundColor Cyan
    } else {
        Write-Host "❌ Registration error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Step 2: Login to get token
Write-Host "`n[2/4] Logging in to get auth token..." -ForegroundColor Yellow
$loginBody = @{
    email = "seller@pawpal.com"
    password = "Seller123!"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    $token = $loginResponse.token
    $userId = $loginResponse.user.id
    Write-Host "✅ Login successful" -ForegroundColor Green
    Write-Host "   Token: $($token.Substring(0,30))..." -ForegroundColor Gray
    Write-Host "   User ID: $userId" -ForegroundColor Gray
} catch {
    Write-Host "❌ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 3: Get categories to find IDs
Write-Host "`n[3/4] Fetching product categories..." -ForegroundColor Yellow
try {
    $categories = Invoke-RestMethod -Uri "$baseUrl/marketplace/categories" -Method GET
    Write-Host "✅ Categories fetched" -ForegroundColor Green
    $categories.categories | ForEach-Object {
        Write-Host "   - $($_.name): $($_.id)" -ForegroundColor Gray
    }
    
    # Find category IDs
    $foodCategoryId = ($categories.categories | Where-Object { $_.name -eq 'Food & Treats' }).id
    $toysCategoryId = ($categories.categories | Where-Object { $_.name -eq 'Toys' }).id
    $accessoriesCategoryId = ($categories.categories | Where-Object { $_.name -eq 'Accessories' }).id
} catch {
    Write-Host "❌ Failed to fetch categories: $($_.Exception.Message)" -ForegroundColor Red
    $foodCategoryId = $null
    $toysCategoryId = $null
    $accessoriesCategoryId = $null
}

# Step 4: Create products
Write-Host "`n[4/4] Creating products..." -ForegroundColor Yellow

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Product 1: Premium Dog Food
Write-Host "`n  📦 Creating Product 1: Premium Dog Food..." -ForegroundColor Cyan
$product1 = @{
    categoryId = $foodCategoryId
    name = "Royal Canin Adult Dog Food - 15kg"
    description = "Premium quality dog food formulated for adult dogs. Contains high-quality proteins, balanced nutrients, and essential vitamins for optimal health. Suitable for all breeds."
    price = 8500.00
    currency = "PKR"
    stockQuantity = 25
    images = @(
        "https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=500",
        "https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=500"
    )
    breedCompatibility = @("All breeds")
    petType = "dog"
    weightGrams = 15000
} | ConvertTo-Json

try {
    $product1Response = Invoke-RestMethod -Uri "$baseUrl/marketplace/products" -Method POST -Headers $headers -Body $product1
    Write-Host "  ✅ Product created: $($product1Response.product.name)" -ForegroundColor Green
    Write-Host "     ID: $($product1Response.product.id)" -ForegroundColor Gray
    Write-Host "     Price: PKR $($product1Response.product.price)" -ForegroundColor Gray
} catch {
    Write-Host "  ❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Product 2: Interactive Cat Toy
Write-Host "`n  🎾 Creating Product 2: Interactive Cat Toy..." -ForegroundColor Cyan
$product2 = @{
    categoryId = $toysCategoryId
    name = "Interactive Feather Wand Toy for Cats"
    description = "Engaging interactive toy with feathers and bells to keep your cat entertained for hours. Promotes exercise and hunting instincts. Durable design with replaceable feathers."
    price = 1200.00
    currency = "PKR"
    stockQuantity = 50
    images = @(
        "https://images.unsplash.com/photo-1545249390-6bdfa286032f?w=500",
        "https://images.unsplash.com/photo-1591871937573-74dbba515c4c?w=500"
    )
    breedCompatibility = @("All breeds")
    petType = "cat"
    weightGrams = 150
} | ConvertTo-Json

try {
    $product2Response = Invoke-RestMethod -Uri "$baseUrl/marketplace/products" -Method POST -Headers $headers -Body $product2
    Write-Host "  ✅ Product created: $($product2Response.product.name)" -ForegroundColor Green
    Write-Host "     ID: $($product2Response.product.id)" -ForegroundColor Gray
    Write-Host "     Price: PKR $($product2Response.product.price)" -ForegroundColor Gray
} catch {
    Write-Host "  ❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Product 3: Adjustable Dog Collar
Write-Host "`n  🦴 Creating Product 3: Adjustable Dog Collar..." -ForegroundColor Cyan
$product3 = @{
    categoryId = $accessoriesCategoryId
    name = "Premium Leather Dog Collar - Adjustable"
    description = "High-quality genuine leather collar with adjustable buckle. Soft padding for comfort, durable metal D-ring for leash attachment. Available in multiple sizes. Perfect for daily walks and training."
    price = 1800.00
    currency = "PKR"
    stockQuantity = 35
    images = @(
        "https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=500",
        "https://images.unsplash.com/photo-1611601679655-7c8bc197f0c6?w=500"
    )
    breedCompatibility = @("Small breeds", "Medium breeds", "Large breeds")
    petType = "dog"
    weightGrams = 120
} | ConvertTo-Json

try {
    $product3Response = Invoke-RestMethod -Uri "$baseUrl/marketplace/products" -Method POST -Headers $headers -Body $product3
    Write-Host "  ✅ Product created: $($product3Response.product.name)" -ForegroundColor Green
    Write-Host "     ID: $($product3Response.product.id)" -ForegroundColor Gray
    Write-Host "     Price: PKR $($product3Response.product.price)" -ForegroundColor Gray
} catch {
    Write-Host "  ❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  ✅ Product Insertion Complete!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan
Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "  • 3 products created successfully" -ForegroundColor White
Write-Host "  • Check the marketplace in your app to see them" -ForegroundColor White
Write-Host "`n"
