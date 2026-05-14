package handlers

import (
	"context"
	"errors"
	"net/http"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"pawpal-backend/internal/models"
	"pawpal-backend/internal/repositories"
	"pawpal-backend/internal/utils"
)

// ChatHandlers handles chat-related endpoints
type ChatHandlers struct {
	chatRepo           *repositories.ChatRepository
	messageRepo        *repositories.MessageRepository
	userRepo           repositories.UserRepository
	vetRepo            *repositories.VetRepository
	bookingRepo        *repositories.BookingRepository
	caregiverRepo      *repositories.CaregiverRepository
	vetAppointmentRepo *repositories.VetAppointmentRepository
}

// NewChatHandlers creates new ChatHandlers
func NewChatHandlers(
	chatRepo *repositories.ChatRepository,
	messageRepo *repositories.MessageRepository,
	userRepo repositories.UserRepository,
	vetRepo *repositories.VetRepository,
	bookingRepo *repositories.BookingRepository,
	caregiverRepo *repositories.CaregiverRepository,
	vetAppointmentRepo *repositories.VetAppointmentRepository,
) *ChatHandlers {
	return &ChatHandlers{
		chatRepo:           chatRepo,
		messageRepo:        messageRepo,
		userRepo:           userRepo,
		vetRepo:            vetRepo,
		bookingRepo:        bookingRepo,
		caregiverRepo:      caregiverRepo,
		vetAppointmentRepo: vetAppointmentRepo,
	}
}

