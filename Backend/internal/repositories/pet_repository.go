package repositories

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"pawpal-backend/internal/models"
)

// PetRepository handles pet database operations
type PetRepository struct {
	db *pgxpool.Pool
}

// NewPetRepository creates a new PetRepository
func NewPetRepository(db *pgxpool.Pool) *PetRepository {
	return &PetRepository{db: db}
}

// Create creates a new pet
func (r *PetRepository) Create(ctx context.Context, pet *models.Pet) error {
	query := `
		INSERT INTO pets (
			id, owner_id, name, type, breed, age, age_unit, gender, color, weight, weight_unit,
			image_url, image_local_path, image_urls, is_verified, verification_confidence,
			verified_breed, bio, is_adopted, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21)
		RETURNING id, created_at, updated_at`

	now := time.Now()
	pet.ID = uuid.New()
	pet.CreatedAt = now
	pet.UpdatedAt = now

	return r.db.QueryRow(ctx, query,
		pet.ID,
		pet.OwnerID,
		pet.Name,
		pet.Type,
		pet.Breed,
		pet.Age,
		pet.AgeUnit,
		pet.Gender,
		pet.Color,
		pet.Weight,
		pet.WeightUnit,
		pet.ImageURL,
		pet.ImageLocalPath,
		pet.ImageURLs,
		pet.IsVerified,
		pet.VerificationConfidence,
		pet.VerifiedBreed,
		pet.Bio,
		pet.IsAdopted,
		pet.CreatedAt,
		pet.UpdatedAt,
	).Scan(&pet.ID, &pet.CreatedAt, &pet.UpdatedAt)
}

