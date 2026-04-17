package repositories

import (
	"context"
	"encoding/json"
	"fmt"
	"net/url"
	"sort"
	"strings"
	"time"

	"pawpal-backend/internal/database"
	"pawpal-backend/internal/models"

	"github.com/google/uuid"
)

// UserRepositorySupabase implements UserRepository using Supabase REST API
type UserRepositorySupabase struct {
	client *database.SupabaseClient
}

// NewUserRepositorySupabase creates a new Supabase-based user repository
func NewUserRepositorySupabase(client *database.SupabaseClient) *UserRepositorySupabase {
	return &UserRepositorySupabase{
		client: client,
	}
}

func (r *UserRepositorySupabase) CreateUser(ctx context.Context, user *models.User) error {
	// Generate UUID if not provided
	if user.ID == uuid.Nil {
		user.ID = uuid.New()
	}

	// Set default user_role if not provided
	userRole := user.UserRole
	if userRole == "" {
		userRole = "petowner" // Default to petowner
	}

	// Set is_active to true by default for new users
	isActive := user.IsActive
	if !isActive {
		isActive = true // New users are active by default
	}

	data := map[string]interface{}{
		"id":             user.ID,
		"email":          user.Email,
		"password_hash":  user.PasswordHash,
		"display_name":   user.DisplayName,
		"account_type":   user.AccountType,
		"user_role":      userRole,
		"avatar_url":     user.AvatarURL,
		"is_active":      isActive,
		"email_verified": user.EmailVerified,
		"google_id":      user.GoogleID,
	}

	respData, err := r.client.Insert(ctx, "users", data)
	if err != nil {
		return fmt.Errorf("failed to create user: %w", err)
	}

	var users []models.User
	if err := json.Unmarshal(respData, &users); err != nil {
		return fmt.Errorf("failed to parse response: %w", err)
	}

	if len(users) > 0 {
		*user = users[0]
	}

	if err := r.AddUserRole(ctx, user.ID, user.AccountType); err != nil && !isMissingUserRolesTable(err) {
		return err
	}

	return nil
}

func (r *UserRepositorySupabase) GetUserByID(ctx context.Context, userID uuid.UUID) (*models.User, error) {
	query := map[string]string{
		"id":     fmt.Sprintf("eq.%s", userID.String()),
		"select": "*",
	}

	respData, err := r.client.Select(ctx, "users", query)
	if err != nil {
		return nil, fmt.Errorf("failed to get user: %w", err)
	}

	var users []models.User
	if err := json.Unmarshal(respData, &users); err != nil {
		return nil, fmt.Errorf("failed to parse response: %w", err)
	}

	if len(users) == 0 {
		return nil, nil // Return nil, nil when user not found (not an error)
	}

	return &users[0], nil
}

func (r *UserRepositorySupabase) GetUserByEmail(ctx context.Context, email string) (*models.User, error) {
	query := map[string]string{
		"email":  fmt.Sprintf("ilike.%s", url.QueryEscape(email)),
		"select": "*",
	}

	respData, err := r.client.Select(ctx, "users", query)
	if err != nil {
		return nil, fmt.Errorf("failed to get user: %w", err)
	}

	// Use a temporary struct that includes password_hash for unmarshaling
	var rawUsers []struct {
		ID            uuid.UUID `json:"id"`
		Email         string    `json:"email"`
		PasswordHash  string    `json:"password_hash"`
		DisplayName   *string   `json:"display_name"`
		AccountType   string    `json:"account_type"`
		UserRole      string    `json:"user_role"`
		AvatarURL     *string   `json:"avatar_url"`
		IsActive      bool      `json:"is_active"`
		EmailVerified bool      `json:"email_verified"`
		GoogleID      *string   `json:"google_id"`
		CreatedAt     time.Time `json:"created_at"`
		UpdatedAt     time.Time `json:"updated_at"`
	}

	if err := json.Unmarshal(respData, &rawUsers); err != nil {
		return nil, fmt.Errorf("failed to parse response: %w", err)
	}

	if len(rawUsers) == 0 {
		return nil, nil // Return nil, nil when user not found (not an error)
	}

	// Convert to User model
	raw := rawUsers[0]
	user := &models.User{
		ID:            raw.ID,
		Email:         raw.Email,
		PasswordHash:  raw.PasswordHash,
		DisplayName:   raw.DisplayName,
		AccountType:   raw.AccountType,
		UserRole:      raw.UserRole,
		AvatarURL:     raw.AvatarURL,
		IsActive:      raw.IsActive,
		EmailVerified: raw.EmailVerified,
		GoogleID:      raw.GoogleID,
		CreatedAt:     raw.CreatedAt,
		UpdatedAt:     raw.UpdatedAt,
	}

	return user, nil
}

