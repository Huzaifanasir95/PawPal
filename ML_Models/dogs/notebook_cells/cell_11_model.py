print(f"📦 Creating model: {config.MODEL_NAME}")
print(f"   This may take 1-2 minutes to download pre-trained weights...\n")

# Create model
model = timm.create_model(
    config.MODEL_NAME,
    pretrained=True,
    num_classes=config.NUM_CLASSES,
    drop_rate=config.DROPOUT,
    drop_path_rate=0.2  # Stochastic depth for regularization
)

model = model.to(config.DEVICE)

# Count parameters
total_params = sum(p.numel() for p in model.parameters())
trainable_params = sum(p.numel() for p in model.parameters() if p.requires_grad)

print(f"\n✅ Model created successfully!")
print(f"{'='*70}")
print(f"Architecture: {config.MODEL_NAME}")
print(f"Input size: {config.IMAGE_SIZE}x{config.IMAGE_SIZE}")
print(f"Number of classes: {config.NUM_CLASSES}")
print(f"Total parameters: {total_params:,}")
print(f"Trainable parameters: {trainable_params:,}")
print(f"Model size: ~{total_params * 4 / 1024**2:.1f} MB (FP32)")
print(f"{'='*70}\n")

# Helper function to freeze/unfreeze layers
def set_parameter_requires_grad(model, requires_grad, layer_names=None):
    """Freeze or unfreeze specific layers"""
    if layer_names is None:
        # Freeze/unfreeze all
        for param in model.parameters():
            param.requires_grad = requires_grad
    else:
        # Freeze/unfreeze specific layers
        for name, param in model.named_parameters():
            if any(layer_name in name for layer_name in layer_names):
                param.requires_grad = requires_grad

def get_trainable_params(model):
    """Count trainable parameters"""
    return sum(p.numel() for p in model.parameters() if p.requires_grad)

print("✅ Model ready for progressive training!")
