package handlers

import (
	"encoding/base64"
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	"pawpal-backend/internal/models"
	"pawpal-backend/internal/repositories"
	"pawpal-backend/internal/services"
)

// PetVerificationHandlers handles pet breed verification endpoints
type PetVerificationHandlers struct {
	petRepo           repositories.PetRepositoryInterface
	predictionService *services.PredictionService
}

// NewPetVerificationHandlers creates new PetVerificationHandlers
func NewPetVerificationHandlers(petRepo repositories.PetRepositoryInterface, predictionService *services.PredictionService) *PetVerificationHandlers {
	return &PetVerificationHandlers{
		petRepo:           petRepo,
		predictionService: predictionService,
	}
}

// VerifyPetBreed verifies a pet's breed using AI prediction
func (h *PetVerificationHandlers) VerifyPetBreed(c *gin.Context) {
	userID := c.MustGet("userID").(string)

	var req struct {
		PetID     string `json:"petId" binding:"required"`
		Image     string `json:"image" binding:"required"` // base64 encoded image
		UseETTA   bool   `json:"useETTA"`
		TopK      int    `json:"topK"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Error:   "Invalid request: " + err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	// Parse pet ID
	petID, err := uuid.Parse(req.PetID)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Error:   "Invalid pet ID format",
			Code:    http.StatusBadRequest,
		})
		return
	}

	// Get pet from database
	pet, err := h.petRepo.GetByID(c.Request.Context(), petID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Error:   "Failed to get pet: " + err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	if pet == nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Error:   "Pet not found",
			Code:    http.StatusNotFound,
		})
		return
	}

	// Check ownership
	if pet.OwnerID.String() != userID {
		c.JSON(http.StatusForbidden, models.ErrorResponse{
			Success: false,
			Error:   "Not authorized to verify this pet",
			Code:    http.StatusForbidden,
		})
		return
	}

	// Determine pet type
	var petType models.PetType
	switch pet.Type {
	case "dog":
		petType = models.PetTypeDog
	case "cat":
		petType = models.PetTypeCat
	default:
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Error:   "Invalid pet type. Must be 'dog' or 'cat'",
			Code:    http.StatusBadRequest,
		})
		return
	}

	// Set default TopK
	if req.TopK <= 0 {
		req.TopK = 5
	}

	// Call AI prediction service
	prediction, err := h.predictionService.PredictSingle(req.Image, petType, req.UseETTA, req.TopK)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Error:   "AI prediction failed: " + err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	if !prediction.Success {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Error:   "AI prediction failed: " + prediction.Message,
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// Update pet with verification results
	pet.IsVerified = true
	pet.VerificationConfidence = &prediction.Confidence
	pet.VerifiedBreed = &prediction.Predicted

	if err := h.petRepo.Update(c.Request.Context(), pet); err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Error:   "Failed to update pet verification: " + err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success":    true,
		"message":    "Pet breed verified successfully",
		"pet":        pet,
		"prediction": prediction,
	})
}

// VerifyPetBreedFromFile verifies a pet's breed from an uploaded file
func (h *PetVerificationHandlers) VerifyPetBreedFromFile(c *gin.Context) {
	userID := c.MustGet("userID").(string)

	// Get pet ID from form
	petIDStr := c.PostForm("petId")
	if petIDStr == "" {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Error:   "Pet ID is required",
			Code:    http.StatusBadRequest,
		})
		return
	}

	// Parse pet ID
	petID, err := uuid.Parse(petIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Error:   "Invalid pet ID format",
			Code:    http.StatusBadRequest,
		})
		return
	}

	// Get file from form
	file, header, err := c.Request.FormFile("image")
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Error:   "Failed to get image from request: " + err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}
	defer file.Close()

	// Validate file type
	contentType := header.Header.Get("Content-Type")
	allowedTypes := map[string]bool{
		"image/jpeg": true,
		"image/jpg":  true,
		"image/png":  true,
		"image/webp": true,
	}

	if !allowedTypes[contentType] {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Error:   "Invalid file type. Only JPEG, PNG, and WebP are allowed",
			Code:    http.StatusBadRequest,
		})
		return
	}

	// Validate file size (max 10MB)
	if header.Size > 10*1024*1024 {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Error:   "File too large. Maximum size is 10MB",
			Code:    http.StatusBadRequest,
		})
		return
	}

	// Read file content
	fileBytes := make([]byte, header.Size)
	if _, err := file.Read(fileBytes); err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Error:   "Failed to read file",
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// Convert to base64
	imageBase64 := base64.StdEncoding.EncodeToString(fileBytes)

	// Get pet from database
	pet, err := h.petRepo.GetByID(c.Request.Context(), petID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Error:   "Failed to get pet: " + err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	if pet == nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Error:   "Pet not found",
			Code:    http.StatusNotFound,
		})
		return
	}

	// Check ownership
	if pet.OwnerID.String() != userID {
		c.JSON(http.StatusForbidden, models.ErrorResponse{
			Success: false,
			Error:   "Not authorized to verify this pet",
			Code:    http.StatusForbidden,
		})
		return
	}

	// Determine pet type
	var petType models.PetType
	switch pet.Type {
	case "dog":
		petType = models.PetTypeDog
	case "cat":
		petType = models.PetTypeCat
	default:
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Error:   "Invalid pet type. Must be 'dog' or 'cat'",
			Code:    http.StatusBadRequest,
		})
		return
	}

	// Get optional parameters
	useETTA := c.PostForm("useETTA") == "true"
	topK := 5
	if topKStr := c.PostForm("topK"); topKStr != "" {
		fmt.Sscanf(topKStr, "%d", &topK)
	}

	// Call AI prediction service
	prediction, err := h.predictionService.PredictSingle(imageBase64, petType, useETTA, topK)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Error:   "AI prediction failed: " + err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	if !prediction.Success {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Error:   "AI prediction failed: " + prediction.Message,
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// Update pet with verification results
	pet.IsVerified = true
	pet.VerificationConfidence = &prediction.Confidence
	pet.VerifiedBreed = &prediction.Predicted

	if err := h.petRepo.Update(c.Request.Context(), pet); err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Error:   "Failed to update pet verification: " + err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success":    true,
		"message":    "Pet breed verified successfully",
		"pet":        pet,
		"prediction": prediction,
	})
}

// VerifyPetBreedFromURL verifies a pet's breed from an image URL
func (h *PetVerificationHandlers) VerifyPetBreedFromURL(c *gin.Context) {
	userID := c.MustGet("userID").(string)

	var req struct {
		PetID    string `json:"petId" binding:"required"`
		ImageURL string `json:"imageUrl" binding:"required"`
		UseETTA  bool   `json:"useETTA"`
		TopK     int    `json:"topK"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Error:   "Invalid request: " + err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	// Parse pet ID
	petID, err := uuid.Parse(req.PetID)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Error:   "Invalid pet ID format",
			Code:    http.StatusBadRequest,
		})
		return
	}

	// Get pet from database
	pet, err := h.petRepo.GetByID(c.Request.Context(), petID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Error:   "Failed to get pet: " + err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	if pet == nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Error:   "Pet not found",
			Code:    http.StatusNotFound,
		})
		return
	}

	// Check ownership
	if pet.OwnerID.String() != userID {
		c.JSON(http.StatusForbidden, models.ErrorResponse{
			Success: false,
			Error:   "Not authorized to verify this pet",
			Code:    http.StatusForbidden,
		})
		return
	}

	// Determine pet type
	var petType models.PetType
	switch pet.Type {
	case "dog":
		petType = models.PetTypeDog
	case "cat":
		petType = models.PetTypeCat
	default:
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Error:   "Invalid pet type. Must be 'dog' or 'cat'",
			Code:    http.StatusBadRequest,
		})
		return
	}

	// Download image from URL
	resp, err := http.Get(req.ImageURL)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Error:   "Failed to download image: " + err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Error:   fmt.Sprintf("Failed to download image. Status: %d", resp.StatusCode),
			Code:    http.StatusBadRequest,
		})
		return
	}

	// Read image data
	imageBytes := make([]byte, 0)
	buf := make([]byte, 8192)
	for {
		n, err := resp.Body.Read(buf)
		if n > 0 {
			imageBytes = append(imageBytes, buf[:n]...)
		}
		if err != nil {
			if err.Error() == "EOF" {
				break
			}
			c.JSON(http.StatusInternalServerError, models.ErrorResponse{
				Success: false,
				Error:   "Failed to read image data",
				Code:    http.StatusInternalServerError,
			})
			return
		}
	}

	// Convert to base64
	imageBase64 := base64.StdEncoding.EncodeToString(imageBytes)

	// Set default TopK
	if req.TopK <= 0 {
		req.TopK = 5
	}

	// Call AI prediction service
	prediction, err := h.predictionService.PredictSingle(imageBase64, petType, req.UseETTA, req.TopK)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Error:   "AI prediction failed: " + err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	if !prediction.Success {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Error:   "AI prediction failed: " + prediction.Message,
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// Update pet with verification results
	pet.IsVerified = true
	pet.VerificationConfidence = &prediction.Confidence
	pet.VerifiedBreed = &prediction.Predicted

	if err := h.petRepo.Update(c.Request.Context(), pet); err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Error:   "Failed to update pet verification: " + err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success":    true,
		"message":    "Pet breed verified successfully",
		"pet":        pet,
		"prediction": prediction,
	})
}
