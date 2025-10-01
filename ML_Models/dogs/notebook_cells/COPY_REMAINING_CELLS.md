# 📋 Quick Copy Commands

Run these commands from PowerShell in the `d:\PawPal\ML_Models\dogs\` directory:

## Copy Remaining Colab Cells (10-15):

```powershell
Copy-Item "..\cats\notebook_cells\cell_10_losses.py" -Destination "notebook_cells\"
Copy-Item "..\cats\notebook_cells\cell_11_model.py" -Destination "notebook_cells\"
Copy-Item "..\cats\notebook_cells\cell_12_training.py" -Destination "notebook_cells\"
Copy-Item "..\cats\notebook_cells\cell_13_run.py" -Destination "notebook_cells\"
Copy-Item "..\cats\notebook_cells\cell_14_evaluate.py" -Destination "notebook_cells\"
Copy-Item "..\cats\notebook_cells\cell_15_inference.py" -Destination "notebook_cells\"
```

## Create Kaggle Version:

```powershell
# Create folder
New-Item -ItemType Directory -Path "notebook_cells_kaggle" -Force

# Copy cells 1-5 (already created for dogs)
Copy-Item "notebook_cells\cell_01_title.py" -Destination "notebook_cells_kaggle\"
Copy-Item "notebook_cells\cell_02_install.py" -Destination "notebook_cells_kaggle\"  
Copy-Item "notebook_cells\cell_03_imports.py" -Destination "notebook_cells_kaggle\"
Copy-Item "notebook_cells\cell_04_config.py" -Destination "notebook_cells_kaggle\"

# Copy cells 6-15 from cats Kaggle (they're generic)
Copy-Item "..\cats\notebook_cells_kaggle\cell_06_analyze.py" -Destination "notebook_cells_kaggle\"
Copy-Item "..\cats\notebook_cells_kaggle\cell_07_visualize.py" -Destination "notebook_cells_kaggle\"
Copy-Item "..\cats\notebook_cells_kaggle\cell_08_augmentation.py" -Destination "notebook_cells_kaggle\"
Copy-Item "..\cats\notebook_cells_kaggle\cell_09_dataset.py" -Destination "notebook_cells_kaggle\"
Copy-Item "..\cats\notebook_cells_kaggle\cell_10_losses.py" -Destination "notebook_cells_kaggle\"
Copy-Item "..\cats\notebook_cells_kaggle\cell_11_model.py" -Destination "notebook_cells_kaggle\"
Copy-Item "..\cats\notebook_cells_kaggle\cell_12_training.py" -Destination "notebook_cells_kaggle\"
Copy-Item "..\cats\notebook_cells_kaggle\cell_13_run.py" -Destination "notebook_cells_kaggle\"
Copy-Item "..\cats\notebook_cells_kaggle\cell_14_evaluate.py" -Destination "notebook_cells_kaggle\"
Copy-Item "..\cats\notebook_cells_kaggle\cell_15_inference.py" -Destination "notebook_cells_kaggle\"

# Copy documentation
Copy-Item "..\cats\notebook_cells_kaggle\KAGGLE_SETUP.md" -Destination "notebook_cells_kaggle\"
Copy-Item "..\cats\notebook_cells_kaggle\QUICK_START.md" -Destination "notebook_cells_kaggle\"
```

## Update Kaggle cell_05:

Create `notebook_cells_kaggle\cell_05_dataset_setup.py`:

```python
import kagglehub

print("📥 Downloading Stanford Dogs Dataset...")
print("   This may take 5-10 minutes (~800MB)...\n")

# Download latest version
path = kagglehub.dataset_download("jessicali9530/stanford-dogs-dataset")

print(f"\n✅ Dataset downloaded!")
print(f"📂 Path: {path}")

# Update config
config.DATASET_ROOT = path

# Find Images directory
images_dir = None
for root, dirs, files in os.walk(path):
    if 'Images' in dirs:
        images_dir = os.path.join(root, 'Images')
        break

if images_dir:
    config.IMAGES_PATH = images_dir
    print(f"📂 Images: {config.IMAGES_PATH}")
    print(f"✅ Ready for training!")
else:
    raise FileNotFoundError("Images directory not found")
```

## Done!

After running these commands, you'll have:
- ✅ Complete Colab version (cells 1-15)
- ✅ Complete Kaggle version (cells 1-15)
- ✅ Ready to train 120 dog breeds to 90%+ accuracy!
