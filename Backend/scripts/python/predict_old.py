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
        self.val_transform = self._get_val_transforms()
        self.tta_transforms = self._get_tta_transforms() if use_tta else [self.val_transform]
    
    def _load_model(self, model_path):
        """Load the trained ConvNeXt V2 model"""
        # Load checkpoint
        checkpoint = torch.load(model_path, map_location=self.device)
        
        # Extract config from checkpoint
        config = checkpoint.get('config', {})
        model_name = config.get('MODEL_NAME', 'convnextv2_base.fcmae_ft_in22k_in1k_384')
        num_classes = config.get('NUM_CLASSES', 120)
        
        # Create model
        model = timm.create_model(
            model_name,
            pretrained=False,
            num_classes=num_classes,
            drop_rate=0.3,
            drop_path_rate=0.2
        )
        
        # Load state dict
        state_dict = checkpoint['model_state_dict']
        
        # Handle DataParallel wrapper
        if 'module.' in list(state_dict.keys())[0]:
            # Remove 'module.' prefix from keys
            new_state_dict = {}
            for k, v in state_dict.items():
                new_key = k.replace('module.', '')
                new_state_dict[new_key] = v
            state_dict = new_state_dict
        
        model.load_state_dict(state_dict)
        model.to(self.device)
        
        return model
    
    def _get_val_transforms(self):
        """Get validation transforms"""
        return A.Compose([
            A.Resize(self.image_size, self.image_size),
            A.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
            ToTensorV2()
        ])
    
    def _get_tta_transforms(self):
        """Get Test-Time Augmentation transforms"""
        return [
            A.Compose([
                A.Resize(self.image_size, self.image_size),
                A.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
                ToTensorV2()
            ]),
            A.Compose([
                A.Resize(self.image_size, self.image_size),
                A.HorizontalFlip(p=1.0),
                A.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
                ToTensorV2()
            ]),
            A.Compose([
                A.Resize(self.image_size, self.image_size),
                A.ShiftScaleRotate(shift_limit=0.0, scale_limit=0.0, rotate_limit=5, p=1.0),
                A.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
                ToTensorV2()
            ]),
            A.Compose([
                A.Resize(self.image_size, self.image_size),
                A.ShiftScaleRotate(shift_limit=0.0, scale_limit=0.0, rotate_limit=-5, p=1.0),
                A.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
                ToTensorV2()
            ]),
        ]
    
    def predict(self, image, top_k=5):
        """
        Predict dog breed from image
        
        Args:
            image: PIL Image or numpy array
            top_k: Number of top predictions to return
            
        Returns:
            dict: Prediction results
        """
        start_time = time.time()
        
        try:
            # Convert to numpy array if needed
            if isinstance(image, Image.Image):
                image = np.array(image)
            
            # Ensure RGB format
            if len(image.shape) == 3 and image.shape[2] == 3:
                image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
            
            # Apply transforms and get predictions
            if self.use_tta and len(self.tta_transforms) > 1:
                all_probs = []
                for transform in self.tta_transforms:
                    augmented = transform(image=image)
                    img_tensor = augmented['image'].unsqueeze(0).to(self.device)
                    
                    with torch.no_grad():
                        outputs = self.model(img_tensor)
                        probs = F.softmax(outputs, dim=1)
                        all_probs.append(probs.cpu().numpy())
                
                # Average predictions
                avg_probs = np.mean(all_probs, axis=0)[0]
                used_tta = True
            else:
                # Single prediction
                augmented = self.val_transform(image=image)
                img_tensor = augmented['image'].unsqueeze(0).to(self.device)
                
                with torch.no_grad():
                    outputs = self.model(img_tensor)
                    probs = F.softmax(outputs, dim=1)
                    avg_probs = probs.cpu().numpy()[0]
                used_tta = False
            
            # Get top K predictions
            top_indices = np.argsort(avg_probs)[-top_k:][::-1]
            
            predictions = []
            for i, idx in enumerate(top_indices):
                breed_name = self.class_names[idx]
                # Clean breed name (remove ID prefix)
                clean_name = breed_name.split('-', 1)[-1].replace('_', ' ').title()
                
                predictions.append({
                    "breed": clean_name,
                    "raw_breed": breed_name,
                    "confidence": float(avg_probs[idx]),
                    "rank": i + 1
                })
            
            process_time = (time.time() - start_time) * 1000  # Convert to milliseconds
            
            return {
                "success": True,
                "predicted_breed": predictions[0]["breed"],
                "confidence": predictions[0]["confidence"],
                "predictions": predictions,
                "process_time_ms": process_time,
                "used_tta": used_tta,
                "device": str(self.device)
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "predictions": []
            }

def decode_base64_image(base64_string):
    """Decode base64 string to PIL Image"""
    try:
        # Remove data URL prefix if present
        if ',' in base64_string:
            base64_string = base64_string.split(',')[1]
        
        # Decode base64
        image_data = base64.b64decode(base64_string)
        
        # Convert to PIL Image
        image = Image.open(io.BytesIO(image_data))
        
        # Convert to RGB if needed
        if image.mode != 'RGB':
            image = image.convert('RGB')
        
        return image
    except Exception as e:
        raise ValueError(f"Failed to decode base64 image: {e}")

def main():
    parser = argparse.ArgumentParser(description='Dog Breed Prediction Service')
    parser.add_argument('--model-path', required=True, help='Path to model file')
    parser.add_argument('--class-names-path', required=True, help='Path to class names JSON')
    parser.add_argument('--image', help='Base64 encoded image (optional)')
    parser.add_argument('--image-file', help='Path to file containing base64 image data')
    parser.add_argument('--use-tta', action='store_true', help='Use Test-Time Augmentation')
    parser.add_argument('--use-gpu', action='store_true', help='Use GPU if available')
    parser.add_argument('--top-k', type=int, default=5, help='Number of top predictions')
    parser.add_argument('--stdin', action='store_true', help='Read image data from stdin')
    
    args = parser.parse_args()
    
    try:
        # Initialize predictor
        predictor = DogBreedPredictor(
            model_path=args.model_path,
            class_names_path=args.class_names_path,
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
            "predictions": []
        }
        print(json.dumps(error_result))
        sys.exit(1)

if __name__ == "__main__":
    main()