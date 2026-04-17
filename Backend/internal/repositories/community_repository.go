package repositories

import (
	"context"
	"errors"
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
			id, user_id, title, content, category, user_name, user_avatar, image_urls,
			likes_count, comments_count, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
		RETURNING id, created_at, updated_at`

	now := time.Now()
	post.ID = uuid.New()
	post.CreatedAt = now
	post.UpdatedAt = now
	post.LikesCount = 0
	post.CommentsCount = 0

	// Default category if not specified
	if post.Category == "" {
		post.Category = "general"
	}

	return r.db.QueryRow(ctx, query,
		post.ID,
		post.UserID,
		post.Title,
		post.Content,
		post.Category,
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
		SELECT id, user_id, title, content, category, user_name, user_avatar, image_urls,
			likes_count, comments_count, created_at, updated_at
		FROM posts WHERE id = $1`

	post := &models.Post{}
	err := r.db.QueryRow(ctx, query, id).Scan(
		&post.ID,
		&post.UserID,
		&post.Title,
		&post.Content,
		&post.Category,
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

// GetAllPosts gets all posts with pagination and optional category filter
func (r *CommunityRepository) GetAllPosts(ctx context.Context, sortBy string, descending bool, limit int, offset int, category string) ([]models.Post, error) {
	order := "ASC"
	if descending {
		order = "DESC"
	}

	// Validate sortBy to prevent SQL injection
	validSortFields := map[string]bool{
		"created_at":  true,
		"likes_count": true,
		"updated_at":  true,
	}
	if !validSortFields[sortBy] {
		sortBy = "created_at"
	}

	var query string
	var rows pgx.Rows
	var err error

	if category != "" && category != "all" {
		query = `
			SELECT id, user_id, title, content, category, user_name, user_avatar, image_urls,
				likes_count, comments_count, created_at, updated_at
			FROM posts WHERE category = $3 ORDER BY ` + sortBy + ` ` + order + `
			LIMIT $1 OFFSET $2`
		rows, err = r.db.Query(ctx, query, limit, offset, category)
	} else {
		query = `
			SELECT id, user_id, title, content, category, user_name, user_avatar, image_urls,
				likes_count, comments_count, created_at, updated_at
			FROM posts ORDER BY ` + sortBy + ` ` + order + `
			LIMIT $1 OFFSET $2`
		rows, err = r.db.Query(ctx, query, limit, offset)
	}

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
			&post.Category,
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

// UpdateComment updates comment content.
func (r *CommunityRepository) UpdateComment(ctx context.Context, commentID uuid.UUID, content string) error {
	_, err := r.db.Exec(ctx, `
		UPDATE comments
		SET content = $2
		WHERE id = $1
	`, commentID, content)
	return err
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

// CreateGroup creates a new community group and adds owner as a member.
func (r *CommunityRepository) CreateGroup(ctx context.Context, group *models.CommunityGroup) error {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	now := time.Now()
	group.ID = uuid.New()
	group.CreatedAt = now
	group.UpdatedAt = now
	group.MembersCount = 1
	group.PostsCount = 0
	group.IsMember = true

	err = tx.QueryRow(ctx, `
		INSERT INTO community_groups (
			id, owner_id, name, slug, description, icon, is_private,
			members_count, posts_count, created_at, updated_at
		)
		VALUES ($1, $2, $3, $4, $5, $6, $7, 1, 0, $8, $9)
		RETURNING id, created_at, updated_at
	`,
		group.ID,
		group.OwnerID,
		group.Name,
		group.Slug,
		group.Description,
		group.Icon,
		group.IsPrivate,
		group.CreatedAt,
		group.UpdatedAt,
	).Scan(&group.ID, &group.CreatedAt, &group.UpdatedAt)
	if err != nil {
		return err
	}

	_, err = tx.Exec(ctx, `
		INSERT INTO community_group_members (id, group_id, user_id, role, created_at)
		VALUES ($1, $2, $3, 'owner', $4)
	`, uuid.New(), group.ID, group.OwnerID, now)
	if err != nil {
		return err
	}

	return tx.Commit(ctx)
}

// ListGroups returns community groups with membership flag for requesting user.
func (r *CommunityRepository) ListGroups(ctx context.Context, userID uuid.UUID, query string, limit, offset int) ([]models.CommunityGroup, int, error) {
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	if offset < 0 {
		offset = 0
	}

	searchText := "%" + query + "%"

	var total int
	err := r.db.QueryRow(ctx, `
		SELECT COUNT(*)
		FROM community_groups cg
		WHERE ($1 = '%%' OR cg.name ILIKE $1 OR COALESCE(cg.description, '') ILIKE $1)
	`, searchText).Scan(&total)
	if err != nil {
		return nil, 0, err
	}

	rows, err := r.db.Query(ctx, `
		SELECT
			cg.id,
			cg.owner_id,
			cg.name,
			cg.slug,
			cg.description,
			cg.icon,
			cg.is_private,
			cg.members_count,
			cg.posts_count,
			EXISTS(
				SELECT 1
				FROM community_group_members cgm
				WHERE cgm.group_id = cg.id AND cgm.user_id = $2
			) AS is_member,
			u.display_name,
			cg.created_at,
			cg.updated_at
		FROM community_groups cg
		JOIN users u ON u.id = cg.owner_id
		WHERE ($1 = '%%' OR cg.name ILIKE $1 OR COALESCE(cg.description, '') ILIKE $1)
		ORDER BY cg.members_count DESC, cg.created_at DESC
		LIMIT $3 OFFSET $4
	`, searchText, userID, limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	groups := make([]models.CommunityGroup, 0)
	for rows.Next() {
		var group models.CommunityGroup
		err = rows.Scan(
			&group.ID,
			&group.OwnerID,
			&group.Name,
			&group.Slug,
			&group.Description,
			&group.Icon,
			&group.IsPrivate,
			&group.MembersCount,
			&group.PostsCount,
			&group.IsMember,
			&group.OwnerName,
			&group.CreatedAt,
			&group.UpdatedAt,
		)
		if err != nil {
			return nil, 0, err
		}
		groups = append(groups, group)
	}

	return groups, total, nil
}

// GetMyGroups returns groups that user has joined.
func (r *CommunityRepository) GetMyGroups(ctx context.Context, userID uuid.UUID, limit, offset int) ([]models.CommunityGroup, int, error) {
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	if offset < 0 {
		offset = 0
	}

	var total int
	err := r.db.QueryRow(ctx, `
		SELECT COUNT(*)
		FROM community_group_members cgm
		WHERE cgm.user_id = $1
	`, userID).Scan(&total)
	if err != nil {
		return nil, 0, err
	}

	rows, err := r.db.Query(ctx, `
		SELECT
			cg.id,
			cg.owner_id,
			cg.name,
			cg.slug,
			cg.description,
			cg.icon,
			cg.is_private,
			cg.members_count,
			cg.posts_count,
			TRUE AS is_member,
			u.display_name,
			cg.created_at,
			cg.updated_at
		FROM community_group_members cgm
		JOIN community_groups cg ON cg.id = cgm.group_id
		JOIN users u ON u.id = cg.owner_id
		WHERE cgm.user_id = $1
		ORDER BY cgm.created_at DESC
		LIMIT $2 OFFSET $3
	`, userID, limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	groups := make([]models.CommunityGroup, 0)
	for rows.Next() {
		var group models.CommunityGroup
		err = rows.Scan(
			&group.ID,
			&group.OwnerID,
			&group.Name,
			&group.Slug,
			&group.Description,
			&group.Icon,
			&group.IsPrivate,
			&group.MembersCount,
			&group.PostsCount,
			&group.IsMember,
			&group.OwnerName,
			&group.CreatedAt,
			&group.UpdatedAt,
		)
		if err != nil {
			return nil, 0, err
		}
		groups = append(groups, group)
	}

	return groups, total, nil
}

// JoinGroup adds user membership into a group.
func (r *CommunityRepository) JoinGroup(ctx context.Context, groupID, userID uuid.UUID) (bool, error) {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return false, err
	}
	defer tx.Rollback(ctx)

	result, err := tx.Exec(ctx, `
		INSERT INTO community_group_members (id, group_id, user_id, role, created_at)
		VALUES ($1, $2, $3, 'member', $4)
		ON CONFLICT (group_id, user_id) DO NOTHING
	`, uuid.New(), groupID, userID, time.Now())
	if err != nil {
		return false, err
	}

	if result.RowsAffected() == 0 {
		return false, nil
	}

	_, err = tx.Exec(ctx, `
		UPDATE community_groups
		SET members_count = members_count + 1, updated_at = CURRENT_TIMESTAMP
		WHERE id = $1
	`, groupID)
	if err != nil {
		return false, err
	}

	if err = tx.Commit(ctx); err != nil {
		return false, err
	}

	return true, nil
}

// LeaveGroup removes user membership from a group.
func (r *CommunityRepository) LeaveGroup(ctx context.Context, groupID, userID uuid.UUID) (bool, error) {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return false, err
	}
	defer tx.Rollback(ctx)

	var role string
	err = tx.QueryRow(ctx, `
		SELECT role
		FROM community_group_members
		WHERE group_id = $1 AND user_id = $2
	`, groupID, userID).Scan(&role)
	if err == pgx.ErrNoRows {
		return false, nil
	}
	if err != nil {
		return false, err
	}

	if role == "owner" {
		return false, errors.New("group owner cannot leave without transferring ownership")
	}

	result, err := tx.Exec(ctx, `
		DELETE FROM community_group_members
		WHERE group_id = $1 AND user_id = $2
	`, groupID, userID)
	if err != nil {
		return false, err
	}

	if result.RowsAffected() == 0 {
		return false, nil
	}

	_, err = tx.Exec(ctx, `
		UPDATE community_groups
		SET members_count = GREATEST(0, members_count - 1), updated_at = CURRENT_TIMESTAMP
		WHERE id = $1
	`, groupID)
	if err != nil {
		return false, err
	}

	if err = tx.Commit(ctx); err != nil {
		return false, err
	}

	return true, nil
}

// AddPostToGroup links a post into a community group.
func (r *CommunityRepository) AddPostToGroup(ctx context.Context, groupID, postID, userID uuid.UUID) error {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	var postOwnerID uuid.UUID
	err = tx.QueryRow(ctx, `SELECT user_id FROM posts WHERE id = $1`, postID).Scan(&postOwnerID)
	if err == pgx.ErrNoRows {
		return errors.New("post not found")
	}
	if err != nil {
		return err
	}
	if postOwnerID != userID {
		return errors.New("only the post author can add this post to groups")
	}

	var isMember bool
	err = tx.QueryRow(ctx, `
		SELECT EXISTS(
			SELECT 1 FROM community_group_members
			WHERE group_id = $1 AND user_id = $2
		)
	`, groupID, userID).Scan(&isMember)
	if err != nil {
		return err
	}
	if !isMember {
		return errors.New("join the group before adding posts")
	}

	result, err := tx.Exec(ctx, `
		INSERT INTO community_group_posts (id, group_id, post_id, added_by, created_at)
		VALUES ($1, $2, $3, $4, $5)
		ON CONFLICT (group_id, post_id) DO NOTHING
	`, uuid.New(), groupID, postID, userID, time.Now())
	if err != nil {
		return err
	}

	if result.RowsAffected() > 0 {
		_, err = tx.Exec(ctx, `
			UPDATE community_groups
			SET posts_count = posts_count + 1, updated_at = CURRENT_TIMESTAMP
			WHERE id = $1
		`, groupID)
		if err != nil {
			return err
		}
	}

	return tx.Commit(ctx)
}

// GetGroupPosts returns posts linked to a group.
func (r *CommunityRepository) GetGroupPosts(ctx context.Context, groupID uuid.UUID, limit, offset int) ([]models.Post, int, error) {
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	if offset < 0 {
		offset = 0
	}

	var total int
	err := r.db.QueryRow(ctx, `
		SELECT COUNT(*)
		FROM community_group_posts
		WHERE group_id = $1
	`, groupID).Scan(&total)
	if err != nil {
		return nil, 0, err
	}

	rows, err := r.db.Query(ctx, `
		SELECT
			p.id, p.user_id, p.title, p.content, p.category, p.user_name, p.user_avatar,
			p.image_urls, p.likes_count, p.comments_count, p.created_at, p.updated_at
		FROM community_group_posts cgp
		JOIN posts p ON p.id = cgp.post_id
		WHERE cgp.group_id = $1
		ORDER BY cgp.created_at DESC
		LIMIT $2 OFFSET $3
	`, groupID, limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	posts := make([]models.Post, 0)
	for rows.Next() {
		var post models.Post
		err = rows.Scan(
			&post.ID,
			&post.UserID,
			&post.Title,
			&post.Content,
			&post.Category,
			&post.UserName,
			&post.UserAvatar,
			&post.ImageURLs,
			&post.LikesCount,
			&post.CommentsCount,
			&post.CreatedAt,
			&post.UpdatedAt,
		)
		if err != nil {
			return nil, 0, err
		}
		posts = append(posts, post)
	}

	return posts, total, nil
}

// GetTrendingPosts returns posts ordered by recent engagement score.
func (r *CommunityRepository) GetTrendingPosts(ctx context.Context, limit, offset int) ([]models.Post, error) {
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	if offset < 0 {
		offset = 0
	}

	rows, err := r.db.Query(ctx, `
		SELECT
			p.id, p.user_id, p.title, p.content, p.category, p.user_name, p.user_avatar,
			p.image_urls, p.likes_count, p.comments_count, p.created_at, p.updated_at
		FROM posts p
		ORDER BY (
			(p.likes_count * 3) +
			(p.comments_count * 2) +
			GREATEST(0, 24 - (EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - p.created_at)) / 3600))
		) DESC,
		p.created_at DESC
		LIMIT $1 OFFSET $2
	`, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	posts := make([]models.Post, 0)
	for rows.Next() {
		var post models.Post
		err = rows.Scan(
			&post.ID,
			&post.UserID,
			&post.Title,
			&post.Content,
			&post.Category,
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

// GetTrendingHashtags returns hashtag frequencies from post titles/content.
func (r *CommunityRepository) GetTrendingHashtags(ctx context.Context, limit int) ([]models.TrendingHashtag, error) {
	if limit <= 0 || limit > 50 {
		limit = 12
	}

	rows, err := r.db.Query(ctx, `
		SELECT LOWER(matches[1]) AS tag, COUNT(*) AS usage_count
		FROM posts p,
		LATERAL regexp_matches(p.title || ' ' || p.content, '#([A-Za-z0-9_]{2,40})', 'g') AS matches
		GROUP BY LOWER(matches[1])
		ORDER BY usage_count DESC, tag ASC
		LIMIT $1
	`, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	hashtags := make([]models.TrendingHashtag, 0)
	for rows.Next() {
		var hashtag models.TrendingHashtag
		err = rows.Scan(&hashtag.Tag, &hashtag.UsageCount)
		if err != nil {
			return nil, err
		}
		hashtag.Tag = "#" + hashtag.Tag
		hashtags = append(hashtags, hashtag)
	}

	return hashtags, nil
}

// GetPostsByHashtag returns posts containing a specific hashtag.
func (r *CommunityRepository) GetPostsByHashtag(ctx context.Context, hashtag string, limit, offset int) ([]models.Post, error) {
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	if offset < 0 {
		offset = 0
	}

	rows, err := r.db.Query(ctx, `
		SELECT
			p.id, p.user_id, p.title, p.content, p.category, p.user_name, p.user_avatar,
			p.image_urls, p.likes_count, p.comments_count, p.created_at, p.updated_at
		FROM posts p
		WHERE (p.title || ' ' || p.content) ~* ('(^|[[:space:]])#' || $1 || '([[:space:][:punct:]]|$)')
		ORDER BY p.created_at DESC
		LIMIT $2 OFFSET $3
	`, hashtag, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	posts := make([]models.Post, 0)
	for rows.Next() {
		var post models.Post
		err = rows.Scan(
			&post.ID,
			&post.UserID,
			&post.Title,
			&post.Content,
			&post.Category,
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
