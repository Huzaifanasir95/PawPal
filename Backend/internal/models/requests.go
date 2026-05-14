package models

import "github.com/google/uuid"

// Auth Request/Response types

// SignUpRequest represents a signup request
type SignUpRequest struct {
	Email       string  `json:"email" binding:"required,email"`
	Password    string  `json:"password" binding:"required,min=6"`
	DisplayName *string `json:"displayName,omitempty"`
	AccountType *string `json:"accountType,omitempty"`
}

// SignInRequest represents a signin request
type SignInRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

// GoogleSignInRequest represents a Google sign-in request
type GoogleSignInRequest struct {
	IDToken     string  `json:"idToken" binding:"required"`
	DisplayName *string `json:"displayName,omitempty"`
	PhotoURL    *string `json:"photoUrl,omitempty"`
	AccountType *string `json:"accountType,omitempty"`
}

// AuthResponse represents an authentication response
type AuthResponse struct {
	Success      bool         `json:"success"`
	Message      string       `json:"message,omitempty"`
	User         *UserProfile `json:"user,omitempty"`
	AccessToken  string       `json:"accessToken,omitempty"`
	RefreshToken string       `json:"refreshToken,omitempty"`
	ExpiresIn    int64        `json:"expiresIn,omitempty"` // Token expiry in seconds
	IsNewUser    bool         `json:"isNewUser,omitempty"` // Indicates if this is a new user needing account setup
}

// RefreshTokenRequest represents a token refresh request
type RefreshTokenRequest struct {
	RefreshToken string `json:"refreshToken" binding:"required"`
}

// PasswordResetRequest represents a password reset request
type PasswordResetRequest struct {
	Email string `json:"email" binding:"required,email"`
}

// PasswordResetConfirmRequest represents a password reset confirmation
type PasswordResetConfirmRequest struct {
	Token       string `json:"token" binding:"required"`
	NewPassword string `json:"newPassword" binding:"required,min=6"`
}

// UpdateProfileRequest represents an update profile request
type UpdateProfileRequest struct {
	DisplayName *string `json:"displayName,omitempty"`
	AccountType *string `json:"accountType,omitempty"`
	AvatarURL   *string `json:"avatarUrl,omitempty"`
}

// UpdateEmailRequest requires current password to safely change email.
type UpdateEmailRequest struct {
	NewEmail        string `json:"newEmail" binding:"required,email"`
	CurrentPassword string `json:"currentPassword" binding:"required"`
}

// UpdatePasswordRequest requires current password before setting a new password.
type UpdatePasswordRequest struct {
	CurrentPassword string `json:"currentPassword" binding:"required"`
	NewPassword     string `json:"newPassword" binding:"required,min=6"`
}

// CreatePaymentMethodRequest captures a card for demo-only saved payment methods.
type CreatePaymentMethodRequest struct {
	CardholderName string  `json:"cardholderName" binding:"required"`
	CardNumber     string  `json:"cardNumber" binding:"required"`
	ExpiryMonth    int     `json:"expiryMonth" binding:"required,min=1,max=12"`
	ExpiryYear     int     `json:"expiryYear" binding:"required,min=2024"`
	Cvv            string  `json:"cvv" binding:"required,min=3,max=4"`
	Nickname       *string `json:"nickname,omitempty"`
	SetAsDefault   bool    `json:"setAsDefault"`
}

// AddRoleRequest represents a request to assign an additional role to a user.
type AddRoleRequest struct {
	Role string `json:"role" binding:"required"`
}

// SwitchRoleRequest represents a request to switch the active role.
type SwitchRoleRequest struct {
	Role string `json:"role" binding:"required"`
}

// Pet Request/Response types

