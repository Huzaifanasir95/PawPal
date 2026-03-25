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

// BookingHandler handles booking-related requests
type BookingHandler struct {
	repo         *repositories.BookingRepository
	caregiverRepo *repositories.CaregiverRepository
}

// NewBookingHandler creates a new booking handler
func NewBookingHandler(repo *repositories.BookingRepository, caregiverRepo *repositories.CaregiverRepository) *BookingHandler {
	return &BookingHandler{
		repo:         repo,
		caregiverRepo: caregiverRepo,
	}
}

// CreateBooking creates a new booking request
// POST /api/v1/bookings
func (h *BookingHandler) CreateBooking(c *gin.Context) {
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

	var req models.CreateBookingRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Parse datetimes
	startDatetime, err := time.Parse(time.RFC3339, req.StartDatetime)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid start datetime format"})
		return
	}
	endDatetime, err := time.Parse(time.RFC3339, req.EndDatetime)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid end datetime format"})
		return
	}

	if endDatetime.Before(startDatetime) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "End time must be after start time"})
		return
	}

	// Get caregiver service to calculate pricing
	services, err := h.caregiverRepo.GetServicesByCaregiver(c.Request.Context(), req.CaregiverID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch caregiver services"})
		return
	}

	var selectedService *models.CaregiverService
	for _, s := range services {
		if s.ID == req.ServiceID {
			selectedService = &s
			break
		}
	}
	if selectedService == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Service not found"})
		return
	}

	// Calculate pricing
	durationHours := endDatetime.Sub(startDatetime).Hours()
	var baseAmount float64
	switch selectedService.RateType {
	case "hourly":
		baseAmount = selectedService.RateAmount * durationHours
	case "daily":
		days := durationHours / 24
		if days < 1 {
			days = 1
		}
		baseAmount = selectedService.RateAmount * days
	case "per_visit", "per_walk":
		baseAmount = selectedService.RateAmount
	default:
		baseAmount = selectedService.RateAmount
	}

	// Additional pets fee
	additionalPetsFee := 0.0
	if len(req.PetIDs) > 1 {
		additionalPetsFee = selectedService.AdditionalPetRate * float64(len(req.PetIDs)-1)
	}

	// Platform service fee (e.g., 10%)
	serviceFee := (baseAmount + additionalPetsFee) * 0.10
	totalAmount := baseAmount + additionalPetsFee + serviceFee

	booking := &models.ServiceBooking{
		PetOwnerID:            uid,
		CaregiverID:           req.CaregiverID,
		ServiceID:             req.ServiceID,
		PetIDs:                req.PetIDs,
		StartDatetime:         startDatetime,
		EndDatetime:           endDatetime,
		ServiceLocationType:   req.ServiceLocationType,
		ServiceAddress:        req.ServiceAddress,
		ServiceLatitude:       req.ServiceLatitude,
		ServiceLongitude:      req.ServiceLongitude,
		SpecialInstructions:   req.SpecialInstructions,
		EmergencyContactName:  req.EmergencyContactName,
		EmergencyContactPhone: req.EmergencyContactPhone,
		BaseAmount:            baseAmount,
		AdditionalPetsFee:     additionalPetsFee,
		ServiceFee:            serviceFee,
		TotalAmount:           totalAmount,
		Currency:              "PKR",
	}

	if err := h.repo.CreateBooking(c.Request.Context(), booking); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create booking"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"booking": booking})
}

// GetBooking returns a booking by ID
// GET /api/v1/bookings/:id
func (h *BookingHandler) GetBooking(c *gin.Context) {
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

	bookingIDStr := c.Param("id")
	bookingID, err := uuid.Parse(bookingIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking ID"})
		return
	}

	booking, err := h.repo.GetBookingByID(c.Request.Context(), bookingID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch booking"})
		return
	}
	if booking == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Booking not found"})
		return
	}

	// Verify access (owner or caregiver)
	profile, _ := h.caregiverRepo.GetProfileByUserID(c.Request.Context(), uid)

	if booking.PetOwnerID != uid && (profile == nil || profile.ID != booking.CaregiverID) {
		c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
		return
	}

	// Get tracking points
	tracking, _ := h.repo.GetTrackingPoints(c.Request.Context(), bookingID)

	// Get completion report if exists
	report, _ := h.repo.GetCompletionReport(c.Request.Context(), bookingID)

	// Get incidents if any
	incidents, _ := h.repo.GetIncidentsByBooking(c.Request.Context(), bookingID)

	// Get payments
	payments, _ := h.repo.GetPaymentsByBooking(c.Request.Context(), bookingID)

	c.JSON(http.StatusOK, gin.H{
		"booking":          booking,
		"tracking":         tracking,
		"completionReport": report,
		"incidents":        incidents,
		"payments":         payments,
	})
}

