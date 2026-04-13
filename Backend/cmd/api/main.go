package main

import (
	"log"
	"os"

	"pawpal-backend/internal/config"
	"pawpal-backend/internal/database"
	"pawpal-backend/internal/handlers"
	"pawpal-backend/internal/middleware"
	"pawpal-backend/internal/repositories"
	"pawpal-backend/internal/services"
	"pawpal-backend/pkg/logger"

	"github.com/gin-gonic/gin"
)

func main() {
	// Initialize logger
	logger := logger.NewLogger()

	// Load configuration
	cfg, err := config.LoadConfig()
	if err != nil {
		log.Fatal("Failed to load configuration:", err)
	}

	// Initialize database connection
	dbEnabled := true
	if err := database.Initialize(); err != nil {
		log.Printf("Warning: Failed to initialize database: %v", err)
		log.Println("Running without database support - PostgreSQL endpoints will not work")
		dbEnabled = false
	}
	if dbEnabled {
		defer database.Close()
	}

	// Get database pool (may be nil if database not available)
	db := database.GetDB()

	// Initialize repositories
	userRepo := repositories.NewUserRepository(db)
	petRepo := repositories.NewPetRepository(db)
	healthRepo := repositories.NewHealthRepository(db)
	communityRepo := repositories.NewCommunityRepository(db)
	vetRepo := repositories.NewVetRepository(db)
	chatRepo := repositories.NewChatRepository(db)
	messageRepo := repositories.NewMessageRepository(db)
	marketplaceRepo := repositories.NewMarketplaceRepository(db)
	communityHubRepo := repositories.NewCommunityHubRepository(db)
	caregiverRepo := repositories.NewCaregiverRepository(db)
	bookingRepo := repositories.NewBookingRepository(db)

	// Initialize auth service
	authService := services.NewAuthService(userRepo)

	// Initialize services for ML
	predictionService, err := services.NewPredictionService(cfg, logger)
	if err != nil {
		log.Fatal("Failed to initialize prediction service:", err)
	}

	chatbotService := services.NewChatbotService(logger)
	chatbotStreamService := services.NewChatbotStreamService(logger) // For streaming

	// Initialize handlers
	h := handlers.NewHandlers(predictionService, chatbotService, chatbotStreamService, logger)
	authHandlers := handlers.NewAuthHandlers(authService)
	petHandlers := handlers.NewPetHandlers(petRepo)
	healthHandlers := handlers.NewHealthHandlers(healthRepo, petRepo)
	communityHandlers := handlers.NewCommunityHandlers(communityRepo, userRepo)
	vetHandlers := handlers.NewVetHandlers(vetRepo)
	chatHandlers := handlers.NewChatHandlers(chatRepo, messageRepo, userRepo, vetRepo)
	wsHandler := handlers.NewWebSocketHandler(messageRepo, chatRepo)
	marketplaceHandlers := handlers.NewMarketplaceHandlers(marketplaceRepo, userRepo)
	communityHubHandlers := handlers.NewCommunityHubHandlers(communityHubRepo, userRepo)
	caregiverHandlers := handlers.NewCaregiverHandler(caregiverRepo, bookingRepo, userRepo)
	bookingHandlers := handlers.NewBookingHandler(bookingRepo, caregiverRepo)

	// Setup router
	router := setupRouter(h, authHandlers, petHandlers, healthHandlers, communityHandlers, vetHandlers, chatHandlers, wsHandler, marketplaceHandlers, communityHubHandlers, caregiverHandlers, bookingHandlers, authService, cfg)

	// Start server
	port := os.Getenv("PORT")
	if port == "" {
		port = cfg.Server.Port
	}

	logger.Info("Starting PawPal Backend API server on port " + port)
	logger.Info("Models: ConvNeXt V2 - Dog Breed Classifier (120 breeds) & Cat Breed Classifier")
	logger.Info("Access at: http://localhost:" + port)

	if err := router.Run(":" + port); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}

