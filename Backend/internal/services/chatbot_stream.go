package services

import (
	"bufio"
	"encoding/json"
	"fmt"
	"io"
	"os/exec"
	"path/filepath"
	"strings"

	"pawpal-backend/pkg/logger"
)

// ChatbotStreamService handles streaming chatbot interactions
type ChatbotStreamService struct {
	logger     *logger.Logger
	pythonPath string
	scriptPath string
}

// NewChatbotStreamService creates a new chatbot streaming service instance
func NewChatbotStreamService(logger *logger.Logger) *ChatbotStreamService {
	// Get absolute path to AI_Chatbot streaming script
	scriptPath, _ := filepath.Abs("../AI_Chatbot/chatbot_api_stream.py")
	
	return &ChatbotStreamService{
		logger:     logger,
		pythonPath: "python",
		scriptPath: scriptPath,
	}
}

// StreamRequest represents the streaming request structure
type StreamRequest struct {
	Message    string                 `json:"message"`
	PetProfile map[string]interface{} `json:"pet_profile,omitempty"`
}

// StreamChunk represents each chunk of the streaming response
type StreamChunk struct {
	Chunk string `json:"chunk"`
	Done  bool   `json:"done"`
	Error string `json:"error,omitempty"`
}

// QueryStream executes the Python chatbot script and streams responses
func (s *ChatbotStreamService) QueryStream(message string, petProfile map[string]interface{}, writer io.Writer) error {
	// Create the request
	request := StreamRequest{
		Message:    message,
		PetProfile: petProfile,
	}

	requestJSON, err := json.Marshal(request)
	if err != nil {
		return fmt.Errorf("failed to marshal request: %w", err)
	}

	// Execute Python script
	cmd := exec.Command(s.pythonPath, s.scriptPath)

	// Setup stdin with request data
	stdin, err := cmd.StdinPipe()
	if err != nil {
		return fmt.Errorf("failed to create stdin pipe: %w", err)
	}

	// Setup stdout to read streaming response
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		return fmt.Errorf("failed to create stdout pipe: %w", err)
	}

	// Setup stderr for error capture
	stderr, err := cmd.StderrPipe()
	if err != nil {
		return fmt.Errorf("failed to create stderr pipe: %w", err)
	}

	// Start the command
	if err := cmd.Start(); err != nil {
		return fmt.Errorf("failed to start Python script: %w", err)
	}

	// Write request to stdin
	if _, err := stdin.Write(requestJSON); err != nil {
		return fmt.Errorf("failed to write to stdin: %w", err)
	}
	stdin.Close()

	// Read streaming chunks from stdout
	scanner := bufio.NewScanner(stdout)
	for scanner.Scan() {
		line := scanner.Text()
		
		// Parse the JSON chunk
		var chunk StreamChunk
		if err := json.Unmarshal([]byte(line), &chunk); err != nil {
			continue // Skip malformed lines
		}

		// Write SSE format: data: {json}\n\n
		sseData := fmt.Sprintf("data: %s\n\n", line)
		if _, err := writer.Write([]byte(sseData)); err != nil {
			return fmt.Errorf("failed to write chunk: %w", err)
		}

		// Flush if writer supports it
		if flusher, ok := writer.(interface{ Flush() }); ok {
			flusher.Flush()
		}

		// Stop if done
		if chunk.Done {
			break
		}
	}

	// Check for errors in stderr
	stderrData, _ := io.ReadAll(stderr)
	if len(stderrData) > 0 {
		errorChunk := StreamChunk{
			Chunk: strings.TrimSpace(string(stderrData)),
			Done:  true,
			Error: "Python script error",
		}
		errorJSON, _ := json.Marshal(errorChunk)
		sseData := fmt.Sprintf("data: %s\n\n", errorJSON)
		writer.Write([]byte(sseData))
		if flusher, ok := writer.(interface{ Flush() }); ok {
			flusher.Flush()
		}
	}

	// Wait for command to finish
	if err := cmd.Wait(); err != nil {
		return fmt.Errorf("Python script failed: %w", err)
	}

	return nil
}