// GetMyBookings returns bookings for the current user
// GET /api/v1/bookings
func (h *BookingHandler) GetMyBookings(c *gin.Context) {
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
	role := c.Query("role") // "owner" or "caregiver"
	status := c.Query("status")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	var statusPtr *string
	if status != "" {
		statusPtr = &status
	}

	var bookings []models.ServiceBooking
	var total int
	var fetchErr error

	if role == "caregiver" {
		profile, profErr := h.caregiverRepo.GetProfileByUserID(c.Request.Context(), uid)
		if profErr != nil || profile == nil {
			c.JSON(http.StatusForbidden, gin.H{"error": "Not a caregiver"})
			return
		}
		bookings, total, fetchErr = h.repo.GetBookingsByCaregiver(c.Request.Context(), profile.ID, statusPtr, page, limit)
	} else {
		bookings, total, fetchErr = h.repo.GetBookingsByOwner(c.Request.Context(), uid, statusPtr, page, limit)
	}

	if fetchErr != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch bookings"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"bookings": bookings,
		"total":    total,
		"page":     page,
		"limit":    limit,
	})
}

// RespondToBooking allows caregiver to accept/decline a booking
// POST /api/v1/bookings/:id/respond
func (h *BookingHandler) RespondToBooking(c *gin.Context) {
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

	bookingIDStr := c.Param("id")
	bookingID, err := uuid.Parse(bookingIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking ID"})
		return
	}

	var req models.RespondToBookingRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	booking, err := h.repo.GetBookingByID(c.Request.Context(), bookingID)
	if err != nil || booking == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Booking not found"})
		return
	}

	// Verify caregiver ownership
	profile, err := h.caregiverRepo.GetProfileByUserID(c.Request.Context(), uid)
	if err != nil || profile == nil || profile.ID != booking.CaregiverID {
		c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
		return
	}

	if booking.Status != "pending" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Booking is not pending"})
		return
	}

	status := "declined"
	if req.Accept {
		status = "accepted"
	}

	if err := h.repo.RespondToBooking(c.Request.Context(), bookingID, status, req.Reason); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to respond to booking"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Booking " + status})
}

// CancelBooking cancels a booking
// POST /api/v1/bookings/:id/cancel
func (h *BookingHandler) CancelBooking(c *gin.Context) {
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

	bookingIDStr := c.Param("id")
	bookingID, err := uuid.Parse(bookingIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking ID"})
		return
	}

	var req models.CancelBookingRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	booking, err := h.repo.GetBookingByID(c.Request.Context(), bookingID)
	if err != nil || booking == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Booking not found"})
		return
	}
	isOwner := booking.PetOwnerID == uid

	if !isOwner {
		// Check if caregiver
		profile, err := h.caregiverRepo.GetProfileByUserID(c.Request.Context(), uid)
		if err != nil || profile == nil || profile.ID != booking.CaregiverID {
			c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
			return
		}
	}

	if booking.Status == "completed" || booking.Status == "cancelled_owner" || booking.Status == "cancelled_caregiver" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Cannot cancel this booking"})
		return
	}

	if err := h.repo.CancelBooking(c.Request.Context(), bookingID, uid, req.Reason, isOwner); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to cancel booking"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Booking cancelled"})
}

// StartService starts the service (caregiver only)
// POST /api/v1/bookings/:id/start
func (h *BookingHandler) StartService(c *gin.Context) {
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

	bookingIDStr := c.Param("id")
	bookingID, err := uuid.Parse(bookingIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking ID"})
		return
	}

	var req models.StartServiceRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	booking, err := h.repo.GetBookingByID(c.Request.Context(), bookingID)
	if err != nil || booking == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Booking not found"})
		return
	}

	// Verify caregiver
	profile, err := h.caregiverRepo.GetProfileByUserID(c.Request.Context(), uid)
	if err != nil || profile == nil || profile.ID != booking.CaregiverID {
		c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
		return
	}

	if booking.Status != "accepted" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Booking is not in accepted status"})
		return
	}

	if err := h.repo.StartService(c.Request.Context(), bookingID, &req.Latitude, &req.Longitude); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to start service"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Service started"})
}