func setupRouter(h *handlers.Handlers, authHandlers *handlers.AuthHandlers, petHandlers *handlers.PetHandlers, healthHandlers *handlers.HealthHandlers, communityHandlers *handlers.CommunityHandlers, vetHandlers *handlers.VetHandlers, chatHandlers *handlers.ChatHandlers, wsHandler *handlers.WebSocketHandler, marketplaceHandlers *handlers.MarketplaceHandlers, communityHubHandlers *handlers.CommunityHubHandlers, caregiverHandlers *handlers.CaregiverHandler, bookingHandlers *handlers.BookingHandler, authService *services.AuthService, cfg *config.Config) *gin.Engine {
	// Set Gin mode
	if cfg.Server.Environment == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	router := gin.New()

	// Global middleware
	router.Use(gin.Logger())
	router.Use(gin.Recovery())
	router.Use(middleware.CORS())
	router.Use(middleware.RequestLogger())

	// Health check endpoint
	router.GET("/health", h.HealthCheck)

	// API routes
	v1 := router.Group("/api/v1")
	{
		// Model info
		v1.GET("/model/info", h.GetModelInfo)

		// Prediction endpoints
		v1.POST("/predict", h.PredictSingle)
		v1.POST("/predict/batch", h.PredictBatch)
		v1.POST("/predict/url", h.PredictFromURL)

		// Chatbot endpoints
		v1.POST("/chatbot/query", h.ChatbotQuery)
		v1.POST("/chatbot/stream", h.ChatbotQueryStream) // Streaming endpoint

		// Utility endpoints
		v1.GET("/breeds", h.GetSupportedBreeds)

		// Public marketplace routes
		publicMarket := v1.Group("/marketplace")
		{
			publicMarket.GET("/categories", marketplaceHandlers.GetCategories)
			publicMarket.GET("/products", marketplaceHandlers.GetProducts)
			publicMarket.GET("/products/:id", marketplaceHandlers.GetProduct)
			publicMarket.GET("/products/:id/reviews", marketplaceHandlers.GetProductReviews)
		}

		// Public vet browsing (no auth required)
		publicVets := v1.Group("/vets")
		{
			publicVets.GET("", vetHandlers.ListVets)                      // List all vets (public)
			publicVets.GET("/profile/:userId", vetHandlers.GetVetProfile) // Get vet profile (public)
		}

		// Authentication endpoints (public)
		auth := v1.Group("/auth")
		{
			auth.POST("/signup", authHandlers.SignUp)
			auth.POST("/signin", authHandlers.SignIn)
			auth.POST("/google", authHandlers.SignInWithGoogle)
			auth.POST("/refresh", authHandlers.RefreshToken)
			auth.POST("/signout", authHandlers.SignOut)
			auth.POST("/password/reset-request", authHandlers.RequestPasswordReset)
			auth.POST("/password/reset", authHandlers.ResetPassword)
		}

		// Protected routes - require authentication
		protected := v1.Group("")
		protected.Use(middleware.AuthMiddleware(authService))
		{
			// User profile and role
			protected.GET("/profile", authHandlers.GetProfile)
			protected.PUT("/profile", authHandlers.UpdateProfile)
			protected.POST("/auth/set-role", authHandlers.SetUserRole)
			protected.GET("/user/roles", authHandlers.GetUserRoles)
			protected.POST("/user/roles/add", authHandlers.AddUserRole)
			protected.POST("/user/roles/switch", authHandlers.SwitchActiveRole)

			// Vet Profiles (protected)
			vets := protected.Group("/vets")
			{
				vets.GET("/profile/me", vetHandlers.GetMyVetProfile) // Get my vet profile
				vets.POST("/profile", vetHandlers.CreateVetProfile)  // Create/Update vet profile
			}

			// Chat & Messaging
			chats := protected.Group("/chats")
			{
				chats.POST("", chatHandlers.StartChat)        // Start new chat
				chats.GET("", chatHandlers.GetMyChats)        // Get my chats
				chats.GET("/:id", chatHandlers.GetChat)       // Get specific chat
				chats.DELETE("/:id", chatHandlers.DeleteChat) // Delete chat
			}

			messages := protected.Group("/messages")
			{
				messages.POST("", chatHandlers.SendMessage)               // Send message
				messages.GET("/:chatId", chatHandlers.GetChatMessages)    // Get chat messages
				messages.PUT("/:id/read", chatHandlers.MarkMessageAsRead) // Mark as read
			}

			// WebSocket for real-time messaging (uses its own auth middleware)
			ws := v1.Group("/ws")
			ws.Use(middleware.WebSocketAuthMiddleware(authService))
			{
				ws.GET("/chat/:chatId", wsHandler.HandleWebSocket) // WebSocket connection
			}

			// Pets
			pets := protected.Group("/pets")
			{
				pets.POST("", petHandlers.CreatePet)
				pets.GET("", petHandlers.GetPets)
				pets.GET("/verified", petHandlers.GetVerifiedPets)
				pets.GET("/search", petHandlers.SearchPetsByBreed)
				pets.GET("/count", petHandlers.GetPetCount)
				pets.GET("/:id", petHandlers.GetPet)
				pets.PUT("/:id", petHandlers.UpdatePet)
				pets.DELETE("/:id", petHandlers.DeletePet)
			}

			// Health Records
			healthRecords := protected.Group("/health-records")
			{
				healthRecords.POST("", healthHandlers.CreateHealthRecord)
				healthRecords.GET("/pet/:petId", healthHandlers.GetHealthRecord)
				healthRecords.PUT("/:id", healthHandlers.UpdateHealthRecord)
				healthRecords.DELETE("/:id", healthHandlers.DeleteHealthRecord)
			}

			// Health Journals
			healthJournals := protected.Group("/health-journals")
			{
				healthJournals.POST("", healthHandlers.CreateHealthJournal)
				healthJournals.GET("/pet/:petId", healthHandlers.GetHealthJournals)
				healthJournals.GET("/:id", healthHandlers.GetHealthJournal)
				healthJournals.DELETE("/:id", healthHandlers.DeleteHealthJournal)
			}

			// Community - Posts
			posts := protected.Group("/posts")
			{
				posts.POST("", communityHandlers.CreatePost)
				posts.GET("", communityHandlers.GetPosts)
				posts.GET("/me", communityHandlers.GetMyPosts)
				posts.GET("/user/:userId", communityHandlers.GetUserPosts)
				posts.GET("/:id", communityHandlers.GetPost)
				posts.PUT("/:id", communityHandlers.UpdatePost)
				posts.DELETE("/:id", communityHandlers.DeletePost)
				posts.POST("/:id/like", communityHandlers.TogglePostLike)
				posts.GET("/:id/liked", communityHandlers.HasUserLikedPost)
			}

			// Community - Comments
			comments := protected.Group("/comments")
			{
				comments.POST("", communityHandlers.CreateComment)
				comments.GET("/post/:postId", communityHandlers.GetComments)
				comments.DELETE("/:id", communityHandlers.DeleteComment)
				comments.POST("/:id/like", communityHandlers.ToggleCommentLike)
			}

			// Marketplace - protected routes
			market := protected.Group("/marketplace")
			{
				// Seller: manage own products
				market.POST("/products", marketplaceHandlers.CreateProduct)
				market.GET("/products/mine", marketplaceHandlers.GetMyProducts)
				market.PUT("/products/:id", marketplaceHandlers.UpdateProduct)
				market.DELETE("/products/:id", marketplaceHandlers.DeleteProduct)

				// Product reviews
				market.POST("/products/:id/reviews", marketplaceHandlers.AddProductReview)

				// Shopping cart
				market.GET("/cart", marketplaceHandlers.GetCart)
				market.POST("/cart", marketplaceHandlers.AddToCart)
				market.PUT("/cart/:itemId", marketplaceHandlers.UpdateCartItem)
				market.DELETE("/cart/:itemId", marketplaceHandlers.RemoveCartItem)

				// Orders
				market.POST("/orders", marketplaceHandlers.PlaceOrder)
				market.GET("/orders", marketplaceHandlers.GetOrders)
				market.GET("/orders/:id", marketplaceHandlers.GetOrder)
				market.PUT("/orders/:id/status", marketplaceHandlers.UpdateOrderStatus)

				// Seller orders view
				market.GET("/seller/orders", marketplaceHandlers.GetSellerOrders)
			}

			// Community Hub - Lost & Found
			lostFound := protected.Group("/lost-found")
			{
				lostFound.POST("", communityHubHandlers.CreateLostFound)
				lostFound.GET("", communityHubHandlers.GetLostFoundPosts)
				lostFound.GET("/me", communityHubHandlers.GetMyLostFoundPosts)
				lostFound.GET("/:id", communityHubHandlers.GetLostFoundByID)
				lostFound.PUT("/:id", communityHubHandlers.UpdateLostFound)
				lostFound.DELETE("/:id", communityHubHandlers.DeleteLostFound)
			}

			// Community Hub - Adoption Listings
			adoptions := protected.Group("/adoptions")
			{
				adoptions.POST("", communityHubHandlers.CreateAdoption)
				adoptions.GET("", communityHubHandlers.GetAdoptionListings)
				adoptions.GET("/me", communityHubHandlers.GetMyAdoptionListings)
				adoptions.GET("/:id", communityHubHandlers.GetAdoptionByID)
				adoptions.PUT("/:id", communityHubHandlers.UpdateAdoption)
				adoptions.DELETE("/:id", communityHubHandlers.DeleteAdoption)
			}

			// Community Hub - Events & Meetups
			events := protected.Group("/events")
			{
				events.POST("", communityHubHandlers.CreateEvent)
				events.GET("", communityHubHandlers.GetEvents)
				events.GET("/me", communityHubHandlers.GetMyEvents)
				events.GET("/:id", communityHubHandlers.GetEventByID)
				events.PUT("/:id", communityHubHandlers.UpdateEvent)
				events.DELETE("/:id", communityHubHandlers.DeleteEvent)
				events.POST("/:id/rsvp", communityHubHandlers.RSVPEvent)
				events.DELETE("/:id/rsvp", communityHubHandlers.CancelRSVP)
				events.GET("/:id/rsvps", communityHubHandlers.GetEventRSVPs)
				events.GET("/:id/rsvp/me", communityHubHandlers.GetMyRSVP)
			}

			// Caregiver Services
			caregivers := protected.Group("/caregivers")
			{
				// Service Types (public within auth)
				caregivers.GET("/service-types", caregiverHandlers.GetServiceTypes)

				// Profile management (for caregivers)
				caregivers.POST("/profile", caregiverHandlers.CreateProfile)
				caregivers.GET("/profile", caregiverHandlers.GetProfile)
				caregivers.PUT("/profile", caregiverHandlers.UpdateProfile)

				// Service management (for caregivers)
				caregivers.POST("/services", caregiverHandlers.AddService)
				caregivers.PUT("/services/:id", caregiverHandlers.UpdateService)
				caregivers.DELETE("/services/:id", caregiverHandlers.DeleteService)

				// Availability management (for caregivers)
				caregivers.POST("/availability", caregiverHandlers.SetAvailability)
				caregivers.GET("/availability", caregiverHandlers.GetAvailability)
				caregivers.POST("/blocked-dates", caregiverHandlers.AddBlockedDate)
				caregivers.DELETE("/blocked-dates/:date", caregiverHandlers.RemoveBlockedDate)

				// Gallery management (for caregivers)
				caregivers.POST("/gallery", caregiverHandlers.AddGalleryImage)
				caregivers.DELETE("/gallery/:id", caregiverHandlers.DeleteGalleryImage)

				// Search caregivers (for pet owners)
				caregivers.GET("/search", caregiverHandlers.SearchCaregivers)

				// View specific caregiver (public within auth)
				caregivers.GET("/:id", caregiverHandlers.GetCaregiverByID)
				caregivers.GET("/:id/reviews", caregiverHandlers.GetReviews)
			}

			// Booking management
			bookings := protected.Group("/bookings")
			{
				// Create and view bookings
				bookings.POST("", bookingHandlers.CreateBooking)
				bookings.GET("", bookingHandlers.GetMyBookings)
				bookings.GET("/:id", bookingHandlers.GetBooking)

				// Booking lifecycle
				bookings.POST("/:id/respond", bookingHandlers.RespondToBooking)
				bookings.POST("/:id/cancel", bookingHandlers.CancelBooking)
				bookings.POST("/:id/start", bookingHandlers.StartService)

				// Tracking during service
				bookings.POST("/:id/tracking", bookingHandlers.UpdateTracking)
				bookings.GET("/:id/tracking", bookingHandlers.GetTracking)

				// Service completion
				bookings.POST("/:id/complete", bookingHandlers.SubmitCompletionReport)

				// Reviews
				bookings.POST("/:id/review/owner", bookingHandlers.SubmitOwnerReview)
				bookings.POST("/:id/review/caregiver", bookingHandlers.SubmitCaregiverReview)

				// Incidents
				bookings.POST("/:id/incidents", bookingHandlers.ReportIncident)
				bookings.GET("/:id/incidents", bookingHandlers.GetIncidents)

				// Payments
				bookings.POST("/:id/payments", bookingHandlers.ProcessPayment)
				bookings.GET("/:id/payments", bookingHandlers.GetPayments)
			}
		}
	}

	// Serve static files for uploads (if needed)
	router.Static("/uploads", "./assets/uploads")

	// Serve test HTML page
	router.Static("/web", "./web")
	router.GET("/test", func(c *gin.Context) {
		c.File("./web/test.html")
	})
	router.GET("/test/chatbot", func(c *gin.Context) {
		c.File("./web/chatbot_test.html")
	})
	router.GET("/test/chatbot_stream", func(c *gin.Context) {
		c.File("./web/chatbot_stream_test.html")
	})

	return router
}
