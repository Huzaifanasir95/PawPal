package repositories

import (
	"context"
	"database/sql"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"pawpal-backend/internal/models"
)

type PaymentMethodRepository struct {
	db *pgxpool.Pool
}

func NewPaymentMethodRepository(db *pgxpool.Pool) *PaymentMethodRepository {
	return &PaymentMethodRepository{db: db}
}

func (r *PaymentMethodRepository) ListByUser(ctx context.Context, userID uuid.UUID) ([]models.PaymentMethod, error) {
	rows, err := r.db.Query(ctx, `
		SELECT id, user_id, method_type, stripe_payment_method_id, brand, cardholder_name, last4,
			expiry_month, expiry_year, nickname, is_default, created_at, updated_at
		FROM payment_methods
		WHERE user_id = $1
		ORDER BY is_default DESC, created_at DESC
	`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	methods := make([]models.PaymentMethod, 0)
	for rows.Next() {
		var method models.PaymentMethod
		var stripePaymentMethodID sql.NullString
		if err := rows.Scan(
			&method.ID, &method.UserID, &method.MethodType, &stripePaymentMethodID, &method.Brand, &method.CardholderName, &method.Last4,
			&method.ExpiryMonth, &method.ExpiryYear, &method.Nickname, &method.IsDefault, &method.CreatedAt, &method.UpdatedAt,
		); err != nil {
			return nil, err
		}
		if stripePaymentMethodID.Valid {
			method.StripePaymentMethodID = &stripePaymentMethodID.String
		}
		method.MaskedNumber = maskedNumber(method.Last4)
		methods = append(methods, method)
	}
	return methods, rows.Err()
}

func (r *PaymentMethodRepository) Create(ctx context.Context, method *models.PaymentMethod) error {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	method.ID = uuid.New()
	method.CreatedAt = time.Now()
	method.UpdatedAt = time.Now()
	method.MethodType = "card"

	if method.IsDefault {
		if _, err := tx.Exec(ctx, `UPDATE payment_methods SET is_default = false, updated_at = NOW() WHERE user_id = $1`, method.UserID); err != nil {
			return err
		}
	}

	err = tx.QueryRow(ctx, `
		INSERT INTO payment_methods (
			id, user_id, method_type, stripe_payment_method_id, brand, cardholder_name, last4,
			expiry_month, expiry_year, nickname, is_default, created_at, updated_at
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)
		RETURNING id, created_at, updated_at
	`, method.ID, method.UserID, method.MethodType, nullableString(method.StripePaymentMethodID), method.Brand, method.CardholderName, method.Last4,
		method.ExpiryMonth, method.ExpiryYear, method.Nickname, method.IsDefault, method.CreatedAt, method.UpdatedAt,
	).Scan(&method.ID, &method.CreatedAt, &method.UpdatedAt)
	if err != nil {
		return err
	}

	return tx.Commit(ctx)
}

func (r *PaymentMethodRepository) Delete(ctx context.Context, userID, methodID uuid.UUID) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM payment_methods WHERE id = $1 AND user_id = $2`, methodID, userID)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return pgx.ErrNoRows
	}
	return nil
}

func (r *PaymentMethodRepository) SetDefault(ctx context.Context, userID, methodID uuid.UUID) error {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	tag, err := tx.Exec(ctx, `UPDATE payment_methods SET is_default = false, updated_at = NOW() WHERE user_id = $1`, userID)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return pgx.ErrNoRows
	}

	if _, err := tx.Exec(ctx, `UPDATE payment_methods SET is_default = true, updated_at = NOW() WHERE id = $1 AND user_id = $2`, methodID, userID); err != nil {
		return err
	}

	return tx.Commit(ctx)
}

func maskedNumber(last4 string) string {
	trimmed := strings.TrimSpace(last4)
	if len(trimmed) < 4 {
		return "**** **** **** ****"
	}
	return "**** **** **** " + trimmed[len(trimmed)-4:]
}

func nullableString(value *string) any {
	if value == nil {
		return nil
	}
	trimmed := strings.TrimSpace(*value)
	if trimmed == "" {
		return nil
	}
	return trimmed
}