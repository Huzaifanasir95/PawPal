#!/usr/bin/env python3
"""
Analyze the Cat Breeds Refined 7k dataset from cache
"""

import os
from pathlib import Path
from collections import Counter
import glob

def find_catbreeds_dataset():
    """Find the Cat Breeds Refined dataset in cache"""
    
    # Common cache locations
    cache_locations = [
        r"C:\Users\nasir\.cache\kagglehub\datasets\doctrinek\catbreedsrefined-7k",
        r"C:\Users\%USERNAME%\.cache\kagglehub\datasets\doctrinek\catbreedsrefined-7k",
        r"C:\Users\*\.cache\kagglehub\datasets\doctrinek\catbreedsrefined-7k"
    ]
    
    print("🔍 Searching for Cat Breeds Refined dataset...")
    
    for location in cache_locations:
        # Expand wildcards and environment variables
        expanded_paths = glob.glob(os.path.expandvars(location))
        
        for path in expanded_paths:
            if os.path.exists(path):
                print(f"✅ Found dataset at: {path}")
                return path
    
    # Manual search in common locations
    base_paths = [
        r"C:\Users\nasir\.cache\kagglehub\datasets",
        r"C:\Users\nasir\.kaggle\datasets"
    ]
    
    for base_path in base_paths:
        if os.path.exists(base_path):
            print(f"🔍 Searching in: {base_path}")
            for root, dirs, files in os.walk(base_path):
                if 'catbreedsrefined' in root.lower() or 'catbreeds' in root.lower():
                    print(f"✅ Found potential dataset at: {root}")
                    return root
    
    return None

