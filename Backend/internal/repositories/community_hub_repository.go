package repositories

import (
	"context"
	"fmt"
	"strings"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"pawpal-backend/internal/models"
)

type CommunityHubRepository struct {
	db *pgxpool.Pool
}

func NewCommunityHubRepository(db *pgxpool.Pool) *CommunityHubRepository {
	return &CommunityHubRepository{db: db}
}

// ─── Lost & Found ────────────────────────────────────────────────

func (r *CommunityHubRepository) CreateLostFound(ctx context.Context, lf *models.LostFoundPost) error {
	query := `INSERT INTO lost_found_posts
		(user_id, type, pet_name, pet_type, breed, color, description, image_urls,
		 last_seen_location, last_seen_lat, last_seen_lng, urgency, contact_phone, contact_email,
		 status, user_name, user_avatar)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17)
		RETURNING id, created_at, updated_at`

	return r.db.QueryRow(ctx, query,
		lf.UserID, lf.Type, lf.PetName, lf.PetType, lf.Breed, lf.Color,
		lf.Description, lf.ImageURLs,
		lf.LastSeenLocation, lf.LastSeenLat, lf.LastSeenLng,
		lf.Urgency, lf.ContactPhone, lf.ContactEmail,
		lf.Status, lf.UserName, lf.UserAvatar,
	).Scan(&lf.ID, &lf.CreatedAt, &lf.UpdatedAt)
}

func (r *CommunityHubRepository) GetLostFoundPosts(ctx context.Context, postType string, status string, limit, offset int) ([]models.LostFoundPost, int, error) {
	conditions := []string{}
	args := []interface{}{}
	argIdx := 1

	if postType != "" {
		conditions = append(conditions, fmt.Sprintf("type = $%d", argIdx))
		args = append(args, postType)
		argIdx++
	}
	if status != "" {
		conditions = append(conditions, fmt.Sprintf("status = $%d", argIdx))
		args = append(args, status)
		argIdx++
	}

	where := ""
	if len(conditions) > 0 {
		where = "WHERE " + strings.Join(conditions, " AND ")
	}

	countQuery := fmt.Sprintf("SELECT COUNT(*) FROM lost_found_posts %s", where)
	var total int
	if err := r.db.QueryRow(ctx, countQuery, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := fmt.Sprintf(`SELECT id, user_id, type, pet_name, pet_type, breed, color,
		description, image_urls, last_seen_location, last_seen_lat, last_seen_lng,
		urgency, contact_phone, contact_email, status, user_name, user_avatar,
		created_at, updated_at
		FROM lost_found_posts %s
		ORDER BY
			CASE urgency WHEN 'critical' THEN 1 WHEN 'high' THEN 2 WHEN 'medium' THEN 3 ELSE 4 END,
			created_at DESC
		LIMIT $%d OFFSET $%d`, where, argIdx, argIdx+1)

	args = append(args, limit, offset)
	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var posts []models.LostFoundPost
	for rows.Next() {
		var p models.LostFoundPost
		if err := rows.Scan(&p.ID, &p.UserID, &p.Type, &p.PetName, &p.PetType,
			&p.Breed, &p.Color, &p.Description, &p.ImageURLs,
			&p.LastSeenLocation, &p.LastSeenLat, &p.LastSeenLng,
			&p.Urgency, &p.ContactPhone, &p.ContactEmail,
			&p.Status, &p.UserName, &p.UserAvatar,
			&p.CreatedAt, &p.UpdatedAt); err != nil {
			return nil, 0, err
		}
		posts = append(posts, p)
	}
	return posts, total, nil
}

func (r *CommunityHubRepository) GetLostFoundByID(ctx context.Context, id uuid.UUID) (*models.LostFoundPost, error) {
	query := `SELECT id, user_id, type, pet_name, pet_type, breed, color,
		description, image_urls, last_seen_location, last_seen_lat, last_seen_lng,
		urgency, contact_phone, contact_email, status, user_name, user_avatar,
		created_at, updated_at
		FROM lost_found_posts WHERE id = $1`

	var p models.LostFoundPost
	err := r.db.QueryRow(ctx, query, id).Scan(&p.ID, &p.UserID, &p.Type, &p.PetName, &p.PetType,
		&p.Breed, &p.Color, &p.Description, &p.ImageURLs,
		&p.LastSeenLocation, &p.LastSeenLat, &p.LastSeenLng,
		&p.Urgency, &p.ContactPhone, &p.ContactEmail,
		&p.Status, &p.UserName, &p.UserAvatar,
		&p.CreatedAt, &p.UpdatedAt)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return &p, nil
}

func (r *CommunityHubRepository) UpdateLostFound(ctx context.Context, id, userID uuid.UUID, req *models.UpdateLostFoundRequest) error {
	sets := []string{}
	args := []interface{}{}
	argIdx := 1

	if req.Description != nil {
		sets = append(sets, fmt.Sprintf("description = $%d", argIdx))
		args = append(args, *req.Description)
		argIdx++
	}
	if req.LastSeenLocation != nil {
		sets = append(sets, fmt.Sprintf("last_seen_location = $%d", argIdx))
		args = append(args, *req.LastSeenLocation)
		argIdx++
	}
	if req.Urgency != nil {
		sets = append(sets, fmt.Sprintf("urgency = $%d", argIdx))
		args = append(args, *req.Urgency)
		argIdx++
	}
	if req.ContactPhone != nil {
		sets = append(sets, fmt.Sprintf("contact_phone = $%d", argIdx))
		args = append(args, *req.ContactPhone)
		argIdx++
	}
	if req.ContactEmail != nil {
		sets = append(sets, fmt.Sprintf("contact_email = $%d", argIdx))
		args = append(args, *req.ContactEmail)
		argIdx++
	}
	if req.Status != nil {
		sets = append(sets, fmt.Sprintf("status = $%d", argIdx))
		args = append(args, *req.Status)
		argIdx++
	}

	if len(sets) == 0 {
		return nil
	}

	sets = append(sets, "updated_at = NOW()")
	query := fmt.Sprintf("UPDATE lost_found_posts SET %s WHERE id = $%d AND user_id = $%d",
		strings.Join(sets, ", "), argIdx, argIdx+1)
	args = append(args, id, userID)

	tag, err := r.db.Exec(ctx, query, args...)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return fmt.Errorf("post not found or you don't own it")
	}
	return nil
}

