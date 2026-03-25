//go:build ignore

package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"
)

const baseURL = "http://localhost:8081/api/v1"

var client = &http.Client{Timeout: 10 * time.Second}

type TestResult struct {
	Endpoint string
	Method   string
	Status   int
	Response string
	Error    string
}

func makeRequest(method, endpoint, token string, body interface{}) TestResult {
	result := TestResult{Endpoint: endpoint, Method: method}

	var reqBody io.Reader
	if body != nil {
		jsonBody, _ := json.Marshal(body)
		reqBody = bytes.NewBuffer(jsonBody)
	}

	req, err := http.NewRequest(method, baseURL+endpoint, reqBody)
	if err != nil {
		result.Error = err.Error()
		return result
	}

	req.Header.Set("Content-Type", "application/json")
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}

	resp, err := client.Do(req)
	if err != nil {
		result.Error = err.Error()
		return result
	}
	defer resp.Body.Close()

	result.Status = resp.StatusCode
	bodyBytes, _ := io.ReadAll(resp.Body)
	result.Response = string(bodyBytes)

	return result
}

func printResult(r TestResult) {
	statusIcon := "✅"
	if r.Status >= 400 || r.Error != "" {
		statusIcon = "❌"
	}
	fmt.Printf("\n%s %s %s\n", statusIcon, r.Method, r.Endpoint)
	if r.Error != "" {
		fmt.Printf("   Error: %s\n", r.Error)
	} else {
		fmt.Printf("   Status: %d\n", r.Status)
		if len(r.Response) > 500 {
			fmt.Printf("   Response: %s...\n", r.Response[:500])
		} else {
			fmt.Printf("   Response: %s\n", r.Response)
		}
	}
}

