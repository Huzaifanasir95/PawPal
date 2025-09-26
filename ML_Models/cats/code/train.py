# Enhanced Training script with advanced techniques for 90%+ accuracy
import torch
import time
from tqdm import tqdm
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.metrics import classification_report, confusion_matrix
import numpy as np

from config import *
from model import (create_enhanced_model, get_enhanced_criterion_optimizer_scheduler,
                   unfreeze_model_layers, MixUpCutMix, save_model)
from data_loader import get_data_loaders, get_class_names, get_labels_for_class_weights

# Set style for plots
plt.style.use('default')
sns.set_palette("husl")


def train_one_epoch_enhanced(model, train_loader, criterion, optimizer, device, mixup_cutmix=None, epoch=0):
    """Enhanced training for one epoch with MixUp/CutMix and gradient clipping"""
    model.train()
    running_loss = 0.0
    correct = 0
    total = 0

    pbar = tqdm(train_loader, desc='Training', leave=False)

    for inputs, labels in pbar:
        inputs, labels = inputs.to(device), labels.to(device)
        batch_size = inputs.size(0)

        # Apply MixUp/CutMix if provided
        if mixup_cutmix and epoch >= 5:  # Start mixup after initial training
            inputs, targets_a, targets_b, lam = mixup_cutmix(inputs, labels)

            # Forward pass
            optimizer.zero_grad()
            outputs = model(inputs)

            # MixUp/CutMix loss
            loss = lam * criterion(outputs, targets_a) + (1 - lam) * criterion(outputs, targets_b)

            # Backward pass
            loss.backward()
            torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
            optimizer.step()

            # Statistics (approximate for mixup)
            running_loss += loss.item() * batch_size
            _, predicted = torch.max(outputs.data, 1)
            # For mixup, we use the dominant label for accuracy calculation
            dominant_labels = torch.where(lam > 0.5, targets_a, targets_b)
            total += batch_size
            correct += (predicted == dominant_labels).sum().item()
        else:
            # Standard training
            optimizer.zero_grad()
            outputs = model(inputs)
            loss = criterion(outputs, labels)

            loss.backward()
            torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
            optimizer.step()

            # Statistics
            running_loss += loss.item() * batch_size
            _, predicted = torch.max(outputs.data, 1)
            total += batch_size
            correct += (predicted == labels).sum().item()

        # Update progress bar
        current_acc = 100 * correct / total if total > 0 else 0
        pbar.set_postfix({
            'loss': f'{loss.item():.4f}',
            'acc': f'{current_acc:.2f}%'
        })

    epoch_loss = running_loss / len(train_loader.dataset)
    epoch_acc = 100 * correct / total

    return epoch_loss, epoch_acc


def validate_one_epoch(model, val_loader, criterion, device):
    """Validate for one epoch"""
    model.eval()
    running_loss = 0.0
    correct = 0
    total = 0

    with torch.no_grad():
        pbar = tqdm(val_loader, desc='Validating', leave=False)
        for inputs, labels in pbar:
            inputs, labels = inputs.to(device), labels.to(device)

            # Forward pass
            outputs = model(inputs)
            loss = criterion(outputs, labels)

            # Statistics
            running_loss += loss.item() * inputs.size(0)
            _, predicted = torch.max(outputs.data, 1)
            total += labels.size(0)
            correct += (predicted == labels).sum().item()

            # Update progress bar
            pbar.set_postfix({
                'loss': f'{loss.item():.4f}',
                'acc': f'{100 * correct / total:.2f}%'
            })

    epoch_loss = running_loss / len(val_loader.dataset)
    epoch_acc = 100 * correct / total

    return epoch_loss, epoch_acc