// StartChat creates a new chat between pet owner and vet
func (h *ChatHandlers) StartChat(c *gin.Context) {
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

	var req struct {
		VetID         *uuid.UUID `json:"vetId"`
		PetID         *uuid.UUID `json:"petId"`
		BookingID     *uuid.UUID `json:"bookingId"`
		AppointmentID *uuid.UUID `json:"appointmentId"`
		ChatType      string     `json:"chatType"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": err.Error()})
		return
	}

	if req.VetID == nil && req.BookingID == nil && req.AppointmentID == nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Provide vetId, bookingId, or appointmentId to start a chat"})
		return
	}

	if req.BookingID != nil && req.AppointmentID != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Provide either bookingId or appointmentId, not both"})
		return
	}

	chatType := normalizeRequestedChatType(req.ChatType, req.BookingID, req.AppointmentID)
	if chatType == "" {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid chatType"})
		return
	}

	ctx := c.Request.Context()
	petOwnerID := userUUID
	participantID := uuid.Nil
	petID := req.PetID

	if req.BookingID != nil {
		booking, err := h.bookingRepo.GetBookingByID(ctx, *req.BookingID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to validate booking"})
			return
		}
		if booking == nil {
			c.JSON(http.StatusNotFound, gin.H{"success": false, "error": "Booking not found"})
			return
		}

		caregiverProfile, err := h.caregiverRepo.GetProfileByID(ctx, booking.CaregiverID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to resolve caregiver profile"})
			return
		}
		if caregiverProfile == nil {
			c.JSON(http.StatusNotFound, gin.H{"success": false, "error": "Caregiver profile not found"})
			return
		}

		isOwner := booking.PetOwnerID == userUUID
		isCaregiver := caregiverProfile.UserID == userUUID
		if !isOwner && !isCaregiver {
			c.JSON(http.StatusForbidden, gin.H{"success": false, "error": "Access denied for booking chat"})
			return
		}

		petOwnerID = booking.PetOwnerID
		participantID = caregiverProfile.UserID
		if petID == nil && len(booking.PetIDs) > 0 {
			petID = &booking.PetIDs[0]
		}
	}

	if req.AppointmentID != nil {
		appointment, err := h.vetAppointmentRepo.GetByID(ctx, *req.AppointmentID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to validate appointment"})
			return
		}
		if appointment == nil {
			c.JSON(http.StatusNotFound, gin.H{"success": false, "error": "Appointment not found"})
			return
		}

		if appointment.PetOwnerID != userUUID && appointment.VetUserID != userUUID {
			c.JSON(http.StatusForbidden, gin.H{"success": false, "error": "Access denied for appointment chat"})
			return
		}

		petOwnerID = appointment.PetOwnerID
		participantID = appointment.VetUserID
		if petID == nil {
			petID = &appointment.PetID
		}
	}

	if participantID == uuid.Nil {
		if req.VetID == nil {
			c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "vetId is required"})
			return
		}

		participantID = *req.VetID
		isProviderParticipant, err := h.isProviderParticipant(ctx, participantID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to validate chat participant"})
			return
		}
		if !isProviderParticipant {
			c.JSON(http.StatusNotFound, gin.H{"success": false, "error": "Selected user is not available for chat"})
			return
		}
	}

	if participantID == petOwnerID {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid chat participants"})
		return
	}

	chat := models.Chat{
		PetOwnerID:    petOwnerID,
		VetID:         participantID,
		PetID:         petID,
		BookingID:     req.BookingID,
		AppointmentID: req.AppointmentID,
		ChatType:      chatType,
	}

	if err := h.chatRepo.CreateChat(ctx, &chat); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to create chat", "details": err.Error()})
		return
	}

	_ = h.chatRepo.GetChatByID(ctx, chat.ID, userUUID, &chat)

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"message": "Chat created successfully",
		"chat":    chat,
	})
}

// GetMyChats retrieves all chats for the authenticated user
func (h *ChatHandlers) GetMyChats(c *gin.Context) {
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

	isProviderParticipant, err := h.isProviderParticipant(c.Request.Context(), userUUID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to resolve chat role", "details": err.Error()})
		return
	}

	chats, err := h.chatRepo.GetUserChats(c.Request.Context(), userUUID, isProviderParticipant)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to fetch chats", "details": err.Error()})
		return
	}

	for i := range chats {
		if chats[i].OtherUserPhoto == "" {
			continue
		}
		chats[i].OtherUserPhoto = utils.ResolveImageReferenceBestEffort(c.Request.Context(), chats[i].OtherUserPhoto, "chat-profiles/"+chats[i].OtherUserName)
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"chats":   chats,
	})
}

// GetChat retrieves a specific chat by ID
func (h *ChatHandlers) GetChat(c *gin.Context) {
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

	chatIDParam := c.Param("id")
	chatID, err := uuid.Parse(chatIDParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid chat ID"})
		return
	}

	// Verify user is part of the chat
	isInChat, err := h.chatRepo.CheckUserIsInChat(c.Request.Context(), chatID, userUUID)
	if err != nil || !isInChat {
		c.JSON(http.StatusForbidden, gin.H{"success": false, "error": "Access denied"})
		return
	}

	var chat models.Chat
	if err := h.chatRepo.GetChatByID(c.Request.Context(), chatID, userUUID, &chat); err != nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "error": "Chat not found"})
		return
	}

	if chat.OtherUserPhoto != "" {
		chat.OtherUserPhoto = utils.ResolveImageReferenceBestEffort(c.Request.Context(), chat.OtherUserPhoto, "chat-profiles/"+chat.OtherUserName)
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"chat":    chat,
	})
}

// SendMessage sends a message in a chat
func (h *ChatHandlers) SendMessage(c *gin.Context) {
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

	var req struct {
		ChatID  uuid.UUID `json:"chatId" binding:"required"`
		Content string    `json:"content" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": err.Error()})
		return
	}

	// Verify user is part of the chat
	isInChat, err := h.chatRepo.CheckUserIsInChat(c.Request.Context(), req.ChatID, userUUID)
	if err != nil || !isInChat {
		c.JSON(http.StatusForbidden, gin.H{"success": false, "error": "Access denied"})
		return
	}

	message := models.Message{
		ChatID:   req.ChatID,
		SenderID: userUUID,
		Content:  req.Content,
	}

	if err := h.messageRepo.CreateMessage(c.Request.Context(), &message); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to send message", "details": err.Error()})
		return
	}

	// Update the chat's last message
	_ = h.chatRepo.UpdateLastMessage(c.Request.Context(), req.ChatID, userUUID, req.Content)

	// Broadcast message via WebSocket to other users in the chat
	messageData := map[string]interface{}{
		"id":        message.ID.String(),
		"chatId":    message.ChatID.String(),
		"senderId":  message.SenderID.String(),
		"content":   message.Content,
		"isRead":    message.IsRead,
		"createdAt": message.CreatedAt,
	}
	BroadcastNewMessage(req.ChatID.String(), messageData, userUUID.String())

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"message": "Message sent successfully",
		"data":    message,
	})
}

