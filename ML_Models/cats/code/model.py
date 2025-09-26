# Enhanced Model definition with advanced techniques for 90%+ accuracy
import torch
import torch.nn as nn
import torchvision.models as models
import numpy as np
from torch.optim.lr_scheduler import CosineAnnealingWarmRestarts, OneCycleLR
from sklearn.utils.class_weight import compute_class_weight
import timm
import time

from config import *


class ImprovedClassifier(nn.Module):
    """Enhanced classifier head with multiple layers and regularization"""
    def __init__(self, in_features, num_classes, dropout_rate=0.5):
        super(ImprovedClassifier, self).__init__()
        self.classifier = nn.Sequential(
            nn.AdaptiveAvgPool2d(1),  # Global average pooling
            nn.Flatten(start_dim=1),  # Flatten from (N, C, 1, 1) to (N, C)
            nn.Linear(in_features, 1024),
            nn.BatchNorm1d(1024),
            nn.ReLU(inplace=True),
            nn.Dropout(dropout_rate),

            nn.Linear(1024, 512),
            nn.BatchNorm1d(512),
            nn.ReLU(inplace=True),
            nn.Dropout(dropout_rate * 0.8),

            nn.Linear(512, num_classes)
        )

    def forward(self, x):
        # Ensure input is 4D (N, C, H, W)
        if x.dim() == 2:
            # If already flattened, skip pooling and flattening
            x = self.classifier[2:](x)  # Skip AdaptiveAvgPool2d and Flatten
        else:
            # Normal case: apply full classifier
            x = self.classifier(x)
        return x