// CreatePetRequest represents a create pet request
type CreatePetRequest struct {
	Name                   string   `json:"name" binding:"required"`
	Type                   string   `json:"type" binding:"required,oneof=dog cat"`
	Breed                  string   `json:"breed" binding:"required"`
	Age                    int      `json:"age" binding:"required,min=0"`
	AgeUnit                string   `json:"ageUnit" binding:"required,oneof=months years"`
	Gender                 string   `json:"gender" binding:"required,oneof=male female"`
	Color                  string   `json:"color" binding:"required"`
	Weight                 float64  `json:"weight" binding:"required,min=0"`
	WeightUnit             string   `json:"weightUnit" binding:"required,oneof=kg lbs"`
	ImageURL               *string  `json:"imageUrl,omitempty"`
	ImageLocalPath         *string  `json:"imageLocalPath,omitempty"`
	ImageURLs              []string `json:"imageUrls,omitempty"`
	IsVerified             *bool    `json:"isVerified,omitempty"`
	VerificationConfidence *float64 `json:"verificationConfidence,omitempty"`
	VerifiedBreed          *string  `json:"verifiedBreed,omitempty"`
	Bio                    *string  `json:"bio,omitempty"`
}

// UpdatePetRequest represents an update pet request
type UpdatePetRequest struct {
	Name       *string  `json:"name,omitempty"`
	Breed      *string  `json:"breed,omitempty"`
	Age        *int     `json:"age,omitempty"`
	AgeUnit    *string  `json:"ageUnit,omitempty"`
	Gender     *string  `json:"gender,omitempty"`
	Color      *string  `json:"color,omitempty"`
	Weight     *float64 `json:"weight,omitempty"`
	WeightUnit *string  `json:"weightUnit,omitempty"`
	ImageURLs  []string `json:"imageUrls,omitempty"`
	Bio        *string  `json:"bio,omitempty"`
	IsAdopted  *bool    `json:"isAdopted,omitempty"`
}

// PetResponse represents a pet response
type PetResponse struct {
	Success bool   `json:"success"`
	Message string `json:"message,omitempty"`
	Pet     *Pet   `json:"pet,omitempty"`
}

// PetsResponse represents multiple pets response
type PetsResponse struct {
	Success bool   `json:"success"`
	Message string `json:"message,omitempty"`
	Pets    []Pet  `json:"pets"`
	Count   int    `json:"count"`
}

// Health Record Request/Response types

// CreateHealthRecordRequest represents a create health record request
type CreateHealthRecordRequest struct {
	PetID                 uuid.UUID `json:"petId" binding:"required"`
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
}

// UpdateHealthRecordRequest represents an update health record request
type UpdateHealthRecordRequest struct {
	IsVaccinated          *bool    `json:"isVaccinated,omitempty"`
	VaccinationDate       *string  `json:"vaccinationDate,omitempty"`
	VaccinationDetails    *string  `json:"vaccinationDetails,omitempty"`
	MedicalConditions     []string `json:"medicalConditions,omitempty"`
	Allergies             []string `json:"allergies,omitempty"`
	Medications           []string `json:"medications,omitempty"`
	VetName               *string  `json:"vetName,omitempty"`
	VetClinic             *string  `json:"vetClinic,omitempty"`
	VetPhone              *string  `json:"vetPhone,omitempty"`
	VetAddress            *string  `json:"vetAddress,omitempty"`
	EmergencyContactName  *string  `json:"emergencyContactName,omitempty"`
	EmergencyContactPhone *string  `json:"emergencyContactPhone,omitempty"`
	InsuranceProvider     *string  `json:"insuranceProvider,omitempty"`
	InsurancePolicyNumber *string  `json:"insurancePolicyNumber,omitempty"`
	AdditionalNotes       *string  `json:"additionalNotes,omitempty"`
}

// HealthRecordResponse represents a health record response
type HealthRecordResponse struct {
	Success      bool          `json:"success"`
	Message      string        `json:"message,omitempty"`
	HealthRecord *HealthRecord `json:"healthRecord,omitempty"`
}

// Health Journal Request/Response types

// CreateHealthJournalRequest represents a create health journal request
type CreateHealthJournalRequest struct {
	PetID            uuid.UUID `json:"petId" binding:"required"`
	Date             string    `json:"date" binding:"required"`
	Weight           *float64  `json:"weight,omitempty"`
	WeightUnit       *string   `json:"weightUnit,omitempty"`
	ActivityLevel    *string   `json:"activityLevel,omitempty"`
	EnergyLevel      *string   `json:"energyLevel,omitempty"`
	Mood             *string   `json:"mood,omitempty"`
	Appetite         *string   `json:"appetite,omitempty"`
	Symptoms         []string  `json:"symptoms,omitempty"`
	MedicationsTaken []string  `json:"medicationsTaken,omitempty"`
	VetVisit         *bool     `json:"vetVisit,omitempty"`
	VetVisitReason   *string   `json:"vetVisitReason,omitempty"`
	VetNotes         *string   `json:"vetNotes,omitempty"`
	GeneralNotes     *string   `json:"generalNotes,omitempty"`
}

