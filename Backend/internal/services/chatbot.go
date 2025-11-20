package services

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"pawpal-backend/pkg/logger"
)

type ChatbotService struct {
	logger     *logger.Logger
	pythonPath string
	scriptPath string
	apiURL     string
	httpClient *http.Client
	useHTTP    bool // Use HTTP mode (faster) or exec mode (fallback)
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
	
	service := &ChatbotService{
		logger:     logger,
		pythonPath: "python",
		scriptPath: scriptPath,
		apiURL:     "http://localhost:8000/api/chatbot/query",
		httpClient: &http.Client{
			Timeout: 30 * time.Second,
		},
		useHTTP: true, // Default to HTTP mode for performance
	}
	
	// Check if FastAPI server is running
	if err := service.checkAPIHealth(); err != nil {
		logger.Info("⚠️  FastAPI chatbot server not running (will use exec mode): " + err.Error())
		logger.Info("💡 For 10x faster responses, run: cd ../AI_Chatbot && python chatbot_fastapi_server.py")
		service.useHTTP = false
	} else {
		logger.Info("✅ Connected to FastAPI chatbot server (HTTP mode - optimized)")
	}
	
	return service
}

// checkAPIHealth checks if the FastAPI server is running
func (s *ChatbotService) checkAPIHealth() error {
	healthURL := "http://localhost:8000/health"
	resp, err := s.httpClient.Get(healthURL)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("unhealthy status: %d", resp.StatusCode)
	}
	return nil
}

// Query sends a question to the RAG chatbot
func (s *ChatbotService) Query(message string, petProfile map[string]interface{}) (*ChatResponse, error) {
	s.logger.Infof("Processing chatbot query: %s", message)

	// Use HTTP mode if available (10x faster!)
	if s.useHTTP {
		return s.queryHTTP(message, petProfile)
	}
	
	// Fallback to exec mode (slower but works without FastAPI server)
	return s.queryExec(message, petProfile)
}

// queryHTTP uses HTTP to query the persistent FastAPI server (FAST!)
func (s *ChatbotService) queryHTTP(message string, petProfile map[string]interface{}) (*ChatResponse, error) {
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
		s.logger.Info("⚠️  HTTP request failed, falling back to exec mode: " + err.Error())
		s.useHTTP = false
		return s.queryExec(message, petProfile)
	}
	defer resp.Body.Close()

	// Read response
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response: %w", err)
	}

	// Check status
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("API error (status %d): %s", resp.StatusCode, string(body))
	}

	// Parse response
	var response ChatResponse
	if err := json.Unmarshal(body, &response); err != nil {
		return nil, fmt.Errorf("failed to parse response: %w", err)
	}

	s.logger.Infof("Chatbot response received via HTTP (fast mode)")
	return &response, nil
}

// queryExec uses exec to spawn Python process (SLOW but works as fallback)
func (s *ChatbotService) queryExec(message string, petProfile map[string]interface{}) (*ChatResponse, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

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

	s.logger.Infof("Chatbot response generated via exec (slow mode)")
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
