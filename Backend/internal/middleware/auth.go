package middleware

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"

	"pawpal-backend/internal/models"
	"pawpal-backend/internal/services"
)

// AuthMiddleware creates an authentication middleware
func AuthMiddleware(authService *services.AuthService) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Get Authorization header
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, models.GenericResponse{
				Success: false,
				Message: "Authorization header is required",
			})
			return
		}

		// Check Bearer token format
		parts := strings.Split(authHeader, " ")
		if len(parts) != 2 || strings.ToLower(parts[0]) != "bearer" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, models.GenericResponse{
				Success: false,
				Message: "Invalid authorization header format. Use 'Bearer <token>'",
			})
			return
		}

		tokenStr := parts[1]

		// Validate token
		claims, err := authService.ValidateAccessToken(tokenStr)
		if err != nil {
			c.AbortWithStatusJSON(http.StatusUnauthorized, models.GenericResponse{
				Success: false,
				Message: "Invalid or expired token",
			})
			return
		}

		// Set user info in context
		c.Set("userID", claims.UserID.String())
		c.Set("email", claims.Email)

		c.Next()
	}
}

// OptionalAuthMiddleware creates an optional authentication middleware
// It will set user info if token is valid, but won't block if not present
func OptionalAuthMiddleware(authService *services.AuthService) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Get Authorization header
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.Next()
			return
		}

		// Check Bearer token format
		parts := strings.Split(authHeader, " ")
		if len(parts) != 2 || strings.ToLower(parts[0]) != "bearer" {
			c.Next()
			return
		}

		tokenStr := parts[1]

		// Validate token
		claims, err := authService.ValidateAccessToken(tokenStr)
		if err != nil {
			c.Next()
			return
		}

		// Set user info in context
		c.Set("userID", claims.UserID.String())
		c.Set("email", claims.Email)

		c.Next()
	}
}
