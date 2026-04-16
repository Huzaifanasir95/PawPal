package models

import (
	"time"

	"github.com/google/uuid"
)

// User represents a user in the system
type User struct {
	ID            uuid.UUID `json:"id"`
	Email         string    `json:"email"`
	PasswordHash  string    `json:"-"` // Never expose in JSON
	DisplayName   *string   `json:"display_name,omitempty"`
	AccountType   string    `json:"account_type"`
	Roles         []string  `json:"roles,omitempty"`
	UserRole      string    `json:"user_role"` // 'petowner' or 'vet'
	AvatarURL     *string   `json:"avatar_url,omitempty"`
	IsActive      bool      `json:"is_active"`
	EmailVerified bool      `json:"email_verified"`
	GoogleID      *string   `json:"google_id,omitempty"` // For Google OAuth users
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}

// UserProfile represents the public user profile
type UserProfile struct {
	ID          uuid.UUID `json:"uid"`
	Email       string    `json:"email"`
	DisplayName *string   `json:"displayName,omitempty"`
	AccountType *string   `json:"accountType,omitempty"`
	Roles       []string  `json:"roles,omitempty"`
	ActiveRole  *string   `json:"activeRole,omitempty"`
	UserRole    *string   `json:"userRole,omitempty"`
	AvatarURL   *string   `json:"avatarUrl,omitempty"`
	CreatedAt   time.Time `json:"createdAt"`
	UpdatedAt   time.Time `json:"updatedAt"`
}

// Pet represents a pet owned by a user
type Pet struct {
	ID                     uuid.UUID `json:"id"`
	OwnerID                uuid.UUID `json:"ownerId"`
	Name                   string    `json:"name"`
	Type                   string    `json:"type"` // 'dog' or 'cat'
	Breed                  string    `json:"breed"`
	Age                    int       `json:"age"`
	AgeUnit                string    `json:"ageUnit"` // 'months' or 'years'
	Gender                 string    `json:"gender"`  // 'male' or 'female'
	Color                  string    `json:"color"`
	Weight                 float64   `json:"weight"`
	WeightUnit             string    `json:"weightUnit"` // 'kg' or 'lbs'
	ImageURL               *string   `json:"imageUrl,omitempty"`
	ImageLocalPath         *string   `json:"imageLocalPath,omitempty"`
	ImageURLs              []string  `json:"imageUrls,omitempty"`
	IsVerified             bool      `json:"isVerified"`
	VerificationConfidence *float64  `json:"verificationConfidence,omitempty"`
	VerifiedBreed          *string   `json:"verifiedBreed,omitempty"`
	Bio                    *string   `json:"bio,omitempty"`
	IsAdopted              bool      `json:"isAdopted"`
	CreatedAt              time.Time `json:"createdAt"`
	UpdatedAt              time.Time `json:"updatedAt"`
}

// HealthRecord represents health information for a pet
type HealthRecord struct {
	ID                    uuid.UUID `json:"id"`
	PetID                 uuid.UUID `json:"petId"`
	OwnerID               uuid.UUID `json:"ownerId"`
	IsVaccinated          bool      `json:"isVaccinated"`
	VaccinationDate       *string   `json:"vaccinationDate,omitempty"`
	VaccinationDetails    *string   `json:"vaccinationDetails,omitempty"`
	MedicalConditions     []string  `json:"medicalConditions,omitempty"`
	Allergies             []string  `json:"allergies,omitempty"`
	Medications           []string  `json:"medications,omitempty"`
	VetName               *string   `json:"vetName,omitempty"`
	VetClinic             *string   `json:"vetClinic,omitempty"`
	VetPhone              *string   `json:"vetPhone,omitempty"`
	VetAddress            *string   `json:"vetAddress,omitempty"`
	EmergencyContactName  *string   `json:"emergencyContactName,omitempty"`
	EmergencyContactPhone *string   `json:"emergencyContactPhone,omitempty"`
	InsuranceProvider     *string   `json:"insuranceProvider,omitempty"`
	InsurancePolicyNumber *string   `json:"insurancePolicyNumber,omitempty"`
	AdditionalNotes       *string   `json:"additionalNotes,omitempty"`
	CreatedAt             time.Time `json:"createdAt"`
	UpdatedAt             time.Time `json:"updatedAt"`
}

