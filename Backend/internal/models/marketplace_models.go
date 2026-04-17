package models

import (
	"time"

	"github.com/google/uuid"
)

// ProductCategory represents a product category
type ProductCategory struct {
	ID          uuid.UUID `json:"id"`
	Name        string    `json:"name"`
	Description *string   `json:"description,omitempty"`
	IconURL     *string   `json:"iconUrl,omitempty"`
	CreatedAt   time.Time `json:"createdAt"`
}

// Product represents a marketplace product listing
type Product struct {
	ID                 uuid.UUID  `json:"id"`
	SellerID           uuid.UUID  `json:"sellerId"`
	SellerName         *string    `json:"sellerName,omitempty"`
	SellerAvatar       *string    `json:"sellerAvatar,omitempty"`
	CategoryID         *uuid.UUID `json:"categoryId,omitempty"`
	CategoryName       *string    `json:"categoryName,omitempty"`
	Name               string     `json:"name"`
	Description        string     `json:"description"`
	Price              float64    `json:"price"`
	Currency           string     `json:"currency"`
	StockQuantity      int        `json:"stockQuantity"`
	Images             []string   `json:"images,omitempty"`
	BreedCompatibility []string   `json:"breedCompatibility,omitempty"`
	PetType            string     `json:"petType"`
	WeightGrams        *int       `json:"weightGrams,omitempty"`
	IsActive           bool       `json:"isActive"`
	Rating             float64    `json:"rating"`
	TotalReviews       int        `json:"totalReviews"`
	TotalSold          int        `json:"totalSold"`
	CreatedAt          time.Time  `json:"createdAt"`
	UpdatedAt          time.Time  `json:"updatedAt"`
}

// CartItem represents an item in the user's shopping cart
type CartItem struct {
	ID        uuid.UUID `json:"id"`
	UserID    uuid.UUID `json:"userId"`
	ProductID uuid.UUID `json:"productId"`
	Product   *Product  `json:"product,omitempty"`
	Quantity  int       `json:"quantity"`
	CreatedAt time.Time `json:"createdAt"`
	UpdatedAt time.Time `json:"updatedAt"`
}

// Order represents a placed order
type Order struct {
	ID              uuid.UUID    `json:"id"`
	BuyerID         uuid.UUID    `json:"buyerId"`
	Status          string       `json:"status"`
	TotalAmount     float64      `json:"totalAmount"`
	Currency        string       `json:"currency"`
	ShippingAddress string       `json:"shippingAddress"`
	ShippingCity    *string      `json:"shippingCity,omitempty"`
	ShippingPhone   *string      `json:"shippingPhone,omitempty"`
	PaymentMethod   string       `json:"paymentMethod"`
	PaymentStatus   string       `json:"paymentStatus"`
	TrackingNumber  *string      `json:"trackingNumber,omitempty"`
	Notes           *string      `json:"notes,omitempty"`
	Items           []OrderItem  `json:"items,omitempty"`
	CreatedAt       time.Time    `json:"createdAt"`
	UpdatedAt       time.Time    `json:"updatedAt"`
}

// OrderItem represents a single product line in an order
type OrderItem struct {
	ID           uuid.UUID `json:"id"`
	OrderID      uuid.UUID `json:"orderId"`
	ProductID    uuid.UUID `json:"productId"`
	ProductName  string    `json:"productName,omitempty"`
	ProductImage string    `json:"productImage,omitempty"`
	SellerID     uuid.UUID `json:"sellerId"`
	SellerName   *string   `json:"sellerName,omitempty"`
	Quantity     int       `json:"quantity"`
	UnitPrice    float64   `json:"unitPrice"`
	TotalPrice   float64   `json:"totalPrice"`
	SellerStatus string    `json:"sellerStatus"`
	CreatedAt    time.Time `json:"createdAt"`
}

// ProductReview represents a review on a product
type ProductReview struct {
	ID          uuid.UUID  `json:"id"`
	ProductID   uuid.UUID  `json:"productId"`
	UserID      uuid.UUID  `json:"userId"`
	UserName    *string    `json:"userName,omitempty"`
	UserAvatar  *string    `json:"userAvatar,omitempty"`
	OrderItemID *uuid.UUID `json:"orderItemId,omitempty"`
	Rating      int        `json:"rating"`
	Comment     *string    `json:"comment,omitempty"`
	CreatedAt   time.Time  `json:"createdAt"`
}

// ─── Request bodies ───────────────────────────────────────────────────────────

type CreateProductRequest struct {
	CategoryID         string   `json:"categoryId" binding:"required"`
	Name               string   `json:"name" binding:"required"`
	Description        string   `json:"description" binding:"required"`
	Price              float64  `json:"price" binding:"required,min=0"`
	Currency           string   `json:"currency"`
	StockQuantity      int      `json:"stockQuantity" binding:"required,min=0"`
	Images             []string `json:"images"`
	BreedCompatibility []string `json:"breedCompatibility"`
	PetType            string   `json:"petType"`
	WeightGrams        *int     `json:"weightGrams"`
}

type UpdateProductRequest struct {
	CategoryID         *string  `json:"categoryId"`
	Name               string   `json:"name"`
	Description        string   `json:"description"`
	Price              float64  `json:"price"`
	Currency           string   `json:"currency"`
	StockQuantity      *int     `json:"stockQuantity"`
	Images             []string `json:"images"`
	BreedCompatibility []string `json:"breedCompatibility"`
	PetType            string   `json:"petType"`
	WeightGrams        *int     `json:"weightGrams"`
	IsActive           *bool    `json:"isActive"`
}

type AddToCartRequest struct {
	ProductID string `json:"productId" binding:"required"`
	Quantity  int    `json:"quantity" binding:"required,min=1"`
}

type UpdateCartItemRequest struct {
	Quantity int `json:"quantity" binding:"required,min=1"`
}

type PlaceOrderRequest struct {
	ShippingAddress string `json:"shippingAddress" binding:"required"`
	ShippingCity    string `json:"shippingCity"`
	ShippingPhone   string `json:"shippingPhone"`
	PaymentMethod   string `json:"paymentMethod"`
	Notes           string `json:"notes"`
}

type UpdateOrderStatusRequest struct {
	Status         string `json:"status" binding:"required"`
	TrackingNumber string `json:"trackingNumber"`
}

type CreateProductReviewRequest struct {
	Rating      int    `json:"rating" binding:"required,min=1,max=5"`
	Comment     string `json:"comment"`
	OrderItemID string `json:"orderItemId"`
}

// ─── Response bodies ──────────────────────────────────────────────────────────

type ProductListResponse struct {
	Success  bool      `json:"success"`
	Products []Product `json:"products"`
	Pagination struct {
		Total  int `json:"total"`
		Page   int `json:"page"`
		Limit  int `json:"limit"`
		Pages  int `json:"pages"`
	} `json:"pagination"`
}

type CartResponse struct {
	Success   bool       `json:"success"`
	Items     []CartItem `json:"items"`
	ItemCount int        `json:"itemCount"`
	Total     float64    `json:"total"`
}
