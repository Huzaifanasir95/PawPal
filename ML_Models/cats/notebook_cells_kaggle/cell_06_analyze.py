def process_image_batch_gpu(image_paths, device):
    """GPU-accelerated batch image processing"""
    results = []
    
    for img_path in image_paths:
        try:
            # Read image using PIL for better GPU compatibility
            img = Image.open(img_path).convert('RGB')
            w, h = img.size
            
            # Basic validation
            if h > 10 and w > 10:
                # Convert to tensor and move to GPU for quality scoring
                img_tensor = torch.tensor(np.array(img), device=device, dtype=torch.float32)
                
                # GPU-accelerated quality scoring
                with torch.no_grad():
                    # Resolution score
                    resolution_score = min((h * w) / (224 * 224), 2.0)
                    
                    # Aspect ratio score
                    aspect_ratio = max(h/w, w/h)
                    aspect_score = max(0, 2.0 - aspect_ratio)
                    
                    # File size score
                    try:
                        file_size = os.path.getsize(img_path) / 1024  # KB
                        size_score = min(file_size / 50, 1.0)
                    except:
                        size_score = 0.5
                    
                    # Image variance (sharpness indicator) - GPU accelerated
                    img_gray = img_tensor.mean(dim=2)  # Convert to grayscale on GPU
                    variance = torch.var(img_gray).item()
                    sharpness_score = min(variance / 1000, 1.0)
                    
                    total_score = resolution_score + aspect_score + size_score + sharpness_score
                
                results.append((img_path, True, total_score))
            else:
                results.append((img_path, False, 0.0))
                
        except Exception as e:
            results.append((img_path, False, 0.0))
    
    return results

def process_image_batch_cpu(image_paths):
    """CPU fallback batch image processing"""
    results = []
    
    for img_path in image_paths:
        try:
            img_data = cv2.imread(img_path)
            if img_data is not None and img_data.shape[0] > 10 and img_data.shape[1] > 10:
                h, w = img_data.shape[:2]
                
                # Quality scoring
                resolution_score = min(h * w / (224 * 224), 2.0)
                aspect_ratio = max(h/w, w/h)
                aspect_score = max(0, 2.0 - aspect_ratio)
                
                try:
                    file_size = os.path.getsize(img_path) / 1024
                    size_score = min(file_size / 50, 1.0)
                except:
                    size_score = 0.5
                
                total_score = resolution_score + aspect_score + size_score
                results.append((img_path, True, total_score))
            else:
                results.append((img_path, False, 0.0))
                
        except:
            results.append((img_path, False, 0.0))
    
    return results

