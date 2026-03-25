package handlers

import (
	"net/http"
	"strconv"
	"time"

	"pawpal-backend/internal/models"
	"pawpal-backend/internal/repositories"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// CaregiverHandler handles caregiver-related requests
type CaregiverHandler struct {
	repo        *repositories.CaregiverRepository
	bookingRepo *repositories.BookingRepository
	userRepo    *repositories.UserRepository
}

// NewCaregiverHandler creates a new caregiver handler
func NewCaregiverHandler(repo *repositories.CaregiverRepository, bookingRepo *repositories.BookingRepository, userRepo *repositories.UserRepository) *CaregiverHandler {
	return &CaregiverHandler{
		repo:        repo,
		bookingRepo: bookingRepo,
		userRepo:    userRepo,
	}
}

// GetServiceTypes returns all available service types
// GET /api/v1/caregivers/service-types
func (h *CaregiverHandler) GetServiceTypes(c *gin.Context) {
	types, err := h.repo.GetServiceTypes(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch service types"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"serviceTypes": types})
}

// CreateProfile creates a new caregiver profile
// POST /api/v1/caregivers/profile
func (h *CaregiverHandler) CreateProfile(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	var req models.CreateCaregiverProfileRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	uid, err := uuid.Parse(userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid user ID"})
		return
	}

	// Check if profile already exists
	existing, err := h.repo.GetProfileByUserID(c.Request.Context(), uid)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to check existing profile"})
		return
	}
	if existing != nil {
		c.JSON(http.StatusConflict, gin.H{"error": "Caregiver profile already exists"})
		return
	}

	// Update user role to caregiver
	err = h.userRepo.SetUserRole(c.Request.Context(), uid, "caregiver")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update user role"})
		return
	}

	profile := &models.CaregiverProfile{
		UserID:               uid,
		Bio:                  req.Bio,
		YearsOfExperience:    req.YearsOfExperience,
		Headline:             req.Headline,
		Address:              req.Address,
		City:                 req.City,
		State:                req.State,
		PostalCode:           req.PostalCode,
		Country:              req.Country,
		Latitude:             req.Latitude,
		Longitude:            req.Longitude,
		ServiceRadiusKm:      req.ServiceRadiusKm,
		AcceptedPetTypes:     req.AcceptedPetTypes,
		AcceptedPetSizes:     req.AcceptedPetSizes,
		MaxPetsAtOnce:        req.MaxPetsAtOnce,
		HasFencedYard:        req.HasFencedYard,
		HasOwnTransport:      req.HasOwnTransport,
		SmokeFreeHome:        req.SmokeFreeHome,
		HasChildren:          req.HasChildren,
		HasOtherPets:         req.HasOtherPets,
		OtherPetsDescription: req.OtherPetsDescription,
		Certifications:       req.Certifications,
		PetFirstAidCertified: req.PetFirstAidCertified,
	}

	if err := h.repo.CreateProfile(c.Request.Context(), profile); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create profile"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"profile": profile})
}

// GetProfile returns the current user's caregiver profile
// GET /api/v1/caregivers/profile
func (h *CaregiverHandler) GetProfile(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	uid, err := uuid.Parse(userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid user ID"})
		return
	}

	profile, err := h.repo.GetProfileByUserID(c.Request.Context(), uid)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch profile"})
		return
	}
	if profile == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Profile not found"})
		return
	}

	// Get services
	services, err := h.repo.GetServicesByCaregiver(c.Request.Context(), profile.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch services"})
		return
	}

	// Get availability
	availability, err := h.repo.GetAvailability(c.Request.Context(), profile.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch availability"})
		return
	}

	// Get gallery
	gallery, err := h.repo.GetGallery(c.Request.Context(), profile.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch gallery"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"profile":      profile,
		"services":     services,
		"availability": availability,
		"gallery":      gallery,
	})
}

// GetCaregiverByID returns a caregiver profile by ID (public view)
// GET /api/v1/caregivers/:id
func (h *CaregiverHandler) GetCaregiverByID(c *gin.Context) {
	idStr := c.Param("id")
	profileID, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid caregiver ID"})
		return
	}

	profile, err := h.repo.GetProfileByID(c.Request.Context(), profileID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch profile"})
		return
	}
	if profile == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Caregiver not found"})
		return
	}

	// Get services
	services, err := h.repo.GetServicesByCaregiver(c.Request.Context(), profile.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch services"})
		return
	}

	// Get availability
	availability, err := h.repo.GetAvailability(c.Request.Context(), profile.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch availability"})
		return
	}

	// Get gallery
	gallery, err := h.repo.GetGallery(c.Request.Context(), profile.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch gallery"})
		return
	}

	// Get reviews
	reviews, total, err := h.bookingRepo.GetReviewsForCaregiver(c.Request.Context(), profile.UserID, 1, 5)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch reviews"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"profile":      profile,
		"services":     services,
		"availability": availability,
		"gallery":      gallery,
		"reviews":      reviews,
		"totalReviews": total,
	})
}

