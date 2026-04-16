package repositories

import (
	"context"
	"database/sql"
	"strconv"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"pawpal-backend/internal/models"
)

// VetRepository handles vet profile database operations
type VetRepository struct {
	db *pgxpool.Pool
}

// NewVetRepository creates a new VetRepository
func NewVetRepository(db *pgxpool.Pool) *VetRepository {
	return &VetRepository{db: db}
}

// CreateOrUpdate creates or updates a vet profile
func (r *VetRepository) CreateOrUpdate(ctx context.Context, profile *models.VetProfile) error {
	// Check if profile exists
	var existingID uuid.UUID
	err := r.db.QueryRow(ctx, "SELECT id FROM vet_profiles WHERE user_id = $1", profile.UserID).Scan(&existingID)

	if err == pgx.ErrNoRows {
		// Create new profile
		query := `
			INSERT INTO vet_profiles (
				id, user_id, full_name, degree, license_number, specialization, experience,
				clinic_name, clinic_address, city, state, zip_code, phone, consultation_fee,
				currency, bio, profile_photo_url, availability_hours, is_available, created_at, updated_at
			) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21)
			RETURNING id, rating, total_reviews, is_verified, created_at, updated_at`

		profile.ID = uuid.New()
		profile.CreatedAt = time.Now()
		profile.UpdatedAt = time.Now()
		
		// Ensure specialization is not nil
		if profile.Specialization == nil {
			profile.Specialization = []string{}
		}

		return r.db.QueryRow(ctx, query,
			profile.ID, profile.UserID, profile.FullName, profile.Degree, profile.LicenseNumber,
			profile.Specialization, profile.Experience, profile.ClinicName, profile.ClinicAddress,
			profile.City, profile.State, profile.ZipCode, profile.Phone, profile.ConsultationFee,
			profile.Currency, profile.Bio, profile.ProfilePhotoURL, profile.AvailabilityHours,
			profile.IsAvailable, profile.CreatedAt, profile.UpdatedAt,
		).Scan(&profile.ID, &profile.Rating, &profile.TotalReviews, &profile.IsVerified, &profile.CreatedAt, &profile.UpdatedAt)
	}

	// Update existing profile
	// Ensure specialization is not nil
	if profile.Specialization == nil {
		profile.Specialization = []string{}
	}
	
	query := `
		UPDATE vet_profiles SET
			full_name = $2, degree = $3, license_number = $4, specialization = $5, experience = $6,
			clinic_name = $7, clinic_address = $8, city = $9, state = $10, zip_code = $11,
			phone = $12, consultation_fee = $13, currency = $14, bio = $15, profile_photo_url = $16,
			availability_hours = $17, is_available = $18, updated_at = $19
		WHERE user_id = $1`

	_, err = r.db.Exec(ctx, query,
		profile.UserID, profile.FullName, profile.Degree, profile.LicenseNumber,
		profile.Specialization, profile.Experience, profile.ClinicName, profile.ClinicAddress,
		profile.City, profile.State, profile.ZipCode, profile.Phone, profile.ConsultationFee,
		profile.Currency, profile.Bio, profile.ProfilePhotoURL, profile.AvailabilityHours,
		profile.IsAvailable, time.Now(),
	)

	if err != nil {
		return err
	}

	// Fetch updated profile
	return r.GetByUserID(ctx, profile.UserID, profile)
}

// GetByUserID gets a vet profile by user ID
func (r *VetRepository) GetByUserID(ctx context.Context, userID uuid.UUID, profile *models.VetProfile) error {
	query := `
		SELECT id, user_id, full_name, degree, license_number, specialization, experience,
			clinic_name, clinic_address, city, state, zip_code, phone, consultation_fee,
			currency, bio, profile_photo_url, availability_hours, rating, total_reviews,
			is_verified, is_available, created_at, updated_at
		FROM vet_profiles WHERE user_id = $1`

	var specialization []string
	err := r.db.QueryRow(ctx, query, userID).Scan(
		&profile.ID, &profile.UserID, &profile.FullName, &profile.Degree, &profile.LicenseNumber,
		&specialization, &profile.Experience, &profile.ClinicName, &profile.ClinicAddress,
		&profile.City, &profile.State, &profile.ZipCode, &profile.Phone, &profile.ConsultationFee,
		&profile.Currency, &profile.Bio, &profile.ProfilePhotoURL, &profile.AvailabilityHours,
		&profile.Rating, &profile.TotalReviews, &profile.IsVerified, &profile.IsAvailable,
		&profile.CreatedAt, &profile.UpdatedAt,
	)
	
	profile.Specialization = specialization
	return err
}

