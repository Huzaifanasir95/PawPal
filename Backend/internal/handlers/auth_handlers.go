package handlers

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"

	"pawpal-backend/internal/models"
	"pawpal-backend/internal/services"
)

// AuthHandlers handles authentication endpoints
type AuthHandlers struct {
	authService *services.AuthService
}

// NewAuthHandlers creates new AuthHandlers
func NewAuthHandlers(authService *services.AuthService) *AuthHandlers {
	return &AuthHandlers{
		authService: authService,
	}
}

// SignUp handles user registration
func (h *AuthHandlers) SignUp(c *gin.Context) {
	var req models.SignUpRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.AuthResponse{
			Success: false,
			Message: "Invalid request: " + err.Error(),
		})
		return
	}

	response, err := h.authService.SignUp(c.Request.Context(), &req)
	if err != nil {
		status := http.StatusInternalServerError
		if err == services.ErrUserAlreadyExists {
			status = http.StatusConflict
		}
		c.JSON(status, models.AuthResponse{
			Success: false,
			Message: err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, response)
}

// SignIn handles user login
func (h *AuthHandlers) SignIn(c *gin.Context) {
	var req models.SignInRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.AuthResponse{
			Success: false,
			Message: "Invalid request: " + err.Error(),
		})
		return
	}

	response, err := h.authService.SignIn(c.Request.Context(), &req)
	if err != nil {
		status := http.StatusInternalServerError
		message := "Invalid email or password"
		if err == services.ErrInvalidCredentials {
			status = http.StatusUnauthorized
		}
		if err == services.ErrPasswordLoginUnavailable {
			status = http.StatusUnauthorized
			message = "This account uses Google sign-in. Use Google sign-in or reset password first"
		}
		c.JSON(status, models.AuthResponse{
			Success: false,
			Message: message,
		})
		return
	}

	c.JSON(http.StatusOK, response)
}

// SignInWithGoogle handles Google OAuth sign-in
func (h *AuthHandlers) SignInWithGoogle(c *gin.Context) {
	var req models.GoogleSignInRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.AuthResponse{
			Success: false,
			Message: "Invalid request: " + err.Error(),
		})
		return
	}

	response, err := h.authService.SignInWithGoogle(c.Request.Context(), &req)
	if err != nil {
		c.JSON(http.StatusUnauthorized, models.AuthResponse{
			Success: false,
			Message: "Google authentication failed: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, response)
}

// RefreshToken handles token refresh
func (h *AuthHandlers) RefreshToken(c *gin.Context) {
	var req models.RefreshTokenRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.AuthResponse{
			Success: false,
			Message: "Invalid request: " + err.Error(),
		})
		return
	}

	response, err := h.authService.RefreshToken(c.Request.Context(), req.RefreshToken)
	if err != nil {
		status := http.StatusInternalServerError
		if err == services.ErrInvalidToken {
			status = http.StatusUnauthorized
		}
		c.JSON(status, models.AuthResponse{
			Success: false,
			Message: "Invalid or expired refresh token",
		})
		return
	}

	c.JSON(http.StatusOK, response)
}

// SignOut handles user logout
func (h *AuthHandlers) SignOut(c *gin.Context) {
	// Try to get refresh token from request body (optional)
	var req struct {
		RefreshToken string `json:"refreshToken"`
	}
	_ = c.ShouldBindJSON(&req)

	// If refresh token provided, revoke it specifically
	if req.RefreshToken != "" {
		if err := h.authService.SignOut(c.Request.Context(), req.RefreshToken); err != nil {
			// Log error but don't fail - continue with clearing client tokens
			c.JSON(http.StatusOK, models.GenericResponse{
				Success: true,
				Message: "Signed out successfully",
			})
			return
		}
	}

	// Optionally: Sign out from all devices using user ID from JWT
	userIDStr, exists := c.Get("userID")
	if exists {
		userID := parseUUID(userIDStr.(string))
		_ = h.authService.SignOutAll(c.Request.Context(), userID)
	}

	c.JSON(http.StatusOK, models.GenericResponse{
		Success: true,
		Message: "Signed out successfully",
	})
}

