package handlers

import (
	"net/http"
	"os"
	"regexp"
	"strings"

	"pawpal-backend/internal/models"
	"pawpal-backend/internal/repositories"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type PaymentMethodHandler struct {
	repo      *repositories.PaymentMethodRepository
	userRepo  repositories.UserRepository
	demoMode  bool
}

func NewPaymentMethodHandler(repo *repositories.PaymentMethodRepository, userRepo repositories.UserRepository, demoMode bool) *PaymentMethodHandler {
	return &PaymentMethodHandler{repo: repo, userRepo: userRepo, demoMode: demoMode}
}

func (h *PaymentMethodHandler) ListPaymentMethods(c *gin.Context) {
	userID, ok := getAuthUserID(c)
	if !ok {
		return
	}

	methods, err := h.repo.ListByUser(c.Request.Context(), userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to load payment methods"})
		return
	}

	if methods == nil {
		methods = []models.PaymentMethod{}
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "paymentMethods": methods})
}

func (h *PaymentMethodHandler) CreatePaymentMethod(c *gin.Context) {
	if !h.demoMode && !strings.EqualFold(os.Getenv("PAYMENT_DEMO_MODE"), "true") {
		c.JSON(http.StatusForbidden, gin.H{"success": false, "error": "Demo payment mode is disabled"})
		return
	}

	userID, ok := getAuthUserID(c)
	if !ok {
		return
	}

	var req models.CreatePaymentMethodRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": err.Error()})
		return
	}

	cardNumber := normalizeDigits(req.CardNumber)
	if len(cardNumber) < 12 || len(cardNumber) > 19 {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid card number"})
		return
	}
	if len(normalizeDigits(req.Cvv)) < 3 {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid CVV"})
		return
	}

	brand := detectBrand(cardNumber)
	method := &models.PaymentMethod{
		UserID:         userID,
		Brand:          brand,
		CardholderName: strings.TrimSpace(req.CardholderName),
		Last4:          cardNumber[len(cardNumber)-4:],
		ExpiryMonth:    req.ExpiryMonth,
		ExpiryYear:     req.ExpiryYear,
		Nickname:       req.Nickname,
		IsDefault:      req.SetAsDefault,
	}

	if method.CardholderName == "" {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Cardholder name is required"})
		return
	}

	if err := h.repo.Create(c.Request.Context(), method); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to save payment method"})
		return
	}

	method.MaskedNumber = "**** **** **** " + method.Last4
	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"message": "Card saved in demo vault",
		"paymentMethod": method,
	})
}

func (h *PaymentMethodHandler) DeletePaymentMethod(c *gin.Context) {
	userID, ok := getAuthUserID(c)
	if !ok {
		return
	}

	methodID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid payment method ID"})
		return
	}

	if err := h.repo.Delete(c.Request.Context(), userID, methodID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to delete payment method"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Payment method removed"})
}

func (h *PaymentMethodHandler) SetDefaultPaymentMethod(c *gin.Context) {
	userID, ok := getAuthUserID(c)
	if !ok {
		return
	}

	methodID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid payment method ID"})
		return
	}

	if err := h.repo.SetDefault(c.Request.Context(), userID, methodID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to update default payment method"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Default payment method updated"})
}

func normalizeDigits(value string) string {
	return regexp.MustCompile(`\D`).ReplaceAllString(strings.TrimSpace(value), "")
}

func detectBrand(cardNumber string) string {
	switch {
	case strings.HasPrefix(cardNumber, "4"):
		return "Visa"
	case strings.HasPrefix(cardNumber, "5"):
		return "Mastercard"
	case strings.HasPrefix(cardNumber, "3"):
		return "Amex"
	default:
		return "Card"
	}
}