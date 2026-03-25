package handlers

import (
	"math"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	"pawpal-backend/internal/models"
	"pawpal-backend/internal/repositories"
)

// MarketplaceHandlers handles marketplace endpoints
type MarketplaceHandlers struct {
	marketplaceRepo *repositories.MarketplaceRepository
}

// NewMarketplaceHandlers creates new MarketplaceHandlers
func NewMarketplaceHandlers(repo *repositories.MarketplaceRepository) *MarketplaceHandlers {
	return &MarketplaceHandlers{marketplaceRepo: repo}
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

func getAuthUserID(c *gin.Context) (uuid.UUID, bool) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "error": "User not authenticated"})
		return uuid.Nil, false
	}
	uid, err := uuid.Parse(userID.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid user ID"})
		return uuid.Nil, false
	}
	return uid, true
}

func parsePagination(c *gin.Context) (page, limit int) {
	page, _ = strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ = strconv.Atoi(c.DefaultQuery("limit", "20"))
	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 20
	}
	return
}

// ─── Categories ───────────────────────────────────────────────────────────────

// GetCategories returns all product categories
func (h *MarketplaceHandlers) GetCategories(c *gin.Context) {
	cats, err := h.marketplaceRepo.GetCategories(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to fetch categories"})
		return
	}
	if cats == nil {
		cats = []models.ProductCategory{}
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "categories": cats})
}

// ─── Products ─────────────────────────────────────────────────────────────────

// GetProducts returns paginated & filtered products (public)
func (h *MarketplaceHandlers) GetProducts(c *gin.Context) {
	page, limit := parsePagination(c)

	categoryID := c.Query("categoryId")
	petType := c.Query("petType")
	search := c.Query("search")
	breedFilter := c.Query("breed")
	minPrice, _ := strconv.ParseFloat(c.DefaultQuery("minPrice", "0"), 64)
	maxPrice, _ := strconv.ParseFloat(c.DefaultQuery("maxPrice", "0"), 64)

	products, total, err := h.marketplaceRepo.GetProducts(c.Request.Context(), categoryID, petType, search, breedFilter, minPrice, maxPrice, page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to fetch products"})
		return
	}
	if products == nil {
		products = []models.Product{}
	}

	pages := int(math.Ceil(float64(total) / float64(limit)))
	c.JSON(http.StatusOK, gin.H{
		"success":  true,
		"products": products,
		"pagination": gin.H{
			"total": total,
			"page":  page,
			"limit": limit,
			"pages": pages,
		},
	})
}

// GetProduct returns a single product by ID (public)
func (h *MarketplaceHandlers) GetProduct(c *gin.Context) {
	productID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid product ID"})
		return
	}

	product, err := h.marketplaceRepo.GetProductByID(c.Request.Context(), productID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to fetch product"})
		return
	}
	if product == nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "error": "Product not found"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "product": product})
}

// GetMyProducts returns all products listed by the authenticated seller
func (h *MarketplaceHandlers) GetMyProducts(c *gin.Context) {
	userID, ok := getAuthUserID(c)
	if !ok {
		return
	}
	page, limit := parsePagination(c)

	products, total, err := h.marketplaceRepo.GetSellerProducts(c.Request.Context(), userID, page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to fetch your products"})
		return
	}
	if products == nil {
		products = []models.Product{}
	}

	pages := int(math.Ceil(float64(total) / float64(limit)))
	c.JSON(http.StatusOK, gin.H{
		"success":  true,
		"products": products,
		"pagination": gin.H{
			"total": total,
			"page":  page,
			"limit": limit,
			"pages": pages,
		},
	})
}

// CreateProduct creates a new product listing
func (h *MarketplaceHandlers) CreateProduct(c *gin.Context) {
	userID, ok := getAuthUserID(c)
	if !ok {
		return
	}

	var req models.CreateProductRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": err.Error()})
		return
	}

	product := &models.Product{
		Name:               req.Name,
		Description:        req.Description,
		Price:              req.Price,
		Currency:           req.Currency,
		StockQuantity:      req.StockQuantity,
		Images:             req.Images,
		BreedCompatibility: req.BreedCompatibility,
		PetType:            req.PetType,
		WeightGrams:        req.WeightGrams,
	}

	if req.CategoryID != nil && *req.CategoryID != "" {
		catID, err := uuid.Parse(*req.CategoryID)
		if err == nil {
			product.CategoryID = &catID
		}
	}

	if err := h.marketplaceRepo.CreateProduct(c.Request.Context(), product, userID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to create product"})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"success": true, "product": product})
}

