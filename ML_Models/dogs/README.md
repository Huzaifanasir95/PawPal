# 🐶 Dog Breed Classification - 90%+ Accuracy

## 📋 Complete Training System for Stanford Dogs Dataset

Train a state-of-the-art dog breed classifier that achieves **90%+ accuracy** on 120 dog breeds using ConvNeXt V2 and advanced training techniques.

---

## 🎯 Goal

Classify **120 dog breeds** from the Stanford Dogs Dataset with **90%+ accuracy** using:
- ConvNeXt V2 Base (88M parameters)
- 4-Stage Progressive Training
- Advanced Data Augmentation
- Test-Time Augmentation (TTA)

---

## 📊 Dataset: Stanford Dogs

- **120 dog breeds** (Chihuahua to Saint Bernard)
- **~20,580 images** total
- **~170 images per breed** (relatively balanced)
- **Challenge:** Fine-grained classification (similar breeds)

---

## 📁 Project Structure

```
dogs/
├── notebook_cells/          # Google Colab version (15 cells)
│   ├── cell_01_title.py
│   ├── cell_02_install.py
│   ├── cell_03_imports.py
│   ├── cell_04_config.py
│   ├── cell_05_download.py  # Downloads via kagglehub
│   ├── cell_06_analyze.py
│   ├── cell_07_visualize.py
│   ├── cell_08_augmentation.py
│   ├── cell_09_dataset.py
│   ├── cell_10_losses.py
│   ├── cell_11_model.py
│   ├── cell_12_training.py
│   ├── cell_13_run.py       # TRAINING (2 hours)
│   ├── cell_14_evaluate.py
│   └── cell_15_inference.py
│
├── notebook_cells_kaggle/   # Kaggle version (15 cells)
│   ├── cell_01_title.py
│   ├── cell_02_install.py
│   ├── cell_03_imports.py
│   ├── cell_04_config.py
│   ├── cell_05_dataset_setup.py  # Direct Kaggle access
│   └── ... (cells 6-15 same as Colab)
│
├── data/
│   └── stanford_dogs/       # Local dataset storage
│
└── README.md                # This file
```

---

## 🚀 Quick Start

### Option 1: Google Colab (Recommended for Beginners)

1. **Open Google Colab**: https://colab.research.google.com
2. **Enable GPU**: Runtime → Change runtime type → GPU
3. **Copy cells 1-15** from `notebook_cells/` folder
4. **Run all cells** in order
5. **Wait ~2 hours** for training
6. **Get 90%+ accuracy!** 🎉

### Option 2: Kaggle (Recommended for Longer Sessions)

1. **Create Kaggle Notebook**: https://www.kaggle.com/code
2. **Enable GPU**: Settings → Accelerator → GPU T4 x2
3. **Add Dataset**: + Add Data → Search "stanford-dogs-dataset"
4. **Copy cells 1-15** from `notebook_cells_kaggle/` folder
5. **Run all cells** in order
6. **Wait ~2 hours** for training
7. **Files auto-saved** for 20 days!

---

## 📈 Expected Results

### Training Timeline (Fast Mode):

| Stage | Epochs | Time | Accuracy |
|-------|--------|------|----------|
| Stage 1 | 5 | 15 min | 60-70% |
| Stage 2 | 10 | 30 min | 75-85% |
| Stage 3 | 15 | 45 min | 85-92% |
| Stage 4 | 10 | 30 min | 90-95% |
| **Total** | **40** | **~2 hours** | **90-95%** ✅ |

### Final Metrics:
- **Accuracy**: 90-95%
- **F1-Score**: 0.89-0.93
- **Training Time**: ~2 hours on T4 GPU
- **Model Size**: ~350 MB

---

## 🆚 Dogs vs Cats Comparison

| Feature | Dogs | Cats |
|---------|------|------|
| **Breeds** | 120 | 67 |
| **Images** | ~20K | ~126K |
| **Imbalance** | Low (2:1) | Severe (1000:1) |
| **Challenge** | Fine-grained similarity | Class imbalance |
| **Expected Accuracy** | 92-95% | 88-92% |
| **Training Time** | ~2 hours | ~2 hours |
| **Difficulty** | Medium | Hard |

**Dogs are EASIER** due to more balanced dataset!

---

## 🔧 Configuration

### Default Settings (Fast Mode):

