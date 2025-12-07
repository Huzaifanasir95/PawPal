package repositories

import (
	"context"
	"encoding/json"
	"fmt"
	"net/url"
	"time"

	"github.com/google/uuid"

	"pawpal-backend/internal/database"
	"pawpal-backend/internal/models"
)

// rawPet is used to unmarshal Supabase response with snake_case fields
type rawPet struct {
	ID                     uuid.UUID  `json:"id"`
	OwnerID                uuid.UUID  `json:"owner_id"`
	Name                   string     `json:"name"`
	Type                   string     `json:"type"`
	Breed                  string     `json:"breed"`
	Age                    int        `json:"age"`
	AgeUnit                string     `json:"age_unit"`
	Gender                 string     `json:"gender"`
	Color                  string     `json:"color"`
	Weight                 float64    `json:"weight"`
	WeightUnit             string     `json:"weight_unit"`
	ImageURL               *string    `json:"image_url"`
	ImageLocalPath         *string    `json:"image_local_path"`
	ImageURLs              []string   `json:"image_urls"`
	IsVerified             bool       `json:"is_verified"`
	VerificationConfidence *float64   `json:"verification_confidence"`
	VerifiedBreed          *string    `json:"verified_breed"`
	Bio                    *string    `json:"bio"`
	IsAdopted              bool       `json:"is_adopted"`
	CreatedAt              time.Time  `json:"created_at"`
	UpdatedAt              time.Time  `json:"updated_at"`
}

// convertToPet converts rawPet (snake_case) to models.Pet (camelCase)
func convertToPet(raw rawPet) models.Pet {
	return models.Pet{
		ID:                     raw.ID,
		OwnerID:                raw.OwnerID,
		Name:                   raw.Name,
		Type:                   raw.Type,
		Breed:                  raw.Breed,
		Age:                    raw.Age,
		AgeUnit:                raw.AgeUnit,
		Gender:                 raw.Gender,
		Color:                  raw.Color,
		Weight:                 raw.Weight,
		WeightUnit:             raw.WeightUnit,
		ImageURL:               raw.ImageURL,
		ImageLocalPath:         raw.ImageLocalPath,
		ImageURLs:              raw.ImageURLs,
		IsVerified:             raw.IsVerified,
		VerificationConfidence: raw.VerificationConfidence,
		VerifiedBreed:          raw.VerifiedBreed,
		Bio:                    raw.Bio,
		IsAdopted:              raw.IsAdopted,
		CreatedAt:              raw.CreatedAt,
		UpdatedAt:              raw.UpdatedAt,
	}
}

// PetRepositorySupabase handles pet database operations using Supabase REST API
type PetRepositorySupabase struct {
	client *database.SupabaseClient
}

// NewPetRepositorySupabase creates a new PetRepositorySupabase
func NewPetRepositorySupabase(client *database.SupabaseClient) *PetRepositorySupabase {
	return &PetRepositorySupabase{client: client}
}

// CreatePet creates a new pet
func (r *PetRepositorySupabase) CreatePet(ctx context.Context, pet *models.Pet) error {
	// Generate UUID if not provided
	if pet.ID == uuid.Nil {
		pet.ID = uuid.New()
	}

	// Set timestamps
	now := time.Now()
	pet.CreatedAt = now
	pet.UpdatedAt = now

	// Set defaults
	if pet.AgeUnit == "" {
		pet.AgeUnit = "years"
	}
	if pet.WeightUnit == "" {
		pet.WeightUnit = "kg"
	}
	if pet.ImageURLs == nil {
		pet.ImageURLs = []string{}
	}

	data := map[string]interface{}{
		"id":                      pet.ID,
		"owner_id":                pet.OwnerID,
		"name":                    pet.Name,
		"type":                    pet.Type,
		"breed":                   pet.Breed,
		"age":                     pet.Age,
		"age_unit":                pet.AgeUnit,
		"gender":                  pet.Gender,
		"color":                   pet.Color,
		"weight":                  pet.Weight,
		"weight_unit":             pet.WeightUnit,
		"image_url":               pet.ImageURL,
		"image_local_path":        pet.ImageLocalPath,
		"image_urls":              pet.ImageURLs,
		"is_verified":             pet.IsVerified,
		"verification_confidence": pet.VerificationConfidence,
		"verified_breed":          pet.VerifiedBreed,
		"bio":                     pet.Bio,
		"is_adopted":              pet.IsAdopted,
		"created_at":              pet.CreatedAt,
		"updated_at":              pet.UpdatedAt,
	}

	respData, err := r.client.Insert(ctx, "pets", data)
	if err != nil {
		return fmt.Errorf("failed to create pet: %w", err)
	}

	// Unmarshal with snake_case tags
	var rawPets []rawPet
	if err := json.Unmarshal(respData, &rawPets); err != nil {
		return fmt.Errorf("failed to parse response: %w", err)
	}

	if len(rawPets) > 0 {
		*pet = convertToPet(rawPets[0])
	}

	return nil
}

