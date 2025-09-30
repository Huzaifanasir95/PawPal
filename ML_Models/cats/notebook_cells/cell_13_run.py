# Initialize optimizer and scheduler
optimizer = optim.AdamW(
    model.parameters(),
    lr=config.LEARNING_RATE,
    weight_decay=config.WEIGHT_DECAY
)

scheduler = optim.lr_scheduler.CosineAnnealingWarmRestarts(
    optimizer,
    T_0=config.SCHEDULER_T0,
    T_mult=config.SCHEDULER_TMULT,
    eta_min=config.ETA_MIN
)

# Mixed precision scaler
scaler = GradScaler(enabled=config.USE_AMP)

# Training history
history = {
    'train_loss': [],
    'val_loss': [],
    'val_accuracy': [],
    'learning_rate': []
}

best_accuracy = 0.0
patience_counter = 0

print(f"\n{'='*70}")
print(f"🚀 STARTING 4-STAGE PROGRESSIVE TRAINING")
print(f"{'='*70}\n")

# ===========================
# STAGE 1: Train head only
# ===========================
print(f"\n📚 STAGE 1: Training classification head only")
print(f"   Freezing backbone, training head for {config.STAGE_1_EPOCHS} epochs\n")

# Freeze all layers except classifier
for name, param in model.named_parameters():
    if 'head' in name or 'fc' in name or 'classifier' in name:
        param.requires_grad = True
    else:
        param.requires_grad = False

print(f"   Trainable parameters: {get_trainable_params(model):,}")

for epoch in range(config.STAGE_1_EPOCHS):
    train_loss = train_one_epoch(model, train_loader, criterion, optimizer, scaler, epoch, 1)
    val_loss, val_acc, _, _ = validate(model, val_loader, criterion)
    
    scheduler.step()
    
    history['train_loss'].append(train_loss)
    history['val_loss'].append(val_loss)
    history['val_accuracy'].append(val_acc)
    history['learning_rate'].append(optimizer.param_groups[0]['lr'])
    
    print(f"   Epoch {epoch+1}/{config.STAGE_1_EPOCHS} - "
          f"Train Loss: {train_loss:.4f}, Val Loss: {val_loss:.4f}, "
          f"Val Acc: {val_acc:.2f}%, LR: {optimizer.param_groups[0]['lr']:.2e}")
    
    if val_acc > best_accuracy:
        best_accuracy = val_acc
        torch.save(model.state_dict(), os.path.join(config.OUTPUT_DIR, 'best_model_stage1.pth'))
        print(f"   ✅ New best accuracy: {best_accuracy:.2f}%")

# ===========================
# STAGE 2: Unfreeze last 1/4
# ===========================
print(f"\n📚 STAGE 2: Unfreezing last 1/4 of backbone")
print(f"   Training for {config.STAGE_2_EPOCHS - config.STAGE_1_EPOCHS} more epochs\n")

# Unfreeze last 1/4 of model
total_layers = len(list(model.named_parameters()))
unfreeze_from = int(total_layers * 0.75)

for idx, (name, param) in enumerate(model.named_parameters()):
    if idx >= unfreeze_from:
        param.requires_grad = True

print(f"   Trainable parameters: {get_trainable_params(model):,}")

# Adjust learning rate for fine-tuning
for param_group in optimizer.param_groups:
    param_group['lr'] = config.LEARNING_RATE * 0.5

for epoch in range(config.STAGE_1_EPOCHS, config.STAGE_2_EPOCHS):
    train_loss = train_one_epoch(model, train_loader, criterion, optimizer, scaler, epoch, 2)
    val_loss, val_acc, _, _ = validate(model, val_loader, criterion)
    
    scheduler.step()
    
    history['train_loss'].append(train_loss)
    history['val_loss'].append(val_loss)
    history['val_accuracy'].append(val_acc)
    history['learning_rate'].append(optimizer.param_groups[0]['lr'])
    
    print(f"   Epoch {epoch+1}/{config.STAGE_2_EPOCHS} - "
          f"Train Loss: {train_loss:.4f}, Val Loss: {val_loss:.4f}, "
          f"Val Acc: {val_acc:.2f}%, LR: {optimizer.param_groups[0]['lr']:.2e}")
    
    if val_acc > best_accuracy:
        best_accuracy = val_acc
        patience_counter = 0
        torch.save(model.state_dict(), os.path.join(config.OUTPUT_DIR, 'best_model_stage2.pth'))
        print(f"   ✅ New best accuracy: {best_accuracy:.2f}%")
    else:
        patience_counter += 1

# ===========================
# STAGE 3: Unfreeze last 1/2
# ===========================
print(f"\n📚 STAGE 3: Unfreezing last 1/2 of backbone")
print(f"   Training for {config.STAGE_3_EPOCHS - config.STAGE_2_EPOCHS} more epochs\n")