// GetChatMessages retrieves all messages in a chat
func (h *ChatHandlers) GetChatMessages(c *gin.Context) {
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

	chatIDParam := c.Param("chatId")
	chatID, err := uuid.Parse(chatIDParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid chat ID"})
		return
	}

	// Verify user is part of the chat
	isInChat, err := h.chatRepo.CheckUserIsInChat(c.Request.Context(), chatID, userUUID)
	if err != nil || !isInChat {
		c.JSON(http.StatusForbidden, gin.H{"success": false, "error": "Access denied"})
		return
	}

	// Get pagination params
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "50"))
	if page < 1 {
		page = 1
	}
	offset := (page - 1) * limit

	messages, err := h.messageRepo.GetMessagesByChat(c.Request.Context(), chatID, limit, offset)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to fetch messages", "details": err.Error()})
		return
	}

	for i := range messages {
		if messages[i].SenderPhoto == "" {
			continue
		}
		messages[i].SenderPhoto = utils.ResolveImageReferenceBestEffort(c.Request.Context(), messages[i].SenderPhoto, "chat-profiles/"+messages[i].SenderID.String())
	}

	// Mark messages as read
	_ = h.messageRepo.MarkChatMessagesAsRead(c.Request.Context(), chatID, userUUID)

	isProviderParticipant := false
	if resolved, err := h.isProviderParticipant(c.Request.Context(), userUUID); err == nil {
		isProviderParticipant = resolved
	}
	_ = h.chatRepo.MarkChatAsRead(c.Request.Context(), chatID, isProviderParticipant)

	c.JSON(http.StatusOK, gin.H{
		"success":  true,
		"messages": messages,
		"pagination": gin.H{
			"page":  page,
			"limit": limit,
		},
	})
}

func normalizeRequestedChatType(chatType string, bookingID, appointmentID *uuid.UUID) string {
	normalized := strings.ToLower(strings.TrimSpace(chatType))
	if normalized == "" {
		if bookingID != nil {
			return "active_booking"
		}
		if appointmentID != nil {
			return "vet_consultation"
		}
		return "general"
	}

	switch normalized {
	case "general", "vet_consultation", "booking_inquiry", "active_booking":
		return normalized
	default:
		return ""
	}
}

func (h *ChatHandlers) isProviderParticipant(ctx context.Context, userID uuid.UUID) (bool, error) {
	roles, err := h.userRepo.GetUserRoles(ctx, userID)
	if err != nil {
		return false, err
	}
	if hasAnyProviderRole(roles) {
		return true, nil
	}

	user, err := h.userRepo.GetByID(ctx, userID)
	if err != nil {
		return false, err
	}
	if user != nil && hasProviderRole(user.AccountType) {
		return true, nil
	}

	var vetProfile models.VetProfile
	err = h.vetRepo.GetByUserID(ctx, userID, &vetProfile)
	if err == nil {
		return true, nil
	}
	if !errors.Is(err, pgx.ErrNoRows) {
		return false, err
	}

	caregiverProfile, err := h.caregiverRepo.GetProfileByUserID(ctx, userID)
	if err != nil {
		return false, err
	}

	return caregiverProfile != nil, nil
}

func hasAnyProviderRole(roles []string) bool {
	for _, role := range roles {
		if hasProviderRole(role) {
			return true
		}
	}

	return false
}

func hasProviderRole(role string) bool {
	switch strings.ToLower(strings.TrimSpace(role)) {
	case "vet", "caregiver", "seller":
		return true
	default:
		return false
	}
}

// MarkMessageAsRead marks a specific message as read
func (h *ChatHandlers) MarkMessageAsRead(c *gin.Context) {
	messageIDParam := c.Param("id")
	messageID, err := uuid.Parse(messageIDParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid message ID"})
		return
	}

	if err := h.messageRepo.MarkMessageAsRead(c.Request.Context(), messageID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to mark message as read"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Message marked as read",
	})
}

// DeleteChat deletes a chat (soft delete or full delete)
func (h *ChatHandlers) DeleteChat(c *gin.Context) {
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

	chatIDParam := c.Param("id")
	chatID, err := uuid.Parse(chatIDParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid chat ID"})
		return
	}

	// Verify user is part of the chat
	isInChat, err := h.chatRepo.CheckUserIsInChat(c.Request.Context(), chatID, userUUID)
	if err != nil || !isInChat {
		c.JSON(http.StatusForbidden, gin.H{"success": false, "error": "Access denied"})
		return
	}

	if err := h.chatRepo.DeleteChat(c.Request.Context(), chatID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to delete chat"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Chat deleted successfully",
	})
}
