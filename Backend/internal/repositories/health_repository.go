package repositories

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"pawpal-backend/internal/models"
)

// HealthRepository handles health records and journals database operations
type HealthRepository struct {
	db *pgxpool.Pool
}

// NewHealthRepository creates a new HealthRepository
func NewHealthRepository(db *pgxpool.Pool) *HealthRepository {
	return &HealthRepository{db: db}
}

// Health Record Methods

// CreateHealthRecord creates a new health record
func (r *HealthRepository) CreateHealthRecord(ctx context.Context, record *models.HealthRecord) error {
	query := `
		INSERT INTO health_records (
			id, pet_id, owner_id, is_vaccinated, vaccination_date, vaccination_details,
			medical_conditions, allergies, medications, vet_name, vet_clinic, vet_phone,
			vet_address, emergency_contact_name, emergency_contact_phone, insurance_provider,
			insurance_policy_number, additional_notes, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20)
		RETURNING id, created_at, updated_at`

	now := time.Now()
	record.ID = uuid.New()
	record.CreatedAt = now
	record.UpdatedAt = now

	return r.db.QueryRow(ctx, query,
		record.ID,
		record.PetID,
		record.OwnerID,
		record.IsVaccinated,
		record.VaccinationDate,
		record.VaccinationDetails,
		record.MedicalConditions,
		record.Allergies,
		record.Medications,
		record.VetName,
		record.VetClinic,
		record.VetPhone,
		record.VetAddress,
		record.EmergencyContactName,
		record.EmergencyContactPhone,
		record.InsuranceProvider,
		record.InsurancePolicyNumber,
		record.AdditionalNotes,
		record.CreatedAt,
		record.UpdatedAt,
	).Scan(&record.ID, &record.CreatedAt, &record.UpdatedAt)
}