func (r *CommunityHubRepository) DeleteLostFound(ctx context.Context, id, userID uuid.UUID) error {
	tag, err := r.db.Exec(ctx, "DELETE FROM lost_found_posts WHERE id = $1 AND user_id = $2", id, userID)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return fmt.Errorf("post not found or you don't own it")
	}
	return nil
}

// ─── Adoption Listings ───────────────────────────────────────────

func (r *CommunityHubRepository) CreateAdoption(ctx context.Context, a *models.AdoptionListing) error {
	if a.PetID == nil {
		return fmt.Errorf("pet id is required")
	}

	var ownershipOK bool
	ownershipQuery := `SELECT EXISTS(SELECT 1 FROM pets WHERE id = $1 AND owner_id = $2)`
	if err := r.db.QueryRow(ctx, ownershipQuery, *a.PetID, a.UserID).Scan(&ownershipOK); err != nil {
		return err
	}
	if !ownershipOK {
		return fmt.Errorf("selected pet not found for this user")
	}

	var activeListingExists bool
	activeQuery := `SELECT EXISTS(
		SELECT 1
		FROM adoption_listings
		WHERE pet_id = $1
			AND status IN ('available', 'pending')
	)`
	if err := r.db.QueryRow(ctx, activeQuery, *a.PetID).Scan(&activeListingExists); err != nil {
		return err
	}
	if activeListingExists {
		return fmt.Errorf("this pet is already listed for adoption")
	}

	// Legacy safeguard: older listings may have NULL pet_id.
	// Block duplicates by owner + pet identity while those rows still exist.
	var legacyDuplicateExists bool
	legacyQuery := `SELECT EXISTS(
		SELECT 1
		FROM adoption_listings
		WHERE user_id = $1
			AND pet_id IS NULL
			AND LOWER(pet_name) = LOWER($2)
			AND LOWER(pet_type) = LOWER($3)
			AND status IN ('available', 'pending')
	)`
	if err := r.db.QueryRow(ctx, legacyQuery, a.UserID, a.PetName, a.PetType).Scan(&legacyDuplicateExists); err != nil {
		return err
	}
	if legacyDuplicateExists {
		return fmt.Errorf("this pet is already listed for adoption")
	}

	query := `INSERT INTO adoption_listings
		(user_id, pet_id, pet_name, pet_type, breed, age, gender, size, color,
		 description, medical_info, is_vaccinated, is_neutered, is_trained,
		 good_with_kids, good_with_pets, image_urls, location,
		 contact_phone, contact_email, adoption_fee, status, user_name, user_avatar)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24)
		RETURNING id, created_at, updated_at`

	return r.db.QueryRow(ctx, query,
		a.UserID, *a.PetID, a.PetName, a.PetType, a.Breed, a.Age, a.Gender, a.Size, a.Color,
		a.Description, a.MedicalInfo, a.IsVaccinated, a.IsNeutered, a.IsTrained,
		a.GoodWithKids, a.GoodWithPets, a.ImageURLs, a.Location,
		a.ContactPhone, a.ContactEmail, a.AdoptionFee, a.Status, a.UserName, a.UserAvatar,
	).Scan(&a.ID, &a.CreatedAt, &a.UpdatedAt)
}

