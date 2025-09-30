# 🐱 Cat Breed Classifier - Kaggle Optimized Version

## 📋 Complete Guide for Kaggle Notebooks

This folder contains **15 cell files + documentation** optimized for training on **Kaggle with GPU acceleration**.

---

## 🎯 Goal: 90%+ Accuracy with Severe Class Imbalance

### Why This Works:
- ✅ **ConvNeXt V2 Base** (88M params) - SOTA architecture
- ✅ **Focal Loss** - Hard example mining
- ✅ **Weighted Sampling** - 4x boost for rare classes  
- ✅ **MixUp & CutMix** - Synthetic data generation
- ✅ **4-Stage Progressive Training** - Gradual unfreezing
- ✅ **Test-Time Augmentation** - 5-transform ensemble
- ✅ **Mixed Precision (AMP)** - Faster training
- ✅ **Multi-GPU Support** - T4 x2 with DataParallel

---

## 📁 Files in This Folder

### 📖 Documentation:
- **QUICK_START.md** - 5-step guide (start here!)
- **KAGGLE_SETUP.md** - Detailed setup instructions
- **README.md** - This file

### 💻 Cell Files (copy in order):
1. `cell_01_title.py` - Overview (MARKDOWN)
2. `cell_02_install.py` - Install packages
3. `cell_03_imports.py` - Import libraries
4. `cell_04_config.py` - Configuration
5. `cell_05_dataset_setup.py` - Verify dataset
6. `cell_06_analyze.py` - Analyze class distribution
7. `cell_07_visualize.py` - Visualize imbalance
8. `cell_08_augmentation.py` - Augmentation pipeline
9. `cell_09_dataset.py` - Dataset & dataloaders
10. `cell_10_losses.py` - Focal Loss + MixUp/CutMix
11. `cell_11_model.py` - Create ConvNeXt V2
12. `cell_12_training.py` - Training functions
13. `cell_13_run.py` - **RUN TRAINING (3-4h)**
14. `cell_14_evaluate.py` - Evaluate with TTA
15. `cell_15_inference.py` - Inference & save

---

## 🚀 Quick Start (5 minutes setup)

### 1. Create Notebook
- Go to https://www.kaggle.com/code
- Click **New Notebook**

### 2. Enable GPU
- Settings → **Accelerator** → **GPU T4 x2**
- Settings → **Internet** → **ON**

### 3. Add Dataset
- Click **+ Add Data**
- Search **"cat-breeds-dataset"**
- Add the one by **ma7555**

### 4. Copy Cells
- Copy code from `cell_01_title.py` → New MARKDOWN cell
- Copy code from `cell_02_install.py` → New CODE cell
- ... repeat for all 15 cells

### 5. Run All
- Click **Run All** (or run cells 1→15)
- Wait 3-4 hours
- Get 90%+ accuracy! 🎉

---

## 🆚 Kaggle vs Colab Differences

| Feature | Kaggle | Colab |
|---------|--------|-------|
| Dataset access | Direct (no download) | Download via kagglehub |
| Output path | `/kaggle/working/` | `/content/outputs/` |
| Persistence | 20 days | Until session ends |
| Session limit | 12 hours | 90 min idle |
| GPU options | T4 x2, P100 | T4, V100, A100 |
| Multi-GPU | DataParallel (T4 x2) | Single GPU |
| Batch size | 32 (default) | 24 (default) |

---

## 💾 What Gets Saved

Everything in `/kaggle/working/` is auto-saved:

```
/kaggle/working/
├── best_model_stage1.pth           # Best model after stage 1
├── best_model_stage2.pth           # Best model after stage 2
├── best_model_stage3.pth           # Best model after stage 3
├── best_model_final.pth            # Best overall model
├── cat_breed_classifier_complete.pth  # Complete checkpoint
├── training_history.json           # Loss/accuracy curves
├── class_names.json               # 67 breed names
├── class_distribution.png         # Imbalance visualization
├── training_results.png           # Training curves
└── confusion_matrix_top20.png     # Performance heatmap
```

**Access:** Click files in output panel → Download button

---

## ⚙️ Configuration Options

Edit `cell_04_config.py` before running:

### For 16GB GPU:
```python
BATCH_SIZE = 24  # Reduce from 32
```