// GetByID gets a pet by ID
func (r *PetRepository) GetByID(ctx context.Context, id uuid.UUID) (*models.Pet, error) {
	query := `
		SELECT id, owner_id, name, type, breed, age, age_unit, gender, color, weight, weight_unit,
			image_url, image_local_path, image_urls, is_verified, verification_confidence,
			verified_breed, bio, is_adopted, created_at, updated_at
		FROM pets WHERE id = $1`

	pet := &models.Pet{}
	err := r.db.QueryRow(ctx, query, id).Scan(
		&pet.ID,
		&pet.OwnerID,
		&pet.Name,
		&pet.Type,
		&pet.Breed,
		&pet.Age,
		&pet.AgeUnit,
		&pet.Gender,
		&pet.Color,
		&pet.Weight,
		&pet.WeightUnit,
		&pet.ImageURL,
		&pet.ImageLocalPath,
		&pet.ImageURLs,
		&pet.IsVerified,
		&pet.VerificationConfidence,
		&pet.VerifiedBreed,
		&pet.Bio,
		&pet.IsAdopted,
		&pet.CreatedAt,
		&pet.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return pet, nil
}

// GetByOwnerID gets all pets for a user
func (r *PetRepository) GetByOwnerID(ctx context.Context, ownerID uuid.UUID) ([]models.Pet, error) {
	query := `
		SELECT id, owner_id, name, type, breed, age, age_unit, gender, color, weight, weight_unit,
			image_url, image_local_path, image_urls, is_verified, verification_confidence,
			verified_breed, bio, is_adopted, created_at, updated_at
		FROM pets WHERE owner_id = $1 ORDER BY created_at DESC`

	rows, err := r.db.Query(ctx, query, ownerID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var pets []models.Pet
	for rows.Next() {
		pet := models.Pet{}
		err := rows.Scan(
			&pet.ID,
			&pet.OwnerID,
			&pet.Name,
			&pet.Type,
			&pet.Breed,
			&pet.Age,
			&pet.AgeUnit,
			&pet.Gender,
			&pet.Color,
			&pet.Weight,
			&pet.WeightUnit,
			&pet.ImageURL,
			&pet.ImageLocalPath,
			&pet.ImageURLs,
			&pet.IsVerified,
			&pet.VerificationConfidence,
			&pet.VerifiedBreed,
			&pet.Bio,
			&pet.IsAdopted,
			&pet.CreatedAt,
			&pet.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		pets = append(pets, pet)
	}
	return pets, nil
}

// GetVerifiedByOwnerID gets all verified pets for a user
func (r *PetRepository) GetVerifiedByOwnerID(ctx context.Context, ownerID uuid.UUID) ([]models.Pet, error) {
	query := `
		SELECT id, owner_id, name, type, breed, age, age_unit, gender, color, weight, weight_unit,
			image_url, image_local_path, image_urls, is_verified, verification_confidence,
			verified_breed, bio, is_adopted, created_at, updated_at
		FROM pets WHERE owner_id = $1 AND is_verified = true ORDER BY created_at DESC`

	rows, err := r.db.Query(ctx, query, ownerID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var pets []models.Pet
	for rows.Next() {
		pet := models.Pet{}
		err := rows.Scan(
			&pet.ID,
			&pet.OwnerID,
			&pet.Name,
			&pet.Type,
			&pet.Breed,
			&pet.Age,
			&pet.AgeUnit,
			&pet.Gender,
			&pet.Color,
			&pet.Weight,
			&pet.WeightUnit,
			&pet.ImageURL,
			&pet.ImageLocalPath,
			&pet.ImageURLs,
			&pet.IsVerified,
			&pet.VerificationConfidence,
			&pet.VerifiedBreed,
			&pet.Bio,
			&pet.IsAdopted,
			&pet.CreatedAt,
			&pet.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		pets = append(pets, pet)
	}
	return pets, nil
}

// SearchByBreed searches pets by breed
func (r *PetRepository) SearchByBreed(ctx context.Context, breed string) ([]models.Pet, error) {
	query := `
		SELECT id, owner_id, name, type, breed, age, age_unit, gender, color, weight, weight_unit,
			image_url, image_local_path, image_urls, is_verified, verification_confidence,
			verified_breed, bio, is_adopted, created_at, updated_at
		FROM pets WHERE breed = $1 ORDER BY created_at DESC`

	rows, err := r.db.Query(ctx, query, breed)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var pets []models.Pet
	for rows.Next() {
		pet := models.Pet{}
		err := rows.Scan(
			&pet.ID,
			&pet.OwnerID,
			&pet.Name,
			&pet.Type,
			&pet.Breed,
			&pet.Age,
			&pet.AgeUnit,
			&pet.Gender,
			&pet.Color,
			&pet.Weight,
			&pet.WeightUnit,
			&pet.ImageURL,
			&pet.ImageLocalPath,
			&pet.ImageURLs,
			&pet.IsVerified,
			&pet.VerificationConfidence,
			&pet.VerifiedBreed,
			&pet.Bio,
			&pet.IsAdopted,
			&pet.CreatedAt,
			&pet.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		pets = append(pets, pet)
	}
	return pets, nil
}

// Update updates a pet
func (r *PetRepository) Update(ctx context.Context, pet *models.Pet) error {
	query := `
		UPDATE pets SET
			name = $2, breed = $3, age = $4, age_unit = $5, gender = $6, color = $7,
			weight = $8, weight_unit = $9, image_urls = $10, bio = $11, is_adopted = $12, updated_at = $13
		WHERE id = $1`

	_, err := r.db.Exec(ctx, query,
		pet.ID,
		pet.Name,
		pet.Breed,
		pet.Age,
		pet.AgeUnit,
		pet.Gender,
		pet.Color,
		pet.Weight,
		pet.WeightUnit,
		pet.ImageURLs,
		pet.Bio,
		pet.IsAdopted,
		time.Now(),
	)
	return err
}

// Delete deletes a pet
func (r *PetRepository) Delete(ctx context.Context, id uuid.UUID) error {
	query := `DELETE FROM pets WHERE id = $1`
	_, err := r.db.Exec(ctx, query, id)
	return err
}

// GetCount gets the pet count for a user
func (r *PetRepository) GetCount(ctx context.Context, ownerID uuid.UUID) (int64, error) {
	query := `SELECT COUNT(*) FROM pets WHERE owner_id = $1`
	var count int64
	err := r.db.QueryRow(ctx, query, ownerID).Scan(&count)
	return count, err
}

// GetVerified gets all verified pets.
func (r *PetRepository) GetVerified(ctx context.Context) ([]models.Pet, error) {
	query := `
		SELECT id, owner_id, name, type, breed, age, age_unit, gender, color, weight, weight_unit,
			image_url, image_local_path, image_urls, is_verified, verification_confidence,
			verified_breed, bio, is_adopted, created_at, updated_at
		FROM pets WHERE is_verified = true ORDER BY created_at DESC`

	rows, err := r.db.Query(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var pets []models.Pet
	for rows.Next() {
		pet := models.Pet{}
		err := rows.Scan(
			&pet.ID,
			&pet.OwnerID,
			&pet.Name,
			&pet.Type,
			&pet.Breed,
			&pet.Age,
			&pet.AgeUnit,
			&pet.Gender,
			&pet.Color,
			&pet.Weight,
			&pet.WeightUnit,
			&pet.ImageURL,
			&pet.ImageLocalPath,
			&pet.ImageURLs,
			&pet.IsVerified,
			&pet.VerificationConfidence,
			&pet.VerifiedBreed,
			&pet.Bio,
			&pet.IsAdopted,
			&pet.CreatedAt,
			&pet.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		pets = append(pets, pet)
	}
	return pets, nil
}

// Standard adapter methods for interface compatibility.
func (r *PetRepository) CreatePet(ctx context.Context, pet *models.Pet) error {
	return r.Create(ctx, pet)
}

func (r *PetRepository) GetPetByID(ctx context.Context, petID uuid.UUID) (*models.Pet, error) {
	return r.GetByID(ctx, petID)
}

func (r *PetRepository) GetPetsByOwnerID(ctx context.Context, ownerID uuid.UUID) ([]models.Pet, error) {
	return r.GetByOwnerID(ctx, ownerID)
}

func (r *PetRepository) UpdatePet(ctx context.Context, pet *models.Pet) error {
	return r.Update(ctx, pet)
}

func (r *PetRepository) DeletePet(ctx context.Context, petID uuid.UUID) error {
	return r.Delete(ctx, petID)
}

func (r *PetRepository) GetVerifiedPets(ctx context.Context) ([]models.Pet, error) {
	return r.GetVerified(ctx)
}

func (r *PetRepository) SearchPetsByBreed(ctx context.Context, breed string) ([]models.Pet, error) {
	return r.SearchByBreed(ctx, breed)
}

func (r *PetRepository) GetPetCount(ctx context.Context, ownerID uuid.UUID) (int64, error) {
	return r.GetCount(ctx, ownerID)
}
