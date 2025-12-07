package handlers

import (
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strings"

	"github.com/gin-gonic/gin"
	"pawpal-backend/internal/models"
)

// UploadHandlers handles file upload endpoints
type UploadHandlers struct {
	uploadsDir string
	baseURL    string
}

// NewUploadHandlers creates new UploadHandlers
func NewUploadHandlers(uploadsDir, baseURL string) *UploadHandlers {
	return &UploadHandlers{
		uploadsDir: uploadsDir,
		baseURL:    baseURL,
	}
}

// UploadPetImage handles uploading pet images
func (h *UploadHandlers) UploadPetImage(c *gin.Context) {
	// Check if user is authenticated
	_, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Success: false,
			Error:   "Authentication required",
			Code:    http.StatusUnauthorized,
		})
		return
	}

	// Parse multipart form
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

	// Generate unique filename
	ext := filepath.Ext(header.Filename)
	if ext == "" {
		// Determine extension from content type
		switch contentType {
		case "image/jpeg", "image/jpg":
			ext = ".jpg"
		case "image/png":
			ext = ".png"
		case "image/webp":
			ext = ".webp"
		}
	}

	randomBytes := make([]byte, 16)
	if _, err := rand.Read(randomBytes); err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Error:   "Failed to generate filename",
			Code:    http.StatusInternalServerError,
		})
		return
	}
	filename := hex.EncodeToString(randomBytes) + ext

	// Create uploads directory if it doesn't exist
	if err := os.MkdirAll(h.uploadsDir, 0755); err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Error:   "Failed to create uploads directory",
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// Save file
	filePath := filepath.Join(h.uploadsDir, filename)
	destFile, err := os.Create(filePath)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Error:   "Failed to save file",
			Code:    http.StatusInternalServerError,
		})
		return
	}
	defer destFile.Close()

	if _, err := io.Copy(destFile, file); err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Error:   "Failed to write file",
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// Generate URL
	fileURL := fmt.Sprintf("%s/uploads/%s", h.baseURL, filename)

	c.JSON(http.StatusOK, gin.H{
		"success":  true,
		"message":  "Image uploaded successfully",
		"filename": filename,
		"url":      fileURL,
		"path":     filePath,
		"size":     header.Size,
	})
}

// UploadMultiplePetImages handles uploading multiple pet images
func (h *UploadHandlers) UploadMultiplePetImages(c *gin.Context) {
	// Check if user is authenticated
	_, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Success: false,
			Error:   "Authentication required",
			Code:    http.StatusUnauthorized,
		})
		return
	}

	// Parse multipart form
	form, err := c.MultipartForm()
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Error:   "Failed to parse form: " + err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	files := form.File["images"]
	if len(files) == 0 {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Error:   "No images provided",
			Code:    http.StatusBadRequest,
		})
		return
	}

	// Limit to 5 images
	if len(files) > 5 {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Error:   "Maximum 5 images allowed",
			Code:    http.StatusBadRequest,
		})
		return
	}

	type UploadedFile struct {
		Filename string `json:"filename"`
		URL      string `json:"url"`
		Path     string `json:"path"`
		Size     int64  `json:"size"`
	}

	uploadedFiles := make([]UploadedFile, 0, len(files))
	allowedTypes := map[string]bool{
		"image/jpeg": true,
		"image/jpg":  true,
		"image/png":  true,
		"image/webp": true,
	}

	for _, fileHeader := range files {
		// Validate file type
		contentType := fileHeader.Header.Get("Content-Type")
		if !allowedTypes[contentType] {
			continue // Skip invalid files
		}

		// Validate file size (max 10MB)
		if fileHeader.Size > 10*1024*1024 {
			continue // Skip files that are too large
		}

		// Open uploaded file
		file, err := fileHeader.Open()
		if err != nil {
			continue
		}

		// Generate unique filename
		ext := filepath.Ext(fileHeader.Filename)
		if ext == "" {
			switch contentType {
			case "image/jpeg", "image/jpg":
				ext = ".jpg"
			case "image/png":
				ext = ".png"
			case "image/webp":
				ext = ".webp"
			}
		}

		randomBytes := make([]byte, 16)
		if _, err := rand.Read(randomBytes); err != nil {
			file.Close()
			continue
		}
		filename := hex.EncodeToString(randomBytes) + ext

		// Create uploads directory if it doesn't exist
		if err := os.MkdirAll(h.uploadsDir, 0755); err != nil {
			file.Close()
			continue
		}

		// Save file
		filePath := filepath.Join(h.uploadsDir, filename)
		destFile, err := os.Create(filePath)
		if err != nil {
			file.Close()
			continue
		}

		if _, err := io.Copy(destFile, file); err != nil {
			file.Close()
			destFile.Close()
			continue
		}

		file.Close()
		destFile.Close()

		// Generate URL
		fileURL := fmt.Sprintf("%s/uploads/%s", h.baseURL, filename)

		uploadedFiles = append(uploadedFiles, UploadedFile{
			Filename: filename,
			URL:      fileURL,
			Path:     filePath,
			Size:     fileHeader.Size,
		})
	}

	if len(uploadedFiles) == 0 {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Error:   "No valid images uploaded",
			Code:    http.StatusBadRequest,
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": fmt.Sprintf("Uploaded %d image(s) successfully", len(uploadedFiles)),
		"files":   uploadedFiles,
		"count":   len(uploadedFiles),
	})
}

// DeleteUploadedImage deletes an uploaded image
func (h *UploadHandlers) DeleteUploadedImage(c *gin.Context) {
	// Check if user is authenticated
	_, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Success: false,
			Error:   "Authentication required",
			Code:    http.StatusUnauthorized,
		})
		return
	}

	filename := c.Param("filename")
	if filename == "" {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Error:   "Filename is required",
			Code:    http.StatusBadRequest,
		})
		return
	}

	// Security: prevent directory traversal
	if strings.Contains(filename, "..") || strings.Contains(filename, "/") || strings.Contains(filename, "\\") {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Error:   "Invalid filename",
			Code:    http.StatusBadRequest,
		})
		return
	}

	filePath := filepath.Join(h.uploadsDir, filename)

	// Check if file exists
	if _, err := os.Stat(filePath); os.IsNotExist(err) {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Error:   "File not found",
			Code:    http.StatusNotFound,
		})
		return
	}

	// Delete file
	if err := os.Remove(filePath); err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Error:   "Failed to delete file",
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Image deleted successfully",
	})
}
