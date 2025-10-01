# Kaggle Direct Dataset Access (No download needed!)

print("📂 Verifying Kaggle dataset access...")

# Check if dataset is attached
dataset_path = "/kaggle/input/stanford-dogs-dataset"

if os.path.exists(dataset_path):
    print(f"✅ Dataset found at: {dataset_path}")
    
    # Find Images directory
    images_dir = None
    for root, dirs, files in os.walk(dataset_path):
        if 'Images' in dirs:
            images_dir = os.path.join(root, 'Images')
            break
        # Also check for lowercase
        if 'images' in dirs:
            images_dir = os.path.join(root, 'images')
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
            images = [f for f in os.listdir(breed_path) 
                     if f.lower().endswith(('.jpg', '.jpeg', '.png', '.bmp'))]
            total_images += len(images)
        
        print(f"\n📊 Dataset verified:")
        print(f"   • Breed folders: {len(breed_folders)}")
        print(f"   • Total images: {total_images:,}")
        print(f"   • Ready for training! 🚀")
    else:
        print(f"\n❌ ERROR: Images directory not found")
        print(f"   Searched in: {dataset_path}")
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
