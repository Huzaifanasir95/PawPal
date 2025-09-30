class Config:
    """Advanced training configuration for 90%+ accuracy"""
    
    # Paths (will be updated after dataset download)
    DATASET_ROOT = "/content/cat_breeds_dataset"
    IMAGES_PATH = None
    OUTPUT_DIR = "/content/outputs"
    
    # Model Architecture
    MODEL_NAME = 'convnextv2_base.fcmae_ft_in22k_in1k_384'  # 88M params
    IMAGE_SIZE = 384
    NUM_CLASSES = 67
    
    # Training Hyperparameters
    BATCH_SIZE = 24  # Reduce to 16 if GPU memory < 15GB, increase to 32 if 24GB+
    ACCUMULATION_STEPS = 3  # Effective batch = BATCH_SIZE * ACCUMULATION_STEPS = 72
    NUM_EPOCHS = 60
    LEARNING_RATE = 3e-5  # Lower LR for large pre-trained model
    WEIGHT_DECAY = 0.05
    
    # Progressive Training Stages (4-stage unfreezing)
    STAGE_1_EPOCHS = 10   # Train classification head only
    STAGE_2_EPOCHS = 25   # Unfreeze last 1/4 of backbone
    STAGE_3_EPOCHS = 45   # Unfreeze last 1/2 of backbone
    STAGE_4_EPOCHS = 60   # Full fine-tuning
    
    # Data Split
    TRAIN_RATIO = 0.85
    VAL_RATIO = 0.15
    
    # Data Augmentation
    USE_MIXUP = True
    USE_CUTMIX = True
    MIXUP_ALPHA = 0.4
    CUTMIX_ALPHA = 1.0
    MIX_PROB = 0.5  # 50% chance to apply MixUp or CutMix
    
    # Test-Time Augmentation
    USE_TTA = True
    TTA_TRANSFORMS = 5
    
    # Regularization
    LABEL_SMOOTHING = 0.1
    DROPOUT = 0.3
    GRADIENT_CLIP = 1.0
    
    # Focal Loss Parameters (for hard example mining)
    USE_FOCAL_LOSS = True
    FOCAL_ALPHA = 0.25
    FOCAL_GAMMA = 2.0
    
    # Class Imbalance Handling (CRITICAL FOR SUCCESS!)
    USE_WEIGHTED_SAMPLER = True  # Weighted sampling in DataLoader
    USE_CLASS_WEIGHTS = True     # Class weights in loss function
    RARE_CLASS_THRESHOLD = 10    # Classes with < 10 images are "rare"
    RARE_CLASS_BOOST = 4.0       # 4x sampling probability for rare classes
    
    # Mixed Precision Training (faster with AMP)
    USE_AMP = True
    
    # Learning Rate Scheduler
    SCHEDULER_T0 = 10        # Cosine annealing restart period
    SCHEDULER_TMULT = 2      # Period multiplier
    ETA_MIN = 1e-7           # Minimum learning rate
    WARMUP_EPOCHS = 3        # Linear warmup epochs
    
    # System
    DEVICE = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    NUM_WORKERS = 2  # Colab works best with 2
    PIN_MEMORY = True
    
    # ImageNet normalization (important for pre-trained models!)
    MEAN = [0.485, 0.456, 0.406]
    STD = [0.229, 0.224, 0.225]
    
    # Checkpointing
    EARLY_STOPPING_PATIENCE = 20
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
print(f"⚖️  Rare Class Boost: {config.RARE_CLASS_BOOST}x")
print(f"{'='*70}\n")

print("🎯 TARGET: 90%+ accuracy with balanced class handling")