// HealthJournal represents a daily health journal entry for a pet
type HealthJournal struct {
	ID               uuid.UUID `json:"id"`
	PetID            uuid.UUID `json:"petId"`
	OwnerID          uuid.UUID `json:"ownerId"`
	Date             time.Time `json:"date"`
	Weight           *float64  `json:"weight,omitempty"`
	WeightUnit       *string   `json:"weightUnit,omitempty"`
	ActivityLevel    *string   `json:"activityLevel,omitempty"`
	EnergyLevel      *string   `json:"energyLevel,omitempty"`
	Mood             *string   `json:"mood,omitempty"`
	Appetite         *string   `json:"appetite,omitempty"`
	Symptoms         []string  `json:"symptoms,omitempty"`
	MedicationsTaken []string  `json:"medicationsTaken,omitempty"`
	VetVisit         bool      `json:"vetVisit"`
	VetVisitReason   *string   `json:"vetVisitReason,omitempty"`
	VetNotes         *string   `json:"vetNotes,omitempty"`
	GeneralNotes     *string   `json:"generalNotes,omitempty"`
	CreatedAt        time.Time `json:"createdAt"`
	UpdatedAt        time.Time `json:"updatedAt"`
}

// Post represents a community post
type Post struct {
	ID            uuid.UUID `json:"id"`
	UserID        uuid.UUID `json:"userId"`
	Title         string    `json:"title"`
	Content       string    `json:"content"`
	Category      string    `json:"category"`
	UserName      *string   `json:"userName,omitempty"`
	UserAvatar    *string   `json:"userAvatar,omitempty"`
	ImageURLs     []string  `json:"imageUrls,omitempty"`
	LikesCount    int       `json:"likesCount"`
	CommentsCount int       `json:"commentsCount"`
	CreatedAt     time.Time `json:"createdAt"`
	UpdatedAt     time.Time `json:"updatedAt"`
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
	ID                uuid.UUID `json:"id"`
	UserID            uuid.UUID `json:"userId"`
	FullName          string    `json:"fullName"`
	Degree            string    `json:"degree"` // e.g., "DVM", "BVMS", etc.
	LicenseNumber     *string   `json:"licenseNumber,omitempty"`
	Specialization    []string  `json:"specialization,omitempty"` // e.g., ["Surgery", "Dermatology"]
	Experience        int       `json:"experience"`               // years of experience
	ClinicName        *string   `json:"clinicName,omitempty"`
	ClinicAddress     *string   `json:"clinicAddress,omitempty"`
	City              *string   `json:"city,omitempty"`
	State             *string   `json:"state,omitempty"`
	ZipCode           *string   `json:"zipCode,omitempty"`
	Phone             string    `json:"phone"`
	ConsultationFee   float64   `json:"consultationFee"`
	Currency          string    `json:"currency"` // e.g., "USD", "PKR"
	Bio               *string   `json:"bio,omitempty"`
	ProfilePhotoURL   *string   `json:"profilePhotoUrl,omitempty"`
	AvailabilityHours *string   `json:"availabilityHours,omitempty"` // JSON string of availability
	Rating            float64   `json:"rating"`
	TotalReviews      int       `json:"totalReviews"`
	IsVerified        bool      `json:"isVerified"`
	IsAvailable       bool      `json:"isAvailable"`
	CreatedAt         time.Time `json:"createdAt"`
	UpdatedAt         time.Time `json:"updatedAt"`
}

