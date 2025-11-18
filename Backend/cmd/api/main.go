package main

import (
	"log"
	"os"

	"pawpal-backend/internal/config"
	"pawpal-backend/internal/handlers"
	"pawpal-backend/internal/middleware"
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
	
	// Initialize services
	predictionService, err := services.NewPredictionService(cfg, logger)
	if err != nil {
		log.Fatal("Failed to initialize prediction service:", err)
	}
	
	chatbotService := services.NewChatbotService(logger)
	chatbotStreamService := services.NewChatbotStreamService(logger) // For streaming
	
	// Initialize handlers
	h := handlers.NewHandlers(predictionService, chatbotService, chatbotStreamService, logger)
	
	// Setup router
	router := setupRouter(h, cfg)
	
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

func setupRouter(h *handlers.Handlers, cfg *config.Config) *gin.Engine {
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