func (r *CommunityHubRepository) GetAdoptionListings(ctx context.Context, petType, status string, limit, offset int) ([]models.AdoptionListing, int, error) {
	conditions := []string{}
	args := []interface{}{}
	argIdx := 1

	if petType != "" {
		conditions = append(conditions, fmt.Sprintf("pet_type = $%d", argIdx))
		args = append(args, petType)
		argIdx++
	}
	if status != "" {
		conditions = append(conditions, fmt.Sprintf("status = $%d", argIdx))
		args = append(args, status)
		argIdx++
	}

	where := ""
	if len(conditions) > 0 {
		where = "WHERE " + strings.Join(conditions, " AND ")
	}

	var total int
	countQuery := fmt.Sprintf("SELECT COUNT(*) FROM adoption_listings %s", where)
	if err := r.db.QueryRow(ctx, countQuery, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := fmt.Sprintf(`SELECT a.id, a.user_id, a.pet_id, a.pet_name, a.pet_type, a.breed,
		COALESCE((
			SELECT p.is_verified
			FROM pets p
			WHERE a.pet_id IS NOT NULL AND p.id = a.pet_id
			ORDER BY p.updated_at DESC
			LIMIT 1
		), false) AS is_breed_verified,
		(
			SELECT p.verified_breed
			FROM pets p
			WHERE a.pet_id IS NOT NULL AND p.id = a.pet_id
			ORDER BY p.updated_at DESC
			LIMIT 1
		) AS verified_breed,
		age, gender, size, color,
		description, medical_info, is_vaccinated, is_neutered, is_trained,
		good_with_kids, good_with_pets, image_urls, location,
		contact_phone, contact_email, adoption_fee, status, user_name, user_avatar,
		created_at, updated_at
		FROM adoption_listings %s ORDER BY created_at DESC LIMIT $%d OFFSET $%d`,
		where, argIdx, argIdx+1)

	args = append(args, limit, offset)
	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var listings []models.AdoptionListing
	for rows.Next() {
		var a models.AdoptionListing
		if err := rows.Scan(&a.ID, &a.UserID, &a.PetID, &a.PetName, &a.PetType, &a.Breed,
			&a.IsBreedVerified, &a.VerifiedBreed,
			&a.Age, &a.Gender, &a.Size, &a.Color,
			&a.Description, &a.MedicalInfo, &a.IsVaccinated, &a.IsNeutered, &a.IsTrained,
			&a.GoodWithKids, &a.GoodWithPets, &a.ImageURLs, &a.Location,
			&a.ContactPhone, &a.ContactEmail, &a.AdoptionFee, &a.Status,
			&a.UserName, &a.UserAvatar,
			&a.CreatedAt, &a.UpdatedAt); err != nil {
			return nil, 0, err
		}
		listings = append(listings, a)
	}
	return listings, total, nil
}

func (r *CommunityHubRepository) GetAdoptionByID(ctx context.Context, id uuid.UUID) (*models.AdoptionListing, error) {
	query := `SELECT a.id, a.user_id, a.pet_id, a.pet_name, a.pet_type, a.breed,
		COALESCE((
			SELECT p.is_verified
			FROM pets p
			WHERE a.pet_id IS NOT NULL AND p.id = a.pet_id
			ORDER BY p.updated_at DESC
			LIMIT 1
		), false) AS is_breed_verified,
		(
			SELECT p.verified_breed
			FROM pets p
			WHERE a.pet_id IS NOT NULL AND p.id = a.pet_id
			ORDER BY p.updated_at DESC
			LIMIT 1
		) AS verified_breed,
		age, gender, size, color,
		description, medical_info, is_vaccinated, is_neutered, is_trained,
		good_with_kids, good_with_pets, image_urls, location,
		contact_phone, contact_email, adoption_fee, status, user_name, user_avatar,
		created_at, updated_at
		FROM adoption_listings a WHERE a.id = $1`

	var a models.AdoptionListing
	err := r.db.QueryRow(ctx, query, id).Scan(&a.ID, &a.UserID, &a.PetID, &a.PetName, &a.PetType, &a.Breed,
		&a.IsBreedVerified, &a.VerifiedBreed,
		&a.Age, &a.Gender, &a.Size, &a.Color,
		&a.Description, &a.MedicalInfo, &a.IsVaccinated, &a.IsNeutered, &a.IsTrained,
		&a.GoodWithKids, &a.GoodWithPets, &a.ImageURLs, &a.Location,
		&a.ContactPhone, &a.ContactEmail, &a.AdoptionFee, &a.Status,
		&a.UserName, &a.UserAvatar,
		&a.CreatedAt, &a.UpdatedAt)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return &a, nil
}

func (r *CommunityHubRepository) UpdateAdoption(ctx context.Context, id, userID uuid.UUID, req *models.UpdateAdoptionRequest) error {
	sets := []string{}
	args := []interface{}{}
	argIdx := 1

	if req.Description != nil {
		sets = append(sets, fmt.Sprintf("description = $%d", argIdx))
		args = append(args, *req.Description)
		argIdx++
	}
	if req.MedicalInfo != nil {
		sets = append(sets, fmt.Sprintf("medical_info = $%d", argIdx))
		args = append(args, *req.MedicalInfo)
		argIdx++
	}
	if req.IsVaccinated != nil {
		sets = append(sets, fmt.Sprintf("is_vaccinated = $%d", argIdx))
		args = append(args, *req.IsVaccinated)
		argIdx++
	}
	if req.IsNeutered != nil {
		sets = append(sets, fmt.Sprintf("is_neutered = $%d", argIdx))
		args = append(args, *req.IsNeutered)
		argIdx++
	}
	if req.IsTrained != nil {
		sets = append(sets, fmt.Sprintf("is_trained = $%d", argIdx))
		args = append(args, *req.IsTrained)
		argIdx++
	}
	if req.AdoptionFee != nil {
		sets = append(sets, fmt.Sprintf("adoption_fee = $%d", argIdx))
		args = append(args, *req.AdoptionFee)
		argIdx++
	}
	if req.Status != nil {
		sets = append(sets, fmt.Sprintf("status = $%d", argIdx))
		args = append(args, *req.Status)
		argIdx++
	}
	if req.ContactPhone != nil {
		sets = append(sets, fmt.Sprintf("contact_phone = $%d", argIdx))
		args = append(args, *req.ContactPhone)
		argIdx++
	}

	if len(sets) == 0 {
		return nil
	}

	sets = append(sets, "updated_at = NOW()")
	query := fmt.Sprintf("UPDATE adoption_listings SET %s WHERE id = $%d AND user_id = $%d",
		strings.Join(sets, ", "), argIdx, argIdx+1)
	args = append(args, id, userID)

	tag, err := r.db.Exec(ctx, query, args...)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return fmt.Errorf("listing not found or you don't own it")
	}
	return nil
}

