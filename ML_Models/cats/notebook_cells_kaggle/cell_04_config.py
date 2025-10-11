class Config:
    """Advanced training configuration for Kaggle - 90%+ accuracy"""
    
    # Kaggle-specific paths
    DATASET_ROOT = "/kaggle/input/cat-breeds-dataset"
    IMAGES_PATH = "/kaggle/input/cat-breeds-dataset/images"
    OUTPUT_DIR = "/kaggle/working"  # Auto-saved by Kaggle!
    
    # Model Architecture
    MODEL_NAME = 'convnextv2_base.fcmae_ft_in22k_in1k_384'  # 88M params
    IMAGE_SIZE = 384
    NUM_CLASSES = 67
    
    # Training Hyperparameters (optimized for Kaggle GPU)
    BATCH_SIZE = 32  # Kaggle T4 x2 can handle larger batches
    ACCUMULATION_STEPS = 2  # Effective batch = 64
    NUM_EPOCHS = 60
    LEARNING_RATE = 3e-5
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
    MIX_PROB = 0.5
    
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
    USE_WEIGHTED_SAMPLER = True
    USE_CLASS_WEIGHTS = True
    RARE_CLASS_THRESHOLD = 10
    RARE_CLASS_BOOST = 4.0  # 4x for rare classes
    
    # Dataset Size Control (NEW - to reduce computation)
    MAX_SAMPLES_PER_BREED = 500  # Cap per breed to save computation
    MIN_SAMPLES_PER_BREED = 1    # Minimum to keep a breed (keep all breeds)
    USE_SMART_SAMPLING = True    # Use quality-based sampling
    USE_GPU_ANALYSIS = True      # Use GPU for faster image processing
    
    # Mixed Precision Training
    USE_AMP = True
    
    # Learning Rate Scheduler
    SCHEDULER_T0 = 10
    SCHEDULER_TMULT = 2
    ETA_MIN = 1e-7
    WARMUP_EPOCHS = 3
    
    # System (Kaggle optimized)
    DEVICE = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    NUM_WORKERS = 2  # Kaggle works well with 2
    PIN_MEMORY = True
    USE_MULTI_GPU = torch.cuda.device_count() > 1  # T4 x2 support
    
    # ImageNet normalization
    MEAN = [0.485, 0.456, 0.406]
    STD = [0.229, 0.224, 0.225]
    
    # Checkpointing
    EARLY_STOPPING_PATIENCE = 20
    SAVE_BEST_ONLY = True

config = Config()
os.makedirs(config.OUTPUT_DIR, exist_ok=True)

print(f"\n✅ Kaggle Configuration loaded!")
print(f"{'='*70}")
print(f"📦 Model: {config.MODEL_NAME}")
print(f"💾 Device: {config.DEVICE}")
print(f"🖼️  Image Size: {config.IMAGE_SIZE}x{config.IMAGE_SIZE}")
print(f"📊 Batch Size: {config.BATCH_SIZE} (effective: {config.BATCH_SIZE * config.ACCUMULATION_STEPS})")
print(f"🎯 Epochs: {config.NUM_EPOCHS}")
print(f"⚖️  Rare Class Boost: {config.RARE_CLASS_BOOST}x")
print(f"📊 Min Samples/Breed: {config.MIN_SAMPLES_PER_BREED} (keep all breeds)")
print(f"🚀 GPU Analysis: {'✓ Enabled' if config.USE_GPU_ANALYSIS else '✗ CPU only'}")
print(f"💪 Multi-GPU: {'✓ Enabled' if config.USE_MULTI_GPU else '✗ Single GPU'}")
print(f"📂 Dataset: {config.IMAGES_PATH}")
print(f"💾 Output: {config.OUTPUT_DIR} (auto-saved!)")
print(f"{'='*70}\n")

print("🎯 TARGET: 90%+ accuracy with balanced class handling")
print("⏱️  Expected training time: 3-4 hours on T4 x2")
