#!/usr/bin/env python3
"""
PawPal Backend - Python Bridge for Pet Breed Prediction
This script interfaces between the Go backend and the PyTorch model.
Supports both dog and cat breed classification.
"""

import sys
import json
import argparse
import base64
import io
import os
import time
from pathlib import Path

def setup_paths(pet_type):
    """Setup paths based on pet type"""
    script_dir = Path(__file__).parent
    if pet_type == "dog":
        ml_models_path = script_dir.parent.parent.parent / "ML_Models" / "dogs"
    else:  # cat
        ml_models_path = script_dir.parent.parent.parent / "ML_Models" / "cats"
    
    sys.path.append(str(ml_models_path))
    return ml_models_path

try:
    import torch
    import torch.nn.functional as F
    import cv2
    import numpy as np
    import timm
    from PIL import Image
    import albumentations as A
    from albumentations.pytorch import ToTensorV2
except ImportError as e:
    print(json.dumps({
        "success": False,
        "error": f"Missing required Python packages: {e}",
        "predictions": []
    }))
    sys.exit(1)

class PetBreedPredictor:
    def __init__(self, model_path, class_names_path, pet_type="dog", use_gpu=True, use_tta=True):
        self.device = torch.device('cuda' if torch.cuda.is_available() and use_gpu else 'cpu')
        self.use_tta = use_tta
        self.pet_type = pet_type
        self.image_size = 384
        
        # Load class names
        with open(class_names_path, 'r') as f:
            self.class_names = json.load(f)
        
        # Load model
        self.model = self._load_model(model_path)
        self.model.eval()
        
        # Setup transforms
        self.transform = self._get_transform()
        if self.use_tta:
            self.tta_transforms = self._get_tta_transforms()
    
    def _load_model(self, model_path):
        """Load the trained model"""
        try:
            # Create model architecture
            model = timm.create_model('convnextv2_base.fcmae', pretrained=False, num_classes=len(self.class_names))
            
            # Load checkpoint
            checkpoint = torch.load(model_path, map_location=self.device)
            
            # Handle different checkpoint formats
            if 'model_state_dict' in checkpoint:
                state_dict = checkpoint['model_state_dict']
            else:
                state_dict = checkpoint
            
            # Handle DataParallel models (remove 'module.' prefix)
            if any(key.startswith('module.') for key in state_dict.keys()):
                new_state_dict = {}
                for key, value in state_dict.items():
                    if key.startswith('module.'):
                        new_key = key[7:]  # Remove 'module.' prefix
                        new_state_dict[new_key] = value
                    else:
                        new_state_dict[key] = value
                state_dict = new_state_dict
            
            model.load_state_dict(state_dict)
            model.to(self.device)
            return model
            
        except Exception as e:
            raise RuntimeError(f"Failed to load model from {model_path}: {e}")
    
    def _get_transform(self):
        """Get standard image transforms"""
        return A.Compose([
            A.Resize(self.image_size, self.image_size),
            A.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
            ToTensorV2()
        ])
    
    def _get_tta_transforms(self):
        """Get Test-Time Augmentation transforms"""
        return [
            # Original
            A.Compose([
                A.Resize(self.image_size, self.image_size),
                A.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
                ToTensorV2()
            ]),
            # Horizontal flip
            A.Compose([
                A.Resize(self.image_size, self.image_size),
                A.HorizontalFlip(p=1.0),
                A.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
                ToTensorV2()
            ]),
            # Slight rotation
            A.Compose([
                A.Resize(self.image_size, self.image_size),
                A.Rotate(limit=5, p=1.0),
                A.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
                ToTensorV2()
            ]),
            # Color jitter
            A.Compose([
                A.Resize(self.image_size, self.image_size),
                A.ColorJitter(brightness=0.1, contrast=0.1, saturation=0.1, hue=0.05, p=1.0),
                A.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
                ToTensorV2()
            ])
        ]
    
    def _preprocess_image(self, image):
        """Preprocess image for model input"""
        # Convert PIL to numpy array
        if isinstance(image, Image.Image):
            image = np.array(image)
        
        # Convert BGR to RGB if needed (OpenCV loads as BGR)
        if len(image.shape) == 3 and image.shape[2] == 3:
            image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        
        # Apply transforms
        transformed = self.transform(image=image)
        tensor = transformed['image'].unsqueeze(0).to(self.device)
        
        return tensor
    
    def _preprocess_image_tta(self, image):
        """Preprocess image with TTA transforms"""
        # Convert PIL to numpy array
        if isinstance(image, Image.Image):
            image = np.array(image)
        
        # Convert BGR to RGB if needed
        if len(image.shape) == 3 and image.shape[2] == 3:
            image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        
        tensors = []
        for transform in self.tta_transforms:
            transformed = transform(image=image)
            tensor = transformed['image'].unsqueeze(0).to(self.device)
            tensors.append(tensor)
        
        return tensors
    
    def predict(self, image, top_k=5):
        """Make prediction on image"""
        start_time = time.time()
        
        try:
            with torch.no_grad():
                if self.use_tta:
                    # Test-Time Augmentation
                    tensors = self._preprocess_image_tta(image)
                    outputs = []
                    
                    for tensor in tensors:
                        output = self.model(tensor)
                        outputs.append(F.softmax(output, dim=1))
                    
                    # Average predictions
                    final_output = torch.mean(torch.stack(outputs), dim=0)
                else:
                    # Standard prediction
                    tensor = self._preprocess_image(image)
                    output = self.model(tensor)
                    final_output = F.softmax(output, dim=1)
                
                # Get top predictions
                probabilities, indices = torch.topk(final_output, top_k)
                probabilities = probabilities.cpu().numpy()[0]
                indices = indices.cpu().numpy()[0]
                
                # Format results
                predictions = []
                for i, (prob, idx) in enumerate(zip(probabilities, indices)):
                    breed_name = self.class_names[idx]
                    
                    # Clean breed name (remove numbers, underscores, etc.)
                    clean_name = breed_name.replace('_', ' ').replace('-', ' ')
                    clean_name = ' '.join(word.capitalize() for word in clean_name.split())
                    
                    predictions.append({
                        "breed": clean_name,
                        "raw_breed": breed_name,
                        "confidence": float(prob),
                        "rank": i + 1
                    })
                
                process_time = (time.time() - start_time) * 1000  # Convert to ms
                
                return {
                    "success": True,
                    "predicted_breed": predictions[0]["breed"] if predictions else "Unknown",
                    "confidence": float(predictions[0]["confidence"]) if predictions else 0.0,
                    "predictions": predictions,
                    "process_time_ms": process_time,
                    "used_tta": self.use_tta,
                    "device": str(self.device),
                    "pet_type": self.pet_type
                }
                
        except Exception as e:
            return {
                "success": False,
                "error": f"Prediction failed: {str(e)}",
                "predictions": [],
                "pet_type": self.pet_type
            }