func (r *CommunityHubRepository) DeleteAdoption(ctx context.Context, id, userID uuid.UUID) error {
	tag, err := r.db.Exec(ctx, "DELETE FROM adoption_listings WHERE id = $1 AND user_id = $2", id, userID)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return fmt.Errorf("listing not found or you don't own it")
	}
	return nil
}

// ─── Events ──────────────────────────────────────────────────────

func (r *CommunityHubRepository) CreateEvent(ctx context.Context, e *models.Event) error {
	query := `INSERT INTO events
		(organizer_id, title, description, event_type, image_url, location,
		 location_lat, location_lng, start_date, end_date, max_attendees,
		 is_pet_friendly, pet_types_allowed, status, organizer_name, organizer_avatar)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16)
		RETURNING id, rsvp_count, created_at, updated_at`

	return r.db.QueryRow(ctx, query,
		e.OrganizerID, e.Title, e.Description, e.EventType, e.ImageURL,
		e.Location, e.LocationLat, e.LocationLng,
		e.StartDate, e.EndDate, e.MaxAttendees,
		e.IsPetFriendly, e.PetTypesAllowed, e.Status,
		e.OrganizerName, e.OrganizerAvatar,
	).Scan(&e.ID, &e.RSVPCount, &e.CreatedAt, &e.UpdatedAt)
}

