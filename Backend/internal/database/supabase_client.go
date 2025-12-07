package database

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"time"
)

// SupabaseClient handles all Supabase REST API operations
type SupabaseClient struct {
	baseURL    string
	apiKey     string
	serviceKey string
	httpClient *http.Client
}

// NewSupabaseClient creates a new Supabase REST API client
func NewSupabaseClient() *SupabaseClient {
	return &SupabaseClient{
		baseURL:    os.Getenv("SUPABASE_URL"),
		apiKey:     os.Getenv("SUPABASE_ANON_KEY"),
		serviceKey: os.Getenv("SUPABASE_SERVICE_ROLE_KEY"),
		httpClient: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
}

// Request makes a REST API request to Supabase
func (c *SupabaseClient) Request(ctx context.Context, method, path string, body interface{}, useServiceRole bool) ([]byte, error) {
	url := fmt.Sprintf("%s/rest/v1/%s", c.baseURL, path)

	var reqBody io.Reader
	if body != nil {
		jsonData, err := json.Marshal(body)
		if err != nil {
			return nil, fmt.Errorf("failed to marshal request body: %w", err)
		}
		reqBody = bytes.NewBuffer(jsonData)
	}

	req, err := http.NewRequestWithContext(ctx, method, url, reqBody)
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	// Set headers
	apiKey := c.apiKey
	if useServiceRole && c.serviceKey != "" {
		apiKey = c.serviceKey
	}

	req.Header.Set("apikey", apiKey)
	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", apiKey))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Prefer", "return=representation")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("request failed: %w", err)
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response: %w", err)
	}

	if resp.StatusCode >= 400 {
		return nil, fmt.Errorf("API error (status %d): %s", resp.StatusCode, string(respBody))
	}

	return respBody, nil
}

// Insert inserts a new record into a table
func (c *SupabaseClient) Insert(ctx context.Context, table string, data interface{}) ([]byte, error) {
	return c.Request(ctx, "POST", table, data, true)
}

// Select queries records from a table
func (c *SupabaseClient) Select(ctx context.Context, table string, query map[string]string) ([]byte, error) {
	path := table
	if len(query) > 0 {
		path += "?"
		first := true
		for key, value := range query {
			if !first {
				path += "&"
			}
			path += fmt.Sprintf("%s=%s", key, value)
			first = false
		}
	}
	return c.Request(ctx, "GET", path, nil, true)
}

// Update updates records in a table
func (c *SupabaseClient) Update(ctx context.Context, table string, query map[string]string, data interface{}) ([]byte, error) {
	path := table
	if len(query) > 0 {
		path += "?"
		first := true
		for key, value := range query {
			if !first {
				path += "&"
			}
			path += fmt.Sprintf("%s=%s", key, value)
			first = false
		}
	}
	return c.Request(ctx, "PATCH", path, data, true)
}

// Delete deletes records from a table
func (c *SupabaseClient) Delete(ctx context.Context, table string, query map[string]string) error {
	path := table
	if len(query) > 0 {
		path += "?"
		first := true
		for key, value := range query {
			if !first {
				path += "&"
			}
			path += fmt.Sprintf("%s=%s", key, value)
			first = false
		}
	}
	_, err := c.Request(ctx, "DELETE", path, nil, true)
	return err
}

// RPC calls a Supabase stored procedure/function
func (c *SupabaseClient) RPC(ctx context.Context, functionName string, params interface{}) ([]byte, error) {
	url := fmt.Sprintf("%s/rest/v1/rpc/%s", c.baseURL, functionName)

	var reqBody io.Reader
	if params != nil {
		jsonData, err := json.Marshal(params)
		if err != nil {
			return nil, fmt.Errorf("failed to marshal params: %w", err)
		}
		reqBody = bytes.NewBuffer(jsonData)
	}

	req, err := http.NewRequestWithContext(ctx, "POST", url, reqBody)
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	req.Header.Set("apikey", c.serviceKey)
	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", c.serviceKey))
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("RPC request failed: %w", err)
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response: %w", err)
	}

	if resp.StatusCode >= 400 {
		return nil, fmt.Errorf("RPC error (status %d): %s", resp.StatusCode, string(respBody))
	}

	return respBody, nil
}

// Health checks if Supabase is accessible
func (c *SupabaseClient) Health(ctx context.Context) error {
	url := fmt.Sprintf("%s/rest/v1/", c.baseURL)
	
	req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
	if err != nil {
		return err
	}

	req.Header.Set("apikey", c.apiKey)
	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", c.apiKey))

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 400 {
		return fmt.Errorf("health check failed with status %d", resp.StatusCode)
	}

	return nil
}
