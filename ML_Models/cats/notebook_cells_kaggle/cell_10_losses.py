class FocalLoss(nn.Module):
    """Focal Loss for addressing class imbalance and hard examples"""
    
    def __init__(self, alpha=0.25, gamma=2.0, reduction='mean'):
        super().__init__()
        self.alpha = alpha
        self.gamma = gamma
        self.reduction = reduction
    
    def forward(self, inputs, targets):
        ce_loss = F.cross_entropy(inputs, targets, reduction='none')
        pt = torch.exp(-ce_loss)
        focal_loss = self.alpha * (1 - pt) ** self.gamma * ce_loss
        
        if self.reduction == 'mean':
            return focal_loss.mean()
        elif self.reduction == 'sum':
            return focal_loss.sum()
        else:
            return focal_loss

def mixup_data(x, y, alpha=0.4):
    """Apply MixUp augmentation"""
    if alpha > 0:
        lam = np.random.beta(alpha, alpha)
    else:
        lam = 1
    
    batch_size = x.size()[0]
    index = torch.randperm(batch_size).to(x.device)
    
    mixed_x = lam * x + (1 - lam) * x[index, :]
    y_a, y_b = y, y[index]
    return mixed_x, y_a, y_b, lam

def cutmix_data(x, y, alpha=1.0):
    """Apply CutMix augmentation"""
    if alpha > 0:
        lam = np.random.beta(alpha, alpha)
    else:
        lam = 1
    
    batch_size = x.size()[0]
    index = torch.randperm(batch_size).to(x.device)
    
    # Random bounding box
    W, H = x.size(2), x.size(3)
    cut_rat = np.sqrt(1. - lam)
    cut_w = int(W * cut_rat)
    cut_h = int(H * cut_rat)
    
    # Uniform
    cx = np.random.randint(W)
    cy = np.random.randint(H)
    
    bbx1 = np.clip(cx - cut_w // 2, 0, W)
    bby1 = np.clip(cy - cut_h // 2, 0, H)
    bbx2 = np.clip(cx + cut_w // 2, 0, W)
    bby2 = np.clip(cy + cut_h // 2, 0, H)
    
    # Apply CutMix
    mixed_x = x.clone()
    mixed_x[:, :, bbx1:bbx2, bby1:bby2] = x[index, :, bbx1:bbx2, bby1:bby2]
    
    # Adjust lambda based on actual area
    lam = 1 - ((bbx2 - bbx1) * (bby2 - bby1) / (W * H))
    
    y_a, y_b = y, y[index]
    return mixed_x, y_a, y_b, lam

def mixup_criterion(criterion, pred, y_a, y_b, lam):
    """Criterion for MixUp/CutMix"""
    return lam * criterion(pred, y_a) + (1 - lam) * criterion(pred, y_b)

# Calculate class weights for loss function
def get_class_weights(train_loader):
    """Calculate class weights for balanced loss"""
    all_labels = []
    for _, labels in tqdm(train_loader, desc="Calculating class weights"):
        all_labels.extend(labels.tolist())
    
    class_counts = Counter(all_labels)
    total_samples = len(all_labels)
    
    # Inverse frequency weights
    class_weights = torch.zeros(config.NUM_CLASSES)
    for cls, count in class_counts.items():
        class_weights[cls] = total_samples / (config.NUM_CLASSES * count)
    
    # Normalize weights
    class_weights = class_weights / class_weights.sum() * config.NUM_CLASSES
    
    return class_weights.to(config.DEVICE)

# Create loss function
if config.USE_FOCAL_LOSS:
    criterion = FocalLoss(alpha=config.FOCAL_ALPHA, gamma=config.FOCAL_GAMMA)
    print(f"✅ Using Focal Loss (α={config.FOCAL_ALPHA}, γ={config.FOCAL_GAMMA})")
else:
    if config.USE_CLASS_WEIGHTS:
        print("⚖️  Calculating class weights...")
        class_weights = get_class_weights(train_loader)
        criterion = nn.CrossEntropyLoss(weight=class_weights, label_smoothing=config.LABEL_SMOOTHING)
        print(f"✅ Using CrossEntropyLoss with class weights and label smoothing")
    else:
        criterion = nn.CrossEntropyLoss(label_smoothing=config.LABEL_SMOOTHING)
        print(f"✅ Using CrossEntropyLoss with label smoothing")

print(f"\n🔀 Data mixing:")
print(f"   • MixUp: {'✓' if config.USE_MIXUP else '✗'} (α={config.MIXUP_ALPHA})")
print(f"   • CutMix: {'✓' if config.USE_CUTMIX else '✗'} (α={config.CUTMIX_ALPHA})")
print(f"   • Mix probability: {config.MIX_PROB * 100}%")
