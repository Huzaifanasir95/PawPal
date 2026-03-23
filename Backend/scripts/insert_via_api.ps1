# Insert Community Hub test data via Supabase REST API
$ErrorActionPreference = "Stop"

$key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVpY3NqZ2pwdnphanZibnZheWdiIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NDIyNDAzMiwiZXhwIjoyMDg5ODAwMDMyfQ.vYZV6xuioHxpuZ737-XAlBQza2ZH_5abwfTcM2wOVDA"
$base = "https://uicsjgjpvzajvbnvaygb.supabase.co/rest/v1"
$headers = @{
    "apikey"        = $key
    "Authorization" = "Bearer $key"
    "Content-Type"  = "application/json"
    "Prefer"        = "return=representation"
}
$userId = "82e92218-d4b7-4967-8e91-1a8e198d18b1"

function Post-Data($table, $jsonBody) {
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($jsonBody)
        $r = Invoke-WebRequest -Uri "$base/$table" -Method POST -Headers $headers -Body $bytes -UseBasicParsing
        $parsed = $r.Content | ConvertFrom-Json
        $count = if ($parsed -is [array]) { $parsed.Count } else { 1 }
        Write-Host "[OK] $table : $count rows inserted" -ForegroundColor Green
        return $parsed
    } catch {
        Write-Host "[FAIL] $table : $($_.Exception.Message)" -ForegroundColor Red
        try {
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            Write-Host "  Detail: $($reader.ReadToEnd())" -ForegroundColor Yellow
        } catch {}
        return $null
    }
}

# Clean up test record
Write-Host "Cleaning up test record..." -ForegroundColor Gray
try {
    $delHeaders = @{ "apikey" = $key; "Authorization" = "Bearer $key" }
    Invoke-WebRequest -Uri "$base/lost_found_posts?pet_name=eq.TestDog" -Method DELETE -Headers $delHeaders -UseBasicParsing | Out-Null
    Write-Host "Cleaned up" -ForegroundColor Gray
} catch {}

Write-Host "`n=== Inserting Lost & Found Posts ===" -ForegroundColor Cyan

$lf1 = @{ user_id=$userId; type="lost"; pet_name="Max"; pet_type="Dog"; breed="Golden Retriever"; color="Golden"; description="Lost my beloved Golden Retriever near Central Park. He is very friendly and responds to Max. He has a blue collar with tags. Please contact if you see him!"; image_urls=@(); last_seen_location="Central Park, New York"; urgency="high"; contact_phone="+1234567890"; contact_email="owner@example.com"; status="active"; user_name="John Doe" }
$lf2 = @{ user_id=$userId; type="found"; pet_name="Unknown"; pet_type="Cat"; breed="Tabby"; color="Orange and White"; description="Found this friendly cat wandering near my house. Looking for the owner. The cat is healthy and well-fed."; image_urls=@(); last_seen_location="Brooklyn Heights"; urgency="medium"; contact_phone="+1234567891"; status="active"; user_name="Sarah Smith" }
$lf3 = @{ user_id=$userId; type="lost"; pet_name="Bella"; pet_type="Dog"; breed="Labrador"; color="Black"; description="My black Labrador went missing yesterday evening. She has a pink collar with tags. Very important to our family!"; image_urls=@(); last_seen_location="Queens Boulevard"; urgency="critical"; contact_phone="+1234567892"; contact_email="bella.owner@example.com"; status="active"; user_name="Mike Johnson" }

$lfJson = @($lf1, $lf2, $lf3) | ConvertTo-Json -Depth 5 -Compress
Post-Data "lost_found_posts" $lfJson

Write-Host "`n=== Inserting Adoption Listings ===" -ForegroundColor Cyan

$a1 = @{ user_id=$userId; pet_name="Charlie"; pet_type="dog"; breed="Beagle"; age="3 years"; gender="male"; size="medium"; color="Brown and White"; description="Charlie is a friendly and energetic Beagle looking for a loving home. He loves to play and is great with kids!"; medical_info="All vaccinations up to date. No known health issues."; is_vaccinated=$true; is_neutered=$true; is_trained=$true; good_with_kids=$true; good_with_pets=$true; image_urls=@(); location="New York, NY"; contact_phone="+1234567890"; contact_email="adopt@example.com"; adoption_fee=150.00; status="available"; user_name="Pet Rescue Center" }
$a2 = @{ user_id=$userId; pet_name="Luna"; pet_type="cat"; breed="Persian"; age="2 years"; gender="female"; size="small"; color="White"; description="Beautiful Persian cat with blue eyes. Very calm and affectionate. Perfect for apartment living."; medical_info="Fully vaccinated and spayed."; is_vaccinated=$true; is_neutered=$true; is_trained=$false; good_with_kids=$true; good_with_pets=$false; image_urls=@(); location="Brooklyn, NY"; contact_phone="+1234567891"; adoption_fee=0.00; status="available"; user_name="Cat Lovers Society" }
$a3 = @{ user_id=$userId; pet_name="Rocky"; pet_type="dog"; breed="German Shepherd"; age="1 year"; gender="male"; size="large"; color="Black and Tan"; description="Young and energetic German Shepherd. Needs an active family with space to run. Very loyal and protective."; is_vaccinated=$true; is_neutered=$false; is_trained=$true; good_with_kids=$true; good_with_pets=$true; image_urls=@(); location="Queens, NY"; contact_phone="+1234567892"; adoption_fee=200.00; status="available"; user_name="Dog Adoption Network" }
$a4 = @{ user_id=$userId; pet_name="Tweety"; pet_type="bird"; breed="Parakeet"; age="6 months"; size="small"; color="Green and Yellow"; description="Cheerful parakeet that loves to sing. Comes with cage and accessories. Very social and enjoys interaction."; is_vaccinated=$false; is_neutered=$false; is_trained=$false; image_urls=@(); location="Manhattan, NY"; contact_phone="+1234567893"; adoption_fee=50.00; status="available"; user_name="Bird Paradise" }

