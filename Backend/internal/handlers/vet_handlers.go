package handlers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	"pawpal-backend/internal/models"
	"pawpal-backend/internal/repositories"
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
		AvailabilityHours *string  `json:"availabilityHours"`
		IsAvailable       *bool    `json:"isAvailable"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": err.Error()})
		return
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