// GetHealthRecordByPetID gets the health record for a pet
func (r *HealthRepository) GetHealthRecordByPetID(ctx context.Context, petID uuid.UUID, ownerID uuid.UUID) (*models.HealthRecord, error) {
	query := `
		SELECT id, pet_id, owner_id, is_vaccinated, vaccination_date, vaccination_details,
			medical_conditions, allergies, medications, vet_name, vet_clinic, vet_phone,
			vet_address, emergency_contact_name, emergency_contact_phone, insurance_provider,
			insurance_policy_number, additional_notes, created_at, updated_at
		FROM health_records WHERE pet_id = $1 AND owner_id = $2 LIMIT 1`

	record := &models.HealthRecord{}
	err := r.db.QueryRow(ctx, query, petID, ownerID).Scan(
		&record.ID,
		&record.PetID,
		&record.OwnerID,
		&record.IsVaccinated,
		&record.VaccinationDate,
		&record.VaccinationDetails,
		&record.MedicalConditions,
		&record.Allergies,
		&record.Medications,
		&record.VetName,
		&record.VetClinic,
		&record.VetPhone,
		&record.VetAddress,
		&record.EmergencyContactName,
		&record.EmergencyContactPhone,
		&record.InsuranceProvider,
		&record.InsurancePolicyNumber,
		&record.AdditionalNotes,
		&record.CreatedAt,
		&record.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return record, nil
}

// GetHealthRecordByID gets a health record by ID
func (r *HealthRepository) GetHealthRecordByID(ctx context.Context, id uuid.UUID) (*models.HealthRecord, error) {
	query := `
		SELECT id, pet_id, owner_id, is_vaccinated, vaccination_date, vaccination_details,
			medical_conditions, allergies, medications, vet_name, vet_clinic, vet_phone,
			vet_address, emergency_contact_name, emergency_contact_phone, insurance_provider,
			insurance_policy_number, additional_notes, created_at, updated_at
		FROM health_records WHERE id = $1`

	record := &models.HealthRecord{}
	err := r.db.QueryRow(ctx, query, id).Scan(
		&record.ID,
		&record.PetID,
		&record.OwnerID,
		&record.IsVaccinated,
		&record.VaccinationDate,
		&record.VaccinationDetails,
		&record.MedicalConditions,
		&record.Allergies,
		&record.Medications,
		&record.VetName,
		&record.VetClinic,
		&record.VetPhone,
		&record.VetAddress,
		&record.EmergencyContactName,
		&record.EmergencyContactPhone,
		&record.InsuranceProvider,
		&record.InsurancePolicyNumber,
		&record.AdditionalNotes,
		&record.CreatedAt,
		&record.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return record, nil
}

// UpdateHealthRecord updates a health record
func (r *HealthRepository) UpdateHealthRecord(ctx context.Context, record *models.HealthRecord) error {
	query := `
		UPDATE health_records SET
			is_vaccinated = $2, vaccination_date = $3, vaccination_details = $4,
			medical_conditions = $5, allergies = $6, medications = $7, vet_name = $8,
			vet_clinic = $9, vet_phone = $10, vet_address = $11, emergency_contact_name = $12,
			emergency_contact_phone = $13, insurance_provider = $14, insurance_policy_number = $15,
			additional_notes = $16, updated_at = $17
		WHERE id = $1`

	_, err := r.db.Exec(ctx, query,
		record.ID,
		record.IsVaccinated,
		record.VaccinationDate,
		record.VaccinationDetails,
		record.MedicalConditions,
		record.Allergies,
		record.Medications,
		record.VetName,
		record.VetClinic,
		record.VetPhone,
		record.VetAddress,
		record.EmergencyContactName,
		record.EmergencyContactPhone,
		record.InsuranceProvider,
		record.InsurancePolicyNumber,
		record.AdditionalNotes,
		time.Now(),
	)
	return err
}

// DeleteHealthRecord deletes a health record
func (r *HealthRepository) DeleteHealthRecord(ctx context.Context, id uuid.UUID) error {
	query := `DELETE FROM health_records WHERE id = $1`
	_, err := r.db.Exec(ctx, query, id)
	return err
}

// Health Journal Methods

// CreateHealthJournal creates a new health journal entry
func (r *HealthRepository) CreateHealthJournal(ctx context.Context, journal *models.HealthJournal) error {
	query := `
		INSERT INTO health_journals (
			id, pet_id, owner_id, date, weight, weight_unit, activity_level, energy_level,
			mood, appetite, symptoms, medications_taken, vet_visit, vet_visit_reason,
			vet_notes, general_notes, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)
		RETURNING id, created_at, updated_at`

	now := time.Now()
	journal.ID = uuid.New()
	journal.CreatedAt = now
	journal.UpdatedAt = now

	return r.db.QueryRow(ctx, query,
		journal.ID,
		journal.PetID,
		journal.OwnerID,
		journal.Date,
		journal.Weight,
		journal.WeightUnit,
		journal.ActivityLevel,
		journal.EnergyLevel,
		journal.Mood,
		journal.Appetite,
		journal.Symptoms,
		journal.MedicationsTaken,
		journal.VetVisit,
		journal.VetVisitReason,
		journal.VetNotes,
		journal.GeneralNotes,
		journal.CreatedAt,
		journal.UpdatedAt,
	).Scan(&journal.ID, &journal.CreatedAt, &journal.UpdatedAt)
}

// GetHealthJournalsByPetID gets all health journal entries for a pet
func (r *HealthRepository) GetHealthJournalsByPetID(ctx context.Context, petID uuid.UUID, ownerID uuid.UUID) ([]models.HealthJournal, error) {
	query := `
		SELECT id, pet_id, owner_id, date, weight, weight_unit, activity_level, energy_level,
			mood, appetite, symptoms, medications_taken, vet_visit, vet_visit_reason,
			vet_notes, general_notes, created_at, updated_at
		FROM health_journals WHERE pet_id = $1 AND owner_id = $2 ORDER BY date DESC`

	rows, err := r.db.Query(ctx, query, petID, ownerID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var journals []models.HealthJournal
	for rows.Next() {
		journal := models.HealthJournal{}
		err := rows.Scan(
			&journal.ID,
			&journal.PetID,
			&journal.OwnerID,
			&journal.Date,
			&journal.Weight,
			&journal.WeightUnit,
			&journal.ActivityLevel,
			&journal.EnergyLevel,
			&journal.Mood,
			&journal.Appetite,
			&journal.Symptoms,
			&journal.MedicationsTaken,
			&journal.VetVisit,
			&journal.VetVisitReason,
			&journal.VetNotes,
			&journal.GeneralNotes,
			&journal.CreatedAt,
			&journal.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		journals = append(journals, journal)
	}
	return journals, nil
}

// GetHealthJournalByID gets a health journal entry by ID
func (r *HealthRepository) GetHealthJournalByID(ctx context.Context, id uuid.UUID) (*models.HealthJournal, error) {
	query := `
		SELECT id, pet_id, owner_id, date, weight, weight_unit, activity_level, energy_level,
			mood, appetite, symptoms, medications_taken, vet_visit, vet_visit_reason,
			vet_notes, general_notes, created_at, updated_at
		FROM health_journals WHERE id = $1`

	journal := &models.HealthJournal{}
	err := r.db.QueryRow(ctx, query, id).Scan(
		&journal.ID,
		&journal.PetID,
		&journal.OwnerID,
		&journal.Date,
		&journal.Weight,
		&journal.WeightUnit,
		&journal.ActivityLevel,
		&journal.EnergyLevel,
		&journal.Mood,
		&journal.Appetite,
		&journal.Symptoms,
		&journal.MedicationsTaken,
		&journal.VetVisit,
		&journal.VetVisitReason,
		&journal.VetNotes,
		&journal.GeneralNotes,
		&journal.CreatedAt,
		&journal.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return journal, nil
}

// UpdateHealthJournal updates a health journal entry
func (r *HealthRepository) UpdateHealthJournal(ctx context.Context, journal *models.HealthJournal) error {
	query := `
		UPDATE health_journals SET
			weight = $2, weight_unit = $3, activity_level = $4, energy_level = $5,
			mood = $6, appetite = $7, symptoms = $8, medications_taken = $9,
			vet_visit = $10, vet_visit_reason = $11, vet_notes = $12, general_notes = $13, updated_at = $14
		WHERE id = $1`

	_, err := r.db.Exec(ctx, query,
		journal.ID,
		journal.Weight,
		journal.WeightUnit,
		journal.ActivityLevel,
		journal.EnergyLevel,
		journal.Mood,
		journal.Appetite,
		journal.Symptoms,
		journal.MedicationsTaken,
		journal.VetVisit,
		journal.VetVisitReason,
		journal.VetNotes,
		journal.GeneralNotes,
		time.Now(),
	)
	return err
}

// DeleteHealthJournal deletes a health journal entry
func (r *HealthRepository) DeleteHealthJournal(ctx context.Context, id uuid.UUID) error {
	query := `DELETE FROM health_journals WHERE id = $1`
	_, err := r.db.Exec(ctx, query, id)
	return err
}
