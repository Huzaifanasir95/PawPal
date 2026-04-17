package services

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"

	"pawpal-backend/internal/models"
	"pawpal-backend/internal/repositories"
)

var (
	ErrInvalidCredentials       = errors.New("invalid credentials")
	ErrPasswordLoginUnavailable = errors.New("password login unavailable")
	ErrUserNotFound             = errors.New("user not found")
	ErrUserAlreadyExists        = errors.New("user already exists")
	ErrEmailAlreadyInUse        = errors.New("email already in use")
	ErrInvalidToken             = errors.New("invalid token")
	ErrTokenExpired             = errors.New("token expired")
)

// AuthService handles authentication operations
type AuthService struct {
	userRepo      repositories.UserRepository
	jwtSecret     []byte
	accessExpiry  time.Duration
	refreshExpiry time.Duration
}

// NewAuthService creates a new AuthService
func NewAuthService(userRepo repositories.UserRepository) *AuthService {
	secret := os.Getenv("SUPABASE_JWT_SECRET")
	if secret == "" {
		secret = os.Getenv("JWT_SECRET")
	}
	if secret == "" {
		secret = "pawpal-super-secret-jwt-key-change-in-production"
	}

	return &AuthService{
		userRepo:      userRepo,
		jwtSecret:     []byte(secret),
		accessExpiry:  24 * time.Hour,      // Access token expires in 24 hours
		refreshExpiry: 30 * 24 * time.Hour, // Refresh token expires in 30 days
	}
}

// Claims represents JWT claims
type Claims struct {
	UserID    uuid.UUID `json:"user_id"`
	Email     string    `json:"email"`
	TokenType string    `json:"token_type"`
	jwt.RegisteredClaims
}

// SignUp creates a new user
func (s *AuthService) SignUp(ctx context.Context, req *models.SignUpRequest) (*models.AuthResponse, error) {
	normalizedEmail := strings.ToLower(strings.TrimSpace(req.Email))
	if normalizedEmail == "" {
		return nil, ErrInvalidCredentials
	}

	// Check if user already exists
	existingUser, err := s.userRepo.GetByEmail(ctx, normalizedEmail)
	if err != nil {
		return nil, err
	}
	if existingUser != nil {
		return nil, ErrUserAlreadyExists
	}

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	accountType := "pet_owner"
	if req.AccountType != nil {
		normalized := normalizeAccountType(*req.AccountType)
		if normalized != "" {
			accountType = normalized
		}
	}

	// Create user
	user := &models.User{
		Email:        normalizedEmail,
		PasswordHash: string(hashedPassword),
		DisplayName:  req.DisplayName,
		AccountType:  accountType,
	}

	if err := s.userRepo.Create(ctx, user); err != nil {
		return nil, err
	}

	// Generate tokens
	accessToken, err := s.generateAccessToken(user)
	if err != nil {
		return nil, err
	}

	refreshToken, err := s.generateRefreshToken(ctx, user.ID)
	if err != nil {
		return nil, err
	}

	return &models.AuthResponse{
		Success:      true,
		Message:      "User created successfully",
		User:         s.buildUserProfile(ctx, user),
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		ExpiresIn:    int64(s.accessExpiry.Seconds()),
	}, nil
}

// SignIn authenticates a user
func (s *AuthService) SignIn(ctx context.Context, req *models.SignInRequest) (*models.AuthResponse, error) {
	normalizedEmail := strings.ToLower(strings.TrimSpace(req.Email))
	if normalizedEmail == "" {
		return nil, ErrInvalidCredentials
	}

	// Get user by email
	user, err := s.userRepo.GetByEmail(ctx, normalizedEmail)
	if err != nil {
		return nil, err
	}
	if user == nil {
		return nil, ErrInvalidCredentials
	}

	// Check if user is active
	if !user.IsActive {
		return nil, ErrInvalidCredentials
	}

	if strings.TrimSpace(user.PasswordHash) == "" {
		return nil, ErrPasswordLoginUnavailable
	}

	// Verify password
	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)); err != nil {
		return nil, ErrInvalidCredentials
	}

	// Generate tokens
	accessToken, err := s.generateAccessToken(user)
	if err != nil {
		return nil, err
	}

	refreshToken, err := s.generateRefreshToken(ctx, user.ID)
	if err != nil {
		return nil, err
	}

	return &models.AuthResponse{
		Success:      true,
		Message:      "Login successful",
		User:         s.buildUserProfile(ctx, user),
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		ExpiresIn:    int64(s.accessExpiry.Seconds()),
	}, nil
}