// HealthJournalResponse represents a health journal response
type HealthJournalResponse struct {
	Success       bool           `json:"success"`
	Message       string         `json:"message,omitempty"`
	HealthJournal *HealthJournal `json:"healthJournal,omitempty"`
}

// HealthJournalsResponse represents multiple health journals response
type HealthJournalsResponse struct {
	Success        bool            `json:"success"`
	Message        string          `json:"message,omitempty"`
	HealthJournals []HealthJournal `json:"healthJournals"`
	Count          int             `json:"count"`
}

// Post Request/Response types

// CreatePostRequest represents a create post request
type CreatePostRequest struct {
	Title     string   `json:"title" binding:"required,min=1,max=500"`
	Content   string   `json:"content" binding:"required,min=1"`
	Category  string   `json:"category"`
	ImageURLs []string `json:"imageUrls,omitempty"`
}

// UpdatePostRequest represents an update post request
type UpdatePostRequest struct {
	Title   *string `json:"title,omitempty"`
	Content *string `json:"content,omitempty"`
}

// PostResponse represents a post response
type PostResponse struct {
	Success bool   `json:"success"`
	Message string `json:"message,omitempty"`
	Post    *Post  `json:"post,omitempty"`
}

// PostsResponse represents multiple posts response
type PostsResponse struct {
	Success bool   `json:"success"`
	Message string `json:"message,omitempty"`
	Posts   []Post `json:"posts"`
	Count   int    `json:"count"`
}

// Comment Request/Response types

// CreateCommentRequest represents a create comment request
type CreateCommentRequest struct {
	PostID          uuid.UUID  `json:"postId" binding:"required"`
	Content         string     `json:"content" binding:"required,min=1"`
	ParentCommentID *uuid.UUID `json:"parentCommentId,omitempty"`
}

// CommentResponse represents a comment response
type CommentResponse struct {
	Success bool     `json:"success"`
	Message string   `json:"message,omitempty"`
	Comment *Comment `json:"comment,omitempty"`
}

// CommentsResponse represents multiple comments response
type CommentsResponse struct {
	Success  bool      `json:"success"`
	Message  string    `json:"message,omitempty"`
	Comments []Comment `json:"comments"`
	Count    int       `json:"count"`
}

// Like Request/Response types

// LikeResponse represents a like response
type LikeResponse struct {
	Success bool   `json:"success"`
	Message string `json:"message,omitempty"`
	Liked   bool   `json:"liked"`
}

// Generic Response

// GenericResponse represents a generic API response
type GenericResponse struct {
	Success bool        `json:"success"`
	Message string      `json:"message,omitempty"`
	Data    interface{} `json:"data,omitempty"`
}

// ─── Lost & Found Request/Response ──────────────────────────────

type CreateLostFoundRequest struct {
	Type             string   `json:"type" binding:"required,oneof=lost found"`
	PetName          *string  `json:"petName,omitempty"`
	PetType          *string  `json:"petType,omitempty"`
	Breed            *string  `json:"breed,omitempty"`
	Color            *string  `json:"color,omitempty"`
	Description      string   `json:"description" binding:"required,min=1"`
	ImageURLs        []string `json:"imageUrls,omitempty"`
	LastSeenLocation *string  `json:"lastSeenLocation,omitempty"`
	LastSeenLat      *float64 `json:"lastSeenLat,omitempty"`
	LastSeenLng      *float64 `json:"lastSeenLng,omitempty"`
	Urgency          string   `json:"urgency" binding:"omitempty,oneof=low medium high critical"`
	ContactPhone     *string  `json:"contactPhone,omitempty"`
	ContactEmail     *string  `json:"contactEmail,omitempty"`
}