func main() {
	fmt.Println("=== PawPal Caregiver API Test Suite ===")
	fmt.Println()

	// Step 1: Register a new test user
	fmt.Println("📝 Step 1: Registering test user...")
	email := fmt.Sprintf("caregiver_test_%d@test.com", time.Now().Unix())
	registerBody := map[string]interface{}{
		"email":        email,
		"password":     "Test@123456",
		"full_name":    "Test Caregiver",
		"phone_number": "+923001234567",
	}
	result := makeRequest("POST", "/auth/signup", "", registerBody)
	printResult(result)

	// Extract token from response
	var authResp map[string]interface{}
	var token string
	var userID string
	if err := json.Unmarshal([]byte(result.Response), &authResp); err == nil {
		if t, ok := authResp["accessToken"].(string); ok {
			token = t
		}
		if user, ok := authResp["user"].(map[string]interface{}); ok {
			if uid, ok := user["uid"].(string); ok {
				userID = uid
			}
		}
	}

	if token == "" {
		fmt.Println("\n❌ Failed to get auth token. Aborting tests.")
		return
	}
	fmt.Printf("\n✅ Got token for user: %s\n", userID)

	// Step 2: Test Service Types
	fmt.Println("\n📝 Step 2: Testing Service Types endpoint...")
	result = makeRequest("GET", "/caregivers/service-types", token, nil)
	printResult(result)

	// Extract a service type ID for later use
	var serviceTypes map[string]interface{}
	var dogWalkingTypeID string
	if err := json.Unmarshal([]byte(result.Response), &serviceTypes); err == nil {
		if types, ok := serviceTypes["serviceTypes"].([]interface{}); ok && len(types) > 0 {
			for _, t := range types {
				if tm, ok := t.(map[string]interface{}); ok {
					if name, ok := tm["name"].(string); ok && name == "dog_walking" {
						dogWalkingTypeID = tm["id"].(string)
						break
					}
				}
			}
		}
	}
	fmt.Printf("   Dog Walking Service Type ID: %s\n", dogWalkingTypeID)

	// Step 3: Create Caregiver Profile
	fmt.Println("\n📝 Step 3: Creating Caregiver Profile...")
	profileBody := map[string]interface{}{
		"bio":                "Professional pet caregiver with 5 years of experience",
		"yearsOfExperience":  5,
		"headline":           "Experienced Pet Caregiver in Lahore",
		"city":               "Lahore",
		"state":              "Punjab",
		"latitude":           31.5204,
		"longitude":          74.3587,
		"serviceRadiusKm":    15,
		"acceptedPetTypes":   []string{"dog", "cat"},
		"acceptedPetSizes":   []string{"small", "medium", "large"},
		"maxPetsAtOnce":      4,
		"hasFencedYard":      true,
		"hasOwnTransport":    true,
		"smokeFreeHome":      true,
	}
	result = makeRequest("POST", "/caregivers/profile", token, profileBody)
	printResult(result)

	// Extract caregiver profile ID
	var profileResp map[string]interface{}
	var caregiverID string
	if err := json.Unmarshal([]byte(result.Response), &profileResp); err == nil {
		if profile, ok := profileResp["profile"].(map[string]interface{}); ok {
			if id, ok := profile["id"].(string); ok {
				caregiverID = id
			}
		}
	}

	if caregiverID == "" {
		fmt.Println("\n⚠️ Failed to create caregiver profile. Continuing with other tests...")
	} else {
		fmt.Printf("   Caregiver Profile ID: %s\n", caregiverID)
	}

	// Step 4: Get Profile
	fmt.Println("\n📝 Step 4: Getting Caregiver Profile...")
	result = makeRequest("GET", "/caregivers/profile", token, nil)
	printResult(result)

	// Step 5: Update Profile
	fmt.Println("\n📝 Step 5: Updating Caregiver Profile...")
	updateBody := map[string]interface{}{
		"bio":               "Updated bio - Expert pet caregiver!",
		"yearsOfExperience": 6,
	}
	result = makeRequest("PUT", "/caregivers/profile", token, updateBody)
	printResult(result)

	// Step 6: Add Service (if profile was created)
	if caregiverID != "" && dogWalkingTypeID != "" {
		fmt.Println("\n📝 Step 6: Adding Dog Walking Service...")
		serviceBody := map[string]interface{}{
			"serviceTypeId":     dogWalkingTypeID,
			"rateType":          "per_walk",
			"rateAmount":        500,
			"description":       "Professional dog walking - 30 min session",
			"durationMinutes":   30,
			"additionalPetRate": 200,
		}
		result = makeRequest("POST", "/caregivers/services", token, serviceBody)
		printResult(result)

		// Extract service ID
		var serviceResp map[string]interface{}
		var serviceID string
		if err := json.Unmarshal([]byte(result.Response), &serviceResp); err == nil {
			if service, ok := serviceResp["service"].(map[string]interface{}); ok {
				if id, ok := service["id"].(string); ok {
					serviceID = id
				}
			}
		}

		if serviceID != "" {
			// Step 7: Update Service
			fmt.Println("\n📝 Step 7: Updating Service...")
			updateSvcBody := map[string]interface{}{
				"rateAmount": 600,
			}
			result = makeRequest("PUT", "/caregivers/services/"+serviceID, token, updateSvcBody)
			printResult(result)
		}
	}

	// Step 8: Set Availability
	fmt.Println("\n📝 Step 8: Setting Availability...")
	availabilityBody := map[string]interface{}{
		"slots": []map[string]interface{}{
			{"dayOfWeek": 1, "startTime": "09:00", "endTime": "17:00", "isAvailable": true},
			{"dayOfWeek": 2, "startTime": "09:00", "endTime": "17:00", "isAvailable": true},
			{"dayOfWeek": 3, "startTime": "09:00", "endTime": "17:00", "isAvailable": true},
			{"dayOfWeek": 4, "startTime": "09:00", "endTime": "17:00", "isAvailable": true},
			{"dayOfWeek": 5, "startTime": "09:00", "endTime": "17:00", "isAvailable": true},
		},
	}
	result = makeRequest("POST", "/caregivers/availability", token, availabilityBody)
	printResult(result)

	// Step 9: Get Availability
	fmt.Println("\n📝 Step 9: Getting Availability...")
	result = makeRequest("GET", "/caregivers/availability", token, nil)
	printResult(result)

	// Step 10: Add Blocked Date
	fmt.Println("\n📝 Step 10: Adding Blocked Date...")
	blockedBody := map[string]interface{}{
		"blockedDate": "2026-04-01",
		"reason":      "On vacation",
	}
	result = makeRequest("POST", "/caregivers/blocked-dates", token, blockedBody)
	printResult(result)

	// Step 11: Search Caregivers
	fmt.Println("\n📝 Step 11: Searching Caregivers...")
	result = makeRequest("GET", "/caregivers/search?city=Lahore&limit=10", token, nil)
	printResult(result)

	// Step 12: Get Specific Caregiver
	if caregiverID != "" {
		fmt.Println("\n📝 Step 12: Getting Specific Caregiver...")
		result = makeRequest("GET", "/caregivers/"+caregiverID, token, nil)
		printResult(result)
	}

	fmt.Println("\n=== Test Suite Complete ===")
}