// RefreshToken refreshes an access token
func (s *AuthService) RefreshToken(ctx context.Context, refreshTokenStr string) (*models.AuthResponse, error) {
	// Get refresh token from database
	refreshToken, err := s.userRepo.GetRefreshToken(ctx, refreshTokenStr)
	if err != nil {
		return nil, err
	}
	if refreshToken == nil {
		return nil, ErrInvalidToken
	}

	// Get user
	user, err := s.userRepo.GetByID(ctx, refreshToken.UserID)
	if err != nil {
		return nil, err
	}
	if user == nil || !user.IsActive {
		return nil, ErrUserNotFound
	}

	// Revoke old refresh token
	if err := s.userRepo.RevokeRefreshToken(ctx, refreshTokenStr); err != nil {
		return nil, err
	}

	// Generate new tokens
	accessToken, err := s.generateAccessToken(user)
	if err != nil {
		return nil, err
	}

	newRefreshToken, err := s.generateRefreshToken(ctx, user.ID)
	if err != nil {
		return nil, err
	}

	return &models.AuthResponse{
		Success:      true,
		Message:      "Token refreshed successfully",
		User:         s.buildUserProfile(ctx, user),
		AccessToken:  accessToken,
		RefreshToken: newRefreshToken,
		ExpiresIn:    int64(s.accessExpiry.Seconds()),
	}, nil
}

// SignOut signs out a user by revoking their refresh token
func (s *AuthService) SignOut(ctx context.Context, refreshTokenStr string) error {
	return s.userRepo.RevokeRefreshToken(ctx, refreshTokenStr)
}

// SignOutAll signs out a user from all devices
func (s *AuthService) SignOutAll(ctx context.Context, userID uuid.UUID) error {
	return s.userRepo.RevokeAllUserRefreshTokens(ctx, userID)
}

// RequestPasswordReset creates a password reset token
func (s *AuthService) RequestPasswordReset(ctx context.Context, email string) (string, error) {
	user, err := s.userRepo.GetByEmail(ctx, email)
	if err != nil {
		return "", err
	}
	if user == nil {
		// Don't reveal if user exists
		return "", nil
	}

	// Generate reset token
	tokenBytes := make([]byte, 32)
	if _, err := rand.Read(tokenBytes); err != nil {
		return "", err
	}
	token := hex.EncodeToString(tokenBytes)

	resetToken := &models.PasswordResetToken{
		UserID:    user.ID,
		Token:     token,
		ExpiresAt: time.Now().Add(1 * time.Hour), // Expires in 1 hour
	}

	if err := s.userRepo.CreatePasswordResetToken(ctx, resetToken); err != nil {
		return "", err
	}

	return token, nil
}

// ResetPassword resets a user's password
func (s *AuthService) ResetPassword(ctx context.Context, token string, newPassword string) error {
	// Get reset token
	resetToken, err := s.userRepo.GetPasswordResetToken(ctx, token)
	if err != nil {
		return err
	}
	if resetToken == nil {
		return ErrInvalidToken
	}

	// Hash new password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(newPassword), bcrypt.DefaultCost)
	if err != nil {
		return err
	}

	// Update password
	if err := s.userRepo.UpdatePassword(ctx, resetToken.UserID, string(hashedPassword)); err != nil {
		return err
	}

	// Mark token as used
	if err := s.userRepo.MarkPasswordResetTokenUsed(ctx, token); err != nil {
		return err
	}

	// Revoke all refresh tokens for security
	return s.userRepo.RevokeAllUserRefreshTokens(ctx, resetToken.UserID)
}

// ValidateAccessToken validates an access token and returns the claims
func (s *AuthService) ValidateAccessToken(tokenStr string) (*Claims, error) {
	token, err := jwt.ParseWithClaims(tokenStr, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		return s.jwtSecret, nil
	})

	if err != nil {
		return nil, err
	}

	if claims, ok := token.Claims.(*Claims); ok && token.Valid {
		if claims.TokenType != "access" {
			return nil, ErrInvalidToken
		}
		return claims, nil
	}

	return nil, ErrInvalidToken
}

// GetUserByID gets a user by ID
func (s *AuthService) GetUserByID(ctx context.Context, id uuid.UUID) (*models.User, error) {
	return s.userRepo.GetByID(ctx, id)
}

