-- Insert test data for Community Hub features
-- Run this after logging into your Supabase database

-- First, get a valid user ID (replace with an actual user ID from your users table)
-- You can find this by running: SELECT id FROM users LIMIT 1;

-- For this example, we'll use a placeholder UUID - replace '82e92218-d4b7-4967-8e91-1a8e198d18b1' with an actual user ID
-- Example: '550e8400-e29b-41d4-a716-446655440000'

-- â•â•â• Lost & Found Posts â•â•â•

INSERT INTO lost_found_posts (
    id,
    user_id,
    type,
    pet_name,
    pet_type,
    breed,
    color,
    description,
    image_urls,
    last_seen_location,
    urgency,
    contact_phone,
    contact_email,
    status,
    user_name,
    created_at,
    updated_at
) VALUES
-- Lost dog post
(
    uuid_generate_v4(),
    '82e92218-d4b7-4967-8e91-1a8e198d18b1', -- Replace with actual user ID
    'lost',
    'Max',
    'Dog',
    'Golden Retriever',
    'Golden',
    'Lost my beloved Golden Retriever near Central Park. He is very friendly and responds to "Max". He has a blue collar with tags. Please contact if you see him!',
    ARRAY[]::TEXT[], -- Empty array
    'Central Park, New York',
    'high',
    '+1234567890',
    'owner@example.com',
    'active',
    'John Doe',
    NOW() - INTERVAL '2 hours',
    NOW() - INTERVAL '2 hours'
),
-- Found cat post
(
    uuid_generate_v4(),
    '82e92218-d4b7-4967-8e91-1a8e198d18b1',
    'found',
    'Unknown',
    'Cat',
    'Tabby',
    'Orange and White',
    'Found this friendly cat wandering near my house. Looking for the owner. The cat is healthy and well-fed.',
    ARRAY[]::TEXT[],
    'Brooklyn Heights',
    'medium',
    '+1234567891',
    NULL,
    'active',
    'Sarah Smith',
    NOW() - INTERVAL '1 day',
    NOW() - INTERVAL '1 day'
),
-- Lost dog - urgent
(
    uuid_generate_v4(),
    '82e92218-d4b7-4967-8e91-1a8e198d18b1',
    'lost',
    'Bella',
    'Dog',
    'Labrador',
    'Black',
    'My black Labrador went missing yesterday evening. She has a pink collar with tags. Very important to our family!',
    ARRAY[]::TEXT[],
    'Queens Boulevard',
    'critical',
    '+1234567892',
    'bella.owner@example.com',
    'active',
    'Mike Johnson',
    NOW() - INTERVAL '12 hours',
    NOW() - INTERVAL '12 hours'
);

-- â•â•â• Adoption Listings â•â•â•

INSERT INTO adoption_listings (
    id,
    user_id,
    pet_name,
    pet_type,
    breed,
    age,
    gender,
    size,
    color,
    description,
    medical_info,
    is_vaccinated,
    is_neutered,
    is_trained,
    good_with_kids,
    good_with_pets,
    image_urls,
    location,
    contact_phone,
    contact_email,
    adoption_fee,
    status,
    user_name,
    created_at,
    updated_at
) VALUES
-- Dog for adoption
(
    uuid_generate_v4(),
    '82e92218-d4b7-4967-8e91-1a8e198d18b1',
    'Charlie',
    'dog',
    'Beagle',
    '3 years',
    'male',
    'medium',
    'Brown and White',
    'Charlie is a friendly and energetic Beagle looking for a loving home. He loves to play and is great with kids! He enjoys long walks and playing fetch.',
    'All vaccinations up to date. No known health issues.',
    true,
    true,
    true,
    true,
    true,
    ARRAY[]::TEXT[],
    'New York, NY',
    '+1234567890',
    'adopt@example.com',
    150.00,
    'available',
    'Pet Rescue Center',
    NOW() - INTERVAL '5 days',
    NOW() - INTERVAL '5 days'
),
-- Cat for adoption - free
(
    uuid_generate_v4(),
    '82e92218-d4b7-4967-8e91-1a8e198d18b1',
    'Luna',
    'cat',
    'Persian',
    '2 years',
    'female',
    'small',
    'White',
    'Beautiful Persian cat with blue eyes. Very calm and affectionate. Perfect for apartment living. She loves to cuddle and enjoys quiet environments.',
    'Fully vaccinated and spayed.',
    true,
    true,
    false,
    true,
    false,
    ARRAY[]::TEXT[],
    'Brooklyn, NY',
    '+1234567891',
    NULL,
    0.00,
    'available',
    'Cat Lovers Society',
    NOW() - INTERVAL '3 days',
    NOW() - INTERVAL '3 days'
),
-- Large dog for adoption
(
    uuid_generate_v4(),
    '82e92218-d4b7-4967-8e91-1a8e198d18b1',
    'Rocky',
    'dog',
    'German Shepherd',
    '1 year',
    'male',
    'large',
    'Black and Tan',
    'Young and energetic German Shepherd. Needs an active family with space to run. Very loyal and protective. Great guard dog and family companion.',
    NULL,
    true,
    false,
    true,
    true,
    true,
    ARRAY[]::TEXT[],
    'Queens, NY',
    '+1234567892',
    NULL,
    200.00,
    'available',
    'Dog Adoption Network',
    NOW() - INTERVAL '1 day',
    NOW() - INTERVAL '1 day'
),
-- Bird for adoption
(
    uuid_generate_v4(),
    '82e92218-d4b7-4967-8e91-1a8e198d18b1',
    'Tweety',
    'bird',
    'Parakeet',
    '6 months',
    NULL,
    'small',
    'Green and Yellow',
    'Cheerful parakeet that loves to sing. Comes with cage and accessories. Very social and enjoys interaction.',
    NULL,
    false,
    false,
    false,
    NULL,
    NULL,
    ARRAY[]::TEXT[],
    'Manhattan, NY',
    '+1234567893',
    NULL,
    50.00,
    'available',
    'Bird Paradise',
    NOW() - INTERVAL '6 hours',
    NOW() - INTERVAL '6 hours'
);