def progressive_training(model, train_loader, val_loader, criterion, optimizer, scheduler,
                        num_epochs, save_path, class_names, labels):
    """Progressive training with staged unfreezing"""
    print("=" * 60)
    print("STARTING PROGRESSIVE TRAINING FOR 90%+ ACCURACY")
    print("=" * 60)
    print(f"Total epochs: {num_epochs}")
    print(f"Training device: {DEVICE}")
    print(f"Model save path: {save_path}")
    print()

    # Initialize MixUp/CutMix
    mixup_cutmix = MixUpCutMix(alpha=1.0)

    # Training stages
    stages = [
        (5, 1, "Stage 1: Training classifier only"),
        (10, 2, "Stage 2: Training classifier + last backbone layers"),
        (num_epochs, 3, "Stage 3: Training entire model")
    ]

    history = {
        'train_loss': [], 'train_acc': [], 'val_loss': [], 'val_acc': [],
        'learning_rates': [], 'stage': []
    }

    best_val_acc = 0.0
    patience = 15  # Early stopping patience
    patience_counter = 0
    current_stage = 0

    start_time = time.time()

    for epoch in range(num_epochs):
        # Check if we need to move to next stage
        if current_stage < len(stages) - 1 and epoch >= stages[current_stage][0]:
            current_stage += 1
            stage_epochs, stage_level, stage_desc = stages[current_stage]
            print(f"\n{stage_desc}")
            unfreeze_model_layers(model, stage_level)

            # Update optimizer for new trainable parameters
            optimizer = torch.optim.AdamW([
                {'params': [p for n, p in model.named_parameters() if 'classifier' not in n and p.requires_grad],
                 'lr': LEARNING_RATE * 0.1, 'weight_decay': 1e-4},
                {'params': [p for n, p in model.named_parameters() if 'classifier' in n and p.requires_grad],
                 'lr': LEARNING_RATE, 'weight_decay': 1e-3}
            ])

        print(f"\nEpoch {epoch+1}/{num_epochs} (Stage {current_stage + 1})")

        # Train one epoch
        train_loss, train_acc = train_one_epoch_enhanced(
            model, train_loader, criterion, optimizer, DEVICE, mixup_cutmix, epoch
        )

        # Validate one epoch
        val_loss, val_acc = validate_one_epoch(model, val_loader, criterion, DEVICE)

        # Update learning rate
        scheduler.step()
        current_lr = optimizer.param_groups[0]['lr']

        # Store history
        history['train_loss'].append(train_loss)
        history['train_acc'].append(train_acc)
        history['val_loss'].append(val_loss)
        history['val_acc'].append(val_acc)
        history['learning_rates'].append(current_lr)
        history['stage'].append(current_stage + 1)

        # Print epoch results
        print(f"Train Loss: {train_loss:.4f}, Train Acc: {train_acc:.2f}%")
        print(f"Val Loss: {val_loss:.4f}, Val Acc: {val_acc:.2f}%")
        print(f"Learning Rate: {current_lr:.6f}")

        # Early stopping check
        if val_acc > best_val_acc:
            best_val_acc = val_acc
            patience_counter = 0
            # Save best model
            torch.save({
                'model_state_dict': model.state_dict(),
                'optimizer_state_dict': optimizer.state_dict(),
                'scheduler_state_dict': scheduler.state_dict(),
                'class_names': class_names,
                'num_classes': len(class_names),
                'history': history,
                'best_val_acc': best_val_acc,
                'epoch': epoch
            }, save_path)
            print(f"✅ New best model saved! (Val Acc: {val_acc:.2f}%)")
        else:
            patience_counter += 1
            if patience_counter >= patience:
                print(f"⏹️  Early stopping triggered after {epoch+1} epochs")
                break

        # Check if we've reached target accuracy
        if val_acc >= 90.0:
            print(f"🎉 Target accuracy reached: {val_acc:.2f}%!")
            break

    total_time = time.time() - start_time
    print(".2f")
    print(".2f")

    return history


def train_ensemble_models(num_models=3, model_name='efficientnetv2_s'):
    """Train ensemble of models for better accuracy"""
    print(f"Training ensemble of {num_models} {model_name} models...")

    ensemble_models = []
    ensemble_histories = []

    # Get data and class information
    train_loader, val_loader, _ = get_data_loaders()
    class_names = get_class_names()
    labels = get_labels_for_class_weights()

    for i in range(num_models):
        print(f"\n{'='*50}")
        print(f"TRAINING MODEL {i+1}/{num_models}")
        print(f"{'='*50}")

        # Different random seed for each model
        torch.manual_seed(RANDOM_SEED + i)
        if torch.cuda.is_available():
            torch.cuda.manual_seed(RANDOM_SEED + i)

        # Create model
        model = create_enhanced_model(len(class_names), model_name)

        # Get training components with class weights
        criterion, optimizer, scheduler = get_enhanced_criterion_optimizer_scheduler(
            model, labels, class_names
        )

        # Train model
        save_path = f"cat_breed_classifier_ensemble_{i+1}.pth"
        history = progressive_training(
            model, train_loader, val_loader, criterion, optimizer, scheduler,
            NUM_EPOCHS, save_path, class_names, labels
        )

        ensemble_models.append(model)
        ensemble_histories.append(history)

        # Clear cache
        if torch.cuda.is_available():
            torch.cuda.empty_cache()

    return ensemble_models, ensemble_histories