func (r *CommunityHubRepository) GetEvents(ctx context.Context, eventType, status string, limit, offset int) ([]models.Event, int, error) {
	conditions := []string{}
	args := []interface{}{}
	argIdx := 1

	if eventType != "" {
		conditions = append(conditions, fmt.Sprintf("event_type = $%d", argIdx))
		args = append(args, eventType)
		argIdx++
	}
	if status != "" {
		conditions = append(conditions, fmt.Sprintf("status = $%d", argIdx))
		args = append(args, status)
		argIdx++
	}

	where := ""
	if len(conditions) > 0 {
		where = "WHERE " + strings.Join(conditions, " AND ")
	}

	var total int
	countQuery := fmt.Sprintf("SELECT COUNT(*) FROM events %s", where)
	if err := r.db.QueryRow(ctx, countQuery, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := fmt.Sprintf(`SELECT id, organizer_id, title, description, event_type,
		image_url, location, location_lat, location_lng,
		start_date, end_date, max_attendees, is_pet_friendly, pet_types_allowed,
		status, organizer_name, organizer_avatar, rsvp_count, created_at, updated_at
		FROM events %s ORDER BY start_date ASC LIMIT $%d OFFSET $%d`,
		where, argIdx, argIdx+1)

	args = append(args, limit, offset)
	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var events []models.Event
	for rows.Next() {
		var e models.Event
		if err := rows.Scan(&e.ID, &e.OrganizerID, &e.Title, &e.Description, &e.EventType,
			&e.ImageURL, &e.Location, &e.LocationLat, &e.LocationLng,
			&e.StartDate, &e.EndDate, &e.MaxAttendees, &e.IsPetFriendly, &e.PetTypesAllowed,
			&e.Status, &e.OrganizerName, &e.OrganizerAvatar, &e.RSVPCount,
			&e.CreatedAt, &e.UpdatedAt); err != nil {
			return nil, 0, err
		}
		events = append(events, e)
	}
	return events, total, nil
}

func (r *CommunityHubRepository) GetEventByID(ctx context.Context, id uuid.UUID) (*models.Event, error) {
	query := `SELECT id, organizer_id, title, description, event_type,
		image_url, location, location_lat, location_lng,
		start_date, end_date, max_attendees, is_pet_friendly, pet_types_allowed,
		status, organizer_name, organizer_avatar, rsvp_count, created_at, updated_at
		FROM events WHERE id = $1`

	var e models.Event
	err := r.db.QueryRow(ctx, query, id).Scan(&e.ID, &e.OrganizerID, &e.Title, &e.Description, &e.EventType,
		&e.ImageURL, &e.Location, &e.LocationLat, &e.LocationLng,
		&e.StartDate, &e.EndDate, &e.MaxAttendees, &e.IsPetFriendly, &e.PetTypesAllowed,
		&e.Status, &e.OrganizerName, &e.OrganizerAvatar, &e.RSVPCount,
		&e.CreatedAt, &e.UpdatedAt)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return &e, nil
}

func (r *CommunityHubRepository) UpdateEvent(ctx context.Context, id, organizerID uuid.UUID, req *models.UpdateEventRequest) error {
	sets := []string{}
	args := []interface{}{}
	argIdx := 1

	if req.Title != nil {
		sets = append(sets, fmt.Sprintf("title = $%d", argIdx))
		args = append(args, *req.Title)
		argIdx++
	}
	if req.Description != nil {
		sets = append(sets, fmt.Sprintf("description = $%d", argIdx))
		args = append(args, *req.Description)
		argIdx++
	}
	if req.Location != nil {
		sets = append(sets, fmt.Sprintf("location = $%d", argIdx))
		args = append(args, *req.Location)
		argIdx++
	}
	if req.Status != nil {
		sets = append(sets, fmt.Sprintf("status = $%d", argIdx))
		args = append(args, *req.Status)
		argIdx++
	}

	if len(sets) == 0 {
		return nil
	}

	sets = append(sets, "updated_at = NOW()")
	query := fmt.Sprintf("UPDATE events SET %s WHERE id = $%d AND organizer_id = $%d",
		strings.Join(sets, ", "), argIdx, argIdx+1)
	args = append(args, id, organizerID)

	tag, err := r.db.Exec(ctx, query, args...)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return fmt.Errorf("event not found or you are not the organizer")
	}
	return nil
}