// UpdateUser updates a user's profile
func (s *AuthService) UpdateUser(ctx context.Context, user *models.User) error {
	return s.userRepo.Update(ctx, user)
}

// UpdateEmailWithPassword updates user email after verifying current password.
func (s *AuthService) UpdateEmailWithPassword(ctx context.Context, userID uuid.UUID, newEmail, currentPassword string) (*models.User, error) {
	normalizedEmail := strings.ToLower(strings.TrimSpace(newEmail))
	if normalizedEmail == "" {
		return nil, ErrInvalidCredentials
	}

	user, err := s.userRepo.GetByID(ctx, userID)
	if err != nil {
		return nil, err
	}
	if user == nil {
		return nil, ErrUserNotFound
	}

	if strings.TrimSpace(user.PasswordHash) == "" {
		return nil, ErrPasswordLoginUnavailable
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(currentPassword)); err != nil {
		return nil, ErrInvalidCredentials
	}

	if strings.EqualFold(user.Email, normalizedEmail) {
		return user, nil
	}

	existingUser, err := s.userRepo.GetByEmail(ctx, normalizedEmail)
	if err != nil {
		return nil, err
	}
	if existingUser != nil && existingUser.ID != userID {
		return nil, ErrEmailAlreadyInUse
	}

	user.Email = normalizedEmail
	if err := s.userRepo.Update(ctx, user); err != nil {
		return nil, err
	}

	return user, nil
}

// UpdatePasswordWithCurrent verifies the current password before changing it.
func (s *AuthService) UpdatePasswordWithCurrent(ctx context.Context, userID uuid.UUID, currentPassword, newPassword string) error {
	user, err := s.userRepo.GetByID(ctx, userID)
	if err != nil {
		return err
	}
	if user == nil {
		return ErrUserNotFound
	}

	if strings.TrimSpace(user.PasswordHash) == "" {
		return ErrPasswordLoginUnavailable
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(currentPassword)); err != nil {
		return ErrInvalidCredentials
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(newPassword), bcrypt.DefaultCost)
	if err != nil {
		return err
	}

	if err := s.userRepo.UpdatePassword(ctx, userID, string(hashedPassword)); err != nil {
		return err
	}

	return s.userRepo.RevokeAllUserRefreshTokens(ctx, userID)
}

// SetUserRole sets the user's role (petowner or vet)
func (s *AuthService) SetUserRole(ctx context.Context, userID uuid.UUID, role string) error {
	return s.userRepo.SetUserRole(ctx, userID, role)
}

// GetUserRoles returns all assigned roles for the given user.
func (s *AuthService) GetUserRoles(ctx context.Context, userID uuid.UUID) ([]string, error) {
	roles, err := s.userRepo.GetUserRoles(ctx, userID)
	if err != nil {
		return nil, err
	}

	if len(roles) == 0 {
		user, userErr := s.userRepo.GetByID(ctx, userID)
		if userErr != nil {
			return nil, userErr
		}

		if user != nil {
			if normalized := normalizeAccountType(user.AccountType); normalized != "" {
				return []string{normalized}, nil
			}
		}

		return []string{}, nil
	}

	user, userErr := s.userRepo.GetByID(ctx, userID)
	if userErr == nil && user != nil {
		activeRole := normalizeAccountType(user.AccountType)
		if activeRole != "" {
			containsActive := false
			for _, role := range roles {
				if normalizeAccountType(role) == activeRole {
					containsActive = true
					break
				}
			}

			if !containsActive {
				roles = append(roles, activeRole)
			}
		}
	}

	return roles, nil
}

// AddUserRole assigns an additional role to the user without switching active role.
func (s *AuthService) AddUserRole(ctx context.Context, userID uuid.UUID, role string) ([]string, error) {
	normalized := normalizeAccountType(role)
	if normalized == "" {
		return nil, fmt.Errorf("invalid role")
	}

	if err := s.userRepo.AddUserRole(ctx, userID, normalized); err != nil {
		if !isMissingUserRolesStorageError(err) {
			return nil, err
		}

		if err := s.userRepo.SetUserRole(ctx, userID, normalized); err != nil {
			return nil, err
		}
	}

	roles, err := s.userRepo.GetUserRoles(ctx, userID)
	if err != nil {
		return nil, err
	}

	if len(roles) == 0 {
		roles = []string{normalized}
	}

	return roles, nil
}