func (r *UserRepositorySupabase) UpdateUser(ctx context.Context, user *models.User) error {
	query := map[string]string{
		"id": fmt.Sprintf("eq.%s", user.ID.String()),
	}

	data := map[string]interface{}{
		"email":          user.Email,
		"display_name":   user.DisplayName,
		"account_type":   user.AccountType,
		"user_role":      user.UserRole,
		"avatar_url":     user.AvatarURL,
		"is_active":      user.IsActive,
		"email_verified": user.EmailVerified,
	}

	_, err := r.client.Update(ctx, "users", query, data)
	if err != nil {
		return fmt.Errorf("failed to update user: %w", err)
	}

	return nil
}

func (r *UserRepositorySupabase) DeleteUser(ctx context.Context, userID uuid.UUID) error {
	query := map[string]string{
		"id": fmt.Sprintf("eq.%s", userID.String()),
	}

	err := r.client.Delete(ctx, "users", query)
	if err != nil {
		return fmt.Errorf("failed to delete user: %w", err)
	}

	return nil
}

func (r *UserRepositorySupabase) UpdatePassword(ctx context.Context, userID uuid.UUID, hashedPassword string) error {
	query := map[string]string{
		"id": fmt.Sprintf("eq.%s", userID.String()),
	}

	data := map[string]interface{}{
		"password_hash": hashedPassword,
	}

	_, err := r.client.Update(ctx, "users", query, data)
	if err != nil {
		return fmt.Errorf("failed to update password: %w", err)
	}

	return nil
}

func (r *UserRepositorySupabase) StoreRefreshToken(ctx context.Context, token *models.RefreshToken) error {
	// Generate UUID if not provided
	if token.ID == uuid.Nil {
		token.ID = uuid.New()
	}

	data := map[string]interface{}{
		"id":         token.ID,
		"user_id":    token.UserID,
		"token":      token.Token,
		"expires_at": token.ExpiresAt,
	}

	_, err := r.client.Insert(ctx, "refresh_tokens", data)
	if err != nil {
		return fmt.Errorf("failed to store refresh token: %w", err)
	}

	return nil
}

func (r *UserRepositorySupabase) GetRefreshToken(ctx context.Context, token string) (*models.RefreshToken, error) {
	query := map[string]string{
		"token":  fmt.Sprintf("eq.%s", url.QueryEscape(token)),
		"select": "*",
	}

	respData, err := r.client.Select(ctx, "refresh_tokens", query)
	if err != nil {
		return nil, fmt.Errorf("failed to get refresh token: %w", err)
	}

	var tokens []models.RefreshToken
	if err := json.Unmarshal(respData, &tokens); err != nil {
		return nil, fmt.Errorf("failed to parse response: %w", err)
	}

	if len(tokens) == 0 {
		return nil, nil // Return nil, nil when token not found (not an error)
	}

	return &tokens[0], nil
}

func (r *UserRepositorySupabase) DeleteRefreshToken(ctx context.Context, token string) error {
	query := map[string]string{
		"token": fmt.Sprintf("eq.%s", url.QueryEscape(token)),
	}

	err := r.client.Delete(ctx, "refresh_tokens", query)
	if err != nil {
		return fmt.Errorf("failed to delete refresh token: %w", err)
	}

	return nil
}

func (r *UserRepositorySupabase) DeleteUserRefreshTokens(ctx context.Context, userID uuid.UUID) error {
	query := map[string]string{
		"user_id": fmt.Sprintf("eq.%s", userID.String()),
	}

	err := r.client.Delete(ctx, "refresh_tokens", query)
	if err != nil {
		return fmt.Errorf("failed to delete user refresh tokens: %w", err)
	}

	return nil
}

// Legacy methods for backwards compatibility

func (r *UserRepositorySupabase) Create(ctx context.Context, user *models.User) error {
	return r.CreateUser(ctx, user)
}

func (r *UserRepositorySupabase) GetByID(ctx context.Context, id uuid.UUID) (*models.User, error) {
	return r.GetUserByID(ctx, id)
}

func (r *UserRepositorySupabase) GetByEmail(ctx context.Context, email string) (*models.User, error) {
	return r.GetUserByEmail(ctx, email)
}

func (r *UserRepositorySupabase) Update(ctx context.Context, user *models.User) error {
	return r.UpdateUser(ctx, user)
}

func (r *UserRepositorySupabase) CreateRefreshToken(ctx context.Context, token *models.RefreshToken) error {
	return r.StoreRefreshToken(ctx, token)
}

func (r *UserRepositorySupabase) RevokeRefreshToken(ctx context.Context, token string) error {
	return r.DeleteRefreshToken(ctx, token)
}

func (r *UserRepositorySupabase) RevokeAllUserRefreshTokens(ctx context.Context, userID uuid.UUID) error {
	return r.DeleteUserRefreshTokens(ctx, userID)
}

func (r *UserRepositorySupabase) CreatePasswordResetToken(ctx context.Context, token *models.PasswordResetToken) error {
	// Supabase REST API implementation for password reset tokens
	data := map[string]interface{}{
		"id":         token.ID,
		"user_id":    token.UserID,
		"token":      token.Token,
		"expires_at": token.ExpiresAt,
		"used":       false,
	}

	_, err := r.client.Insert(ctx, "password_reset_tokens", data)
	if err != nil {
		return fmt.Errorf("failed to create password reset token: %w", err)
	}

	return nil
}