def decode_base64_image(base64_string):
    """Decode base64 string to PIL Image"""
    try:
        # Remove data URL prefix if present
        if base64_string.startswith('data:image'):
            base64_string = base64_string.split(',')[1]
        
        # Decode base64
        image_data = base64.b64decode(base64_string)
        
        # Create PIL Image
        image = Image.open(io.BytesIO(image_data))
        
        # Convert to RGB if necessary
        if image.mode != 'RGB':
            image = image.convert('RGB')
        
        return image
        
    except Exception as e:
        raise ValueError(f"Failed to decode image: {e}")

def main():
    parser = argparse.ArgumentParser(description='Pet Breed Prediction Service')
    parser.add_argument('--model-path', required=True, help='Path to model file')
    parser.add_argument('--class-names-path', required=True, help='Path to class names JSON')
    parser.add_argument('--pet-type', choices=['dog', 'cat'], default='dog', help='Type of pet to classify')
    parser.add_argument('--image', help='Base64 encoded image (optional)')
    parser.add_argument('--image-file', help='Path to file containing base64 image data')
    parser.add_argument('--use-tta', action='store_true', help='Use Test-Time Augmentation')
    parser.add_argument('--use-gpu', action='store_true', help='Use GPU if available')
    parser.add_argument('--top-k', type=int, default=5, help='Number of top predictions')
    parser.add_argument('--stdin', action='store_true', help='Read image data from stdin')
    
    args = parser.parse_args()
    
    try:
        # Setup paths for the specific pet type
        setup_paths(args.pet_type)
        
        # Initialize predictor
        predictor = PetBreedPredictor(
            model_path=args.model_path,
            class_names_path=args.class_names_path,
            pet_type=args.pet_type,
            use_gpu=args.use_gpu,
            use_tta=args.use_tta
        )
        
        # Get image data
        if args.image_file:
            # Read from file
            with open(args.image_file, 'r') as f:
                image_data = f.read().strip()
        elif args.stdin:
            # Read from stdin
            image_data = sys.stdin.read().strip()
        elif args.image:
            # Use command line argument
            image_data = args.image
        else:
            raise ValueError("No image data provided")
        
        if not image_data:
            raise ValueError("No image data provided")
        
        # Decode image
        image = decode_base64_image(image_data)
        
        # Make prediction
        result = predictor.predict(image, top_k=args.top_k)
        
        # Output JSON result
        print(json.dumps(result))
        
    except Exception as e:
        error_result = {
            "success": False,
            "error": str(e),
            "predictions": [],
            "pet_type": args.pet_type if 'args' in locals() else "unknown"
        }
        print(json.dumps(error_result))
        sys.exit(1)

if __name__ == "__main__":
    main()