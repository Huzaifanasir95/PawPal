# Model definition and utilities
import torch
import torch.nn as nn
import torchvision.models as models

from config import *


def create_model(num_classes=None):
    """Create ResNet-50 model with transfer learning"""
    if num_classes is None:
        num_classes = NUM_CLASSES

    # Load pretrained ResNet-50 model
    model = models.resnet50(pretrained=True)

    # Freeze all layers initially
    for param in model.parameters():
        param.requires_grad = False

    # Get the number of input features for the final fully connected layer
    num_ftrs = model.fc.in_features
    print(f"ResNet-50 fc input features: {num_ftrs}")

    # Replace the final layer for our classification task
    model.fc = nn.Sequential(
        nn.Linear(num_ftrs, 512),
        nn.ReLU(),
        nn.Dropout(0.3),
        nn.Linear(512, num_classes),
        nn.LogSoftmax(dim=1)
    )

    # Move model to device
    model = model.to(DEVICE)

    print(f"Model created with {num_classes} output classes")
    print(f"Total parameters: {sum(p.numel() for p in model.parameters()):,}")
    print(f"Trainable parameters: {sum(p.numel() for p in model.parameters() if p.requires_grad):,}")

    return model


def get_criterion_optimizer_scheduler(model):
    """Get loss function, optimizer, and scheduler"""
    # Loss function
    criterion = nn.NLLLoss()

    # Optimizer (only train the final layers)
    optimizer = torch.optim.Adam(model.fc.parameters(), lr=LEARNING_RATE)

    # Learning rate scheduler
    scheduler = torch.optim.lr_scheduler.StepLR(optimizer, step_size=7, gamma=0.1)

    return criterion, optimizer, scheduler


def save_model(model, optimizer, scheduler, class_names, history, save_path):
    """Save model checkpoint"""
    torch.save({
        'model_state_dict': model.state_dict(),
        'optimizer_state_dict': optimizer.state_dict(),
        'scheduler_state_dict': scheduler.state_dict(),
        'class_names': class_names,
        'num_classes': len(class_names),
        'history': history
    }, save_path)
    print(f"Model saved to: {save_path}")


def load_model(model_path, device=DEVICE):
    """Load model checkpoint"""
    checkpoint = torch.load(model_path, map_location=device)

    # Recreate model
    model = create_model(checkpoint['num_classes'])
    model.load_state_dict(checkpoint['model_state_dict'])

    # Load optimizer and scheduler if needed
    optimizer = torch.optim.Adam(model.fc.parameters(), lr=LEARNING_RATE)
    optimizer.load_state_dict(checkpoint['optimizer_state_dict'])

    scheduler = torch.optim.lr_scheduler.StepLR(optimizer, step_size=7, gamma=0.1)
    scheduler.load_state_dict(checkpoint['scheduler_state_dict'])

    class_names = checkpoint['class_names']
    history = checkpoint.get('history', {})

    print(f"Model loaded from: {model_path}")
    return model, optimizer, scheduler, class_names, history