# Unfreeze last 1/2 of model
unfreeze_from = int(total_layers * 0.5)

for idx, (name, param) in enumerate(model.named_parameters()):
    if idx >= unfreeze_from:
        param.requires_grad = True

print(f"   Trainable parameters: {get_trainable_params(model):,}")

# Further reduce learning rate
for param_group in optimizer.param_groups:
    param_group['lr'] = config.LEARNING_RATE * 0.3

for epoch in range(config.STAGE_2_EPOCHS, config.STAGE_3_EPOCHS):
    train_loss = train_one_epoch(model, train_loader, criterion, optimizer, scaler, epoch, 3)
    val_loss, val_acc, _, _ = validate(model, val_loader, criterion)
    
    scheduler.step()
    
    history['train_loss'].append(train_loss)
    history['val_loss'].append(val_loss)
    history['val_accuracy'].append(val_acc)
    history['learning_rate'].append(optimizer.param_groups[0]['lr'])
    
    print(f"   Epoch {epoch+1}/{config.STAGE_3_EPOCHS} - "
          f"Train Loss: {train_loss:.4f}, Val Loss: {val_loss:.4f}, "
          f"Val Acc: {val_acc:.2f}%, LR: {optimizer.param_groups[0]['lr']:.2e}")
    
    if val_acc > best_accuracy:
        best_accuracy = val_acc
        patience_counter = 0
        torch.save(model.state_dict(), os.path.join(config.OUTPUT_DIR, 'best_model_stage3.pth'))
        print(f"   ✅ New best accuracy: {best_accuracy:.2f}%")
    else:
        patience_counter += 1
        if patience_counter >= config.EARLY_STOPPING_PATIENCE:
            print(f"\n   ⏸️  Early stopping triggered at epoch {epoch+1}")
            break

# ===========================
# STAGE 4: Full fine-tuning
# ===========================
if epoch + 1 < config.STAGE_4_EPOCHS and patience_counter < config.EARLY_STOPPING_PATIENCE:
    print(f"\n📚 STAGE 4: Full model fine-tuning")
    print(f"   Training for {config.STAGE_4_EPOCHS - (epoch+1)} more epochs\n")
    
    # Unfreeze all layers
    for param in model.parameters():
        param.requires_grad = True
    
    print(f"   Trainable parameters: {get_trainable_params(model):,}")
    
    # Minimal learning rate for full fine-tuning
    for param_group in optimizer.param_groups:
        param_group['lr'] = config.LEARNING_RATE * 0.1
    
    for epoch in range(max(config.STAGE_3_EPOCHS, epoch+1), config.STAGE_4_EPOCHS):
        train_loss = train_one_epoch(model, train_loader, criterion, optimizer, scaler, epoch, 4)
        val_loss, val_acc, _, _ = validate(model, val_loader, criterion)
        
        scheduler.step()
        
        history['train_loss'].append(train_loss)
        history['val_loss'].append(val_loss)
        history['val_accuracy'].append(val_acc)
        history['learning_rate'].append(optimizer.param_groups[0]['lr'])
        
        print(f"   Epoch {epoch+1}/{config.STAGE_4_EPOCHS} - "
              f"Train Loss: {train_loss:.4f}, Val Loss: {val_loss:.4f}, "
              f"Val Acc: {val_acc:.2f}%, LR: {optimizer.param_groups[0]['lr']:.2e}")
        
        if val_acc > best_accuracy:
            best_accuracy = val_acc
            patience_counter = 0
            torch.save(model.state_dict(), os.path.join(config.OUTPUT_DIR, 'best_model_final.pth'))
            print(f"   ✅ New best accuracy: {best_accuracy:.2f}%")
        else:
            patience_counter += 1
            if patience_counter >= config.EARLY_STOPPING_PATIENCE:
                print(f"\n   ⏸️  Early stopping triggered at epoch {epoch+1}")
                break

print(f"\n{'='*70}")
print(f"🎉 TRAINING COMPLETED!")
print(f"{'='*70}")
print(f"📊 Best Validation Accuracy: {best_accuracy:.2f}%")
print(f"📁 Best model saved to: {config.OUTPUT_DIR}/best_model_final.pth")
print(f"{'='*70}\n")

# Save training history
with open(os.path.join(config.OUTPUT_DIR, 'training_history.json'), 'w') as f:
    json.dump(history, f, indent=2)

# Save class names
with open(os.path.join(config.OUTPUT_DIR, 'class_names.json'), 'w') as f:
    json.dump(class_names, f, indent=2)

print("✅ Training history and class names saved!")