// UpdateProfile updates the current user's caregiver profile
// PUT /api/v1/caregivers/profile
func (h *CaregiverHandler) UpdateProfile(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	uid, err := uuid.Parse(userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid user ID"})
		return
	}

	var req models.UpdateCaregiverProfileRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	profile, err := h.repo.GetProfileByUserID(c.Request.Context(), uid)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch profile"})
		return
	}
	if profile == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Profile not found"})
		return
	}

	if err := h.repo.UpdateProfile(c.Request.Context(), profile.ID, &req); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update profile"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Profile updated successfully"})
}

// AddService adds a new service to the caregiver's offerings
// POST /api/v1/caregivers/services
func (h *CaregiverHandler) AddService(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	uid, err := uuid.Parse(userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid user ID"})
		return
	}

	var req models.AddCaregiverServiceRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	profile, err := h.repo.GetProfileByUserID(c.Request.Context(), uid)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch profile"})
		return
	}
	if profile == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Caregiver profile not found"})
		return
	}

	service := &models.CaregiverService{
		CaregiverID:       profile.ID,
		ServiceTypeID:     req.ServiceTypeID,
		RateType:          req.RateType,
		RateAmount:        req.RateAmount,
		Currency:          req.Currency,
		Description:       req.Description,
		DurationMinutes:   req.DurationMinutes,
		Includes:          req.Includes,
		AdditionalPetRate: req.AdditionalPetRate,
	}

	if err := h.repo.AddService(c.Request.Context(), service); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to add service"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"service": service})
}

// UpdateService updates a caregiver service
// PUT /api/v1/caregivers/services/:id
func (h *CaregiverHandler) UpdateService(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	uid, err := uuid.Parse(userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid user ID"})
		return
	}

	serviceIDStr := c.Param("id")
	serviceID, err := uuid.Parse(serviceIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid service ID"})
		return
	}

	var req models.UpdateCaregiverServiceRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Verify ownership
	profile, err := h.repo.GetProfileByUserID(c.Request.Context(), uid)
	if err != nil || profile == nil {
		c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
		return
	}

	if err := h.repo.UpdateService(c.Request.Context(), serviceID, &req); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update service"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Service updated successfully"})
}

// DeleteService removes a service from the caregiver's offerings
// DELETE /api/v1/caregivers/services/:id
func (h *CaregiverHandler) DeleteService(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	uid, err := uuid.Parse(userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid user ID"})
		return
	}

	serviceIDStr := c.Param("id")
	serviceID, err := uuid.Parse(serviceIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid service ID"})
		return
	}

	// Verify ownership
	profile, err := h.repo.GetProfileByUserID(c.Request.Context(), uid)
	if err != nil || profile == nil {
		c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
		return
	}

	if err := h.repo.DeleteService(c.Request.Context(), serviceID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete service"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Service deleted successfully"})
}

// SetAvailability sets the weekly availability schedule
// PUT /api/v1/caregivers/availability
func (h *CaregiverHandler) SetAvailability(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	uid, err := uuid.Parse(userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid user ID"})
		return
	}

	var req models.SetCaregiverAvailabilityRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	profile, err := h.repo.GetProfileByUserID(c.Request.Context(), uid)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch profile"})
		return
	}
	if profile == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Caregiver profile not found"})
		return
	}

	if err := h.repo.SetAvailability(c.Request.Context(), profile.ID, req.Slots); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to set availability"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Availability updated successfully"})
}

// GetAvailability returns the weekly availability schedule for current user
// GET /api/v1/caregivers/availability
func (h *CaregiverHandler) GetAvailability(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	uid, err := uuid.Parse(userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid user ID"})
		return
	}

	profile, err := h.repo.GetProfileByUserID(c.Request.Context(), uid)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch profile"})
		return
	}
	if profile == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Caregiver profile not found"})
		return
	}

	availability, err := h.repo.GetAvailability(c.Request.Context(), profile.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch availability"})
		return
	}

	blockedDates, err := h.repo.GetBlockedDates(c.Request.Context(), profile.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch blocked dates"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"availability": availability,
		"blockedDates": blockedDates,
	})
}

// AddBlockedDate blocks a specific date
// POST /api/v1/caregivers/blocked-dates
func (h *CaregiverHandler) AddBlockedDate(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	uid, err := uuid.Parse(userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid user ID"})
		return
	}

	var req models.AddBlockedDateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	profile, err := h.repo.GetProfileByUserID(c.Request.Context(), uid)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch profile"})
		return
	}
	if profile == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Caregiver profile not found"})
		return
	}

	date, err := time.Parse("2006-01-02", req.BlockedDate)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid date format. Use YYYY-MM-DD"})
		return
	}

	if err := h.repo.AddBlockedDate(c.Request.Context(), profile.ID, date, req.Reason); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to add blocked date"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "Date blocked successfully"})
}

