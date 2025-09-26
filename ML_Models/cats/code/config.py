# Enhanced Configuration file for Cat Breed Classification with 90%+ accuracy
import os
import torch

# Dataset paths
DATASET_ROOT = r"d:\PawPal\ML_Models\cats\data\cat_breeds_dataset"
IMAGES_PATH = os.path.join(DATASET_ROOT, "images")
CSV_PATH = os.path.join(DATASET_ROOT, "data", "cats.csv")

# Enhanced training parameters for 90%+ accuracy
BATCH_SIZE = 16  # Smaller batch size for better generalization
NUM_EPOCHS = 25  # More epochs for progressive training
LEARNING_RATE = 0.001  # Higher learning rate for classifier
NUM_WORKERS = 2  # Use more workers if system allows

# Model parameters
NUM_CLASSES = 67  # Will be updated after loading dataset
MODEL_SAVE_PATH = "cat_breed_classifier_enhanced.pth"
FINAL_MODEL_PATH = "cat_breed_classifier_final_enhanced.pth"
CLASS_NAMES_PATH = "class_names_enhanced.json"

# Enhanced image parameters
IMAGE_SIZE = 384  # Larger images for better accuracy (EfficientNetV2 works well with 384)
MEAN = [0.485, 0.456, 0.406]
STD = [0.229, 0.224, 0.225]

# Data split - more validation data for better monitoring
TRAIN_SPLIT = 0.75
VAL_SPLIT = 0.25

# Random seed
RANDOM_SEED = 42

# Device
DEVICE = "cuda" if torch.cuda.is_available() else "cpu"

# Enhanced training settings
USE_MIXUP_CUTMIX = True
MIXUP_ALPHA = 1.0
GRADIENT_CLIP_NORM = 1.0
LABEL_SMOOTHING = 0.1

# Progressive training stages
STAGE_1_EPOCHS = 5   # Train classifier only
STAGE_2_EPOCHS = 10  # Train classifier + backbone layers
STAGE_3_EPOCHS = 25  # Train entire model

# Early stopping
PATIENCE = 15

# Model architecture
MODEL_NAME = 'efficientnetv2_s'  # Options: 'efficientnetv2_s', 'convnext_tiny', 'resnet50'