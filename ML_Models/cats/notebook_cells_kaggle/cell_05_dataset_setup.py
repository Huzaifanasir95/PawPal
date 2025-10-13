# Cat Breeds Refined 7k Dataset Setup for Kaggle

print("📂 Setting up Cat Breeds Refined 7k dataset...")

# Check if dataset is attached
if os.path.exists(config.IMAGES_PATH):
    print(f"✅ Dataset found at: {config.IMAGES_PATH}")
    
    # Count breed folders (should be 20 breeds with 350 images each)
    breed_folders = [d for d in os.listdir(config.IMAGES_PATH) 
                     if os.path.isdir(os.path.join(config.IMAGES_PATH, d))]
    
    breed_counts = {}
    total_images = 0
    
    for breed in sorted(breed_folders):
        breed_path = os.path.join(config.IMAGES_PATH, breed)
        images = [f for f in os.listdir(breed_path) 
                 if f.lower().endswith(('.jpg', '.jpeg', '.png', '.bmp'))]
        breed_counts[breed] = len(images)
        total_images += len(images)
    
    print(f"\n📊 Cat Breeds Refined 7k Dataset verified:")
    print(f"   • Total breeds: {len(breed_folders)}")
    print(f"   • Total images: {total_images:,}")
    print(f"   • Expected: 20 breeds × 350 images = 7,000 total")
    
    # Verify perfect balance
    if len(set(breed_counts.values())) == 1:
        images_per_breed = list(breed_counts.values())[0]
        print(f"   ✅ Perfect balance: {images_per_breed} images per breed")
    else:
        print(f"   ⚠️  Imbalanced: {dict(sorted(breed_counts.items(), key=lambda x: x[1]))}")
    
    print(f"   • Ready for training! 🚀")
    
    # Update config with actual number of classes
    config.NUM_CLASSES = len(breed_folders)
    
else:
    print(f"\n❌ ERROR: Dataset not found at {config.IMAGES_PATH}")
    print(f"\n🔧 How to fix:")
    print(f"   1. Click '+ Add Data' button on the right")
    print(f"   2. Search for: 'catbreedsrefined-7k'")
    print(f"   3. Find the dataset by 'doctrinek'")
    print(f"   4. Click 'Add' button")
    print(f"   5. Wait for it to attach")
    print(f"   6. Re-run this cell")
    raise FileNotFoundError(f"Dataset not found. Please add 'catbreedsrefined-7k' via Kaggle UI.")