// Chat represents a conversation between a pet owner and a vet
type Chat struct {
	ID               uuid.UUID  `json:"id"`
	PetOwnerID       uuid.UUID  `json:"petOwnerId"`
	VetID            uuid.UUID  `json:"vetId"`
	PetID            *uuid.UUID `json:"petId,omitempty"`
	PetName          string     `json:"petName,omitempty"`
	LastMessage      *string    `json:"lastMessage,omitempty"`
	LastMessageAt    *time.Time `json:"lastMessageAt,omitempty"`
	UnreadCountOwner int        `json:"unreadCountOwner"`
	UnreadCountVet   int        `json:"unreadCountVet"`
	OtherUserName    string     `json:"otherUserName,omitempty"`
	OtherUserPhoto   string     `json:"otherUserPhoto,omitempty"`
	CreatedAt        time.Time  `json:"createdAt"`
	UpdatedAt        time.Time  `json:"updatedAt"`
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
	ID         uuid.UUID `json:"id"`
	VetID      uuid.UUID `json:"vetId"`
	UserID     uuid.UUID `json:"userId"`
	UserName   *string   `json:"userName,omitempty"`
	UserAvatar *string   `json:"userAvatar,omitempty"`
	Rating     int       `json:"rating"` // 1-5
	Comment    *string   `json:"comment,omitempty"`
	CreatedAt  time.Time `json:"createdAt"`
	UpdatedAt  time.Time `json:"updatedAt"`
}

// VetAppointment represents a scheduled vet consultation appointment
type VetAppointment struct {
	ID                  uuid.UUID  `json:"id"`
	AppointmentNumber   string     `json:"appointmentNumber"`
	PetOwnerID          uuid.UUID  `json:"petOwnerId"`
	VetUserID           uuid.UUID  `json:"vetUserId"`
	PetID               uuid.UUID  `json:"petId"`
	PetName             *string    `json:"petName,omitempty"`
	PetType             *string    `json:"petType,omitempty"`
	Reason              string     `json:"reason"`
	Symptoms            *string    `json:"symptoms,omitempty"`
	OwnerNotes          *string    `json:"ownerNotes,omitempty"`
	AppointmentDatetime time.Time  `json:"appointmentDatetime"`
	DurationMinutes     int        `json:"durationMinutes"`
	MeetingType         string     `json:"meetingType"`
	ClinicAddress       *string    `json:"clinicAddress,omitempty"`
	MeetingLink         *string    `json:"meetingLink,omitempty"`
	FeeAmount           float64    `json:"feeAmount"`
	Currency            string     `json:"currency"`
	Status              string     `json:"status"`
	ResponseNote        *string    `json:"responseNote,omitempty"`
	RespondedAt         *time.Time `json:"respondedAt,omitempty"`
	CancelledAt         *time.Time `json:"cancelledAt,omitempty"`
	CompletedAt         *time.Time `json:"completedAt,omitempty"`
	CreatedAt           time.Time  `json:"createdAt"`
	UpdatedAt           time.Time  `json:"updatedAt"`

	// Joined fields
	OwnerName   *string `json:"ownerName,omitempty"`
	OwnerAvatar *string `json:"ownerAvatar,omitempty"`
	VetName     *string `json:"vetName,omitempty"`
	VetAvatar   *string `json:"vetAvatar,omitempty"`
}

// LostFoundPost represents a lost or found pet alert
type LostFoundPost struct {
	ID               uuid.UUID `json:"id"`
	UserID           uuid.UUID `json:"userId"`
	Type             string    `json:"type"` // lost or found
	PetName          *string   `json:"petName,omitempty"`
	PetType          *string   `json:"petType,omitempty"`
	Breed            *string   `json:"breed,omitempty"`
	Color            *string   `json:"color,omitempty"`
	Description      string    `json:"description"`
	ImageURLs        []string  `json:"imageUrls,omitempty"`
	LastSeenLocation *string   `json:"lastSeenLocation,omitempty"`
	LastSeenLat      *float64  `json:"lastSeenLat,omitempty"`
	LastSeenLng      *float64  `json:"lastSeenLng,omitempty"`
	Urgency          string    `json:"urgency"`
	ContactPhone     *string   `json:"contactPhone,omitempty"`
	ContactEmail     *string   `json:"contactEmail,omitempty"`
	Status           string    `json:"status"`
	UserName         *string   `json:"userName,omitempty"`
	UserAvatar       *string   `json:"userAvatar,omitempty"`
	CreatedAt        time.Time `json:"createdAt"`
	UpdatedAt        time.Time `json:"updatedAt"`
}

