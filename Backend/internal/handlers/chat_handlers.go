package handlers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	"pawpal-backend/internal/models"
	"pawpal-backend/internal/repositories"
	"pawpal-backend/internal/utils"
)

// ChatHandlers handles chat-related endpoints
type ChatHandlers struct {
	chatRepo    *repositories.ChatRepository
	messageRepo *repositories.MessageRepository
	userRepo    repositories.UserRepository
	vetRepo     *repositories.VetRepository
}

// NewChatHandlers creates new ChatHandlers
func NewChatHandlers(chatRepo *repositories.ChatRepository, messageRepo *repositories.MessageRepository, userRepo repositories.UserRepository, vetRepo *repositories.VetRepository) *ChatHandlers {
	return &ChatHandlers{
		chatRepo:    chatRepo,
		messageRepo: messageRepo,
		userRepo:    userRepo,
		vetRepo:     vetRepo,
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
		VetID *uuid.UUID `json:"vetId" binding:"required"`
		PetID *uuid.UUID `json:"petId"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": err.Error()})
		return
	}

	// Verify the vet exists
	var vetProfile models.VetProfile
	if err := h.vetRepo.GetByUserID(c.Request.Context(), *req.VetID, &vetProfile); err != nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "error": "Vet not found"})
		return
	}

	chat := models.Chat{
		PetOwnerID: userUUID,
		VetID:      *req.VetID,
		PetID:      req.PetID,
	}

	if err := h.chatRepo.CreateChat(c.Request.Context(), &chat); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to create chat", "details": err.Error()})
		return
	}

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

	// Check if user is a vet
	var vetProfile models.VetProfile
	isVet := h.vetRepo.GetByUserID(c.Request.Context(), userUUID, &vetProfile) == nil

	chats, err := h.chatRepo.GetUserChats(c.Request.Context(), userUUID, isVet)
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
	if err := h.chatRepo.GetChatByID(c.Request.Context(), chatID, &chat); err != nil {
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

	// Check if user is vet and mark chat as read
	var vetProfile models.VetProfile
	isVet := h.vetRepo.GetByUserID(c.Request.Context(), userUUID, &vetProfile) == nil
	_ = h.chatRepo.MarkChatAsRead(c.Request.Context(), chatID, isVet)

	c.JSON(http.StatusOK, gin.H{
		"success":  true,
		"messages": messages,
		"pagination": gin.H{
			"page":  page,
			"limit": limit,
		},
	})
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
