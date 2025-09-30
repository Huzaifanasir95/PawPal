# Install required packages
print("📦 Installing required packages...")
print("This may take 2-3 minutes...\n")

!pip install -q torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
!pip install -q timm albumentations opencv-python-headless
!pip install -q kagglehub scikit-learn pandas
!pip install -q matplotlib seaborn tqdm

print("\n✅ All packages installed successfully!")
print("🚀 Ready to train!")
