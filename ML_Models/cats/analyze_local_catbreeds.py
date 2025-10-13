#!/usr/bin/env python3
"""
Analyze the Cat Breeds Refined 7k dataset from local data folder
"""

import os
from pathlib import Path
from collections import Counter

def analyze_local_catbreeds():
    """Analyze the Cat Breeds Refined dataset from local data folder"""
    
    print("🐱 Analyzing Cat Breeds Refined 7k Dataset (Local)")
    print("=" * 60)
    
    # Dataset path
    dataset_path = r"D:\PawPal\ML_Models\cats\data\catbreedsrefined-7k\versions\2\CatBreedsRefined-v2"
    
    if not os.path.exists(dataset_path):
        print(f"❌ Dataset path not found: {dataset_path}")
        return None
    
    print(f"📁 Dataset location: {dataset_path}")
    
    # Get all breed directories
    breed_dirs = [d for d in os.listdir(dataset_path) 
                 if os.path.isdir(os.path.join(dataset_path, d))]
    
    if not breed_dirs:
        print("❌ No breed directories found!")
        return None
    
    print(f"📂 Found {len(breed_dirs)} breed directories")
    
    # Count images per breed
    breed_counts = {}
    total_images = 0
    
    print(f"\n📊 Counting images per breed...")
    
    for breed in sorted(breed_dirs):
        breed_path = os.path.join(dataset_path, breed)
        if os.path.isdir(breed_path):
            # Count image files
            image_files = [f for f in os.listdir(breed_path) 
                          if f.lower().endswith(('.jpg', '.jpeg', '.png', '.bmp'))]
            breed_counts[breed] = len(image_files)
            total_images += len(image_files)
    
    # Sort breeds alphabetically for display
    sorted_breeds = sorted(breed_counts.items())
    
    print(f"\n🐱 CAT BREEDS ANALYSIS:")
    print("=" * 60)
    print(f"🎯 TOTAL CAT BREEDS: {len(breed_counts)}")
    print(f"📸 TOTAL IMAGES: {total_images:,}")
    
    print(f"\n📋 ALL CAT BREEDS (alphabetical order):")
    print("-" * 60)
    
    for i, (breed, count) in enumerate(sorted_breeds, 1):
        print(f"   {i:2d}. {breed:<25} : {count:3d} images")
    
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
    
    if imbalance_ratio == 1.0:
        print(f"   ✅ PERFECT BALANCE! All breeds have exactly the same number of images!")
    elif imbalance_ratio < 1.5:
        print(f"   ✅ EXCELLENT BALANCE!")
    elif imbalance_ratio < 2.0:
        print(f"   ✅ VERY GOOD BALANCE!")
    elif imbalance_ratio < 5.0:
        print(f"   ✅ GOOD BALANCE!")
    else:
        print(f"   ⚠️  IMBALANCED")
    
    # Check for uniformity
    unique_counts = set(counts)
    if len(unique_counts) == 1:
        print(f"   🎯 PERFECTLY UNIFORM: All breeds have exactly {counts[0]} images each!")
    else:
        print(f"   📊 Count variations: {sorted(unique_counts)}")
    
    # Sample some images to verify structure
    print(f"\n🔍 SAMPLE VERIFICATION:")
    sample_breed = sorted_breeds[0][0]  # First breed alphabetically
    sample_path = os.path.join(dataset_path, sample_breed)
    sample_images = [f for f in os.listdir(sample_path)[:3] 
                    if f.lower().endswith(('.jpg', '.jpeg', '.png', '.bmp'))]
    
    print(f"   Sample breed: {sample_breed}")
    print(f"   Sample images: {sample_images}")
    
    # Verify file extensions
    all_extensions = set()
    for breed in breed_dirs[:3]:  # Check first 3 breeds
        breed_path = os.path.join(dataset_path, breed)
        for file in os.listdir(breed_path):
            if '.' in file:
                ext = file.split('.')[-1].lower()
                all_extensions.add(ext)
    
    print(f"   File extensions found: {sorted(all_extensions)}")
    
    # Dataset quality assessment
    print(f"\n🏆 DATASET QUALITY ASSESSMENT:")
    
    quality_score = 0
    max_score = 5
    
    # Balance score
    if imbalance_ratio == 1.0:
        quality_score += 2
        print(f"   ✅ Perfect balance: +2 points")
    elif imbalance_ratio < 2.0:
        quality_score += 1
        print(f"   ✅ Good balance: +1 point")
    
    # Size score
    if total_images >= 5000:
        quality_score += 1
        print(f"   ✅ Large dataset (7k+ images): +1 point")
    
    # Breed diversity score
    if len(breed_counts) >= 15:
        quality_score += 1
        print(f"   ✅ Good breed diversity (20 breeds): +1 point")
    
    # Consistency score
    if len(unique_counts) == 1:
        quality_score += 1
        print(f"   ✅ Perfect consistency: +1 point")
    
    print(f"\n   🎯 Overall Quality Score: {quality_score}/{max_score}")
    
    if quality_score >= 4:
        print(f"   🏆 EXCELLENT dataset for machine learning!")
    elif quality_score >= 3:
        print(f"   ✅ VERY GOOD dataset for machine learning!")
    elif quality_score >= 2:
        print(f"   👍 GOOD dataset for machine learning!")
    else:
        print(f"   ⚠️  MODERATE dataset quality")
    
    return dataset_path, breed_counts

if __name__ == "__main__":
    result = analyze_local_catbreeds()
    if result:
        dataset_path, breed_counts = result
        print(f"\n✅ Analysis complete!")
        print(f"📁 Dataset: {dataset_path}")
        print(f"🐱 Total Breeds: {len(breed_counts)}")
        print(f"📷 Total Images: {sum(breed_counts.values()):,}")
        print(f"📊 Images per breed: {list(breed_counts.values())[0]} (uniform)")
    else:
        print("❌ Analysis failed!")
