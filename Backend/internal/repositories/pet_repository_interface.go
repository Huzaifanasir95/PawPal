package repositories

import (
	"context"

	"github.com/google/uuid"

	"pawpal-backend/internal/models"
)

// PetRepositoryInterface defines the interface for pet repository operations
type PetRepositoryInterface interface {
	// Standard methods
	CreatePet(ctx context.Context, pet *models.Pet) error
	GetPetByID(ctx context.Context, petID uuid.UUID) (*models.Pet, error)
	GetPetsByOwnerID(ctx context.Context, ownerID uuid.UUID) ([]models.Pet, error)
	UpdatePet(ctx context.Context, pet *models.Pet) error
	DeletePet(ctx context.Context, petID uuid.UUID) error
	GetVerifiedPets(ctx context.Context) ([]models.Pet, error)
	SearchPetsByBreed(ctx context.Context, breed string) ([]models.Pet, error)
	GetPetCount(ctx context.Context, ownerID uuid.UUID) (int64, error)

	// Legacy methods for backward compatibility
	Create(ctx context.Context, pet *models.Pet) error
	GetByID(ctx context.Context, petID uuid.UUID) (*models.Pet, error)
	GetByOwnerID(ctx context.Context, ownerID uuid.UUID) ([]models.Pet, error)
	Update(ctx context.Context, pet *models.Pet) error
	Delete(ctx context.Context, petID uuid.UUID) error
	GetVerified(ctx context.Context) ([]models.Pet, error)
	SearchByBreed(ctx context.Context, breed string) ([]models.Pet, error)
	GetCount(ctx context.Context, ownerID uuid.UUID) (int64, error)
}
