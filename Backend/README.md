# PawPal Backend - Dog Breed Classification API

🐕 A high-performance Go backend API for dog breed classification using ConvNeXt V2 neural network.

## Features

- **120 Dog Breeds**: Classify from 120 different dog breeds
- **High Accuracy**: 92-95% accuracy using ConvNeXt V2 model
- **Multiple Input Methods**: Upload images or provide URLs
- **Batch Processing**: Process multiple images at once
- **Test-Time Augmentation**: Improved accuracy with TTA
- **RESTful API**: Easy integration with mobile apps
- **Built-in Testing**: HTML test interface included

## Quick Start

### Prerequisites

1. **Go 1.19+** (Already installed ✅)
2. **Python 3.8+** with required packages
3. **PyTorch model files** (Already available ✅)

### Installation

1. **Install Python Dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

2. **Build and Run the Server**:
   ```bash
   cd cmd/api
   go run main.go
   ```

3. **Test the API**:
   - Open browser: http://localhost:8080/test
   - Or use Postman with the provided collection

## API Endpoints

### Health Check
```
GET /health
```

### Model Information
```
GET /api/v1/model/info
```

### Single Prediction
```
POST /api/v1/predict
Content-Type: application/json

{
  "image": "data:image/jpeg;base64,/9j/4AAQ...",
  "use_tta": true,
  "top_k": 5
}
```

### URL Prediction
```
POST /api/v1/predict/url
Content-Type: application/json

{
  "image_url": "https://example.com/dog.jpg",
  "use_tta": true,
  "top_k": 5
}
```

### Batch Prediction
```
POST /api/v1/predict/batch
Content-Type: application/json

{
  "images": ["base64_image1", "base64_image2"],
  "use_tta": false,
  "top_k": 3
}
```

### Get Supported Breeds
```
GET /api/v1/breeds
```

## Testing Options

### 1. HTML Test Interface (Recommended)
- Start the server
- Open: http://localhost:8080/test
- Upload images or paste URLs
- See live predictions

### 2. Postman Collection
- Import `PawPal_API_Collection.postman_collection.json`
- Set base URL to `http://localhost:8080`
- Test all endpoints

### 3. cURL Examples
```bash
# Health check
curl http://localhost:8080/health

# Model info
curl http://localhost:8080/api/v1/model/info

# URL prediction
curl -X POST http://localhost:8080/api/v1/predict/url \
  -H "Content-Type: application/json" \
  -d '{"image_url": "https://example.com/dog.jpg", "use_tta": true}'
```

## Configuration

### Environment Variables
```bash
PORT=8080                    # Server port
ENVIRONMENT=development      # development/production
USE_GPU=true                # Use GPU for inference
USE_TTA=true                # Enable Test-Time Augmentation
PYTHON_PATH=python          # Python executable path
DEBUG=true                  # Enable debug logging
```

### Model Paths
The backend automatically detects model files at:
- Model: `../../ML_Models/dogs/model/cat_breed_classifier_complete.pth`
- Classes: `../../ML_Models/dogs/model/class_names.json`

## Project Structure

```
Backend/
├── cmd/api/                 # Main application
│   └── main.go
├── internal/
│   ├── config/             # Configuration management
│   ├── handlers/           # HTTP handlers
│   ├── middleware/         # HTTP middleware
│   ├── models/            # Data structures
│   ├── services/          # Business logic
│   └── utils/             # Utilities
├── pkg/logger/            # Logging package
├── scripts/python/        # Python ML bridge
├── web/                   # Test HTML interface
├── assets/uploads/        # File uploads
├── go.mod                 # Go dependencies
├── requirements.txt       # Python dependencies
└── README.md             # This file
```

## Performance

- **Inference Time**: ~50ms (GPU), ~200ms (CPU)
- **Throughput**: ~20 images/second
- **Memory Usage**: ~2GB GPU memory
- **Model Size**: 350MB

## Supported Image Formats

- JPEG (.jpg, .jpeg)
- PNG (.png)
- WebP (.webp)
- Maximum size: 50MB

## Error Handling

The API returns consistent error responses:
```json
{
  "success": false,
  "error": "Error description",
  "code": 400
}
```

## Development

### Running in Development Mode
```bash
export DEBUG=true
export ENVIRONMENT=development
go run cmd/api/main.go
```

### Building for Production
```bash
go build -o pawpal-backend cmd/api/main.go
./pawpal-backend
```

## Flutter Integration

This backend is designed to work seamlessly with Flutter mobile apps:

### Flutter HTTP Example
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> predictBreed(String base64Image) async {
  final response = await http.post(
    Uri.parse('http://localhost:8080/api/v1/predict'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'image': base64Image,
      'use_tta': true,
      'top_k': 5,
    }),
  );
  
  return jsonDecode(response.body);
}
```

## Troubleshooting

### Common Issues

1. **Python Script Fails**
   - Ensure all Python packages are installed
   - Check Python path in configuration
   - Verify model files exist

2. **Model Loading Errors**
   - Check model file paths
   - Ensure sufficient disk space
   - Verify PyTorch installation

3. **GPU Issues**
   - Install CUDA-compatible PyTorch
   - Set `USE_GPU=false` for CPU-only mode

### Logs
Enable debug logging with `DEBUG=true` to see detailed information.

## License

This project is part of the PawPal application suite.

## Model Information

- **Architecture**: ConvNeXt V2 Base
- **Parameters**: 88M
- **Training Dataset**: Stanford Dogs Dataset
- **Classes**: 120 dog breeds
- **Accuracy**: 92-95%
- **Input Size**: 384x384 pixels