// RequestPasswordReset handles password reset request
func (h *AuthHandlers) RequestPasswordReset(c *gin.Context) {
	var req models.PasswordResetRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.GenericResponse{
			Success: false,
			Message: "Invalid request: " + err.Error(),
		})
		return
	}

	token, err := h.authService.RequestPasswordReset(c.Request.Context(), req.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.GenericResponse{
			Success: false,
			Message: "Failed to process password reset request",
		})
		return
	}

	// In production, send email with reset link instead of returning token
	// For development, we return the token
	c.JSON(http.StatusOK, models.GenericResponse{
		Success: true,
		Message: "If an account exists with that email, a password reset link has been sent",
		Data:    map[string]string{"reset_token": token}, // Remove in production
	})
}

// ResetPassword handles password reset confirmation
func (h *AuthHandlers) ResetPassword(c *gin.Context) {
	var req models.PasswordResetConfirmRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.GenericResponse{
			Success: false,
			Message: "Invalid request: " + err.Error(),
		})
		return
	}

	if err := h.authService.ResetPassword(c.Request.Context(), req.Token, req.NewPassword); err != nil {
		status := http.StatusInternalServerError
		if err == services.ErrInvalidToken {
			status = http.StatusBadRequest
		}
		c.JSON(status, models.GenericResponse{
			Success: false,
			Message: "Invalid or expired reset token",
		})
		return
	}

	c.JSON(http.StatusOK, models.GenericResponse{
		Success: true,
		Message: "Password reset successfully",
	})
}

// GetProfile handles getting current user profile
func (h *AuthHandlers) GetProfile(c *gin.Context) {
	userID := c.MustGet("userID").(string)

	// Parse UUID
	user, err := h.authService.GetUserByID(c.Request.Context(), parseUUID(userID))
	if err != nil || user == nil {
		c.JSON(http.StatusNotFound, models.GenericResponse{
			Success: false,
			Message: "User not found",
		})
		return
	}

	c.JSON(http.StatusOK, models.GenericResponse{
		Success: true,
		Data:    h.buildUserProfile(c, user),
	})
}

// UpdateProfile handles updating user profile
func (h *AuthHandlers) UpdateProfile(c *gin.Context) {
	userID := c.MustGet("userID").(string)

	var req models.UpdateProfileRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.GenericResponse{
			Success: false,
			Message: "Invalid request: " + err.Error(),
		})
		return
	}

	user, err := h.authService.GetUserByID(c.Request.Context(), parseUUID(userID))
	if err != nil || user == nil {
		c.JSON(http.StatusNotFound, models.GenericResponse{
			Success: false,
			Message: "User not found",
		})
		return
	}

	// Update fields
	if req.DisplayName != nil {
		user.DisplayName = req.DisplayName
	}
	if req.AccountType != nil {
		normalizedRole := normalizeAccountType(*req.AccountType)
		if normalizedRole == "" {
			c.JSON(http.StatusBadRequest, models.GenericResponse{
				Success: false,
				Message: "Invalid account type",
			})
			return
		}

		if _, err := h.authService.AddUserRole(c.Request.Context(), user.ID, normalizedRole); err != nil {
			c.JSON(http.StatusInternalServerError, models.GenericResponse{
				Success: false,
				Message: "Failed to assign account role",
			})
			return
		}
		user.AccountType = normalizedRole
	}
	if req.AvatarURL != nil {
		user.AvatarURL = req.AvatarURL
	}

	if err := h.authService.UpdateUser(c.Request.Context(), user); err != nil {
		c.JSON(http.StatusInternalServerError, models.GenericResponse{
			Success: false,
			Message: "Failed to update profile",
		})
		return
	}

	c.JSON(http.StatusOK, models.GenericResponse{
		Success: true,
		Message: "Profile updated successfully",
		Data:    h.buildUserProfile(c, user),
	})
}