// UpdateProduct updates an existing product (seller only)
func (h *MarketplaceHandlers) UpdateProduct(c *gin.Context) {
	userID, ok := getAuthUserID(c)
	if !ok {
		return
	}

	productID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid product ID"})
		return
	}

	var req models.UpdateProductRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": err.Error()})
		return
	}

	product, err := h.marketplaceRepo.UpdateProduct(c.Request.Context(), productID, userID, &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to update product"})
		return
	}
	if product == nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "error": "Product not found or you don't have permission"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "product": product})
}

// DeleteProduct deactivates a product (seller only)
func (h *MarketplaceHandlers) DeleteProduct(c *gin.Context) {
	userID, ok := getAuthUserID(c)
	if !ok {
		return
	}

	productID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid product ID"})
		return
	}

	if err := h.marketplaceRepo.DeleteProduct(c.Request.Context(), productID, userID); err != nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "error": "Product not found or you don't have permission"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Product removed"})
}

// ─── Product Reviews ──────────────────────────────────────────────────────────

// GetProductReviews returns reviews for a product (public)
func (h *MarketplaceHandlers) GetProductReviews(c *gin.Context) {
	productID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid product ID"})
		return
	}
	page, limit := parsePagination(c)

	reviews, total, err := h.marketplaceRepo.GetProductReviews(c.Request.Context(), productID, page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to fetch reviews"})
		return
	}
	if reviews == nil {
		reviews = []models.ProductReview{}
	}

	pages := int(math.Ceil(float64(total) / float64(limit)))
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"reviews": reviews,
		"pagination": gin.H{
			"total": total,
			"page":  page,
			"limit": limit,
			"pages": pages,
		},
	})
}

// AddProductReview adds a review to a product (authenticated)
func (h *MarketplaceHandlers) AddProductReview(c *gin.Context) {
	userID, ok := getAuthUserID(c)
	if !ok {
		return
	}

	productID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid product ID"})
		return
	}

	var req models.CreateProductReviewRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": err.Error()})
		return
	}

	review := &models.ProductReview{
		ProductID: productID,
		UserID:    userID,
		Rating:    req.Rating,
	}
	if req.Comment != "" {
		review.Comment = &req.Comment
	}
	if req.OrderItemID != "" {
		oid, err := uuid.Parse(req.OrderItemID)
		if err == nil {
			review.OrderItemID = &oid
		}
	}

	if err := h.marketplaceRepo.AddReview(c.Request.Context(), review); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to add review"})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"success": true, "review": review})
}

// ─── Cart ─────────────────────────────────────────────────────────────────────

// GetCart returns the authenticated user's cart
func (h *MarketplaceHandlers) GetCart(c *gin.Context) {
	userID, ok := getAuthUserID(c)
	if !ok {
		return
	}

	items, total, err := h.marketplaceRepo.GetCartItems(c.Request.Context(), userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to fetch cart"})
		return
	}
	if items == nil {
		items = []models.CartItem{}
	}
	c.JSON(http.StatusOK, gin.H{
		"success":   true,
		"items":     items,
		"itemCount": len(items),
		"total":     total,
	})
}

// AddToCart adds/increments a product in the cart
func (h *MarketplaceHandlers) AddToCart(c *gin.Context) {
	userID, ok := getAuthUserID(c)
	if !ok {
		return
	}

	var req models.AddToCartRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": err.Error()})
		return
	}

	productID, err := uuid.Parse(req.ProductID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid product ID"})
		return
	}

	// Verify product exists and has enough stock
	product, err := h.marketplaceRepo.GetProductByID(c.Request.Context(), productID)
	if err != nil || product == nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "error": "Product not found"})
		return
	}
	if !product.IsActive {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Product is no longer available"})
		return
	}
	if product.StockQuantity < req.Quantity {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Insufficient stock", "available": product.StockQuantity})
		return
	}

	item, err := h.marketplaceRepo.AddToCart(c.Request.Context(), userID, productID, req.Quantity)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to add item to cart"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "cartItem": item})
}

// UpdateCartItem updates the quantity of a cart item
func (h *MarketplaceHandlers) UpdateCartItem(c *gin.Context) {
	userID, ok := getAuthUserID(c)
	if !ok {
		return
	}

	itemID, err := uuid.Parse(c.Param("itemId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid item ID"})
		return
	}

	var req models.UpdateCartItemRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": err.Error()})
		return
	}

	if err := h.marketplaceRepo.UpdateCartItem(c.Request.Context(), itemID, userID, req.Quantity); err != nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "error": "Cart item not found"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Cart updated"})
}