// AdoptionListing represents a pet available for adoption
type AdoptionListing struct {
	ID           uuid.UUID `json:"id"`
	UserID       uuid.UUID `json:"userId"`
	PetID        *uuid.UUID `json:"petId,omitempty"`
	PetName      string    `json:"petName"`
	PetType      string    `json:"petType"`
	Breed        *string   `json:"breed,omitempty"`
	IsBreedVerified bool    `json:"isBreedVerified"`
	VerifiedBreed *string   `json:"verifiedBreed,omitempty"`
	Age          *string   `json:"age,omitempty"`
	Gender       *string   `json:"gender,omitempty"`
	Size         *string   `json:"size,omitempty"`
	Color        *string   `json:"color,omitempty"`
	Description  string    `json:"description"`
	MedicalInfo  *string   `json:"medicalInfo,omitempty"`
	IsVaccinated bool      `json:"isVaccinated"`
	IsNeutered   bool      `json:"isNeutered"`
	IsTrained    bool      `json:"isTrained"`
	GoodWithKids *bool     `json:"goodWithKids,omitempty"`
	GoodWithPets *bool     `json:"goodWithPets,omitempty"`
	ImageURLs    []string  `json:"imageUrls,omitempty"`
	Location     *string   `json:"location,omitempty"`
	ContactPhone *string   `json:"contactPhone,omitempty"`
	ContactEmail *string   `json:"contactEmail,omitempty"`
	AdoptionFee  float64   `json:"adoptionFee"`
	Status       string    `json:"status"`
	UserName     *string   `json:"userName,omitempty"`
	UserAvatar   *string   `json:"userAvatar,omitempty"`
	CreatedAt    time.Time `json:"createdAt"`
	UpdatedAt    time.Time `json:"updatedAt"`
}

// Event represents a community event or meetup
type Event struct {
	ID              uuid.UUID  `json:"id"`
	OrganizerID     uuid.UUID  `json:"organizerId"`
	Title           string     `json:"title"`
	Description     string     `json:"description"`
	EventType       string     `json:"eventType"`
	ImageURL        *string    `json:"imageUrl,omitempty"`
	Location        *string    `json:"location,omitempty"`
	LocationLat     *float64   `json:"locationLat,omitempty"`
	LocationLng     *float64   `json:"locationLng,omitempty"`
	StartDate       time.Time  `json:"startDate"`
	EndDate         *time.Time `json:"endDate,omitempty"`
	MaxAttendees    *int       `json:"maxAttendees,omitempty"`
	IsPetFriendly   bool       `json:"isPetFriendly"`
	PetTypesAllowed []string   `json:"petTypesAllowed,omitempty"`
	Status          string     `json:"status"`
	OrganizerName   *string    `json:"organizerName,omitempty"`
	OrganizerAvatar *string    `json:"organizerAvatar,omitempty"`
	RSVPCount       int        `json:"rsvpCount"`
	CreatedAt       time.Time  `json:"createdAt"`
	UpdatedAt       time.Time  `json:"updatedAt"`
}

// EventRSVP represents a user's RSVP to an event
type EventRSVP struct {
	ID         uuid.UUID `json:"id"`
	EventID    uuid.UUID `json:"eventId"`
	UserID     uuid.UUID `json:"userId"`
	Status     string    `json:"status"` // going, interested, waitlisted
	UserName   *string   `json:"userName,omitempty"`
	UserAvatar *string   `json:"userAvatar,omitempty"`
	CreatedAt  time.Time `json:"createdAt"`
}