def plot_enhanced_training_history(history):
    """Plot enhanced training history with stages"""
    fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=(16, 12))

    epochs = range(1, len(history['train_loss']) + 1)
    stages = history.get('stage', [1] * len(epochs))

    # Color by stage
    colors = ['blue', 'orange', 'red']
    stage_colors = [colors[s-1] for s in stages]

    # Loss plot
    for i in range(len(epochs)):
        ax1.plot(epochs[i:i+2], history['train_loss'][i:i+2], color=stage_colors[i], alpha=0.7)
        ax1.plot(epochs[i:i+2], history['val_loss'][i:i+2], color=stage_colors[i], linestyle='--', alpha=0.7)

    ax1.set_title('Training and Validation Loss (by Stage)')
    ax1.set_xlabel('Epochs')
    ax1.set_ylabel('Loss')
    ax1.legend(['Train', 'Validation'])
    ax1.grid(True, alpha=0.3)

    # Accuracy plot
    for i in range(len(epochs)):
        ax2.plot(epochs[i:i+2], history['train_acc'][i:i+2], color=stage_colors[i], alpha=0.7)
        ax2.plot(epochs[i:i+2], history['val_acc'][i:i+2], color=stage_colors[i], linestyle='--', alpha=0.7)

    ax2.set_title('Training and Validation Accuracy (by Stage)')
    ax2.set_xlabel('Epochs')
    ax2.set_ylabel('Accuracy (%)')
    ax2.legend(['Train', 'Validation'])
    ax2.grid(True, alpha=0.3)

    # Learning rate plot
    ax3.plot(epochs, history['learning_rates'], 'g-', linewidth=2)
    ax3.set_title('Learning Rate Schedule')
    ax3.set_xlabel('Epochs')
    ax3.set_ylabel('Learning Rate')
    ax3.set_yscale('log')
    ax3.grid(True, alpha=0.3)

    # Stage information
    ax4.axis('off')
    final_train_loss = history['train_loss'][-1]
    final_train_acc = history['train_acc'][-1]
    final_val_loss = history['val_loss'][-1]
    final_val_acc = history['val_acc'][-1]
    max_val_acc = max(history['val_acc'])

    ax4.text(0.05, 0.95, f'Final Training Loss: {final_train_loss:.4f}', fontsize=11)
    ax4.text(0.05, 0.85, f'Final Training Acc: {final_train_acc:.2f}%', fontsize=11)
    ax4.text(0.05, 0.75, f'Final Validation Loss: {final_val_loss:.4f}', fontsize=11)
    ax4.text(0.05, 0.65, f'Final Validation Acc: {final_val_acc:.2f}%', fontsize=11)
    ax4.text(0.05, 0.55, f'Best Validation Acc: {max_val_acc:.2f}%', fontsize=11, fontweight='bold')

    # Stage legend
    ax4.text(0.05, 0.35, 'Training Stages:', fontsize=12, fontweight='bold')
    ax4.text(0.05, 0.25, '🔵 Stage 1: Classifier only', fontsize=10)
    ax4.text(0.05, 0.15, '🟠 Stage 2: Classifier + backbone', fontsize=10)
    ax4.text(0.05, 0.05, '🔴 Stage 3: Full model', fontsize=10)

    plt.tight_layout()
    plt.savefig('enhanced_training_history.png', dpi=300, bbox_inches='tight', facecolor='white')
    plt.show()


# Legacy functions for backward compatibility
def train_one_epoch(model, train_loader, criterion, optimizer, device):
    return train_one_epoch_enhanced(model, train_loader, criterion, optimizer, device)


def train_model(model, train_loader, val_loader, criterion, optimizer, scheduler, num_epochs, save_path):
    """Legacy training function"""
    class_names = get_class_names()
    labels = get_labels_for_class_weights()
    return progressive_training(model, train_loader, val_loader, criterion, optimizer, scheduler,
                              num_epochs, save_path, class_names, labels)


