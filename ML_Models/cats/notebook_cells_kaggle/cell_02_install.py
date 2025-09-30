# Install required packages (Kaggle has some pre-installed)
print("📦 Installing required packages...")

# Most packages are pre-installed on Kaggle, but we need timm and albumentations
!pip install -q timm albumentations --upgrade

print("\n✅ Packages installed successfully!")
print("🚀 Ready to train on Kaggle GPU!")
