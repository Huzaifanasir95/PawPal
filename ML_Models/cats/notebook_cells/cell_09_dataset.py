class BalancedCatDataset(Dataset):
    """Custom dataset with special handling for rare classes"""
    
    def __init__(self, samples, class_to_idx, transform=None, is_training=False):
        self.samples = samples
        self.class_to_idx = class_to_idx
        self.idx_to_class = {v: k for k, v in class_to_idx.items()}
        self.transform = transform
        self.is_training = is_training
        
        # Calculate class frequencies
        self.class_counts = Counter([label for _, label in samples])
        
        # Identify rare classes
        self.rare_classes = set([label for label, count in self.class_counts.items() 
                                 if count < config.RARE_CLASS_THRESHOLD])
        
        if self.rare_classes and is_training:
            print(f"\n   ⚠️  Detected {len(self.rare_classes)} rare classes in this split")
    
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
    """Create stratified train/val split ensuring all classes represented"""
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

def get_weighted_sampler(dataset):
    """Create weighted sampler for balanced training"""
    # Calculate class weights (inverse frequency)
    class_counts = Counter([label for _, label in dataset.samples])
    class_weights = {cls: 1.0 / count for cls, count in class_counts.items()}
    
    # Boost rare classes even more
    for cls in dataset.rare_classes:
        class_weights[cls] *= config.RARE_CLASS_BOOST
    
    # Assign weights to each sample
    sample_weights = [class_weights[label] for _, label in dataset.samples]
    
    # Create sampler
    sampler = WeightedRandomSampler(
        weights=sample_weights,
        num_samples=len(sample_weights),
        replacement=True
    )
    
    return sampler

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

train_dataset = BalancedCatDataset(train_samples, class_to_idx, 
                                   train_transforms, is_training=True)
val_dataset = BalancedCatDataset(val_samples, class_to_idx, 
                                 val_transforms, is_training=False)

# Create weighted sampler for training
if config.USE_WEIGHTED_SAMPLER:
    print("\n⚖️  Creating weighted sampler...")
    train_sampler = get_weighted_sampler(train_dataset)
    shuffle_train = False
    print(f"   • Rare classes get {config.RARE_CLASS_BOOST}x sampling probability")
else:
    train_sampler = None
    shuffle_train = True

# Create dataloaders
train_loader = DataLoader(
    train_dataset, 
    batch_size=config.BATCH_SIZE,
    sampler=train_sampler,
    shuffle=shuffle_train if train_sampler is None else False,
    num_workers=config.NUM_WORKERS,
    pin_memory=config.PIN_MEMORY,
    drop_last=True  # Drop last incomplete batch
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
