# Enhanced Cat Breed Classification - 90%+ Accuracy

This project implements an advanced cat breed classification system using state-of-the-art deep learning techniques to achieve 90%+ accuracy on 67 cat breeds.

## 🚀 Key Features

### Advanced Architecture
- **EfficientNetV2-S**: Modern architecture optimized for accuracy and efficiency
- **ConvNeXt-Tiny**: Alternative high-performance model
- **Enhanced Classifier**: Multi-layer classifier with advanced regularization

### Progressive Training
- **Stage 1**: Train classifier only (first 5 epochs)
- **Stage 2**: Train classifier + backbone layers (epochs 6-10)
- **Stage 3**: Train entire model (epochs 11+)

### Advanced Techniques
- **Class-weighted Loss**: Addresses severe class imbalance
- **MixUp & CutMix**: Data augmentation for better generalization
- **Label Smoothing**: Prevents overfitting
- **Gradient Clipping**: Stable training
- **Cosine Annealing**: Optimal learning rate scheduling
- **Early Stopping**: Prevents overfitting

### Data Handling
- **Image Validation**: Filters corrupted images automatically
- **Enhanced Augmentation**: Multiple transforms for robustness
- **Class Balance Analysis**: Detailed imbalance statistics

## 📊 Expected Performance

- **Target Accuracy**: 90%+ on validation set
- **Robust to Imbalance**: Special handling for underrepresented breeds
- **GPU Optimized**: Utilizes CUDA for fast training

## 🛠️ Installation

```bash
# Install dependencies
pip install -r requirements.txt

# Install timm for advanced models
pip install timm
```

## 🚀 Quick Start

### Train Enhanced Model
```bash
# Train with default settings (25 epochs, EfficientNetV2-S)
python main.py --mode train --epochs 25

# Train with custom settings
python main.py --mode train --epochs 30 --batch_size 12 --model_path my_model.pth

# Skip dataset validation (if already validated)
python main.py --mode train --epochs 25 --skip_validation
```

### Validate Dataset (One-time Setup)
```bash
# Validate dataset integrity (run once before training)
python main.py --mode validate
```

## 📁 Project Structure

```
code/
├── config.py              # Enhanced configuration with 90%+ accuracy settings
├── model.py               # Advanced model architectures and training techniques
├── train.py               # Progressive training with MixUp/CutMix
├── data_loader.py         # Enhanced data loading with validation
├── evaluate.py            # Comprehensive evaluation metrics
├── main.py                # Command-line interface
├── requirements.txt       # Dependencies including timm
└── README.md             # This file
```

## 🎯 Advanced Configuration

### Model Selection
```python
# In config.py
MODEL_NAME = 'efficientnetv2_s'  # Options: 'efficientnetv2_s', 'convnext_tiny', 'resnet50'
```

### Training Stages
```python
STAGE_1_EPOCHS = 5    # Classifier only
STAGE_2_EPOCHS = 10   # Classifier + backbone
STAGE_3_EPOCHS = 25   # Full model
```

### Data Augmentation
```python
USE_MIXUP_CUTMIX = True
MIXUP_ALPHA = 1.0
LABEL_SMOOTHING = 0.1
```

## 📈 Training Progress

The enhanced training provides:
- **Stage-by-stage visualization** of training progress
- **Class-wise performance analysis**
- **Confusion matrix** for breed identification
- **Learning rate scheduling** plots
- **Early stopping** when target accuracy is reached

## 🎉 Results

Expected outcomes:
- **Validation Accuracy**: 90%+ (vs 51% with basic ResNet-50)
- **Balanced Performance**: Better accuracy on underrepresented breeds
- **Robust Predictions**: MixUp/CutMix improves generalization
- **Fast Training**: EfficientNetV2-S is optimized for speed

## 🔧 Troubleshooting

### CUDA Issues
```bash
# Verify CUDA installation
python -c "import torch; print(torch.cuda.is_available())"

# Check GPU memory
python -c "import torch; print(torch.cuda.get_device_properties(0))"
```

### Memory Issues
- Reduce batch size in config.py
- Use smaller model: `MODEL_NAME = 'convnext_tiny'`
- Enable gradient checkpointing (advanced)

### Class Imbalance
- Automatic class weighting is enabled
- Check class distribution with `--mode validate`
- Consider data augmentation for rare breeds

## 📝 Notes

- Training time: ~2-4 hours on modern GPU
- Memory requirement: 8GB+ GPU RAM recommended
- Dataset: 67 cat breeds with class imbalance handling
- Models saved with full training state for resuming

## 🤝 Contributing

This enhanced version focuses on achieving state-of-the-art accuracy through:
1. Modern architectures (EfficientNetV2, ConvNeXt)
2. Advanced training techniques (progressive learning, MixUp)
3. Class imbalance handling (weighted loss, focal loss concepts)
4. Robust evaluation (confusion matrix, per-class metrics)

For questions or improvements, please check the code comments and configuration options.