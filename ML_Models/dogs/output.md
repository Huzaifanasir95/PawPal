cell 1
📦 Installing required packages...
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 68.5/68.5 kB 2.1 MB/s eta 0:00:00
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 58.9/58.9 kB 3.1 MB/s eta 0:00:00
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 2.2/2.2 MB 32.8 MB/s eta 0:00:00
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 125.7/125.7 kB 7.3 MB/s eta 0:00:00
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 34.1/34.1 MB 52.5 MB/s eta 0:00:00
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 17.3/17.3 MB 94.6 MB/s eta 0:00:00
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 50.0/50.0 MB 36.5 MB/s eta 0:00:00
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 14.9/14.9 MB 93.7 MB/s eta 0:00:00
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 363.4/363.4 MB 4.7 MB/s eta 0:00:00
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 13.8/13.8 MB 84.0 MB/s eta 0:00:00
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 24.6/24.6 MB 76.5 MB/s eta 0:00:00
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 883.7/883.7 kB 40.7 MB/s eta 0:00:00
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 664.8/664.8 MB 2.7 MB/s eta 0:00:00
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 211.5/211.5 MB 6.2 MB/s eta 0:00:00
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 56.3/56.3 MB 29.5 MB/s eta 0:00:00
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 127.9/127.9 MB 5.7 MB/s eta 0:00:00
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 207.5/207.5 MB 2.2 MB/s eta 0:00:00
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 21.1/21.1 MB 77.1 MB/s eta 0:00:00

✅ Packages installed successfully!
🚀 Ready to train on Kaggle GPU!

💡 Note: Dependency warnings are normal on Kaggle and won't affect training


cell 2

======================================================================
KAGGLE GPU CHECK
======================================================================
PyTorch version: 2.6.0+cu124
CUDA available: True

🎉 GPU DETECTED!
   GPU 0: Tesla T4
   Memory: 14.7 GB
   GPU 1: Tesla T4
   Memory: 14.7 GB
   CUDA version: 12.4

💪 T4 x2 detected! Using DataParallel for faster training
======================================================================

✅ Libraries imported successfully!
✅ Random seeds set for reproducibility!

cell 3

======================================================================
KAGGLE GPU CHECK
======================================================================
PyTorch version: 2.6.0+cu124
CUDA available: True

🎉 GPU DETECTED!
   GPU 0: Tesla T4
   Memory: 14.7 GB
   GPU 1: Tesla T4
   Memory: 14.7 GB
   CUDA version: 12.4

💪 T4 x2 detected! Using DataParallel for faster training
======================================================================

✅ Libraries imported successfully!
✅ Random seeds set for reproducibility!


cell 4

✅ Kaggle Configuration loaded!
======================================================================
📦 Model: convnextv2_base.fcmae_ft_in22k_in1k_384
💾 Device: cuda
🖼️  Image Size: 384x384
📊 Batch Size: 48 (effective: 48)
🎯 Epochs: 40
💪 Multi-GPU: ✓ Enabled
📂 Dataset: Stanford Dogs (120 breeds)
💾 Output: /kaggle/working (auto-saved!)
======================================================================

🎯 TARGET: 90%+ accuracy on Stanford Dogs Dataset
⏱️  Expected training time: ~2 hours on T4 x2



cell 5
📂 Verifying Kaggle dataset access...
✅ Dataset found at: /kaggle/input/stanford-dogs-dataset
📂 Images directory: /kaggle/input/stanford-dogs-dataset/images/Images

📊 Dataset verified:
   • Breed folders: 120
   • Total images: 20,580
   • Ready for training! 🚀

cell 6

======================================================================
📊 DATASET DISTRIBUTION ANALYSIS
======================================================================

Scanning and validating images:   0%|          | 0/120 [00:00<?, ?it/s]

📈 STATISTICS:
   Total Breeds: 120
   Total Valid Images: 20,580
   Min images per class: 148
   Max images per class: 252
   Mean images per class: 171.5
   Median images per class: 159.5
   Std Dev: 23.1

