package utils

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/base64"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"path"
	"strings"
	"time"
)

const defaultStorageBucket = "pawpal-images"

// ResolveImageReference normalizes an image reference and returns an HTTP URL when possible.
// Accepts: http(s) URL, data URI, or raw base64 image bytes.
func ResolveImageReference(ctx context.Context, imageRef, objectPrefix string) (string, error) {
	trimmed := strings.TrimSpace(imageRef)
	if trimmed == "" {
		return "", nil
	}

	if isHTTPURL(trimmed) {
		return trimmed, nil
	}

	contentType, rawBase64, err := parseImagePayload(trimmed)
	if err != nil {
		return "", err
	}

	rawBytes, err := base64.StdEncoding.DecodeString(rawBase64)
	if err != nil {
		return "", fmt.Errorf("invalid base64 image data: %w", err)
	}

	if len(rawBytes) == 0 {
		return "", fmt.Errorf("image payload is empty")
	}

	if contentType == "" {
		contentType = http.DetectContentType(rawBytes)
	}
	if !strings.HasPrefix(contentType, "image/") {
		return "", fmt.Errorf("unsupported image payload type: %s", contentType)
	}

	return uploadImageBytesToSupabaseStorage(ctx, rawBytes, contentType, objectPrefix)
}

// ResolveImageReferenceBestEffort is a non-failing variant for response normalization.
func ResolveImageReferenceBestEffort(ctx context.Context, imageRef, objectPrefix string) string {
	resolved, err := ResolveImageReference(ctx, imageRef, objectPrefix)
	if err != nil {
		return ""
	}
	return resolved
}

// ResolveImageReferences normalizes and uploads a list of image references.
func ResolveImageReferences(ctx context.Context, refs []string, objectPrefix string) ([]string, error) {
	if len(refs) == 0 {
		return []string{}, nil
	}

	resolved := make([]string, 0, len(refs))
	for i, ref := range refs {
		url, err := ResolveImageReference(ctx, ref, fmt.Sprintf("%s/%d", objectPrefix, i))
		if err != nil {
			return nil, err
		}
		if url != "" {
			resolved = append(resolved, url)
		}
	}

	return resolved, nil
}

// ResolveImageReferencesBestEffort normalizes a list for read APIs.
func ResolveImageReferencesBestEffort(ctx context.Context, refs []string, objectPrefix string) []string {
	if len(refs) == 0 {
		return []string{}
	}

	resolved := make([]string, 0, len(refs))
	for i, ref := range refs {
		url := ResolveImageReferenceBestEffort(ctx, ref, fmt.Sprintf("%s/%d", objectPrefix, i))
		if url != "" {
			resolved = append(resolved, url)
		}
	}

	return resolved
}

func parseImagePayload(input string) (contentType string, rawBase64 string, err error) {
	if strings.HasPrefix(input, "data:") {
		parts := strings.SplitN(input, ",", 2)
		if len(parts) != 2 {
			return "", "", fmt.Errorf("invalid data URI")
		}

		meta := parts[0]
		if !strings.Contains(meta, ";base64") {
			return "", "", fmt.Errorf("data URI must be base64 encoded")
		}

		contentType = strings.TrimPrefix(strings.Split(meta, ";")[0], "data:")
		return contentType, parts[1], nil
	}

	// Raw base64 payload fallback.
	return "", input, nil
}

func uploadImageBytesToSupabaseStorage(ctx context.Context, data []byte, contentType, objectPrefix string) (string, error) {
	supabaseURL := strings.TrimSpace(os.Getenv("SUPABASE_URL"))
	apiKey := strings.TrimSpace(os.Getenv("SUPABASE_SERVICE_ROLE_KEY"))
	if apiKey == "" {
		apiKey = strings.TrimSpace(os.Getenv("SUPABASE_ANON_KEY"))
	}

	if supabaseURL == "" || apiKey == "" {
		return "", fmt.Errorf("supabase storage is not configured")
	}

	bucket := strings.TrimSpace(os.Getenv("SUPABASE_STORAGE_BUCKET"))
	if bucket == "" {
		bucket = defaultStorageBucket
	}

	ext := GetFileExtensionFromMime(contentType)
	sum := sha256.Sum256(data)
	hash := fmt.Sprintf("%x", sum[:12])
	prefix := strings.Trim(strings.TrimSpace(objectPrefix), "/")
	if prefix == "" {
		prefix = "uploads"
	}
	objectPath := path.Join(prefix, fmt.Sprintf("%s%s", hash, ext))

	endpoint := strings.TrimRight(supabaseURL, "/") + "/storage/v1/object/" + bucket + "/" + objectPath
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, endpoint, bytes.NewReader(data))
	if err != nil {
		return "", err
	}

	req.Header.Set("Authorization", "Bearer "+apiKey)
	req.Header.Set("apikey", apiKey)
	req.Header.Set("Content-Type", contentType)
	req.Header.Set("x-upsert", "true")

	client := &http.Client{Timeout: 20 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		body, _ := io.ReadAll(resp.Body)
		return "", fmt.Errorf("supabase storage upload failed: %d %s", resp.StatusCode, strings.TrimSpace(string(body)))
	}

	publicURL := strings.TrimRight(supabaseURL, "/") + "/storage/v1/object/public/" + bucket + "/" + url.PathEscape(objectPath)
	publicURL = strings.ReplaceAll(publicURL, "%2F", "/")
	return publicURL, nil
}

func isHTTPURL(value string) bool {
	u, err := url.Parse(value)
	if err != nil {
		return false
	}
	if u.Scheme != "http" && u.Scheme != "https" {
		return false
	}
	return u.Host != ""
}