// CommunityGroup represents a discussion group in community space.
type CommunityGroup struct {
	ID           uuid.UUID `json:"id"`
	OwnerID      uuid.UUID `json:"ownerId"`
	Name         string    `json:"name"`
	Slug         string    `json:"slug"`
	Description  *string   `json:"description,omitempty"`
	Icon         *string   `json:"icon,omitempty"`
	IsPrivate    bool      `json:"isPrivate"`
	MembersCount int       `json:"membersCount"`
	PostsCount   int       `json:"postsCount"`
	IsMember     bool      `json:"isMember"`
	OwnerName    *string   `json:"ownerName,omitempty"`
	CreatedAt    time.Time `json:"createdAt"`
	UpdatedAt    time.Time `json:"updatedAt"`
}

// TrendingHashtag represents a hashtag trend snapshot.
type TrendingHashtag struct {
	Tag        string `json:"tag"`
	UsageCount int    `json:"usageCount"`
}

// =====================================================
// CAREGIVER MODULE MODELS
// =====================================================

// CaregiverServiceType represents a type of service (walking, sitting, etc.)
type CaregiverServiceType struct {
	ID             uuid.UUID `json:"id"`
	Name           string    `json:"name"`
	DisplayName    string    `json:"displayName"`
	Description    *string   `json:"description,omitempty"`
	BaseHourlyRate float64   `json:"baseHourlyRate"`
	IconName       *string   `json:"iconName,omitempty"`
	IsActive       bool      `json:"isActive"`
	CreatedAt      time.Time `json:"createdAt"`
}

// CaregiverProfile represents a caregiver's professional profile
type CaregiverProfile struct {
	ID                    uuid.UUID  `json:"id"`
	UserID                uuid.UUID  `json:"userId"`
	Bio                   *string    `json:"bio,omitempty"`
	YearsOfExperience     int        `json:"yearsOfExperience"`
	Headline              *string    `json:"headline,omitempty"`
	Address               *string    `json:"address,omitempty"`
	City                  *string    `json:"city,omitempty"`
	State                 *string    `json:"state,omitempty"`
	PostalCode            *string    `json:"postalCode,omitempty"`
	Country               string     `json:"country"`
	Latitude              *float64   `json:"latitude,omitempty"`
	Longitude             *float64   `json:"longitude,omitempty"`
	ServiceRadiusKm       int        `json:"serviceRadiusKm"`
	IsVerified            bool       `json:"isVerified"`
	VerificationDate      *time.Time `json:"verificationDate,omitempty"`
	BackgroundCheckStatus string     `json:"backgroundCheckStatus"`
	BackgroundCheckDate   *time.Time `json:"backgroundCheckDate,omitempty"`
	BackgroundCheckExpiry *time.Time `json:"backgroundCheckExpiry,omitempty"`
	IDVerified            bool       `json:"idVerified"`
	IDDocumentURL         *string    `json:"idDocumentUrl,omitempty"`
	Certifications        []string   `json:"certifications,omitempty"`
	PetFirstAidCertified  bool       `json:"petFirstAidCertified"`
	InsuranceVerified     bool       `json:"insuranceVerified"`
	InsurancePolicyNumber *string    `json:"insurancePolicyNumber,omitempty"`
	InsuranceExpiry       *time.Time `json:"insuranceExpiry,omitempty"`
	AcceptedPetTypes      []string   `json:"acceptedPetTypes"`
	AcceptedPetSizes      []string   `json:"acceptedPetSizes"`
	MaxPetsAtOnce         int        `json:"maxPetsAtOnce"`
	HasFencedYard         bool       `json:"hasFencedYard"`
	HasOwnTransport       bool       `json:"hasOwnTransport"`
	SmokeFreeHome         bool       `json:"smokeFreeHome"`
	HasChildren           bool       `json:"hasChildren"`
	HasOtherPets          bool       `json:"hasOtherPets"`
	OtherPetsDescription  *string    `json:"otherPetsDescription,omitempty"`
	AverageRating         float64    `json:"averageRating"`
	TotalReviews          int        `json:"totalReviews"`
	TotalBookings         int        `json:"totalBookings"`
	CompletionRate        float64    `json:"completionRate"`
	ResponseTimeHours     int        `json:"responseTimeHours"`
	IsActive              bool       `json:"isActive"`
	IsAcceptingBookings   bool       `json:"isAcceptingBookings"`
	CreatedAt             time.Time  `json:"createdAt"`
	UpdatedAt             time.Time  `json:"updatedAt"`

	// Joined fields
	UserName   *string            `json:"userName,omitempty"`
	UserAvatar *string            `json:"userAvatar,omitempty"`
	UserEmail  *string            `json:"userEmail,omitempty"`
	Services   []CaregiverService `json:"services,omitempty"`
}

