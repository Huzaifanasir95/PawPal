package repositories

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"time"

	"pawpal-backend/internal/models"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// VetAppointmentRepository handles vet appointment database operations.
type VetAppointmentRepository struct {
	db *pgxpool.Pool
}

// NewVetAppointmentRepository creates a new vet appointment repository.
func NewVetAppointmentRepository(db *pgxpool.Pool) *VetAppointmentRepository {
	return &VetAppointmentRepository{db: db}
}

// Create creates a new vet appointment.
func (r *VetAppointmentRepository) Create(ctx context.Context, appointment *models.VetAppointment) error {
	if appointment.DurationMinutes <= 0 {
		appointment.DurationMinutes = 30
	}

	if appointment.MeetingType == "" {
		appointment.MeetingType = "in_person"
	}

	var petName string
	var petType string
	err := r.db.QueryRow(ctx, `
		SELECT name, type
		FROM pets
		WHERE id = $1 AND owner_id = $2
	`, appointment.PetID, appointment.PetOwnerID).Scan(&petName, &petType)
	if err == pgx.ErrNoRows {
		return errors.New("selected pet was not found for this user")
	}
	if err != nil {
		return err
	}

	var vetClinicAddress *string
	var vetAvailable bool
	err = r.db.QueryRow(ctx, `
		SELECT consultation_fee, currency, clinic_address, is_available
		FROM vet_profiles
		WHERE user_id = $1
	`, appointment.VetUserID).Scan(&appointment.FeeAmount, &appointment.Currency, &vetClinicAddress, &vetAvailable)
	if err == pgx.ErrNoRows {
		return errors.New("vet profile not found")
	}
	if err != nil {
		return err
	}

	if !vetAvailable {
		return errors.New("selected vet is currently unavailable")
	}

	if appointment.MeetingType == "in_person" && appointment.ClinicAddress == nil {
		appointment.ClinicAddress = vetClinicAddress
	}

	var overlapCount int
	err = r.db.QueryRow(ctx, `
		SELECT COUNT(*)
		FROM vet_appointments
		WHERE vet_user_id = $1
			AND status IN ('requested', 'confirmed')
			AND appointment_datetime < ($2 + (($3::text || ' minutes')::interval))
			AND (appointment_datetime + ((duration_minutes::text || ' minutes')::interval)) > $2
	`, appointment.VetUserID, appointment.AppointmentDatetime, appointment.DurationMinutes).Scan(&overlapCount)
	if err != nil {
		return err
	}
	if overlapCount > 0 {
		return errors.New("selected appointment time overlaps with an existing booking")
	}

	err = r.db.QueryRow(ctx, `
		INSERT INTO vet_appointments (
			pet_owner_id,
			vet_user_id,
			pet_id,
			reason,
			symptoms,
			owner_notes,
			appointment_datetime,
			duration_minutes,
			meeting_type,
			clinic_address,
			meeting_link,
			fee_amount,
			currency
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13
		)
		RETURNING id, appointment_number, status, created_at, updated_at
	`,
		appointment.PetOwnerID,
		appointment.VetUserID,
		appointment.PetID,
		appointment.Reason,
		appointment.Symptoms,
		appointment.OwnerNotes,
		appointment.AppointmentDatetime,
		appointment.DurationMinutes,
		appointment.MeetingType,
		appointment.ClinicAddress,
		appointment.MeetingLink,
		appointment.FeeAmount,
		appointment.Currency,
	).Scan(
		&appointment.ID,
		&appointment.AppointmentNumber,
		&appointment.Status,
		&appointment.CreatedAt,
		&appointment.UpdatedAt,
	)
	if err != nil {
		return err
	}

	appointment.PetName = &petName
	appointment.PetType = &petType
	return nil
}

