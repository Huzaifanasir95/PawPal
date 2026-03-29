# Simple script to insert products into PawPal marketplace
$baseUrl = "http://localhost:8081/api/v1"

Write-Host "`n=== PawPal Product Insertion ===" -ForegroundColor Cyan

# Step 1: Register user
Write-Host "`nStep 1: Registering user..." -ForegroundColor Yellow
$registerBody = '{"email":"seller@pawpal.com","password":"Seller123!","fullName":"Pet Store Owner","phoneNumber":"+923001234567"}'

try {
    Invoke-RestMethod -Uri "$baseUrl/auth/signup" -Method POST -Body $registerBody -ContentType "application/json" | Out-Null
    Write-Host "User registered" -ForegroundColor Green
} catch {
    Write-Host "User may already exist (continuing...)" -ForegroundColor Cyan
}

# Step 2: Login
Write-Host "`nStep 2: Logging in..." -ForegroundColor Yellow
$loginBody = '{"email":"seller@pawpal.com","password":"Seller123!"}'
$loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/signin" -Method POST -Body $loginBody -ContentType "application/json"
$token = $loginResponse.accessToken
Write-Host "Login successful" -ForegroundColor Green
Write-Host "Token: $($token.Substring(0, [Math]::Min(30, $token.Length)))..." -ForegroundColor Gray

# Step 3: Get categories
Write-Host "`nStep 3: Fetching categories..." -ForegroundColor Yellow
$categories = Invoke-RestMethod -Uri "$baseUrl/marketplace/categories" -Method GET
$foodCat = ($categories.categories | Where-Object { $_.name -like '*Food*' }).id
$toysCat = ($categories.categories | Where-Object { $_.name -like '*Toys*' }).id
$accCat = ($categories.categories | Where-Object { $_.name -like '*Accessories*' }).id
Write-Host "Categories fetched" -ForegroundColor Green

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Product 1: Dog Food
Write-Host "`nCreating Product 1: Premium Dog Food..." -ForegroundColor Cyan
$product1 = @{
    categoryId = $foodCat
    name = "Royal Canin Adult Dog Food - 15kg"
    description = "Premium quality dog food formulated for adult dogs. Contains high-quality proteins, balanced nutrients, and essential vitamins for optimal health. Suitable for all breeds."
    price = 8500.00
    currency = "PKR"
    stockQuantity = 25
    images = @("https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=500")
    breedCompatibility = @("All breeds")
    petType = "dog"
    weightGrams = 15000
} | ConvertTo-Json -Depth 10

$p1 = Invoke-RestMethod -Uri "$baseUrl/marketplace/products" -Method POST -Headers $headers -Body $product1
Write-Host "✅ Created: $($p1.product.name) - PKR $($p1.product.price)" -ForegroundColor Green

# Product 2: Cat Toy
Write-Host "`nCreating Product 2: Interactive Cat Toy..." -ForegroundColor Cyan
$product2 = @{
    categoryId = $toysCat
    name = "Interactive Feather Wand Toy for Cats"
    description = "Engaging interactive toy with feathers and bells to keep your cat entertained for hours. Promotes exercise and hunting instincts."
    price = 1200.00
    currency = "PKR"
    stockQuantity = 50
    images = @("https://images.unsplash.com/photo-1545249390-6bdfa286032f?w=500")
    breedCompatibility = @("All breeds")
    petType = "cat"
    weightGrams = 150
} | ConvertTo-Json -Depth 10

$p2 = Invoke-RestMethod -Uri "$baseUrl/marketplace/products" -Method POST -Headers $headers -Body $product2
Write-Host "✅ Created: $($p2.product.name) - PKR $($p2.product.price)" -ForegroundColor Green

# Product 3: Dog Collar
Write-Host "`nCreating Product 3: Dog Collar..." -ForegroundColor Cyan
$product3 = @{
    categoryId = $accCat
    name = "Premium Leather Dog Collar - Adjustable"
    description = "High-quality genuine leather collar with adjustable buckle. Soft padding for comfort, durable metal D-ring for leash attachment."
    price = 1800.00
    currency = "PKR"
    stockQuantity = 35
    images = @("https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=500")
    breedCompatibility = @("Small breeds", "Medium breeds", "Large breeds")
    petType = "dog"
    weightGrams = 120
} | ConvertTo-Json -Depth 10

$p3 = Invoke-RestMethod -Uri "$baseUrl/marketplace/products" -Method POST -Headers $headers -Body $product3
Write-Host "✅ Created: $($p3.product.name) - PKR $($p3.product.price)" -ForegroundColor Green

Write-Host "`n=== SUCCESS: 3 products inserted! ===" -ForegroundColor Green
Write-Host "`nProduct IDs:" -ForegroundColor Yellow
Write-Host "1. $($p1.product.id)" -ForegroundColor Gray
Write-Host "2. $($p2.product.id)" -ForegroundColor Gray
Write-Host "3. $($p3.product.id)" -ForegroundColor Gray