// RemoveCartItem removes an item from the cart
func (h *MarketplaceHandlers) RemoveCartItem(c *gin.Context) {
	userID, ok := getAuthUserID(c)
	if !ok {
		return
	}

	itemID, err := uuid.Parse(c.Param("itemId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid item ID"})
		return
	}

	if err := h.marketplaceRepo.RemoveCartItem(c.Request.Context(), itemID, userID); err != nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "error": "Cart item not found"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Item removed from cart"})
}

// ─── Orders ───────────────────────────────────────────────────────────────────

// PlaceOrder converts the cart into an order
func (h *MarketplaceHandlers) PlaceOrder(c *gin.Context) {
	userID, ok := getAuthUserID(c)
	if !ok {
		return
	}

	var req models.PlaceOrderRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": err.Error()})
		return
	}

	// Load cart items
	cartItems, total, err := h.marketplaceRepo.GetCartItems(c.Request.Context(), userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to read cart"})
		return
	}
	if len(cartItems) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Cart is empty"})
		return
	}

	// Build order
	order := &models.Order{
		BuyerID:         userID,
		TotalAmount:     total,
		ShippingAddress: req.ShippingAddress,
		PaymentMethod:   req.PaymentMethod,
	}
	if req.ShippingCity != "" {
		order.ShippingCity = &req.ShippingCity
	}
	if req.ShippingPhone != "" {
		order.ShippingPhone = &req.ShippingPhone
	}
	if req.Notes != "" {
		order.Notes = &req.Notes
	}

	if err := h.marketplaceRepo.CreateOrder(c.Request.Context(), order, cartItems); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to place order"})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"success": true, "order": order})
}

// GetOrders returns orders for the authenticated buyer
func (h *MarketplaceHandlers) GetOrders(c *gin.Context) {
	userID, ok := getAuthUserID(c)
	if !ok {
		return
	}
	page, limit := parsePagination(c)

	orders, total, err := h.marketplaceRepo.GetOrders(c.Request.Context(), userID, page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to fetch orders"})
		return
	}
	if orders == nil {
		orders = []models.Order{}
	}

	pages := int(math.Ceil(float64(total) / float64(limit)))
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"orders":  orders,
		"pagination": gin.H{
			"total": total,
			"page":  page,
			"limit": limit,
			"pages": pages,
		},
	})
}

// GetOrder returns a single order with items
func (h *MarketplaceHandlers) GetOrder(c *gin.Context) {
	userID, ok := getAuthUserID(c)
	if !ok {
		return
	}

	orderID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid order ID"})
		return
	}

	order, err := h.marketplaceRepo.GetOrderByID(c.Request.Context(), orderID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to fetch order"})
		return
	}
	if order == nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "error": "Order not found"})
		return
	}
	// Users can only see their own orders
	if order.BuyerID != userID {
		c.JSON(http.StatusForbidden, gin.H{"success": false, "error": "Access denied"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "order": order})
}

// UpdateOrderStatus lets a seller/admin update the order status
func (h *MarketplaceHandlers) UpdateOrderStatus(c *gin.Context) {
	_, ok := getAuthUserID(c)
	if !ok {
		return
	}

	orderID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Invalid order ID"})
		return
	}

	var req models.UpdateOrderStatusRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": err.Error()})
		return
	}

	if err := h.marketplaceRepo.UpdateOrderStatus(c.Request.Context(), orderID, req.Status, req.TrackingNumber); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to update order status"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Order status updated"})
}

// GetSellerOrders returns orders containing items from the authenticated seller
func (h *MarketplaceHandlers) GetSellerOrders(c *gin.Context) {
	userID, ok := getAuthUserID(c)
	if !ok {
		return
	}
	page, limit := parsePagination(c)

	orders, total, err := h.marketplaceRepo.GetSellerOrders(c.Request.Context(), userID, page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "Failed to fetch seller orders"})
		return
	}
	if orders == nil {
		orders = []models.Order{}
	}

	pages := int(math.Ceil(float64(total) / float64(limit)))
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"orders":  orders,
		"pagination": gin.H{
			"total": total,
			"page":  page,
			"limit": limit,
			"pages": pages,
		},
	})
}
