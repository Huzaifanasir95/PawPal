#!/usr/bin/env python3
"""
Explore the actual structure of the cached Cat Breeds dataset
"""

import os
import glob

def explore_cached_structure():
    """Explore the cached dataset structure in detail"""
    
    print("🔍 Exploring Cat Breeds Dataset Structure...")
    print("=" * 50)
    
    # Find the dataset
    base_path = r"C:\Users\nasir\.cache\kagglehub\datasets\doctrinek\catbreedsrefined-7k"
    
    if not os.path.exists(base_path):
        print(f"❌ Base path not found: {base_path}")
        return
    
    print(f"📁 Base path: {base_path}")
    
    # Explore all subdirectories
    def explore_directory(path, max_depth=4, current_depth=0, prefix=""):
        """Recursively explore directory structure"""
        
        if current_depth >= max_depth:
            return
        
        try:
            items = sorted(os.listdir(path))
        except PermissionError:
            print(f"{prefix}[Permission Denied]")
            return
        
        for i, item in enumerate(items):
            item_path = os.path.join(path, item)
            is_last = i == len(items) - 1
            current_prefix = "└── " if is_last else "├── "
            
            if os.path.isdir(item_path):
                # Count files in directory
                try:
                    files = os.listdir(item_path)
                    image_files = [f for f in files if f.lower().endswith(('.jpg', '.jpeg', '.png', '.bmp'))]
                    
                    if image_files:
                        print(f"{prefix}{current_prefix}{item}/ ({len(image_files)} images)")
                    else:
                        print(f"{prefix}{current_prefix}{item}/ ({len(files)} items)")
                    
                    # Continue exploring
                    extension = "    " if is_last else "│   "
                    explore_directory(item_path, max_depth, current_depth + 1, prefix + extension)
                    
                except PermissionError:
                    print(f"{prefix}{current_prefix}{item}/ [Permission Denied]")
            else:
                # Show file size for files
                try:
                    size = os.path.getsize(item_path)
                    if size > 1024*1024:  # > 1MB
                        size_str = f"{size/(1024*1024):.1f}MB"
                    elif size > 1024:  # > 1KB
                        size_str = f"{size/1024:.1f}KB"
                    else:
                        size_str = f"{size}B"
                    print(f"{prefix}{current_prefix}{item} ({size_str})")
                except:
                    print(f"{prefix}{current_prefix}{item}")
    
    explore_directory(base_path)
    
    # Look for the actual data in versions
    versions_path = os.path.join(base_path, "versions")
    if os.path.exists(versions_path):
        print(f"\n🔍 Checking versions directory...")
        
        for version in os.listdir(versions_path):
            version_path = os.path.join(versions_path, version)
            if os.path.isdir(version_path):
                print(f"\n📂 Version {version}:")
                
                # Check what's in this version
                for item in os.listdir(version_path):
                    item_path = os.path.join(version_path, item)
                    if os.path.isdir(item_path):
                        # Count images in subdirectories
                        total_images = 0
                        breed_count = 0
                        
                        for subitem in os.listdir(item_path):
                            subitem_path = os.path.join(item_path, subitem)
                            if os.path.isdir(subitem_path):
                                images = [f for f in os.listdir(subitem_path) 
                                         if f.lower().endswith(('.jpg', '.jpeg', '.png', '.bmp'))]
                                if images:
                                    total_images += len(images)
                                    breed_count += 1
                                    print(f"   📁 {subitem}: {len(images)} images")
                        
                        if breed_count > 0:
                            print(f"\n   🎯 Found {breed_count} breeds with {total_images} total images!")
                            return version_path, item_path
                    else:
                        print(f"   📄 {item}")
    
    return None, None

if __name__ == "__main__":
    result = explore_cached_structure()
    if result[0]:
        print(f"\n✅ Found dataset structure!")
        print(f"📁 Version path: {result[0]}")
        print(f"📸 Images path: {result[1]}")
    else:
        print(f"\n❌ Could not locate image structure")
