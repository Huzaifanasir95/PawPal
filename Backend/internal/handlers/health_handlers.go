package handlers

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"

	"pawpal-backend/internal/models"
	"pawpal-backend/internal/repositories"
)

// HealthHandlers handles health record and journal endpoints
type HealthHandlers struct {
	healthRepo *repositories.HealthRepository
	petRepo    repositories.PetRepositoryInterface
}

// NewHealthHandlers creates new HealthHandlers
func NewHealthHandlers(healthRepo *repositories.HealthRepository, petRepo repositories.PetRepositoryInterface) *HealthHandlers {
	return &HealthHandlers{
		healthRepo: healthRepo,
		petRepo:    petRepo,
	}
}

// Health Record Endpoints

// CreateHealthRecord handles creating a health record
func (h *HealthHandlers) CreateHealthRecord(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	
	var req models.CreateHealthRecordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.HealthRecordResponse{
			Success: false,
			Message: "Invalid request: " + err.Error(),
		})
		return
	}

	// Verify pet ownership
	pet, err := h.petRepo.GetByID(c.Request.Context(), req.PetID)
	if err != nil || pet == nil {
		c.JSON(http.StatusNotFound, models.HealthRecordResponse{
			Success: false,
			Message: "Pet not found",
		})
		return
	}

	if pet.OwnerID.String() != userID {
		c.JSON(http.StatusForbidden, models.HealthRecordResponse{
			Success: false,
			Message: "Not authorized to create health record for this pet",
		})
		return
	}

	record := &models.HealthRecord{
		PetID:                 req.PetID,
		OwnerID:               parseUUID(userID),
		IsVaccinated:          req.IsVaccinated,
		VaccinationDate:       req.VaccinationDate,
		VaccinationDetails:    req.VaccinationDetails,
		MedicalConditions:     req.MedicalConditions,
		Allergies:             req.Allergies,
		Medications:           req.Medications,
		VetName:               req.VetName,
		VetClinic:             req.VetClinic,
		VetPhone:              req.VetPhone,
		VetAddress:            req.VetAddress,
		EmergencyContactName:  req.EmergencyContactName,
		EmergencyContactPhone: req.EmergencyContactPhone,
		InsuranceProvider:     req.InsuranceProvider,
		InsurancePolicyNumber: req.InsurancePolicyNumber,
		AdditionalNotes:       req.AdditionalNotes,
	}

	if err := h.healthRepo.CreateHealthRecord(c.Request.Context(), record); err != nil {
		c.JSON(http.StatusInternalServerError, models.HealthRecordResponse{
			Success: false,
			Message: "Failed to create health record: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, models.HealthRecordResponse{
		Success:      true,
		Message:      "Health record created successfully",
		HealthRecord: record,
	})
}

// GetHealthRecord handles getting a health record for a pet
func (h *HealthHandlers) GetHealthRecord(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	petID := c.Param("petId")
	
	record, err := h.healthRepo.GetHealthRecordByPetID(c.Request.Context(), parseUUID(petID), parseUUID(userID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.HealthRecordResponse{
			Success: false,
			Message: "Failed to get health record: " + err.Error(),
		})
		return
	}

	if record == nil {
		c.JSON(http.StatusNotFound, models.HealthRecordResponse{
			Success: false,
			Message: "Health record not found",
		})
		return
	}

	c.JSON(http.StatusOK, models.HealthRecordResponse{
		Success:      true,
		HealthRecord: record,
	})
}