// CaregiverService represents a service offered by a caregiver
type CaregiverService struct {
	ID                uuid.UUID `json:"id"`
	CaregiverID       uuid.UUID `json:"caregiverId"`
	ServiceTypeID     uuid.UUID `json:"serviceTypeId"`
	RateType          string    `json:"rateType"` // hourly, per_visit, daily, per_walk
	RateAmount        float64   `json:"rateAmount"`
	Currency          string    `json:"currency"`
	Description       *string   `json:"description,omitempty"`
	DurationMinutes   *int      `json:"durationMinutes,omitempty"`
	Includes          []string  `json:"includes,omitempty"`
	AdditionalPetRate float64   `json:"additionalPetRate"`
	IsAvailable       bool      `json:"isAvailable"`
	CreatedAt         time.Time `json:"createdAt"`
	UpdatedAt         time.Time `json:"updatedAt"`

	// Joined fields
	ServiceTypeName        string  `json:"serviceTypeName,omitempty"`
	ServiceTypeDisplayName string  `json:"serviceTypeDisplayName,omitempty"`
	ServiceTypeIcon        *string `json:"serviceTypeIcon,omitempty"`
}

// CaregiverAvailability represents weekly availability slot
type CaregiverAvailability struct {
	ID          uuid.UUID `json:"id"`
	CaregiverID uuid.UUID `json:"caregiverId"`
	DayOfWeek   int       `json:"dayOfWeek"` // 0=Sunday, 6=Saturday
	StartTime   string    `json:"startTime"` // HH:MM format
	EndTime     string    `json:"endTime"`
	IsAvailable bool      `json:"isAvailable"`
	CreatedAt   time.Time `json:"createdAt"`
}

// CaregiverBlockedDate represents a blocked/unavailable date
type CaregiverBlockedDate struct {
	ID          uuid.UUID `json:"id"`
	CaregiverID uuid.UUID `json:"caregiverId"`
	BlockedDate time.Time `json:"blockedDate"`
	Reason      *string   `json:"reason,omitempty"`
	CreatedAt   time.Time `json:"createdAt"`
}

