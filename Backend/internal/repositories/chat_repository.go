package repositories

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"

	"pawpal-backend/internal/models"
)

// ChatRepository handles chat database operations
type ChatRepository struct {
	db *pgxpool.Pool
}

// NewChatRepository creates a new ChatRepository
func NewChatRepository(db *pgxpool.Pool) *ChatRepository {
	return &ChatRepository{db: db}
}

// CreateChat creates a new chat between pet owner and vet
func (r *ChatRepository) CreateChat(ctx context.Context, chat *models.Chat) error {
	// Check if chat already exists between these users
	existingID, err := r.GetChatBetweenUsers(ctx, chat.PetOwnerID, chat.VetID)
	if err == nil && existingID != uuid.Nil {
		// Chat already exists, return the existing ID
		chat.ID = existingID
		return nil
	}

	query := `
		INSERT INTO chats (
			id, pet_owner_id, vet_id, pet_id, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id, created_at, updated_at`

	chat.ID = uuid.New()
	chat.CreatedAt = time.Now()
	chat.UpdatedAt = time.Now()

	return r.db.QueryRow(ctx, query,
		chat.ID, chat.PetOwnerID, chat.VetID, chat.PetID, chat.CreatedAt, chat.UpdatedAt,
	).Scan(&chat.ID, &chat.CreatedAt, &chat.UpdatedAt)
}

// GetChatBetweenUsers checks if a chat exists between two users
func (r *ChatRepository) GetChatBetweenUsers(ctx context.Context, petOwnerID, vetID uuid.UUID) (uuid.UUID, error) {
	var chatID uuid.UUID
	query := `SELECT id FROM chats WHERE pet_owner_id = $1 AND vet_id = $2`
	err := r.db.QueryRow(ctx, query, petOwnerID, vetID).Scan(&chatID)
	return chatID, err
}

// GetChatByID retrieves a chat by ID with other user info
func (r *ChatRepository) GetChatByID(ctx context.Context, chatID uuid.UUID, chat *models.Chat) error {
	query := `
		SELECT c.id, c.pet_owner_id, c.vet_id, c.pet_id, c.last_message, c.last_message_at,
			c.unread_count_owner, c.unread_count_vet, c.created_at, c.updated_at,
			u_vet.display_name as vet_name,
			u_owner.display_name as owner_name,
			COALESCE(u_vet.avatar_url, vp.profile_photo_url) as vet_photo,
			u_owner.avatar_url as owner_photo
		FROM chats c
		LEFT JOIN users u_owner ON c.pet_owner_id = u_owner.id
		LEFT JOIN users u_vet ON c.vet_id = u_vet.id
		LEFT JOIN vet_profiles vp ON c.vet_id = vp.user_id
		WHERE c.id = $1`

	var vetName, ownerName, vetPhoto, ownerPhoto *string
	err := r.db.QueryRow(ctx, query, chatID).Scan(
		&chat.ID, &chat.PetOwnerID, &chat.VetID, &chat.PetID, &chat.LastMessage,
		&chat.LastMessageAt, &chat.UnreadCountOwner, &chat.UnreadCountVet,
		&chat.CreatedAt, &chat.UpdatedAt, &vetName, &ownerName, &vetPhoto, &ownerPhoto,
	)

	if err != nil {
		return err
	}

	// Determine other user based on context - default to showing vet info
	// (since most calls are from pet owners viewing vet)
	if vetName != nil {
		chat.OtherUserName = *vetName
	}
	if vetPhoto != nil {
		chat.OtherUserPhoto = *vetPhoto
	}

	return nil
}

// GetUserChats retrieves all chats for a user
func (r *ChatRepository) GetUserChats(ctx context.Context, userID uuid.UUID, isVet bool) ([]models.Chat, error) {
	var query string
	if isVet {
		query = `
			SELECT c.id, c.pet_owner_id, c.vet_id, c.pet_id, c.last_message, c.last_message_at,
				c.unread_count_owner, c.unread_count_vet, c.created_at, c.updated_at,
				u.display_name as pet_owner_name, u.avatar_url as pet_owner_photo,
				p.name as pet_name
			FROM chats c
			LEFT JOIN users u ON c.pet_owner_id = u.id
			LEFT JOIN pets p ON c.pet_id = p.id
			WHERE c.vet_id = $1
			ORDER BY c.last_message_at DESC NULLS LAST, c.created_at DESC`
	} else {
		query = `
			SELECT c.id, c.pet_owner_id, c.vet_id, c.pet_id, c.last_message, c.last_message_at,
				c.unread_count_owner, c.unread_count_vet, c.created_at, c.updated_at,
				vp.full_name as vet_name, COALESCE(u.avatar_url, vp.profile_photo_url) as vet_photo
			FROM chats c
			LEFT JOIN vet_profiles vp ON c.vet_id = vp.user_id
			LEFT JOIN users u ON c.vet_id = u.id
			WHERE c.pet_owner_id = $1
			ORDER BY c.last_message_at DESC NULLS LAST, c.created_at DESC`
	}

	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	chats := []models.Chat{}
	for rows.Next() {
		var chat models.Chat
		var otherUserName, otherUserPhoto, petName *string

		if isVet {
			err = rows.Scan(
				&chat.ID, &chat.PetOwnerID, &chat.VetID, &chat.PetID, &chat.LastMessage,
				&chat.LastMessageAt, &chat.UnreadCountOwner, &chat.UnreadCountVet,
				&chat.CreatedAt, &chat.UpdatedAt, &otherUserName, &otherUserPhoto, &petName,
			)
		} else {
			err = rows.Scan(
				&chat.ID, &chat.PetOwnerID, &chat.VetID, &chat.PetID, &chat.LastMessage,
				&chat.LastMessageAt, &chat.UnreadCountOwner, &chat.UnreadCountVet,
				&chat.CreatedAt, &chat.UpdatedAt, &otherUserName, &otherUserPhoto,
			)
		}

		if err != nil {
			continue
		}

		// Add metadata for display
		if otherUserName != nil {
			chat.OtherUserName = *otherUserName
		}
		if otherUserPhoto != nil {
			chat.OtherUserPhoto = *otherUserPhoto
		}
		if petName != nil {
			chat.PetName = *petName
		}

		chats = append(chats, chat)
	}

	return chats, nil
}

// MarkChatAsRead marks all messages in a chat as read for a user
func (r *ChatRepository) MarkChatAsRead(ctx context.Context, chatID uuid.UUID, isVet bool) error {
	var query string
	if isVet {
		query = `UPDATE chats SET unread_count_vet = 0 WHERE id = $1`
	} else {
		query = `UPDATE chats SET unread_count_owner = 0 WHERE id = $1`
	}

	_, err := r.db.Exec(ctx, query, chatID)
	return err
}

// DeleteChat deletes a chat
func (r *ChatRepository) DeleteChat(ctx context.Context, chatID uuid.UUID) error {
	query := `DELETE FROM chats WHERE id = $1`
	_, err := r.db.Exec(ctx, query, chatID)
	return err
}

// CheckUserIsInChat verifies if a user is part of a chat
func (r *ChatRepository) CheckUserIsInChat(ctx context.Context, chatID, userID uuid.UUID) (bool, error) {
	query := `SELECT EXISTS(SELECT 1 FROM chats WHERE id = $1 AND (pet_owner_id = $2 OR vet_id = $2))`
	var exists bool
	err := r.db.QueryRow(ctx, query, chatID, userID).Scan(&exists)
	return exists, err
}
