# MARKDOWN CELL - Copy this as markdown, not code!

"""
# 🐱 Advanced Cat Breed Classification - 90%+ Accuracy (KAGGLE)

## 🎯 Goal: Achieve 90%+ accuracy with severe class imbalance

### 🚀 Advanced Techniques Implemented:

#### **1. Architecture**
- **ConvNeXt V2 Base** (88M parameters) - State-of-the-art CNN
- Pre-trained on ImageNet-22k → ImageNet-1k
- 384x384 input resolution for fine details

#### **2. Class Imbalance Solutions** ⚠️ CRITICAL!
- **Focal Loss** - Focuses on hard-to-classify examples
- **Weighted Random Sampling** - Balances batch composition
- **Class-Balanced Weights** - Emphasizes rare classes
- **Rare Class Boost (4x)** - Extra augmentation for classes with <10 images
- **Stratified Train/Val Split** - Ensures all classes represented

#### **3. Data Augmentation Suite**
- **Advanced Albumentations**: RandAugment, perspective, distortion
- **MixUp & CutMix** - Generates synthetic training examples
- **Test-Time Augmentation (TTA)** - 5 transforms for inference

#### **4. Training Strategy**
- **4-Stage Progressive Training** - Gradual unfreezing
- **Discriminative Learning Rates** - Lower LR for backbone
- **Mixed Precision (AMP)** - Faster training with FP16
- **Gradient Accumulation** - Effective batch size = 72
- **Cosine Annealing** with warm restarts

#### **5. Regularization**
- Label Smoothing (0.1)
- Weight Decay (0.05)
- Gradient Clipping (1.0)
- Dropout (0.3)

---

## 📊 Dataset: 67 Cat Breeds (~126K images)
- **Challenge**: SEVERE IMBALANCE (some breeds have only 1-2 images!)
- **Solution**: Multi-pronged approach with special rare class handling

---

## ⚡ Kaggle Advantages:
✅ **Direct dataset access** - No download needed!  
✅ **Persistent storage** - Saves for 20 days  
✅ **Longer sessions** - 12 hours vs 90 min  
✅ **GPU T4 x2 or P100** - Free!  

---

## 🎯 Setup Checklist:
1. ✅ Click **+ Add Data** → Search "cat-breeds-dataset" → Add
2. ✅ **Settings** → Accelerator → **GPU T4 x2**
3. ✅ **Settings** → Internet → **ON**
4. ✅ Run all cells in order

**Let's get 90%+ accuracy! 🚀**
"""
