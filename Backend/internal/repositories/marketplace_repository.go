package repositories

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"pawpal-backend/internal/models"
)

// MarketplaceRepository handles all marketplace DB operations
type MarketplaceRepository struct {
	db *pgxpool.Pool
}

// NewMarketplaceRepository creates a new MarketplaceRepository
func NewMarketplaceRepository(db *pgxpool.Pool) *MarketplaceRepository {
	return &MarketplaceRepository{db: db}
}

// ─── Categories ───────────────────────────────────────────────────────────────

// GetCategories returns all product categories
func (r *MarketplaceRepository) GetCategories(ctx context.Context) ([]models.ProductCategory, error) {
	rows, err := r.db.Query(ctx, `
		SELECT id, name, description, icon_url, created_at
		FROM product_categories
		ORDER BY name ASC`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var cats []models.ProductCategory
	for rows.Next() {
		var c models.ProductCategory
		if err := rows.Scan(&c.ID, &c.Name, &c.Description, &c.IconURL, &c.CreatedAt); err != nil {
			return nil, err
		}
		cats = append(cats, c)
	}
	return cats, rows.Err()
}

// ─── Products ─────────────────────────────────────────────────────────────────

// CreateProduct inserts a new product listing
func (r *MarketplaceRepository) CreateProduct(ctx context.Context, p *models.Product, sellerID uuid.UUID) error {
	p.ID = uuid.New()
	p.SellerID = sellerID
	p.CreatedAt = time.Now()
	p.UpdatedAt = time.Now()
	if p.Currency == "" {
		p.Currency = "PKR"
	}

	query := `
		INSERT INTO products
			(id, seller_id, category_id, name, description, price, currency,
			 stock_quantity, images, breed_compatibility, pet_type, weight_grams,
			 is_active, created_at, updated_at)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,true,$13,$14)
		RETURNING is_active, rating, total_reviews, total_sold`

	return r.db.QueryRow(ctx, query,
		p.ID, p.SellerID, p.CategoryID, p.Name, p.Description, p.Price, p.Currency,
		p.StockQuantity, p.Images, p.BreedCompatibility, p.PetType, p.WeightGrams,
		p.CreatedAt, p.UpdatedAt,
	).Scan(&p.IsActive, &p.Rating, &p.TotalReviews, &p.TotalSold)
}

// GetProducts returns paginated + filtered products
func (r *MarketplaceRepository) GetProducts(ctx context.Context, categoryID, petType, search, breedFilter string, minPrice, maxPrice float64, page, limit int) ([]models.Product, int, error) {
	args := []interface{}{}
	argIdx := 1

	where := []string{"p.is_active = true"}

	if categoryID != "" {
		where = append(where, fmt.Sprintf("p.category_id = $%d", argIdx))
		args = append(args, categoryID)
		argIdx++
	}
	if petType != "" {
		where = append(where, fmt.Sprintf("p.pet_type = $%d", argIdx))
		args = append(args, petType)
		argIdx++
	}
	if search != "" {
		where = append(where, fmt.Sprintf("(p.name ILIKE $%d OR p.description ILIKE $%d)", argIdx, argIdx+1))
		like := "%" + search + "%"
		args = append(args, like, like)
		argIdx += 2
	}
	if breedFilter != "" {
		where = append(where, fmt.Sprintf("$%d = ANY(p.breed_compatibility)", argIdx))
		args = append(args, breedFilter)
		argIdx++
	}
	if minPrice > 0 {
		where = append(where, fmt.Sprintf("p.price >= $%d", argIdx))
		args = append(args, minPrice)
		argIdx++
	}
	if maxPrice > 0 {
		where = append(where, fmt.Sprintf("p.price <= $%d", argIdx))
		args = append(args, maxPrice)
		argIdx++
	}

	whereClause := strings.Join(where, " AND ")

	// Count total
	var total int
	countQuery := fmt.Sprintf(`
		SELECT COUNT(*) FROM products p WHERE %s`, whereClause)
	if err := r.db.QueryRow(ctx, countQuery, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	// Paginated data
	offset := (page - 1) * limit
	args = append(args, limit, offset)

	dataQuery := fmt.Sprintf(`
		SELECT p.id, p.seller_id, u.display_name, u.avatar_url,
		       p.category_id, pc.name,
		       p.name, p.description, p.price, p.currency,
		       p.stock_quantity, p.images, p.breed_compatibility, p.pet_type,
		       p.weight_grams, p.is_active, p.rating, p.total_reviews, p.total_sold,
		       p.created_at, p.updated_at
		FROM products p
		LEFT JOIN users u ON u.id = p.seller_id
		LEFT JOIN product_categories pc ON pc.id = p.category_id
		WHERE %s
		ORDER BY p.created_at DESC
		LIMIT $%d OFFSET $%d`, whereClause, argIdx, argIdx+1)

	rows, err := r.db.Query(ctx, dataQuery, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var products []models.Product
	for rows.Next() {
		var p models.Product
		if err := rows.Scan(
			&p.ID, &p.SellerID, &p.SellerName, &p.SellerAvatar,
			&p.CategoryID, &p.CategoryName,
			&p.Name, &p.Description, &p.Price, &p.Currency,
			&p.StockQuantity, &p.Images, &p.BreedCompatibility, &p.PetType,
			&p.WeightGrams, &p.IsActive, &p.Rating, &p.TotalReviews, &p.TotalSold,
			&p.CreatedAt, &p.UpdatedAt,
		); err != nil {
			return nil, 0, err
		}
		products = append(products, p)
	}
	return products, total, rows.Err()
}

// GetProductByID returns a single product with full details
func (r *MarketplaceRepository) GetProductByID(ctx context.Context, productID uuid.UUID) (*models.Product, error) {
	var p models.Product
	query := `
		SELECT p.id, p.seller_id, u.display_name, u.avatar_url,
		       p.category_id, pc.name,
		       p.name, p.description, p.price, p.currency,
		       p.stock_quantity, p.images, p.breed_compatibility, p.pet_type,
		       p.weight_grams, p.is_active, p.rating, p.total_reviews, p.total_sold,
		       p.created_at, p.updated_at
		FROM products p
		LEFT JOIN users u ON u.id = p.seller_id
		LEFT JOIN product_categories pc ON pc.id = p.category_id
		WHERE p.id = $1`

	err := r.db.QueryRow(ctx, query, productID).Scan(
		&p.ID, &p.SellerID, &p.SellerName, &p.SellerAvatar,
		&p.CategoryID, &p.CategoryName,
		&p.Name, &p.Description, &p.Price, &p.Currency,
		&p.StockQuantity, &p.Images, &p.BreedCompatibility, &p.PetType,
		&p.WeightGrams, &p.IsActive, &p.Rating, &p.TotalReviews, &p.TotalSold,
		&p.CreatedAt, &p.UpdatedAt,
	)
	if err == pgx.ErrNoRows {
		return nil, nil
	}
	return &p, err
}

// GetSellerProducts returns products listed by a specific seller
func (r *MarketplaceRepository) GetSellerProducts(ctx context.Context, sellerID uuid.UUID, page, limit int) ([]models.Product, int, error) {
	var total int
	if err := r.db.QueryRow(ctx,
		`SELECT COUNT(*) FROM products WHERE seller_id = $1`, sellerID,
	).Scan(&total); err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * limit
	rows, err := r.db.Query(ctx, `
				SELECT p.id, p.seller_id, u.display_name, u.avatar_url,
		       p.category_id, pc.name,
		       p.name, p.description, p.price, p.currency,
		       p.stock_quantity, p.images, p.breed_compatibility, p.pet_type,
		       p.weight_grams, p.is_active, p.rating, p.total_reviews, p.total_sold,
		       p.created_at, p.updated_at
		FROM products p
		LEFT JOIN users u ON u.id = p.seller_id
		LEFT JOIN product_categories pc ON pc.id = p.category_id
		WHERE p.seller_id = $1
		ORDER BY p.created_at DESC
		LIMIT $2 OFFSET $3`,
		sellerID, limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var products []models.Product
	for rows.Next() {
		var p models.Product
		if err := rows.Scan(
			&p.ID, &p.SellerID, &p.SellerName, &p.SellerAvatar,
			&p.CategoryID, &p.CategoryName,
			&p.Name, &p.Description, &p.Price, &p.Currency,
			&p.StockQuantity, &p.Images, &p.BreedCompatibility, &p.PetType,
			&p.WeightGrams, &p.IsActive, &p.Rating, &p.TotalReviews, &p.TotalSold,
			&p.CreatedAt, &p.UpdatedAt,
		); err != nil {
			return nil, 0, err
		}
		products = append(products, p)
	}
	return products, total, rows.Err()
}

// UpdateProduct updates a product (only by its seller)
func (r *MarketplaceRepository) UpdateProduct(ctx context.Context, productID, sellerID uuid.UUID, req *models.UpdateProductRequest) (*models.Product, error) {
	query := `
		UPDATE products SET
			name = COALESCE(NULLIF($3,''), name),
			description = COALESCE(NULLIF($4,''), description),
			price = CASE WHEN $5::DECIMAL > 0 THEN $5::DECIMAL ELSE price END,
			currency = COALESCE(NULLIF($6,''), currency),
			stock_quantity = COALESCE($7, stock_quantity),
			images = COALESCE($8, images),
			breed_compatibility = COALESCE($9, breed_compatibility),
			pet_type = COALESCE(NULLIF($10,''), pet_type),
			weight_grams = COALESCE($11, weight_grams),
			is_active = COALESCE($12, is_active),
			category_id = COALESCE($13::UUID, category_id),
			updated_at = NOW()
		WHERE id = $1 AND seller_id = $2
		RETURNING id, seller_id, category_id, name, description, price, currency,
		          stock_quantity, images, breed_compatibility, pet_type, weight_grams,
		          is_active, rating, total_reviews, total_sold, created_at, updated_at`

	var catID *uuid.UUID
	if req.CategoryID != nil && *req.CategoryID != "" {
		parsed, err := uuid.Parse(*req.CategoryID)
		if err == nil {
			catID = &parsed
		}
	}

	var p models.Product
	err := r.db.QueryRow(ctx, query,
		productID, sellerID,
		req.Name, req.Description, req.Price, req.Currency,
		req.StockQuantity, req.Images, req.BreedCompatibility, req.PetType,
		req.WeightGrams, req.IsActive, catID,
	).Scan(
		&p.ID, &p.SellerID, &p.CategoryID,
		&p.Name, &p.Description, &p.Price, &p.Currency,
		&p.StockQuantity, &p.Images, &p.BreedCompatibility, &p.PetType,
		&p.WeightGrams, &p.IsActive, &p.Rating, &p.TotalReviews, &p.TotalSold,
		&p.CreatedAt, &p.UpdatedAt,
	)
	if err == pgx.ErrNoRows {
		return nil, nil
	}
	return &p, err
}

// DeleteProduct soft-deletes (deactivates) a product owned by sellerID
func (r *MarketplaceRepository) DeleteProduct(ctx context.Context, productID, sellerID uuid.UUID) error {
	tag, err := r.db.Exec(ctx,
		`UPDATE products SET is_active = false, updated_at = NOW() WHERE id = $1 AND seller_id = $2`,
		productID, sellerID)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return pgx.ErrNoRows
	}
	return nil
}

// ─── Cart ─────────────────────────────────────────────────────────────────────

// GetCartItems returns all active cart items for a user
func (r *MarketplaceRepository) GetCartItems(ctx context.Context, userID uuid.UUID) ([]models.CartItem, float64, error) {
	rows, err := r.db.Query(ctx, `
		SELECT ci.id, ci.user_id, ci.product_id, ci.quantity, ci.created_at, ci.updated_at,
		       p.id, p.seller_id, p.name, p.description, p.price, p.currency,
		       p.stock_quantity, p.images, p.breed_compatibility, p.pet_type,
		       p.weight_grams, p.is_active, p.rating, p.total_reviews, p.total_sold,
		       p.created_at, p.updated_at
		FROM cart_items ci
		JOIN products p ON p.id = ci.product_id
		WHERE ci.user_id = $1 AND p.is_active = true
		ORDER BY ci.created_at DESC`,
		userID)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var items []models.CartItem
	var total float64
	for rows.Next() {
		var ci models.CartItem
		var p models.Product
		if err := rows.Scan(
			&ci.ID, &ci.UserID, &ci.ProductID, &ci.Quantity, &ci.CreatedAt, &ci.UpdatedAt,
			&p.ID, &p.SellerID, &p.Name, &p.Description, &p.Price, &p.Currency,
			&p.StockQuantity, &p.Images, &p.BreedCompatibility, &p.PetType,
			&p.WeightGrams, &p.IsActive, &p.Rating, &p.TotalReviews, &p.TotalSold,
			&p.CreatedAt, &p.UpdatedAt,
		); err != nil {
			return nil, 0, err
		}
		ci.Product = &p
		total += p.Price * float64(ci.Quantity)
		items = append(items, ci)
	}
	return items, total, rows.Err()
}

// AddToCart upserts a cart item (adds or increments quantity)
func (r *MarketplaceRepository) AddToCart(ctx context.Context, userID, productID uuid.UUID, quantity int) (*models.CartItem, error) {
	var ci models.CartItem
	query := `
		INSERT INTO cart_items (id, user_id, product_id, quantity, created_at, updated_at)
		VALUES ($1, $2, $3, $4, NOW(), NOW())
		ON CONFLICT (user_id, product_id)
		DO UPDATE SET quantity = cart_items.quantity + EXCLUDED.quantity, updated_at = NOW()
		RETURNING id, user_id, product_id, quantity, created_at, updated_at`

	err := r.db.QueryRow(ctx, query, uuid.New(), userID, productID, quantity).Scan(
		&ci.ID, &ci.UserID, &ci.ProductID, &ci.Quantity, &ci.CreatedAt, &ci.UpdatedAt,
	)
	return &ci, err
}

// UpdateCartItem sets the quantity of a specific cart item belonging to userID
func (r *MarketplaceRepository) UpdateCartItem(ctx context.Context, itemID, userID uuid.UUID, quantity int) error {
	tag, err := r.db.Exec(ctx,
		`UPDATE cart_items SET quantity = $3, updated_at = NOW() WHERE id = $1 AND user_id = $2`,
		itemID, userID, quantity)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return pgx.ErrNoRows
	}
	return nil
}

// RemoveCartItem deletes a cart item belonging to userID
func (r *MarketplaceRepository) RemoveCartItem(ctx context.Context, itemID, userID uuid.UUID) error {
	tag, err := r.db.Exec(ctx,
		`DELETE FROM cart_items WHERE id = $1 AND user_id = $2`,
		itemID, userID)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return pgx.ErrNoRows
	}
	return nil
}

// ClearCart removes all items from a user's cart
func (r *MarketplaceRepository) ClearCart(ctx context.Context, userID uuid.UUID) error {
	_, err := r.db.Exec(ctx, `DELETE FROM cart_items WHERE user_id = $1`, userID)
	return err
}

// ─── Orders ───────────────────────────────────────────────────────────────────

// CreateOrder places a new order within a transaction
func (r *MarketplaceRepository) CreateOrder(ctx context.Context, order *models.Order, items []models.CartItem) error {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	order.ID = uuid.New()
	order.CreatedAt = time.Now()
	order.UpdatedAt = time.Now()
	if order.Currency == "" {
		order.Currency = "PKR"
	}
	if order.PaymentMethod == "" {
		order.PaymentMethod = "cash_on_delivery"
	}
	order.Status = "pending"
	order.PaymentStatus = "pending"

	_, err = tx.Exec(ctx, `
		INSERT INTO orders
			(id, buyer_id, status, total_amount, currency, shipping_address,
			 shipping_city, shipping_phone, payment_method, payment_status, notes, created_at, updated_at)
		VALUES ($1,$2,'pending',$3,$4,$5,$6,$7,$8,'pending',$9,$10,$11)`,
		order.ID, order.BuyerID, order.TotalAmount, order.Currency,
		order.ShippingAddress, order.ShippingCity, order.ShippingPhone,
		order.PaymentMethod, order.Notes, order.CreatedAt, order.UpdatedAt,
	)
	if err != nil {
		return err
	}

	for _, ci := range items {
		itemID := uuid.New()
		unitPrice := ci.Product.Price
		totalPrice := unitPrice * float64(ci.Quantity)
		_, err = tx.Exec(ctx, `
			INSERT INTO order_items
				(id, order_id, product_id, seller_id, quantity, unit_price, total_price, seller_status, created_at)
			VALUES ($1,$2,$3,$4,$5,$6,$7,'pending',$8)`,
			itemID, order.ID, ci.ProductID, ci.Product.SellerID,
			ci.Quantity, unitPrice, totalPrice, time.Now(),
		)
		if err != nil {
			return err
		}

		// Decrement stock
		_, err = tx.Exec(ctx,
			`UPDATE products SET stock_quantity = stock_quantity - $1, total_sold = total_sold + $1, updated_at = NOW() WHERE id = $2`,
			ci.Quantity, ci.ProductID,
		)
		if err != nil {
			return err
		}
	}

	// Clear cart after successful order
	_, err = tx.Exec(ctx, `DELETE FROM cart_items WHERE user_id = $1`, order.BuyerID)
	if err != nil {
		return err
	}

	return tx.Commit(ctx)
}

// GetOrders returns orders for a buyer (paginated)
func (r *MarketplaceRepository) GetOrders(ctx context.Context, buyerID uuid.UUID, page, limit int) ([]models.Order, int, error) {
	var total int
	if err := r.db.QueryRow(ctx,
		`SELECT COUNT(*) FROM orders WHERE buyer_id = $1`, buyerID,
	).Scan(&total); err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * limit
	rows, err := r.db.Query(ctx, `
		SELECT id, buyer_id, status, total_amount, currency, shipping_address,
		       shipping_city, shipping_phone, payment_method, payment_status,
		       tracking_number, notes, created_at, updated_at
		FROM orders
		WHERE buyer_id = $1
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3`,
		buyerID, limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var orders []models.Order
	for rows.Next() {
		var o models.Order
		if err := rows.Scan(
			&o.ID, &o.BuyerID, &o.Status, &o.TotalAmount, &o.Currency,
			&o.ShippingAddress, &o.ShippingCity, &o.ShippingPhone,
			&o.PaymentMethod, &o.PaymentStatus, &o.TrackingNumber, &o.Notes,
			&o.CreatedAt, &o.UpdatedAt,
		); err != nil {
			return nil, 0, err
		}
		orders = append(orders, o)
	}
	return orders, total, rows.Err()
}

// GetOrderByID returns a full order with its items
func (r *MarketplaceRepository) GetOrderByID(ctx context.Context, orderID uuid.UUID) (*models.Order, error) {
	var o models.Order
	err := r.db.QueryRow(ctx, `
		SELECT id, buyer_id, status, total_amount, currency, shipping_address,
		       shipping_city, shipping_phone, payment_method, payment_status,
		       tracking_number, notes, created_at, updated_at
		FROM orders WHERE id = $1`, orderID).Scan(
		&o.ID, &o.BuyerID, &o.Status, &o.TotalAmount, &o.Currency,
		&o.ShippingAddress, &o.ShippingCity, &o.ShippingPhone,
		&o.PaymentMethod, &o.PaymentStatus, &o.TrackingNumber, &o.Notes,
		&o.CreatedAt, &o.UpdatedAt,
	)
	if err == pgx.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	// Fetch order items
	rows, err := r.db.Query(ctx, `
		SELECT oi.id, oi.order_id, oi.product_id, p.name, COALESCE(p.images[1], ''),
		       oi.seller_id, u.display_name,
		       oi.quantity, oi.unit_price, oi.total_price, oi.seller_status, oi.created_at
		FROM order_items oi
		JOIN products p ON p.id = oi.product_id
		JOIN users u ON u.id = oi.seller_id
		WHERE oi.order_id = $1`, orderID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var item models.OrderItem
		if err := rows.Scan(
			&item.ID, &item.OrderID, &item.ProductID, &item.ProductName, &item.ProductImage,
			&item.SellerID, &item.SellerName,
			&item.Quantity, &item.UnitPrice, &item.TotalPrice, &item.SellerStatus, &item.CreatedAt,
		); err != nil {
			return nil, err
		}
		o.Items = append(o.Items, item)
	}
	return &o, rows.Err()
}

// UpdateOrderStatus updates the status of an order (buyer cancels, admin/seller updates)
func (r *MarketplaceRepository) UpdateOrderStatus(ctx context.Context, orderID uuid.UUID, status, trackingNumber string) error {
	var err error
	if trackingNumber != "" {
		_, err = r.db.Exec(ctx,
			`UPDATE orders SET status=$2, tracking_number=$3, updated_at=NOW() WHERE id=$1`,
			orderID, status, trackingNumber)
	} else {
		_, err = r.db.Exec(ctx,
			`UPDATE orders SET status=$2, updated_at=NOW() WHERE id=$1`,
			orderID, status)
	}
	return err
}

// GetSellerOrders returns orders that contain items sold by sellerID
func (r *MarketplaceRepository) GetSellerOrders(ctx context.Context, sellerID uuid.UUID, page, limit int) ([]models.Order, int, error) {
	var total int
	if err := r.db.QueryRow(ctx,
		`SELECT COUNT(DISTINCT o.id) FROM orders o JOIN order_items oi ON oi.order_id = o.id WHERE oi.seller_id = $1`,
		sellerID,
	).Scan(&total); err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * limit
	rows, err := r.db.Query(ctx, `
		SELECT DISTINCT o.id, o.buyer_id, o.status, o.total_amount, o.currency,
		       o.shipping_address, o.shipping_city, o.shipping_phone,
		       o.payment_method, o.payment_status, o.tracking_number, o.notes,
		       o.created_at, o.updated_at
		FROM orders o
		JOIN order_items oi ON oi.order_id = o.id
		WHERE oi.seller_id = $1
		ORDER BY o.created_at DESC
		LIMIT $2 OFFSET $3`,
		sellerID, limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var orders []models.Order
	for rows.Next() {
		var o models.Order
		if err := rows.Scan(
			&o.ID, &o.BuyerID, &o.Status, &o.TotalAmount, &o.Currency,
			&o.ShippingAddress, &o.ShippingCity, &o.ShippingPhone,
			&o.PaymentMethod, &o.PaymentStatus, &o.TrackingNumber, &o.Notes,
			&o.CreatedAt, &o.UpdatedAt,
		); err != nil {
			return nil, 0, err
		}
		orders = append(orders, o)
	}
	return orders, total, rows.Err()
}

// ─── Reviews ─────────────────────────────────────────────────────────────────

// AddReview inserts a review and updates the product's aggregate rating
func (r *MarketplaceRepository) AddReview(ctx context.Context, review *models.ProductReview) error {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	review.ID = uuid.New()
	review.CreatedAt = time.Now()

	_, err = tx.Exec(ctx, `
		INSERT INTO product_reviews (id, product_id, user_id, order_item_id, rating, comment, created_at)
		VALUES ($1,$2,$3,$4,$5,$6,$7)`,
		review.ID, review.ProductID, review.UserID, review.OrderItemID,
		review.Rating, review.Comment, review.CreatedAt,
	)
	if err != nil {
		return err
	}

	// Recalculate aggregate rating
	_, err = tx.Exec(ctx, `
		UPDATE products SET
			rating = (SELECT AVG(rating)::DECIMAL(3,2) FROM product_reviews WHERE product_id = $1),
			total_reviews = (SELECT COUNT(*) FROM product_reviews WHERE product_id = $1),
			updated_at = NOW()
		WHERE id = $1`, review.ProductID)
	if err != nil {
		return err
	}

	return tx.Commit(ctx)
}

// GetProductReviews returns paginated reviews for a product
func (r *MarketplaceRepository) GetProductReviews(ctx context.Context, productID uuid.UUID, page, limit int) ([]models.ProductReview, int, error) {
	var total int
	if err := r.db.QueryRow(ctx,
		`SELECT COUNT(*) FROM product_reviews WHERE product_id = $1`, productID,
	).Scan(&total); err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * limit
	rows, err := r.db.Query(ctx, `
		SELECT pr.id, pr.product_id, pr.user_id, u.display_name, u.avatar_url,
		       pr.order_item_id, pr.rating, pr.comment, pr.created_at
		FROM product_reviews pr
		JOIN users u ON u.id = pr.user_id
		WHERE pr.product_id = $1
		ORDER BY pr.created_at DESC
		LIMIT $2 OFFSET $3`,
		productID, limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var reviews []models.ProductReview
	for rows.Next() {
		var rv models.ProductReview
		if err := rows.Scan(
			&rv.ID, &rv.ProductID, &rv.UserID, &rv.UserName, &rv.UserAvatar,
			&rv.OrderItemID, &rv.Rating, &rv.Comment, &rv.CreatedAt,
		); err != nil {
			return nil, 0, err
		}
		reviews = append(reviews, rv)
	}
	return reviews, total, rows.Err()
}