func (r *CommunityHubRepository) DeleteEvent(ctx context.Context, id, organizerID uuid.UUID) error {
	tag, err := r.db.Exec(ctx,
		"DELETE FROM events WHERE id = $1 AND organizer_id = $2", id, organizerID)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return fmt.Errorf("event not found or you are not the organizer")
	}
	return nil
}

// ─── RSVPs ───────────────────────────────────────────────────────

func (r *CommunityHubRepository) RSVPEvent(ctx context.Context, rsvp *models.EventRSVP, maxAttendees *int) error {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	// Check capacity if going
	if rsvp.Status == "going" && maxAttendees != nil {
		var goingCount int
		err := tx.QueryRow(ctx,
			"SELECT COUNT(*) FROM event_rsvps WHERE event_id = $1 AND status = 'going'",
			rsvp.EventID).Scan(&goingCount)
		if err != nil {
			return err
		}
		if goingCount >= *maxAttendees {
			rsvp.Status = "waitlisted"
		}
	}

	// Upsert RSVP
	query := `INSERT INTO event_rsvps (event_id, user_id, status, user_name, user_avatar)
		VALUES ($1, $2, $3, $4, $5)
		ON CONFLICT (event_id, user_id) DO UPDATE SET status = $3
		RETURNING id, created_at`
	err = tx.QueryRow(ctx, query,
		rsvp.EventID, rsvp.UserID, rsvp.Status, rsvp.UserName, rsvp.UserAvatar,
	).Scan(&rsvp.ID, &rsvp.CreatedAt)
	if err != nil {
		return err
	}

	// Update rsvp_count
	_, err = tx.Exec(ctx,
		"UPDATE events SET rsvp_count = (SELECT COUNT(*) FROM event_rsvps WHERE event_id = $1 AND status IN ('going','interested')) WHERE id = $1",
		rsvp.EventID)
	if err != nil {
		return err
	}

	return tx.Commit(ctx)
}

func (r *CommunityHubRepository) CancelRSVP(ctx context.Context, eventID, userID uuid.UUID) error {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	tag, err := tx.Exec(ctx,
		"DELETE FROM event_rsvps WHERE event_id = $1 AND user_id = $2", eventID, userID)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return fmt.Errorf("RSVP not found")
	}

	_, err = tx.Exec(ctx,
		"UPDATE events SET rsvp_count = (SELECT COUNT(*) FROM event_rsvps WHERE event_id = $1 AND status IN ('going','interested')) WHERE id = $1",
		eventID)
	if err != nil {
		return err
	}

	return tx.Commit(ctx)
}

