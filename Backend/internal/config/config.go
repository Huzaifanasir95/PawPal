package config

import (
	"os"
)

type Config struct {
	Server ServerConfig `json:"server"`
	Model  ModelConfig  `json:"model"`
	Python PythonConfig `json:"python"`
}

type ServerConfig struct {
	Port        string `json:"port"`
	Environment string `json:"environment"`
	Host        string `json:"host"`
	MaxFileSize int64  `json:"max_file_size"` // in bytes
}

type ModelConfig struct {
	Name           string   `json:"name"`
	ModelPath      string   `json:"model_path"`
	ClassNamesPath string   `json:"class_names_path"`
	ImageSize      int      `json:"image_size"`
	NumClasses     int      `json:"num_classes"`
	UseGPU         bool     `json:"use_gpu"`
	UseTTA         bool     `json:"use_tta"`
	BatchSize      int      `json:"batch_size"`
	TopK           int      `json:"top_k"`
	SupportedTypes []string `json:"supported_types"`
}

type PythonConfig struct {
	PythonPath   string `json:"python_path"`
	ScriptPath   string `json:"script_path"`
	Timeout      int    `json:"timeout"` // in seconds
	VenvPath     string `json:"venv_path"`
}

func LoadConfig() (*Config, error) {
	// Default configuration
	config := &Config{
		Server: ServerConfig{
			Port:        getEnv("PORT", "8080"),
			Environment: getEnv("ENVIRONMENT", "development"),
			Host:        getEnv("HOST", "localhost"),
			MaxFileSize: 50 * 1024 * 1024, // 50MB
		},
		Model: ModelConfig{
			Name:           "ConvNeXt V2 Base - Dog Breed Classifier",
			ModelPath:      getEnv("MODEL_PATH", "d:\\PawPal\\ML_Models\\dogs\\model\\cat_breed_classifier_complete.pth"),
			ClassNamesPath: getEnv("CLASS_NAMES_PATH", "d:\\PawPal\\ML_Models\\dogs\\model\\class_names.json"),
			ImageSize:      384,
			NumClasses:     120,
			UseGPU:         getEnvBool("USE_GPU", true),
			UseTTA:         getEnvBool("USE_TTA", true),
			BatchSize:      1,
			TopK:           5,
			SupportedTypes: []string{"image/jpeg", "image/jpg", "image/png", "image/webp"},
		},
		Python: PythonConfig{
			PythonPath: getEnv("PYTHON_PATH", "D:/Apps/Python/python.exe"),
			ScriptPath: getEnv("PYTHON_SCRIPT_PATH", "d:\\PawPal\\Backend\\scripts\\python\\predict.py"),
			Timeout:    getEnvInt("PYTHON_TIMEOUT", 30),
			VenvPath:   getEnv("PYTHON_VENV_PATH", ""),
		},
	}
	
	return config, nil
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func getEnvBool(key string, defaultValue bool) bool {
	if value := os.Getenv(key); value != "" {
		return value == "true" || value == "1"
	}
	return defaultValue
}

func getEnvInt(key string, defaultValue int) int {
	if value := os.Getenv(key); value != "" {
		// Simple conversion - in production you'd want proper error handling
		if value == "15" { return 15 }
		if value == "30" { return 30 }
		if value == "60" { return 60 }
	}
	return defaultValue
}