# Configuration file for Cat Breed Classification
import os
import torch

# Dataset paths
DATASET_ROOT = r"d:\PawPal\ML_Models\cats\data\cat_breeds_dataset"
IMAGES_PATH = os.path.join(DATASET_ROOT, "images")
CSV_PATH = os.path.join(DATASET_ROOT, "data", "cats.csv")

# Training parameters
BATCH_SIZE = 32
NUM_EPOCHS = 15
LEARNING_RATE = 0.001
NUM_WORKERS = 0  # Set to 0 to avoid multiprocessing issues

# Model parameters
NUM_CLASSES = 67  # Will be updated after loading dataset
MODEL_SAVE_PATH = "cat_breed_classifier.pth"
FINAL_MODEL_PATH = "cat_breed_classifier_final.pth"
CLASS_NAMES_PATH = "class_names.json"

# Image parameters
IMAGE_SIZE = 224
MEAN = [0.485, 0.456, 0.406]
STD = [0.229, 0.224, 0.225]

# Data split
TRAIN_SPLIT = 0.8
VAL_SPLIT = 0.2

# Random seed
RANDOM_SEED = 42

# Device
DEVICE = "cuda" if torch.cuda.is_available() else "cpu"