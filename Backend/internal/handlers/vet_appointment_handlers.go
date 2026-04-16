package handlers

import (
	"net/http"
	"strconv"
	"strings"
	"time"

	"pawpal-backend/internal/models"
	"pawpal-backend/internal/repositories"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// VetAppointmentHandlers handles vet appointment booking/scheduling endpoints.
type VetAppointmentHandlers struct {
	repo    *repositories.VetAppointmentRepository
	vetRepo *repositories.VetRepository
}

// NewVetAppointmentHandlers creates new vet appointment handlers.
func NewVetAppointmentHandlers(repo *repositories.VetAppointmentRepository, vetRepo *repositories.VetRepository) *VetAppointmentHandlers {
	return &VetAppointmentHandlers{
		repo:    repo,
		vetRepo: vetRepo,
	}
}

// CreateAppointment creates a new appointment request by a pet owner.
func (h *VetAppointmentHandlers) CreateAppointment(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "error": "User not authenticated"})
		return
	}

	ownerID, err := uuid.Parse(userID.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid user ID"})
		return
	}

	var req models.CreateVetAppointmentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": err.Error()})
		return
	}

	req.Reason = strings.TrimSpace(req.Reason)
	req.Symptoms = sanitizeOptionalText(req.Symptoms)
	req.OwnerNotes = sanitizeOptionalText(req.OwnerNotes)
	req.ClinicAddress = sanitizeOptionalText(req.ClinicAddress)
	if req.Reason == "" {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Reason is required"})
		return
	}

	if req.VetUserID == ownerID {
		c.JSON(http.StatusForbidden, gin.H{"success": false, "error": "You cannot book a vet appointment with your own account"})
		return
	}

	appointmentDatetime, err := time.Parse(time.RFC3339, req.AppointmentDatetime)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid appointment datetime format"})
		return
	}

	if appointmentDatetime.Before(time.Now().Add(5 * time.Minute)) {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Appointment time must be in the future"})
		return
	}

	isVet, err := h.vetRepo.CheckUserIsVet(c.Request.Context(), req.VetUserID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to validate vet"})
		return
	}
	if !isVet {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Selected user is not a veterinarian"})
		return
	}

	meetingType := strings.TrimSpace(req.MeetingType)
	if meetingType == "" {
		meetingType = "in_person"
	}

	appointment := &models.VetAppointment{
		PetOwnerID:          ownerID,
		VetUserID:           req.VetUserID,
		PetID:               req.PetID,
		Reason:              req.Reason,
		Symptoms:            req.Symptoms,
		OwnerNotes:          req.OwnerNotes,
		AppointmentDatetime: appointmentDatetime,
		DurationMinutes:     req.DurationMinutes,
		MeetingType:         meetingType,
		ClinicAddress:       req.ClinicAddress,
	}

	if err := h.repo.Create(c.Request.Context(), appointment); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"success":     true,
		"message":     "Appointment request created successfully",
		"appointment": appointment,
	})
}

// ListAppointments lists appointments for the logged-in user.
func (h *VetAppointmentHandlers) ListAppointments(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "error": "User not authenticated"})
		return
	}

	uid, err := uuid.Parse(userID.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid user ID"})
		return
	}

	role := strings.ToLower(strings.TrimSpace(c.DefaultQuery("role", "owner")))
	if role != "owner" && role != "vet" {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid role. Use owner or vet"})
		return
	}

	if role == "vet" {
		isVet, err := h.vetRepo.CheckUserIsVet(c.Request.Context(), uid)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to validate vet role"})
			return
		}
		if !isVet {
			c.JSON(http.StatusForbidden, gin.H{"success": false, "error": "Only veterinarians can view vet appointments"})
			return
		}
	}

	status := c.Query("status")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	appointments, total, err := h.repo.ListByUser(c.Request.Context(), uid, role, status, page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to fetch appointments"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success":      true,
		"appointments": appointments,
		"pagination": gin.H{
			"page":  page,
			"limit": limit,
			"total": total,
		},
	})
}

