package services

import (
	"encoding/json"
	"fmt"
	"os/exec"
	"pawpal-backend/internal/config"
	"pawpal-backend/internal/models"
	"pawpal-backend/pkg/logger"
	"strings"
	"time"
)

type PredictionService struct {
	config *config.Config
	logger *logger.Logger
}

func NewPredictionService(cfg *config.Config, logger *logger.Logger) (*PredictionService, error) {
	return &PredictionService{
		config: cfg,
		logger: logger,
	}, nil
}

// PythonPredictionResult represents the result from Python script
type PythonPredictionResult struct {
	Success        bool    `json:"success"`
	Error          string  `json:"error,omitempty"`
	PredictedBreed string  `json:"predicted_breed"`
	Confidence     float64 `json:"confidence"`
	Predictions    []struct {
		Breed      string  `json:"breed"`
		RawBreed   string  `json:"raw_breed"`
		Confidence float64 `json:"confidence"`
		Rank       int     `json:"rank"`
	} `json:"predictions"`
	ProcessTimeMs float64 `json:"process_time_ms"`
	UsedTTA       bool    `json:"used_tta"`
	Device        string  `json:"device"`
}

func (s *PredictionService) PredictSingle(imageBase64 string, petType models.PetType, useeTTA bool, topK int) (*models.PredictionResponse, error) {
	start := time.Now()
	
	// Validate pet type
	if petType != models.PetTypeDog && petType != models.PetTypeCat {
		return &models.PredictionResponse{
			Success: false,
			Message: "Invalid pet type. Must be 'dog' or 'cat'",
		}, fmt.Errorf("invalid pet type: %s", petType)
	}
	
	// Get model configuration based on pet type
	var modelPath, classNamesPath string
	var numClasses int
	var modelName string
	
	if petType == models.PetTypeDog {
		modelPath = s.config.Models.Dogs.ModelPath
		classNamesPath = s.config.Models.Dogs.ClassNamesPath
		numClasses = s.config.Models.Dogs.NumClasses
		modelName = s.config.Models.Dogs.Name
		if topK <= 0 {
			topK = s.config.Models.Dogs.TopK
		}
	} else {
		modelPath = s.config.Models.Cats.ModelPath
		classNamesPath = s.config.Models.Cats.ClassNamesPath
		numClasses = s.config.Models.Cats.NumClasses
		modelName = s.config.Models.Cats.Name
		if topK <= 0 {
			topK = s.config.Models.Cats.TopK
		}
	}
	
	if topK > 10 {
		topK = 10 // Limit to prevent excessive response size
	}
	
	// Call Python prediction script
	result, err := s.callPythonPredict(imageBase64, petType, useeTTA, topK, modelPath, classNamesPath)
	if err != nil {
		return &models.PredictionResponse{
			Success: false,
			Message: err.Error(),
			PetType: petType,
		}, err
	}
	
	if !result.Success {
		return &models.PredictionResponse{
			Success: false,
			Message: result.Error,
			PetType: petType,
		}, fmt.Errorf("prediction failed: %s", result.Error)
	}
	
	// Convert Python result to Go response
	predictions := make([]models.BreedPrediction, len(result.Predictions))
	for i, pred := range result.Predictions {
		predictions[i] = models.BreedPrediction{
			Breed:      pred.Breed,
			Confidence: pred.Confidence,
			Rank:       pred.Rank,
		}
	}
	
	totalTime := time.Since(start).Milliseconds()
	
	var accuracy string
	if petType == models.PetTypeDog {
		accuracy = "92-95%"
	} else {
		accuracy = "88-92%" // Adjust based on your cat model performance
	}
	
	response := &models.PredictionResponse{
		Success:     true,
		PetType:     petType,
		Predicted:   result.PredictedBreed,
		Confidence:  result.Confidence,
		Predictions: predictions,
		ProcessTime: float64(totalTime),
		UsedTTA:     result.UsedTTA,
		ModelInfo: models.ModelInfo{
			Name:        modelName,
			PetType:     petType,
			Version:     "1.0",
			Classes:     numClasses,
			ImageSize:   384,
			Accuracy:    accuracy,
			Description: fmt.Sprintf("ConvNeXt V2 Base model trained for %s breed classification", string(petType)),
		},
	}
	
	s.logger.Infof("Prediction completed: %s %s (%.2f%%) in %dms", 
		string(petType), result.PredictedBreed, result.Confidence*100, totalTime)
	
	return response, nil
}

