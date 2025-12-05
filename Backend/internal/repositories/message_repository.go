package repositories

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"

	"pawpal-backend/internal/models"
)

// MessageRepository handles message database operations
type MessageRepository struct {
	db *pgxpool.Pool
}

// NewMessageRepository creates a new MessageRepository
func NewMessageRepository(db *pgxpool.Pool) *MessageRepository {
	return &MessageRepository{db: db}
}

// CreateMessage creates a new message in a chat
func (r *MessageRepository) CreateMessage(ctx context.Context, message *models.Message) error {
	query := `
		INSERT INTO messages (
			id, chat_id, sender_id, content, is_read, created_at
		) VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id, created_at`

	message.ID = uuid.New()
	message.CreatedAt = time.Now()
	message.IsRead = false

	return r.db.QueryRow(ctx, query,
		message.ID, message.ChatID, message.SenderID, message.Content, message.IsRead, message.CreatedAt,
	).Scan(&message.ID, &message.CreatedAt)
}

// GetMessagesByChat retrieves all messages in a chat
func (r *MessageRepository) GetMessagesByChat(ctx context.Context, chatID uuid.UUID, limit, offset int) ([]models.Message, error) {
	if limit <= 0 {
		limit = 50
	}

	query := `
		SELECT m.id, m.chat_id, m.sender_id, m.content, m.is_read, m.created_at,
			u.display_name as sender_name, u.avatar_url as sender_photo
		FROM messages m
		LEFT JOIN users u ON m.sender_id = u.id
		WHERE m.chat_id = $1
		ORDER BY m.created_at DESC
		LIMIT $2 OFFSET $3`

	rows, err := r.db.Query(ctx, query, chatID, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	messages := []models.Message{}
	for rows.Next() {
		var msg models.Message
		var senderName, senderPhoto *string

		err = rows.Scan(
			&msg.ID, &msg.ChatID, &msg.SenderID, &msg.Content, &msg.IsRead,
			&msg.CreatedAt, &senderName, &senderPhoto,
		)

		if err != nil {
			continue
		}

		if senderName != nil {
			msg.SenderName = *senderName
		}
		if senderPhoto != nil {
			msg.SenderPhoto = *senderPhoto
		}

		messages = append(messages, msg)
	}

	// Reverse to get chronological order
	for i, j := 0, len(messages)-1; i < j; i, j = i+1, j-1 {
		messages[i], messages[j] = messages[j], messages[i]
	}

	return messages, nil
}

// MarkMessageAsRead marks a message as read
func (r *MessageRepository) MarkMessageAsRead(ctx context.Context, messageID uuid.UUID) error {
	query := `UPDATE messages SET is_read = true WHERE id = $1`
	_, err := r.db.Exec(ctx, query, messageID)
	return err
}

// MarkChatMessagesAsRead marks all messages in a chat as read for the receiver
func (r *MessageRepository) MarkChatMessagesAsRead(ctx context.Context, chatID, receiverID uuid.UUID) error {
	query := `UPDATE messages SET is_read = true WHERE chat_id = $1 AND sender_id != $2 AND is_read = false`
	_, err := r.db.Exec(ctx, query, chatID, receiverID)
	return err
}

// DeleteMessage deletes a message
func (r *MessageRepository) DeleteMessage(ctx context.Context, messageID uuid.UUID) error {
	query := `DELETE FROM messages WHERE id = $1`
	_, err := r.db.Exec(ctx, query, messageID)
	return err
}

// GetUnreadCount gets the unread message count for a user in a chat
func (r *MessageRepository) GetUnreadCount(ctx context.Context, chatID, userID uuid.UUID) (int, error) {
	query := `SELECT COUNT(*) FROM messages WHERE chat_id = $1 AND sender_id != $2 AND is_read = false`
	var count int
	err := r.db.QueryRow(ctx, query, chatID, userID).Scan(&count)
	return count, err
}
