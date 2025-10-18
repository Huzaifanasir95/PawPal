#!/usr/bin/env python3
"""
Simple test script to verify Python environment and model paths
"""

import sys
import os
import json
from pathlib import Path

def test_python_environment():
    """Test if all required packages are available"""
    try:
        import torch
        import cv2
        import timm
        import albumentations
        import numpy as np
        from PIL import Image
        print("✅ All Python packages are available")
        return True
    except ImportError as e:
        print(f"❌ Missing package: {e}")
        return False

def test_model_files():
    """Test if model files exist"""
    
    model_path = Path("d:/PawPal/ML_Models/dogs/model/cat_breed_classifier_complete.pth")
    class_names_path = Path("d:/PawPal/ML_Models/dogs/model/class_names.json")
    
    print(f"Checking model path: {model_path}")
    print(f"Model exists: {model_path.exists()}")
    
    print(f"Checking class names path: {class_names_path}")
    print(f"Class names exist: {class_names_path.exists()}")
    
    return model_path.exists() and class_names_path.exists()

def test_model_loading():
    """Test if we can load the model"""
    try:
        model_path = Path("d:/PawPal/ML_Models/dogs/model/cat_breed_classifier_complete.pth")
        class_names_path = Path("d:/PawPal/ML_Models/dogs/model/class_names.json")
        
        import torch
        import timm
        
        # Load class names
        with open(class_names_path, 'r') as f:
            class_names = json.load(f)
        print(f"✅ Loaded {len(class_names)} class names")
        
        # Load model checkpoint
        checkpoint = torch.load(str(model_path), map_location='cpu')
        print(f"✅ Model checkpoint loaded")
        
        # Check checkpoint contents
        print(f"Checkpoint keys: {list(checkpoint.keys())}")
        
        return True
    except Exception as e:
        print(f"❌ Model loading failed: {e}")
        return False

if __name__ == "__main__":
    print("🔍 Testing Python Environment for PawPal Backend")
    print("=" * 50)
    
    # Test 1: Python packages
    print("\n1. Testing Python packages...")
    pkg_ok = test_python_environment()
    
    # Test 2: Model files
    print("\n2. Testing model files...")
    files_ok = test_model_files()
    
    # Test 3: Model loading
    if files_ok:
        print("\n3. Testing model loading...")
        model_ok = test_model_loading()
    else:
        print("\n3. Skipping model loading test (files missing)")
        model_ok = False
    
    print("\n" + "=" * 50)
    print("📋 Summary:")
    print(f"  Python packages: {'✅' if pkg_ok else '❌'}")
    print(f"  Model files: {'✅' if files_ok else '❌'}")
    print(f"  Model loading: {'✅' if model_ok else '❌'}")
    
    if pkg_ok and files_ok and model_ok:
        print("\n🎉 All tests passed! Ready for predictions.")
        sys.exit(0)
    else:
        print("\n⚠️ Some tests failed. Check the issues above.")
        sys.exit(1)