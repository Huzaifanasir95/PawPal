# 🐱 Advanced Cat Breed Classification - Cell Order Guide

## 📋 How to Use These Files in Google Colab

### Instructions:
1. Create a new Jupyter notebook in Google Colab
2. Copy the code from each file below into **separate cells** in order
3. Run cells sequentially (Cell 1 → Cell 2 → ... → Cell 15)

---

## 📝 Cell Order:

| Cell # | File Name | Description | Cell Type |
|--------|-----------|-------------|-----------|
| **1** | `cell_01_title.py` | Title and overview | Markdown |
| **2** | `cell_02_install.py` | Install packages | Code |
| **3** | `cell_03_imports.py` | Import libraries & GPU check | Code |
| **4** | `cell_04_config.py` | Configuration class | Code |
| **5** | `cell_05_download.py` | Download dataset from Kaggle | Code |
| **6** | `cell_06_analyze.py` | Analyze class distribution | Code |
| **7** | `cell_07_visualize.py` | Visualize class imbalance | Code |
| **8** | `cell_08_augmentation.py` | Advanced augmentation pipeline | Code |
| **9** | `cell_09_dataset.py` | Custom dataset with class balancing | Code |
| **10** | `cell_10_losses.py` | Focal Loss & MixUp/CutMix | Code |
| **11** | `cell_11_model.py` | Create ConvNeXt V2 model | Code |
| **12** | `cell_12_training.py` | Training & validation functions | Code |
| **13** | `cell_13_run.py` | Run 4-stage progressive training | Code |
| **14** | `cell_14_evaluate.py` | Evaluate & visualize results | Code |
| **15** | `cell_15_inference.py` | Inference function with TTA | Code |

---

## 🎯 Expected Accuracy: **90%+**

### Key Features:
✅ ConvNeXt V2 Base (88M parameters)  
✅ Focal Loss for hard examples  
✅ Weighted sampling (4x boost for rare classes)  
✅ Advanced augmentation (MixUp, CutMix, Albumentations)  
✅ 4-stage progressive training  
✅ Test-Time Augmentation  
✅ Mixed precision training (AMP)  

---

## 💡 Tips:
- Make sure GPU is enabled: Runtime → Change runtime type → GPU (T4 or better)
- Estimated training time: 3-4 hours on T4 GPU
- Required GPU memory: 15GB+ (reduce BATCH_SIZE if needed)
- The model will automatically handle classes with only 1-2 images!
