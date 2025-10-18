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

func (s *PredictionService) PredictSingle(imageBase64 string, useeTTA bool, topK int) (*models.PredictionResponse, error) {
	start := time.Now()
	
	// Set defaults
	if topK <= 0 {
		topK = s.config.Model.TopK
	}
	if topK > 10 {
		topK = 10 // Limit to prevent excessive response size
	}
	
	// Call Python prediction script
	result, err := s.callPythonPredict(imageBase64, useeTTA, topK)
	if err != nil {
		return &models.PredictionResponse{
			Success: false,
			Message: err.Error(),
		}, err
	}
	
	if !result.Success {
		return &models.PredictionResponse{
			Success: false,
			Message: result.Error,
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
	
	response := &models.PredictionResponse{
		Success:     true,
		Predicted:   result.PredictedBreed,
		Confidence:  result.Confidence,
		Predictions: predictions,
		ProcessTime: float64(totalTime),
		UsedTTA:     result.UsedTTA,
		ModelInfo: models.ModelInfo{
			Name:        s.config.Model.Name,
			Version:     "1.0",
			Classes:     s.config.Model.NumClasses,
			ImageSize:   s.config.Model.ImageSize,
			Accuracy:    "92-95%",
			Description: "ConvNeXt V2 Base model trained on Stanford Dogs Dataset for 120 dog breed classification",
		},
	}
	
	s.logger.Infof("Prediction completed: %s (%.2f%%) in %dms", 
		result.PredictedBreed, result.Confidence*100, totalTime)
	
	return response, nil
}

func (s *PredictionService) PredictBatch(images []string, useeTTA bool, topK int) (*models.BatchPredictionResponse, error) {
	start := time.Now()
	
	results := make([]models.PredictionResponse, len(images))
	successCount := 0
	
	for i, imageBase64 := range images {
		result, err := s.PredictSingle(imageBase64, useeTTA, topK)
		if err != nil {
			results[i] = models.PredictionResponse{
				Success: false,
				Message: err.Error(),
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

func (s *PredictionService) callPythonPredict(imageBase64 string, useeTTA bool, topK int) (*PythonPredictionResult, error) {
	// Build command arguments (without the image data to avoid command line length issues)
	args := []string{
		s.config.Python.ScriptPath,
		"--model-path", s.config.Model.ModelPath,
		"--class-names-path", s.config.Model.ClassNamesPath,
		"--top-k", fmt.Sprintf("%d", topK),
		"--stdin", // Use stdin for image data
	}
	
	if useeTTA {
		args = append(args, "--use-tta")
	}
	
	if s.config.Model.UseGPU {
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

func (s *PredictionService) GetModelInfo() models.ModelInfo {
	return models.ModelInfo{
		Name:        s.config.Model.Name,
		Version:     "1.0",
		Classes:     s.config.Model.NumClasses,
		ImageSize:   s.config.Model.ImageSize,
		Accuracy:    "92-95%",
		Description: "ConvNeXt V2 Base model trained on Stanford Dogs Dataset for 120 dog breed classification",
	}
}