// SwitchActiveRole validates ownership of a role and switches account_type to that role.
func (s *AuthService) SwitchActiveRole(ctx context.Context, userID uuid.UUID, role string) ([]string, error) {
	normalized := normalizeAccountType(role)
	if normalized == "" {
		return nil, fmt.Errorf("invalid role")
	}

	roles, err := s.userRepo.GetUserRoles(ctx, userID)
	if err != nil {
		return nil, err
	}

	if len(roles) == 0 {
		user, userErr := s.userRepo.GetByID(ctx, userID)
		if userErr != nil {
			return nil, userErr
		}

		if user != nil {
			if normalized := normalizeAccountType(user.AccountType); normalized != "" {
				roles = []string{normalized}
			}
		}
	}

	if len(roles) == 0 {
		return nil, fmt.Errorf("no roles assigned to user")
	}

	hasRole := false
	for _, assigned := range roles {
		if normalizeAccountType(assigned) == normalized {
			hasRole = true
			break
		}
	}

	if !hasRole {
		return nil, fmt.Errorf("role is not assigned to user")
	}

	if err := s.userRepo.SetUserRole(ctx, userID, normalized); err != nil {
		return nil, err
	}

	return roles, nil
}

func (s *AuthService) buildUserProfile(ctx context.Context, user *models.User) *models.UserProfile {
	activeRole := normalizeAccountType(user.AccountType)

	roles, err := s.userRepo.GetUserRoles(ctx, user.ID)
	if err != nil {
		roles = []string{}
	}

	if len(roles) == 0 && activeRole != "" {
		roles = []string{activeRole}
	}

	if activeRole != "" {
		containsActive := false
		for _, role := range roles {
			if normalizeAccountType(role) == activeRole {
				containsActive = true
				break
			}
		}

		if !containsActive {
			roles = append(roles, activeRole)
		}
	}

	var accountType *string
	var activeRolePtr *string
	if activeRole != "" {
		accountType = &activeRole
		activeRolePtr = &activeRole
	}

	return &models.UserProfile{
		ID:          user.ID,
		Email:       user.Email,
		DisplayName: user.DisplayName,
		AccountType: accountType,
		Roles:       roles,
		ActiveRole:  activeRolePtr,
		AvatarURL:   user.AvatarURL,
		CreatedAt:   user.CreatedAt,
		UpdatedAt:   user.UpdatedAt,
	}
}

// Helper functions