// ServiceBooking represents a booking for caregiver service
type ServiceBooking struct {
	ID                    uuid.UUID   `json:"id"`
	BookingNumber         string      `json:"bookingNumber"`
	PetOwnerID            uuid.UUID   `json:"petOwnerId"`
	CaregiverID           uuid.UUID   `json:"caregiverId"`
	ServiceID             uuid.UUID   `json:"serviceId"`
	PetIDs                []uuid.UUID `json:"petIds"`
	StartDatetime         time.Time   `json:"startDatetime"`
	EndDatetime           time.Time   `json:"endDatetime"`
	ServiceLocationType   string      `json:"serviceLocationType"`
	ServiceAddress        *string     `json:"serviceAddress,omitempty"`
	ServiceLatitude       *float64    `json:"serviceLatitude,omitempty"`
	ServiceLongitude      *float64    `json:"serviceLongitude,omitempty"`
	SpecialInstructions   *string     `json:"specialInstructions,omitempty"`
	EmergencyContactName  *string     `json:"emergencyContactName,omitempty"`
	EmergencyContactPhone *string     `json:"emergencyContactPhone,omitempty"`
	BaseAmount            float64     `json:"baseAmount"`
	AdditionalPetsFee     float64     `json:"additionalPetsFee"`
	ServiceFee            float64     `json:"serviceFee"`
	DiscountAmount        float64     `json:"discountAmount"`
	TotalAmount           float64     `json:"totalAmount"`
	Currency              string      `json:"currency"`
	Status                string      `json:"status"`
	RequestedAt           time.Time   `json:"requestedAt"`
	RespondedAt           *time.Time  `json:"respondedAt,omitempty"`
	StartedAt             *time.Time  `json:"startedAt,omitempty"`
	CompletedAt           *time.Time  `json:"completedAt,omitempty"`
	CancelledAt           *time.Time  `json:"cancelledAt,omitempty"`
	CancellationReason    *string     `json:"cancellationReason,omitempty"`
	CreatedAt             time.Time   `json:"createdAt"`
	UpdatedAt             time.Time   `json:"updatedAt"`

	// Joined fields
	OwnerName       *string `json:"ownerName,omitempty"`
	OwnerAvatar     *string `json:"ownerAvatar,omitempty"`
	CaregiverName   *string `json:"caregiverName,omitempty"`
	CaregiverAvatar *string `json:"caregiverAvatar,omitempty"`
	ServiceName     *string `json:"serviceName,omitempty"`
	Pets            []Pet   `json:"pets,omitempty"`
}

// BookingPayment represents payment for a booking
type BookingPayment struct {
	ID                  uuid.UUID  `json:"id"`
	BookingID           uuid.UUID  `json:"bookingId"`
	Amount              float64    `json:"amount"`
	Currency            string     `json:"currency"`
	PaymentType         string     `json:"paymentType"` // deposit, final, refund, tip
	PaymentMethod       *string    `json:"paymentMethod,omitempty"`
	TransactionID       *string    `json:"transactionId,omitempty"`
	Status              string     `json:"status"`
	EscrowHeldAt        *time.Time `json:"escrowHeldAt,omitempty"`
	EscrowReleasedAt    *time.Time `json:"escrowReleasedAt,omitempty"`
	PayoutStatus        string     `json:"payoutStatus"`
	PayoutAmount        *float64   `json:"payoutAmount,omitempty"`
	PlatformFee         *float64   `json:"platformFee,omitempty"`
	PayoutTransactionID *string    `json:"payoutTransactionId,omitempty"`
	PayoutAt            *time.Time `json:"payoutAt,omitempty"`
	CreatedAt           time.Time  `json:"createdAt"`
	UpdatedAt           time.Time  `json:"updatedAt"`
}

// BookingTracking represents GPS tracking during service
type BookingTracking struct {
	ID             uuid.UUID `json:"id"`
	BookingID      uuid.UUID `json:"bookingId"`
	Latitude       float64   `json:"latitude"`
	Longitude      float64   `json:"longitude"`
	AccuracyMeters *float64  `json:"accuracyMeters,omitempty"`
	ActivityType   *string   `json:"activityType,omitempty"`
	Note           *string   `json:"note,omitempty"`
	RecordedAt     time.Time `json:"recordedAt"`
}