// GetAppointment returns details for a single appointment.
func (h *VetAppointmentHandlers) GetAppointment(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "error": "User not authenticated"})
		return
	}

	uid, err := uuid.Parse(userID.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid user ID"})
		return
	}

	appointmentID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid appointment ID"})
		return
	}

	appointment, err := h.repo.GetByID(c.Request.Context(), appointmentID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to fetch appointment"})
		return
	}
	if appointment == nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "error": "Appointment not found"})
		return
	}

	if appointment.PetOwnerID != uid && appointment.VetUserID != uid {
		c.JSON(http.StatusForbidden, gin.H{"success": false, "error": "Access denied"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success":     true,
		"appointment": appointment,
	})
}

// RespondAppointment lets a vet confirm or decline an appointment request.
func (h *VetAppointmentHandlers) RespondAppointment(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "error": "User not authenticated"})
		return
	}

	vetUserID, err := uuid.Parse(userID.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid user ID"})
		return
	}

	appointmentID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid appointment ID"})
		return
	}

	appointment, err := h.repo.GetByID(c.Request.Context(), appointmentID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to fetch appointment"})
		return
	}
	if appointment == nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "error": "Appointment not found"})
		return
	}

	if appointment.VetUserID != vetUserID {
		c.JSON(http.StatusForbidden, gin.H{"success": false, "error": "Only assigned vet can respond"})
		return
	}

	if appointment.Status != "requested" && appointment.Status != "confirmed" {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Only requested or confirmed appointments can be updated"})
		return
	}

	var req models.RespondVetAppointmentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": err.Error()})
		return
	}

	req.ResponseNote = sanitizeOptionalText(req.ResponseNote)
	req.MeetingLink = sanitizeOptionalText(req.MeetingLink)

	var appointmentDatetime *time.Time
	if req.AppointmentDatetime != nil {
		parsedTime, err := time.Parse(time.RFC3339, strings.TrimSpace(*req.AppointmentDatetime))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid appointmentDatetime format"})
			return
		}
		appointmentDatetime = &parsedTime
	}

	if err := h.repo.Respond(c.Request.Context(), appointmentID, req.Accept, req.ResponseNote, appointmentDatetime, req.MeetingLink); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to respond to appointment"})
		return
	}

	message := "Appointment declined"
	if req.Accept {
		message = "Appointment confirmed"
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": message})
}

// CancelAppointment cancels an appointment by owner or vet.
func (h *VetAppointmentHandlers) CancelAppointment(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "error": "User not authenticated"})
		return
	}

	uid, err := uuid.Parse(userID.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid user ID"})
		return
	}

	appointmentID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid appointment ID"})
		return
	}

	var req models.CancelVetAppointmentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": err.Error()})
		return
	}

	req.Reason = strings.TrimSpace(req.Reason)
	if req.Reason == "" {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Cancellation reason is required"})
		return
	}

	appointment, err := h.repo.GetByID(c.Request.Context(), appointmentID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to fetch appointment"})
		return
	}
	if appointment == nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "error": "Appointment not found"})
		return
	}

	isOwner := appointment.PetOwnerID == uid
	isVet := appointment.VetUserID == uid
	if !isOwner && !isVet {
		c.JSON(http.StatusForbidden, gin.H{"success": false, "error": "Access denied"})
		return
	}

	switch appointment.Status {
	case "completed", "declined", "cancelled_owner", "cancelled_vet":
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Appointment cannot be cancelled in current state"})
		return
	}

	if err := h.repo.Cancel(c.Request.Context(), appointmentID, isVet, req.Reason); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to cancel appointment"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Appointment cancelled"})
}

// CompleteAppointment marks an appointment as completed (vet only).
func (h *VetAppointmentHandlers) CompleteAppointment(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "error": "User not authenticated"})
		return
	}

	vetUserID, err := uuid.Parse(userID.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid user ID"})
		return
	}

	appointmentID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid appointment ID"})
		return
	}

	appointment, err := h.repo.GetByID(c.Request.Context(), appointmentID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to fetch appointment"})
		return
	}
	if appointment == nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "error": "Appointment not found"})
		return
	}

	if appointment.VetUserID != vetUserID {
		c.JSON(http.StatusForbidden, gin.H{"success": false, "error": "Only assigned vet can complete appointment"})
		return
	}

	if appointment.Status != "confirmed" {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Only confirmed appointments can be completed"})
		return
	}

	var req models.CompleteVetAppointmentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": err.Error()})
		return
	}
	req.ResponseNote = sanitizeOptionalText(req.ResponseNote)

	if err := h.repo.Complete(c.Request.Context(), appointmentID, req.ResponseNote); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to complete appointment"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Appointment completed"})
}