// List lists all available vets with filters
func (r *VetRepository) List(ctx context.Context, filters map[string]interface{}, limit, offset int) ([]models.VetProfile, int, error) {
	// Build query - join with users table to get avatar_url
	query := `
		SELECT vp.id, vp.user_id, vp.full_name, vp.degree, vp.license_number, vp.specialization, vp.experience,
			vp.clinic_name, vp.clinic_address, vp.city, vp.state, vp.zip_code, vp.phone, vp.consultation_fee,
			vp.currency, vp.bio, COALESCE(u.avatar_url, vp.profile_photo_url) as profile_photo_url, vp.availability_hours, vp.rating, vp.total_reviews,
			vp.is_verified, vp.is_available, vp.created_at, vp.updated_at
		FROM vet_profiles vp
		LEFT JOIN users u ON vp.user_id = u.id
		WHERE vp.is_available = true`

	args := []interface{}{}
	argCount := 0

	if city, ok := filters["city"].(string); ok && city != "" {
		argCount++
		query += " AND LOWER(vp.city) = LOWER($" + strconv.Itoa(argCount) + ")"
		args = append(args, city)
	}

	if spec, ok := filters["specialization"].(string); ok && spec != "" {
		argCount++
		query += " AND $" + strconv.Itoa(argCount) + " = ANY(vp.specialization)"
		args = append(args, spec)
	}

	if minRating, ok := filters["minRating"].(float64); ok && minRating > 0 {
		argCount++
		query += " AND vp.rating >= $" + strconv.Itoa(argCount)
		args = append(args, minRating)
	}

	query += " ORDER BY vp.rating DESC, vp.total_reviews DESC"
	query += " LIMIT $" + strconv.Itoa(argCount+1) + " OFFSET $" + strconv.Itoa(argCount+2)
	args = append(args, limit, offset)

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	vets := []models.VetProfile{}
	for rows.Next() {
		var vet models.VetProfile
		var specialization []string
		err := rows.Scan(
			&vet.ID, &vet.UserID, &vet.FullName, &vet.Degree, &vet.LicenseNumber,
			&specialization, &vet.Experience, &vet.ClinicName, &vet.ClinicAddress,
			&vet.City, &vet.State, &vet.ZipCode, &vet.Phone, &vet.ConsultationFee, &vet.Currency,
			&vet.Bio, &vet.ProfilePhotoURL, &vet.AvailabilityHours, &vet.Rating, &vet.TotalReviews,
			&vet.IsVerified, &vet.IsAvailable, &vet.CreatedAt, &vet.UpdatedAt,
		)
		if err != nil {
			continue
		}
		vet.Specialization = specialization
		vets = append(vets, vet)
	}

	// Get total count
	countQuery := "SELECT COUNT(*) FROM vet_profiles WHERE is_available = true"
	countArgs := []interface{}{}
	argCount = 0

	if city, ok := filters["city"].(string); ok && city != "" {
		argCount++
		countQuery += " AND LOWER(city) = LOWER($" + strconv.Itoa(argCount) + ")"
		countArgs = append(countArgs, city)
	}

	if spec, ok := filters["specialization"].(string); ok && spec != "" {
		argCount++
		countQuery += " AND $" + strconv.Itoa(argCount) + " = ANY(specialization)"
		countArgs = append(countArgs, spec)
	}

	if minRating, ok := filters["minRating"].(float64); ok && minRating > 0 {
		argCount++
		countQuery += " AND rating >= $" + strconv.Itoa(argCount)
		countArgs = append(countArgs, minRating)
	}

	var total int
	err = r.db.QueryRow(ctx, countQuery, countArgs...).Scan(&total)
	if err != nil {
		total = 0
	}

	return vets, total, nil
}