-- â•â•â• Events â•â•â•

INSERT INTO events (
    id,
    organizer_id,
    title,
    description,
    event_type,
    location,
    start_date,
    end_date,
    max_attendees,
    is_pet_friendly,
    pet_types_allowed,
    status,
    organizer_name,
    rsvp_count,
    created_at,
    updated_at
) VALUES
-- Dog meetup
(
    uuid_generate_v4(),
    '82e92218-d4b7-4967-8e91-1a8e198d18b1',
    'Dog Meetup at Central Park',
    'Join us for a fun afternoon with your furry friends! All dogs welcome. Bring toys and treats! We will have activities and games for dogs of all sizes.',
    'meetup',
    'Central Park - Sheep Meadow, New York, NY',
    NOW() + INTERVAL '3 days',
    NOW() + INTERVAL '3 days' + INTERVAL '3 hours',
    50,
    true,
    ARRAY['dog']::TEXT[],
    'upcoming',
    'NYC Dog Lovers',
    23,
    NOW() - INTERVAL '10 days',
    NOW() - INTERVAL '1 day'
),
-- Adoption drive
(
    uuid_generate_v4(),
    '82e92218-d4b7-4967-8e91-1a8e198d18b1',
    'Pet Adoption Drive',
    'Come meet adorable pets looking for their forever homes! Multiple rescue organizations will be present with dogs, cats, and other pets.',
    'adoption_drive',
    'Brooklyn Animal Shelter, 2336 Linden Blvd, Brooklyn, NY',
    NOW() + INTERVAL '7 days',
    NOW() + INTERVAL '7 days' + INTERVAL '6 hours',
    200,
    true,
    ARRAY['dog', 'cat', 'bird', 'other']::TEXT[],
    'upcoming',
    'Brooklyn Pet Rescue',
    87,
    NOW() - INTERVAL '15 days',
    NOW() - INTERVAL '2 days'
),
-- Training workshop
(
    uuid_generate_v4(),
    '82e92218-d4b7-4967-8e91-1a8e198d18b1',
    'Puppy Training Workshop',
    'Learn basic obedience training techniques for puppies. Professional trainer will demonstrate best practices. Bring your puppy (under 1 year) for hands-on training!',
    'training',
    'Manhattan Dog Training Center, 123 West St, NY',
    NOW() + INTERVAL '14 days',
    NOW() + INTERVAL '14 days' + INTERVAL '2 hours',
    15,
    true,
    ARRAY['dog']::TEXT[],
    'upcoming',
    'Paws & Train',
    12,
    NOW() - INTERVAL '5 days',
    NOW() - INTERVAL '1 day'
),
-- Competition
(
    uuid_generate_v4(),
    '82e92218-d4b7-4967-8e91-1a8e198d18b1',
    'Cat Agility Competition',
    'Watch talented cats show off their agility skills! Registration for participants is closed, but spectators are welcome. See amazing felines navigate obstacle courses!',
    'competition',
    'Queens Community Center, 456 Northern Blvd, Queens, NY',
    NOW() + INTERVAL '21 days',
    NULL,
    100,
    false,
    ARRAY['cat']::TEXT[],
    'upcoming',
    'Feline Sports Association',
    45,
    NOW() - INTERVAL '20 days',
    NOW() - INTERVAL '12 hours'
),
-- Charity event
(
    uuid_generate_v4(),
    '82e92218-d4b7-4967-8e91-1a8e198d18b1',
    'Charity Walk for Animal Shelters',
    'Join our 5K walk to raise funds for local animal shelters. All proceeds go to helping homeless pets. Bring your dog and walk with us! Registration includes a t-shirt.',
    'charity',
    'Prospect Park, Brooklyn, NY',
    NOW() + INTERVAL '30 days',
    NOW() + INTERVAL '30 days' + INTERVAL '4 hours',
    500,
    true,
    ARRAY['dog', 'cat']::TEXT[],
    'upcoming',
    'Paws for a Cause',
    234,
    NOW() - INTERVAL '25 days',
    NOW() - INTERVAL '1 day'
);

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- IMPORTANT: Replace '82e92218-d4b7-4967-8e91-1a8e198d18b1' with an actual user ID
-- 
-- To find a user ID, run:
-- SELECT id, email FROM users LIMIT 5;
-- 
-- Then use one of those IDs to replace all instances of '82e92218-d4b7-4967-8e91-1a8e198d18b1' above
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
