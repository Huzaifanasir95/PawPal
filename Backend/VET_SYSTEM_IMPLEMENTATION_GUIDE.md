# Vet System Implementation Guide

## Overview
This guide outlines the implementation of the Vet System feature for PawPal, which includes:
- User role system (Pet Owner vs Veterinarian)
- Vet profile management
- Chat/messaging between pet owners and vets
- Vet listing and search
- Different dashboards for each role

## Database Migration

### Step 1: Run the Migration
Connect to your PostgreSQL database and run:
```bash
psql -h <your-host> -U <username> -d <database> -f Backend/internal/database/migrations/002_add_vet_and_chat_system.sql
```

This will create:
- `vet_profiles` table
- `chats` table  
- `messages` table
- `vet_reviews` table
- Add `user_role` column to `users` table

### Step 2: Verify Migration
```sql
-- Check if user_role column was added
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name = 'users' AND column_name = 'user_role';

-- Check new tables
\dt vet_profiles
\dt chats
\dt messages
\dt vet_reviews
```

## Backend Implementation Status

### ✅ Completed
- User model updated with `user_role` field
- New models created: `VetProfile`, `Chat`, `Message`, `VetReview`
- Database schema designed and migration created

### 🚧 In Progress
- Creating vet profile handlers
- Creating chat/messaging handlers
- Creating vet listing handlers

### ⏳ To Do
- Update auth handlers to support role selection
- Add role-based access control middleware
- Create vet profile CRUD endpoints
- Create chat endpoints
- Create message endpoints
- Create vet listing with filters endpoint

## Frontend Implementation Status

### ⏳ To Do
1. **Role Selection Screen**
   - Show after successful signup
   - Two elegant cards: "Pet Owner" vs "Veterinarian"
   - Update user role via API

2. **Vet Profile Setup**
   - Multi-step form for vet registration
   - Fields: name, degree, license, specialization, experience, clinic info, fees
   - Photo upload for profile picture

3. **Vet Dashboard**
   - Different from pet owner dashboard
   - Show: pending consultations, messages, appointments, stats

4. **Pet Owner Features**
   - Vets list screen (accessible from bottom nav)
   - Vet detail screen
   - Chat screen for messaging vets

5. **Navigation Updates**
   - Role-based bottom navigation
   - Different home screens per role

## API Endpoints (Planned)

### Auth
- `POST /api/v1/auth/set-role` - Set user role after signup
- `GET /api/v1/auth/me` - Get current user with role

### Vet Profiles
- `POST /api/v1/vets/profile` - Create vet profile
- `GET /api/v1/vets/profile/:userId` - Get vet profile
- `PUT /api/v1/vets/profile` - Update vet profile
- `GET /api/v1/vets` - List all vets (with filters)
- `GET /api/v1/vets/:id` - Get specific vet details

### Chats
- `POST /api/v1/chats` - Start new chat
- `GET /api/v1/chats` - Get user's chats
- `GET /api/v1/chats/:id` - Get specific chat

### Messages
- `POST /api/v1/messages` - Send message
- `GET /api/v1/messages/:chatId` - Get chat messages
- `PUT /api/v1/messages/:id/read` - Mark as read

### Reviews
- `POST /api/v1/vets/:id/reviews` - Add review
- `GET /api/v1/vets/:id/reviews` - Get vet reviews

## Next Steps

1. **Run the database migration** (CRITICAL - do this first!)
2. Complete backend handlers (in progress)
3. Test API endpoints with Postman
4. Implement frontend screens
5. Test complete flow

## Estimated Timeline
- Backend: 4-6 hours
- Frontend: 8-10 hours  
- Testing & Polish: 2-3 hours
**Total: ~15-20 hours**

## Notes
- This is a complex feature touching many parts of the system
- Implement incrementally and test each component
- Consider WebSocket integration for real-time chat later
- Add push notifications for new messages (future enhancement)