// UpdateHealthRecord handles updating a health record
func (h *HealthHandlers) UpdateHealthRecord(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	recordID := c.Param("id")
	
	var req models.UpdateHealthRecordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.HealthRecordResponse{
			Success: false,
			Message: "Invalid request: " + err.Error(),
		})
		return
	}

	// Get existing record
	record, err := h.healthRepo.GetHealthRecordByID(c.Request.Context(), parseUUID(recordID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.HealthRecordResponse{
			Success: false,
			Message: "Failed to get health record: " + err.Error(),
		})
		return
	}

	if record == nil {
		c.JSON(http.StatusNotFound, models.HealthRecordResponse{
			Success: false,
			Message: "Health record not found",
		})
		return
	}

	// Check ownership
	if record.OwnerID.String() != userID {
		c.JSON(http.StatusForbidden, models.HealthRecordResponse{
			Success: false,
			Message: "Not authorized to update this health record",
		})
		return
	}

	// Update fields
	if req.IsVaccinated != nil {
		record.IsVaccinated = *req.IsVaccinated
	}
	if req.VaccinationDate != nil {
		record.VaccinationDate = req.VaccinationDate
	}
	if req.VaccinationDetails != nil {
		record.VaccinationDetails = req.VaccinationDetails
	}
	if req.MedicalConditions != nil {
		record.MedicalConditions = req.MedicalConditions
	}
	if req.Allergies != nil {
		record.Allergies = req.Allergies
	}
	if req.Medications != nil {
		record.Medications = req.Medications
	}
	if req.VetName != nil {
		record.VetName = req.VetName
	}
	if req.VetClinic != nil {
		record.VetClinic = req.VetClinic
	}
	if req.VetPhone != nil {
		record.VetPhone = req.VetPhone
	}
	if req.VetAddress != nil {
		record.VetAddress = req.VetAddress
	}
	if req.EmergencyContactName != nil {
		record.EmergencyContactName = req.EmergencyContactName
	}
	if req.EmergencyContactPhone != nil {
		record.EmergencyContactPhone = req.EmergencyContactPhone
	}
	if req.InsuranceProvider != nil {
		record.InsuranceProvider = req.InsuranceProvider
	}
	if req.InsurancePolicyNumber != nil {
		record.InsurancePolicyNumber = req.InsurancePolicyNumber
	}
	if req.AdditionalNotes != nil {
		record.AdditionalNotes = req.AdditionalNotes
	}

	if err := h.healthRepo.UpdateHealthRecord(c.Request.Context(), record); err != nil {
		c.JSON(http.StatusInternalServerError, models.HealthRecordResponse{
			Success: false,
			Message: "Failed to update health record: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, models.HealthRecordResponse{
		Success:      true,
		Message:      "Health record updated successfully",
		HealthRecord: record,
	})
}

// DeleteHealthRecord handles deleting a health record
func (h *HealthHandlers) DeleteHealthRecord(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	recordID := c.Param("id")
	
	// Get existing record
	record, err := h.healthRepo.GetHealthRecordByID(c.Request.Context(), parseUUID(recordID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.GenericResponse{
			Success: false,
			Message: "Failed to get health record: " + err.Error(),
		})
		return
	}

	if record == nil {
		c.JSON(http.StatusNotFound, models.GenericResponse{
			Success: false,
			Message: "Health record not found",
		})
		return
	}

	// Check ownership
	if record.OwnerID.String() != userID {
		c.JSON(http.StatusForbidden, models.GenericResponse{
			Success: false,
			Message: "Not authorized to delete this health record",
		})
		return
	}

	if err := h.healthRepo.DeleteHealthRecord(c.Request.Context(), parseUUID(recordID)); err != nil {
		c.JSON(http.StatusInternalServerError, models.GenericResponse{
			Success: false,
			Message: "Failed to delete health record: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, models.GenericResponse{
		Success: true,
		Message: "Health record deleted successfully",
	})
}

// Health Journal Endpoints

// CreateHealthJournal handles creating a health journal entry
func (h *HealthHandlers) CreateHealthJournal(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	
	var req models.CreateHealthJournalRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.HealthJournalResponse{
			Success: false,
			Message: "Invalid request: " + err.Error(),
		})
		return
	}

	// Verify pet ownership
	pet, err := h.petRepo.GetByID(c.Request.Context(), req.PetID)
	if err != nil || pet == nil {
		c.JSON(http.StatusNotFound, models.HealthJournalResponse{
			Success: false,
			Message: "Pet not found",
		})
		return
	}

	if pet.OwnerID.String() != userID {
		c.JSON(http.StatusForbidden, models.HealthJournalResponse{
			Success: false,
			Message: "Not authorized to create health journal for this pet",
		})
		return
	}

	// Parse date
	date, err := time.Parse("2006-01-02", req.Date)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.HealthJournalResponse{
			Success: false,
			Message: "Invalid date format. Use YYYY-MM-DD",
		})
		return
	}

	journal := &models.HealthJournal{
		PetID:            req.PetID,
		OwnerID:          parseUUID(userID),
		Date:             date,
		Weight:           req.Weight,
		WeightUnit:       req.WeightUnit,
		ActivityLevel:    req.ActivityLevel,
		EnergyLevel:      req.EnergyLevel,
		Mood:             req.Mood,
		Appetite:         req.Appetite,
		Symptoms:         req.Symptoms,
		MedicationsTaken: req.MedicationsTaken,
		VetVisitReason:   req.VetVisitReason,
		VetNotes:         req.VetNotes,
		GeneralNotes:     req.GeneralNotes,
	}

	if req.VetVisit != nil {
		journal.VetVisit = *req.VetVisit
	}

	if err := h.healthRepo.CreateHealthJournal(c.Request.Context(), journal); err != nil {
		c.JSON(http.StatusInternalServerError, models.HealthJournalResponse{
			Success: false,
			Message: "Failed to create health journal: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, models.HealthJournalResponse{
		Success:       true,
		Message:       "Health journal created successfully",
		HealthJournal: journal,
	})
}