def analyze_dataset_distribution(images_path):
    """GPU-accelerated dataset analysis with smart sampling"""
    class_counts = {}
    all_samples = []
    original_counts = {}
    
    breed_dirs = sorted([d for d in os.listdir(images_path) 
                        if os.path.isdir(os.path.join(images_path, d))])
    
    print(f"\n{'='*70}")
    print(f"📊 CAT BREEDS REFINED 7K - GPU ANALYSIS")
    print(f"{'='*70}")
    print(f"🐱 Dataset: Cat Breeds Refined 7k (20 breeds × 350 images)")
    print(f"🎯 Max samples per breed: {config.MAX_SAMPLES_PER_BREED}")
    print(f"🎯 Min samples per breed: {config.MIN_SAMPLES_PER_BREED}")
    print(f"🧠 Smart sampling: {'✓ Enabled' if config.USE_SMART_SAMPLING else '✗ Disabled'}")
    print(f"🚀 GPU acceleration: {'✓ Enabled' if config.USE_GPU_ANALYSIS and torch.cuda.is_available() else '✗ CPU only'}")
    print()
    
    # Initialize GPU processing if available
    device = torch.device('cuda' if config.USE_GPU_ANALYSIS and torch.cuda.is_available() else 'cpu')
    
    # Performance timing
    import time
    start_time = time.time()
    
    # Scan all breeds and apply smart sampling
    excluded_breeds = []
    
    for breed in tqdm(breed_dirs, desc="🔍 GPU-accelerated scanning"):
        breed_path = os.path.join(images_path, breed)
        images = [f for f in os.listdir(breed_path) 
                 if f.lower().endswith(('.jpg', '.jpeg', '.png', '.bmp'))]
        
        # Batch process images for GPU efficiency
        valid_images = []
        image_scores = []
        
        # Process images in batches for GPU efficiency
        batch_size = 32 if device.type == 'cuda' else 8
        
        for i in range(0, len(images), batch_size):
            batch_images = images[i:i + batch_size]
            batch_paths = [os.path.join(breed_path, img) for img in batch_images]
            
            # GPU-accelerated batch processing
            if config.USE_GPU_ANALYSIS and device.type == 'cuda':
                batch_results = process_image_batch_gpu(batch_paths, device)
            else:
                batch_results = process_image_batch_cpu(batch_paths)
            
            for img_path, is_valid, quality_score in batch_results:
                if is_valid:
                    valid_images.append(img_path)
                    if config.USE_SMART_SAMPLING:
                        image_scores.append((img_path, quality_score))
        
        original_counts[breed] = len(valid_images)
        
        # Apply breed filtering and sampling
        if len(valid_images) < config.MIN_SAMPLES_PER_BREED:
            excluded_breeds.append((breed, len(valid_images)))
            continue
        
        # Smart sampling for breeds with too many images
        if len(valid_images) > config.MAX_SAMPLES_PER_BREED:
            if config.USE_SMART_SAMPLING and image_scores:
                # Sort by quality score and take top samples
                image_scores.sort(key=lambda x: x[1], reverse=True)
                selected_images = [img_path for img_path, _ in image_scores[:config.MAX_SAMPLES_PER_BREED]]
            else:
                # Random sampling
                import random
                random.seed(42)  # Reproducible sampling
                selected_images = random.sample(valid_images, config.MAX_SAMPLES_PER_BREED)
            
            valid_images = selected_images
        
        class_counts[breed] = len(valid_images)
        all_samples.extend([(img_path, breed) for img_path in valid_images])
    
    # Calculate statistics
    counts = list(class_counts.values())
    original_total = sum(original_counts.values())
    total_images = sum(counts)
    
    print(f"\n📈 SAMPLING RESULTS:")
    print(f"   Original Total Images: {original_total:,}")
    print(f"   After Sampling: {total_images:,}")
    print(f"   Reduction: {((original_total - total_images) / original_total * 100):.1f}%")
    print(f"   Total Breeds (after filtering): {len(class_counts)}")
    
    if excluded_breeds:
        print(f"\n🚫 EXCLUDED BREEDS (< {config.MIN_SAMPLES_PER_BREED} images): {len(excluded_breeds)}")
        for breed, count in excluded_breeds[:5]:
            print(f"      • {breed}: {count} images")
        if len(excluded_breeds) > 5:
            print(f"      ... and {len(excluded_breeds) - 5} more")
    
    print(f"\n📊 FINAL STATISTICS:")
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
    else:
        print(f"   ✅ MANAGEABLE IMBALANCE")
    
    # Show sampling impact on large classes
    large_classes = {k: (original_counts[k], v) for k, v in class_counts.items() 
                    if original_counts[k] > config.MAX_SAMPLES_PER_BREED}
    
    if large_classes:
        print(f"\n📉 LARGE CLASSES SAMPLED:")
        for i, (breed, (orig, final)) in enumerate(sorted(large_classes.items(), 
                                                         key=lambda x: x[1][0], reverse=True)[:10], 1):
            reduction = ((orig - final) / orig * 100)
            print(f"      {i:2d}. {breed:25s} : {orig:4d} → {final:3d} (-{reduction:.0f}%)")
    
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
    
    # Calculate processing time
    end_time = time.time()
    processing_time = end_time - start_time
    
    print(f"\n💡 COMPUTATIONAL SAVINGS:")
    print(f"   ✓ Smart sampling reduces training time")
    print(f"   ✓ Better class balance improves convergence")
    print(f"   ✓ High-quality samples selected automatically")
    print(f"   ✓ {'GPU' if device.type == 'cuda' else 'CPU'} processing: {processing_time:.2f} seconds")
    
    if device.type == 'cuda':
        images_per_second = original_total / processing_time
        print(f"   ⚡ Processing speed: {images_per_second:.0f} images/second")
    
    print(f"\n{'='*70}\n")
    
    return all_samples, class_counts, list(class_counts.keys())

# Run analysis
all_samples, class_counts, class_names = analyze_dataset_distribution(config.IMAGES_PATH)
config.NUM_CLASSES = len(class_names)

print(f"✅ Dataset analysis complete!")
print(f"   Total samples: {len(all_samples):,}")
print(f"   Total classes: {config.NUM_CLASSES}")