⚖️  IMBALANCE RATIO: 1.7:1
   ✅ WELL-BALANCED DATASET!

======================================================================

✅ Dataset analysis complete!
   Total samples: 20,580
   Total classes: 120

cell 7
for cell 7 image is atatched 

cell 8
✅ Advanced augmentation pipeline created!
   • Training: Heavy augmentation with Albumentations
   • Validation: Center crop only
   • TTA: 5 different transforms

cell 9

📊 Creating stratified train/val split...
   • Training samples: 17,492
   • Validation samples: 3,088

✅ Dataloaders created!
   • Train batches: 364
   • Val batches: 65
   • Effective batch size: 48


cell 10
✅ Using Focal Loss (α=0.25, γ=2.0)

🔀 Data mixing:
   • MixUp: ✓ (α=0.4)
   • CutMix: ✓ (α=1.0)
   • Mix probability: 30.0%


cell 11
📦 Creating model: convnextv2_base.fcmae_ft_in22k_in1k_384
   This may take 1-2 minutes to download pre-trained weights...

model.safetensors:   0%|          | 0.00/355M [00:00<?, ?B/s]
💪 Using DataParallel across 2 GPUs

✅ Model created successfully!
======================================================================
Architecture: convnextv2_base.fcmae_ft_in22k_in1k_384
Input size: 384x384
Number of classes: 120
Total parameters: 87,815,800
Trainable parameters: 87,815,800
Model size: ~335.0 MB (FP32)
Multi-GPU: ✓ Using 2 GPUs
======================================================================

✅ Model ready for progressive training on Kaggle GPU!


cell 12
✅ Training and validation functions ready!


cell 13

======================================================================
🚀 STARTING 4-STAGE PROGRESSIVE TRAINING ON KAGGLE
======================================================================


📚 STAGE 1: Training classification head only
   Freezing backbone, training head for 5 epochs

   Trainable parameters: 83,970,296
Stage 1 | Epoch 1:   0%|          | 0/364 [00:00<?, ?it/s]
Validation:   0%|          | 0/65 [00:00<?, ?it/s]
   Epoch 1/5 - Train Loss: 0.6195, Val Loss: 0.0639, Val Acc: 89.99%, LR: 2.71e-05
   ✅ New best accuracy: 89.99%
Stage 1 | Epoch 2:   0%|          | 0/364 [00:00<?, ?it/s]
Validation:   0%|          | 0/65 [00:00<?, ?it/s]
   Epoch 2/5 - Train Loss: 0.2008, Val Loss: 0.0485, Val Acc: 90.64%, LR: 1.97e-05
   ✅ New best accuracy: 90.64%
Stage 1 | Epoch 3:   0%|          | 0/364 [00:00<?, ?it/s]
Validation:   0%|          | 0/65 [00:00<?, ?it/s]
   Epoch 3/5 - Train Loss: 0.1559, Val Loss: 0.0448, Val Acc: 90.97%, LR: 1.04e-05
   ✅ New best accuracy: 90.97%
Stage 1 | Epoch 4:   0%|          | 0/364 [00:00<?, ?it/s]
Validation:   0%|          | 0/65 [00:00<?, ?it/s]
   Epoch 4/5 - Train Loss: 0.1218, Val Loss: 0.0413, Val Acc: 91.71%, LR: 2.96e-06
   ✅ New best accuracy: 91.71%
Stage 1 | Epoch 5:   0%|          | 0/364 [00:00<?, ?it/s]
Validation:   0%|          | 0/65 [00:00<?, ?it/s]
   Epoch 5/5 - Train Loss: 0.1201, Val Loss: 0.0407, Val Acc: 92.03%, LR: 3.00e-05
   ✅ New best accuracy: 92.03%

📚 STAGE 2: Unfreezing last 1/4 of backbone
   Training for 10 more epochs

   Trainable parameters: 86,412,024