// UpdateEmail handles secure email updates by validating current password.
func (h *AuthHandlers) UpdateEmail(c *gin.Context) {
	userID := c.MustGet("userID").(string)

	var req models.UpdateEmailRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.GenericResponse{
			Success: false,
			Message: "Invalid request: " + err.Error(),
		})
		return
	}

	updatedUser, err := h.authService.UpdateEmailWithPassword(
		c.Request.Context(),
		parseUUID(userID),
		req.NewEmail,
		req.CurrentPassword,
	)
	if err != nil {
		switch err {
		case services.ErrInvalidCredentials:
			c.JSON(http.StatusUnauthorized, models.GenericResponse{Success: false, Message: "Current password is incorrect"})
			return
		case services.ErrPasswordLoginUnavailable:
			c.JSON(http.StatusBadRequest, models.GenericResponse{Success: false, Message: "This account does not have a password yet"})
			return
		case services.ErrEmailAlreadyInUse:
			c.JSON(http.StatusConflict, models.GenericResponse{Success: false, Message: "Email is already in use"})
			return
		case services.ErrUserNotFound:
			c.JSON(http.StatusNotFound, models.GenericResponse{Success: false, Message: "User not found"})
			return
		default:
			c.JSON(http.StatusInternalServerError, models.GenericResponse{Success: false, Message: "Failed to update email"})
			return
		}
	}

	c.JSON(http.StatusOK, models.GenericResponse{
		Success: true,
		Message: "Email updated successfully",
		Data:    h.buildUserProfile(c, updatedUser),
	})
}

// UpdatePassword handles secure password updates.
func (h *AuthHandlers) UpdatePassword(c *gin.Context) {
	userID := c.MustGet("userID").(string)

	var req models.UpdatePasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.GenericResponse{
			Success: false,
			Message: "Invalid request: " + err.Error(),
		})
		return
	}

	if strings.TrimSpace(req.NewPassword) == strings.TrimSpace(req.CurrentPassword) {
		c.JSON(http.StatusBadRequest, models.GenericResponse{
			Success: false,
			Message: "New password must be different from current password",
		})
		return
	}

	err := h.authService.UpdatePasswordWithCurrent(
		c.Request.Context(),
		parseUUID(userID),
		req.CurrentPassword,
		req.NewPassword,
	)
	if err != nil {
		switch err {
		case services.ErrInvalidCredentials:
			c.JSON(http.StatusUnauthorized, models.GenericResponse{Success: false, Message: "Current password is incorrect"})
			return
		case services.ErrPasswordLoginUnavailable:
			c.JSON(http.StatusBadRequest, models.GenericResponse{Success: false, Message: "This account does not have a password yet"})
			return
		case services.ErrUserNotFound:
			c.JSON(http.StatusNotFound, models.GenericResponse{Success: false, Message: "User not found"})
			return
		default:
			c.JSON(http.StatusInternalServerError, models.GenericResponse{Success: false, Message: "Failed to update password"})
			return
		}
	}

	c.JSON(http.StatusOK, models.GenericResponse{
		Success: true,
		Message: "Password updated successfully. Please sign in again on other devices.",
	})
}

