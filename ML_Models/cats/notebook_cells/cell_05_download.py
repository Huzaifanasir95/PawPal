import kagglehub

# Download latest version
print("📥 Downloading cat breeds dataset from Kaggle...")
print("This may take 5-10 minutes depending on connection speed...\n")

path = kagglehub.dataset_download("ma7555/cat-breeds-dataset")

print(f"\n✅ Dataset downloaded successfully!")
print(f"📂 Path to dataset files: {path}")

# Update config paths
config.DATASET_ROOT = path
config.IMAGES_PATH = os.path.join(path, "images")

# Verify dataset structure
if os.path.exists(config.IMAGES_PATH):
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
    print(f"   • Images path: {config.IMAGES_PATH}")
else:
    print(f"\n❌ ERROR: Images folder not found at {config.IMAGES_PATH}")
    print("Please check the dataset download.")
