class BalancedDogDataset(Dataset):
    """Custom dataset for dog breed classification"""
    
    def __init__(self, samples, class_to_idx, transform=None, is_training=False):
        self.samples = samples
        self.class_to_idx = class_to_idx
        self.idx_to_class = {v: k for k, v in class_to_idx.items()}
        self.transform = transform
        self.is_training = is_training
        
        # Calculate class frequencies
        self.class_counts = Counter([label for _, label in samples])
    
    def __len__(self):
        return len(self.samples)
    
    def __getitem__(self, idx):
        img_path, label = self.samples[idx]
        
        try:
            # Load image with OpenCV (faster than PIL)
            image = cv2.imread(img_path)
            image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
            
            # Apply transforms
            if self.transform:
                augmented = self.transform(image=image)
                image = augmented['image']
            
            return image, label
            
        except Exception as e:
            # Return blank image if loading fails
            print(f"Warning: Error loading {img_path}: {e}")
            blank = np.zeros((config.IMAGE_SIZE, config.IMAGE_SIZE, 3), dtype=np.uint8)
            if self.transform:
                augmented = self.transform(image=blank)
                return augmented['image'], label
            return torch.zeros(3, config.IMAGE_SIZE, config.IMAGE_SIZE), label

def create_stratified_split(samples, class_to_idx, train_ratio=0.85):
    """Create stratified train/val split"""
    # Convert to format needed for sklearn
    labels = [class_to_idx[class_name] for _, class_name in samples]
    
    # Stratified split
    train_samples, val_samples = train_test_split(
        [(path, class_to_idx[cls]) for path, cls in samples],
        test_size=1-train_ratio,
        stratify=labels,
        random_state=42
    )
    
    return train_samples, val_samples

# Create class mapping
class_to_idx = {cls: idx for idx, cls in enumerate(class_names)}
idx_to_class = {idx: cls for cls, idx in class_to_idx.items()}

# Stratified split
print("\n📊 Creating stratified train/val split...")
train_samples, val_samples = create_stratified_split(
    all_samples, class_to_idx, config.TRAIN_RATIO
)

print(f"   • Training samples: {len(train_samples):,}")
print(f"   • Validation samples: {len(val_samples):,}")

# Create datasets
train_transforms = get_train_transforms()
val_transforms = get_val_transforms()

train_dataset = BalancedDogDataset(train_samples, class_to_idx, 
                                   train_transforms, is_training=True)
val_dataset = BalancedDogDataset(val_samples, class_to_idx, 
                                 val_transforms, is_training=False)

# Create dataloaders
train_loader = DataLoader(
    train_dataset, 
    batch_size=config.BATCH_SIZE,
    shuffle=True,
    num_workers=config.NUM_WORKERS,
    pin_memory=config.PIN_MEMORY,
    drop_last=True
)

val_loader = DataLoader(
    val_dataset,
    batch_size=config.BATCH_SIZE,
    shuffle=False,
    num_workers=config.NUM_WORKERS,
    pin_memory=config.PIN_MEMORY
)

print(f"\n✅ Dataloaders created!")
print(f"   • Train batches: {len(train_loader)}")
print(f"   • Val batches: {len(val_loader)}")
print(f"   • Effective batch size: {config.BATCH_SIZE * config.ACCUMULATION_STEPS}")
