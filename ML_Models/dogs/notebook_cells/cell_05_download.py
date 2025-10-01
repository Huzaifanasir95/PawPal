import kagglehub

print("📥 Downloading Stanford Dogs Dataset...")
print("   This may take 5-10 minutes (~800MB)...\n")

# Download latest version
path = kagglehub.dataset_download("jessicali9530/stanford-dogs-dataset")

print(f"\n✅ Dataset downloaded!")
print(f"📂 Path to dataset files: {path}")

# Update config paths
config.DATASET_ROOT = path

# Find the Images directory
images_dir = None
for root, dirs, files in os.walk(path):
    if 'Images' in dirs:
        images_dir = os.path.join(root, 'Images')
        break

if images_dir and os.path.exists(images_dir):
    config.IMAGES_PATH = images_dir
    print(f"📂 Images directory: {config.IMAGES_PATH}")
    
    # Count breeds
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
    print(f"\n❌ ERROR: Images directory not found in {path}")
    print(f"   Please check the dataset structure")
    raise FileNotFoundError("Images directory not found")