type UpdateLostFoundRequest struct {
	Description      *string `json:"description,omitempty"`
	LastSeenLocation *string `json:"lastSeenLocation,omitempty"`
	Urgency          *string `json:"urgency,omitempty"`
	ContactPhone     *string `json:"contactPhone,omitempty"`
	ContactEmail     *string `json:"contactEmail,omitempty"`
	Status           *string `json:"status,omitempty"`
}

// ─── Adoption Request/Response ──────────────────────────────────

type CreateAdoptionRequest struct {
	PetID        uuid.UUID `json:"petId" binding:"required"`
	PetName      string   `json:"petName" binding:"required,min=1,max=100"`
	PetType      string   `json:"petType" binding:"required"`
	Breed        *string  `json:"breed,omitempty"`
	Age          *string  `json:"age,omitempty"`
	Gender       *string  `json:"gender,omitempty" binding:"omitempty,oneof=male female unknown"`
	Size         *string  `json:"size,omitempty" binding:"omitempty,oneof=small medium large xlarge"`
	Color        *string  `json:"color,omitempty"`
	Description  string   `json:"description" binding:"required,min=1"`
	MedicalInfo  *string  `json:"medicalInfo,omitempty"`
	IsVaccinated bool     `json:"isVaccinated"`
	IsNeutered   bool     `json:"isNeutered"`
	IsTrained    bool     `json:"isTrained"`
	GoodWithKids *bool    `json:"goodWithKids,omitempty"`
	GoodWithPets *bool    `json:"goodWithPets,omitempty"`
	ImageURLs    []string `json:"imageUrls,omitempty"`
	Location     *string  `json:"location,omitempty"`
	ContactPhone *string  `json:"contactPhone,omitempty"`
	ContactEmail *string  `json:"contactEmail,omitempty"`
	AdoptionFee  float64  `json:"adoptionFee"`
}

type UpdateAdoptionRequest struct {
	Description  *string  `json:"description,omitempty"`
	MedicalInfo  *string  `json:"medicalInfo,omitempty"`
	IsVaccinated *bool    `json:"isVaccinated,omitempty"`
	IsNeutered   *bool    `json:"isNeutered,omitempty"`
	IsTrained    *bool    `json:"isTrained,omitempty"`
	AdoptionFee  *float64 `json:"adoptionFee,omitempty"`
	Status       *string  `json:"status,omitempty"`
	ContactPhone *string  `json:"contactPhone,omitempty"`
}

// ─── Event Request/Response ─────────────────────────────────────

type CreateEventRequest struct {
	Title           string   `json:"title" binding:"required,min=1,max=255"`
	Description     string   `json:"description" binding:"required,min=1"`
	EventType       string   `json:"eventType" binding:"omitempty,oneof=meetup adoption_drive training competition charity other"`
	ImageURL        *string  `json:"imageUrl,omitempty"`
	Location        *string  `json:"location,omitempty"`
	LocationLat     *float64 `json:"locationLat,omitempty"`
	LocationLng     *float64 `json:"locationLng,omitempty"`
	StartDate       string   `json:"startDate" binding:"required"` // ISO 8601
	EndDate         *string  `json:"endDate,omitempty"`
	MaxAttendees    *int     `json:"maxAttendees,omitempty"`
	IsPetFriendly   bool     `json:"isPetFriendly"`
	PetTypesAllowed []string `json:"petTypesAllowed,omitempty"`
}

type UpdateEventRequest struct {
	Title       *string `json:"title,omitempty"`
	Description *string `json:"description,omitempty"`
	Location    *string `json:"location,omitempty"`
	Status      *string `json:"status,omitempty"`
}

type RSVPRequest struct {
	Status string `json:"status" binding:"required,oneof=going interested"`
}

// ─── Vet Appointment Request/Response ───────────────────────────

type CreateVetAppointmentRequest struct {
	VetUserID           uuid.UUID `json:"vetUserId" binding:"required"`
	PetID               uuid.UUID `json:"petId" binding:"required"`
	AppointmentDatetime string    `json:"appointmentDatetime" binding:"required"` // ISO 8601
	DurationMinutes     int       `json:"durationMinutes"`
	MeetingType         string    `json:"meetingType" binding:"omitempty"`
	Reason              string    `json:"reason" binding:"required,min=3"`
	Symptoms            *string   `json:"symptoms,omitempty"`
	OwnerNotes          *string   `json:"ownerNotes,omitempty"`
	ClinicAddress       *string   `json:"clinicAddress,omitempty"`
}