// GetPetByID gets a pet by ID
func (r *PetRepositorySupabase) GetPetByID(ctx context.Context, petID uuid.UUID) (*models.Pet, error) {
	query := map[string]string{
		"id":     fmt.Sprintf("eq.%s", petID.String()),
		"select": "*",
	}

	respData, err := r.client.Select(ctx, "pets", query)
	if err != nil {
		return nil, fmt.Errorf("failed to get pet: %w", err)
	}

	var rawPets []rawPet
	if err := json.Unmarshal(respData, &rawPets); err != nil {
		return nil, fmt.Errorf("failed to parse response: %w", err)
	}

	if len(rawPets) == 0 {
		return nil, nil // Pet not found
	}

	pet := convertToPet(rawPets[0])
	return &pet, nil
}

// GetPetsByOwnerID gets all pets owned by a user
func (r *PetRepositorySupabase) GetPetsByOwnerID(ctx context.Context, ownerID uuid.UUID) ([]models.Pet, error) {
	query := map[string]string{
		"owner_id": fmt.Sprintf("eq.%s", ownerID.String()),
		"select":   "*",
		"order":    "created_at.desc",
	}

	respData, err := r.client.Select(ctx, "pets", query)
	if err != nil {
		return nil, fmt.Errorf("failed to get pets: %w", err)
	}

	var rawPets []rawPet
	if err := json.Unmarshal(respData, &rawPets); err != nil {
		return nil, fmt.Errorf("failed to parse response: %w", err)
	}

	pets := make([]models.Pet, len(rawPets))
	for i, raw := range rawPets {
		pets[i] = convertToPet(raw)
	}

	return pets, nil
}

// UpdatePet updates a pet
func (r *PetRepositorySupabase) UpdatePet(ctx context.Context, pet *models.Pet) error {
	query := map[string]string{
		"id": fmt.Sprintf("eq.%s", pet.ID.String()),
	}

	pet.UpdatedAt = time.Now()

	data := map[string]interface{}{
		"name":                    pet.Name,
		"type":                    pet.Type,
		"breed":                   pet.Breed,
		"age":                     pet.Age,
		"age_unit":                pet.AgeUnit,
		"gender":                  pet.Gender,
		"color":                   pet.Color,
		"weight":                  pet.Weight,
		"weight_unit":             pet.WeightUnit,
		"image_url":               pet.ImageURL,
		"image_local_path":        pet.ImageLocalPath,
		"image_urls":              pet.ImageURLs,
		"is_verified":             pet.IsVerified,
		"verification_confidence": pet.VerificationConfidence,
		"verified_breed":          pet.VerifiedBreed,
		"bio":                     pet.Bio,
		"is_adopted":              pet.IsAdopted,
		"updated_at":              pet.UpdatedAt,
	}

	respData, err := r.client.Update(ctx, "pets", query, data)
	if err != nil {
		return fmt.Errorf("failed to update pet: %w", err)
	}

	var rawPets []rawPet
	if err := json.Unmarshal(respData, &rawPets); err != nil {
		return fmt.Errorf("failed to parse response: %w", err)
	}

	if len(rawPets) > 0 {
		*pet = convertToPet(rawPets[0])
	}

	return nil
}

// DeletePet deletes a pet
func (r *PetRepositorySupabase) DeletePet(ctx context.Context, petID uuid.UUID) error {
	query := map[string]string{
		"id": fmt.Sprintf("eq.%s", petID.String()),
	}

	err := r.client.Delete(ctx, "pets", query)
	if err != nil {
		return fmt.Errorf("failed to delete pet: %w", err)
	}

	return nil
}

