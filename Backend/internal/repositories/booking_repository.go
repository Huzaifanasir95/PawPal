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

// BookingRepository handles booking-related database operations
type BookingRepository struct {
	db *pgxpool.Pool
}

// NewBookingRepository creates a new booking repository
func NewBookingRepository(db *pgxpool.Pool) *BookingRepository {
	return &BookingRepository{db: db}
}

// CreateBooking creates a new service booking
func (r *BookingRepository) CreateBooking(ctx context.Context, booking *models.ServiceBooking) error {
	query := `
		INSERT INTO service_bookings (
			pet_owner_id, caregiver_id, service_id, pet_ids,
			start_datetime, end_datetime,
			service_location_type, service_address, service_latitude, service_longitude,
			special_instructions, emergency_contact_name, emergency_contact_phone,
			base_amount, additional_pets_fee, service_fee, total_amount, currency
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18
		) RETURNING id, booking_number, status, created_at, updated_at
	`

	currency := booking.Currency
	if currency == "" {
		currency = "PKR"
	}

	// Convert UUID slice to string slice for PostgreSQL array encoding
	petIDStrings := make([]string, len(booking.PetIDs))
	for i, id := range booking.PetIDs {
		petIDStrings[i] = id.String()
	}

	err := r.db.QueryRow(ctx, query,
		booking.PetOwnerID, booking.CaregiverID, booking.ServiceID,
		petIDStrings, booking.StartDatetime, booking.EndDatetime,
		booking.ServiceLocationType, booking.ServiceAddress, booking.ServiceLatitude, booking.ServiceLongitude,
		booking.SpecialInstructions, booking.EmergencyContactName, booking.EmergencyContactPhone,
		booking.BaseAmount, booking.AdditionalPetsFee, booking.ServiceFee, booking.TotalAmount, currency,
	).Scan(&booking.ID, &booking.BookingNumber, &booking.Status, &booking.CreatedAt, &booking.UpdatedAt)

	return err
}

// GetBookingByID retrieves a booking by its ID
func (r *BookingRepository) GetBookingByID(ctx context.Context, bookingID uuid.UUID) (*models.ServiceBooking, error) {
	query := `
		SELECT 
			sb.id, sb.booking_number, sb.pet_owner_id, sb.caregiver_id,
			sb.service_id, sb.pet_ids, sb.start_datetime, sb.end_datetime,
			sb.service_location_type, sb.service_address, sb.service_latitude, sb.service_longitude,
			sb.special_instructions, sb.emergency_contact_name, sb.emergency_contact_phone,
			sb.base_amount, sb.additional_pets_fee, sb.service_fee, sb.discount_amount,
			sb.total_amount, sb.currency, sb.status,
			sb.requested_at, sb.responded_at, sb.started_at, sb.completed_at,
			sb.cancelled_at, sb.cancellation_reason, sb.created_at, sb.updated_at,
			u_owner.display_name, u_owner.avatar_url,
			u_caregiver.display_name, u_caregiver.avatar_url,
			cst.name, cst.display_name
		FROM service_bookings sb
		JOIN users u_owner ON sb.pet_owner_id = u_owner.id
		JOIN caregiver_profiles cp ON sb.caregiver_id = cp.id
		JOIN users u_caregiver ON cp.user_id = u_caregiver.id
		JOIN caregiver_services cs ON sb.service_id = cs.id
		JOIN caregiver_service_types cst ON cs.service_type_id = cst.id
		WHERE sb.id = $1
	`

	var b models.ServiceBooking
	err := r.db.QueryRow(ctx, query, bookingID).Scan(
		&b.ID, &b.BookingNumber, &b.PetOwnerID, &b.CaregiverID,
		&b.ServiceID, &b.PetIDs, &b.StartDatetime, &b.EndDatetime,
		&b.ServiceLocationType, &b.ServiceAddress, &b.ServiceLatitude, &b.ServiceLongitude,
		&b.SpecialInstructions, &b.EmergencyContactName, &b.EmergencyContactPhone,
		&b.BaseAmount, &b.AdditionalPetsFee, &b.ServiceFee, &b.DiscountAmount,
		&b.TotalAmount, &b.Currency, &b.Status,
		&b.RequestedAt, &b.RespondedAt, &b.StartedAt, &b.CompletedAt,
		&b.CancelledAt, &b.CancellationReason, &b.CreatedAt, &b.UpdatedAt,
		&b.OwnerName, &b.OwnerAvatar,
		&b.CaregiverName, &b.CaregiverAvatar,
		&b.ServiceName, &b.ServiceName,
	)

	if err == pgx.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	return &b, nil
}