type RespondVetAppointmentRequest struct {
	Accept              bool    `json:"accept"`
	ResponseNote        *string `json:"responseNote,omitempty"`
	AppointmentDatetime *string `json:"appointmentDatetime,omitempty"` // ISO 8601; optional reschedule by vet
	MeetingLink         *string `json:"meetingLink,omitempty"`
}

type CancelVetAppointmentRequest struct {
	Reason string `json:"reason" binding:"required"`
}

type CompleteVetAppointmentRequest struct {
	ResponseNote *string `json:"responseNote,omitempty"`
}

// ─── Community Advanced Features Request/Response ───────────────

type CreateCommunityGroupRequest struct {
	Name        string  `json:"name" binding:"required,min=3,max=80"`
	Description *string `json:"description,omitempty"`
	Icon        *string `json:"icon,omitempty"`
	IsPrivate   bool    `json:"isPrivate"`
}

type AddPostToGroupRequest struct {
	PostID uuid.UUID `json:"postId" binding:"required"`
}

// =====================================================
// CAREGIVER MODULE REQUEST/RESPONSE TYPES
// =====================================================

// CreateCaregiverProfileRequest represents a request to create caregiver profile
type CreateCaregiverProfileRequest struct {
	Bio                  *string  `json:"bio,omitempty"`
	YearsOfExperience    int      `json:"yearsOfExperience"`
	Headline             *string  `json:"headline,omitempty"`
	Address              *string  `json:"address,omitempty"`
	City                 *string  `json:"city,omitempty"`
	State                *string  `json:"state,omitempty"`
	PostalCode           *string  `json:"postalCode,omitempty"`
	Country              string   `json:"country"`
	Latitude             *float64 `json:"latitude,omitempty"`
	Longitude            *float64 `json:"longitude,omitempty"`
	ServiceRadiusKm      int      `json:"serviceRadiusKm"`
	AcceptedPetTypes     []string `json:"acceptedPetTypes"`
	AcceptedPetSizes     []string `json:"acceptedPetSizes"`
	MaxPetsAtOnce        int      `json:"maxPetsAtOnce"`
	HasFencedYard        bool     `json:"hasFencedYard"`
	HasOwnTransport      bool     `json:"hasOwnTransport"`
	SmokeFreeHome        bool     `json:"smokeFreeHome"`
	HasChildren          bool     `json:"hasChildren"`
	HasOtherPets         bool     `json:"hasOtherPets"`
	OtherPetsDescription *string  `json:"otherPetsDescription,omitempty"`
	Certifications       []string `json:"certifications,omitempty"`
	PetFirstAidCertified bool     `json:"petFirstAidCertified"`
}

// UpdateCaregiverProfileRequest represents a request to update caregiver profile
type UpdateCaregiverProfileRequest struct {
	Bio                  *string  `json:"bio,omitempty"`
	YearsOfExperience    *int     `json:"yearsOfExperience,omitempty"`
	Headline             *string  `json:"headline,omitempty"`
	Address              *string  `json:"address,omitempty"`
	City                 *string  `json:"city,omitempty"`
	State                *string  `json:"state,omitempty"`
	PostalCode           *string  `json:"postalCode,omitempty"`
	Latitude             *float64 `json:"latitude,omitempty"`
	Longitude            *float64 `json:"longitude,omitempty"`
	ServiceRadiusKm      *int     `json:"serviceRadiusKm,omitempty"`
	AcceptedPetTypes     []string `json:"acceptedPetTypes,omitempty"`
	AcceptedPetSizes     []string `json:"acceptedPetSizes,omitempty"`
	MaxPetsAtOnce        *int     `json:"maxPetsAtOnce,omitempty"`
	HasFencedYard        *bool    `json:"hasFencedYard,omitempty"`
	HasOwnTransport      *bool    `json:"hasOwnTransport,omitempty"`
	SmokeFreeHome        *bool    `json:"smokeFreeHome,omitempty"`
	HasChildren          *bool    `json:"hasChildren,omitempty"`
	HasOtherPets         *bool    `json:"hasOtherPets,omitempty"`
	OtherPetsDescription *string  `json:"otherPetsDescription,omitempty"`
	IsAcceptingBookings  *bool    `json:"isAcceptingBookings,omitempty"`
}