// GetVerifiedPets gets all verified pets
func (r *PetRepositorySupabase) GetVerifiedPets(ctx context.Context) ([]models.Pet, error) {
	query := map[string]string{
		"is_verified": "eq.true",
		"select":      "*",
		"order":       "created_at.desc",
	}

	respData, err := r.client.Select(ctx, "pets", query)
	if err != nil {
		return nil, fmt.Errorf("failed to get verified pets: %w", err)
	}

	var rawPets []rawPet
	if err := json.Unmarshal(respData, &rawPets); err != nil {
		return nil, fmt.Errorf("failed to parse response: %w", err)
	}

	pets := make([]models.Pet, len(rawPets))
	for i, raw := range rawPets {
		pets[i] = convertToPet(raw)
	}

	return pets, nil
}

// SearchPetsByBreed searches pets by breed
func (r *PetRepositorySupabase) SearchPetsByBreed(ctx context.Context, breed string) ([]models.Pet, error) {
	query := map[string]string{
		"breed":  fmt.Sprintf("ilike.%%%s%%", url.QueryEscape(breed)),
		"select": "*",
		"order":  "created_at.desc",
	}

	respData, err := r.client.Select(ctx, "pets", query)
	if err != nil {
		return nil, fmt.Errorf("failed to search pets: %w", err)
	}

	var rawPets []rawPet
	if err := json.Unmarshal(respData, &rawPets); err != nil {
		return nil, fmt.Errorf("failed to parse response: %w", err)
	}

	pets := make([]models.Pet, len(rawPets))
	for i, raw := range rawPets {
		pets[i] = convertToPet(raw)
	}

	return pets, nil
}

// GetPetCount gets the total number of pets for a user
func (r *PetRepositorySupabase) GetPetCount(ctx context.Context, ownerID uuid.UUID) (int64, error) {
	query := map[string]string{
		"owner_id": fmt.Sprintf("eq.%s", ownerID.String()),
		"select":   "count",
	}

	respData, err := r.client.Select(ctx, "pets", query)
	if err != nil {
		return 0, fmt.Errorf("failed to get pet count: %w", err)
	}

	// Supabase returns count in a specific format
	var result []map[string]interface{}
	if err := json.Unmarshal(respData, &result); err != nil {
		return 0, fmt.Errorf("failed to parse count response: %w", err)
	}

	if len(result) > 0 {
		if count, ok := result[0]["count"].(float64); ok {
			return int64(count), nil
		}
	}

	// Fallback: get all pets and count them
	pets, err := r.GetPetsByOwnerID(ctx, ownerID)
	if err != nil {
		return 0, err
	}

	return int64(len(pets)), nil
}

// Legacy adapter methods for compatibility with existing handlers

func (r *PetRepositorySupabase) Create(ctx context.Context, pet *models.Pet) error {
	return r.CreatePet(ctx, pet)
}

func (r *PetRepositorySupabase) GetByID(ctx context.Context, petID uuid.UUID) (*models.Pet, error) {
	return r.GetPetByID(ctx, petID)
}

func (r *PetRepositorySupabase) GetByOwnerID(ctx context.Context, ownerID uuid.UUID) ([]models.Pet, error) {
	return r.GetPetsByOwnerID(ctx, ownerID)
}

func (r *PetRepositorySupabase) Update(ctx context.Context, pet *models.Pet) error {
	return r.UpdatePet(ctx, pet)
}

func (r *PetRepositorySupabase) Delete(ctx context.Context, petID uuid.UUID) error {
	return r.DeletePet(ctx, petID)
}

func (r *PetRepositorySupabase) GetVerified(ctx context.Context) ([]models.Pet, error) {
	return r.GetVerifiedPets(ctx)
}

func (r *PetRepositorySupabase) SearchByBreed(ctx context.Context, breed string) ([]models.Pet, error) {
	return r.SearchPetsByBreed(ctx, breed)
}

func (r *PetRepositorySupabase) GetCount(ctx context.Context, ownerID uuid.UUID) (int64, error) {
	return r.GetPetCount(ctx, ownerID)
}