// GetBookingsByOwner returns bookings for a pet owner
func (r *BookingRepository) GetBookingsByOwner(ctx context.Context, ownerID uuid.UUID, status *string, page, limit int) ([]models.ServiceBooking, int, error) {
	return r.getBookings(ctx, "pet_owner_id", ownerID, status, page, limit)
}

// GetBookingsByCaregiver returns bookings for a caregiver
func (r *BookingRepository) GetBookingsByCaregiver(ctx context.Context, caregiverID uuid.UUID, status *string, page, limit int) ([]models.ServiceBooking, int, error) {
	return r.getBookings(ctx, "caregiver_id", caregiverID, status, page, limit)
}

func (r *BookingRepository) getBookings(ctx context.Context, filterField string, filterID uuid.UUID, status *string, page, limit int) ([]models.ServiceBooking, int, error) {
	var whereClauses []string
	var args []interface{}
	argNum := 1

	whereClauses = append(whereClauses, fmt.Sprintf("sb.%s = $%d", filterField, argNum))
	args = append(args, filterID)
	argNum++

	if status != nil && *status != "" {
		statusParts := strings.Split(*status, ",")
		filteredStatuses := make([]string, 0, len(statusParts))
		for _, s := range statusParts {
			trimmed := strings.TrimSpace(s)
			if trimmed == "" {
				continue
			}
			filteredStatuses = append(filteredStatuses, trimmed)
		}

		switch len(filteredStatuses) {
		case 0:
			// Ignore empty status filters.
		case 1:
			whereClauses = append(whereClauses, fmt.Sprintf("sb.status = $%d", argNum))
			args = append(args, filteredStatuses[0])
			argNum++
		default:
			whereClauses = append(whereClauses, fmt.Sprintf("sb.status = ANY($%d)", argNum))
			args = append(args, filteredStatuses)
			argNum++
		}
	}

	whereClause := strings.Join(whereClauses, " AND ")

	// Count total
	countQuery := fmt.Sprintf("SELECT COUNT(*) FROM service_bookings sb WHERE %s", whereClause)
	var total int
	err := r.db.QueryRow(ctx, countQuery, args...).Scan(&total)
	if err != nil {
		return nil, 0, err
	}

	if limit <= 0 {
		limit = 20
	}
	if page <= 0 {
		page = 1
	}
	offset := (page - 1) * limit

	args = append(args, limit, offset)

	query := fmt.Sprintf(`
		SELECT 
			sb.id, sb.booking_number, sb.pet_owner_id, sb.caregiver_id,
			sb.service_id, sb.pet_ids, sb.start_datetime, sb.end_datetime,
			sb.service_location_type, sb.service_address, sb.service_latitude, sb.service_longitude,
			sb.special_instructions, sb.emergency_contact_name, sb.emergency_contact_phone,
			sb.base_amount, sb.additional_pets_fee, sb.service_fee, sb.discount_amount,
			sb.total_amount, sb.currency, sb.status,
			sb.requested_at, sb.responded_at, sb.started_at, sb.completed_at,
			sb.cancelled_at, sb.cancellation_reason, sb.created_at, sb.updated_at,
			u_owner.display_name, u_owner.avatar_url,
			u_caregiver.display_name, u_caregiver.avatar_url,
			cst.name, cst.display_name
		FROM service_bookings sb
		JOIN users u_owner ON sb.pet_owner_id = u_owner.id
		JOIN caregiver_profiles cp ON sb.caregiver_id = cp.id
		JOIN users u_caregiver ON cp.user_id = u_caregiver.id
		JOIN caregiver_services cs ON sb.service_id = cs.id
		JOIN caregiver_service_types cst ON cs.service_type_id = cst.id
		WHERE %s
		ORDER BY sb.start_datetime DESC, sb.created_at DESC
		LIMIT $%d OFFSET $%d
	`, whereClause, argNum, argNum+1)

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var bookings []models.ServiceBooking
	for rows.Next() {
		var b models.ServiceBooking
		err := rows.Scan(
			&b.ID, &b.BookingNumber, &b.PetOwnerID, &b.CaregiverID,
			&b.ServiceID, &b.PetIDs, &b.StartDatetime, &b.EndDatetime,
			&b.ServiceLocationType, &b.ServiceAddress, &b.ServiceLatitude, &b.ServiceLongitude,
			&b.SpecialInstructions, &b.EmergencyContactName, &b.EmergencyContactPhone,
			&b.BaseAmount, &b.AdditionalPetsFee, &b.ServiceFee, &b.DiscountAmount,
			&b.TotalAmount, &b.Currency, &b.Status,
			&b.RequestedAt, &b.RespondedAt, &b.StartedAt, &b.CompletedAt,
			&b.CancelledAt, &b.CancellationReason, &b.CreatedAt, &b.UpdatedAt,
			&b.OwnerName, &b.OwnerAvatar,
			&b.CaregiverName, &b.CaregiverAvatar,
			&b.ServiceName, &b.ServiceName,
		)
		if err != nil {
			return nil, 0, err
		}
		bookings = append(bookings, b)
	}

	return bookings, total, nil
}

