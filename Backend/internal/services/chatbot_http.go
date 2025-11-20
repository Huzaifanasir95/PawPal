package services

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"pawpal-backend/pkg/logger"
)

// ChatbotHTTPService uses HTTP to communicate with FastAPI server (persistent process)
type ChatbotHTTPService struct {
	logger     *logger.Logger
	apiURL     string
	httpClient *http.Client
}

// NewChatbotHTTPService creates a new HTTP-based chatbot service
func NewChatbotHTTPService(logger *logger.Logger) *ChatbotHTTPService {
	return &ChatbotHTTPService{
		logger: logger,
		apiURL: "http://localhost:8000/api/chatbot/query",
		httpClient: &http.Client{
			Timeout: 30 * time.Second, // 30s timeout for chatbot queries
		},
	}
}

// Query sends a question to the FastAPI chatbot server
func (s *ChatbotHTTPService) Query(message string, petProfile map[string]interface{}) (*ChatResponse, error) {
	s.logger.Infof("Processing chatbot query via HTTP: %s", message)

	// Prepare request
	reqData := ChatRequest{
		Message:    message,
		PetProfile: petProfile,
	}

	reqJSON, err := json.Marshal(reqData)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal request: %w", err)
	}

	// Make HTTP POST request
	resp, err := s.httpClient.Post(s.apiURL, "application/json", bytes.NewBuffer(reqJSON))
	if err != nil {
		return nil, fmt.Errorf("failed to connect to chatbot API: %w", err)
	}
	defer resp.Body.Close()

	// Read response body
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response: %w", err)
	}

	// Check status code
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("chatbot API error (status %d): %s", resp.StatusCode, string(body))
	}

	// Parse response
	var response ChatResponse
	if err := json.Unmarshal(body, &response); err != nil {
		return nil, fmt.Errorf("failed to parse response: %w", err)
	}

	s.logger.Infof("Chatbot response received successfully via HTTP")
	return &response, nil
}

// HealthCheck verifies the chatbot API is reachable
func (s *ChatbotHTTPService) HealthCheck() error {
	healthURL := "http://localhost:8000/health"
	
	resp, err := s.httpClient.Get(healthURL)
	if err != nil {
		return fmt.Errorf("chatbot API unreachable: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("chatbot API unhealthy (status %d)", resp.StatusCode)
	}

	return nil
}
