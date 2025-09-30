def get_train_transforms():
    """Advanced training augmentations with Albumentations"""
    return A.Compose([
        # Resize and crop
        A.RandomResizedCrop(config.IMAGE_SIZE, config.IMAGE_SIZE, 
                           scale=(0.75, 1.0), ratio=(0.9, 1.1), p=1.0),
        
        # Geometric transforms
        A.HorizontalFlip(p=0.5),
        A.Rotate(limit=25, p=0.5),
        A.ShiftScaleRotate(shift_limit=0.1, scale_limit=0.15, 
                          rotate_limit=25, p=0.5),
        A.Perspective(scale=(0.05, 0.1), p=0.3),
        
        # Color augmentations
        A.OneOf([
            A.ColorJitter(brightness=0.3, contrast=0.3, saturation=0.3, hue=0.2, p=1.0),
            A.HueSaturationValue(hue_shift_limit=20, sat_shift_limit=30, 
                                val_shift_limit=20, p=1.0),
            A.RGBShift(r_shift_limit=25, g_shift_limit=25, b_shift_limit=25, p=1.0),
        ], p=0.7),
        
        # Quality/Noise augmentations
        A.OneOf([
            A.GaussNoise(var_limit=(10.0, 50.0), p=1.0),
            A.GaussianBlur(blur_limit=(3, 7), p=1.0),
            A.MotionBlur(blur_limit=7, p=1.0),
        ], p=0.3),
        
        # Advanced augmentations
        A.CoarseDropout(max_holes=8, max_height=32, max_width=32,
                       min_holes=1, fill_value=0, p=0.3),
        A.GridDistortion(num_steps=5, distort_limit=0.3, p=0.3),
        A.OpticalDistortion(distort_limit=0.3, shift_limit=0.3, p=0.3),
        
        # Lighting
        A.RandomBrightnessContrast(brightness_limit=0.2, contrast_limit=0.2, p=0.5),
        A.RandomGamma(gamma_limit=(80, 120), p=0.3),
        
        # Normalize and convert to tensor
        A.Normalize(mean=config.MEAN, std=config.STD, p=1.0),
        ToTensorV2()
    ])

def get_val_transforms():
    """Validation/Test transforms (no augmentation)"""
    return A.Compose([
        A.Resize(config.IMAGE_SIZE, config.IMAGE_SIZE),
        A.Normalize(mean=config.MEAN, std=config.STD),
        ToTensorV2()
    ])

def get_tta_transforms():
    """Test-Time Augmentation transforms"""
    return [
        # Original
        A.Compose([
            A.Resize(config.IMAGE_SIZE, config.IMAGE_SIZE),
            A.Normalize(mean=config.MEAN, std=config.STD),
            ToTensorV2()
        ]),
        # Horizontal flip
        A.Compose([
            A.Resize(config.IMAGE_SIZE, config.IMAGE_SIZE),
            A.HorizontalFlip(p=1.0),
            A.Normalize(mean=config.MEAN, std=config.STD),
            ToTensorV2()
        ]),
        # Crop 1
        A.Compose([
            A.Resize(int(config.IMAGE_SIZE * 1.1), int(config.IMAGE_SIZE * 1.1)),
            A.CenterCrop(config.IMAGE_SIZE, config.IMAGE_SIZE),
            A.Normalize(mean=config.MEAN, std=config.STD),
            ToTensorV2()
        ]),
        # Crop 2
        A.Compose([
            A.Resize(int(config.IMAGE_SIZE * 1.15), int(config.IMAGE_SIZE * 1.15)),
            A.RandomCrop(config.IMAGE_SIZE, config.IMAGE_SIZE),
            A.Normalize(mean=config.MEAN, std=config.STD),
            ToTensorV2()
        ]),
        # Color jitter
        A.Compose([
            A.Resize(config.IMAGE_SIZE, config.IMAGE_SIZE),
            A.ColorJitter(brightness=0.1, contrast=0.1, saturation=0.1, hue=0.05, p=1.0),
            A.Normalize(mean=config.MEAN, std=config.STD),
            ToTensorV2()
        ]),
    ]

print("✅ Advanced augmentation pipeline created!")
print(f"   • Training: Heavy augmentation with Albumentations")
print(f"   • Validation: Center crop only")
print(f"   • TTA: {config.TTA_TRANSFORMS} different transforms")