// RespondToBooking updates booking status (accept/reject/cancel)
func (r *BookingRepository) RespondToBooking(ctx context.Context, bookingID uuid.UUID, status string, reason *string) error {
	query := `
		UPDATE service_bookings 
		SET status = $2, 
			responded_at = CURRENT_TIMESTAMP,
			updated_at = CURRENT_TIMESTAMP
		WHERE id = $1
	`
	_, err := r.db.Exec(ctx, query, bookingID, status)
	return err
}

// CancelBooking cancels a booking
func (r *BookingRepository) CancelBooking(ctx context.Context, bookingID uuid.UUID, cancelledBy uuid.UUID, reason string, isOwner bool) error {
	status := "cancelled_caregiver"
	if isOwner {
		status = "cancelled_owner"
	}

	query := `
		UPDATE service_bookings 
		SET status = $2,
			cancellation_reason = $3,
			cancelled_at = CURRENT_TIMESTAMP,
			updated_at = CURRENT_TIMESTAMP
		WHERE id = $1
	`
	_, err := r.db.Exec(ctx, query, bookingID, status, reason)
	return err
}

// StartService marks a service as in-progress
func (r *BookingRepository) StartService(ctx context.Context, bookingID uuid.UUID, startLat, startLong *float64) error {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	// Update booking status
	_, err = tx.Exec(ctx, `
		UPDATE service_bookings 
		SET status = 'in_progress',
			started_at = CURRENT_TIMESTAMP,
			updated_at = CURRENT_TIMESTAMP
		WHERE id = $1
	`, bookingID)
	if err != nil {
		return err
	}

	// Create tracking entry if location provided
	if startLat != nil && startLong != nil {
		_, err = tx.Exec(ctx, `
			INSERT INTO booking_tracking (booking_id, latitude, longitude, activity_type)
			VALUES ($1, $2, $3, 'started')
		`, bookingID, *startLat, *startLong)
		if err != nil {
			return err
		}
	}

	return tx.Commit(ctx)
}

