# Simple script to insert lost & found posts into PawPal
$baseUrl = "http://localhost:8081/api/v1"

Write-Host "`n=== PawPal Lost & Found Insertion ===" -ForegroundColor Cyan

# Step 1: Register user
Write-Host "`nStep 1: Registering user..." -ForegroundColor Yellow
$registerBody = '{"email":"petowner@pawpal.com","password":"Owner123!","fullName":"Pet Owner","phoneNumber":"+923001234567"}'

try {
    Invoke-RestMethod -Uri "$baseUrl/auth/signup" -Method POST -Body $registerBody -ContentType "application/json" | Out-Null
    Write-Host "User registered" -ForegroundColor Green
} catch {
    Write-Host "User may already exist (continuing...)" -ForegroundColor Cyan
}

# Step 2: Login
Write-Host "`nStep 2: Logging in..." -ForegroundColor Yellow
$loginBody = '{"email":"petowner@pawpal.com","password":"Owner123!"}'
$loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/signin" -Method POST -Body $loginBody -ContentType "application/json"
$token = $loginResponse.accessToken
Write-Host "Login successful" -ForegroundColor Green
Write-Host "Token: $($token.Substring(0, [Math]::Min(30, $token.Length)))..." -ForegroundColor Gray

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Post 1: Lost Dog - Golden Retriever
Write-Host "`nCreating Post 1: Lost Golden Retriever..." -ForegroundColor Cyan
$post1 = @{
    type = "lost"
    petName = "Max"
    petType = "Dog"
    breed = "Golden Retriever"
    color = "Golden"
    description = "Lost our beloved Golden Retriever 'Max' near DHA Phase 5 park. He's very friendly and responds to his name. He was wearing a blue collar with a bone-shaped tag. Please contact if you've seen him!"
    imageUrls = @(
        "https://images.unsplash.com/photo-1633722715463-d30f4f325e24?w=500",
        "https://images.unsplash.com/photo-1552053831-71594a27632d?w=500"
    )
    urgency = "high"
    lastSeenLocation = "DHA Phase 5, Sunset Boulevard Park, Karachi"
    contactPhone = "+923001234567"
    contactEmail = "petowner@pawpal.com"
} | ConvertTo-Json -Depth 10

$p1 = Invoke-RestMethod -Uri "$baseUrl/lost-found" -Method POST -Headers $headers -Body $post1
Write-Host "✅ Created: LOST - $($p1.post.petName) ($($p1.post.petType))" -ForegroundColor Green

# Post 2: Found Cat - Persian
Write-Host "`nCreating Post 2: Found Persian Cat..." -ForegroundColor Cyan
$post2 = @{
    type = "found"
    petName = "Unknown"
    petType = "Cat"
    breed = "Persian"
    color = "White"
    description = "Found a white Persian cat wandering near Clifton Beach. She seems well-groomed and friendly, likely someone's pet. No collar or ID tag visible. Currently being cared for. Owner please contact urgently!"
    imageUrls = @(
        "https://images.unsplash.com/photo-1513360371669-4adf3dd7dff8?w=500"
    )
    urgency = "medium"
    lastSeenLocation = "Clifton Beach, near Do Darya, Karachi"
    contactPhone = "+923009876543"
    contactEmail = "petowner@pawpal.com"
} | ConvertTo-Json -Depth 10

$p2 = Invoke-RestMethod -Uri "$baseUrl/lost-found" -Method POST -Headers $headers -Body $post2
Write-Host "✅ Created: FOUND - $($p2.post.petName) ($($p2.post.petType))" -ForegroundColor Green

# Post 3: Lost Cat - Siamese (Critical)
Write-Host "`nCreating Post 3: Lost Siamese Cat (Critical)..." -ForegroundColor Cyan
$post3 = @{
    type = "lost"
    petName = "Luna"
    petType = "Cat"
    breed = "Siamese"
    color = "Cream with dark points"
    description = "URGENT: Lost our 2-year-old Siamese cat 'Luna'. She needs daily medication and we're very worried. Last seen near Zamzama Commercial Area. She has distinctive blue eyes and a unique meow. Reward offered for safe return!"
    imageUrls = @(
        "https://images.unsplash.com/photo-1513245543132-31f507417b26?w=500",
        "https://images.unsplash.com/photo-1518791841217-8f162f1e1131?w=500"
    )
    urgency = "critical"
    lastSeenLocation = "Zamzama Commercial Area, Phase 5 DHA, Karachi"
    contactPhone = "+923007654321"
    contactEmail = "petowner@pawpal.com"
} | ConvertTo-Json -Depth 10

$p3 = Invoke-RestMethod -Uri "$baseUrl/lost-found" -Method POST -Headers $headers -Body $post3
Write-Host "✅ Created: LOST - $($p3.post.petName) ($($p3.post.petType)) [CRITICAL]" -ForegroundColor Red

Write-Host "`n=== SUCCESS: 3 lost & found posts inserted! ===" -ForegroundColor Green
Write-Host "`nPost Details:" -ForegroundColor Yellow
Write-Host "1. LOST - Max (Golden Retriever) - High Urgency" -ForegroundColor Gray
Write-Host "   ID: $($p1.post.id)" -ForegroundColor DarkGray
Write-Host "2. FOUND - Unknown (Persian Cat) - Medium Urgency" -ForegroundColor Gray
Write-Host "   ID: $($p2.post.id)" -ForegroundColor DarkGray
Write-Host "3. LOST - Luna (Siamese Cat) - Critical Urgency" -ForegroundColor Gray
Write-Host "   ID: $($p3.post.id)" -ForegroundColor DarkGray

Write-Host "`nYou can now view these posts in the PawPal app!" -ForegroundColor Cyan
