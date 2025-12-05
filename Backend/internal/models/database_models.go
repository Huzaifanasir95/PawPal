package models

import (
	"time"

	"github.com/google/uuid"
)

// User represents a user in the system
type User struct {
	ID            uuid.UUID  `json:"id"`
	Email         string     `json:"email"`
	PasswordHash  string     `json:"-"` // Never expose in JSON
	DisplayName   *string    `json:"display_name,omitempty"`
	AccountType   string     `json:"account_type"`
	UserRole      string     `json:"user_role"` // 'petowner' or 'vet'
	AvatarURL     *string    `json:"avatar_url,omitempty"`
	IsActive      bool       `json:"is_active"`
	EmailVerified bool       `json:"email_verified"`
	GoogleID      *string    `json:"google_id,omitempty"` // For Google OAuth users
	CreatedAt     time.Time  `json:"created_at"`
	UpdatedAt     time.Time  `json:"updated_at"`
}

// UserProfile represents the public user profile
type UserProfile struct {
	ID          uuid.UUID `json:"uid"`
	Email       string    `json:"email"`
	DisplayName *string   `json:"displayName,omitempty"`
	AccountType *string   `json:"accountType,omitempty"`
	UserRole    *string   `json:"userRole,omitempty"`
	AvatarURL   *string   `json:"avatarUrl,omitempty"`
	CreatedAt   time.Time `json:"createdAt"`
	UpdatedAt   time.Time `json:"updatedAt"`
}

// Pet represents a pet owned by a user
type Pet struct {
	ID                     uuid.UUID  `json:"id"`
	OwnerID                uuid.UUID  `json:"ownerId"`
	Name                   string     `json:"name"`
	Type                   string     `json:"type"` // 'dog' or 'cat'
	Breed                  string     `json:"breed"`
	Age                    int        `json:"age"`
	AgeUnit                string     `json:"ageUnit"` // 'months' or 'years'
	Gender                 string     `json:"gender"`  // 'male' or 'female'
	Color                  string     `json:"color"`
	Weight                 float64    `json:"weight"`
	WeightUnit             string     `json:"weightUnit"` // 'kg' or 'lbs'
	ImageURL               *string    `json:"imageUrl,omitempty"`
	ImageLocalPath         *string    `json:"imageLocalPath,omitempty"`
	ImageURLs              []string   `json:"imageUrls,omitempty"`
	IsVerified             bool       `json:"isVerified"`
	VerificationConfidence *float64   `json:"verificationConfidence,omitempty"`
	VerifiedBreed          *string    `json:"verifiedBreed,omitempty"`
	Bio                    *string    `json:"bio,omitempty"`
	IsAdopted              bool       `json:"isAdopted"`
	CreatedAt              time.Time  `json:"createdAt"`
	UpdatedAt              time.Time  `json:"updatedAt"`
}

// HealthRecord represents health information for a pet
type HealthRecord struct {
	ID                    uuid.UUID  `json:"id"`
	PetID                 uuid.UUID  `json:"petId"`
	OwnerID               uuid.UUID  `json:"ownerId"`
	IsVaccinated          bool       `json:"isVaccinated"`
	VaccinationDate       *string    `json:"vaccinationDate,omitempty"`
	VaccinationDetails    *string    `json:"vaccinationDetails,omitempty"`
	MedicalConditions     []string   `json:"medicalConditions,omitempty"`
	Allergies             []string   `json:"allergies,omitempty"`
	Medications           []string   `json:"medications,omitempty"`
	VetName               *string    `json:"vetName,omitempty"`
	VetClinic             *string    `json:"vetClinic,omitempty"`
	VetPhone              *string    `json:"vetPhone,omitempty"`
	VetAddress            *string    `json:"vetAddress,omitempty"`
	EmergencyContactName  *string    `json:"emergencyContactName,omitempty"`
	EmergencyContactPhone *string    `json:"emergencyContactPhone,omitempty"`
	InsuranceProvider     *string    `json:"insuranceProvider,omitempty"`
	InsurancePolicyNumber *string    `json:"insurancePolicyNumber,omitempty"`
	AdditionalNotes       *string    `json:"additionalNotes,omitempty"`
	CreatedAt             time.Time  `json:"createdAt"`
	UpdatedAt             time.Time  `json:"updatedAt"`
}

// HealthJournal represents a daily health journal entry for a pet
type HealthJournal struct {
	ID               uuid.UUID  `json:"id"`
	PetID            uuid.UUID  `json:"petId"`
	OwnerID          uuid.UUID  `json:"ownerId"`
	Date             time.Time  `json:"date"`
	Weight           *float64   `json:"weight,omitempty"`
	WeightUnit       *string    `json:"weightUnit,omitempty"`
	ActivityLevel    *string    `json:"activityLevel,omitempty"`
	EnergyLevel      *string    `json:"energyLevel,omitempty"`
	Mood             *string    `json:"mood,omitempty"`
	Appetite         *string    `json:"appetite,omitempty"`
	Symptoms         []string   `json:"symptoms,omitempty"`
	MedicationsTaken []string   `json:"medicationsTaken,omitempty"`
	VetVisit         bool       `json:"vetVisit"`
	VetVisitReason   *string    `json:"vetVisitReason,omitempty"`
	VetNotes         *string    `json:"vetNotes,omitempty"`
	GeneralNotes     *string    `json:"generalNotes,omitempty"`
	CreatedAt        time.Time  `json:"createdAt"`
	UpdatedAt        time.Time  `json:"updatedAt"`
}

