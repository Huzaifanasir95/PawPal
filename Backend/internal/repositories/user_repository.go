package repositories

import (
	"context"
	"fmt"
	"sort"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"

	"pawpal-backend/internal/models"
)

// UserRepositoryPG handles user database operations using PostgreSQL
type UserRepositoryPG struct {
	db *pgxpool.Pool
}

// NewUserRepository creates a new UserRepositoryPG
func NewUserRepository(db *pgxpool.Pool) UserRepository {
	return &UserRepositoryPG{db: db}
}

// Create creates a new user
func (r *UserRepositoryPG) Create(ctx context.Context, user *models.User) error {
	query := `
		INSERT INTO users (id, email, password_hash, display_name, account_type, avatar_url, is_active, email_verified, google_id, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
		RETURNING id, created_at, updated_at`

	now := time.Now()
	user.ID = uuid.New()
	user.CreatedAt = now
	user.UpdatedAt = now
	user.IsActive = true

	if user.AccountType == "" {
		user.AccountType = "pet_owner"
	}

	err := r.db.QueryRow(ctx, query,
		user.ID,
		user.Email,
		user.PasswordHash,
		user.DisplayName,
		user.AccountType,
		user.AvatarURL,
		user.IsActive,
		user.EmailVerified,
		user.GoogleID,
		user.CreatedAt,
		user.UpdatedAt,
	).Scan(&user.ID, &user.CreatedAt, &user.UpdatedAt)
	if err != nil {
		return err
	}

	if err := r.AddUserRole(ctx, user.ID, user.AccountType); err != nil && !isUndefinedTableError(err) {
		return err
	}

	return nil
}