// GetByID returns one appointment with joined display data.
func (r *VetAppointmentRepository) GetByID(ctx context.Context, appointmentID uuid.UUID) (*models.VetAppointment, error) {
	appointment := &models.VetAppointment{}
	var petName string
	var petType string

	err := r.db.QueryRow(ctx, `
		SELECT
			va.id,
			va.appointment_number,
			va.pet_owner_id,
			va.vet_user_id,
			va.pet_id,
			p.name,
			p.type,
			va.reason,
			va.symptoms,
			va.owner_notes,
			va.appointment_datetime,
			va.duration_minutes,
			va.meeting_type,
			va.clinic_address,
			va.meeting_link,
			va.fee_amount,
			va.currency,
			va.status,
			va.response_note,
			va.responded_at,
			va.cancelled_at,
			va.completed_at,
			va.created_at,
			va.updated_at,
			u_owner.display_name,
			u_owner.avatar_url,
			u_vet.display_name,
			u_vet.avatar_url
		FROM vet_appointments va
		JOIN pets p ON p.id = va.pet_id
		JOIN users u_owner ON u_owner.id = va.pet_owner_id
		JOIN users u_vet ON u_vet.id = va.vet_user_id
		WHERE va.id = $1
	`, appointmentID).Scan(
		&appointment.ID,
		&appointment.AppointmentNumber,
		&appointment.PetOwnerID,
		&appointment.VetUserID,
		&appointment.PetID,
		&petName,
		&petType,
		&appointment.Reason,
		&appointment.Symptoms,
		&appointment.OwnerNotes,
		&appointment.AppointmentDatetime,
		&appointment.DurationMinutes,
		&appointment.MeetingType,
		&appointment.ClinicAddress,
		&appointment.MeetingLink,
		&appointment.FeeAmount,
		&appointment.Currency,
		&appointment.Status,
		&appointment.ResponseNote,
		&appointment.RespondedAt,
		&appointment.CancelledAt,
		&appointment.CompletedAt,
		&appointment.CreatedAt,
		&appointment.UpdatedAt,
		&appointment.OwnerName,
		&appointment.OwnerAvatar,
		&appointment.VetName,
		&appointment.VetAvatar,
	)
	if err == pgx.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	appointment.PetName = &petName
	appointment.PetType = &petType
	return appointment, nil
}

