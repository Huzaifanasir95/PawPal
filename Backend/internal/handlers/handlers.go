package handlers

import (
	"net/http"
	"strconv"
	"time"

	"pawpal-backend/internal/models"
	"pawpal-backend/internal/services"
	"pawpal-backend/internal/utils"
	"pawpal-backend/pkg/logger"

	"github.com/gin-gonic/gin"
)

type Handlers struct {
	predictionService *services.PredictionService
	logger            *logger.Logger
	startTime         time.Time
}

func NewHandlers(predictionService *services.PredictionService, logger *logger.Logger) *Handlers {
	return &Handlers{
		predictionService: predictionService,
		logger:            logger,
		startTime:         time.Now(),
	}
}

// HealthCheck handles health check requests
func (h *Handlers) HealthCheck(c *gin.Context) {
	uptime := time.Since(h.startTime)
	
	// Get model info for both dogs and cats
	dogModel := h.predictionService.GetModelInfo(models.PetTypeDog)
	catModel := h.predictionService.GetModelInfo(models.PetTypeCat)
	
	response := models.HealthResponse{
		Status:    "healthy",
		Timestamp: time.Now(),
		Version:   "1.0.0",
		Uptime:    uptime.String(),
		Model:     dogModel, // For backward compatibility (default to dog)
		Models: map[string]models.ModelInfo{
			"dog": dogModel,
			"cat": catModel,
		},
	}
	
	c.JSON(http.StatusOK, response)
}

// GetModelInfo returns information about the model
func (h *Handlers) GetModelInfo(c *gin.Context) {
	petTypeStr := c.Query("pet_type")
	if petTypeStr == "" {
		petTypeStr = "dog" // Default to dog
	}
	
	var petType models.PetType
	if petTypeStr == "cat" {
		petType = models.PetTypeCat
	} else {
		petType = models.PetTypeDog
	}
	
	modelInfo := h.predictionService.GetModelInfo(petType)
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"model":   modelInfo,
	})
}

// PredictSingle handles single image prediction
func (h *Handlers) PredictSingle(c *gin.Context) {
	var req models.PredictionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		h.logger.Errorf("Invalid request: %v", err)
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Error:   "Invalid request format: " + err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}
	
	// Validate pet type
	if req.PetType != models.PetTypeDog && req.PetType != models.PetTypeCat {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Error:   "Invalid pet type. Must be 'dog' or 'cat'",
			Code:    http.StatusBadRequest,
		})
		return
	}
	
	// Validate image
	supportedTypes := []string{"image/jpeg", "image/jpg", "image/png", "image/webp"}
	imageData, err := utils.ValidateBase64Image(req.Image, supportedTypes, 50*1024*1024) // 50MB limit
	if err != nil {
		h.logger.Errorf("Image validation failed: %v", err)
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Error:   "Image validation failed: " + err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}
	
	// Set defaults
	topK := req.TopK
	if topK <= 0 {
		topK = 5
	}
	
	// Make prediction
	result, err := h.predictionService.PredictSingle(imageData, req.PetType, req.UseeTTA, topK)
	if err != nil {
		h.logger.Errorf("Prediction failed: %v", err)
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Error:   "Prediction failed: " + err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}
	
	c.JSON(http.StatusOK, result)
}