func (r *CommunityHubRepository) GetEventRSVPs(ctx context.Context, eventID uuid.UUID) ([]models.EventRSVP, error) {
	rows, err := r.db.Query(ctx,
		`SELECT id, event_id, user_id, status, user_name, user_avatar, created_at
		FROM event_rsvps WHERE event_id = $1 ORDER BY created_at`, eventID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var rsvps []models.EventRSVP
	for rows.Next() {
		var r models.EventRSVP
		if err := rows.Scan(&r.ID, &r.EventID, &r.UserID, &r.Status,
			&r.UserName, &r.UserAvatar, &r.CreatedAt); err != nil {
			return nil, err
		}
		rsvps = append(rsvps, r)
	}
	return rsvps, nil
}

func (r *CommunityHubRepository) GetUserRSVP(ctx context.Context, eventID, userID uuid.UUID) (*models.EventRSVP, error) {
	query := `SELECT id, event_id, user_id, status, user_name, user_avatar, created_at
		FROM event_rsvps WHERE event_id = $1 AND user_id = $2`
	var rsvp models.EventRSVP
	err := r.db.QueryRow(ctx, query, eventID, userID).Scan(
		&rsvp.ID, &rsvp.EventID, &rsvp.UserID, &rsvp.Status,
		&rsvp.UserName, &rsvp.UserAvatar, &rsvp.CreatedAt)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return &rsvp, nil
}

func (r *CommunityHubRepository) GetMyLostFoundPosts(ctx context.Context, userID uuid.UUID) ([]models.LostFoundPost, error) {
	query := `SELECT id, user_id, type, pet_name, pet_type, breed, color,
		description, image_urls, last_seen_location, last_seen_lat, last_seen_lng,
		urgency, contact_phone, contact_email, status, user_name, user_avatar,
		created_at, updated_at
		FROM lost_found_posts WHERE user_id = $1 ORDER BY created_at DESC`

	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var posts []models.LostFoundPost
	for rows.Next() {
		var p models.LostFoundPost
		if err := rows.Scan(&p.ID, &p.UserID, &p.Type, &p.PetName, &p.PetType,
			&p.Breed, &p.Color, &p.Description, &p.ImageURLs,
			&p.LastSeenLocation, &p.LastSeenLat, &p.LastSeenLng,
			&p.Urgency, &p.ContactPhone, &p.ContactEmail,
			&p.Status, &p.UserName, &p.UserAvatar,
			&p.CreatedAt, &p.UpdatedAt); err != nil {
			return nil, err
		}
		posts = append(posts, p)
	}
	return posts, nil
}

func (r *CommunityHubRepository) GetMyAdoptionListings(ctx context.Context, userID uuid.UUID) ([]models.AdoptionListing, error) {
	query := `SELECT a.id, a.user_id, a.pet_id, a.pet_name, a.pet_type, a.breed,
		COALESCE((
			SELECT p.is_verified
			FROM pets p
			WHERE a.pet_id IS NOT NULL AND p.id = a.pet_id
			ORDER BY p.updated_at DESC
			LIMIT 1
		), false) AS is_breed_verified,
		(
			SELECT p.verified_breed
			FROM pets p
			WHERE a.pet_id IS NOT NULL AND p.id = a.pet_id
			ORDER BY p.updated_at DESC
			LIMIT 1
		) AS verified_breed,
		age, gender, size, color,
		description, medical_info, is_vaccinated, is_neutered, is_trained,
		good_with_kids, good_with_pets, image_urls, location,
		contact_phone, contact_email, adoption_fee, status, user_name, user_avatar,
		created_at, updated_at
		FROM adoption_listings a WHERE a.user_id = $1 ORDER BY a.created_at DESC`

	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var listings []models.AdoptionListing
	for rows.Next() {
		var a models.AdoptionListing
		if err := rows.Scan(&a.ID, &a.UserID, &a.PetID, &a.PetName, &a.PetType, &a.Breed,
			&a.IsBreedVerified, &a.VerifiedBreed,
			&a.Age, &a.Gender, &a.Size, &a.Color,
			&a.Description, &a.MedicalInfo, &a.IsVaccinated, &a.IsNeutered, &a.IsTrained,
			&a.GoodWithKids, &a.GoodWithPets, &a.ImageURLs, &a.Location,
			&a.ContactPhone, &a.ContactEmail, &a.AdoptionFee, &a.Status,
			&a.UserName, &a.UserAvatar,
			&a.CreatedAt, &a.UpdatedAt); err != nil {
			return nil, err
		}
		listings = append(listings, a)
	}
	return listings, nil
}

func (r *CommunityHubRepository) GetMyEvents(ctx context.Context, userID uuid.UUID) ([]models.Event, error) {
	query := `SELECT id, organizer_id, title, description, event_type,
		image_url, location, location_lat, location_lng,
		start_date, end_date, max_attendees, is_pet_friendly, pet_types_allowed,
		status, organizer_name, organizer_avatar, rsvp_count, created_at, updated_at
		FROM events WHERE organizer_id = $1 ORDER BY start_date DESC`

	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var events []models.Event
	for rows.Next() {
		var e models.Event
		if err := rows.Scan(&e.ID, &e.OrganizerID, &e.Title, &e.Description, &e.EventType,
			&e.ImageURL, &e.Location, &e.LocationLat, &e.LocationLng,
			&e.StartDate, &e.EndDate, &e.MaxAttendees, &e.IsPetFriendly, &e.PetTypesAllowed,
			&e.Status, &e.OrganizerName, &e.OrganizerAvatar, &e.RSVPCount,
			&e.CreatedAt, &e.UpdatedAt); err != nil {
			return nil, err
		}
		events = append(events, e)
	}
	return events, nil
}


