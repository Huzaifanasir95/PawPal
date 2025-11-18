package services

import (
	"bytes"
	"encoding/json"
	"fmt"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"

	"pawpal-backend/pkg/logger"
)

type ChatbotService struct {
	logger     *logger.Logger
	pythonPath string
	scriptPath string
	mu         sync.Mutex
}

type ChatMessage struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type ChatRequest struct {
	Message    string                 `json:"message"`
	PetProfile map[string]interface{} `json:"pet_profile,omitempty"`
}

type ChatResponse struct {
	Answer        string                   `json:"answer"`
	Sources       []map[string]interface{} `json:"sources,omitempty"`
	Query         string                   `json:"query"`
	EnhancedQuery string                   `json:"enhanced_query,omitempty"`
}

func NewChatbotService(logger *logger.Logger) *ChatbotService {
	// Get absolute path to AI_Chatbot directory
	scriptPath, _ := filepath.Abs("../AI_Chatbot/chatbot_api.py")
	
	return &ChatbotService{
		logger:     logger,
		pythonPath: "python",
		scriptPath: scriptPath,
	}
}

// Query sends a question to the RAG chatbot
func (s *ChatbotService) Query(message string, petProfile map[string]interface{}) (*ChatResponse, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	s.logger.Infof("Processing chatbot query: %s", message)

	// Prepare request data
	reqData := ChatRequest{
		Message:    message,
		PetProfile: petProfile,
	}

	reqJSON, err := json.Marshal(reqData)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal request: %w", err)
	}

	// Call Python script
	cmd := exec.Command(s.pythonPath, s.scriptPath)
	cmd.Stdin = bytes.NewReader(reqJSON)

	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	if err := cmd.Run(); err != nil {
		s.logger.Errorf("Python script error: %s", stderr.String())
		return nil, fmt.Errorf("chatbot error: %s", stderr.String())
	}

	// Parse response
	var response ChatResponse
	if err := json.Unmarshal(stdout.Bytes(), &response); err != nil {
		return nil, fmt.Errorf("failed to parse response: %w", err)
	}

	s.logger.Infof("Chatbot response generated successfully")
	return &response, nil
}

// QueryStream sends a question and returns streaming response
func (s *ChatbotService) QueryStream(message string, petProfile map[string]interface{}) (<-chan string, <-chan error) {
	responseChan := make(chan string, 100)
	errorChan := make(chan error, 1)

	go func() {
		defer close(responseChan)
		defer close(errorChan)

		response, err := s.Query(message, petProfile)
		if err != nil {
			errorChan <- err
			return
		}

		// Simulate streaming by breaking response into words
		words := strings.Fields(response.Answer)
		for _, word := range words {
			responseChan <- word + " "
		}
	}()

	return responseChan, errorChan
}

// HealthCheck verifies the chatbot service is working
func (s *ChatbotService) HealthCheck() error {
	// Try a simple query
	response, err := s.Query("test", nil)
	if err != nil {
		return err
	}
	if response.Answer == "" {
		return fmt.Errorf("chatbot returned empty response")
	}
	return nil
}
