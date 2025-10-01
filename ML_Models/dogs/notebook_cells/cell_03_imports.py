import os
import sys
import random
import warnings
warnings.filterwarnings('ignore')

# Suppress PIL/OpenCV JPEG warnings (some images have minor corruption)
os.environ['PYTHONWARNINGS'] = 'ignore'
try:
    from PIL import ImageFile
    ImageFile.LOAD_TRUNCATED_IMAGES = True  # Load partially corrupted images
except:
    pass

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path
from collections import Counter, defaultdict
from tqdm.auto import tqdm
import json
import pickle
import cv2
from PIL import Image

import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader, WeightedRandomSampler
from torch.cuda.amp import GradScaler, autocast

import timm
import albumentations as A
from albumentations.pytorch import ToTensorV2

from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, f1_score, confusion_matrix, accuracy_score

# Check GPU
print(f"\n{'='*70}")
print(f"COLAB GPU CHECK")
print(f"{'='*70}")
print(f"PyTorch version: {torch.__version__}")
print(f"CUDA available: {torch.cuda.is_available()}")

if torch.cuda.is_available():
    print(f"\n🎉 GPU DETECTED!")
    print(f"   GPU: {torch.cuda.get_device_name(0)}")
    memory_gb = torch.cuda.get_device_properties(0).total_memory / 1024**3
    print(f"   Memory: {memory_gb:.1f} GB")
    print(f"   CUDA version: {torch.version.cuda}")
else:
    print("❌ WARNING: No GPU detected!")
    print("   Go to: Runtime → Change runtime type → GPU")

print(f"{'='*70}\n")

# Set seeds for reproducibility
def set_seed(seed=42):
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False

set_seed(42)
print("✅ Libraries imported successfully!")
print("✅ Random seeds set for reproducibility!")