// ListByUser returns appointments for either owner or vet role.
func (r *VetAppointmentRepository) ListByUser(ctx context.Context, userID uuid.UUID, role string, statusFilter string, page int, limit int) ([]models.VetAppointment, int, error) {
	filterField := "va.pet_owner_id"
	if role == "vet" {
		filterField = "va.vet_user_id"
	}

	if page <= 0 {
		page = 1
	}
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	offset := (page - 1) * limit

	whereClauses := []string{fmt.Sprintf("%s = $1", filterField)}
	args := []interface{}{userID}
	argNum := 2

	statuses := make([]string, 0)
	for _, status := range strings.Split(statusFilter, ",") {
		trimmed := strings.TrimSpace(status)
		if trimmed == "" {
			continue
		}
		statuses = append(statuses, trimmed)
	}

	switch len(statuses) {
	case 1:
		whereClauses = append(whereClauses, fmt.Sprintf("va.status = $%d", argNum))
		args = append(args, statuses[0])
		argNum++
	case 2, 3, 4, 5, 6:
		whereClauses = append(whereClauses, fmt.Sprintf("va.status = ANY($%d)", argNum))
		args = append(args, statuses)
		argNum++
	}

	whereClause := strings.Join(whereClauses, " AND ")

	var total int
	err := r.db.QueryRow(ctx, fmt.Sprintf(`
		SELECT COUNT(*)
		FROM vet_appointments va
		WHERE %s
	`, whereClause), args...).Scan(&total)
	if err != nil {
		return nil, 0, err
	}

	args = append(args, limit, offset)
	rows, err := r.db.Query(ctx, fmt.Sprintf(`
		SELECT
			va.id,
			va.appointment_number,
			va.pet_owner_id,
			va.vet_user_id,
			va.pet_id,
			p.name,
			p.type,
			va.reason,
			va.symptoms,
			va.owner_notes,
			va.appointment_datetime,
			va.duration_minutes,
			va.meeting_type,
			va.clinic_address,
			va.meeting_link,
			va.fee_amount,
			va.currency,
			va.status,
			va.response_note,
			va.responded_at,
			va.cancelled_at,
			va.completed_at,
			va.created_at,
			va.updated_at,
			u_owner.display_name,
			u_owner.avatar_url,
			u_vet.display_name,
			u_vet.avatar_url
		FROM vet_appointments va
		JOIN pets p ON p.id = va.pet_id
		JOIN users u_owner ON u_owner.id = va.pet_owner_id
		JOIN users u_vet ON u_vet.id = va.vet_user_id
		WHERE %s
		ORDER BY va.appointment_datetime DESC, va.created_at DESC
		LIMIT $%d OFFSET $%d
	`, whereClause, argNum, argNum+1), args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	appointments := make([]models.VetAppointment, 0)
	for rows.Next() {
		var appointment models.VetAppointment
		var petName string
		var petType string

		err = rows.Scan(
			&appointment.ID,
			&appointment.AppointmentNumber,
			&appointment.PetOwnerID,
			&appointment.VetUserID,
			&appointment.PetID,
			&petName,
			&petType,
			&appointment.Reason,
			&appointment.Symptoms,
			&appointment.OwnerNotes,
			&appointment.AppointmentDatetime,
			&appointment.DurationMinutes,
			&appointment.MeetingType,
			&appointment.ClinicAddress,
			&appointment.MeetingLink,
			&appointment.FeeAmount,
			&appointment.Currency,
			&appointment.Status,
			&appointment.ResponseNote,
			&appointment.RespondedAt,
			&appointment.CancelledAt,
			&appointment.CompletedAt,
			&appointment.CreatedAt,
			&appointment.UpdatedAt,
			&appointment.OwnerName,
			&appointment.OwnerAvatar,
			&appointment.VetName,
			&appointment.VetAvatar,
		)
		if err != nil {
			return nil, 0, err
		}

		appointment.PetName = &petName
		appointment.PetType = &petType
		appointments = append(appointments, appointment)
	}

	return appointments, total, nil
}

// Respond updates an appointment response from the vet (confirm/decline).
func (r *VetAppointmentRepository) Respond(ctx context.Context, appointmentID uuid.UUID, accept bool, responseNote *string, appointmentDatetime *time.Time, meetingLink *string) error {
	status := "declined"
	if accept {
		status = "confirmed"
	}

	_, err := r.db.Exec(ctx, `
		UPDATE vet_appointments
		SET
			status = $2,
			response_note = $3,
			appointment_datetime = CASE
				WHEN $4::timestamptz IS NULL THEN appointment_datetime
				ELSE $4
			END,
			meeting_link = CASE
				WHEN $5::text IS NULL THEN meeting_link
				ELSE $5
			END,
			responded_at = CURRENT_TIMESTAMP,
			updated_at = CURRENT_TIMESTAMP
		WHERE id = $1
	`, appointmentID, status, responseNote, appointmentDatetime, meetingLink)

	return err
}

// Cancel updates appointment status as cancelled by owner or vet.
func (r *VetAppointmentRepository) Cancel(ctx context.Context, appointmentID uuid.UUID, cancelledByVet bool, reason string) error {
	status := "cancelled_owner"
	if cancelledByVet {
		status = "cancelled_vet"
	}

	_, err := r.db.Exec(ctx, `
		UPDATE vet_appointments
		SET
			status = $2,
			response_note = $3,
			cancelled_at = CURRENT_TIMESTAMP,
			updated_at = CURRENT_TIMESTAMP
		WHERE id = $1
	`, appointmentID, status, reason)

	return err
}

// Complete marks a confirmed appointment as completed.
func (r *VetAppointmentRepository) Complete(ctx context.Context, appointmentID uuid.UUID, responseNote *string) error {
	_, err := r.db.Exec(ctx, `
		UPDATE vet_appointments
		SET
			status = 'completed',
			response_note = CASE
				WHEN $2::text IS NULL THEN response_note
				ELSE $2
			END,
			completed_at = CURRENT_TIMESTAMP,
			updated_at = CURRENT_TIMESTAMP
		WHERE id = $1
	`, appointmentID, responseNote)
	return err
}