// RemoveBlockedDate removes a blocked date
// DELETE /api/v1/caregivers/blocked-dates/:date
func (h *CaregiverHandler) RemoveBlockedDate(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	uid, err := uuid.Parse(userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid user ID"})
		return
	}

	dateStr := c.Param("date")
	date, err := time.Parse("2006-01-02", dateStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid date format. Use YYYY-MM-DD"})
		return
	}

	profile, err := h.repo.GetProfileByUserID(c.Request.Context(), uid)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch profile"})
		return
	}
	if profile == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Caregiver profile not found"})
		return
	}

	if err := h.repo.RemoveBlockedDate(c.Request.Context(), profile.ID, date); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to remove blocked date"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Blocked date removed successfully"})
}

// SearchCaregivers searches for caregivers based on filters
// GET /api/v1/caregivers/search
func (h *CaregiverHandler) SearchCaregivers(c *gin.Context) {
	var req models.SearchCaregiversRequest

	// Parse query parameters
	if city := c.Query("city"); city != "" {
		req.City = &city
	}
	if petType := c.Query("petType"); petType != "" {
		req.PetType = &petType
	}
	if petSize := c.Query("petSize"); petSize != "" {
		req.PetSize = &petSize
	}
	if lat := c.Query("latitude"); lat != "" {
		if latF, err := strconv.ParseFloat(lat, 64); err == nil {
			req.Latitude = &latF
		}
	}
	if lng := c.Query("longitude"); lng != "" {
		if lngF, err := strconv.ParseFloat(lng, 64); err == nil {
			req.Longitude = &lngF
		}
	}
	if radius := c.Query("radius"); radius != "" {
		if r, err := strconv.Atoi(radius); err == nil {
			req.RadiusKm = &r
		}
	}
	if minRating := c.Query("minRating"); minRating != "" {
		if mr, err := strconv.ParseFloat(minRating, 64); err == nil {
			req.MinRating = &mr
		}
	}
	if c.Query("verifiedOnly") == "true" {
		req.VerifiedOnly = true
	}
	if page := c.Query("page"); page != "" {
		if p, err := strconv.Atoi(page); err == nil {
			req.Page = p
		}
	}
	if limit := c.Query("limit"); limit != "" {
		if l, err := strconv.Atoi(limit); err == nil {
			req.Limit = l
		}
	}

	caregivers, total, err := h.repo.SearchCaregivers(c.Request.Context(), &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to search caregivers"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"caregivers": caregivers,
		"total":      total,
		"page":       req.Page,
		"limit":      req.Limit,
	})
}

// AddGalleryImage adds an image to the caregiver's gallery
// POST /api/v1/caregivers/gallery
func (h *CaregiverHandler) AddGalleryImage(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	uid, err := uuid.Parse(userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid user ID"})
		return
	}

	var req struct {
		ImageURL  string  `json:"imageUrl" binding:"required"`
		Caption   *string `json:"caption,omitempty"`
		IsPrimary bool    `json:"isPrimary"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	profile, err := h.repo.GetProfileByUserID(c.Request.Context(), uid)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch profile"})
		return
	}
	if profile == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Caregiver profile not found"})
		return
	}

	image, err := h.repo.AddGalleryImage(c.Request.Context(), profile.ID, req.ImageURL, req.Caption, req.IsPrimary)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to add gallery image"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"image": image})
}

// DeleteGalleryImage removes an image from the gallery
// DELETE /api/v1/caregivers/gallery/:id
func (h *CaregiverHandler) DeleteGalleryImage(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	uid, err := uuid.Parse(userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid user ID"})
		return
	}

	imageIDStr := c.Param("id")
	imageID, err := uuid.Parse(imageIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid image ID"})
		return
	}

	// Verify ownership
	profile, err := h.repo.GetProfileByUserID(c.Request.Context(), uid)
	if err != nil || profile == nil {
		c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
		return
	}

	if err := h.repo.DeleteGalleryImage(c.Request.Context(), imageID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete image"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Image deleted successfully"})
}

// GetReviews returns reviews for a caregiver
// GET /api/v1/caregivers/:id/reviews
func (h *CaregiverHandler) GetReviews(c *gin.Context) {
	idStr := c.Param("id")
	profileID, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid caregiver ID"})
		return
	}

	profile, err := h.repo.GetProfileByID(c.Request.Context(), profileID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch profile"})
		return
	}
	if profile == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Caregiver not found"})
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	reviews, total, err := h.bookingRepo.GetReviewsForCaregiver(c.Request.Context(), profile.UserID, page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch reviews"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"reviews": reviews,
		"total":   total,
		"page":    page,
		"limit":   limit,
	})
}
