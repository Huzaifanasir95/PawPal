#!/usr/bin/env python3
"""
Analyze the Cat Breeds Refined 7k dataset
"""

import kagglehub
import os
from pathlib import Path
import pandas as pd
from collections import Counter

def analyze_catbreedsrefined():
    """Download and analyze the Cat Breeds Refined 7k dataset"""
    
    print("🐱 Analyzing Cat Breeds Refined 7k Dataset...")
    print("=" * 60)
    
    # Download the dataset
    try:
        print("📥 Downloading Cat Breeds Refined 7k dataset...")
        dataset_path = kagglehub.dataset_download("doctrinek/catbreedsrefined-7k")
        print(f"✅ Dataset downloaded to: {dataset_path}")
    except Exception as e:
        print(f"❌ Error downloading dataset: {e}")
        return None
    
    # Create data folder structure
    cats_data_folder = Path("d:/PawPal/ML_Models/cats/data")
    cats_data_folder.mkdir(parents=True, exist_ok=True)
    
    print(f"📁 Created data folder: {cats_data_folder}")
    
    # Explore directory structure
    print(f"\n📁 Dataset Structure:")
    print("=" * 40)
    
    def print_tree(directory, prefix="", max_depth=3, current_depth=0):
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
            print(f"{prefix}{current_prefix}{item}")
            
            if os.path.isdir(item_path) and current_depth < max_depth - 1:
                extension = "    " if is_last else "│   "
                print_tree(item_path, prefix + extension, max_depth, current_depth + 1)
    
    print_tree(dataset_path)
    
    # Look for images directory
    images_dir = None
    for root, dirs, files in os.walk(dataset_path):
        for dir_name in dirs:
            if 'image' in dir_name.lower() or len([f for f in os.listdir(os.path.join(root, dir_name)) 
                                                  if f.lower().endswith(('.jpg', '.jpeg', '.png'))]) > 0:
                images_dir = os.path.join(root, dir_name)
                print(f"📸 Found images directory: {images_dir}")
                break
        if images_dir:
            break
    
    # If no images subdirectory, check root
    if not images_dir:
        image_files = [f for f in os.listdir(dataset_path) 
                      if f.lower().endswith(('.jpg', '.jpeg', '.png', '.bmp'))]
        if image_files:
            images_dir = dataset_path
            print(f"📸 Images found in root directory: {images_dir}")
    
    if not images_dir:
        print("❌ No images directory found!")
        return None
    
    # Analyze the dataset structure
    print(f"\n🔍 Analyzing dataset organization...")
    
    # Check if organized by breed folders
    subdirs = [d for d in os.listdir(images_dir) if os.path.isdir(os.path.join(images_dir, d))]
    
    if subdirs:
        print(f"📂 Found {len(subdirs)} breed directories")
        analyze_breed_structure(images_dir, subdirs)
    else:
        # Check for flat structure with CSV labels
        print("📄 Checking for flat structure with label files...")
        analyze_flat_structure(dataset_path, images_dir)
    
    return dataset_path, images_dir

def analyze_breed_structure(images_dir, breed_dirs):
    """Analyze breed-organized directory structure"""
    
    print(f"\n📊 Breed Analysis:")
    print("=" * 40)
    
    breed_counts = {}
    total_images = 0
    
    # Count images per breed
    for breed in breed_dirs:
        breed_path = os.path.join(images_dir, breed)
        if os.path.isdir(breed_path):
            image_files = [f for f in os.listdir(breed_path) 
                          if f.lower().endswith(('.jpg', '.jpeg', '.png', '.bmp'))]
            breed_counts[breed] = len(image_files)
            total_images += len(image_files)
    
    # Sort breeds by count
    sorted_breeds = sorted(breed_counts.items(), key=lambda x: x[1], reverse=True)
    
    print(f"🐱 TOTAL CAT BREEDS: {len(breed_counts)}")
    print(f"📸 TOTAL IMAGES: {total_images:,}")
    
    print(f"\n📈 Top 15 Breeds (Most Images):")
    for i, (breed, count) in enumerate(sorted_breeds[:15], 1):
        print(f"   {i:2d}. {breed:<25} : {count:4d} images")
    
    print(f"\n📉 Bottom 15 Breeds (Least Images):")
    for i, (breed, count) in enumerate(sorted_breeds[-15:], 1):
        print(f"   {i:2d}. {breed:<25} : {count:4d} images")
    
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
        for breed in rare_breeds[:10]:
            print(f"      • {breed}: {breed_counts[breed]} images")
    
    if large_breeds:
        print(f"\n📈 OVERSIZED BREEDS (> 3x mean): {len(large_breeds)}")
        for breed in large_breeds[:10]:
            print(f"      • {breed}: {breed_counts[breed]} images")
    
    return breed_counts

def analyze_flat_structure(dataset_path, images_dir):
    """Analyze flat structure with potential CSV labels"""
    
    # Look for CSV files
    csv_files = [f for f in os.listdir(dataset_path) if f.endswith('.csv')]
    
    if csv_files:
        print(f"📄 Found CSV files: {csv_files}")
        
        for csv_file in csv_files:
            csv_path = os.path.join(dataset_path, csv_file)
            try:
                df = pd.read_csv(csv_path)
                print(f"\n📊 {csv_file}:")
                print(f"   Shape: {df.shape}")
                print(f"   Columns: {list(df.columns)}")
                print(f"   First 5 rows:")
                print(df.head())
                
                # Look for breed/label columns
                for col in df.columns:
                    if 'breed' in col.lower() or 'label' in col.lower() or 'class' in col.lower():
                        unique_values = df[col].nunique()
                        print(f"   📋 {col}: {unique_values} unique values")
                        if unique_values < 100:
                            value_counts = df[col].value_counts()
                            print(f"      Top breeds: {dict(value_counts.head())}")
                
            except Exception as e:
                print(f"   Error reading {csv_file}: {e}")
    
    # Count total images
    image_files = [f for f in os.listdir(images_dir) 
                  if f.lower().endswith(('.jpg', '.jpeg', '.png', '.bmp'))]
    print(f"\n📸 Total images in flat structure: {len(image_files)}")

if __name__ == "__main__":
    result = analyze_catbreedsrefined()
    if result:
        dataset_path, images_dir = result
        print(f"\n✅ Analysis complete!")
        print(f"📁 Dataset location: {dataset_path}")
        print(f"📸 Images location: {images_dir}")
    else:
        print("❌ Analysis failed!")