// GetHealthJournals handles getting all health journal entries for a pet
func (h *HealthHandlers) GetHealthJournals(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	petID := c.Param("petId")
	
	journals, err := h.healthRepo.GetHealthJournalsByPetID(c.Request.Context(), parseUUID(petID), parseUUID(userID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.HealthJournalsResponse{
			Success: false,
			Message: "Failed to get health journals: " + err.Error(),
		})
		return
	}

	if journals == nil {
		journals = []models.HealthJournal{}
	}

	c.JSON(http.StatusOK, models.HealthJournalsResponse{
		Success:        true,
		HealthJournals: journals,
		Count:          len(journals),
	})
}

// GetHealthJournal handles getting a specific health journal entry
func (h *HealthHandlers) GetHealthJournal(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	journalID := c.Param("id")
	
	journal, err := h.healthRepo.GetHealthJournalByID(c.Request.Context(), parseUUID(journalID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.HealthJournalResponse{
			Success: false,
			Message: "Failed to get health journal: " + err.Error(),
		})
		return
	}

	if journal == nil {
		c.JSON(http.StatusNotFound, models.HealthJournalResponse{
			Success: false,
			Message: "Health journal not found",
		})
		return
	}

	// Check ownership
	if journal.OwnerID.String() != userID {
		c.JSON(http.StatusForbidden, models.HealthJournalResponse{
			Success: false,
			Message: "Not authorized to view this health journal",
		})
		return
	}

	c.JSON(http.StatusOK, models.HealthJournalResponse{
		Success:       true,
		HealthJournal: journal,
	})
}

// DeleteHealthJournal handles deleting a health journal entry
func (h *HealthHandlers) DeleteHealthJournal(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	journalID := c.Param("id")
	
	// Get existing journal
	journal, err := h.healthRepo.GetHealthJournalByID(c.Request.Context(), parseUUID(journalID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.GenericResponse{
			Success: false,
			Message: "Failed to get health journal: " + err.Error(),
		})
		return
	}

	if journal == nil {
		c.JSON(http.StatusNotFound, models.GenericResponse{
			Success: false,
			Message: "Health journal not found",
		})
		return
	}

	// Check ownership
	if journal.OwnerID.String() != userID {
		c.JSON(http.StatusForbidden, models.GenericResponse{
			Success: false,
			Message: "Not authorized to delete this health journal",
		})
		return
	}

	if err := h.healthRepo.DeleteHealthJournal(c.Request.Context(), parseUUID(journalID)); err != nil {
		c.JSON(http.StatusInternalServerError, models.GenericResponse{
			Success: false,
			Message: "Failed to delete health journal: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, models.GenericResponse{
		Success: true,
		Message: "Health journal deleted successfully",
	})
}