class MixUpCutMix(nn.Module):
    """MixUp and CutMix data augmentation"""
    def __init__(self, alpha=1.0):
        super().__init__()
        self.alpha = alpha

    def forward(self, x, y):
        if not self.training:
            return x, y

        batch_size = x.size(0)
        lam = np.random.beta(self.alpha, self.alpha)

        # Randomly choose between MixUp and CutMix
        if np.random.rand() > 0.5:  # MixUp
            index = torch.randperm(batch_size).to(x.device)
            mixed_x = lam * x + (1 - lam) * x[index]
            y_a, y_b = y, y[index]
            return mixed_x, y_a, y_b, lam
        else:  # CutMix
            index = torch.randperm(batch_size).to(x.device)
            W, H = x.size(2), x.size(3)
            cut_rat = np.sqrt(1. - lam)
            cut_w = int(W * cut_rat)
            cut_h = int(H * cut_rat)

            cx = np.random.randint(W)
            cy = np.random.randint(H)

            bbx1 = np.clip(cx - cut_w // 2, 0, W)
            bby1 = np.clip(cy - cut_h // 2, 0, H)
            bbx2 = np.clip(cx + cut_w // 2, 0, W)
            bby2 = np.clip(cy + cut_h // 2, 0, H)

            mixed_x = x.clone()
            mixed_x[:, :, bby1:bby2, bbx1:bbx2] = x[index, :, bby1:bby2, bbx1:bbx2]

            # Adjust lambda to match pixel ratio
            lam = 1 - ((bbx2 - bbx1) * (bby2 - bby1) / (W * H))
            y_a, y_b = y, y[index]
            return mixed_x, y_a, y_b, lam


def create_enhanced_model(num_classes=None, model_name='efficientnetv2_s'):
    """Create enhanced model with modern architecture and techniques"""
    if num_classes is None:
        num_classes = NUM_CLASSES

    print(f"Creating {model_name} model with {num_classes} classes...")

    # Use timm for better model access
    if model_name == 'efficientnetv2_s':
        model = timm.create_model('efficientnetv2_rw_s', pretrained=True, num_classes=0)
        in_features = model.num_features
    elif model_name == 'convnext_tiny':
        model = timm.create_model('convnext_tiny', pretrained=True, num_classes=0)
        in_features = model.num_features
    elif model_name == 'resnet50':
        model = models.resnet50(pretrained=True)
        in_features = model.fc.in_features
        model = nn.Sequential(*list(model.children())[:-2])  # Remove avgpool and fc
    else:
        raise ValueError(f"Unsupported model: {model_name}")

    # Enhanced classifier
    classifier = ImprovedClassifier(in_features, num_classes, dropout_rate=0.4)

    # Combine backbone and classifier
    model = nn.Sequential(model, classifier)

    # Move to device
    model = model.to(DEVICE)

    # Count parameters
    total_params = sum(p.numel() for p in model.parameters())
    trainable_params = sum(p.numel() for p in model.parameters() if p.requires_grad)

    print(f"Model: {model_name}")
    print(f"Input features: {in_features}")
    print(f"Total parameters: {total_params:,}")
    print(f"Trainable parameters: {trainable_params:,}")

    return model


def get_class_weights(labels, class_names):
    """Compute class weights for imbalanced dataset"""
    class_weights = compute_class_weight(
        class_weight='balanced',
        classes=np.unique(labels),
        y=labels
    )

    # Convert to tensor
    class_weights = torch.tensor(class_weights, dtype=torch.float).to(DEVICE)

    print("Class weights computed for balanced training:")
    for i, (name, weight) in enumerate(zip(class_names, class_weights)):
        print(".3f")

    return class_weights


def get_enhanced_criterion_optimizer_scheduler(model, labels=None, class_names=None):
    """Get enhanced loss function, optimizer, and scheduler"""

    # Enhanced loss function with label smoothing and class weights
    if labels is not None and class_names is not None:
        class_weights = get_class_weights(labels, class_names)
        criterion = nn.CrossEntropyLoss(weight=class_weights, label_smoothing=0.1)
    else:
        criterion = nn.CrossEntropyLoss(label_smoothing=0.1)

    # Enhanced optimizer with different learning rates for backbone and classifier
    backbone_params = []
    classifier_params = []

    for name, param in model.named_parameters():
        if 'classifier' in name:
            classifier_params.append(param)
        else:
            backbone_params.append(param)

    optimizer = torch.optim.AdamW([
        {'params': backbone_params, 'lr': LEARNING_RATE * 0.1, 'weight_decay': 1e-4},
        {'params': classifier_params, 'lr': LEARNING_RATE, 'weight_decay': 1e-3}
    ], lr=LEARNING_RATE, weight_decay=1e-4)

    # Cosine annealing with warm restarts
    scheduler = CosineAnnealingWarmRestarts(optimizer, T_0=10, T_mult=2, eta_min=1e-6)

    return criterion, optimizer, scheduler


def unfreeze_model_layers(model, stage):
    """Progressive unfreezing of model layers"""
    if stage == 1:
        # Unfreeze classifier only
        for param in model.parameters():
            param.requires_grad = False
        for param in model[-1].parameters():  # classifier
            param.requires_grad = True
        print("Stage 1: Training classifier only")

    elif stage == 2:
        # Unfreeze last few layers of backbone
        for param in model.parameters():
            param.requires_grad = False
        for param in model[-1].parameters():  # classifier
            param.requires_grad = True

        # Unfreeze last 3 blocks for ResNet/EfficientNet
        if hasattr(model[0], 'layer4'):
            for param in model[0].layer4.parameters():
                param.requires_grad = True
        elif hasattr(model[0], 'blocks'):
            # For EfficientNet/ConvNeXt style models
            for i in range(max(0, len(model[0].blocks) - 3), len(model[0].blocks)):
                for param in model[0].blocks[i].parameters():
                    param.requires_grad = True
        print("Stage 2: Training classifier + last backbone layers")

    elif stage == 3:
        # Unfreeze entire model
        for param in model.parameters():
            param.requires_grad = True
        print("Stage 3: Training entire model")

    # Update optimizer for new trainable parameters
    trainable_params = [p for p in model.parameters() if p.requires_grad]
    print(f"Trainable parameters: {sum(p.numel() for p in trainable_params):,}")


def apply_test_time_augmentation(model, image, transforms, num_augmentations=5):
    """Apply test-time augmentation for better predictions"""
    model.eval()
    predictions = []

    with torch.no_grad():
        # Original image
        pred = model(image.unsqueeze(0))
        predictions.append(pred)

        # Augmented versions
        for _ in range(num_augmentations):
            aug_image = transforms(image).unsqueeze(0).to(DEVICE)
            pred = model(aug_image)
            predictions.append(pred)

    # Average predictions
    avg_pred = torch.mean(torch.stack(predictions), dim=0)
    return avg_pred


def create_ensemble_models(num_classes, num_models=3, model_name='efficientnetv2_s'):
    """Create ensemble of models with different initializations"""
    models_list = []
    for i in range(num_models):
        torch.manual_seed(RANDOM_SEED + i)  # Different seed for each model
        model = create_enhanced_model(num_classes, model_name)
        models_list.append(model)
    return models_list


def ensemble_predict(models, image, transforms=None):
    """Make predictions using ensemble of models"""
    predictions = []
    for model in models:
        model.eval()
        with torch.no_grad():
            if transforms:
                pred = apply_test_time_augmentation(model, image, transforms)
            else:
                pred = model(image.unsqueeze(0))
            predictions.append(pred)

    # Average predictions from all models
    ensemble_pred = torch.mean(torch.stack(predictions), dim=0)
    return ensemble_pred


# Legacy function for backward compatibility
def create_model(num_classes=None):
    """Legacy function - use create_enhanced_model instead"""
    return create_enhanced_model(num_classes, model_name='resnet50')


def save_model(model, optimizer, scheduler, class_names, history, save_path):
    """Save model checkpoint with training state"""
    checkpoint = {
        'model_state_dict': model.state_dict(),
        'optimizer_state_dict': optimizer.state_dict(),
        'scheduler_state_dict': scheduler.state_dict() if scheduler else None,
        'class_names': class_names,
        'num_classes': len(class_names),
        'history': history,
        'save_time': time.strftime('%Y-%m-%d %H:%M:%S')
    }

    torch.save(checkpoint, save_path)
    print(f"Model saved to: {save_path}")


def load_model(checkpoint_path, device):
    """Load model checkpoint"""
    if not os.path.exists(checkpoint_path):
        raise FileNotFoundError(f"Checkpoint not found: {checkpoint_path}")

    checkpoint = torch.load(checkpoint_path, map_location=device)

    # Create model
    num_classes = checkpoint['num_classes']
    model = create_enhanced_model(num_classes)
    model.load_state_dict(checkpoint['model_state_dict'])
    model.to(device)
    model.eval()

    class_names = checkpoint['class_names']
    history = checkpoint.get('history', {})

    print(f"Model loaded from {checkpoint_path}")
    print(f"Number of classes: {num_classes}")
    print(f"Training history available: {'Yes' if history else 'No'}")

    return model, class_names, history