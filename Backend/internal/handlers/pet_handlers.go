package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	"pawpal-backend/internal/models"
	"pawpal-backend/internal/repositories"
	"pawpal-backend/internal/utils"
)

// PetHandlers handles pet endpoints
type PetHandlers struct {
	petRepo repositories.PetRepositoryInterface
}

// NewPetHandlers creates new PetHandlers
func NewPetHandlers(petRepo repositories.PetRepositoryInterface) *PetHandlers {
	return &PetHandlers{
		petRepo: petRepo,
	}
}

// CreatePet handles creating a new pet
func (h *PetHandlers) CreatePet(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	
	var req models.CreatePetRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.PetResponse{
			Success: false,
			Message: "Invalid request: " + err.Error(),
		})
		return
	}

	pet := &models.Pet{
		OwnerID:    parseUUID(userID),
		Name:       req.Name,
		Type:       req.Type,
		Breed:      req.Breed,
		Age:        req.Age,
		AgeUnit:    req.AgeUnit,
		Gender:     req.Gender,
		Color:      req.Color,
		Weight:     req.Weight,
		WeightUnit: req.WeightUnit,
		ImageURL:   nil,
		ImageLocalPath: nil,
		ImageURLs:  []string{},
		Bio:        req.Bio,
		IsAdopted:  false,
	}

	if req.ImageURL != nil && *req.ImageURL != "" {
		resolved, err := utils.ResolveImageReference(c.Request.Context(), *req.ImageURL, "pets/"+userID+"/primary")
		if err != nil {
			c.JSON(http.StatusBadRequest, models.PetResponse{Success: false, Message: "Invalid imageUrl: " + err.Error()})
			return
		}
		if resolved != "" {
			pet.ImageURL = &resolved
		}
	}

	if len(req.ImageURLs) > 0 {
		resolvedList, err := utils.ResolveImageReferences(c.Request.Context(), req.ImageURLs, "pets/"+userID+"/gallery")
		if err != nil {
			c.JSON(http.StatusBadRequest, models.PetResponse{Success: false, Message: "Invalid imageUrls: " + err.Error()})
			return
		}
		pet.ImageURLs = resolvedList
		if pet.ImageURL == nil && len(resolvedList) > 0 {
			pet.ImageURL = &resolvedList[0]
		}
	}

	if req.IsVerified != nil {
		pet.IsVerified = *req.IsVerified
	}
	if req.VerificationConfidence != nil {
		pet.VerificationConfidence = req.VerificationConfidence
	}
	if req.VerifiedBreed != nil {
		pet.VerifiedBreed = req.VerifiedBreed
	}

	if err := h.petRepo.Create(c.Request.Context(), pet); err != nil {
		c.JSON(http.StatusInternalServerError, models.PetResponse{
			Success: false,
			Message: "Failed to create pet: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, models.PetResponse{
		Success: true,
		Message: "Pet created successfully",
		Pet:     pet,
	})
}

// GetPets handles getting all pets for the current user
func (h *PetHandlers) GetPets(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	
	pets, err := h.petRepo.GetByOwnerID(c.Request.Context(), parseUUID(userID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.PetsResponse{
			Success: false,
			Message: "Failed to get pets: " + err.Error(),
		})
		return
	}

	if pets == nil {
		pets = []models.Pet{}
	}

	c.JSON(http.StatusOK, models.PetsResponse{
		Success: true,
		Pets:    pets,
		Count:   len(pets),
	})
}

// GetPet handles getting a specific pet
func (h *PetHandlers) GetPet(c *gin.Context) {
	petID := c.Param("id")
	
	pet, err := h.petRepo.GetByID(c.Request.Context(), parseUUID(petID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.PetResponse{
			Success: false,
			Message: "Failed to get pet: " + err.Error(),
		})
		return
	}

	if pet == nil {
		c.JSON(http.StatusNotFound, models.PetResponse{
			Success: false,
			Message: "Pet not found",
		})
		return
	}

	c.JSON(http.StatusOK, models.PetResponse{
		Success: true,
		Pet:     pet,
	})
}

