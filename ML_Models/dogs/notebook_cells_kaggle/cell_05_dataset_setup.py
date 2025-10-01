# Kaggle Direct Dataset Access (No download needed!)

print("📂 Verifying Kaggle dataset access...")

# Check if dataset is attached
dataset_path = "/kaggle/input/stanford-dogs-dataset"

if os.path.exists(dataset_path):
    print(f"✅ Dataset found at: {dataset_path}")
    
    # Stanford Dogs has nested structure: images/Images/[breed_folders]
    # Try multiple possible paths
    possible_paths = [
        os.path.join(dataset_path, "images", "Images"),  # Nested structure
        os.path.join(dataset_path, "Images"),             # Direct
        os.path.join(dataset_path, "images"),             # Lowercase
    ]
    
    images_dir = None
    for path in possible_paths:
        if os.path.exists(path):
            # Check if this path has breed folders (not just one "Images" folder)
            contents = os.listdir(path)
            folders = [d for d in contents if os.path.isdir(os.path.join(path, d))]
            
            # If we have multiple folders or folders with breed-like names, this is it
            if len(folders) > 10:  # Stanford Dogs has 120 breeds
                images_dir = path
                break
    
    if images_dir and os.path.exists(images_dir):
        config.IMAGES_PATH = images_dir
        print(f"📂 Images directory: {config.IMAGES_PATH}")
        
        # Count breed folders
        breed_folders = [d for d in os.listdir(config.IMAGES_PATH) 
                         if os.path.isdir(os.path.join(config.IMAGES_PATH, d))]
        
        total_images = 0
        for breed in breed_folders:
            breed_path = os.path.join(config.IMAGES_PATH, breed)
            try:
                images = [f for f in os.listdir(breed_path) 
                         if f.lower().endswith(('.jpg', '.jpeg', '.png', '.bmp'))]
                total_images += len(images)
            except:
                continue
        
        print(f"\n📊 Dataset verified:")
        print(f"   • Breed folders: {len(breed_folders)}")
        print(f"   • Total images: {total_images:,}")
        
        if len(breed_folders) >= 100 and total_images > 10000:
            print(f"   • Ready for training! 🚀")
        else:
            print(f"\n⚠️  WARNING: Dataset seems incomplete!")
            print(f"   Expected: 120 breeds, ~20,000 images")
            print(f"   Found: {len(breed_folders)} breeds, {total_images} images")
    else:
        print(f"\n❌ ERROR: Images directory not found")
        print(f"   Searched paths:")
        for path in possible_paths:
            print(f"   - {path}: {'exists' if os.path.exists(path) else 'not found'}")
        raise FileNotFoundError("Images directory not found")
    
else:
    print(f"\n❌ ERROR: Dataset not found at {dataset_path}")
    print(f"\n🔧 How to fix:")
    print(f"   1. Click '+ Add Data' button on the right")
    print(f"   2. Search for: 'stanford-dogs-dataset'")
    print(f"   3. Find the dataset by 'jessicali9530'")
    print(f"   4. Click 'Add' button")
    print(f"   5. Wait for it to attach")
    print(f"   6. Re-run this cell")
    raise FileNotFoundError(f"Dataset not found. Please add 'stanford-dogs-dataset' via Kaggle UI.")
