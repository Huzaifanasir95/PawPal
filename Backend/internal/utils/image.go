package utils

import (
	"encoding/base64"
	"fmt"
	"io"
	"mime"
	"net/http"
	"strings"
)

// ValidateImageType checks if the content type is supported
func ValidateImageType(contentType string, supportedTypes []string) bool {
	for _, supported := range supportedTypes {
		if contentType == supported {
			return true
		}
	}
	return false
}

// GetContentTypeFromBase64 extracts content type from base64 data URL
func GetContentTypeFromBase64(base64Data string) (string, error) {
	if !strings.HasPrefix(base64Data, "data:") {
		return "", fmt.Errorf("not a data URL")
	}
	
	// Extract content type from data URL
	parts := strings.Split(base64Data, ";")
	if len(parts) < 2 {
		return "", fmt.Errorf("invalid data URL format")
	}
	
	contentType := strings.TrimPrefix(parts[0], "data:")
	return contentType, nil
}

// ValidateBase64Image validates and extracts image data from base64 string
func ValidateBase64Image(base64Data string, supportedTypes []string, maxSize int64) (string, error) {
	// Check if it's a data URL
	if strings.HasPrefix(base64Data, "data:") {
		// Extract content type
		contentType, err := GetContentTypeFromBase64(base64Data)
		if err != nil {
			return "", fmt.Errorf("invalid data URL: %v", err)
		}
		
		// Validate content type
		if !ValidateImageType(contentType, supportedTypes) {
			return "", fmt.Errorf("unsupported image type: %s", contentType)
		}
		
		// Extract base64 data
		parts := strings.Split(base64Data, ",")
		if len(parts) != 2 {
			return "", fmt.Errorf("invalid data URL format")
		}
		base64Data = parts[1]
	}
	
	// Validate base64 format
	decoded, err := base64.StdEncoding.DecodeString(base64Data)
	if err != nil {
		return "", fmt.Errorf("invalid base64 encoding: %v", err)
	}
	
	// Check file size
	if maxSize > 0 && int64(len(decoded)) > maxSize {
		return "", fmt.Errorf("image size too large: %d bytes (max: %d bytes)", len(decoded), maxSize)
	}
	
	// Validate that it's actually an image by checking magic bytes
	contentType := http.DetectContentType(decoded)
	if !strings.HasPrefix(contentType, "image/") {
		return "", fmt.Errorf("file is not an image: detected type %s", contentType)
	}
	
	return base64Data, nil
}

// DownloadImageFromURL downloads image from URL and converts to base64
func DownloadImageFromURL(url string, maxSize int64) (string, error) {
	// Make HTTP request
	resp, err := http.Get(url)
	if err != nil {
		return "", fmt.Errorf("failed to download image: %v", err)
	}
	defer resp.Body.Close()
	
	// Check status code
	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("failed to download image: HTTP %d", resp.StatusCode)
	}
	
	// Check content type
	contentType := resp.Header.Get("Content-Type")
	if !strings.HasPrefix(contentType, "image/") {
		return "", fmt.Errorf("URL does not point to an image: %s", contentType)
	}
	
	// Check content length
	if resp.ContentLength > maxSize {
		return "", fmt.Errorf("image too large: %d bytes (max: %d bytes)", resp.ContentLength, maxSize)
	}
	
	// Read image data
	imageData, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("failed to read image data: %v", err)
	}
	
	// Check actual size
	if maxSize > 0 && int64(len(imageData)) > maxSize {
		return "", fmt.Errorf("image too large: %d bytes (max: %d bytes)", len(imageData), maxSize)
	}
	
	// Convert to base64
	base64Data := base64.StdEncoding.EncodeToString(imageData)
	
	return base64Data, nil
}

// GetFileExtensionFromMime returns file extension for given MIME type
func GetFileExtensionFromMime(mimeType string) string {
	extensions, err := mime.ExtensionsByType(mimeType)
	if err != nil || len(extensions) == 0 {
		return ".jpg" // Default fallback
	}
	return extensions[0]
}

// SanitizeFilename removes or replaces unsafe characters in filename
func SanitizeFilename(filename string) string {
	// Replace unsafe characters
	unsafe := []string{"/", "\\", ":", "*", "?", "\"", "<", ">", "|"}
	safe := filename
	for _, char := range unsafe {
		safe = strings.ReplaceAll(safe, char, "_")
	}
	return safe
}