// AddCaregiverServiceRequest represents a request to add a service
type AddCaregiverServiceRequest struct {
	ServiceTypeID     uuid.UUID `json:"serviceTypeId" binding:"required"`
	RateType          string    `json:"rateType" binding:"required,oneof=hourly per_visit daily per_walk"`
	RateAmount        float64   `json:"rateAmount" binding:"required,min=0"`
	Currency          string    `json:"currency"`
	Description       *string   `json:"description,omitempty"`
	DurationMinutes   *int      `json:"durationMinutes,omitempty"`
	Includes          []string  `json:"includes,omitempty"`
	AdditionalPetRate float64   `json:"additionalPetRate"`
}

// UpdateCaregiverServiceRequest represents a request to update a service
type UpdateCaregiverServiceRequest struct {
	RateType          *string  `json:"rateType,omitempty"`
	RateAmount        *float64 `json:"rateAmount,omitempty"`
	Description       *string  `json:"description,omitempty"`
	DurationMinutes   *int     `json:"durationMinutes,omitempty"`
	Includes          []string `json:"includes,omitempty"`
	AdditionalPetRate *float64 `json:"additionalPetRate,omitempty"`
	IsAvailable       *bool    `json:"isAvailable,omitempty"`
}

// SetCaregiverAvailabilityRequest represents availability slots
type SetCaregiverAvailabilityRequest struct {
	Slots []AvailabilitySlot `json:"slots" binding:"required"`
}

// AvailabilitySlot represents a single availability time slot
type AvailabilitySlot struct {
	DayOfWeek   int    `json:"dayOfWeek" binding:"min=0,max=6"`
	StartTime   string `json:"startTime" binding:"required"` // HH:MM format
	EndTime     string `json:"endTime" binding:"required"`
	IsAvailable bool   `json:"isAvailable"`
}

// AddBlockedDateRequest represents a request to block a date
type AddBlockedDateRequest struct {
	BlockedDate string  `json:"blockedDate" binding:"required"` // YYYY-MM-DD
	Reason      *string `json:"reason,omitempty"`
}

// CreateBookingRequest represents a request to create a booking
type CreateBookingRequest struct {
	CaregiverID           uuid.UUID   `json:"caregiverId" binding:"required"`
	ServiceID             uuid.UUID   `json:"serviceId" binding:"required"`
	PetIDs                []uuid.UUID `json:"petIds" binding:"required,min=1"`
	StartDatetime         string      `json:"startDatetime" binding:"required"` // ISO 8601
	EndDatetime           string      `json:"endDatetime" binding:"required"`
	ServiceLocationType   string      `json:"serviceLocationType" binding:"required,oneof=owner_home caregiver_home pickup_location outdoor"`
	ServiceAddress        *string     `json:"serviceAddress,omitempty"`
	ServiceLatitude       *float64    `json:"serviceLatitude,omitempty"`
	ServiceLongitude      *float64    `json:"serviceLongitude,omitempty"`
	SpecialInstructions   *string     `json:"specialInstructions,omitempty"`
	EmergencyContactName  *string     `json:"emergencyContactName,omitempty"`
	EmergencyContactPhone *string     `json:"emergencyContactPhone,omitempty"`
}

// RespondToBookingRequest represents caregiver response to booking
type RespondToBookingRequest struct {
	Accept bool    `json:"accept"`
	Reason *string `json:"reason,omitempty"` // Required if declining
}

// CancelBookingRequest represents a booking cancellation
type CancelBookingRequest struct {
	Reason string `json:"reason" binding:"required"`
}

// StartServiceRequest represents starting a service
type StartServiceRequest struct {
	Latitude  *float64 `json:"latitude,omitempty"`
	Longitude *float64 `json:"longitude,omitempty"`
}

