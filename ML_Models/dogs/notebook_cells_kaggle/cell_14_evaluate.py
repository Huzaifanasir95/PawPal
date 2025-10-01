# Load best model
print("📥 Loading best model...")
model.load_state_dict(torch.load(os.path.join(config.OUTPUT_DIR, 'best_model_final.pth')))
model.eval()

# Standard validation
print("\n🔍 Running standard validation...")
val_loss, val_acc, all_preds, all_labels = validate(model, val_loader, criterion)

print(f"\n📊 Standard Validation Results:")
print(f"   Accuracy: {val_acc:.2f}%")
print(f"   Loss: {val_loss:.4f}")

# Test-Time Augmentation
if config.USE_TTA:
    tta_transforms = get_tta_transforms()
    tta_acc, tta_preds, tta_labels = validate_with_tta(model, val_loader, tta_transforms)
    
    print(f"\n🔮 TTA Validation Results:")
    print(f"   Accuracy: {tta_acc:.2f}%")
    print(f"   Improvement: +{tta_acc - val_acc:.2f}%")
    
    # Use TTA results for final evaluation
    final_preds = tta_preds
    final_acc = tta_acc
else:
    final_preds = all_preds
    final_acc = val_acc

# Calculate per-class metrics
print(f"\n📋 Calculating per-class metrics...")
f1 = f1_score(all_labels, all_preds, average='weighted')
print(f"   Weighted F1-Score: {f1:.4f}")

# Visualize training history
fig, axes = plt.subplots(2, 2, figsize=(16, 12))

# Loss curves
ax = axes[0, 0]
ax.plot(history['train_loss'], label='Train Loss', linewidth=2)
ax.plot(history['val_loss'], label='Val Loss', linewidth=2)
ax.axvline(config.STAGE_1_EPOCHS, color='red', linestyle='--', alpha=0.5, label='Stage 1→2')
ax.axvline(config.STAGE_2_EPOCHS, color='orange', linestyle='--', alpha=0.5, label='Stage 2→3')
ax.axvline(config.STAGE_3_EPOCHS, color='green', linestyle='--', alpha=0.5, label='Stage 3→4')
ax.set_xlabel('Epoch', fontsize=12)
ax.set_ylabel('Loss', fontsize=12)
ax.set_title('Training & Validation Loss', fontsize=14, fontweight='bold')
ax.legend()
ax.grid(True, alpha=0.3)

# Accuracy curve
ax = axes[0, 1]
ax.plot(history['val_accuracy'], label='Val Accuracy', color='green', linewidth=2)
ax.axhline(90, color='red', linestyle='--', linewidth=2, label='90% Target')
ax.axvline(config.STAGE_1_EPOCHS, color='red', linestyle='--', alpha=0.5)
ax.axvline(config.STAGE_2_EPOCHS, color='orange', linestyle='--', alpha=0.5)
ax.axvline(config.STAGE_3_EPOCHS, color='green', linestyle='--', alpha=0.5)
ax.set_xlabel('Epoch', fontsize=12)
ax.set_ylabel('Accuracy (%)', fontsize=12)
ax.set_title('Validation Accuracy', fontsize=14, fontweight='bold')
ax.legend()
ax.grid(True, alpha=0.3)

# Learning rate schedule
ax = axes[1, 0]
ax.plot(history['learning_rate'], color='purple', linewidth=2)
ax.set_xlabel('Epoch', fontsize=12)
ax.set_ylabel('Learning Rate', fontsize=12)
ax.set_title('Learning Rate Schedule', fontsize=14, fontweight='bold')
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

