package repositories

import (
	"context"
	"fmt"
	"strings"
	"time"

	"pawpal-backend/internal/models"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// CaregiverRepository handles caregiver-related database operations
type CaregiverRepository struct {
	db *pgxpool.Pool
}

// NewCaregiverRepository creates a new caregiver repository
func NewCaregiverRepository(db *pgxpool.Pool) *CaregiverRepository {
	return &CaregiverRepository{db: db}
}

// GetServiceTypes returns all available service types
func (r *CaregiverRepository) GetServiceTypes(ctx context.Context) ([]models.CaregiverServiceType, error) {
	query := `
		SELECT id, name, display_name, description, base_hourly_rate, icon_name, is_active, created_at
		FROM caregiver_service_types
		WHERE is_active = true
		ORDER BY display_name
	`

	rows, err := r.db.Query(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var types []models.CaregiverServiceType
	for rows.Next() {
		var t models.CaregiverServiceType
		err := rows.Scan(
			&t.ID, &t.Name, &t.DisplayName, &t.Description,
			&t.BaseHourlyRate, &t.IconName, &t.IsActive, &t.CreatedAt,
		)
		if err != nil {
			return nil, err
		}
		types = append(types, t)
	}

	return types, nil
}

// CreateProfile creates a new caregiver profile
func (r *CaregiverRepository) CreateProfile(ctx context.Context, profile *models.CaregiverProfile) error {
	query := `
		INSERT INTO caregiver_profiles (
			user_id, bio, years_of_experience, headline, address, city, state,
			postal_code, country, latitude, longitude, service_radius_km,
			accepted_pet_types, accepted_pet_sizes, max_pets_at_once,
			has_fenced_yard, has_own_transport, smoke_free_home,
			has_children, has_other_pets, other_pets_description,
			certifications, pet_first_aid_certified
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15,
			$16, $17, $18, $19, $20, $21, $22, $23
		) RETURNING id, created_at, updated_at
	`

	err := r.db.QueryRow(ctx, query,
		profile.UserID, profile.Bio, profile.YearsOfExperience, profile.Headline,
		profile.Address, profile.City, profile.State, profile.PostalCode,
		profile.Country, profile.Latitude, profile.Longitude, profile.ServiceRadiusKm,
		profile.AcceptedPetTypes, profile.AcceptedPetSizes, profile.MaxPetsAtOnce,
		profile.HasFencedYard, profile.HasOwnTransport, profile.SmokeFreeHome,
		profile.HasChildren, profile.HasOtherPets, profile.OtherPetsDescription,
		profile.Certifications, profile.PetFirstAidCertified,
	).Scan(&profile.ID, &profile.CreatedAt, &profile.UpdatedAt)

	return err
}

// GetProfileByUserID retrieves a caregiver profile by user ID
func (r *CaregiverRepository) GetProfileByUserID(ctx context.Context, userID uuid.UUID) (*models.CaregiverProfile, error) {
	query := `
		SELECT 
			cp.id, cp.user_id, cp.bio, cp.years_of_experience, cp.headline,
			cp.address, cp.city, cp.state, cp.postal_code, cp.country,
			cp.latitude, cp.longitude, cp.service_radius_km,
			cp.is_verified, cp.verification_date, cp.background_check_status,
			cp.background_check_date, cp.background_check_expiry,
			cp.id_verified, cp.id_document_url, cp.certifications,
			cp.pet_first_aid_certified, cp.insurance_verified,
			cp.insurance_policy_number, cp.insurance_expiry,
			cp.accepted_pet_types, cp.accepted_pet_sizes, cp.max_pets_at_once,
			cp.has_fenced_yard, cp.has_own_transport, cp.smoke_free_home,
			cp.has_children, cp.has_other_pets, cp.other_pets_description,
			cp.average_rating, cp.total_reviews, cp.total_bookings,
			cp.completion_rate, cp.response_time_hours,
			cp.is_active, cp.is_accepting_bookings, cp.created_at, cp.updated_at,
			u.display_name, u.avatar_url, u.email
		FROM caregiver_profiles cp
		JOIN users u ON cp.user_id = u.id
		WHERE cp.user_id = $1
	`

	var p models.CaregiverProfile
	err := r.db.QueryRow(ctx, query, userID).Scan(
		&p.ID, &p.UserID, &p.Bio, &p.YearsOfExperience, &p.Headline,
		&p.Address, &p.City, &p.State, &p.PostalCode, &p.Country,
		&p.Latitude, &p.Longitude, &p.ServiceRadiusKm,
		&p.IsVerified, &p.VerificationDate, &p.BackgroundCheckStatus,
		&p.BackgroundCheckDate, &p.BackgroundCheckExpiry,
		&p.IDVerified, &p.IDDocumentURL, &p.Certifications,
		&p.PetFirstAidCertified, &p.InsuranceVerified,
		&p.InsurancePolicyNumber, &p.InsuranceExpiry,
		&p.AcceptedPetTypes, &p.AcceptedPetSizes, &p.MaxPetsAtOnce,
		&p.HasFencedYard, &p.HasOwnTransport, &p.SmokeFreeHome,
		&p.HasChildren, &p.HasOtherPets, &p.OtherPetsDescription,
		&p.AverageRating, &p.TotalReviews, &p.TotalBookings,
		&p.CompletionRate, &p.ResponseTimeHours,
		&p.IsActive, &p.IsAcceptingBookings, &p.CreatedAt, &p.UpdatedAt,
		&p.UserName, &p.UserAvatar, &p.UserEmail,
	)

	if err == pgx.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	return &p, nil
}

// GetProfileByID retrieves a caregiver profile by profile ID
func (r *CaregiverRepository) GetProfileByID(ctx context.Context, profileID uuid.UUID) (*models.CaregiverProfile, error) {
	query := `
		SELECT 
			cp.id, cp.user_id, cp.bio, cp.years_of_experience, cp.headline,
			cp.address, cp.city, cp.state, cp.postal_code, cp.country,
			cp.latitude, cp.longitude, cp.service_radius_km,
			cp.is_verified, cp.verification_date, cp.background_check_status,
			cp.background_check_date, cp.background_check_expiry,
			cp.id_verified, cp.id_document_url, cp.certifications,
			cp.pet_first_aid_certified, cp.insurance_verified,
			cp.insurance_policy_number, cp.insurance_expiry,
			cp.accepted_pet_types, cp.accepted_pet_sizes, cp.max_pets_at_once,
			cp.has_fenced_yard, cp.has_own_transport, cp.smoke_free_home,
			cp.has_children, cp.has_other_pets, cp.other_pets_description,
			cp.average_rating, cp.total_reviews, cp.total_bookings,
			cp.completion_rate, cp.response_time_hours,
			cp.is_active, cp.is_accepting_bookings, cp.created_at, cp.updated_at,
			u.display_name, u.avatar_url, u.email
		FROM caregiver_profiles cp
		JOIN users u ON cp.user_id = u.id
		WHERE cp.id = $1
	`

	var p models.CaregiverProfile
	err := r.db.QueryRow(ctx, query, profileID).Scan(
		&p.ID, &p.UserID, &p.Bio, &p.YearsOfExperience, &p.Headline,
		&p.Address, &p.City, &p.State, &p.PostalCode, &p.Country,
		&p.Latitude, &p.Longitude, &p.ServiceRadiusKm,
		&p.IsVerified, &p.VerificationDate, &p.BackgroundCheckStatus,
		&p.BackgroundCheckDate, &p.BackgroundCheckExpiry,
		&p.IDVerified, &p.IDDocumentURL, &p.Certifications,
		&p.PetFirstAidCertified, &p.InsuranceVerified,
		&p.InsurancePolicyNumber, &p.InsuranceExpiry,
		&p.AcceptedPetTypes, &p.AcceptedPetSizes, &p.MaxPetsAtOnce,
		&p.HasFencedYard, &p.HasOwnTransport, &p.SmokeFreeHome,
		&p.HasChildren, &p.HasOtherPets, &p.OtherPetsDescription,
		&p.AverageRating, &p.TotalReviews, &p.TotalBookings,
		&p.CompletionRate, &p.ResponseTimeHours,
		&p.IsActive, &p.IsAcceptingBookings, &p.CreatedAt, &p.UpdatedAt,
		&p.UserName, &p.UserAvatar, &p.UserEmail,
	)

	if err == pgx.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	return &p, nil
}

// UpdateProfile updates a caregiver profile
func (r *CaregiverRepository) UpdateProfile(ctx context.Context, profileID uuid.UUID, req *models.UpdateCaregiverProfileRequest) error {
	var setClauses []string
	var args []interface{}
	argNum := 1

	if req.Bio != nil {
		setClauses = append(setClauses, fmt.Sprintf("bio = $%d", argNum))
		args = append(args, *req.Bio)
		argNum++
	}
	if req.YearsOfExperience != nil {
		setClauses = append(setClauses, fmt.Sprintf("years_of_experience = $%d", argNum))
		args = append(args, *req.YearsOfExperience)
		argNum++
	}
	if req.Headline != nil {
		setClauses = append(setClauses, fmt.Sprintf("headline = $%d", argNum))
		args = append(args, *req.Headline)
		argNum++
	}
	if req.Address != nil {
		setClauses = append(setClauses, fmt.Sprintf("address = $%d", argNum))
		args = append(args, *req.Address)
		argNum++
	}
	if req.City != nil {
		setClauses = append(setClauses, fmt.Sprintf("city = $%d", argNum))
		args = append(args, *req.City)
		argNum++
	}
	if req.State != nil {
		setClauses = append(setClauses, fmt.Sprintf("state = $%d", argNum))
		args = append(args, *req.State)
		argNum++
	}
	if req.PostalCode != nil {
		setClauses = append(setClauses, fmt.Sprintf("postal_code = $%d", argNum))
		args = append(args, *req.PostalCode)
		argNum++
	}
	if req.Latitude != nil {
		setClauses = append(setClauses, fmt.Sprintf("latitude = $%d", argNum))
		args = append(args, *req.Latitude)
		argNum++
	}
	if req.Longitude != nil {
		setClauses = append(setClauses, fmt.Sprintf("longitude = $%d", argNum))
		args = append(args, *req.Longitude)
		argNum++
	}
	if req.ServiceRadiusKm != nil {
		setClauses = append(setClauses, fmt.Sprintf("service_radius_km = $%d", argNum))
		args = append(args, *req.ServiceRadiusKm)
		argNum++
	}
	if req.AcceptedPetTypes != nil {
		setClauses = append(setClauses, fmt.Sprintf("accepted_pet_types = $%d", argNum))
		args = append(args, req.AcceptedPetTypes)
		argNum++
	}
	if req.AcceptedPetSizes != nil {
		setClauses = append(setClauses, fmt.Sprintf("accepted_pet_sizes = $%d", argNum))
		args = append(args, req.AcceptedPetSizes)
		argNum++
	}
	if req.MaxPetsAtOnce != nil {
		setClauses = append(setClauses, fmt.Sprintf("max_pets_at_once = $%d", argNum))
		args = append(args, *req.MaxPetsAtOnce)
		argNum++
	}
	if req.HasFencedYard != nil {
		setClauses = append(setClauses, fmt.Sprintf("has_fenced_yard = $%d", argNum))
		args = append(args, *req.HasFencedYard)
		argNum++
	}
	if req.HasOwnTransport != nil {
		setClauses = append(setClauses, fmt.Sprintf("has_own_transport = $%d", argNum))
		args = append(args, *req.HasOwnTransport)
		argNum++
	}
	if req.SmokeFreeHome != nil {
		setClauses = append(setClauses, fmt.Sprintf("smoke_free_home = $%d", argNum))
		args = append(args, *req.SmokeFreeHome)
		argNum++
	}
	if req.HasChildren != nil {
		setClauses = append(setClauses, fmt.Sprintf("has_children = $%d", argNum))
		args = append(args, *req.HasChildren)
		argNum++
	}
	if req.HasOtherPets != nil {
		setClauses = append(setClauses, fmt.Sprintf("has_other_pets = $%d", argNum))
		args = append(args, *req.HasOtherPets)
		argNum++
	}
	if req.OtherPetsDescription != nil {
		setClauses = append(setClauses, fmt.Sprintf("other_pets_description = $%d", argNum))
		args = append(args, *req.OtherPetsDescription)
		argNum++
	}
	if req.IsAcceptingBookings != nil {
		setClauses = append(setClauses, fmt.Sprintf("is_accepting_bookings = $%d", argNum))
		args = append(args, *req.IsAcceptingBookings)
		argNum++
	}

	if len(setClauses) == 0 {
		return nil
	}

	setClauses = append(setClauses, "updated_at = CURRENT_TIMESTAMP")
	args = append(args, profileID)

	query := fmt.Sprintf(
		"UPDATE caregiver_profiles SET %s WHERE id = $%d",
		strings.Join(setClauses, ", "),
		argNum,
	)

	_, err := r.db.Exec(ctx, query, args...)
	return err
}

// AddService adds a service to a caregiver's offerings
func (r *CaregiverRepository) AddService(ctx context.Context, service *models.CaregiverService) error {
	query := `
		INSERT INTO caregiver_services (
			caregiver_id, service_type_id, rate_type, rate_amount, currency,
			description, duration_minutes, includes, additional_pet_rate
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
		RETURNING id, created_at, updated_at
	`

	currency := service.Currency
	if currency == "" {
		currency = "PKR"
	}

	err := r.db.QueryRow(ctx, query,
		service.CaregiverID, service.ServiceTypeID, service.RateType,
		service.RateAmount, currency, service.Description,
		service.DurationMinutes, service.Includes, service.AdditionalPetRate,
	).Scan(&service.ID, &service.CreatedAt, &service.UpdatedAt)

	return err
}

// GetServicesByCaregiver returns all services for a caregiver
func (r *CaregiverRepository) GetServicesByCaregiver(ctx context.Context, caregiverID uuid.UUID) ([]models.CaregiverService, error) {
	query := `
		SELECT 
			cs.id, cs.caregiver_id, cs.service_type_id, cs.rate_type,
			cs.rate_amount, cs.currency, cs.description, cs.duration_minutes,
			cs.includes, cs.additional_pet_rate, cs.is_available,
			cs.created_at, cs.updated_at,
			cst.name, cst.display_name, cst.icon_name
		FROM caregiver_services cs
		JOIN caregiver_service_types cst ON cs.service_type_id = cst.id
		WHERE cs.caregiver_id = $1
		ORDER BY cst.display_name
	`

	rows, err := r.db.Query(ctx, query, caregiverID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var services []models.CaregiverService
	for rows.Next() {
		var s models.CaregiverService
		err := rows.Scan(
			&s.ID, &s.CaregiverID, &s.ServiceTypeID, &s.RateType,
			&s.RateAmount, &s.Currency, &s.Description, &s.DurationMinutes,
			&s.Includes, &s.AdditionalPetRate, &s.IsAvailable,
			&s.CreatedAt, &s.UpdatedAt,
			&s.ServiceTypeName, &s.ServiceTypeDisplayName, &s.ServiceTypeIcon,
		)
		if err != nil {
			return nil, err
		}
		services = append(services, s)
	}

	return services, nil
}

// UpdateService updates a caregiver service
func (r *CaregiverRepository) UpdateService(ctx context.Context, serviceID uuid.UUID, req *models.UpdateCaregiverServiceRequest) error {
	var setClauses []string
	var args []interface{}
	argNum := 1

	if req.RateType != nil {
		setClauses = append(setClauses, fmt.Sprintf("rate_type = $%d", argNum))
		args = append(args, *req.RateType)
		argNum++
	}
	if req.RateAmount != nil {
		setClauses = append(setClauses, fmt.Sprintf("rate_amount = $%d", argNum))
		args = append(args, *req.RateAmount)
		argNum++
	}
	if req.Description != nil {
		setClauses = append(setClauses, fmt.Sprintf("description = $%d", argNum))
		args = append(args, *req.Description)
		argNum++
	}
	if req.DurationMinutes != nil {
		setClauses = append(setClauses, fmt.Sprintf("duration_minutes = $%d", argNum))
		args = append(args, *req.DurationMinutes)
		argNum++
	}
	if req.Includes != nil {
		setClauses = append(setClauses, fmt.Sprintf("includes = $%d", argNum))
		args = append(args, req.Includes)
		argNum++
	}
	if req.AdditionalPetRate != nil {
		setClauses = append(setClauses, fmt.Sprintf("additional_pet_rate = $%d", argNum))
		args = append(args, *req.AdditionalPetRate)
		argNum++
	}
	if req.IsAvailable != nil {
		setClauses = append(setClauses, fmt.Sprintf("is_available = $%d", argNum))
		args = append(args, *req.IsAvailable)
		argNum++
	}

	if len(setClauses) == 0 {
		return nil
	}

	setClauses = append(setClauses, "updated_at = CURRENT_TIMESTAMP")
	args = append(args, serviceID)

	query := fmt.Sprintf(
		"UPDATE caregiver_services SET %s WHERE id = $%d",
		strings.Join(setClauses, ", "),
		argNum,
	)

	_, err := r.db.Exec(ctx, query, args...)
	return err
}

// DeleteService removes a service from caregiver's offerings
func (r *CaregiverRepository) DeleteService(ctx context.Context, serviceID uuid.UUID) error {
	_, err := r.db.Exec(ctx, "DELETE FROM caregiver_services WHERE id = $1", serviceID)
	return err
}

// SetAvailability sets the weekly availability for a caregiver
func (r *CaregiverRepository) SetAvailability(ctx context.Context, caregiverID uuid.UUID, slots []models.AvailabilitySlot) error {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	// Clear existing availability
	_, err = tx.Exec(ctx, "DELETE FROM caregiver_availability WHERE caregiver_id = $1", caregiverID)
	if err != nil {
		return err
	}

	// Insert new slots
	for _, slot := range slots {
		_, err = tx.Exec(ctx, `
			INSERT INTO caregiver_availability (caregiver_id, day_of_week, start_time, end_time, is_available)
			VALUES ($1, $2, $3, $4, $5)
		`, caregiverID, slot.DayOfWeek, slot.StartTime, slot.EndTime, slot.IsAvailable)
		if err != nil {
			return err
		}
	}

	return tx.Commit(ctx)
}

// GetAvailability returns the weekly availability for a caregiver
func (r *CaregiverRepository) GetAvailability(ctx context.Context, caregiverID uuid.UUID) ([]models.CaregiverAvailability, error) {
	query := `
		SELECT id, caregiver_id, day_of_week, start_time::text, end_time::text, is_available, created_at
		FROM caregiver_availability
		WHERE caregiver_id = $1
		ORDER BY day_of_week, start_time
	`

	rows, err := r.db.Query(ctx, query, caregiverID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var availability []models.CaregiverAvailability
	for rows.Next() {
		var a models.CaregiverAvailability
		err := rows.Scan(&a.ID, &a.CaregiverID, &a.DayOfWeek, &a.StartTime, &a.EndTime, &a.IsAvailable, &a.CreatedAt)
		if err != nil {
			return nil, err
		}
		availability = append(availability, a)
	}

	return availability, nil
}

// AddBlockedDate blocks a specific date
func (r *CaregiverRepository) AddBlockedDate(ctx context.Context, caregiverID uuid.UUID, date time.Time, reason *string) error {
	_, err := r.db.Exec(ctx, `
		INSERT INTO caregiver_blocked_dates (caregiver_id, blocked_date, reason)
		VALUES ($1, $2, $3)
		ON CONFLICT (caregiver_id, blocked_date) DO UPDATE SET reason = $3
	`, caregiverID, date, reason)
	return err
}

// RemoveBlockedDate removes a blocked date
func (r *CaregiverRepository) RemoveBlockedDate(ctx context.Context, caregiverID uuid.UUID, date time.Time) error {
	_, err := r.db.Exec(ctx, "DELETE FROM caregiver_blocked_dates WHERE caregiver_id = $1 AND blocked_date = $2", caregiverID, date)
	return err
}

// GetBlockedDates returns all blocked dates for a caregiver
func (r *CaregiverRepository) GetBlockedDates(ctx context.Context, caregiverID uuid.UUID) ([]models.CaregiverBlockedDate, error) {
	query := `
		SELECT id, caregiver_id, blocked_date, reason, created_at
		FROM caregiver_blocked_dates
		WHERE caregiver_id = $1
		ORDER BY blocked_date
	`

	rows, err := r.db.Query(ctx, query, caregiverID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var dates []models.CaregiverBlockedDate
	for rows.Next() {
		var d models.CaregiverBlockedDate
		err := rows.Scan(&d.ID, &d.CaregiverID, &d.BlockedDate, &d.Reason, &d.CreatedAt)
		if err != nil {
			return nil, err
		}
		dates = append(dates, d)
	}

	return dates, nil
}

// SearchCaregivers searches for caregivers based on filters
func (r *CaregiverRepository) SearchCaregivers(ctx context.Context, req *models.SearchCaregiversRequest) ([]models.CaregiverProfile, int, error) {
	var whereClauses []string
	var args []interface{}
	argNum := 1

	whereClauses = append(whereClauses, "cp.is_active = true")
	whereClauses = append(whereClauses, "cp.is_accepting_bookings = true")

	if req.VerifiedOnly {
		whereClauses = append(whereClauses, "cp.is_verified = true")
	}

	if req.City != nil && *req.City != "" {
		whereClauses = append(whereClauses, fmt.Sprintf("LOWER(cp.city) = LOWER($%d)", argNum))
		args = append(args, *req.City)
		argNum++
	}

	if req.PetType != nil && *req.PetType != "" {
		whereClauses = append(whereClauses, fmt.Sprintf("$%d = ANY(cp.accepted_pet_types)", argNum))
		args = append(args, *req.PetType)
		argNum++
	}

	if req.PetSize != nil && *req.PetSize != "" {
		whereClauses = append(whereClauses, fmt.Sprintf("$%d = ANY(cp.accepted_pet_sizes)", argNum))
		args = append(args, *req.PetSize)
		argNum++
	}

	if req.MinRating != nil && *req.MinRating > 0 {
		whereClauses = append(whereClauses, fmt.Sprintf("cp.average_rating >= $%d", argNum))
		args = append(args, *req.MinRating)
		argNum++
	}

	// Location-based search
	if req.Latitude != nil && req.Longitude != nil {
		radiusKm := 10
		if req.RadiusKm != nil {
			radiusKm = *req.RadiusKm
		}
		// Haversine formula approximation
		whereClauses = append(whereClauses, fmt.Sprintf(`
			(6371 * acos(cos(radians($%d)) * cos(radians(cp.latitude)) * cos(radians(cp.longitude) - radians($%d)) + sin(radians($%d)) * sin(radians(cp.latitude)))) <= $%d
		`, argNum, argNum+1, argNum+2, argNum+3))
		args = append(args, *req.Latitude, *req.Longitude, *req.Latitude, radiusKm)
		argNum += 4
	}

	whereClause := strings.Join(whereClauses, " AND ")

	// Count total
	countQuery := fmt.Sprintf(`
		SELECT COUNT(DISTINCT cp.id)
		FROM caregiver_profiles cp
		WHERE %s
	`, whereClause)

	var total int
	err := r.db.QueryRow(ctx, countQuery, args...).Scan(&total)
	if err != nil {
		return nil, 0, err
	}

	// Get page
	limit := 20
	if req.Limit > 0 && req.Limit <= 100 {
		limit = req.Limit
	}
	page := 1
	if req.Page > 0 {
		page = req.Page
	}
	offset := (page - 1) * limit

	args = append(args, limit, offset)

	query := fmt.Sprintf(`
		SELECT 
			cp.id, cp.user_id, cp.bio, cp.years_of_experience, cp.headline,
			cp.address, cp.city, cp.state, cp.postal_code, cp.country,
			cp.latitude, cp.longitude, cp.service_radius_km,
			cp.is_verified, cp.verification_date, cp.background_check_status,
			cp.background_check_date, cp.background_check_expiry,
			cp.id_verified, cp.id_document_url, cp.certifications,
			cp.pet_first_aid_certified, cp.insurance_verified,
			cp.insurance_policy_number, cp.insurance_expiry,
			cp.accepted_pet_types, cp.accepted_pet_sizes, cp.max_pets_at_once,
			cp.has_fenced_yard, cp.has_own_transport, cp.smoke_free_home,
			cp.has_children, cp.has_other_pets, cp.other_pets_description,
			cp.average_rating, cp.total_reviews, cp.total_bookings,
			cp.completion_rate, cp.response_time_hours,
			cp.is_active, cp.is_accepting_bookings, cp.created_at, cp.updated_at,
			u.display_name, u.avatar_url, u.email
		FROM caregiver_profiles cp
		JOIN users u ON cp.user_id = u.id
		WHERE %s
		ORDER BY cp.average_rating DESC, cp.total_reviews DESC
		LIMIT $%d OFFSET $%d
	`, whereClause, argNum, argNum+1)

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var profiles []models.CaregiverProfile
	for rows.Next() {
		var p models.CaregiverProfile
		err := rows.Scan(
			&p.ID, &p.UserID, &p.Bio, &p.YearsOfExperience, &p.Headline,
			&p.Address, &p.City, &p.State, &p.PostalCode, &p.Country,
			&p.Latitude, &p.Longitude, &p.ServiceRadiusKm,
			&p.IsVerified, &p.VerificationDate, &p.BackgroundCheckStatus,
			&p.BackgroundCheckDate, &p.BackgroundCheckExpiry,
			&p.IDVerified, &p.IDDocumentURL, &p.Certifications,
			&p.PetFirstAidCertified, &p.InsuranceVerified,
			&p.InsurancePolicyNumber, &p.InsuranceExpiry,
			&p.AcceptedPetTypes, &p.AcceptedPetSizes, &p.MaxPetsAtOnce,
			&p.HasFencedYard, &p.HasOwnTransport, &p.SmokeFreeHome,
			&p.HasChildren, &p.HasOtherPets, &p.OtherPetsDescription,
			&p.AverageRating, &p.TotalReviews, &p.TotalBookings,
			&p.CompletionRate, &p.ResponseTimeHours,
			&p.IsActive, &p.IsAcceptingBookings, &p.CreatedAt, &p.UpdatedAt,
			&p.UserName, &p.UserAvatar, &p.UserEmail,
		)
		if err != nil {
			return nil, 0, err
		}
		profiles = append(profiles, p)
	}

	return profiles, total, nil
}

// AddGalleryImage adds an image to caregiver's gallery
func (r *CaregiverRepository) AddGalleryImage(ctx context.Context, caregiverID uuid.UUID, imageURL string, caption *string, isPrimary bool) (*models.CaregiverGallery, error) {
	// If this is primary, unset other primaries
	if isPrimary {
		_, err := r.db.Exec(ctx, "UPDATE caregiver_gallery SET is_primary = false WHERE caregiver_id = $1", caregiverID)
		if err != nil {
			return nil, err
		}
	}

	var gallery models.CaregiverGallery
	err := r.db.QueryRow(ctx, `
		INSERT INTO caregiver_gallery (caregiver_id, image_url, caption, is_primary)
		VALUES ($1, $2, $3, $4)
		RETURNING id, caregiver_id, image_url, caption, is_primary, display_order, created_at
	`, caregiverID, imageURL, caption, isPrimary).Scan(
		&gallery.ID, &gallery.CaregiverID, &gallery.ImageURL,
		&gallery.Caption, &gallery.IsPrimary, &gallery.DisplayOrder, &gallery.CreatedAt,
	)

	if err != nil {
		return nil, err
	}

	return &gallery, nil
}

// GetGallery returns all gallery images for a caregiver
func (r *CaregiverRepository) GetGallery(ctx context.Context, caregiverID uuid.UUID) ([]models.CaregiverGallery, error) {
	query := `
		SELECT id, caregiver_id, image_url, caption, is_primary, display_order, created_at
		FROM caregiver_gallery
		WHERE caregiver_id = $1
		ORDER BY is_primary DESC, display_order
	`

	rows, err := r.db.Query(ctx, query, caregiverID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var gallery []models.CaregiverGallery
	for rows.Next() {
		var g models.CaregiverGallery
		err := rows.Scan(&g.ID, &g.CaregiverID, &g.ImageURL, &g.Caption, &g.IsPrimary, &g.DisplayOrder, &g.CreatedAt)
		if err != nil {
			return nil, err
		}
		gallery = append(gallery, g)
	}

	return gallery, nil
}

// DeleteGalleryImage removes an image from gallery
func (r *CaregiverRepository) DeleteGalleryImage(ctx context.Context, imageID uuid.UUID) error {
	_, err := r.db.Exec(ctx, "DELETE FROM caregiver_gallery WHERE id = $1", imageID)
	return err
}