// UpdateTracking adds a tracking point during service
// POST /api/v1/bookings/:id/tracking
func (h *BookingHandler) UpdateTracking(c *gin.Context) {
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

	bookingIDStr := c.Param("id")
	bookingID, err := uuid.Parse(bookingIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking ID"})
		return
	}

	var req models.UpdateTrackingRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	booking, err := h.repo.GetBookingByID(c.Request.Context(), bookingID)
	if err != nil || booking == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Booking not found"})
		return
	}

	// Verify caregiver
	profile, err := h.caregiverRepo.GetProfileByUserID(c.Request.Context(), uid)
	if err != nil || profile == nil || profile.ID != booking.CaregiverID {
		c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
		return
	}

	if booking.Status != "in_progress" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Service is not in progress"})
		return
	}

	tracking := &models.BookingTracking{
		BookingID:      bookingID,
		Latitude:       req.Latitude,
		Longitude:      req.Longitude,
		AccuracyMeters: req.AccuracyMeters,
		ActivityType:   req.ActivityType,
		Note:           req.Note,
	}

	if err := h.repo.AddTrackingPoint(c.Request.Context(), tracking); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to add tracking point"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"tracking": tracking})
}

// GetTracking returns tracking points for a booking
// GET /api/v1/bookings/:id/tracking
func (h *BookingHandler) GetTracking(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	bookingIDStr := c.Param("id")
	bookingID, err := uuid.Parse(bookingIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking ID"})
		return
	}

	booking, err := h.repo.GetBookingByID(c.Request.Context(), bookingID)
	if err != nil || booking == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Booking not found"})
		return
	}

	// Verify access
	uid, err := uuid.Parse(userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid user ID"})
		return
	}
	profile, _ := h.caregiverRepo.GetProfileByUserID(c.Request.Context(), uid)

	if booking.PetOwnerID != uid && (profile == nil || profile.ID != booking.CaregiverID) {
		c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
		return
	}

	tracking, err := h.repo.GetTrackingPoints(c.Request.Context(), bookingID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch tracking"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"tracking": tracking})
}

// SubmitCompletionReport submits the service completion report
// POST /api/v1/bookings/:id/completion-report
func (h *BookingHandler) SubmitCompletionReport(c *gin.Context) {
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

	bookingIDStr := c.Param("id")
	bookingID, err := uuid.Parse(bookingIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking ID"})
		return
	}

	var req models.SubmitCompletionReportRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	booking, err := h.repo.GetBookingByID(c.Request.Context(), bookingID)
	if err != nil || booking == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Booking not found"})
		return
	}

	// Verify caregiver
	profile, err := h.caregiverRepo.GetProfileByUserID(c.Request.Context(), uid)
	if err != nil || profile == nil || profile.ID != booking.CaregiverID {
		c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
		return
	}

	if booking.Status != "in_progress" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Service is not in progress"})
		return
	}

	report := &models.BookingCompletionReport{
		BookingID:           bookingID,
		Summary:             req.Summary,
		ActivitiesPerformed: req.ActivitiesPerformed,
		FeedingNotes:        req.FeedingNotes,
		BathroomNotes:       req.BathroomNotes,
		BehaviorNotes:       req.BehaviorNotes,
		HealthObservations:  req.HealthObservations,
		PhotoURLs:           req.PhotoURLs,
	}

	if err := h.repo.CreateCompletionReport(c.Request.Context(), report); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to submit report"})
		return
	}

	// Mark service as completed
	if err := h.repo.CompleteService(c.Request.Context(), bookingID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to complete service"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Service completed",
		"report":  report,
	})
}

// SubmitOwnerReview submits a review from the pet owner
// POST /api/v1/bookings/:id/review/owner
func (h *BookingHandler) SubmitOwnerReview(c *gin.Context) {
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

	bookingIDStr := c.Param("id")
	bookingID, err := uuid.Parse(bookingIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking ID"})
		return
	}

	var req models.SubmitOwnerReviewRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	booking, err := h.repo.GetBookingByID(c.Request.Context(), bookingID)
	if err != nil || booking == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Booking not found"})
		return
	}

	// Verify owner
	if booking.PetOwnerID != uid {
		c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
		return
	}

	if booking.Status != "completed" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Booking is not completed"})
		return
	}

	err = h.repo.CreateOwnerReview(c.Request.Context(), bookingID, req.OverallRating, req.Review,
		req.CommunicationRating, req.ReliabilityRating, req.CareQualityRating)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to submit review"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "Review submitted"})
}