// PredictBatch handles batch image prediction
func (h *Handlers) PredictBatch(c *gin.Context) {
	var req models.BatchPredictionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		h.logger.Errorf("Invalid batch request: %v", err)
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Error:   "Invalid request format: " + err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}
	
	// Validate pet type
	if req.PetType != models.PetTypeDog && req.PetType != models.PetTypeCat {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Error:   "Invalid pet type. Must be 'dog' or 'cat'",
			Code:    http.StatusBadRequest,
		})
		return
	}
	
	// Validate batch size
	if len(req.Images) > 10 {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Error:   "Batch size too large. Maximum 10 images allowed.",
			Code:    http.StatusBadRequest,
		})
		return
	}
	
	// Validate all images
	supportedTypes := []string{"image/jpeg", "image/jpg", "image/png", "image/webp"}
	validatedImages := make([]string, len(req.Images))
	
	for i, image := range req.Images {
		imageData, err := utils.ValidateBase64Image(image, supportedTypes, 50*1024*1024)
		if err != nil {
			h.logger.Errorf("Image %d validation failed: %v", i, err)
			c.JSON(http.StatusBadRequest, models.ErrorResponse{
				Success: false,
				Error:   "Image " + strconv.Itoa(i+1) + " validation failed: " + err.Error(),
				Code:    http.StatusBadRequest,
			})
			return
		}
		validatedImages[i] = imageData
	}
	
	// Set defaults
	topK := req.TopK
	if topK <= 0 {
		topK = 5
	}
	
	// Make batch prediction
	result, err := h.predictionService.PredictBatch(validatedImages, req.PetType, req.UseeTTA, topK)
	if err != nil {
		h.logger.Errorf("Batch prediction failed: %v", err)
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Error:   "Batch prediction failed: " + err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}
	
	c.JSON(http.StatusOK, result)
}

// PredictFromURL handles prediction from image URL
func (h *Handlers) PredictFromURL(c *gin.Context) {
	var req models.URLPredictionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		h.logger.Errorf("Invalid URL request: %v", err)
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Error:   "Invalid request format: " + err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}
	
	// Validate pet type
	if req.PetType != models.PetTypeDog && req.PetType != models.PetTypeCat {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Error:   "Invalid pet type. Must be 'dog' or 'cat'",
			Code:    http.StatusBadRequest,
		})
		return
	}
	
	// Download image from URL
	h.logger.Infof("Downloading image from URL: %s", req.ImageURL)
	imageData, err := utils.DownloadImageFromURL(req.ImageURL, 50*1024*1024) // 50MB limit
	if err != nil {
		h.logger.Errorf("Failed to download image: %v", err)
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Error:   "Failed to download image: " + err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}
	
	// Set defaults
	topK := req.TopK
	if topK <= 0 {
		topK = 5
	}
	
	// Make prediction
	result, err := h.predictionService.PredictSingle(imageData, req.PetType, req.UseeTTA, topK)
	if err != nil {
		h.logger.Errorf("Prediction failed: %v", err)
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Error:   "Prediction failed: " + err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}
	
	c.JSON(http.StatusOK, result)
}

// GetSupportedBreeds returns list of supported breeds
func (h *Handlers) GetSupportedBreeds(c *gin.Context) {
	petTypeStr := c.Query("pet_type")
	if petTypeStr == "" {
		petTypeStr = "dog" // Default to dog
	}
	
	var petType models.PetType
	if petTypeStr == "cat" {
		petType = models.PetTypeCat
	} else {
		petType = models.PetTypeDog
	}
	
	// Read class names from the appropriate model's class names file
	var classNamesPath string
	if petType == models.PetTypeDog {
		classNamesPath = "d:\\PawPal\\ML_Models\\dogs\\model\\class_names.json"
	} else {
		classNamesPath = "d:\\PawPal\\ML_Models\\cats\\model\\class_names.json"
	}
	
	// Read and parse class names (this should be cached in production)
	classNames, err := utils.ReadClassNames(classNamesPath)
	if err != nil {
		h.logger.Errorf("Failed to read class names: %v", err)
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Error:   "Failed to load breed information",
			Code:    http.StatusInternalServerError,
		})
		return
	}
	
	// Convert to BreedInfo format
	breeds := make([]models.BreedInfo, len(classNames))
	for i, className := range classNames {
		cleanName := utils.CleanBreedName(className)
		breeds[i] = models.BreedInfo{
			ID:        className,
			Name:      className,
			CleanName: cleanName,
			Group:     "", // Could be enhanced with breed group information
		}
	}
	
	response := models.BreedsResponse{
		Success:    true,
		TotalCount: len(breeds),
		Breeds:     breeds,
		PetType:    petType,
	}
	
	c.JSON(http.StatusOK, response)
}