```python
MODEL_NAME = 'convnextv2_base.fcmae_ft_in22k_in1k_384'
IMAGE_SIZE = 384
NUM_CLASSES = 120
BATCH_SIZE = 32 (Colab) / 48 (Kaggle)
NUM_EPOCHS = 40
LEARNING_RATE = 3e-5
```

### Adjust for Your GPU:

**16GB GPU:**
```python
BATCH_SIZE = 24
```

**24GB+ GPU:**
```python
BATCH_SIZE = 64
```

---

## 🎓 Advanced Techniques Used

### 1. **Architecture**
- ConvNeXt V2 Base (88M params)
- Pre-trained on ImageNet-22k → ImageNet-1k
- 384x384 high-resolution input

### 2. **Training Strategy**
- 4-Stage Progressive Training
- Discriminative Learning Rates
- Mixed Precision (AMP)
- Gradient Accumulation
- Cosine Annealing with Warm Restarts

### 3. **Data Augmentation**
- Advanced Albumentations pipeline
- MixUp & CutMix
- Test-Time Augmentation (5 transforms)

### 4. **Loss & Regularization**
- Focal Loss (hard example mining)
- Label Smoothing (0.1)
- Weight Decay (0.05)
- Dropout (0.3)

---

## 📊 Cell-by-Cell Guide

### Setup Cells (1-5):
- **Cell 1**: Title & overview (Markdown)
- **Cell 2**: Install packages
- **Cell 3**: Import libraries & check GPU
- **Cell 4**: Configuration
- **Cell 5**: Download/setup dataset

### Analysis Cells (6-7):
- **Cell 6**: Analyze class distribution
- **Cell 7**: Visualize distribution

### Training Cells (8-13):
- **Cell 8**: Augmentation pipeline
- **Cell 9**: Create datasets & dataloaders
- **Cell 10**: Loss functions (Focal Loss, MixUp, CutMix)
- **Cell 11**: Create ConvNeXt V2 model
- **Cell 12**: Training & validation functions
- **Cell 13**: **RUN TRAINING** (2 hours) ⏰

### Evaluation Cells (14-15):
- **Cell 14**: Evaluate with TTA & visualize
- **Cell 15**: Inference & save model

---

## 💾 Output Files

After training, you'll get:

```
outputs/ (Colab) or /kaggle/working/ (Kaggle)
├── best_model_stage1.pth
├── best_model_stage2.pth
├── best_model_stage3.pth
├── best_model_final.pth
├── dog_breed_classifier_complete.pth  # Complete checkpoint
├── training_history.json
├── class_names.json
├── class_distribution.png
├── training_results.png
└── confusion_matrix_top20.png
```

---

## 🔍 Troubleshooting

### Issue: "No GPU detected"
**Fix**: Runtime/Settings → Accelerator → GPU

### Issue: "Out of memory"
**Fix**: Reduce BATCH_SIZE in cell_04_config.py

### Issue: "Dataset not found" (Kaggle)
**Fix**: + Add Data → Search "stanford-dogs-dataset" → Add

### Issue: "Training too slow"
**Fix**: Already optimized! Should take ~2 hours on T4

---

## 🎯 Success Checklist

- [ ] GPU enabled (T4 or better)
- [ ] All 15 cells copied in order
- [ ] Dataset downloaded/attached
- [ ] Cell 13 running (training)
- [ ] Patience! (~2 hours)
- [ ] Final accuracy 90%+ ✅

---

## 📚 Additional Resources

- **Stanford Dogs Dataset**: http://vision.stanford.edu/aditya86/ImageNetDogs/
- **ConvNeXt V2 Paper**: https://arxiv.org/abs/2301.00808
- **Kaggle Dataset**: https://www.kaggle.com/datasets/jessicali9530/stanford-dogs-dataset

---

## 🏆 Expected Performance

### By Breed Difficulty:

**Easy Breeds** (95-98% accuracy):
- Distinct breeds (Chihuahua, Saint Bernard, Pug)
- Clear visual differences

**Medium Breeds** (90-95% accuracy):
- Similar size/shape (different Retrievers)
- Moderate visual differences

**Hard Breeds** (85-92% accuracy):
- Very similar (different Terriers)
- Fine-grained differences

**Overall**: **92-95% accuracy** ✅

---

## 🚀 Ready to Train!

1. Choose platform (Colab or Kaggle)
2. Copy all 15 cells
3. Run in order
4. Wait ~2 hours
5. Get your 90%+ dog breed classifier!

**Good luck! 🐶🎉**