func (r *UserRepositorySupabase) GetPasswordResetToken(ctx context.Context, token string) (*models.PasswordResetToken, error) {
	query := map[string]string{
		"token":  fmt.Sprintf("eq.%s", url.QueryEscape(token)),
		"used":   "eq.false",
		"select": "*",
	}

	respData, err := r.client.Select(ctx, "password_reset_tokens", query)
	if err != nil {
		return nil, fmt.Errorf("failed to get password reset token: %w", err)
	}

	var tokens []models.PasswordResetToken
	if err := json.Unmarshal(respData, &tokens); err != nil {
		return nil, fmt.Errorf("failed to parse response: %w", err)
	}

	if len(tokens) == 0 {
		return nil, nil
	}

	// Check if token is expired
	if tokens[0].ExpiresAt.Before(time.Now()) {
		return nil, nil
	}

	return &tokens[0], nil
}

func (r *UserRepositorySupabase) MarkPasswordResetTokenUsed(ctx context.Context, token string) error {
	query := map[string]string{
		"token": fmt.Sprintf("eq.%s", url.QueryEscape(token)),
	}

	data := map[string]interface{}{
		"used": true,
	}

	_, err := r.client.Update(ctx, "password_reset_tokens", query, data)
	if err != nil {
		return fmt.Errorf("failed to mark password reset token as used: %w", err)
	}

	return nil
}

func (r *UserRepositorySupabase) SetUserRole(ctx context.Context, userID uuid.UUID, role string) error {
	normalizedRole := normalizeAccountRoleSupabase(role)
	if normalizedRole == "" {
		return fmt.Errorf("invalid role: %s", role)
	}

	query := map[string]string{
		"id": fmt.Sprintf("eq.%s", userID.String()),
	}

	data := map[string]interface{}{
		"account_type": normalizedRole,
	}

	// user_role can be an enum in older schemas, so only write known legacy-safe values.
	switch normalizedRole {
	case "pet_owner", "petowner":
		data["user_role"] = "petowner"
	case "vet":
		data["user_role"] = normalizedRole
	}

	_, err := r.client.Update(ctx, "users", query, data)
	if err != nil {
		return fmt.Errorf("failed to set user role: %w", err)
	}

	if err := r.AddUserRole(ctx, userID, normalizedRole); err != nil && !isMissingUserRolesTable(err) {
		return err
	}

	return nil
}

func (r *UserRepositorySupabase) AddUserRole(ctx context.Context, userID uuid.UUID, role string) error {
	normalizedRole := normalizeAccountRoleSupabase(role)
	if normalizedRole == "" {
		return fmt.Errorf("invalid role: %s", role)
	}

	data := map[string]interface{}{
		"user_id": userID,
		"role":    normalizedRole,
	}

	_, err := r.client.Insert(ctx, "user_roles", data)
	if err != nil {
		message := strings.ToLower(err.Error())
		if strings.Contains(message, "duplicate") || strings.Contains(message, "23505") {
			return nil
		}
		return fmt.Errorf("failed to add user role: %w", err)
	}

	return nil
}

func (r *UserRepositorySupabase) GetUserRoles(ctx context.Context, userID uuid.UUID) ([]string, error) {
	query := map[string]string{
		"user_id": fmt.Sprintf("eq.%s", userID.String()),
		"select":  "role",
	}

	respData, err := r.client.Select(ctx, "user_roles", query)
	if err != nil {
		if isMissingUserRolesTable(err) {
			return r.getLegacyUserRoles(ctx, userID)
		}
		return nil, fmt.Errorf("failed to get user roles: %w", err)
	}

	var rows []struct {
		Role string `json:"role"`
	}

	if err := json.Unmarshal(respData, &rows); err != nil {
		return nil, fmt.Errorf("failed to parse roles response: %w", err)
	}

	roles := make([]string, 0, len(rows))
	for _, row := range rows {
		normalized := normalizeAccountRoleSupabase(row.Role)
		if normalized != "" {
			roles = append(roles, normalized)
		}
	}

	roles = uniqueSortedRolesSupabase(roles)
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

func (r *UserRepositorySupabase) getLegacyUserRoles(ctx context.Context, userID uuid.UUID) ([]string, error) {
	user, err := r.GetUserByID(ctx, userID)
	if err != nil {
		return nil, err
	}
	if user == nil {
		return []string{}, nil
	}

	normalized := normalizeAccountRoleSupabase(user.AccountType)
	if normalized == "" {
		return []string{}, nil
	}

	return []string{normalized}, nil
}

func uniqueSortedRolesSupabase(roles []string) []string {
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
		return []string{}
	}

	sort.Strings(unique)
	return unique
}

func normalizeAccountRoleSupabase(raw string) string {
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

func isMissingUserRolesTable(err error) bool {
	message := strings.ToLower(err.Error())
	return strings.Contains(message, "relation \"user_roles\"") ||
		strings.Contains(message, "table user_roles")
}
