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

// AuthResponse represents an authentication response
type AuthResponse struct {
	Success      bool         `json:"success"`
	Message      string       `json:"message,omitempty"`
	User         *UserProfile `json:"user,omitempty"`
	AccessToken  string       `json:"accessToken,omitempty"`
	RefreshToken string       `json:"refreshToken,omitempty"`
	ExpiresIn    int64        `json:"expiresIn,omitempty"` // Token expiry in seconds
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