// CompleteService marks a service as completed
func (r *BookingRepository) CompleteService(ctx context.Context, bookingID uuid.UUID) error {
	query := `
		UPDATE service_bookings 
		SET status = 'completed',
			completed_at = CURRENT_TIMESTAMP,
			updated_at = CURRENT_TIMESTAMP
		WHERE id = $1
	`
	_, err := r.db.Exec(ctx, query, bookingID)
	return err
}

// AddTrackingPoint adds a GPS tracking point
func (r *BookingRepository) AddTrackingPoint(ctx context.Context, tracking *models.BookingTracking) error {
	query := `
		INSERT INTO booking_tracking (
			booking_id, latitude, longitude, accuracy_meters, activity_type, note
		) VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id, recorded_at
	`

	err := r.db.QueryRow(ctx, query,
		tracking.BookingID, tracking.Latitude, tracking.Longitude,
		tracking.AccuracyMeters, tracking.ActivityType, tracking.Note,
	).Scan(&tracking.ID, &tracking.RecordedAt)

	return err
}

// GetTrackingPoints returns all tracking points for a booking
func (r *BookingRepository) GetTrackingPoints(ctx context.Context, bookingID uuid.UUID) ([]models.BookingTracking, error) {
	query := `
		SELECT id, booking_id, latitude, longitude, accuracy_meters, activity_type, note, recorded_at
		FROM booking_tracking
		WHERE booking_id = $1
		ORDER BY recorded_at
	`

	rows, err := r.db.Query(ctx, query, bookingID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var points []models.BookingTracking
	for rows.Next() {
		var t models.BookingTracking
		err := rows.Scan(
			&t.ID, &t.BookingID, &t.Latitude, &t.Longitude,
			&t.AccuracyMeters, &t.ActivityType, &t.Note, &t.RecordedAt,
		)
		if err != nil {
			return nil, err
		}
		points = append(points, t)
	}

	return points, nil
}

// CreateCompletionReport creates a service completion report
func (r *BookingRepository) CreateCompletionReport(ctx context.Context, report *models.BookingCompletionReport) error {
	query := `
		INSERT INTO booking_completion_reports (
			booking_id, summary, activities_performed, feeding_notes,
			bathroom_notes, behavior_notes, health_observations, photo_urls
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		RETURNING id, submitted_at
	`

	err := r.db.QueryRow(ctx, query,
		report.BookingID, report.Summary, report.ActivitiesPerformed,
		report.FeedingNotes, report.BathroomNotes, report.BehaviorNotes,
		report.HealthObservations, report.PhotoURLs,
	).Scan(&report.ID, &report.SubmittedAt)

	return err
}

// GetCompletionReport returns the completion report for a booking
func (r *BookingRepository) GetCompletionReport(ctx context.Context, bookingID uuid.UUID) (*models.BookingCompletionReport, error) {
	query := `
		SELECT id, booking_id, summary, activities_performed, feeding_notes,
			bathroom_notes, behavior_notes, health_observations, photo_urls, video_urls,
			actual_duration_minutes, distance_walked_km, submitted_at, owner_acknowledged_at
		FROM booking_completion_reports
		WHERE booking_id = $1
	`

	var report models.BookingCompletionReport
	err := r.db.QueryRow(ctx, query, bookingID).Scan(
		&report.ID, &report.BookingID, &report.Summary, &report.ActivitiesPerformed,
		&report.FeedingNotes, &report.BathroomNotes, &report.BehaviorNotes,
		&report.HealthObservations, &report.PhotoURLs, &report.VideoURLs,
		&report.ActualDurationMinutes, &report.DistanceWalkedKm,
		&report.SubmittedAt, &report.OwnerAcknowledgedAt,
	)

	if err == pgx.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	return &report, nil
}

// CreateOwnerReview creates a review by the pet owner for the caregiver
func (r *BookingRepository) CreateOwnerReview(ctx context.Context, bookingID uuid.UUID, rating int, review *string, communicationRating, reliabilityRating, careQualityRating *int) error {
	// First check if review exists for this booking
	var existingID *uuid.UUID
	err := r.db.QueryRow(ctx, "SELECT id FROM service_reviews WHERE booking_id = $1", bookingID).Scan(&existingID)

	if err == pgx.ErrNoRows {
		// Create new review
		_, err = r.db.Exec(ctx, `
			INSERT INTO service_reviews (booking_id, owner_rating, owner_review, owner_review_at,
				communication_rating, reliability_rating, care_quality_rating)
			VALUES ($1, $2, $3, CURRENT_TIMESTAMP, $4, $5, $6)
		`, bookingID, rating, review, communicationRating, reliabilityRating, careQualityRating)
		return err
	}
	if err != nil {
		return err
	}

	// Update existing review
	_, err = r.db.Exec(ctx, `
		UPDATE service_reviews 
		SET owner_rating = $2, owner_review = $3, owner_review_at = CURRENT_TIMESTAMP,
			communication_rating = $4, reliability_rating = $5, care_quality_rating = $6,
			updated_at = CURRENT_TIMESTAMP
		WHERE booking_id = $1
	`, bookingID, rating, review, communicationRating, reliabilityRating, careQualityRating)
	return err
}

// CreateCaregiverReview creates a review by the caregiver for the pet/owner
func (r *BookingRepository) CreateCaregiverReview(ctx context.Context, bookingID uuid.UUID, rating int, review *string, petBehaviorRating *int) error {
	// First check if review exists for this booking
	var existingID *uuid.UUID
	err := r.db.QueryRow(ctx, "SELECT id FROM service_reviews WHERE booking_id = $1", bookingID).Scan(&existingID)

	if err == pgx.ErrNoRows {
		// Create new review
		_, err = r.db.Exec(ctx, `
			INSERT INTO service_reviews (booking_id, caregiver_rating, caregiver_review, caregiver_review_at, pet_behavior_rating)
			VALUES ($1, $2, $3, CURRENT_TIMESTAMP, $4)
		`, bookingID, rating, review, petBehaviorRating)
		return err
	}
	if err != nil {
		return err
	}

	// Update existing review
	_, err = r.db.Exec(ctx, `
		UPDATE service_reviews 
		SET caregiver_rating = $2, caregiver_review = $3, caregiver_review_at = CURRENT_TIMESTAMP,
			pet_behavior_rating = $4, updated_at = CURRENT_TIMESTAMP
		WHERE booking_id = $1
	`, bookingID, rating, review, petBehaviorRating)
	return err
}

// GetReviewsForCaregiver returns reviews for a caregiver
func (r *BookingRepository) GetReviewsForCaregiver(ctx context.Context, caregiverID uuid.UUID, page, limit int) ([]models.ServiceReview, int, error) {
	// Get caregiver profile ID
	var profileID uuid.UUID
	err := r.db.QueryRow(ctx, "SELECT id FROM caregiver_profiles WHERE user_id = $1", caregiverID).Scan(&profileID)
	if err != nil {
		return nil, 0, err
	}

	// Count total (reviews where owner has submitted a rating)
	var total int
	err = r.db.QueryRow(ctx, `
		SELECT COUNT(*) FROM service_reviews sr
		JOIN service_bookings sb ON sr.booking_id = sb.id
		WHERE sb.caregiver_id = $1 AND sr.owner_rating IS NOT NULL AND sr.is_public = true
	`, profileID).Scan(&total)
	if err != nil {
		return nil, 0, err
	}

	if limit <= 0 {
		limit = 20
	}
	if page <= 0 {
		page = 1
	}
	offset := (page - 1) * limit

	query := `
		SELECT 
			sr.id, sr.booking_id, sr.owner_rating, sr.owner_review, sr.owner_review_at,
			sr.communication_rating, sr.reliability_rating, sr.care_quality_rating,
			sr.is_public, sr.created_at,
			u.display_name, u.avatar_url
		FROM service_reviews sr
		JOIN service_bookings sb ON sr.booking_id = sb.id
		JOIN users u ON sb.pet_owner_id = u.id
		WHERE sb.caregiver_id = $1 AND sr.owner_rating IS NOT NULL AND sr.is_public = true
		ORDER BY sr.owner_review_at DESC
		LIMIT $2 OFFSET $3
	`

	rows, err := r.db.Query(ctx, query, profileID, limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var reviews []models.ServiceReview
	for rows.Next() {
		var rev models.ServiceReview
		err := rows.Scan(
			&rev.ID, &rev.BookingID, &rev.OwnerRating, &rev.OwnerReview, &rev.OwnerReviewAt,
			&rev.CommunicationRating, &rev.ReliabilityRating, &rev.CareQualityRating,
			&rev.IsPublic, &rev.CreatedAt,
			&rev.OwnerName, &rev.OwnerAvatar,
		)
		if err != nil {
			return nil, 0, err
		}
		reviews = append(reviews, rev)
	}

	return reviews, total, nil
}

// CreateIncidentReport creates an incident report
func (r *BookingRepository) CreateIncidentReport(ctx context.Context, incident *models.ServiceIncident) error {
	query := `
		INSERT INTO service_incidents (
			booking_id, reported_by, incident_type, severity, description,
			occurred_at, location_description, photo_urls, video_urls
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
		RETURNING id, incident_number, created_at
	`

	occurredAt := incident.OccurredAt
	if occurredAt.IsZero() {
		occurredAt = time.Now()
	}

	err := r.db.QueryRow(ctx, query,
		incident.BookingID, incident.ReportedBy, incident.IncidentType,
		incident.Severity, incident.Description, occurredAt,
		incident.LocationDescription, incident.PhotoURLs, incident.VideoURLs,
	).Scan(&incident.ID, &incident.IncidentNumber, &incident.CreatedAt)

	return err
}

// GetIncidentsByBooking returns incidents for a booking
func (r *BookingRepository) GetIncidentsByBooking(ctx context.Context, bookingID uuid.UUID) ([]models.ServiceIncident, error) {
	query := `
		SELECT 
			si.id, si.incident_number, si.booking_id, si.reported_by, 
			si.incident_type, si.severity, si.description, si.occurred_at,
			si.location_description, si.photo_urls, si.video_urls,
			si.status, si.resolution_notes, si.resolved_at, si.resolved_by,
			si.insurance_claim_filed, si.insurance_claim_number, si.insurance_claim_status,
			si.created_at, si.updated_at,
			u.display_name
		FROM service_incidents si
		JOIN users u ON si.reported_by = u.id
		WHERE si.booking_id = $1
		ORDER BY si.created_at DESC
	`

	rows, err := r.db.Query(ctx, query, bookingID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var incidents []models.ServiceIncident
	for rows.Next() {
		var inc models.ServiceIncident
		err := rows.Scan(
			&inc.ID, &inc.IncidentNumber, &inc.BookingID, &inc.ReportedBy,
			&inc.IncidentType, &inc.Severity, &inc.Description, &inc.OccurredAt,
			&inc.LocationDescription, &inc.PhotoURLs, &inc.VideoURLs,
			&inc.Status, &inc.ResolutionNotes, &inc.ResolvedAt, &inc.ResolvedBy,
			&inc.InsuranceClaimFiled, &inc.InsuranceClaimNumber, &inc.InsuranceClaimStatus,
			&inc.CreatedAt, &inc.UpdatedAt,
			&inc.ReporterName,
		)
		if err != nil {
			return nil, err
		}
		incidents = append(incidents, inc)
	}

	return incidents, nil
}

// UpdateIncidentStatus updates the status of an incident
func (r *BookingRepository) UpdateIncidentStatus(ctx context.Context, incidentID uuid.UUID, status string) error {
	_, err := r.db.Exec(ctx, `
		UPDATE service_incidents 
		SET status = $2, updated_at = CURRENT_TIMESTAMP
		WHERE id = $1
	`, incidentID, status)
	return err
}

// ResolveIncident marks an incident as resolved
func (r *BookingRepository) ResolveIncident(ctx context.Context, incidentID uuid.UUID, resolvedByID uuid.UUID, resolution string) error {
	_, err := r.db.Exec(ctx, `
		UPDATE service_incidents 
		SET status = 'resolved', resolution_notes = $2, resolved_at = CURRENT_TIMESTAMP, 
			resolved_by = $3, updated_at = CURRENT_TIMESTAMP
		WHERE id = $1
	`, incidentID, resolution, resolvedByID)
	return err
}

// CreatePayment creates a payment record
func (r *BookingRepository) CreatePayment(ctx context.Context, payment *models.BookingPayment) error {
	query := `
		INSERT INTO booking_payments (
			booking_id, amount, currency, payment_type, payment_method,
			transaction_id, status
		) VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING id, created_at
	`

	currency := payment.Currency
	if currency == "" {
		currency = "PKR"
	}

	err := r.db.QueryRow(ctx, query,
		payment.BookingID, payment.Amount, currency, payment.PaymentType,
		payment.PaymentMethod, payment.TransactionID, payment.Status,
	).Scan(&payment.ID, &payment.CreatedAt)

	return err
}

// GetPaymentsByBooking returns all payments for a booking
func (r *BookingRepository) GetPaymentsByBooking(ctx context.Context, bookingID uuid.UUID) ([]models.BookingPayment, error) {
	query := `
		SELECT id, booking_id, amount, currency, payment_type, payment_method,
			transaction_id, status, escrow_held_at, escrow_released_at,
			payout_status, payout_amount, platform_fee, payout_transaction_id, payout_at,
			created_at, updated_at
		FROM booking_payments
		WHERE booking_id = $1
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(ctx, query, bookingID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var payments []models.BookingPayment
	for rows.Next() {
		var p models.BookingPayment
		err := rows.Scan(
			&p.ID, &p.BookingID, &p.Amount, &p.Currency, &p.PaymentType, &p.PaymentMethod,
			&p.TransactionID, &p.Status, &p.EscrowHeldAt, &p.EscrowReleasedAt,
			&p.PayoutStatus, &p.PayoutAmount, &p.PlatformFee, &p.PayoutTransactionID, &p.PayoutAt,
			&p.CreatedAt, &p.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		payments = append(payments, p)
	}

	return payments, nil
}

// UpdatePaymentStatus updates the payment status
func (r *BookingRepository) UpdatePaymentStatus(ctx context.Context, paymentID uuid.UUID, status string) error {
	_, err := r.db.Exec(ctx, `
		UPDATE booking_payments SET status = $2, updated_at = CURRENT_TIMESTAMP WHERE id = $1
	`, paymentID, status)
	return err
}

// HoldPaymentInEscrow marks payment as held in escrow
func (r *BookingRepository) HoldPaymentInEscrow(ctx context.Context, paymentID uuid.UUID) error {
	_, err := r.db.Exec(ctx, `
		UPDATE booking_payments 
		SET status = 'held', escrow_held_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP
		WHERE id = $1
	`, paymentID)
	return err
}

// ReleasePaymentFromEscrow releases payment from escrow and initiates payout
func (r *BookingRepository) ReleasePaymentFromEscrow(ctx context.Context, paymentID uuid.UUID, payoutAmount, platformFee float64) error {
	_, err := r.db.Exec(ctx, `
		UPDATE booking_payments 
		SET status = 'completed', escrow_released_at = CURRENT_TIMESTAMP, 
			payout_status = 'pending', payout_amount = $2, platform_fee = $3,
			updated_at = CURRENT_TIMESTAMP
		WHERE id = $1
	`, paymentID, payoutAmount, platformFee)
	return err
}

// ProcessRefund processes a refund for a payment
func (r *BookingRepository) ProcessRefund(ctx context.Context, bookingID uuid.UUID, amount float64) error {
	_, err := r.db.Exec(ctx, `
		INSERT INTO booking_payments (booking_id, amount, currency, payment_type, status)
		SELECT $1, $2, currency, 'refund', 'completed'
		FROM booking_payments WHERE booking_id = $1 AND payment_type = 'deposit' LIMIT 1
	`, bookingID, amount)
	return err
}

// GetUpcomingBookingsForCaregiver returns upcoming bookings for notification
func (r *BookingRepository) GetUpcomingBookingsForCaregiver(ctx context.Context, caregiverID uuid.UUID, hours int) ([]models.ServiceBooking, error) {
	query := `
		SELECT 
			sb.id, sb.booking_number, sb.pet_owner_id, sb.caregiver_id,
			sb.service_id, sb.pet_ids, sb.start_datetime, sb.end_datetime,
			sb.service_location_type, sb.service_address, sb.service_latitude, sb.service_longitude,
			sb.special_instructions, sb.emergency_contact_name, sb.emergency_contact_phone,
			sb.base_amount, sb.additional_pets_fee, sb.service_fee, sb.discount_amount,
			sb.total_amount, sb.currency, sb.status,
			sb.requested_at, sb.responded_at, sb.started_at, sb.completed_at,
			sb.cancelled_at, sb.cancellation_reason, sb.created_at, sb.updated_at,
			u_owner.display_name, u_owner.avatar_url,
			u_caregiver.display_name, u_caregiver.avatar_url,
			cst.name, cst.display_name
		FROM service_bookings sb
		JOIN users u_owner ON sb.pet_owner_id = u_owner.id
		JOIN caregiver_profiles cp ON sb.caregiver_id = cp.id
		JOIN users u_caregiver ON cp.user_id = u_caregiver.id
		JOIN caregiver_services cs ON sb.service_id = cs.id
		JOIN caregiver_service_types cst ON cs.service_type_id = cst.id
		WHERE sb.caregiver_id = $1 
			AND sb.status = 'accepted'
			AND sb.start_datetime <= CURRENT_TIMESTAMP + interval '%d hours'
			AND sb.start_datetime > CURRENT_TIMESTAMP
		ORDER BY sb.start_datetime
	`

	formattedQuery := fmt.Sprintf(query, hours)
	rows, err := r.db.Query(ctx, formattedQuery, caregiverID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var bookings []models.ServiceBooking
	for rows.Next() {
		var b models.ServiceBooking
		err := rows.Scan(
			&b.ID, &b.BookingNumber, &b.PetOwnerID, &b.CaregiverID,
			&b.ServiceID, &b.PetIDs, &b.StartDatetime, &b.EndDatetime,
			&b.ServiceLocationType, &b.ServiceAddress, &b.ServiceLatitude, &b.ServiceLongitude,
			&b.SpecialInstructions, &b.EmergencyContactName, &b.EmergencyContactPhone,
			&b.BaseAmount, &b.AdditionalPetsFee, &b.ServiceFee, &b.DiscountAmount,
			&b.TotalAmount, &b.Currency, &b.Status,
			&b.RequestedAt, &b.RespondedAt, &b.StartedAt, &b.CompletedAt,
			&b.CancelledAt, &b.CancellationReason, &b.CreatedAt, &b.UpdatedAt,
			&b.OwnerName, &b.OwnerAvatar,
			&b.CaregiverName, &b.CaregiverAvatar,
			&b.ServiceName, &b.ServiceName,
		)
		if err != nil {
			return nil, err
		}
		bookings = append(bookings, b)
	}

	return bookings, nil
}