$adoptJson = @($a1, $a2, $a3, $a4) | ConvertTo-Json -Depth 5 -Compress
Post-Data "adoption_listings" $adoptJson

Write-Host "`n=== Inserting Events ===" -ForegroundColor Cyan

$d3  = (Get-Date).AddDays(3).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$d3e = (Get-Date).AddDays(3).AddHours(3).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$d7  = (Get-Date).AddDays(7).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$d7e = (Get-Date).AddDays(7).AddHours(6).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$d14 = (Get-Date).AddDays(14).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$d14e= (Get-Date).AddDays(14).AddHours(2).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$d21 = (Get-Date).AddDays(21).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$d30 = (Get-Date).AddDays(30).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$d30e= (Get-Date).AddDays(30).AddHours(4).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

$e1 = @{ organizer_id=$userId; title="Dog Meetup at Central Park"; description="Join us for a fun afternoon with your furry friends! All dogs welcome. Bring toys and treats!"; event_type="meetup"; location="Central Park - Sheep Meadow, New York, NY"; start_date=$d3; end_date=$d3e; max_attendees=50; is_pet_friendly=$true; pet_types_allowed=@("dog"); status="upcoming"; organizer_name="NYC Dog Lovers"; rsvp_count=23 }
$e2 = @{ organizer_id=$userId; title="Pet Adoption Drive"; description="Come meet adorable pets looking for their forever homes! Multiple rescue organizations will be present."; event_type="adoption_drive"; location="Brooklyn Animal Shelter, 2336 Linden Blvd, Brooklyn, NY"; start_date=$d7; end_date=$d7e; max_attendees=200; is_pet_friendly=$true; pet_types_allowed=@("dog","cat","bird","other"); status="upcoming"; organizer_name="Brooklyn Pet Rescue"; rsvp_count=87 }
$e3 = @{ organizer_id=$userId; title="Puppy Training Workshop"; description="Learn basic obedience training techniques for puppies. Professional trainer will demonstrate best practices."; event_type="training"; location="Manhattan Dog Training Center, 123 West St, NY"; start_date=$d14; end_date=$d14e; max_attendees=15; is_pet_friendly=$true; pet_types_allowed=@("dog"); status="upcoming"; organizer_name="Paws & Train"; rsvp_count=12 }
$e4 = @{ organizer_id=$userId; title="Cat Agility Competition"; description="Watch talented cats show off their agility skills! Spectators are welcome."; event_type="competition"; location="Queens Community Center, 456 Northern Blvd, Queens, NY"; start_date=$d21; max_attendees=100; is_pet_friendly=$false; pet_types_allowed=@("cat"); status="upcoming"; organizer_name="Feline Sports Association"; rsvp_count=45 }
$e5 = @{ organizer_id=$userId; title="Charity Walk for Animal Shelters"; description="Join our 5K walk to raise funds for local animal shelters. All proceeds go to helping homeless pets."; event_type="charity"; location="Prospect Park, Brooklyn, NY"; start_date=$d30; end_date=$d30e; max_attendees=500; is_pet_friendly=$true; pet_types_allowed=@("dog","cat"); status="upcoming"; organizer_name="Paws for a Cause"; rsvp_count=234 }

$eventsJson = @($e1, $e2, $e3, $e4, $e5) | ConvertTo-Json -Depth 5 -Compress
Post-Data "events" $eventsJson

# === Verify ===
Write-Host "`n=== Verifying Data ===" -ForegroundColor Cyan
$vHeaders = @{ "apikey" = $key; "Authorization" = "Bearer $key" }
$lf = Invoke-RestMethod -Uri "$base/lost_found_posts?select=id,type,pet_name,urgency&user_id=eq.$userId" -Headers $vHeaders
$ad = Invoke-RestMethod -Uri "$base/adoption_listings?select=id,pet_name,pet_type,status&user_id=eq.$userId" -Headers $vHeaders
$ev = Invoke-RestMethod -Uri "$base/events?select=id,title,event_type&organizer_id=eq.$userId" -Headers $vHeaders

Write-Host "`n--- Lost & Found Posts ---"
$lf | Format-Table -AutoSize
Write-Host "--- Adoption Listings ---"
$ad | Format-Table -AutoSize
Write-Host "--- Events ---"
$ev | Format-Table -AutoSize

$lfC = if ($lf -is [array]) { $lf.Count } else { if ($lf) { 1 } else { 0 } }
$adC = if ($ad -is [array]) { $ad.Count } else { if ($ad) { 1 } else { 0 } }
$evC = if ($ev -is [array]) { $ev.Count } else { if ($ev) { 1 } else { 0 } }
Write-Host "`nTotal: $lfC lost/found, $adC adoptions, $evC events" -ForegroundColor Green
Write-Host "Done!" -ForegroundColor Green