// GetByID gets a user by ID
func (r *UserRepositoryPG) GetByID(ctx context.Context, id uuid.UUID) (*models.User, error) {
	query := `
		SELECT id, email, password_hash, display_name, account_type, avatar_url, is_active, email_verified, google_id, created_at, updated_at
		FROM users WHERE id = $1 AND is_active = true`

	user := &models.User{}
	err := r.db.QueryRow(ctx, query, id).Scan(
		&user.ID,
		&user.Email,
		&user.PasswordHash,
		&user.DisplayName,
		&user.AccountType,
		&user.AvatarURL,
		&user.IsActive,
		&user.EmailVerified,
		&user.GoogleID,
		&user.CreatedAt,
		&user.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return user, nil
}

// GetByEmail gets a user by email
func (r *UserRepositoryPG) GetByEmail(ctx context.Context, email string) (*models.User, error) {
	query := `
		SELECT id, email, password_hash, display_name, account_type, avatar_url, is_active, email_verified, google_id, created_at, updated_at
		FROM users WHERE LOWER(email) = LOWER($1)`

	user := &models.User{}
	err := r.db.QueryRow(ctx, query, email).Scan(
		&user.ID,
		&user.Email,
		&user.PasswordHash,
		&user.DisplayName,
		&user.AccountType,
		&user.AvatarURL,
		&user.IsActive,
		&user.EmailVerified,
		&user.GoogleID,
		&user.CreatedAt,
		&user.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return user, nil
}

// Update updates a user
func (r *UserRepositoryPG) Update(ctx context.Context, user *models.User) error {
	query := `
		UPDATE users 
		SET email = $2, display_name = $3, account_type = $4, avatar_url = $5, google_id = $6, email_verified = $7, updated_at = $8
		WHERE id = $1`

	_, err := r.db.Exec(ctx, query,
		user.ID,
		user.Email,
		user.DisplayName,
		user.AccountType,
		user.AvatarURL,
		user.GoogleID,
		user.EmailVerified,
		time.Now(),
	)
	return err
}

// UpdatePassword updates a user's password
func (r *UserRepositoryPG) UpdatePassword(ctx context.Context, userID uuid.UUID, passwordHash string) error {
	query := `UPDATE users SET password_hash = $2, updated_at = $3 WHERE id = $1`
	_, err := r.db.Exec(ctx, query, userID, passwordHash, time.Now())
	return err
}

// Delete soft deletes a user
func (r *UserRepositoryPG) Delete(ctx context.Context, id uuid.UUID) error {
	query := `UPDATE users SET is_active = false, updated_at = $2 WHERE id = $1`
	_, err := r.db.Exec(ctx, query, id, time.Now())
	return err
}

// SetUserRole updates account_type and keeps legacy user_role in sync when possible.
func (r *UserRepositoryPG) SetUserRole(ctx context.Context, userID uuid.UUID, role string) error {
	normalizedRole := normalizeAccountRole(role)
	if normalizedRole == "" {
		return fmt.Errorf("invalid role: %s", role)
	}

	if err := r.AddUserRole(ctx, userID, normalizedRole); err != nil && !isUndefinedTableError(err) {
		return err
	}

	query := `
		UPDATE users
		SET
			account_type = $2,
			user_role = CASE
				WHEN $2 = 'pet_owner' THEN 'petowner'
				WHEN $2 = 'vet' THEN 'vet'
				ELSE user_role
			END,
			updated_at = $3
		WHERE id = $1`
	_, err := r.db.Exec(ctx, query, userID, normalizedRole, time.Now())
	return err
}

// AddUserRole adds a role assignment to the user without changing active role.
func (r *UserRepositoryPG) AddUserRole(ctx context.Context, userID uuid.UUID, role string) error {
	normalizedRole := normalizeAccountRole(role)
	if normalizedRole == "" {
		return fmt.Errorf("invalid role: %s", role)
	}

	query := `
		INSERT INTO user_roles (id, user_id, role, created_at)
		VALUES ($1, $2, $3, $4)
		ON CONFLICT (user_id, role) DO NOTHING`

	_, err := r.db.Exec(ctx, query, uuid.New(), userID, normalizedRole, time.Now())
	return err
}

// GetUserRoles returns all roles assigned to a user.
func (r *UserRepositoryPG) GetUserRoles(ctx context.Context, userID uuid.UUID) ([]string, error) {
	query := `SELECT role FROM user_roles WHERE user_id = $1`
	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		if isUndefinedTableError(err) {
			return r.getLegacyUserRoles(ctx, userID)
		}
		return nil, err
	}
	defer rows.Close()

	roles := make([]string, 0)
	for rows.Next() {
		var role string
		if err := rows.Scan(&role); err != nil {
			return nil, err
		}
		normalized := normalizeAccountRole(role)
		if normalized != "" {
			roles = append(roles, normalized)
		}
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	roles = uniqueSortedRoles(roles)
	if len(roles) > 0 {
		return roles, nil
	}

	legacyRoles, err := r.getLegacyUserRoles(ctx, userID)
	if err != nil {
		return nil, err
	}

	for _, role := range legacyRoles {
		_ = r.AddUserRole(ctx, userID, role)
	}

	return legacyRoles, nil
}

func (r *UserRepositoryPG) getLegacyUserRoles(ctx context.Context, userID uuid.UUID) ([]string, error) {
	query := `SELECT account_type FROM users WHERE id = $1`
	var accountType string

	err := r.db.QueryRow(ctx, query, userID).Scan(&accountType)
	if err != nil {
		if err == pgx.ErrNoRows {
			return []string{"pet_owner"}, nil
		}
		return nil, err
	}

	normalized := normalizeAccountRole(accountType)
	if normalized == "" {
		normalized = "pet_owner"
	}

	return []string{normalized}, nil
}

func uniqueSortedRoles(roles []string) []string {
	seen := make(map[string]struct{}, len(roles))
	unique := make([]string, 0, len(roles))

	for _, role := range roles {
		if role == "" {
			continue
		}
		if _, exists := seen[role]; exists {
			continue
		}
		seen[role] = struct{}{}
		unique = append(unique, role)
	}

	if len(unique) == 0 {
		return []string{"pet_owner"}
	}

	sort.Strings(unique)
	return unique
}

func normalizeAccountRole(raw string) string {
	switch strings.ToLower(strings.TrimSpace(raw)) {
	case "pet_owner", "petowner", "pet-owner", "owner":
		return "pet_owner"
	case "vet", "veterinarian", "veterinary":
		return "vet"
	case "seller", "vendor", "merchant", "shop_owner", "shopowner":
		return "seller"
	case "caregiver", "care_giver", "pet_caregiver":
		return "caregiver"
	case "admin":
		return "admin"
	default:
		return ""
	}
}

func isUndefinedTableError(err error) bool {
	pgErr, ok := err.(*pgconn.PgError)
	return ok && pgErr.Code == "42P01"
}

// CreateRefreshToken creates a new refresh token
func (r *UserRepositoryPG) CreateRefreshToken(ctx context.Context, token *models.RefreshToken) error {
	query := `
		INSERT INTO refresh_tokens (id, user_id, token, expires_at, revoked, created_at)
		VALUES ($1, $2, $3, $4, $5, $6)`

	token.ID = uuid.New()
	token.CreatedAt = time.Now()
	token.Revoked = false

	_, err := r.db.Exec(ctx, query,
		token.ID,
		token.UserID,
		token.Token,
		token.ExpiresAt,
		token.Revoked,
		token.CreatedAt,
	)
	return err
}

// GetRefreshToken gets a refresh token
func (r *UserRepositoryPG) GetRefreshToken(ctx context.Context, token string) (*models.RefreshToken, error) {
	query := `
		SELECT id, user_id, token, expires_at, revoked, created_at
		FROM refresh_tokens WHERE token = $1 AND revoked = false AND expires_at > NOW()`

	refreshToken := &models.RefreshToken{}
	err := r.db.QueryRow(ctx, query, token).Scan(
		&refreshToken.ID,
		&refreshToken.UserID,
		&refreshToken.Token,
		&refreshToken.ExpiresAt,
		&refreshToken.Revoked,
		&refreshToken.CreatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return refreshToken, nil
}

// RevokeRefreshToken revokes a refresh token
func (r *UserRepositoryPG) RevokeRefreshToken(ctx context.Context, token string) error {
	query := `UPDATE refresh_tokens SET revoked = true WHERE token = $1`
	_, err := r.db.Exec(ctx, query, token)
	return err
}

// RevokeAllUserRefreshTokens revokes all refresh tokens for a user
func (r *UserRepositoryPG) RevokeAllUserRefreshTokens(ctx context.Context, userID uuid.UUID) error {
	query := `UPDATE refresh_tokens SET revoked = true WHERE user_id = $1`
	_, err := r.db.Exec(ctx, query, userID)
	return err
}

// CreatePasswordResetToken creates a password reset token
func (r *UserRepositoryPG) CreatePasswordResetToken(ctx context.Context, token *models.PasswordResetToken) error {
	query := `
		INSERT INTO password_reset_tokens (id, user_id, token, expires_at, used, created_at)
		VALUES ($1, $2, $3, $4, $5, $6)`

	token.ID = uuid.New()
	token.CreatedAt = time.Now()
	token.Used = false

	_, err := r.db.Exec(ctx, query,
		token.ID,
		token.UserID,
		token.Token,
		token.ExpiresAt,
		token.Used,
		token.CreatedAt,
	)
	return err
}

// GetPasswordResetToken gets a password reset token
func (r *UserRepositoryPG) GetPasswordResetToken(ctx context.Context, token string) (*models.PasswordResetToken, error) {
	query := `
		SELECT id, user_id, token, expires_at, used, created_at
		FROM password_reset_tokens WHERE token = $1 AND used = false AND expires_at > NOW()`

	resetToken := &models.PasswordResetToken{}
	err := r.db.QueryRow(ctx, query, token).Scan(
		&resetToken.ID,
		&resetToken.UserID,
		&resetToken.Token,
		&resetToken.ExpiresAt,
		&resetToken.Used,
		&resetToken.CreatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return resetToken, nil
}

// MarkPasswordResetTokenUsed marks a password reset token as used
func (r *UserRepositoryPG) MarkPasswordResetTokenUsed(ctx context.Context, token string) error {
	query := `UPDATE password_reset_tokens SET used = true WHERE token = $1`
	_, err := r.db.Exec(ctx, query, token)
	return err
}

// Adapter methods to match the UserRepository interface

// CreateUser is an adapter for Create method
func (r *UserRepositoryPG) CreateUser(ctx context.Context, user *models.User) error {
	return r.Create(ctx, user)
}

// GetUserByID is an adapter for GetByID method
func (r *UserRepositoryPG) GetUserByID(ctx context.Context, userID uuid.UUID) (*models.User, error) {
	return r.GetByID(ctx, userID)
}

// GetUserByEmail is an adapter for GetByEmail method
func (r *UserRepositoryPG) GetUserByEmail(ctx context.Context, email string) (*models.User, error) {
	return r.GetByEmail(ctx, email)
}

// UpdateUser is an adapter for Update method
func (r *UserRepositoryPG) UpdateUser(ctx context.Context, user *models.User) error {
	return r.Update(ctx, user)
}

// DeleteUser is an adapter for Delete method
func (r *UserRepositoryPG) DeleteUser(ctx context.Context, userID uuid.UUID) error {
	return r.Delete(ctx, userID)
}

// StoreRefreshToken is an adapter for CreateRefreshToken method
func (r *UserRepositoryPG) StoreRefreshToken(ctx context.Context, token *models.RefreshToken) error {
	return r.CreateRefreshToken(ctx, token)
}

// DeleteRefreshToken is an adapter for RevokeRefreshToken method
func (r *UserRepositoryPG) DeleteRefreshToken(ctx context.Context, token string) error {
	return r.RevokeRefreshToken(ctx, token)
}

// DeleteUserRefreshTokens is an adapter for RevokeAllUserRefreshTokens method
func (r *UserRepositoryPG) DeleteUserRefreshTokens(ctx context.Context, userID uuid.UUID) error {
	return r.RevokeAllUserRefreshTokens(ctx, userID)
}
