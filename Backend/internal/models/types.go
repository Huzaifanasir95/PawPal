package models

import "time"

// PetType represents the type of pet for classification
type PetType string

const (
	PetTypeDog PetType = "dog"
	PetTypeCat PetType = "cat"
)

// PredictionRequest represents a single prediction request
type PredictionRequest struct {
	Image   string  `json:"image" binding:"required"`          // Base64 encoded image
	PetType PetType `json:"pet_type" binding:"required"`       // Type of pet: "dog" or "cat"
	UseeTTA bool    `json:"use_tta,omitempty"`                 // Use Test-Time Augmentation
	TopK    int     `json:"top_k,omitempty"`                   // Number of top predictions to return
}

// URLPredictionRequest represents a prediction request from URL
type URLPredictionRequest struct {
	ImageURL string  `json:"image_url" binding:"required,url"` // Image URL
	PetType  PetType `json:"pet_type" binding:"required"`      // Type of pet: "dog" or "cat"
	UseeTTA  bool    `json:"use_tta,omitempty"`                // Use Test-Time Augmentation
	TopK     int     `json:"top_k,omitempty"`                  // Number of top predictions to return
}

// BatchPredictionRequest represents a batch prediction request
type BatchPredictionRequest struct {
	Images  []string `json:"images" binding:"required,min=1,max=10"` // Base64 encoded images
	PetType PetType  `json:"pet_type" binding:"required"`            // Type of pet: "dog" or "cat"
	UseeTTA bool     `json:"use_tta,omitempty"`                      // Use Test-Time Augmentation
	TopK    int      `json:"top_k,omitempty"`                        // Number of top predictions to return
}

// BreedPrediction represents a single breed prediction
type BreedPrediction struct {
	Breed      string  `json:"breed"`
	Confidence float64 `json:"confidence"`
	Rank       int     `json:"rank"`
}

// PredictionResponse represents the response for a single prediction
type PredictionResponse struct {
	Success     bool              `json:"success"`
	Message     string            `json:"message,omitempty"`
	PetType     PetType           `json:"pet_type"`
	Predicted   string            `json:"predicted_breed"`
	Confidence  float64           `json:"confidence"`
	Predictions []BreedPrediction `json:"top_predictions"`
	ProcessTime float64           `json:"process_time_ms"`
	UsedTTA     bool              `json:"used_tta"`
	ModelInfo   ModelInfo         `json:"model_info"`
}

// BatchPredictionResponse represents the response for batch predictions
type BatchPredictionResponse struct {
	Success     bool                 `json:"success"`
	Message     string               `json:"message,omitempty"`
	PetType     PetType              `json:"pet_type"`
	Results     []PredictionResponse `json:"results"`
	TotalImages int                  `json:"total_images"`
	ProcessTime float64              `json:"total_process_time_ms"`
}

// ModelInfo represents information about the model
type ModelInfo struct {
	Name        string  `json:"name"`
	PetType     PetType `json:"pet_type"`
	Version     string  `json:"version"`
	Classes     int     `json:"classes"`
	ImageSize   int     `json:"image_size"`
	Accuracy    string  `json:"accuracy"`
	Description string  `json:"description"`
}

// HealthResponse represents health check response
type HealthResponse struct {
	Status    string                  `json:"status"`
	Timestamp time.Time               `json:"timestamp"`
	Version   string                  `json:"version"`
	Uptime    string                  `json:"uptime"`
	Model     ModelInfo               `json:"model"`  // For backward compatibility
	Models    map[string]ModelInfo    `json:"models,omitempty"` // Both cat and dog models
}

// ErrorResponse represents error response
type ErrorResponse struct {
	Success bool   `json:"success"`
	Error   string `json:"error"`
	Code    int    `json:"code"`
}

// BreedInfo represents information about a dog breed
type BreedInfo struct {
	ID          string `json:"id"`
	Name        string `json:"name"`
	CleanName   string `json:"clean_name"`
	Group       string `json:"group,omitempty"`
	Description string `json:"description,omitempty"`
}

// BreedsResponse represents the list of supported breeds
type BreedsResponse struct {
	Success    bool        `json:"success"`
	PetType    PetType     `json:"pet_type"`
	TotalCount int         `json:"total_count"`
	Breeds     []BreedInfo `json:"breeds"`
}