Stage 2 | Epoch 6:   0%|          | 0/364 [00:00<?, ?it/s]
Validation:   0%|          | 0/65 [00:00<?, ?it/s]
   Epoch 6/15 - Train Loss: 0.1259, Val Loss: 0.0416, Val Acc: 91.39%, LR: 2.93e-05
Stage 2 | Epoch 7:   0%|          | 0/364 [00:00<?, ?it/s]
Validation:   0%|          | 0/65 [00:00<?, ?it/s]
   Epoch 7/15 - Train Loss: 0.1282, Val Loss: 0.0449, Val Acc: 91.26%, LR: 2.71e-05
Stage 2 | Epoch 8:   0%|          | 0/364 [00:00<?, ?it/s]
Validation:   0%|          | 0/65 [00:00<?, ?it/s]
   Epoch 8/15 - Train Loss: 0.1236, Val Loss: 0.0429, Val Acc: 91.58%, LR: 2.38e-05
Stage 2 | Epoch 9:   0%|          | 0/364 [00:00<?, ?it/s]
Validation:   0%|          | 0/65 [00:00<?, ?it/s]
   Epoch 9/15 - Train Loss: 0.1231, Val Loss: 0.0432, Val Acc: 91.26%, LR: 1.97e-05
Stage 2 | Epoch 10:   0%|          | 0/364 [00:00<?, ?it/s]
Validation:   0%|          | 0/65 [00:00<?, ?it/s]
   Epoch 10/15 - Train Loss: 0.1077, Val Loss: 0.0410, Val Acc: 91.74%, LR: 1.51e-05
Stage 2 | Epoch 11:   0%|          | 0/364 [00:00<?, ?it/s]
Validation:   0%|          | 0/65 [00:00<?, ?it/s]
   Epoch 11/15 - Train Loss: 0.0824, Val Loss: 0.0413, Val Acc: 91.52%, LR: 1.04e-05
Stage 2 | Epoch 12:   0%|          | 0/364 [00:00<?, ?it/s]
Validation:   0%|          | 0/65 [00:00<?, ?it/s]
   Epoch 12/15 - Train Loss: 0.0843, Val Loss: 0.0411, Val Acc: 92.26%, LR: 6.26e-06
   ✅ New best accuracy: 92.26%
Stage 2 | Epoch 13:   0%|          | 0/364 [00:00<?, ?it/s]
Validation:   0%|          | 0/65 [00:00<?, ?it/s]
   Epoch 13/15 - Train Loss: 0.0860, Val Loss: 0.0409, Val Acc: 92.39%, LR: 2.96e-06
   ✅ New best accuracy: 92.39%
Stage 2 | Epoch 14:   0%|          | 0/364 [00:00<?, ?it/s]
Validation:   0%|          | 0/65 [00:00<?, ?it/s]
   Epoch 14/15 - Train Loss: 0.0932, Val Loss: 0.0404, Val Acc: 92.45%, LR: 8.32e-07
   ✅ New best accuracy: 92.45%
Stage 2 | Epoch 15:   0%|          | 0/364 [00:00<?, ?it/s]
Validation:   0%|          | 0/65 [00:00<?, ?it/s]
   Epoch 15/15 - Train Loss: 0.0990, Val Loss: 0.0401, Val Acc: 92.42%, LR: 3.00e-05

📚 STAGE 3: Unfreezing last 1/2 of backbone
   Training for 15 more epochs

   Trainable parameters: 86,714,616
Stage 3 | Epoch 16:   0%|          | 0/364 [00:00<?, ?it/s]
Validation:   0%|          | 0/65 [00:00<?, ?it/s]
   Epoch 16/30 - Train Loss: 0.0941, Val Loss: 0.0420, Val Acc: 92.07%, LR: 2.98e-05
Stage 3 | Epoch 17:   0%|          | 0/364 [00:00<?, ?it/s]
Validation:   0%|          | 0/65 [00:00<?, ?it/s]
   Epoch 17/30 - Train Loss: 0.0891, Val Loss: 0.0451, Val Acc: 91.22%, LR: 2.93e-05
