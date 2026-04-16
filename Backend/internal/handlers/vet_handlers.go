package handlers

import (
	"errors"
	"net/http"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgconn"

	"pawpal-backend/internal/models"
	"pawpal-backend/internal/repositories"
	"pawpal-backend/internal/utils"
)

// VetHandlers handles vet-related endpoints
type VetHandlers struct {
	vetRepo *repositories.VetRepository
}

// NewVetHandlers creates new VetHandlers
func NewVetHandlers(vetRepo *repositories.VetRepository) *VetHandlers {
	return &VetHandlers{
		vetRepo: vetRepo,
	}
}

// CreateVetProfile creates or updates a vet profile
func (h *VetHandlers) CreateVetProfile(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "error": "User not authenticated"})
		return
	}

	userUUID, err := uuid.Parse(userID.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid user ID"})
		return
	}

	// Check if user is a vet
	isVet, err := h.vetRepo.CheckUserIsVet(c.Request.Context(), userUUID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to verify user role"})
		return
	}

	if !isVet {
		c.JSON(http.StatusForbidden, gin.H{"success": false, "error": "Only veterinarians can create vet profiles"})
		return
	}

	var req struct {
		FullName          string   `json:"fullName" binding:"required"`
		Degree            string   `json:"degree" binding:"required"`
		LicenseNumber     *string  `json:"licenseNumber"`
		Specialization    []string `json:"specialization"`
		Experience        int      `json:"experience" binding:"required"`
		ClinicName        *string  `json:"clinicName"`
		ClinicAddress     *string  `json:"clinicAddress"`
		City              *string  `json:"city"`
		State             *string  `json:"state"`
		ZipCode           *string  `json:"zipCode"`
		Phone             string   `json:"phone" binding:"required"`
		ConsultationFee   float64  `json:"consultationFee" binding:"required"`
		Currency          string   `json:"currency"`
		Bio               *string  `json:"bio"`
		ProfilePhotoURL   *string  `json:"profilePhotoUrl"`
		ProfilePhotoBytes *string  `json:"profilePhotoBytes"`
		AvailabilityHours *string  `json:"availabilityHours"`
		IsAvailable       *bool    `json:"isAvailable"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": err.Error()})
		return
	}

	req.FullName = strings.TrimSpace(req.FullName)
	req.Degree = strings.TrimSpace(req.Degree)
	req.Phone = strings.TrimSpace(req.Phone)
	req.Currency = strings.ToUpper(strings.TrimSpace(req.Currency))

	if req.FullName == "" {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Full name is required"})
		return
	}
	if req.Degree == "" {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Degree is required"})
		return
	}
	if req.Phone == "" {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Phone number is required"})
		return
	}
	if req.Experience < 0 {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Experience cannot be negative"})
		return
	}
	if req.ConsultationFee < 0 {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Consultation fee cannot be negative"})
		return
	}

	req.LicenseNumber = sanitizeOptionalText(req.LicenseNumber)
	req.ClinicName = sanitizeOptionalText(req.ClinicName)
	req.ClinicAddress = sanitizeOptionalText(req.ClinicAddress)
	req.City = sanitizeOptionalText(req.City)
	req.State = sanitizeOptionalText(req.State)
	req.ZipCode = sanitizeOptionalText(req.ZipCode)
	req.Bio = sanitizeOptionalText(req.Bio)
	req.ProfilePhotoURL = sanitizeOptionalText(req.ProfilePhotoURL)
	req.ProfilePhotoBytes = sanitizeOptionalText(req.ProfilePhotoBytes)
	req.AvailabilityHours = sanitizeOptionalText(req.AvailabilityHours)
	req.Specialization = sanitizeStringList(req.Specialization)

	if req.ProfilePhotoURL != nil {
		resolved, resolveErr := utils.ResolveImageReference(c.Request.Context(), *req.ProfilePhotoURL, "vet-profiles/"+userUUID.String())
		if resolveErr != nil {
			c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid profilePhotoUrl. Provide an HTTP URL or valid base64 image payload"})
			return
		}
		req.ProfilePhotoURL = sanitizeOptionalText(&resolved)
	}

	if req.ProfilePhotoURL == nil && req.ProfilePhotoBytes != nil {
		resolved, resolveErr := utils.ResolveImageReference(c.Request.Context(), *req.ProfilePhotoBytes, "vet-profiles/"+userUUID.String())
		if resolveErr != nil {
			c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid profilePhotoBytes. Provide a valid base64 image payload"})
			return
		}
		req.ProfilePhotoURL = sanitizeOptionalText(&resolved)
	}

	// Set defaults
	if req.Currency == "" {
		req.Currency = "USD"
	}
	isAvailable := true
	if req.IsAvailable != nil {
		isAvailable = *req.IsAvailable
	}

	vetProfile := models.VetProfile{
		UserID:            userUUID,
		FullName:          req.FullName,
		Degree:            req.Degree,
		LicenseNumber:     req.LicenseNumber,
		Specialization:    req.Specialization,
		Experience:        req.Experience,
		ClinicName:        req.ClinicName,
		ClinicAddress:     req.ClinicAddress,
		City:              req.City,
		State:             req.State,
		ZipCode:           req.ZipCode,
		Phone:             req.Phone,
		ConsultationFee:   req.ConsultationFee,
		Currency:          req.Currency,
		Bio:               req.Bio,
		ProfilePhotoURL:   req.ProfilePhotoURL,
		AvailabilityHours: req.AvailabilityHours,
		IsAvailable:       isAvailable,
	}

	if err := h.vetRepo.CreateOrUpdate(c.Request.Context(), &vetProfile); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to save vet profile", "details": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success":    true,
		"message":    "Vet profile saved successfully",
		"vetProfile": vetProfile,
	})
}

// GetVetProfile gets a vet profile by user ID
func (h *VetHandlers) GetVetProfile(c *gin.Context) {
	vetUserID := c.Param("userId")
	vetUUID, err := uuid.Parse(vetUserID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid vet user ID"})
		return
	}

	var vetProfile models.VetProfile
	err = h.vetRepo.GetByUserID(c.Request.Context(), vetUUID, &vetProfile)
	if err != nil {
		if err.Error() == "no rows in result set" {
			c.JSON(http.StatusNotFound, gin.H{"success": false, "error": "Vet profile not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to fetch vet profile"})
		return
	}

	if vetProfile.ProfilePhotoURL != nil {
		resolved := utils.ResolveImageReferenceBestEffort(c.Request.Context(), *vetProfile.ProfilePhotoURL, "vet-profiles/"+vetProfile.UserID.String())
		vetProfile.ProfilePhotoURL = sanitizeOptionalText(&resolved)
	}

	c.JSON(http.StatusOK, gin.H{
		"success":    true,
		"vetProfile": vetProfile,
	})
}

// GetMyVetProfile gets the current user's vet profile
func (h *VetHandlers) GetMyVetProfile(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "error": "User not authenticated"})
		return
	}

	userUUID, err := uuid.Parse(userID.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid user ID"})
		return
	}

	var vetProfile models.VetProfile
	err = h.vetRepo.GetByUserID(c.Request.Context(), userUUID, &vetProfile)
	if err != nil {
		if err.Error() == "no rows in result set" {
			c.JSON(http.StatusNotFound, gin.H{"success": false, "error": "Vet profile not found. Please create your profile first."})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to fetch vet profile"})
		return
	}

	if vetProfile.ProfilePhotoURL != nil {
		resolved := utils.ResolveImageReferenceBestEffort(c.Request.Context(), *vetProfile.ProfilePhotoURL, "vet-profiles/"+vetProfile.UserID.String())
		vetProfile.ProfilePhotoURL = sanitizeOptionalText(&resolved)
	}

	c.JSON(http.StatusOK, gin.H{
		"success":    true,
		"vetProfile": vetProfile,
	})
}

// ListVets lists all veterinarians with optional filters
func (h *VetHandlers) ListVets(c *gin.Context) {
	// Query parameters for filtering
	city := c.Query("city")
	specialization := c.Query("specialization")
	minRatingStr := c.DefaultQuery("minRating", "0")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 20
	}

	minRating, _ := strconv.ParseFloat(minRatingStr, 64)
	offset := (page - 1) * limit

	// Build filters map
	filters := make(map[string]interface{})
	if city != "" {
		filters["city"] = city
	}
	if specialization != "" {
		filters["specialization"] = specialization
	}
	if minRating > 0 {
		filters["minRating"] = minRating
	}

	vets, total, err := h.vetRepo.List(c.Request.Context(), filters, limit, offset)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to fetch vets", "details": err.Error()})
		return
	}

	for i := range vets {
		if vets[i].ProfilePhotoURL == nil {
			continue
		}
		resolved := utils.ResolveImageReferenceBestEffort(c.Request.Context(), *vets[i].ProfilePhotoURL, "vet-profiles/"+vets[i].UserID.String())
		vets[i].ProfilePhotoURL = sanitizeOptionalText(&resolved)
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"vets":    vets,
		"pagination": gin.H{
			"page":  page,
			"limit": limit,
			"total": total,
		},
	})
}

// GetVetReviews lists reviews for a vet profile.
func (h *VetHandlers) GetVetReviews(c *gin.Context) {
	vetUserID, err := uuid.Parse(c.Param("userId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid vet user ID"})
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 20
	}

	reviews, total, err := h.vetRepo.GetReviews(c.Request.Context(), vetUserID, page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to fetch vet reviews"})
		return
	}
	if reviews == nil {
		reviews = []models.VetReview{}
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"reviews": reviews,
		"pagination": gin.H{
			"page":  page,
			"limit": limit,
			"total": total,
		},
	})
}

// AddVetReview submits a review for a vet profile.
func (h *VetHandlers) AddVetReview(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "error": "User not authenticated"})
		return
	}

	reviewerID, err := uuid.Parse(userID.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid user ID"})
		return
	}

	vetUserID, err := uuid.Parse(c.Param("userId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid vet user ID"})
		return
	}

	if reviewerID == vetUserID {
		c.JSON(http.StatusForbidden, gin.H{"success": false, "error": "You cannot review your own vet profile"})
		return
	}

	isVet, err := h.vetRepo.CheckUserIsVet(c.Request.Context(), vetUserID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to validate vet profile"})
		return
	}
	if !isVet {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "error": "Vet profile not found"})
		return
	}

	var req struct {
		Rating  int     `json:"rating" binding:"required,min=1,max=5"`
		Comment *string `json:"comment"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": err.Error()})
		return
	}

	if req.Comment != nil {
		trimmed := strings.TrimSpace(*req.Comment)
		if trimmed == "" {
			req.Comment = nil
		} else {
			req.Comment = &trimmed
		}
	}

	hasCompletedAppointment, err := h.vetRepo.UserHasCompletedAppointmentWithVet(c.Request.Context(), reviewerID, vetUserID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to validate review eligibility"})
		return
	}
	if !hasCompletedAppointment {
		c.JSON(http.StatusForbidden, gin.H{"success": false, "error": "You can review a vet only after a completed appointment"})
		return
	}

	review := &models.VetReview{
		VetID:   vetUserID,
		UserID:  reviewerID,
		Rating:  req.Rating,
		Comment: req.Comment,
	}

	if err := h.vetRepo.AddReview(c.Request.Context(), review); err != nil {
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) && pgErr.Code == "23505" {
			c.JSON(http.StatusConflict, gin.H{"success": false, "error": "You have already reviewed this vet"})
			return
		}

		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to submit vet review"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"review":  review,
	})
}

func sanitizeOptionalText(value *string) *string {
	if value == nil {
		return nil
	}

	trimmed := strings.TrimSpace(*value)
	if trimmed == "" {
		return nil
	}

	return &trimmed
}

func sanitizeStringList(values []string) []string {
	if len(values) == 0 {
		return []string{}
	}

	cleaned := make([]string, 0, len(values))
	seen := make(map[string]struct{}, len(values))

	for _, value := range values {
		trimmed := strings.TrimSpace(value)
		if trimmed == "" {
			continue
		}

		key := strings.ToLower(trimmed)
		if _, exists := seen[key]; exists {
			continue
		}

		seen[key] = struct{}{}
		cleaned = append(cleaned, trimmed)
	}

	return cleaned
}
