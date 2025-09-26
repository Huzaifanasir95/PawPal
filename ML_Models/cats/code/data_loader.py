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
from tqdm import tqdm


def seed_torch(seed=RANDOM_SEED):
    """Set random seeds for reproducibility"""
    random.seed(seed)
    os.environ['PYTHONHASHSEED'] = str(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed(seed)
    torch.backends.cudnn.benchmark = False
    torch.backends.cudnn.deterministic = True


def is_image_valid_gpu_accelerated(image_path):
    """GPU-accelerated image validation using OpenCV and CUDA"""
    try:
        # Try to use OpenCV with CUDA if available
        import cv2
        if cv2.cuda.getCudaEnabledDeviceCount() > 0:
            # Use GPU-accelerated OpenCV
            img = cv2.imread(image_path)
            if img is None:
                return False
            # Convert to RGB and check dimensions
            img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
            if img_rgb.shape[0] < 10 or img_rgb.shape[1] < 10:
                return False
            return True
        else:
            # Fallback to CPU-based validation
            img = cv2.imread(image_path)
            if img is None:
                return False
            return True
    except ImportError:
        # Fallback to PIL-based validation
        return is_image_valid(image_path)
    except Exception:
        return False


def validate_images_parallel(image_paths, max_workers=None):
    """Validate images using parallel processing for speed"""
    from concurrent.futures import ThreadPoolExecutor
    import multiprocessing

    if max_workers is None:
        max_workers = min(8, multiprocessing.cpu_count())  # Use up to 8 workers

    print(f"Validating {len(image_paths)} images using {max_workers} parallel workers...")

    def validate_single_image(img_path):
        return img_path, is_image_valid_gpu_accelerated(img_path)

    valid_samples = []
    total_processed = 0

    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = [executor.submit(validate_single_image, img_path) for img_path in image_paths]

        for future in tqdm(futures, desc="Validating images", unit="img"):
            img_path, is_valid = future.result()
            total_processed += 1

            if is_valid:
                # Extract class name from path
                class_name = os.path.basename(os.path.dirname(img_path))
                class_idx = temp_dataset.class_to_idx.get(class_name, 0)
                valid_samples.append((img_path, class_idx))

            # Progress update every 100 images
            if total_processed % 100 == 0:
                print(f"Processed {total_processed}/{len(image_paths)} images, {len(valid_samples)} valid so far")

    return valid_samples


def save_validation_cache(valid_samples, cache_path="validation_cache.pkl"):
    """Save validation results to cache file"""
    import pickle
    try:
        with open(cache_path, 'wb') as f:
            pickle.dump(valid_samples, f)
        print(f"✅ Validation cache saved to {cache_path}")
    except Exception as e:
        print(f"⚠️ Failed to save cache: {e}")


def load_validation_cache(cache_path="validation_cache.pkl"):
    """Load validation results from cache file"""
    import pickle
    try:
        if os.path.exists(cache_path):
            with open(cache_path, 'rb') as f:
                valid_samples = pickle.load(f)
            print(f"✅ Loaded {len(valid_samples)} validated images from cache")
            return valid_samples
        else:
            print("No validation cache found")
            return None
    except Exception as e:
        print(f"⚠️ Failed to load cache: {e}")
        return None


def validate_dataset_once(cache_path="validation_cache.pkl", force_revalidate=False):
    """Validate dataset once and cache results for future use"""
    global temp_dataset

    # Try to load from cache first
    if not force_revalidate:
        cached_samples = load_validation_cache(cache_path)
        if cached_samples is not None:
            return cached_samples

    print("🔍 Starting one-time dataset validation...")

    # Check if local dataset exists
    if not os.path.exists(DATASET_ROOT):
        raise FileNotFoundError(f"Dataset not found at {DATASET_ROOT}")

    # Set dataset path to images folder
    dataset_path = IMAGES_PATH if os.path.exists(IMAGES_PATH) else DATASET_ROOT
    print(f"📁 Dataset path: {dataset_path}")

    # Get basic dataset info without transforms
    temp_dataset = datasets.ImageFolder(root=dataset_path, transform=None)
    print(f"📊 Found {len(temp_dataset.classes)} classes with {len(temp_dataset)} total images")

    # Collect all image paths
    all_image_paths = []
    class_stats = {}

    for class_idx, class_name in enumerate(temp_dataset.classes):
        class_path = os.path.join(dataset_path, class_name)
        if os.path.isdir(class_path):
            image_files = [f for f in os.listdir(class_path)
                          if f.lower().endswith(('.jpg', '.jpeg', '.png'))]
            class_stats[class_name] = len(image_files)
            for img_file in image_files:
                img_path = os.path.join(class_path, img_file)
                all_image_paths.append(img_path)

    print(f"🖼️ Total images to validate: {len(all_image_paths)}")

    # Validate images in parallel
    valid_samples = validate_images_parallel(all_image_paths)

    # Show validation summary
    print(f"\n📈 Validation Summary:")
    print(f"✅ Valid images: {len(valid_samples)}/{len(all_image_paths)} ({100*len(valid_samples)/len(all_image_paths):.1f}%)")

    # Per-class statistics
    valid_per_class = {}
    for img_path, class_idx in valid_samples:
        class_name = temp_dataset.classes[class_idx]
        valid_per_class[class_name] = valid_per_class.get(class_name, 0) + 1

    print(f"\n📋 Per-class validation results:")
    for class_name in sorted(temp_dataset.classes):
        original = class_stats.get(class_name, 0)
        valid = valid_per_class.get(class_name, 0)
        percentage = 100 * valid / original if original > 0 else 0
        print(f"  {class_name}: {valid}/{original} ({percentage:.1f}%)")

    # Save to cache
    save_validation_cache(valid_samples, cache_path)

    return valid_samples


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


def load_and_filter_dataset(force_reload=False, force_revalidate=False):
    """Load dataset using cached validation results for speed"""
    global _cached_train_loader, _cached_val_loader, _cached_full_dataset
    global _cached_train_dataset, _cached_val_dataset, _dataset_loaded
    global class_names, class_to_idx, idx_to_class, NUM_CLASSES

    # Return cached data if already loaded and not forcing reload
    if _dataset_loaded and not force_reload and _cached_train_loader is not None:
        print("✅ Using cached dataset (already loaded and validated)")
        return _cached_train_loader, _cached_val_loader, _cached_full_dataset, _cached_train_dataset, _cached_val_dataset

    print("🔄 Loading dataset...")

    # Set random seed
    seed_torch(RANDOM_SEED)

    # Check if local dataset exists
    if not os.path.exists(DATASET_ROOT):
        raise FileNotFoundError(f"Dataset not found at {DATASET_ROOT}")

    # Set dataset path to images folder
    dataset_path = IMAGES_PATH if os.path.exists(IMAGES_PATH) else DATASET_ROOT
    print(f"📁 Using dataset path: {dataset_path}")

    # Get data transforms
    train_transforms, val_transforms = get_data_transforms()

    # Get validated samples (from cache or validate once)
    valid_samples = validate_dataset_once(force_revalidate=force_revalidate)

    if not valid_samples:
        raise ValueError("No valid images found in dataset!")

    print(f"✅ Loaded {len(valid_samples)} validated images")

    # Get class names from the validation process
    global temp_dataset
    if temp_dataset is None:
        temp_dataset = datasets.ImageFolder(root=dataset_path, transform=None)

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
    class_names = full_dataset.classes
    NUM_CLASSES = len(class_names)
    class_to_idx = {class_name: idx for idx, class_name in enumerate(class_names)}
    idx_to_class = {v: k for k, v in class_to_idx.items()}

    # Cache the loaded data
    _cached_train_loader = train_loader
    _cached_val_loader = val_loader
    _cached_full_dataset = full_dataset
    _cached_train_dataset = train_dataset
    _cached_val_dataset = val_dataset
    _dataset_loaded = True

    print(f"✅ Dataset loaded and cached successfully!")
    print(f"📊 Classes: {len(class_names)}")
    print(f"🖼️ Training images: {len(train_dataset)}")
    print(f"🖼️ Validation images: {len(val_dataset)}")

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


# Global variables to be updated and cached
class_names = None
class_to_idx = None
idx_to_class = None
_cached_train_loader = None
_cached_val_loader = None
_cached_full_dataset = None
_cached_train_dataset = None
_cached_val_dataset = None
_dataset_loaded = False
_cached_labels = None  # Cache for class weights computation
temp_dataset = None  # Global for validation cache


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
    global class_names

    if class_names is None:
        # Load dataset to populate class names
        load_and_filter_dataset()

    return class_names if class_names is not None else []


def get_labels_for_class_weights():
    """Get all labels for computing class weights"""
    global _cached_labels, _cached_train_dataset, _cached_val_dataset, _dataset_loaded

    # If we have cached labels, use them
    if _cached_labels is not None:
        return _cached_labels

    # If dataset is not loaded, load it (this will use cached validation)
    if not _dataset_loaded or _cached_train_dataset is None or _cached_val_dataset is None:
        load_and_filter_dataset()

    # Extract labels from cached datasets without loading images
    all_labels = []
    if _cached_train_dataset is not None:
        # Get labels from the underlying dataset using indices
        dataset = _cached_train_dataset.dataset
        indices = _cached_train_dataset.indices
        all_labels.extend([dataset.samples[idx][1] for idx in indices])
    if _cached_val_dataset is not None:
        # Get labels from the underlying dataset using indices
        dataset = _cached_val_dataset.dataset
        indices = _cached_val_dataset.indices
        all_labels.extend([dataset.samples[idx][1] for idx in indices])

    # Cache the labels for future use
    _cached_labels = np.array(all_labels)
    return _cached_labels