Stage 3 | Epoch 18:   0%|          | 0/364 [00:00<?, ?it/s]
Validation:   0%|          | 0/65 [00:00<?, ?it/s]
   Epoch 18/30 - Train Loss: 0.0982, Val Loss: 0.0433, Val Acc: 91.13%, LR: 2.84e-05
Stage 3 | Epoch 19:   0%|          | 0/364 [00:00<?, ?it/s]
Validation:   0%|          | 0/65 [00:00<?, ?it/s]
   Epoch 19/30 - Train Loss: 0.0885, Val Loss: 0.0460, Val Acc: 90.90%, LR: 2.71e-05
Stage 3 | Epoch 20:   0%|          | 0/364 [00:00<?, ?it/s]
Validation:   0%|          | 0/65 [00:00<?, ?it/s]
   Epoch 20/30 - Train Loss: 0.0906, Val Loss: 0.0449, Val Acc: 91.87%, LR: 2.56e-05
Stage 3 | Epoch 21:   0%|          | 0/364 [00:00<?, ?it/s]
Validation:   0%|          | 0/65 [00:00<?, ?it/s]
   Epoch 21/30 - Train Loss: 0.0900, Val Loss: 0.0454, Val Acc: 91.58%, LR: 2.38e-05
Stage 3 | Epoch 22:   0%|          | 0/364 [00:00<?, ?it/s]
Validation:   0%|          | 0/65 [00:00<?, ?it/s]
   Epoch 22/30 - Train Loss: 0.0783, Val Loss: 0.0453, Val Acc: 91.16%, LR: 2.18e-05
Stage 3 | Epoch 23:   0%|          | 0/364 [00:00<?, ?it/s]
Validation:   0%|          | 0/65 [00:00<?, ?it/s]
   Epoch 23/30 - Train Loss: 0.0829, Val Loss: 0.0435, Val Acc: 92.07%, LR: 1.97e-05
Stage 3 | Epoch 24:   0%|          | 0/364 [00:00<?, ?it/s]
Validation:   0%|          | 0/65 [00:00<?, ?it/s]
   Epoch 24/30 - Train Loss: 0.0748, Val Loss: 0.0438, Val Acc: 91.74%, LR: 1.74e-05
Stage 3 | Epoch 25:   0%|          | 0/364 [00:00<?, ?it/s]
Validation:   0%|          | 0/65 [00:00<?, ?it/s]
   Epoch 25/30 - Train Loss: 0.0881, Val Loss: 0.0442, Val Acc: 91.81%, LR: 1.51e-05
Stage 3 | Epoch 26:   0%|          | 0/364 [00:00<?, ?it/s]
Validation:   0%|          | 0/65 [00:00<?, ?it/s]
   Epoch 26/30 - Train Loss: 0.0705, Val Loss: 0.0440, Val Acc: 91.81%, LR: 1.27e-05

   ⏸️  Early stopping triggered at epoch 26

======================================================================
🎉 TRAINING COMPLETED ON KAGGLE!
======================================================================
📊 Best Validation Accuracy: 92.45%
📁 Model saved to: /kaggle/working/ (auto-saved for 20 days!)
======================================================================

✅ Training history and class names saved to /kaggle/working/
💡 Files will be available in the notebook output panel!


cell 14
📥 Loading best model...
   ✅ Found: best_model_stage2.pth
   ✅ Found: best_model_stage1.pth
🎯 Loading: best_model_stage2.pth

🔍 Running standard validation...
Validation:   0%|          | 0/65 [00:00<?, ?it/s]

📊 Standard Validation Results:
   Accuracy: 92.45%
   Loss: 0.0404

🔮 Running TTA with 5 transforms...
TTA Validation:   0%|          | 0/65 [00:00<?, ?it/s]

🔮 TTA Validation Results:
   Accuracy: 92.58%
   Improvement: +0.13%

📋 Calculating per-class metrics...
   Weighted F1-Score: 0.9240


cell 14 
image atatched 