// GetReviews returns paginated reviews for a vet user.
func (r *VetRepository) GetReviews(ctx context.Context, vetUserID uuid.UUID, page, limit int) ([]models.VetReview, int, error) {
	if page <= 0 {
		page = 1
	}
	if limit <= 0 || limit > 100 {
		limit = 20
	}

	var total int
	err := r.db.QueryRow(ctx, `
		SELECT COUNT(*)
		FROM vet_reviews
		WHERE vet_id = $1
	`, vetUserID).Scan(&total)
	if err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * limit
	rows, err := r.db.Query(ctx, `
		SELECT
			vr.id,
			vr.vet_id,
			vr.user_id,
			u.display_name,
			u.avatar_url,
			vr.rating,
			vr.comment,
			vr.created_at,
			vr.updated_at
		FROM vet_reviews vr
		JOIN users u ON u.id = vr.user_id
		WHERE vr.vet_id = $1
		ORDER BY vr.created_at DESC
		LIMIT $2 OFFSET $3
	`, vetUserID, limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	reviews := make([]models.VetReview, 0)
	for rows.Next() {
		var review models.VetReview
		err := rows.Scan(
			&review.ID,
			&review.VetID,
			&review.UserID,
			&review.UserName,
			&review.UserAvatar,
			&review.Rating,
			&review.Comment,
			&review.CreatedAt,
			&review.UpdatedAt,
		)
		if err != nil {
			return nil, 0, err
		}
		reviews = append(reviews, review)
	}

	if err := rows.Err(); err != nil {
		return nil, 0, err
	}

	return reviews, total, nil
}

// AddReview creates a review for a vet user.
func (r *VetRepository) AddReview(ctx context.Context, review *models.VetReview) error {
	review.ID = uuid.New()

	return r.db.QueryRow(ctx, `
		INSERT INTO vet_reviews (
			id,
			vet_id,
			user_id,
			rating,
			comment,
			created_at,
			updated_at
		) VALUES ($1, $2, $3, $4, $5, NOW(), NOW())
		RETURNING created_at, updated_at
	`, review.ID, review.VetID, review.UserID, review.Rating, review.Comment).Scan(&review.CreatedAt, &review.UpdatedAt)
}

// UserHasCompletedAppointmentWithVet checks if an owner has at least one completed appointment with the vet.
func (r *VetRepository) UserHasCompletedAppointmentWithVet(ctx context.Context, ownerID, vetUserID uuid.UUID) (bool, error) {
	var exists bool
	err := r.db.QueryRow(ctx, `
		SELECT EXISTS(
			SELECT 1
			FROM vet_appointments
			WHERE pet_owner_id = $1
				AND vet_user_id = $2
				AND status = 'completed'
		)
	`, ownerID, vetUserID).Scan(&exists)
	if err != nil {
		return false, err
	}

	return exists, nil
}

// CheckUserIsVet checks if a user has vet role
func (r *VetRepository) CheckUserIsVet(ctx context.Context, userID uuid.UUID) (bool, error) {
	var role sql.NullString
	var accountType sql.NullString
	
	// Check both user_role and account_type fields for backward compatibility
	err := r.db.QueryRow(ctx, `
		SELECT user_role, account_type 
		FROM users 
		WHERE id = $1
	`, userID).Scan(&role, &accountType)
	
	if err != nil {
		if err == sql.ErrNoRows || err == pgx.ErrNoRows {
			return false, nil
		}
		return false, err
	}
	
	// Check user_role field (for email sign-ups)
	if role.Valid && role.String == "vet" {
		return true, nil
	}
	
	// Check account_type field (for Google Sign-In)
	if accountType.Valid && accountType.String == "vet" {
		return true, nil
	}
	
	return false, nil
}