// Post represents a community post
type Post struct {
	ID            uuid.UUID  `json:"id"`
	UserID        uuid.UUID  `json:"userId"`
	Title         string     `json:"title"`
	Content       string     `json:"content"`
	UserName      *string    `json:"userName,omitempty"`
	UserAvatar    *string    `json:"userAvatar,omitempty"`
	ImageURLs     []string   `json:"imageUrls,omitempty"`
	LikesCount    int        `json:"likesCount"`
	CommentsCount int        `json:"commentsCount"`
	CreatedAt     time.Time  `json:"createdAt"`
	UpdatedAt     time.Time  `json:"updatedAt"`
}

// Comment represents a comment on a post
type Comment struct {
	ID              uuid.UUID  `json:"id"`
	PostID          uuid.UUID  `json:"postId"`
	UserID          uuid.UUID  `json:"userId"`
	ParentCommentID *uuid.UUID `json:"parentCommentId,omitempty"`
	Content         string     `json:"content"`
	UserName        *string    `json:"userName,omitempty"`
	UserAvatar      *string    `json:"userAvatar,omitempty"`
	LikesCount      int        `json:"likesCount"`
	Replies         []Comment  `json:"replies,omitempty"`
	CreatedAt       time.Time  `json:"createdAt"`
}

// Like represents a like on a post or comment
type Like struct {
	ID         uuid.UUID `json:"id"`
	UserID     uuid.UUID `json:"userId"`
	TargetID   uuid.UUID `json:"targetId"`
	TargetType string    `json:"targetType"` // 'post' or 'comment'
	CreatedAt  time.Time `json:"createdAt"`
}

// RefreshToken represents a JWT refresh token
type RefreshToken struct {
	ID        uuid.UUID `json:"id"`
	UserID    uuid.UUID `json:"user_id"`
	Token     string    `json:"token"`
	ExpiresAt time.Time `json:"expires_at"`
	Revoked   bool      `json:"revoked"`
	CreatedAt time.Time `json:"created_at"`
}

// PasswordResetToken represents a password reset token
type PasswordResetToken struct {
	ID        uuid.UUID `json:"id"`
	UserID    uuid.UUID `json:"user_id"`
	Token     string    `json:"token"`
	ExpiresAt time.Time `json:"expires_at"`
	Used      bool      `json:"used"`
	CreatedAt time.Time `json:"created_at"`
}

// VetProfile represents a veterinarian's professional profile
type VetProfile struct {
	ID                uuid.UUID  `json:"id"`
	UserID            uuid.UUID  `json:"userId"`
	FullName          string     `json:"fullName"`
	Degree            string     `json:"degree"` // e.g., "DVM", "BVMS", etc.
	LicenseNumber     *string    `json:"licenseNumber,omitempty"`
	Specialization    []string   `json:"specialization,omitempty"` // e.g., ["Surgery", "Dermatology"]
	Experience        int        `json:"experience"` // years of experience
	ClinicName        *string    `json:"clinicName,omitempty"`
	ClinicAddress     *string    `json:"clinicAddress,omitempty"`
	City              *string    `json:"city,omitempty"`
	State             *string    `json:"state,omitempty"`
	ZipCode           *string    `json:"zipCode,omitempty"`
	Phone             string     `json:"phone"`
	ConsultationFee   float64    `json:"consultationFee"`
	Currency          string     `json:"currency"` // e.g., "USD", "PKR"
	Bio               *string    `json:"bio,omitempty"`
	ProfilePhotoURL   *string    `json:"profilePhotoUrl,omitempty"`
	AvailabilityHours *string    `json:"availabilityHours,omitempty"` // JSON string of availability
	Rating            float64    `json:"rating"`
	TotalReviews      int        `json:"totalReviews"`
	IsVerified        bool       `json:"isVerified"`
	IsAvailable       bool       `json:"isAvailable"`
	CreatedAt         time.Time  `json:"createdAt"`
	UpdatedAt         time.Time  `json:"updatedAt"`
}

// Chat represents a conversation between a pet owner and a vet
type Chat struct {
	ID                uuid.UUID  `json:"id"`
	PetOwnerID        uuid.UUID  `json:"petOwnerId"`
	VetID             uuid.UUID  `json:"vetId"`
	PetID             *uuid.UUID `json:"petId,omitempty"`
	PetName           string     `json:"petName,omitempty"`
	LastMessage       *string    `json:"lastMessage,omitempty"`
	LastMessageAt     *time.Time `json:"lastMessageAt,omitempty"`
	UnreadCountOwner  int        `json:"unreadCountOwner"`
	UnreadCountVet    int        `json:"unreadCountVet"`
	OtherUserName     string     `json:"otherUserName,omitempty"`
	OtherUserPhoto    string     `json:"otherUserPhoto,omitempty"`
	CreatedAt         time.Time  `json:"createdAt"`
	UpdatedAt         time.Time  `json:"updatedAt"`
}

// Message represents a single message in a chat
type Message struct {
	ID          uuid.UUID `json:"id"`
	ChatID      uuid.UUID `json:"chatId"`
	SenderID    uuid.UUID `json:"senderId"`
	SenderName  string    `json:"senderName,omitempty"`
	SenderPhoto string    `json:"senderPhoto,omitempty"`
	Content     string    `json:"content"`
	IsRead      bool      `json:"isRead"`
	CreatedAt   time.Time `json:"createdAt"`
}

// VetReview represents a review for a vet
type VetReview struct {
	ID         uuid.UUID  `json:"id"`
	VetID      uuid.UUID  `json:"vetId"`
	UserID     uuid.UUID  `json:"userId"`
	UserName   *string    `json:"userName,omitempty"`
	UserAvatar *string    `json:"userAvatar,omitempty"`
	Rating     int        `json:"rating"` // 1-5
	Comment    *string    `json:"comment,omitempty"`
	CreatedAt  time.Time  `json:"createdAt"`
	UpdatedAt  time.Time  `json:"updatedAt"`
}