// UpdateTrackingRequest represents GPS tracking update
type UpdateTrackingRequest struct {
	Latitude       float64  `json:"latitude" binding:"required"`
	Longitude      float64  `json:"longitude" binding:"required"`
	AccuracyMeters *float64 `json:"accuracyMeters,omitempty"`
	ActivityType   *string  `json:"activityType,omitempty"`
	Note           *string  `json:"note,omitempty"`
}

// SubmitCompletionReportRequest represents service completion report
type SubmitCompletionReportRequest struct {
	Summary               string   `json:"summary" binding:"required"`
	ActivitiesPerformed   []string `json:"activitiesPerformed,omitempty"`
	FeedingNotes          *string  `json:"feedingNotes,omitempty"`
	BathroomNotes         *string  `json:"bathroomNotes,omitempty"`
	BehaviorNotes         *string  `json:"behaviorNotes,omitempty"`
	HealthObservations    *string  `json:"healthObservations,omitempty"`
	PhotoURLs             []string `json:"photoUrls,omitempty"`
	VideoURLs             []string `json:"videoUrls,omitempty"`
	ActualDurationMinutes *int     `json:"actualDurationMinutes,omitempty"`
	DistanceWalkedKm      *float64 `json:"distanceWalkedKm,omitempty"`
}

// SubmitOwnerReviewRequest represents owner's review of service
type SubmitOwnerReviewRequest struct {
	OverallRating       int     `json:"overallRating" binding:"required,min=1,max=5"`
	CommunicationRating *int    `json:"communicationRating,omitempty" binding:"omitempty,min=1,max=5"`
	ReliabilityRating   *int    `json:"reliabilityRating,omitempty" binding:"omitempty,min=1,max=5"`
	CareQualityRating   *int    `json:"careQualityRating,omitempty" binding:"omitempty,min=1,max=5"`
	Review              *string `json:"review,omitempty"`
}

// SubmitCaregiverReviewRequest represents caregiver's review of owner/pet
type SubmitCaregiverReviewRequest struct {
	OverallRating     int     `json:"overallRating" binding:"required,min=1,max=5"`
	PetBehaviorRating *int    `json:"petBehaviorRating,omitempty" binding:"omitempty,min=1,max=5"`
	Review            *string `json:"review,omitempty"`
}

// ReportIncidentRequest represents an incident report
type ReportIncidentRequest struct {
	IncidentType        string   `json:"incidentType" binding:"required,oneof=injury_pet injury_caregiver pet_escape property_damage behavioral_issue medical_emergency service_quality safety_concern other"`
	Severity            string   `json:"severity" binding:"required,oneof=low medium high critical"`
	Description         string   `json:"description" binding:"required"`
	OccurredAt          string   `json:"occurredAt" binding:"required"` // ISO 8601
	LocationDescription *string  `json:"locationDescription,omitempty"`
	PhotoURLs           []string `json:"photoUrls,omitempty"`
	VideoURLs           []string `json:"videoUrls,omitempty"`
}

// ProcessPaymentRequest represents payment processing
type ProcessPaymentRequest struct {
	PaymentMethod string `json:"paymentMethod" binding:"required,oneof=card wallet bank_transfer cash jazzcash easypaisa"`
	PaymentType   string `json:"paymentType" binding:"required,oneof=deposit final tip"`
}

// SearchCaregiversRequest represents caregiver search filters
type SearchCaregiversRequest struct {
	ServiceType   *string  `json:"serviceType,omitempty"`
	City          *string  `json:"city,omitempty"`
	Latitude      *float64 `json:"latitude,omitempty"`
	Longitude     *float64 `json:"longitude,omitempty"`
	RadiusKm      *int     `json:"radiusKm,omitempty"`
	PetType       *string  `json:"petType,omitempty"`
	PetSize       *string  `json:"petSize,omitempty"`
	MinRating     *float64 `json:"minRating,omitempty"`
	MaxRate       *float64 `json:"maxRate,omitempty"`
	VerifiedOnly  bool     `json:"verifiedOnly"`
	AvailableDate *string  `json:"availableDate,omitempty"` // YYYY-MM-DD
	Page          int      `json:"page"`
	Limit         int      `json:"limit"`
}