# Summary text
ax = axes[1, 1]
ax.axis('off')
summary_text = f"""
KAGGLE TRAINING SUMMARY
{'='*45}

Final Results:
  • Best Val Accuracy: {best_accuracy:.2f}%
  • TTA Accuracy: {final_acc:.2f}%
  • Weighted F1-Score: {f1:.4f}
  • Total Epochs: {len(history['train_loss'])}

Model Configuration:
  • Architecture: ConvNeXt V2 Base
  • Parameters: {total_params:,}
  • Input Size: {config.IMAGE_SIZE}x{config.IMAGE_SIZE}
  • Classes: {config.NUM_CLASSES}
  • Multi-GPU: {'Yes' if config.USE_MULTI_GPU else 'No'}

Training Techniques:
  ✓ 4-Stage Progressive Training
  ✓ Focal Loss (γ={config.FOCAL_GAMMA})
  ✓ Weighted Sampling ({config.RARE_CLASS_BOOST}x)
  ✓ MixUp & CutMix
  ✓ Advanced Augmentation
  ✓ Mixed Precision (AMP)
  ✓ Test-Time Augmentation

Class Imbalance:
  • Rare classes: {len([c for c in class_counts.values() if c < config.RARE_CLASS_THRESHOLD])}
  • Imbalance ratio: {max(class_counts.values())/max(min(class_counts.values()), 1):.1f}:1

Status: {'✅ TARGET ACHIEVED!' if final_acc >= 90 else '⚠️ Continue training needed'}
Saved: /kaggle/working/ (20 days)
"""

ax.text(0.05, 0.95, summary_text, transform=ax.transAxes,
       fontsize=9, verticalalignment='top',
       fontfamily='monospace',
       bbox=dict(boxstyle='round', facecolor='lightgreen' if final_acc >= 90 else 'lightyellow', alpha=0.8))

plt.tight_layout()
plt.savefig(os.path.join(config.OUTPUT_DIR, 'training_results.png'), dpi=150, bbox_inches='tight')
plt.show()

print(f"\n📊 Visualization saved to /kaggle/working/training_results.png")

# Confusion matrix for top classes
print("\n📈 Generating confusion matrix...")
cm = confusion_matrix(all_labels, all_preds)

# Plot confusion matrix for top 20 classes
top_20_classes = np.argsort(np.bincount(all_labels))[-20:]
cm_top20 = cm[top_20_classes][:, top_20_classes]
class_names_top20 = [class_names[i] for i in top_20_classes]

plt.figure(figsize=(14, 12))
sns.heatmap(cm_top20, annot=False, fmt='d', cmap='Blues', 
            xticklabels=class_names_top20, yticklabels=class_names_top20)
plt.title(f'Confusion Matrix (Top 20 Classes)', fontsize=14, fontweight='bold')
plt.ylabel('True Label')
plt.xlabel('Predicted Label')
plt.xticks(rotation=45, ha='right')
plt.yticks(rotation=0)
plt.tight_layout()
plt.savefig(os.path.join(config.OUTPUT_DIR, 'confusion_matrix_top20.png'), dpi=150, bbox_inches='tight')
plt.show()

print(f"✅ Confusion matrix saved!")

# Print classification report for rare classes
rare_class_indices = [idx for idx, cls in enumerate(class_names) if class_counts[cls] < config.RARE_CLASS_THRESHOLD]
if rare_class_indices:
    rare_mask = np.isin(all_labels, rare_class_indices)
    if rare_mask.sum() > 0:
        rare_acc = 100 * np.sum(np.array(all_preds)[rare_mask] == np.array(all_labels)[rare_mask]) / rare_mask.sum()
        print(f"\n⚠️  Performance on Rare Classes:")
        print(f"   Accuracy: {rare_acc:.2f}%")
        print(f"   Classes: {len(rare_class_indices)}")

print(f"\n{'='*70}")
print(f"🎉 EVALUATION COMPLETE ON KAGGLE!")
print(f"{'='*70}")
print(f"✅ Final TTA Accuracy: {final_acc:.2f}%")
if final_acc >= 90:
    print(f"🏆 TARGET ACHIEVED! Model reached 90%+ accuracy!")
else:
    print(f"📈 Current: {final_acc:.2f}% | Target: 90.00%")
    print(f"   Consider: More epochs or larger batch size")
print(f"{'='*70}")
print(f"💾 All outputs saved to /kaggle/working/ (auto-saved for 20 days!)")
print(f"{'='*70}\n")
