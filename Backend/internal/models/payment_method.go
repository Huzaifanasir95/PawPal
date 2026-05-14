package models

import (
	"time"

	"github.com/google/uuid"
)

// PaymentMethod represents a masked payment card saved for demo checkout flows.
// Sensitive card details are intentionally not persisted.
type PaymentMethod struct {
	ID             uuid.UUID `json:"id"`
	UserID         uuid.UUID `json:"userId"`
	MethodType     string    `json:"methodType"`
	Brand          string    `json:"brand"`
	CardholderName string    `json:"cardholderName"`
	Last4          string    `json:"last4"`
	ExpiryMonth    int       `json:"expiryMonth"`
	ExpiryYear     int       `json:"expiryYear"`
	Nickname       *string   `json:"nickname,omitempty"`
	IsDefault      bool      `json:"isDefault"`
	CreatedAt      time.Time `json:"createdAt"`
	UpdatedAt      time.Time `json:"updatedAt"`
	MaskedNumber   string    `json:"maskedNumber,omitempty"`
}