func (s *AuthService) generateAccessToken(user *models.User) (string, error) {
	claims := &Claims{
		UserID:    user.ID,
		Email:     user.Email,
		TokenType: "access",
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(s.accessExpiry)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Issuer:    "pawpal-api",
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(s.jwtSecret)
}

func (s *AuthService) generateRefreshToken(ctx context.Context, userID uuid.UUID) (string, error) {
	// Generate random token
	tokenBytes := make([]byte, 32)
	if _, err := rand.Read(tokenBytes); err != nil {
		return "", err
	}
	token := hex.EncodeToString(tokenBytes)

	refreshToken := &models.RefreshToken{
		UserID:    userID,
		Token:     token,
		ExpiresAt: time.Now().Add(s.refreshExpiry),
	}

	if err := s.userRepo.CreateRefreshToken(ctx, refreshToken); err != nil {
		return "", err
	}

	return token, nil
}

// GoogleTokenInfo represents the response from Google's tokeninfo endpoint
type GoogleTokenInfo struct {
	Iss           string `json:"iss"`
	Azp           string `json:"azp"`
	Aud           string `json:"aud"`
	Sub           string `json:"sub"`
	Email         string `json:"email"`
	EmailVerified string `json:"email_verified"`
	Name          string `json:"name"`
	Picture       string `json:"picture"`
	GivenName     string `json:"given_name"`
	FamilyName    string `json:"family_name"`
	Locale        string `json:"locale"`
	Iat           string `json:"iat"`
	Exp           string `json:"exp"`
	Alg           string `json:"alg"`
	Kid           string `json:"kid"`
	Typ           string `json:"typ"`
}

// SignInWithGoogle authenticates a user with Google ID token
func (s *AuthService) SignInWithGoogle(ctx context.Context, req *models.GoogleSignInRequest) (*models.AuthResponse, error) {
	// Verify the Google ID token
	tokenInfo, err := s.verifyGoogleIDToken(req.IDToken)
	if err != nil {
		return nil, fmt.Errorf("invalid Google token: %w", err)
	}

	normalizedGoogleEmail := strings.ToLower(strings.TrimSpace(tokenInfo.Email))
	if normalizedGoogleEmail == "" {
		return nil, fmt.Errorf("google account email is missing")
	}

	// Check if user exists
	user, err := s.userRepo.GetByEmail(ctx, normalizedGoogleEmail)
	if err != nil {
		return nil, err
	}

	isNewUser := false
	if user == nil {
		// For new users, check if account type is provided
		if req.AccountType == nil || *req.AccountType == "" {
			// Return response indicating user needs to select account type
			return &models.AuthResponse{
				Success:   true,
				Message:   "Account type required for new user",
				IsNewUser: true,
				User: &models.UserProfile{
					Email:       normalizedGoogleEmail,
					DisplayName: &tokenInfo.Name,
					AvatarURL:   &tokenInfo.Picture,
				},
			}, nil
		}

		// Create new user with Google info and selected account type
		accountType := normalizeAccountType(*req.AccountType)
		if accountType == "" {
			accountType = "pet_owner"
		}

		user = &models.User{
			Email:         normalizedGoogleEmail,
			DisplayName:   &tokenInfo.Name,
			AvatarURL:     &tokenInfo.Picture,
			PasswordHash:  "", // No password for Google users
			AccountType:   accountType,
			IsActive:      true,
			EmailVerified: tokenInfo.EmailVerified == "true",
			GoogleID:      &tokenInfo.Sub,
		}

		if req.DisplayName != nil && *req.DisplayName != "" {
			user.DisplayName = req.DisplayName
		}
		if req.PhotoURL != nil && *req.PhotoURL != "" {
			user.AvatarURL = req.PhotoURL
		}

		if err := s.userRepo.Create(ctx, user); err != nil {
			return nil, err
		}
		isNewUser = true
	} else {
		// Update existing user with Google info if needed
		needsUpdate := false
		if user.GoogleID == nil || *user.GoogleID != tokenInfo.Sub {
			user.GoogleID = &tokenInfo.Sub
			needsUpdate = true
		}
		if user.AvatarURL == nil && tokenInfo.Picture != "" {
			user.AvatarURL = &tokenInfo.Picture
			needsUpdate = true
		}
		if !user.EmailVerified && tokenInfo.EmailVerified == "true" {
			user.EmailVerified = true
			needsUpdate = true
		}

		if needsUpdate {
			if err := s.userRepo.Update(ctx, user); err != nil {
				return nil, err
			}
		}
	}

	// Generate tokens
	accessToken, err := s.generateAccessToken(user)
	if err != nil {
		return nil, err
	}

	refreshToken, err := s.generateRefreshToken(ctx, user.ID)
	if err != nil {
		return nil, err
	}

	return &models.AuthResponse{
		Success:      true,
		Message:      "Google sign in successful",
		User:         s.buildUserProfile(ctx, user),
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		ExpiresIn:    int64(s.accessExpiry.Seconds()),
		IsNewUser:    isNewUser,
	}, nil
}

// verifyGoogleIDToken verifies a Google ID token
func (s *AuthService) verifyGoogleIDToken(idToken string) (*GoogleTokenInfo, error) {
	// Verify token with Google's tokeninfo endpoint
	resp, err := http.Get(fmt.Sprintf("https://oauth2.googleapis.com/tokeninfo?id_token=%s", idToken))
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("google token verification failed with status: %d", resp.StatusCode)
	}

	var tokenInfo GoogleTokenInfo
	if err := json.NewDecoder(resp.Body).Decode(&tokenInfo); err != nil {
		return nil, err
	}

	// Verify the token is from Google
	if tokenInfo.Iss != "accounts.google.com" && tokenInfo.Iss != "https://accounts.google.com" {
		return nil, fmt.Errorf("invalid token issuer")
	}

	// Optionally verify the audience matches your client ID
	// googleClientID := os.Getenv("GOOGLE_CLIENT_ID")
	// if googleClientID != "" && tokenInfo.Aud != googleClientID {
	// 	return nil, fmt.Errorf("invalid token audience")
	// }

	return &tokenInfo, nil
}

func normalizeAccountType(raw string) string {
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

func isMissingUserRolesStorageError(err error) bool {
	if err == nil {
		return false
	}

	message := strings.ToLower(err.Error())
	if !strings.Contains(message, "user_roles") {
		return false
	}

	return strings.Contains(message, "relation") ||
		strings.Contains(message, "table") ||
		strings.Contains(message, "42p01")
}