def analyze_catbreeds_from_cache():
    """Analyze the cached Cat Breeds Refined dataset"""
    
    print("🐱 Analyzing Cat Breeds Refined 7k Dataset from Cache...")
    print("=" * 60)
    
    # Find the dataset
    dataset_path = find_catbreeds_dataset()
    
    if not dataset_path:
        print("❌ Dataset not found in cache!")
        print("💡 Try downloading it first with kagglehub")
        return None
    
    print(f"📁 Dataset location: {dataset_path}")
    
    # Explore directory structure
    print(f"\n📁 Directory Structure:")
    print("=" * 40)
    
    def print_tree(directory, prefix="", max_depth=2, current_depth=0):
        """Print directory tree structure"""
        if current_depth >= max_depth:
            return
            
        try:
            items = sorted(os.listdir(directory))
        except PermissionError:
            print(f"{prefix}[Permission Denied]")
            return
            
        for i, item in enumerate(items):
            item_path = os.path.join(directory, item)
            is_last = i == len(items) - 1
            
            current_prefix = "└── " if is_last else "├── "
            
            if os.path.isdir(item_path):
                # Count images in directory
                image_count = len([f for f in os.listdir(item_path) 
                                 if f.lower().endswith(('.jpg', '.jpeg', '.png', '.bmp'))])
                if image_count > 0:
                    print(f"{prefix}{current_prefix}{item}/ ({image_count} images)")
                else:
                    print(f"{prefix}{current_prefix}{item}/")
                
                if current_depth < max_depth - 1:
                    extension = "    " if is_last else "│   "
                    print_tree(item_path, prefix + extension, max_depth, current_depth + 1)
            else:
                print(f"{prefix}{current_prefix}{item}")
    
    print_tree(dataset_path)
    
    # Find images directory
    images_dir = None
    
    # Check for common image directory names
    possible_dirs = ['images', 'data', 'train', 'dataset']
    
    for possible_dir in possible_dirs:
        potential_path = os.path.join(dataset_path, possible_dir)
        if os.path.exists(potential_path):
            # Check if it contains images or subdirectories with images
            subdirs = [d for d in os.listdir(potential_path) 
                      if os.path.isdir(os.path.join(potential_path, d))]
            if subdirs:
                images_dir = potential_path
                print(f"📸 Found images directory: {images_dir}")
                break
    
    # If no subdirectory found, check if root contains breed folders
    if not images_dir:
        subdirs = [d for d in os.listdir(dataset_path) 
                  if os.path.isdir(os.path.join(dataset_path, d))]
        
        # Check if these subdirectories contain images
        breed_dirs = []
        for subdir in subdirs:
            subdir_path = os.path.join(dataset_path, subdir)
            image_files = [f for f in os.listdir(subdir_path) 
                          if f.lower().endswith(('.jpg', '.jpeg', '.png', '.bmp'))]
            if image_files:
                breed_dirs.append(subdir)
        
        if breed_dirs:
            images_dir = dataset_path
            print(f"📸 Found breed directories in root: {dataset_path}")
    
    if not images_dir:
        print("❌ No images directory found!")
        return None
    
    # Analyze breed structure
    print(f"\n🔍 Analyzing breed structure...")
    
    breed_dirs = [d for d in os.listdir(images_dir) 
                 if os.path.isdir(os.path.join(images_dir, d))]
    
    if not breed_dirs:
        print("❌ No breed directories found!")
        return None
    
    print(f"📂 Found {len(breed_dirs)} breed directories")
    
    # Count images per breed
    breed_counts = {}
    total_images = 0
    
    print(f"\n📊 Counting images per breed...")
    
    for breed in breed_dirs:
        breed_path = os.path.join(images_dir, breed)
        if os.path.isdir(breed_path):
            image_files = [f for f in os.listdir(breed_path) 
                          if f.lower().endswith(('.jpg', '.jpeg', '.png', '.bmp'))]
            breed_counts[breed] = len(image_files)
            total_images += len(image_files)
    
    # Sort breeds by count
    sorted_breeds = sorted(breed_counts.items(), key=lambda x: x[1], reverse=True)
    
    print(f"\n🐱 CAT BREEDS ANALYSIS:")
    print("=" * 50)
    print(f"🎯 TOTAL CAT BREEDS: {len(breed_counts)}")
    print(f"📸 TOTAL IMAGES: {total_images:,}")
    
    print(f"\n📈 ALL BREEDS (sorted by image count):")
    print("-" * 50)
    
    for i, (breed, count) in enumerate(sorted_breeds, 1):
        print(f"   {i:2d}. {breed:<30} : {count:4d} images")
    
    # Calculate statistics
    counts = list(breed_counts.values())
    min_count = min(counts)
    max_count = max(counts)
    mean_count = sum(counts) / len(counts)
    median_count = sorted(counts)[len(counts)//2]
    
    print(f"\n📊 STATISTICS:")
    print(f"   Min images per breed: {min_count}")
    print(f"   Max images per breed: {max_count}")
    print(f"   Mean images per breed: {mean_count:.1f}")
    print(f"   Median images per breed: {median_count}")
    
    # Balance analysis
    imbalance_ratio = max_count / max(min_count, 1)
    print(f"\n⚖️  BALANCE ANALYSIS:")
    print(f"   Imbalance ratio: {imbalance_ratio:.1f}:1")
    
    if imbalance_ratio < 2.0:
        print(f"   ✅ EXCELLENT BALANCE!")
    elif imbalance_ratio < 5.0:
        print(f"   ✅ GOOD BALANCE!")
    elif imbalance_ratio < 10.0:
        print(f"   ⚠️  MODERATE IMBALANCE")
    elif imbalance_ratio < 50.0:
        print(f"   ⚠️  SEVERE IMBALANCE")
    else:
        print(f"   ❌ EXTREME IMBALANCE!")
    
    # Identify problematic breeds
    rare_breeds = [breed for breed, count in breed_counts.items() if count < 10]
    large_breeds = [breed for breed, count in breed_counts.items() if count > mean_count * 3]
    
    if rare_breeds:
        print(f"\n⚠️  RARE BREEDS (< 10 images): {len(rare_breeds)}")
        for breed in rare_breeds:
            print(f"      • {breed}: {breed_counts[breed]} images")
    
    if large_breeds:
        print(f"\n📈 OVERSIZED BREEDS (> 3x mean): {len(large_breeds)}")
        for breed in large_breeds:
            print(f"      • {breed}: {breed_counts[breed]} images")
    
    return dataset_path, images_dir, breed_counts

if __name__ == "__main__":
    result = analyze_catbreeds_from_cache()
    if result:
        dataset_path, images_dir, breed_counts = result
        print(f"\n✅ Analysis complete!")
        print(f"📁 Dataset: {dataset_path}")
        print(f"📸 Images: {images_dir}")
        print(f"🐱 Total Breeds: {len(breed_counts)}")
        print(f"📷 Total Images: {sum(breed_counts.values()):,}")
    else:
        print("❌ Analysis failed!")
