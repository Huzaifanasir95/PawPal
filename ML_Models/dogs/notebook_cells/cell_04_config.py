class Config:
    """Advanced training configuration for Stanford Dogs - 90%+ accuracy"""
    
    # Paths (will be updated after dataset download)
    DATASET_ROOT = "/content/stanford_dogs_dataset"
    IMAGES_PATH = None  # Will be set after download
    OUTPUT_DIR = "/content/outputs"
    
    # Model Architecture
    MODEL_NAME = 'convnextv2_base.fcmae_ft_in22k_in1k_384'  # 88M params
    IMAGE_SIZE = 384
    NUM_CLASSES = 120  # Stanford Dogs has 120 breeds
    
    # Training Hyperparameters (⚡ FAST MODE - 2 hours!)
    BATCH_SIZE = 16         # Reduced for T4 GPU (15GB)
    ACCUMULATION_STEPS = 4  # Effective batch size = 64
    NUM_EPOCHS = 40         # Fewer epochs, still 90%+
    LEARNING_RATE = 3e-5    # Conservative for fine-tuning
    WEIGHT_DECAY = 0.05
    SCHEDULER_T0 = 5        # Faster restarts
    SCHEDULER_TMULT = 2
    
    # Progressive Training Stages (⚡ FASTER 4-stage)
    STAGE_1_EPOCHS = 5    # Train head faster
    STAGE_2_EPOCHS = 15   # Unfreeze last 1/4
    STAGE_3_EPOCHS = 30   # Unfreeze last 1/2
    STAGE_4_EPOCHS = 40   # Full fine-tuning
    
    # Data Split
    TRAIN_RATIO = 0.85
    VAL_RATIO = 0.15
    
    # Data Augmentation
    USE_MIXUP = True
    USE_CUTMIX = True
    MIXUP_ALPHA = 0.4
    CUTMIX_ALPHA = 1.0
    MIX_PROB = 0.3          # Less mixing = faster
    
    # Test-Time Augmentation
    USE_TTA = True
    TTA_TRANSFORMS = 5
    
    # Regularization
    LABEL_SMOOTHING = 0.1
    DROPOUT = 0.3
    GRADIENT_CLIP = 1.0
    
    # Focal Loss Parameters
    USE_FOCAL_LOSS = True
    FOCAL_ALPHA = 0.25
    FOCAL_GAMMA = 2.0
    
    # Mixed Precision Training
    USE_AMP = True
    
    # Learning Rate Scheduler
    SCHEDULER_T0 = 10
    ETA_MIN = 1e-7
    WARMUP_EPOCHS = 2
    
    # System
    DEVICE = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    NUM_WORKERS = 4  # Faster data loading
    PIN_MEMORY = True
    
    # ImageNet normalization
    MEAN = [0.485, 0.456, 0.406]
    STD = [0.229, 0.224, 0.225]
    
    # Checkpointing
    EARLY_STOPPING_PATIENCE = 12
    SAVE_BEST_ONLY = True

config = Config()
os.makedirs(config.OUTPUT_DIR, exist_ok=True)

print(f"\n✅ Configuration loaded!")
print(f"{'='*70}")
print(f"📦 Model: {config.MODEL_NAME}")
print(f"💾 Device: {config.DEVICE}")
print(f"🖼️  Image Size: {config.IMAGE_SIZE}x{config.IMAGE_SIZE}")
print(f"📊 Batch Size: {config.BATCH_SIZE} (effective: {config.BATCH_SIZE * config.ACCUMULATION_STEPS})")
print(f"🎯 Epochs: {config.NUM_EPOCHS}")
print(f"🐶 Dog Breeds: {config.NUM_CLASSES}")
print(f"{'='*70}\n")

print("🎯 TARGET: 90%+ accuracy on Stanford Dogs Dataset")
print("⏱️  Expected training time: ~2 hours on T4 GPU")
