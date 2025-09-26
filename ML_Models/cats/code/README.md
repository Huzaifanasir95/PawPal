# Cat Breed Classification - PawPal ML Model

This directory contains the modular Python scripts for training and evaluating a cat breed classification model using PyTorch and transfer learning with ResNet-50.

## Project Structure

```
code/
├── config.py          # Configuration parameters and paths
├── data_loader.py     # Dataset loading, validation, and preprocessing
├── model.py           # Model definition and utilities
├── train.py           # Training script
├── evaluate.py        # Evaluation and analysis script
├── main.py            # Main entry point for training/evaluation
└── requirements.txt   # Python dependencies
```

## Setup

1. **Install Dependencies**
   ```bash
   pip install -r requirements.txt
   ```

2. **Dataset Structure**
   The scripts expect the dataset to be organized as:
   ```
   data/cat_breeds_dataset/
   ├── images/           # Folder containing breed subfolders with images
   │   ├── breed1/
   │   ├── breed2/
   │   └── ...
   └── data/
       └── cats.csv     # CSV file with image metadata
   ```

## Usage

### Training

Train the model from scratch:
```bash
python main.py --mode train --epochs 15
```

Train with custom parameters:
```bash
python main.py --mode train --epochs 20 --batch_size 64 --model_path my_model.pth
```

### Evaluation

Evaluate a trained model:
```bash
python main.py --mode evaluate --model_path cat_breed_classifier.pth
```

### Dataset Validation

Validate dataset integrity before training:
```bash
python main.py --mode validate
```

## Configuration

All configuration parameters are defined in `config.py`:

- **Dataset Paths**: `DATASET_ROOT`, `IMAGES_PATH`, `CSV_PATH`
- **Training Parameters**: `BATCH_SIZE`, `NUM_EPOCHS`, `LEARNING_RATE`
- **Model Parameters**: `NUM_CLASSES`, `MODEL_SAVE_PATH`
- **Image Parameters**: `IMAGE_SIZE`, `MEAN`, `STD`
- **Device**: Automatically detects CUDA if available

## Model Architecture

- **Base Model**: ResNet-50 (pretrained on ImageNet)
- **Transfer Learning**: Only the final classification head is trained
- **Classification Head**: 2048 → 512 → 67 (with ReLU, Dropout, LogSoftmax)
- **Loss Function**: Negative Log Likelihood Loss (NLLLoss)
- **Optimizer**: Adam (lr=0.001)
- **Scheduler**: StepLR (step_size=7, gamma=0.1)

## Features

- **Robust Dataset Handling**: Automatically filters corrupted images
- **Cross-Platform Compatibility**: Works on Windows, Linux, and macOS
- **GPU Support**: Automatic CUDA detection and utilization
- **Progress Monitoring**: Real-time training progress with tqdm
- **Comprehensive Evaluation**: Confusion matrix, per-breed metrics, error analysis
- **Visualization**: Training history plots and confusion matrices
- **Model Persistence**: Save/load model checkpoints with training history

## Output Files

After training:
- `cat_breed_classifier.pth`: Best model checkpoint
- `training_history.png`: Training curves (loss, accuracy, learning rate)
- `confusion_matrix.png`: Evaluation confusion matrix

## Troubleshooting

1. **CUDA Issues**: If CUDA is not available, the model will automatically use CPU
2. **Memory Issues**: Reduce `BATCH_SIZE` if you encounter out-of-memory errors
3. **Dataset Issues**: Run `python main.py --mode validate` to check dataset integrity
4. **Import Errors**: Ensure all dependencies are installed with `pip install -r requirements.txt`

## Performance

- **Expected Accuracy**: ~85-95% validation accuracy (depending on dataset quality)
- **Training Time**: ~30-60 minutes on GPU, ~2-4 hours on CPU (15 epochs)
- **Inference Speed**: ~50-100 images/second on GPU

## Next Steps

- Fine-tune hyperparameters in `config.py`
- Experiment with different architectures (EfficientNet, ViT)
- Add data augmentation techniques
- Implement model quantization for deployment
- Create a web API for breed prediction