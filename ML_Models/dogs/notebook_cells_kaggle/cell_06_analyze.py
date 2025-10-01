def analyze_dataset_distribution(images_path):
    """Analyze dataset and identify severe class imbalance"""
    class_counts = {}
    all_samples = []
    
    breed_dirs = sorted([d for d in os.listdir(images_path) 
                        if os.path.isdir(os.path.join(images_path, d))])
    
    print(f"\n{'='*70}")
    print(f"📊 DATASET DISTRIBUTION ANALYSIS")
    print(f"{'='*70}\n")
    
    # Scan all breeds and validate images
    for breed in tqdm(breed_dirs, desc="Scanning and validating images"):
        breed_path = os.path.join(images_path, breed)
        images = [f for f in os.listdir(breed_path) 
                 if f.lower().endswith(('.jpg', '.jpeg', '.png', '.bmp'))]
        
        # Validate images (check if readable and has valid dimensions)
        valid_images = []
        for img in images:
            img_path = os.path.join(breed_path, img)
            try:
                img_data = cv2.imread(img_path)
                if img_data is not None and img_data.shape[0] > 10 and img_data.shape[1] > 10:
                    valid_images.append(img_path)
            except:
                continue
        
        class_counts[breed] = len(valid_images)
        all_samples.extend([(img_path, breed) for img_path in valid_images])
    
    # Calculate statistics
    counts = list(class_counts.values())
    total_images = sum(counts)
    
    print(f"\n📈 STATISTICS:")
    print(f"   Total Breeds: {len(class_counts)}")
    print(f"   Total Valid Images: {total_images:,}")
    print(f"   Min images per class: {min(counts)}")
    print(f"   Max images per class: {max(counts)}")
    print(f"   Mean images per class: {np.mean(counts):.1f}")
    print(f"   Median images per class: {np.median(counts):.1f}")
    print(f"   Std Dev: {np.std(counts):.1f}")
    
    # Imbalance analysis
    imbalance_ratio = max(counts) / max(min(counts), 1)
    print(f"\n⚖️  IMBALANCE RATIO: {imbalance_ratio:.1f}:1")
    
    if imbalance_ratio > 100:
        print(f"   ⚠️  EXTREME IMBALANCE DETECTED!")
    elif imbalance_ratio > 10:
        print(f"   ⚠️  SEVERE IMBALANCE DETECTED!")
    
    # Identify rare classes
    rare_classes = {k: v for k, v in class_counts.items() 
                    if v < config.RARE_CLASS_THRESHOLD}
    
    print(f"\n⚠️  RARE CLASSES (< {config.RARE_CLASS_THRESHOLD} images): {len(rare_classes)}")
    
    if rare_classes:
        print(f"\n   Top 10 rarest breeds:")
        for i, (breed, count) in enumerate(sorted(rare_classes.items(), key=lambda x: x[1])[:10], 1):
            print(f"      {i:2d}. {breed:30s} : {count:2d} images")
        
        if len(rare_classes) > 10:
            print(f"      ... and {len(rare_classes) - 10} more rare breeds")
        
        print(f"\n   💡 SOLUTION APPLIED:")
        print(f"      ✓ {config.RARE_CLASS_BOOST}x augmentation boost")
        print(f"      ✓ Weighted random sampling")
        print(f"      ✓ Focal Loss for hard examples")
        print(f"      ✓ Class-balanced loss weights")
    
    print(f"\n{'='*70}\n")
    
    return all_samples, class_counts, breed_dirs

# Run analysis
all_samples, class_counts, class_names = analyze_dataset_distribution(config.IMAGES_PATH)
config.NUM_CLASSES = len(class_names)

print(f"✅ Dataset analysis complete!")
print(f"   Total samples: {len(all_samples):,}")
print(f"   Total classes: {config.NUM_CLASSES}")