def plot_training_history(history):
    """Legacy plotting function"""
    plot_enhanced_training_history(history)


if __name__ == "__main__":
    # Set random seeds for reproducibility
    torch.manual_seed(RANDOM_SEED)
    if torch.cuda.is_available():
        torch.cuda.manual_seed(RANDOM_SEED)
        torch.backends.cudnn.benchmark = True

    print("🚀 Starting Enhanced Cat Breed Classification Training")
    print("=" * 60)

    # Choose training mode
    TRAIN_ENSEMBLE = False  # Set to True for ensemble training

    if TRAIN_ENSEMBLE:
        # Train ensemble of models
        ensemble_models, ensemble_histories = train_ensemble_models(
            num_models=3, model_name='efficientnetv2_s'
        )

        # Plot ensemble results
        for i, history in enumerate(ensemble_histories):
            print(f"\nModel {i+1} Final Validation Accuracy: {max(history['val_acc']):.2f}%")

    else:
        # Train single enhanced model
        train_loader, val_loader, _ = get_data_loaders()
        class_names = get_class_names()
        labels = get_labels_for_class_weights()

        # Create enhanced model
        model = create_enhanced_model(len(class_names), model_name='efficientnetv2_s')

        # Get enhanced training components
        criterion, optimizer, scheduler = get_enhanced_criterion_optimizer_scheduler(
            model, labels, class_names
        )

        # Train with progressive learning
        history = progressive_training(
            model, train_loader, val_loader, criterion, optimizer, scheduler,
            NUM_EPOCHS, MODEL_SAVE_PATH, class_names, labels
        )

        # Plot training history
        plot_enhanced_training_history(history)

    print("\n🎉 Enhanced training completed!")
    print(f"Model(s) saved with advanced techniques for 90%+ accuracy")
    print("Training history plot saved as: enhanced_training_history.png")


def train_one_epoch(model, train_loader, criterion, optimizer, device):
    """Train for one epoch"""
    model.train()
    running_loss = 0.0
    correct = 0
    total = 0

    pbar = tqdm(train_loader, desc='Training', leave=False)
    for inputs, labels in pbar:
        inputs, labels = inputs.to(device), labels.to(device)

        # Zero gradients
        optimizer.zero_grad()

        # Forward pass
        outputs = model(inputs)
        loss = criterion(outputs, labels)

        # Backward pass and optimize
        loss.backward()
        optimizer.step()

        # Statistics
        running_loss += loss.item() * inputs.size(0)
        _, predicted = torch.max(outputs.data, 1)
        total += labels.size(0)
        correct += (predicted == labels).sum().item()

        # Update progress bar
        pbar.set_postfix({
            'loss': f'{loss.item():.4f}',
            'acc': f'{100 * correct / total:.2f}%'
        })

    epoch_loss = running_loss / len(train_loader.dataset)
    epoch_acc = 100 * correct / total

    return epoch_loss, epoch_acc


def validate_one_epoch(model, val_loader, criterion, device):
    """Validate for one epoch"""
    model.eval()
    running_loss = 0.0
    correct = 0
    total = 0

    with torch.no_grad():
        pbar = tqdm(val_loader, desc='Validating', leave=False)
        for inputs, labels in pbar:
            inputs, labels = inputs.to(device), labels.to(device)

            # Forward pass
            outputs = model(inputs)
            loss = criterion(outputs, labels)

            # Statistics
            running_loss += loss.item() * inputs.size(0)
            _, predicted = torch.max(outputs.data, 1)
            total += labels.size(0)
            correct += (predicted == labels).sum().item()

            # Update progress bar
            pbar.set_postfix({
                'loss': f'{loss.item():.4f}',
                'acc': f'{100 * correct / total:.2f}%'
            })

    epoch_loss = running_loss / len(val_loader.dataset)
    epoch_acc = 100 * correct / total

    return epoch_loss, epoch_acc