// SubmitCaregiverReview submits a review from the caregiver
// POST /api/v1/bookings/:id/review/caregiver
func (h *BookingHandler) SubmitCaregiverReview(c *gin.Context) {
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

	bookingIDStr := c.Param("id")
	bookingID, err := uuid.Parse(bookingIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking ID"})
		return
	}

	var req models.SubmitCaregiverReviewRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	booking, err := h.repo.GetBookingByID(c.Request.Context(), bookingID)
	if err != nil || booking == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Booking not found"})
		return
	}

	// Verify caregiver
	profile, err := h.caregiverRepo.GetProfileByUserID(c.Request.Context(), uid)
	if err != nil || profile == nil || profile.ID != booking.CaregiverID {
		c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
		return
	}

	if booking.Status != "completed" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Booking is not completed"})
		return
	}

	err = h.repo.CreateCaregiverReview(c.Request.Context(), bookingID, req.OverallRating, req.Review, req.PetBehaviorRating)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to submit review"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "Review submitted"})
}

// ReportIncident reports an incident during service
// POST /api/v1/bookings/:id/incidents
func (h *BookingHandler) ReportIncident(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	bookingIDStr := c.Param("id")
	bookingID, err := uuid.Parse(bookingIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking ID"})
		return
	}

	var req models.ReportIncidentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	booking, err := h.repo.GetBookingByID(c.Request.Context(), bookingID)
	if err != nil || booking == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Booking not found"})
		return
	}

	uid, err := uuid.Parse(userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid user ID"})
		return
	}
	profile, _ := h.caregiverRepo.GetProfileByUserID(c.Request.Context(), uid)

	// Verify access
	if booking.PetOwnerID != uid && (profile == nil || profile.ID != booking.CaregiverID) {
		c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
		return
	}

	occurredAt := time.Now()
	if req.OccurredAt != "" {
		if t, err := time.Parse(time.RFC3339, req.OccurredAt); err == nil {
			occurredAt = t
		}
	}

	incident := &models.ServiceIncident{
		BookingID:           bookingID,
		ReportedBy:          uid,
		IncidentType:        req.IncidentType,
		Severity:            req.Severity,
		Description:         req.Description,
		OccurredAt:          occurredAt,
		LocationDescription: req.LocationDescription,
		PhotoURLs:           req.PhotoURLs,
	}

	if err := h.repo.CreateIncidentReport(c.Request.Context(), incident); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to report incident"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"incident": incident})
}

// GetIncidents returns incidents for a booking
// GET /api/v1/bookings/:id/incidents
func (h *BookingHandler) GetIncidents(c *gin.Context) {
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

	bookingIDStr := c.Param("id")
	bookingID, err := uuid.Parse(bookingIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking ID"})
		return
	}

	booking, err := h.repo.GetBookingByID(c.Request.Context(), bookingID)
	if err != nil || booking == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Booking not found"})
		return
	}

	profile, _ := h.caregiverRepo.GetProfileByUserID(c.Request.Context(), uid)

	if booking.PetOwnerID != uid && (profile == nil || profile.ID != booking.CaregiverID) {
		c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
		return
	}

	incidents, err := h.repo.GetIncidentsByBooking(c.Request.Context(), bookingID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch incidents"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"incidents": incidents})
}

// ProcessPayment processes a payment for a booking
// POST /api/v1/bookings/:id/payment
func (h *BookingHandler) ProcessPayment(c *gin.Context) {
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

	bookingIDStr := c.Param("id")
	bookingID, err := uuid.Parse(bookingIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking ID"})
		return
	}

	var req models.ProcessPaymentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	booking, err := h.repo.GetBookingByID(c.Request.Context(), bookingID)
	if err != nil || booking == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Booking not found"})
		return
	}

	// Verify owner
	if booking.PetOwnerID != uid {
		c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
		return
	}

	paymentMethod := req.PaymentMethod
	payment := &models.BookingPayment{
		BookingID:     bookingID,
		Amount:        booking.TotalAmount,
		Currency:      booking.Currency,
		PaymentType:   req.PaymentType,
		PaymentMethod: &paymentMethod,
		Status:        "completed",
	}

	if err := h.repo.CreatePayment(c.Request.Context(), payment); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to process payment"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"payment": payment})
}

// GetPayments returns payments for a booking
// GET /api/v1/bookings/:id/payments
func (h *BookingHandler) GetPayments(c *gin.Context) {
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

	bookingIDStr := c.Param("id")
	bookingID, err := uuid.Parse(bookingIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking ID"})
		return
	}

	booking, err := h.repo.GetBookingByID(c.Request.Context(), bookingID)
	if err != nil || booking == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Booking not found"})
		return
	}

	profile, _ := h.caregiverRepo.GetProfileByUserID(c.Request.Context(), uid)

	if booking.PetOwnerID != uid && (profile == nil || profile.ID != booking.CaregiverID) {
		c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
		return
	}

	payments, err := h.repo.GetPaymentsByBooking(c.Request.Context(), bookingID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch payments"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"payments": payments})
}
