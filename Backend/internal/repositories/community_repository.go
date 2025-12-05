package repositories

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"pawpal-backend/internal/models"
)

// CommunityRepository handles posts, comments, and likes database operations
type CommunityRepository struct {
	db *pgxpool.Pool
}

// NewCommunityRepository creates a new CommunityRepository
func NewCommunityRepository(db *pgxpool.Pool) *CommunityRepository {
	return &CommunityRepository{db: db}
}

// Post Methods

// CreatePost creates a new post
func (r *CommunityRepository) CreatePost(ctx context.Context, post *models.Post) error {
	query := `
		INSERT INTO posts (
			id, user_id, title, content, user_name, user_avatar, image_urls,
			likes_count, comments_count, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
		RETURNING id, created_at, updated_at`

	now := time.Now()
	post.ID = uuid.New()
	post.CreatedAt = now
	post.UpdatedAt = now
	post.LikesCount = 0
	post.CommentsCount = 0

	return r.db.QueryRow(ctx, query,
		post.ID,
		post.UserID,
		post.Title,
		post.Content,
		post.UserName,
		post.UserAvatar,
		post.ImageURLs,
		post.LikesCount,
		post.CommentsCount,
		post.CreatedAt,
		post.UpdatedAt,
	).Scan(&post.ID, &post.CreatedAt, &post.UpdatedAt)
}