// UpdatePet handles updating a pet
func (h *PetHandlers) UpdatePet(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	petID := c.Param("id")
	
	var req models.UpdatePetRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.PetResponse{
			Success: false,
			Message: "Invalid request: " + err.Error(),
		})
		return
	}

	// Get existing pet
	pet, err := h.petRepo.GetByID(c.Request.Context(), parseUUID(petID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.PetResponse{
			Success: false,
			Message: "Failed to get pet: " + err.Error(),
		})
		return
	}

	if pet == nil {
		c.JSON(http.StatusNotFound, models.PetResponse{
			Success: false,
			Message: "Pet not found",
		})
		return
	}

	// Check ownership
	if pet.OwnerID.String() != userID {
		c.JSON(http.StatusForbidden, models.PetResponse{
			Success: false,
			Message: "Not authorized to update this pet",
		})
		return
	}

	// Update fields
	if req.Name != nil {
		pet.Name = *req.Name
	}
	if req.Breed != nil {
		pet.Breed = *req.Breed
	}
	if req.Age != nil {
		pet.Age = *req.Age
	}
	if req.AgeUnit != nil {
		pet.AgeUnit = *req.AgeUnit
	}
	if req.Gender != nil {
		pet.Gender = *req.Gender
	}
	if req.Color != nil {
		pet.Color = *req.Color
	}
	if req.Weight != nil {
		pet.Weight = *req.Weight
	}
	if req.WeightUnit != nil {
		pet.WeightUnit = *req.WeightUnit
	}
	if req.ImageURLs != nil {
		resolvedList, err := utils.ResolveImageReferences(c.Request.Context(), req.ImageURLs, "pets/"+userID+"/gallery")
		if err != nil {
			c.JSON(http.StatusBadRequest, models.PetResponse{Success: false, Message: "Invalid imageUrls: " + err.Error()})
			return
		}
		pet.ImageURLs = resolvedList
		if len(resolvedList) > 0 {
			pet.ImageURL = &resolvedList[0]
			pet.ImageLocalPath = nil
		}
	}
	if req.Bio != nil {
		pet.Bio = req.Bio
	}
	if req.IsAdopted != nil {
		pet.IsAdopted = *req.IsAdopted
	}

	if err := h.petRepo.Update(c.Request.Context(), pet); err != nil {
		c.JSON(http.StatusInternalServerError, models.PetResponse{
			Success: false,
			Message: "Failed to update pet: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, models.PetResponse{
		Success: true,
		Message: "Pet updated successfully",
		Pet:     pet,
	})
}

// DeletePet handles deleting a pet
func (h *PetHandlers) DeletePet(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	petID := c.Param("id")
	
	// Get existing pet
	pet, err := h.petRepo.GetByID(c.Request.Context(), parseUUID(petID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.GenericResponse{
			Success: false,
			Message: "Failed to get pet: " + err.Error(),
		})
		return
	}

	if pet == nil {
		c.JSON(http.StatusNotFound, models.GenericResponse{
			Success: false,
			Message: "Pet not found",
		})
		return
	}

	// Check ownership
	if pet.OwnerID.String() != userID {
		c.JSON(http.StatusForbidden, models.GenericResponse{
			Success: false,
			Message: "Not authorized to delete this pet",
		})
		return
	}

	if err := h.petRepo.Delete(c.Request.Context(), parseUUID(petID)); err != nil {
		c.JSON(http.StatusInternalServerError, models.GenericResponse{
			Success: false,
			Message: "Failed to delete pet: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, models.GenericResponse{
		Success: true,
		Message: "Pet deleted successfully",
	})
}

// GetVerifiedPets handles getting all verified pets for the current user
func (h *PetHandlers) GetVerifiedPets(c *gin.Context) {
	
	pets, err := h.petRepo.GetVerified(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.PetsResponse{
			Success: false,
			Message: "Failed to get verified pets: " + err.Error(),
		})
		return
	}

	if pets == nil {
		pets = []models.Pet{}
	}

	c.JSON(http.StatusOK, models.PetsResponse{
		Success: true,
		Pets:    pets,
		Count:   len(pets),
	})
}

// SearchPetsByBreed handles searching pets by breed
func (h *PetHandlers) SearchPetsByBreed(c *gin.Context) {
	breed := c.Query("breed")
	
	if breed == "" {
		c.JSON(http.StatusBadRequest, models.PetsResponse{
			Success: false,
			Message: "Breed parameter is required",
		})
		return
	}

	pets, err := h.petRepo.SearchByBreed(c.Request.Context(), breed)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.PetsResponse{
			Success: false,
			Message: "Failed to search pets: " + err.Error(),
		})
		return
	}

	if pets == nil {
		pets = []models.Pet{}
	}

	c.JSON(http.StatusOK, models.PetsResponse{
		Success: true,
		Pets:    pets,
		Count:   len(pets),
	})
}

// GetPetCount handles getting the pet count for the current user
func (h *PetHandlers) GetPetCount(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	
	count, err := h.petRepo.GetCount(c.Request.Context(), parseUUID(userID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.GenericResponse{
			Success: false,
			Message: "Failed to get pet count: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, models.GenericResponse{
		Success: true,
		Data:    map[string]int64{"count": count},
	})
}

// Helper function to parse UUID
func parseUUID(s string) uuid.UUID {
	id, err := uuid.Parse(s)
	if err != nil {
		return uuid.Nil
	}
	return id
}