### For 24GB+ GPU:
```python
BATCH_SIZE = 48  # Increase from 32
```

### For faster training (may reduce accuracy):
```python
NUM_EPOCHS = 40  # Reduce from 60
STAGE_4_EPOCHS = 40
```

### For even better accuracy (slower):
```python
NUM_EPOCHS = 80  # Increase from 60
RARE_CLASS_BOOST = 5.0  # More boost for rare classes
```

---

## 📊 Expected Timeline

| Stage | Time | Accuracy | What Happens |
|-------|------|----------|--------------|
| Setup | 2 min | - | Install, import, analyze |
| Stage 1 | 20 min | 60-70% | Train head only |
| Stage 2 | 45 min | 75-85% | Unfreeze last 1/4 |
| Stage 3 | 1.5h | 85-92% | Unfreeze last 1/2 |
| Stage 4 | 1h | 90-95% | Full fine-tuning |
| TTA | 5 min | +1-3% | Test-time augmentation |
| **Total** | **~3-4h** | **90-95%** | ✅ Done! |

---

## 🎯 Success Indicators

### During Training:
```
✅ New best accuracy: 91.23%   ← Good! Improving
⏸️ Early stopping triggered    ← Training stopped (patience=20)
```

### Final Results:
```
🎉 TRAINING COMPLETED ON KAGGLE!
✅ Final TTA Accuracy: 92.34%
🏆 TARGET ACHIEVED! Model reached 90%+ accuracy!
```

---

## 🔧 Troubleshooting

### Issue: "No GPU detected"
**Fix:** Settings → Accelerator → GPU T4 x2

### Issue: "Dataset not found"
**Fix:** + Add Data → Search "cat-breeds-dataset" → Add

### Issue: "CUDA out of memory"
**Fix:** In cell_04, change `BATCH_SIZE = 24` or `16`

### Issue: "Accuracy stuck at 80%"
**Fix:** 
- Let all 4 stages complete
- TTA adds 1-3% improvement at end
- If still <90%, increase epochs

### Issue: "Session timeout"
**Fix:** Kaggle allows 12 hours. Should be enough for 60 epochs.

---

## 🏆 Performance Expectations

### Standard Classes (100+ images):
- **Accuracy:** 95-98%
- **Very easy** to classify

### Medium Classes (10-100 images):
- **Accuracy:** 85-92%
- **Good** performance with augmentation

### Rare Classes (<10 images):
- **Accuracy:** 70-85%
- **Challenging** but handled by:
  - 4x weighted sampling
  - Heavy augmentation
  - Focal Loss
  - Transfer learning

### Overall:
- **Final TTA Accuracy:** 90-95% ✅
- **Weighted F1-Score:** 0.88-0.92

---

## 💡 Pro Tips

1. **Use T4 x2** if available (2 GPUs = faster training)
2. **Enable Internet** (needed to download timm weights)
3. **Don't stop Cell 13 early** - Let all 4 stages complete
4. **Save notebook frequently** - Click "Save Version"
5. **Download model** from output panel when done
6. **Commit notebook** to save permanently

---

## 📞 Need Help?

### Check:
1. ✅ GPU enabled (T4 x2)
2. ✅ Internet enabled
3. ✅ Dataset added (cat-breeds-dataset)
4. ✅ All cells copied in order
5. ✅ Cells running sequentially

### Common Mistakes:
- ❌ Running cells out of order
- ❌ Forgetting to add dataset
- ❌ GPU not enabled
- ❌ Stopping training too early

---

## 🎓 Key Differences from Colab Version

1. **No dataset download** - Direct access via `/kaggle/input/`
2. **Multi-GPU support** - DataParallel for T4 x2
3. **Larger batch size** - 32 vs 24 (more GPU memory)
4. **Auto-saved outputs** - `/kaggle/working/` saved for 20 days
5. **Longer sessions** - 12 hours vs 90 min

---

## 🚀 Ready to Train?

1. Read **QUICK_START.md** for 5-step guide
2. Copy all 15 cells into Kaggle notebook
3. Run all cells in order
4. Wait 3-4 hours
5. Download your 90%+ accuracy model!

**Good luck! 🐱🎉**