func (s *PredictionService) PredictBatch(images []string, petType models.PetType, useeTTA bool, topK int) (*models.BatchPredictionResponse, error) {
	start := time.Now()
	
	results := make([]models.PredictionResponse, len(images))
	successCount := 0
	
	for i, imageBase64 := range images {
		result, err := s.PredictSingle(imageBase64, petType, useeTTA, topK)
		if err != nil {
			results[i] = models.PredictionResponse{
				Success: false,
				Message: err.Error(),
				PetType: petType,
			}
		} else {
			results[i] = *result
			if result.Success {
				successCount++
			}
		}
	}
	
	totalTime := time.Since(start).Milliseconds()
	
	response := &models.BatchPredictionResponse{
		Success:     successCount > 0,
		PetType:     petType,
		Results:     results,
		TotalImages: len(images),
		ProcessTime: float64(totalTime),
	}
	
	if successCount == 0 {
		response.Message = "All predictions failed"
	} else if successCount < len(images) {
		response.Message = fmt.Sprintf("%d/%d predictions succeeded", successCount, len(images))
	}
	
	s.logger.Infof("Batch prediction completed: %d/%d successful in %dms", 
		successCount, len(images), totalTime)
	
	return response, nil
}

func (s *PredictionService) callPythonPredict(imageBase64 string, petType models.PetType, useeTTA bool, topK int, modelPath, classNamesPath string) (*PythonPredictionResult, error) {
	// Build command arguments (without the image data to avoid command line length issues)
	args := []string{
		s.config.Python.ScriptPath,
		"--model-path", modelPath,
		"--class-names-path", classNamesPath,
		"--pet-type", string(petType),
		"--top-k", fmt.Sprintf("%d", topK),
		"--stdin", // Use stdin for image data
	}
	
	if useeTTA {
		args = append(args, "--use-tta")
	}
	
	// Use GPU setting from the appropriate model config
	var useGPU bool
	if petType == models.PetTypeDog {
		useGPU = s.config.Models.Dogs.UseGPU
	} else {
		useGPU = s.config.Models.Cats.UseGPU
	}
	
	if useGPU {
		args = append(args, "--use-gpu")
	}
	
	// Execute Python script
	cmd := exec.Command(s.config.Python.PythonPath, args...)
	
	// Set up stdin to pass image data
	stdin, err := cmd.StdinPipe()
	if err != nil {
		return nil, fmt.Errorf("failed to create stdin pipe: %s", err)
	}
	
	s.logger.Debugf("Executing: %s %s", s.config.Python.PythonPath, strings.Join(args, " "))
	
	// Write image data to stdin in a goroutine and close it
	go func() {
		defer stdin.Close()
		stdin.Write([]byte(imageBase64))
	}()
	
	// Get output directly (this starts the process, waits for completion, and returns output)
	output, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("failed to execute python script: %s", err)
	}
	
	// Parse JSON output
	var result PythonPredictionResult
	if err := json.Unmarshal(output, &result); err != nil {
		return nil, fmt.Errorf("failed to parse python output: %s, output: %s", err, string(output))
	}
	
	return &result, nil
}

func (s *PredictionService) GetModelInfo(petType models.PetType) models.ModelInfo {
	if petType == models.PetTypeDog {
		return models.ModelInfo{
			Name:        s.config.Models.Dogs.Name,
			PetType:     models.PetTypeDog,
			Version:     "1.0",
			Classes:     s.config.Models.Dogs.NumClasses,
			ImageSize:   s.config.Models.Dogs.ImageSize,
			Accuracy:    "92-95%",
			Description: "ConvNeXt V2 Base model trained on Stanford Dogs Dataset for 120 dog breed classification",
		}
	} else {
		return models.ModelInfo{
			Name:        s.config.Models.Cats.Name,
			PetType:     models.PetTypeCat,
			Version:     "1.0",
			Classes:     s.config.Models.Cats.NumClasses,
			ImageSize:   s.config.Models.Cats.ImageSize,
			Accuracy:    "88-92%",
			Description: "ConvNeXt V2 Base model trained for cat breed classification",
		}
	}
}