// BookingCompletionReport represents service completion report
type BookingCompletionReport struct {
	ID                    uuid.UUID  `json:"id"`
	BookingID             uuid.UUID  `json:"bookingId"`
	Summary               string     `json:"summary"`
	ActivitiesPerformed   []string   `json:"activitiesPerformed,omitempty"`
	FeedingNotes          *string    `json:"feedingNotes,omitempty"`
	BathroomNotes         *string    `json:"bathroomNotes,omitempty"`
	BehaviorNotes         *string    `json:"behaviorNotes,omitempty"`
	HealthObservations    *string    `json:"healthObservations,omitempty"`
	PhotoURLs             []string   `json:"photoUrls,omitempty"`
	VideoURLs             []string   `json:"videoUrls,omitempty"`
	ActualDurationMinutes *int       `json:"actualDurationMinutes,omitempty"`
	DistanceWalkedKm      *float64   `json:"distanceWalkedKm,omitempty"`
	SubmittedAt           time.Time  `json:"submittedAt"`
	OwnerAcknowledgedAt   *time.Time `json:"ownerAcknowledgedAt,omitempty"`
}

// ServiceReview represents reviews for a completed booking
type ServiceReview struct {
	ID                  uuid.UUID  `json:"id"`
	BookingID           uuid.UUID  `json:"bookingId"`
	OwnerRating         *int       `json:"ownerRating,omitempty"`
	OwnerReview         *string    `json:"ownerReview,omitempty"`
	OwnerReviewAt       *time.Time `json:"ownerReviewAt,omitempty"`
	CommunicationRating *int       `json:"communicationRating,omitempty"`
	ReliabilityRating   *int       `json:"reliabilityRating,omitempty"`
	CareQualityRating   *int       `json:"careQualityRating,omitempty"`
	CaregiverRating     *int       `json:"caregiverRating,omitempty"`
	CaregiverReview     *string    `json:"caregiverReview,omitempty"`
	CaregiverReviewAt   *time.Time `json:"caregiverReviewAt,omitempty"`
	PetBehaviorRating   *int       `json:"petBehaviorRating,omitempty"`
	IsPublic            bool       `json:"isPublic"`
	CreatedAt           time.Time  `json:"createdAt"`
	UpdatedAt           time.Time  `json:"updatedAt"`

	// Joined fields
	OwnerName     *string `json:"ownerName,omitempty"`
	OwnerAvatar   *string `json:"ownerAvatar,omitempty"`
	CaregiverName *string `json:"caregiverName,omitempty"`
}

// ServiceIncident represents an incident during service
type ServiceIncident struct {
	ID                   uuid.UUID  `json:"id"`
	IncidentNumber       string     `json:"incidentNumber"`
	BookingID            uuid.UUID  `json:"bookingId"`
	ReportedBy           uuid.UUID  `json:"reportedBy"`
	IncidentType         string     `json:"incidentType"`
	Severity             string     `json:"severity"`
	Description          string     `json:"description"`
	OccurredAt           time.Time  `json:"occurredAt"`
	LocationDescription  *string    `json:"locationDescription,omitempty"`
	PhotoURLs            []string   `json:"photoUrls,omitempty"`
	VideoURLs            []string   `json:"videoUrls,omitempty"`
	Status               string     `json:"status"`
	ResolutionNotes      *string    `json:"resolutionNotes,omitempty"`
	ResolvedAt           *time.Time `json:"resolvedAt,omitempty"`
	ResolvedBy           *uuid.UUID `json:"resolvedBy,omitempty"`
	InsuranceClaimFiled  bool       `json:"insuranceClaimFiled"`
	InsuranceClaimNumber *string    `json:"insuranceClaimNumber,omitempty"`
	InsuranceClaimStatus *string    `json:"insuranceClaimStatus,omitempty"`
	CreatedAt            time.Time  `json:"createdAt"`
	UpdatedAt            time.Time  `json:"updatedAt"`

	// Joined fields
	ReporterName *string `json:"reporterName,omitempty"`
}

// CaregiverGallery represents caregiver's portfolio images
type CaregiverGallery struct {
	ID           uuid.UUID `json:"id"`
	CaregiverID  uuid.UUID `json:"caregiverId"`
	ImageURL     string    `json:"imageUrl"`
	Caption      *string   `json:"caption,omitempty"`
	IsPrimary    bool      `json:"isPrimary"`
	DisplayOrder int       `json:"displayOrder"`
	CreatedAt    time.Time `json:"createdAt"`
}
