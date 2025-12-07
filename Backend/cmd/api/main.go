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

	// Initialize Supabase connection
	if err := database.Initialize(); err != nil {
		log.Fatal("Failed to initialize Supabase:", err)
	}
	defer database.Close()

	// Initialize repositories using Supabase REST API
	userRepo := repositories.NewUserRepositorySupabase(database.Supabase)
	petRepo := repositories.NewPetRepositorySupabase(database.Supabase)
	logger.Info("Using Supabase REST API for all database operations")
	
	// TODO: Implement Supabase versions for other repositories
	// For now, pass nil to handlers that need them
	var healthRepo *repositories.HealthRepository = nil
	var communityRepo *repositories.CommunityRepository = nil
	var vetRepo *repositories.VetRepository = nil
	var chatRepo *repositories.ChatRepository = nil
	var messageRepo *repositories.MessageRepository = nil

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
	
	// Setup router
	router := setupRouter(h, authHandlers, petHandlers, healthHandlers, communityHandlers, vetHandlers, chatHandlers, authService, cfg)
	
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

func setupRouter(h *handlers.Handlers, authHandlers *handlers.AuthHandlers, petHandlers *handlers.PetHandlers, healthHandlers *handlers.HealthHandlers, communityHandlers *handlers.CommunityHandlers, vetHandlers *handlers.VetHandlers, chatHandlers *handlers.ChatHandlers, authService *services.AuthService, cfg *config.Config) *gin.Engine {
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

			// Vet Profiles (protected)
			vets := protected.Group("/vets")
			{
				vets.GET("/profile/me", vetHandlers.GetMyVetProfile)      // Get my vet profile
				vets.POST("/profile", vetHandlers.CreateVetProfile)       // Create/Update vet profile
			}

			// Chat & Messaging
			chats := protected.Group("/chats")
			{
				chats.POST("", chatHandlers.StartChat)                    // Start new chat
				chats.GET("", chatHandlers.GetMyChats)                    // Get my chats
				chats.GET("/:id", chatHandlers.GetChat)                   // Get specific chat
				chats.DELETE("/:id", chatHandlers.DeleteChat)             // Delete chat
			}

			messages := protected.Group("/messages")
			{
				messages.POST("", chatHandlers.SendMessage)               // Send message
				messages.GET("/:chatId", chatHandlers.GetChatMessages)    // Get chat messages
				messages.PUT("/:id/read", chatHandlers.MarkMessageAsRead) // Mark as read
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