def train_model(model, train_loader, val_loader, criterion, optimizer, scheduler, num_epochs, save_path):
    """Main training function"""
    print(f"Starting training for {num_epochs} epochs...")
    print(f"Training on device: {DEVICE}")
    print(f"Save path: {save_path}")
    print("-" * 50)

    # Initialize history
    history = {
        'train_loss': [],
        'train_acc': [],
        'val_loss': [],
        'val_acc': [],
        'learning_rates': []
    }

    best_val_acc = 0.0
    start_time = time.time()

    for epoch in range(num_epochs):
        print(f"\nEpoch {epoch+1}/{num_epochs}")

        # Train one epoch
        train_loss, train_acc = train_one_epoch(model, train_loader, criterion, optimizer, DEVICE)

        # Validate one epoch
        val_loss, val_acc = validate_one_epoch(model, val_loader, criterion, DEVICE)

        # Update learning rate
        scheduler.step()
        current_lr = optimizer.param_groups[0]['lr']

        # Store history
        history['train_loss'].append(train_loss)
        history['train_acc'].append(train_acc)
        history['val_loss'].append(val_loss)
        history['val_acc'].append(val_acc)
        history['learning_rates'].append(current_lr)

        # Print epoch results
        print(f"Train Loss: {train_loss:.4f}, Train Acc: {train_acc:.2f}%")
        print(f"Val Loss: {val_loss:.4f}, Val Acc: {val_acc:.2f}%")
        print(f"Learning Rate: {current_lr:.6f}")

        # Save best model
        if val_acc > best_val_acc:
            best_val_acc = val_acc
            save_model(model, optimizer, scheduler, get_class_names(), history, save_path)
            print(f"New best model saved! (Val Acc: {val_acc:.2f}%)")

    total_time = time.time() - start_time
    print(".2f")
    print(".2f")

    return history


def plot_training_history(history):
    """Plot training history"""
    fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=(15, 10))

    epochs = range(1, len(history['train_loss']) + 1)

    # Loss plot
    ax1.plot(epochs, history['train_loss'], 'b-', label='Training Loss')
    ax1.plot(epochs, history['val_loss'], 'r-', label='Validation Loss')
    ax1.set_title('Training and Validation Loss')
    ax1.set_xlabel('Epochs')
    ax1.set_ylabel('Loss')
    ax1.legend()
    ax1.grid(True)

    # Accuracy plot
    ax2.plot(epochs, history['train_acc'], 'b-', label='Training Accuracy')
    ax2.plot(epochs, history['val_acc'], 'r-', label='Validation Accuracy')
    ax2.set_title('Training and Validation Accuracy')
    ax2.set_xlabel('Epochs')
    ax2.set_ylabel('Accuracy (%)')
    ax2.legend()
    ax2.grid(True)

    # Learning rate plot
    ax3.plot(epochs, history['learning_rates'], 'g-', label='Learning Rate')
    ax3.set_title('Learning Rate Schedule')
    ax3.set_xlabel('Epochs')
    ax3.set_ylabel('Learning Rate')
    ax3.set_yscale('log')
    ax3.legend()
    ax3.grid(True)

    # Final metrics
    ax4.axis('off')
    final_train_loss = history['train_loss'][-1]
    final_train_acc = history['train_acc'][-1]
    final_val_loss = history['val_loss'][-1]
    final_val_acc = history['val_acc'][-1]

    ax4.text(0.1, 0.8, f'Final Training Loss: {final_train_loss:.4f}', fontsize=12)
    ax4.text(0.1, 0.6, f'Final Training Acc: {final_train_acc:.2f}%', fontsize=12)
    ax4.text(0.1, 0.4, f'Final Validation Loss: {final_val_loss:.4f}', fontsize=12)
    ax4.text(0.1, 0.2, f'Final Validation Acc: {final_val_acc:.2f}%', fontsize=12)

    plt.tight_layout()
    plt.savefig('training_history.png', dpi=300, bbox_inches='tight')
    plt.show()


if __name__ == "__main__":
    # Set random seeds for reproducibility
    torch.manual_seed(42)
    if torch.cuda.is_available():
        torch.cuda.manual_seed(42)

    # Get data loaders
    train_loader, val_loader, test_loader = get_data_loaders()

    # Create model
    model = create_model()

    # Get training components
    criterion, optimizer, scheduler = get_criterion_optimizer_scheduler(model)

    # Train the model
    history = train_model(
        model=model,
        train_loader=train_loader,
        val_loader=val_loader,
        criterion=criterion,
        optimizer=optimizer,
        scheduler=scheduler,
        num_epochs=NUM_EPOCHS,
        save_path=MODEL_SAVE_PATH
    )

    # Plot training history
    plot_training_history(history)

    print("\nTraining completed!")
    print(f"Model saved to: {MODEL_SAVE_PATH}")
    print("Training history plot saved as: training_history.png")