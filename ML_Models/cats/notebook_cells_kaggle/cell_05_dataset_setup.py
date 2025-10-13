# Cat Breeds Refined 7k Dataset Setup for Kaggle

print("📂 Setting up Cat Breeds Refined 7k dataset...")

# Check if dataset is attached
if os.path.exists(config.IMAGES_PATH):
    print(f"✅ Dataset found at: {config.IMAGES_PATH}")
    
    # Explore the actual structure first
    print(f"\n🔍 Exploring dataset structure...")
    def explore_structure(path, max_depth=3, current_depth=0):
        items = []
        if current_depth >= max_depth:
            return items
        
        try:
            for item in os.listdir(path):
                item_path = os.path.join(path, item)
                if os.path.isdir(item_path):
                    # Check if this directory contains images
                    image_files = [f for f in os.listdir(item_path) 
                                  if f.lower().endswith(('.jpg', '.jpeg', '.png', '.bmp'))]
                    if image_files:
                        items.append((item, item_path, len(image_files)))
                        print(f"   📁 {item}: {len(image_files)} images")
                    else:
                        # Recursively explore subdirectories
                        sub_items = explore_structure(item_path, max_depth, current_depth + 1)
                        items.extend(sub_items)
        except PermissionError:
            pass
        
        return items
    
    # Find all directories with images
    breed_info = explore_structure(config.IMAGES_PATH)
    
    if not breed_info:
        print("❌ No breed directories with images found!")
        print("🔍 Let's check the exact structure:")
        for item in os.listdir(config.IMAGES_PATH):
            item_path = os.path.join(config.IMAGES_PATH, item)
            if os.path.isdir(item_path):
                print(f"   📁 {item}/")
                # Check one level deeper
                try:
                    for subitem in os.listdir(item_path)[:5]:  # Show first 5 items
                        subitem_path = os.path.join(item_path, subitem)
                        if os.path.isdir(subitem_path):
                            print(f"      📁 {subitem}/")
                        else:
                            print(f"      📄 {subitem}")
                except:
                    pass
    else:
        # Process the found breed directories
        breed_counts = {}
        total_images = 0
        
        for breed_name, breed_path, image_count in breed_info:
            breed_counts[breed_name] = image_count
            total_images += image_count
        
        print(f"\n📊 Cat Breeds Refined 7k Dataset verified:")
        print(f"   • Total breeds: {len(breed_counts)}")
        print(f"   • Total images: {total_images:,}")
        print(f"   • Expected: 20 breeds × 350 images = 7,000 total")
        
        # Show all breeds found
        print(f"\n📋 Breeds found:")
        for i, (breed, count) in enumerate(sorted(breed_counts.items()), 1):
            print(f"   {i:2d}. {breed}: {count} images")
        
        # Verify perfect balance
        if len(set(breed_counts.values())) == 1:
            images_per_breed = list(breed_counts.values())[0]
            print(f"\n   ✅ Perfect balance: {images_per_breed} images per breed")
        else:
            print(f"\n   ⚠️  Imbalanced distribution found")
        
        print(f"\n   • Ready for training! 🚀")
        
        # Update config with actual number of classes and correct path
        config.NUM_CLASSES = len(breed_counts)
        
        # If breeds are in a subdirectory, update the images path
        if breed_info and len(breed_info) > 0:
            # Check if all breeds are in the same parent directory
            parent_dirs = set(os.path.dirname(info[1]) for info in breed_info)
            if len(parent_dirs) == 1:
                actual_images_path = list(parent_dirs)[0]
                if actual_images_path != config.IMAGES_PATH:
                    print(f"\n🔄 Updating images path to: {actual_images_path}")
                    config.IMAGES_PATH = actual_images_path
    
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