// GetPostByID gets a post by ID
func (r *CommunityRepository) GetPostByID(ctx context.Context, id uuid.UUID) (*models.Post, error) {
	query := `
		SELECT id, user_id, title, content, user_name, user_avatar, image_urls,
			likes_count, comments_count, created_at, updated_at
		FROM posts WHERE id = $1`

	post := &models.Post{}
	err := r.db.QueryRow(ctx, query, id).Scan(
		&post.ID,
		&post.UserID,
		&post.Title,
		&post.Content,
		&post.UserName,
		&post.UserAvatar,
		&post.ImageURLs,
		&post.LikesCount,
		&post.CommentsCount,
		&post.CreatedAt,
		&post.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return post, nil
}

// GetAllPosts gets all posts with pagination
func (r *CommunityRepository) GetAllPosts(ctx context.Context, sortBy string, descending bool, limit int, offset int) ([]models.Post, error) {
	order := "ASC"
	if descending {
		order = "DESC"
	}

	// Validate sortBy to prevent SQL injection
	validSortFields := map[string]bool{
		"created_at":   true,
		"likes_count":  true,
		"updated_at":   true,
	}
	if !validSortFields[sortBy] {
		sortBy = "created_at"
	}

	query := `
		SELECT id, user_id, title, content, user_name, user_avatar, image_urls,
			likes_count, comments_count, created_at, updated_at
		FROM posts ORDER BY ` + sortBy + ` ` + order + `
		LIMIT $1 OFFSET $2`

	rows, err := r.db.Query(ctx, query, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var posts []models.Post
	for rows.Next() {
		post := models.Post{}
		err := rows.Scan(
			&post.ID,
			&post.UserID,
			&post.Title,
			&post.Content,
			&post.UserName,
			&post.UserAvatar,
			&post.ImageURLs,
			&post.LikesCount,
			&post.CommentsCount,
			&post.CreatedAt,
			&post.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		posts = append(posts, post)
	}
	return posts, nil
}

// GetPostsByUserID gets all posts by a user
func (r *CommunityRepository) GetPostsByUserID(ctx context.Context, userID uuid.UUID) ([]models.Post, error) {
	query := `
		SELECT id, user_id, title, content, user_name, user_avatar, image_urls,
			likes_count, comments_count, created_at, updated_at
		FROM posts WHERE user_id = $1 ORDER BY created_at DESC`

	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var posts []models.Post
	for rows.Next() {
		post := models.Post{}
		err := rows.Scan(
			&post.ID,
			&post.UserID,
			&post.Title,
			&post.Content,
			&post.UserName,
			&post.UserAvatar,
			&post.ImageURLs,
			&post.LikesCount,
			&post.CommentsCount,
			&post.CreatedAt,
			&post.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		posts = append(posts, post)
	}
	return posts, nil
}

// UpdatePost updates a post
func (r *CommunityRepository) UpdatePost(ctx context.Context, post *models.Post) error {
	query := `
		UPDATE posts SET title = $2, content = $3, updated_at = $4
		WHERE id = $1`

	_, err := r.db.Exec(ctx, query,
		post.ID,
		post.Title,
		post.Content,
		time.Now(),
	)
	return err
}

// DeletePost deletes a post and all associated comments and likes
func (r *CommunityRepository) DeletePost(ctx context.Context, id uuid.UUID) error {
	// Start a transaction
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	// Delete all likes for this post
	_, err = tx.Exec(ctx, `DELETE FROM likes WHERE target_id = $1 AND target_type = 'post'`, id)
	if err != nil {
		return err
	}

	// Delete all likes for comments on this post
	_, err = tx.Exec(ctx, `
		DELETE FROM likes WHERE target_id IN (
			SELECT id FROM comments WHERE post_id = $1
		) AND target_type = 'comment'`, id)
	if err != nil {
		return err
	}

	// Delete all comments for this post
	_, err = tx.Exec(ctx, `DELETE FROM comments WHERE post_id = $1`, id)
	if err != nil {
		return err
	}

	// Delete the post
	_, err = tx.Exec(ctx, `DELETE FROM posts WHERE id = $1`, id)
	if err != nil {
		return err
	}

	return tx.Commit(ctx)
}

// Comment Methods

// CreateComment creates a new comment
func (r *CommunityRepository) CreateComment(ctx context.Context, comment *models.Comment) error {
	query := `
		INSERT INTO comments (
			id, post_id, user_id, parent_comment_id, content, user_name, user_avatar, likes_count, created_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
		RETURNING id, created_at`

	now := time.Now()
	comment.ID = uuid.New()
	comment.CreatedAt = now
	comment.LikesCount = 0

	err := r.db.QueryRow(ctx, query,
		comment.ID,
		comment.PostID,
		comment.UserID,
		comment.ParentCommentID,
		comment.Content,
		comment.UserName,
		comment.UserAvatar,
		comment.LikesCount,
		comment.CreatedAt,
	).Scan(&comment.ID, &comment.CreatedAt)

	if err != nil {
		return err
	}

	// Update post comments count
	_, err = r.db.Exec(ctx, `UPDATE posts SET comments_count = comments_count + 1 WHERE id = $1`, comment.PostID)
	return err
}

// GetCommentsByPostID gets all comments for a post (with nested replies)
func (r *CommunityRepository) GetCommentsByPostID(ctx context.Context, postID uuid.UUID) ([]models.Comment, error) {
	query := `
		SELECT id, post_id, user_id, parent_comment_id, content, user_name, user_avatar, likes_count, created_at
		FROM comments WHERE post_id = $1 ORDER BY created_at ASC`

	rows, err := r.db.Query(ctx, query, postID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var allComments []models.Comment
	commentMap := make(map[uuid.UUID]*models.Comment)

	for rows.Next() {
		comment := models.Comment{}
		err := rows.Scan(
			&comment.ID,
			&comment.PostID,
			&comment.UserID,
			&comment.ParentCommentID,
			&comment.Content,
			&comment.UserName,
			&comment.UserAvatar,
			&comment.LikesCount,
			&comment.CreatedAt,
		)
		if err != nil {
			return nil, err
		}
		comment.Replies = []models.Comment{}
		allComments = append(allComments, comment)
		commentMap[comment.ID] = &allComments[len(allComments)-1]
	}

	// Build comment tree
	var rootComments []models.Comment
	for i := range allComments {
		comment := &allComments[i]
		if comment.ParentCommentID == nil {
			rootComments = append(rootComments, *comment)
		} else {
			if parent, ok := commentMap[*comment.ParentCommentID]; ok {
				parent.Replies = append(parent.Replies, *comment)
			}
		}
	}

	return rootComments, nil
}

// GetCommentByID gets a comment by ID
func (r *CommunityRepository) GetCommentByID(ctx context.Context, id uuid.UUID) (*models.Comment, error) {
	query := `
		SELECT id, post_id, user_id, parent_comment_id, content, user_name, user_avatar, likes_count, created_at
		FROM comments WHERE id = $1`

	comment := &models.Comment{}
	err := r.db.QueryRow(ctx, query, id).Scan(
		&comment.ID,
		&comment.PostID,
		&comment.UserID,
		&comment.ParentCommentID,
		&comment.Content,
		&comment.UserName,
		&comment.UserAvatar,
		&comment.LikesCount,
		&comment.CreatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return comment, nil
}

// DeleteComment deletes a comment and its replies
func (r *CommunityRepository) DeleteComment(ctx context.Context, id uuid.UUID, postID uuid.UUID) error {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	// Count the comment and its replies
	var count int
	err = tx.QueryRow(ctx, `
		WITH RECURSIVE comment_tree AS (
			SELECT id FROM comments WHERE id = $1
			UNION ALL
			SELECT c.id FROM comments c JOIN comment_tree ct ON c.parent_comment_id = ct.id
		)
		SELECT COUNT(*) FROM comment_tree`, id).Scan(&count)
	if err != nil {
		return err
	}

	// Delete likes for the comment and its replies
	_, err = tx.Exec(ctx, `
		WITH RECURSIVE comment_tree AS (
			SELECT id FROM comments WHERE id = $1
			UNION ALL
			SELECT c.id FROM comments c JOIN comment_tree ct ON c.parent_comment_id = ct.id
		)
		DELETE FROM likes WHERE target_id IN (SELECT id FROM comment_tree) AND target_type = 'comment'`, id)
	if err != nil {
		return err
	}

	// Delete the comment and its replies
	_, err = tx.Exec(ctx, `
		WITH RECURSIVE comment_tree AS (
			SELECT id FROM comments WHERE id = $1
			UNION ALL
			SELECT c.id FROM comments c JOIN comment_tree ct ON c.parent_comment_id = ct.id
		)
		DELETE FROM comments WHERE id IN (SELECT id FROM comment_tree)`, id)
	if err != nil {
		return err
	}

	// Update post comments count
	_, err = tx.Exec(ctx, `UPDATE posts SET comments_count = comments_count - $2 WHERE id = $1`, postID, count)
	if err != nil {
		return err
	}

	return tx.Commit(ctx)
}

// Like Methods

// ToggleLike toggles a like on a post or comment
func (r *CommunityRepository) ToggleLike(ctx context.Context, userID uuid.UUID, targetID uuid.UUID, targetType string) (bool, error) {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return false, err
	}
	defer tx.Rollback(ctx)

	// Check if like exists
	var existingID uuid.UUID
	err = tx.QueryRow(ctx, `
		SELECT id FROM likes WHERE user_id = $1 AND target_id = $2 AND target_type = $3`,
		userID, targetID, targetType).Scan(&existingID)

	if err == pgx.ErrNoRows {
		// Create like
		_, err = tx.Exec(ctx, `
			INSERT INTO likes (id, user_id, target_id, target_type, created_at)
			VALUES ($1, $2, $3, $4, $5)`,
			uuid.New(), userID, targetID, targetType, time.Now())
		if err != nil {
			return false, err
		}

		// Update likes count
		if targetType == "post" {
			_, err = tx.Exec(ctx, `UPDATE posts SET likes_count = likes_count + 1 WHERE id = $1`, targetID)
		} else {
			_, err = tx.Exec(ctx, `UPDATE comments SET likes_count = likes_count + 1 WHERE id = $1`, targetID)
		}
		if err != nil {
			return false, err
		}

		err = tx.Commit(ctx)
		return true, err
	} else if err != nil {
		return false, err
	}

	// Remove like
	_, err = tx.Exec(ctx, `DELETE FROM likes WHERE id = $1`, existingID)
	if err != nil {
		return false, err
	}

	// Update likes count
	if targetType == "post" {
		_, err = tx.Exec(ctx, `UPDATE posts SET likes_count = likes_count - 1 WHERE id = $1`, targetID)
	} else {
		_, err = tx.Exec(ctx, `UPDATE comments SET likes_count = likes_count - 1 WHERE id = $1`, targetID)
	}
	if err != nil {
		return false, err
	}

	err = tx.Commit(ctx)
	return false, err
}

// HasUserLiked checks if a user has liked a post or comment
func (r *CommunityRepository) HasUserLiked(ctx context.Context, userID uuid.UUID, targetID uuid.UUID, targetType string) (bool, error) {
	var count int
	err := r.db.QueryRow(ctx, `
		SELECT COUNT(*) FROM likes WHERE user_id = $1 AND target_id = $2 AND target_type = $3`,
		userID, targetID, targetType).Scan(&count)
	return count > 0, err
}
