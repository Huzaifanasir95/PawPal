# Data loading and preprocessing utilities
import os
import random
import copy
from PIL import Image
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

import torch
import torchvision
import torchvision.transforms as transforms
import torchvision.datasets as datasets
from torch.utils.data import DataLoader, Dataset, random_split

from config import *


def seed_torch(seed=RANDOM_SEED):
    """Set random seeds for reproducibility"""
    random.seed(seed)
    os.environ['PYTHONHASHSEED'] = str(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed(seed)
    torch.backends.cudnn.benchmark = False
    torch.backends.cudnn.deterministic = True


def is_image_valid(image_path):
    """Check if an image file is valid and can be opened and converted"""
    try:
        with Image.open(image_path) as img:
            # Try to load and convert to ensure it's fully readable
            img.load()
            img.convert("RGB")
        return True
    except (IOError, OSError, Image.DecompressionBombError, ValueError, TypeError):
        return False


class ValidImageDataset(Dataset):
    """Custom dataset class that filters out corrupted images"""

    def __init__(self, samples, classes, transform=None):
        self.samples = samples
        self.transform = transform
        self.classes = classes

    def __len__(self):
        return len(self.samples)

    def __getitem__(self, idx):
        img_path, label = self.samples[idx]
        try:
            image = Image.open(img_path).convert('RGB')
            if self.transform:
                image = self.transform(image)
            return image, label
        except Exception as e:
            # If image fails to load for any reason, return a placeholder
            print(f"Warning: Failed to load image {img_path}: {e}")
            if self.transform:
                # Create a placeholder image that matches the transform expectations
                placeholder = Image.new('RGB', (IMAGE_SIZE, IMAGE_SIZE), color='black')
                return self.transform(placeholder), label
            else:
                placeholder = Image.new('RGB', (IMAGE_SIZE, IMAGE_SIZE), color='black')
                return placeholder, label


def get_data_transforms():
    """Get data transformations for training and validation"""
    # Normalization values for ImageNet (since we'll use pretrained models)
    normalize = transforms.Normalize(mean=MEAN, std=STD)

    # Training transforms with augmentation
    train_transforms = transforms.Compose([
        transforms.Resize((256, 256)),
        transforms.RandomCrop(IMAGE_SIZE),
        transforms.RandomHorizontalFlip(),
        transforms.RandomRotation(15),
        transforms.ColorJitter(brightness=0.1, contrast=0.1, saturation=0.1, hue=0.1),
        transforms.ToTensor(),
        normalize
    ])

    # Validation/Test transforms (no augmentation)
    val_transforms = transforms.Compose([
        transforms.Resize((256, 256)),
        transforms.CenterCrop(IMAGE_SIZE),
        transforms.ToTensor(),
        normalize
    ])

    return train_transforms, val_transforms


def load_and_filter_dataset():
    """Load dataset, validate images, and filter out corrupted ones"""
    print("Loading and validating dataset...")

    # Set random seed
    seed_torch(RANDOM_SEED)

    # Check if local dataset exists
    if not os.path.exists(DATASET_ROOT):
        raise FileNotFoundError(f"Dataset not found at {DATASET_ROOT}")

    # Set dataset path to images folder
    dataset_path = IMAGES_PATH if os.path.exists(IMAGES_PATH) else DATASET_ROOT
    print(f"Using dataset path: {dataset_path}")

    # Get data transforms
    train_transforms, val_transforms = get_data_transforms()

    # Validate all images in the dataset
    print("Validating images in dataset...")
    valid_samples = []

    # Use the original dataset classes
    temp_dataset = datasets.ImageFolder(root=dataset_path, transform=None)

    for class_idx, class_name in enumerate(temp_dataset.classes):
        class_path = os.path.join(dataset_path, class_name)
        if os.path.isdir(class_path):
            image_files = [f for f in os.listdir(class_path)
                          if f.lower().endswith(('.jpg', '.jpeg', '.png'))]
            valid_count = 0
            for img_file in image_files:
                img_path = os.path.join(class_path, img_file)
                if is_image_valid(img_path):
                    valid_samples.append((img_path, class_idx))
                    valid_count += 1
                else:
                    print(f"Skipping corrupted image: {img_path}")
            print(f"Class '{class_name}': {valid_count}/{len(image_files)} valid images")

    print(f"\nTotal valid images: {len(valid_samples)}")
    print(f"Original dataset size: {len(temp_dataset)}")

    # Create filtered dataset
    full_dataset = ValidImageDataset(valid_samples, temp_dataset.classes, transform=None)

    # Create train/validation split
    train_size = int(TRAIN_SPLIT * len(full_dataset))
    val_size = len(full_dataset) - train_size

    train_dataset, val_dataset = random_split(
        full_dataset, [train_size, val_size],
        generator=torch.Generator().manual_seed(RANDOM_SEED)
    )

    # Apply transforms
    train_dataset.dataset.transform = train_transforms
    val_dataset.dataset.transform = val_transforms

    # Create data loaders
    train_loader = DataLoader(
        train_dataset, batch_size=BATCH_SIZE, shuffle=True,
        num_workers=NUM_WORKERS, pin_memory=True
    )
    val_loader = DataLoader(
        val_dataset, batch_size=BATCH_SIZE, shuffle=False,
        num_workers=NUM_WORKERS, pin_memory=True
    )

    # Update global variables
    global NUM_CLASSES, class_names, class_to_idx, idx_to_class
    class_names = full_dataset.classes
    NUM_CLASSES = len(class_names)
    class_to_idx = {class_name: idx for idx, class_name in enumerate(class_names)}
    idx_to_class = {v: k for k, v in class_to_idx.items()}

    print(f"Dataset loaded successfully!")
    print(f"Classes: {len(class_names)}")
    print(f"Training images: {len(train_dataset)}")
    print(f"Validation images: {len(val_dataset)}")

    return train_loader, val_loader, full_dataset, train_dataset, val_dataset


def explore_dataset():
    """Explore the dataset structure and show statistics"""
    print(f"Dataset path: {IMAGES_PATH}")

    # List all directories (breeds)
    breed_dirs = [d for d in os.listdir(IMAGES_PATH) if os.path.isdir(os.path.join(IMAGES_PATH, d))]
    print(f"\nNumber of breed folders: {len(breed_dirs)}")
    print("\nFirst 10 breed folders:")
    for i, breed in enumerate(sorted(breed_dirs)[:10]):
        print(f"{i+1}. {breed}")

    # Count images per breed
    breed_counts = {}
    total_images = 0

    for breed in breed_dirs:
        breed_path = os.path.join(IMAGES_PATH, breed)
        if os.path.exists(breed_path):
            images = [f for f in os.listdir(breed_path) if f.lower().endswith(('.jpg', '.jpeg', '.png'))]
            count = len(images)
            breed_counts[breed] = count
            total_images += count

    print(f"\nTotal images in folders: {total_images}")
    print(f"Average images per breed: {total_images / len(breed_dirs):.1f}")

    # Check CSV file
    if os.path.exists(CSV_PATH):
        print(f"\n📄 Found CSV file: {CSV_PATH}")
        cats_df = pd.read_csv(CSV_PATH)
        print(f"CSV shape: {cats_df.shape}")
        print("CSV columns:", list(cats_df.columns))

        if 'breed' in cats_df.columns:
            print(f"\nBreed distribution in CSV (top 10):")
            print(cats_df['breed'].value_counts().head(10))

            print(f"\n📊 Dataset Summary:")
            print(f"- CSV contains {len(cats_df)} cat records")
            print(f"- {len(cats_df['breed'].unique())} unique breeds in CSV")
            print(f"- {len(breed_dirs)} breed folders with images")
            print(f"- Total images in folders: {total_images}")
    else:
        print("\nNo CSV file found")


# Global variables to be updated
class_names = None
class_to_idx = None
idx_to_class = None


def get_data_loaders(batch_size=None):
    """Get train, validation, and test data loaders"""
    if batch_size is None:
        batch_size = BATCH_SIZE

    train_loader, val_loader, _, _, _ = load_and_filter_dataset()

    # For now, use validation set as test set (can be modified later)
    test_loader = val_loader

    return train_loader, val_loader, test_loader


def validate_dataset():
    """Validate dataset structure and show statistics"""
    explore_dataset()


def get_class_names():
    """Get class names (breeds)"""
    if class_names is None:
        # Load dataset to populate class names
        load_and_filter_dataset()
    return class_names


def get_transforms():
    """Get data transforms"""
    return get_data_transforms()