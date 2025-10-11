# Install required packages (Kaggle has some pre-installed)
print("📦 Installing required packages...")

# Install only what we need for cat breed classification
# Using --no-deps to avoid dependency conflicts with pre-installed packages
!pip install -q timm albumentations --upgrade --no-warn-conflicts

# Suppress dependency warnings for cleaner output
import warnings
warnings.filterwarnings('ignore', category=UserWarning, module='pip._internal.resolution.resolvelib')

print("\n✅ Packages installed successfully!")
print("🚀 Ready to train on Kaggle GPU!")
print("\n💡 Note: Dependency warnings are normal on Kaggle and won't affect training")