// SetUserRole sets the user's account type/role.
func (h *AuthHandlers) SetUserRole(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.GenericResponse{
			Success: false,
			Message: "User not authenticated",
		})
		return
	}

	var req struct {
		Role string `json:"role" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.GenericResponse{
			Success: false,
			Message: "Invalid request: " + err.Error(),
		})
		return
	}

	normalizedRole := normalizeAccountType(req.Role)

	// Validate role
	if normalizedRole == "" {
		c.JSON(http.StatusBadRequest, models.GenericResponse{
			Success: false,
			Message: "Invalid role. Must be one of: pet_owner, vet, seller, caregiver",
		})
		return
	}

	user, err := h.authService.GetUserByID(c.Request.Context(), parseUUID(userID.(string)))
	if err != nil || user == nil {
		c.JSON(http.StatusNotFound, models.GenericResponse{
			Success: false,
			Message: "User not found",
		})
		return
	}

	// Update user role
	if _, err := h.authService.AddUserRole(c.Request.Context(), user.ID, normalizedRole); err != nil {
		c.JSON(http.StatusInternalServerError, models.GenericResponse{
			Success: false,
			Message: "Failed to assign user role",
		})
		return
	}

	if _, err := h.authService.SwitchActiveRole(c.Request.Context(), user.ID, normalizedRole); err != nil {
		c.JSON(http.StatusInternalServerError, models.GenericResponse{
			Success: false,
			Message: "Failed to set user role",
		})
		return
	}

	c.JSON(http.StatusOK, models.GenericResponse{
		Success: true,
		Message: "User role set successfully",
		Data: gin.H{
			"userId":     user.ID,
			"role":       normalizedRole,
			"activeRole": normalizedRole,
		},
	})
}

// GetUserRoles returns all assigned roles for the authenticated user.
func (h *AuthHandlers) GetUserRoles(c *gin.Context) {
	userID := parseUUID(c.MustGet("userID").(string))

	user, err := h.authService.GetUserByID(c.Request.Context(), userID)
	if err != nil || user == nil {
		c.JSON(http.StatusNotFound, models.GenericResponse{
			Success: false,
			Message: "User not found",
		})
		return
	}

	roles, err := h.authService.GetUserRoles(c.Request.Context(), user.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.GenericResponse{
			Success: false,
			Message: "Failed to load user roles",
		})
		return
	}

	activeRole := normalizeAccountType(user.AccountType)
	if activeRole == "" {
		if len(roles) > 0 {
			activeRole = normalizeAccountType(roles[0])
		}
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

	data := gin.H{
		"userId": user.ID,
		"roles":  roles,
	}
	if activeRole != "" {
		data["activeRole"] = activeRole
	}

	c.JSON(http.StatusOK, models.GenericResponse{
		Success: true,
		Data:    data,
	})
}

// AddUserRole assigns an additional role to the authenticated user.
func (h *AuthHandlers) AddUserRole(c *gin.Context) {
	userID := parseUUID(c.MustGet("userID").(string))

	var req models.AddRoleRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.GenericResponse{
			Success: false,
			Message: "Invalid request: " + err.Error(),
		})
		return
	}

	normalizedRole := normalizeAccountType(req.Role)
	if normalizedRole == "" {
		c.JSON(http.StatusBadRequest, models.GenericResponse{
			Success: false,
			Message: "Invalid role. Must be one of: pet_owner, vet, seller, caregiver",
		})
		return
	}

	roles, err := h.authService.AddUserRole(c.Request.Context(), userID, normalizedRole)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.GenericResponse{
			Success: false,
			Message: "Failed to add role: " + err.Error(),
		})
		return
	}

	user, _ := h.authService.GetUserByID(c.Request.Context(), userID)
	activeRole := normalizedRole
	if user != nil {
		if normalized := normalizeAccountType(user.AccountType); normalized != "" {
			activeRole = normalized
		} else if len(roles) > 0 {
			if normalizedFromRoles := normalizeAccountType(roles[0]); normalizedFromRoles != "" {
				activeRole = normalizedFromRoles
			}
		}
	}

	c.JSON(http.StatusOK, models.GenericResponse{
		Success: true,
		Message: "Role added successfully",
		Data: gin.H{
			"roles":      roles,
			"activeRole": activeRole,
		},
	})
}

// SwitchActiveRole switches the user's active role after backend validation.
func (h *AuthHandlers) SwitchActiveRole(c *gin.Context) {
	userID := parseUUID(c.MustGet("userID").(string))

	var req models.SwitchRoleRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.GenericResponse{
			Success: false,
			Message: "Invalid request: " + err.Error(),
		})
		return
	}

	normalizedRole := normalizeAccountType(req.Role)
	if normalizedRole == "" {
		c.JSON(http.StatusBadRequest, models.GenericResponse{
			Success: false,
			Message: "Invalid role. Must be one of: pet_owner, vet, seller, caregiver",
		})
		return
	}

	roles, err := h.authService.SwitchActiveRole(c.Request.Context(), userID, normalizedRole)
	if err != nil {
		lowerErr := strings.ToLower(err.Error())
		if strings.Contains(lowerErr, "not assigned") || strings.Contains(lowerErr, "no roles assigned") {
			c.JSON(http.StatusForbidden, models.GenericResponse{
				Success: false,
				Message: "Role is not assigned to this user",
			})
			return
		}

		c.JSON(http.StatusInternalServerError, models.GenericResponse{
			Success: false,
			Message: "Failed to switch role",
		})
		return
	}

	c.JSON(http.StatusOK, models.GenericResponse{
		Success: true,
		Message: "Active role switched",
		Data: gin.H{
			"roles":      roles,
			"activeRole": normalizedRole,
		},
	})
}

func (h *AuthHandlers) buildUserProfile(c *gin.Context, user *models.User) *models.UserProfile {
	activeRole := normalizeAccountType(user.AccountType)

	roles, err := h.authService.GetUserRoles(c.Request.Context(), user.ID)
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

// normalizeAccountType converts supported role/account aliases into canonical values.
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
