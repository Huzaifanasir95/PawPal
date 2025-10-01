def train_one_epoch(model, train_loader, criterion, optimizer, scaler, epoch, stage):
    """Train for one epoch"""
    model.train()
    running_loss = 0.0
    correct = 0
    total = 0
    
    pbar = tqdm(train_loader, desc=f"Stage {stage} | Epoch {epoch+1}")
    
    optimizer.zero_grad()
    
    for batch_idx, (inputs, labels) in enumerate(pbar):
        inputs, labels = inputs.to(config.DEVICE), labels.to(config.DEVICE)
        
        # Apply MixUp or CutMix randomly
        use_mix = (config.USE_MIXUP or config.USE_CUTMIX) and np.random.rand() < config.MIX_PROB
        
        if use_mix:
            if config.USE_MIXUP and (not config.USE_CUTMIX or np.random.rand() < 0.5):
                inputs, y_a, y_b, lam = mixup_data(inputs, labels, config.MIXUP_ALPHA)
            else:
                inputs, y_a, y_b, lam = cutmix_data(inputs, labels, config.CUTMIX_ALPHA)
        
        # Forward pass with mixed precision
        with autocast(enabled=config.USE_AMP):
            outputs = model(inputs)
            
            if use_mix:
                loss = mixup_criterion(criterion, outputs, y_a, y_b, lam)
            else:
                loss = criterion(outputs, labels)
            
            # Scale loss for gradient accumulation
            loss = loss / config.ACCUMULATION_STEPS
        
        # Backward pass
        scaler.scale(loss).backward()
        
        # Gradient accumulation
        if (batch_idx + 1) % config.ACCUMULATION_STEPS == 0:
            # Gradient clipping
            scaler.unscale_(optimizer)
            torch.nn.utils.clip_grad_norm_(model.parameters(), config.GRADIENT_CLIP)
            
            # Optimizer step
            scaler.step(optimizer)
            scaler.update()
            optimizer.zero_grad()
        
        # Statistics (only for non-mixed batches)
        running_loss += loss.item() * config.ACCUMULATION_STEPS
        
        if not use_mix:
            _, predicted = outputs.max(1)
            total += labels.size(0)
            correct += predicted.eq(labels).sum().item()
        
        # Update progress bar
        if total > 0:
            acc = 100. * correct / total
            pbar.set_postfix({'loss': f'{running_loss/(batch_idx+1):.4f}', 'acc': f'{acc:.2f}%'})
        else:
            pbar.set_postfix({'loss': f'{running_loss/(batch_idx+1):.4f}'})
    
    avg_loss = running_loss / len(train_loader)
    return avg_loss

@torch.no_grad()
def validate(model, val_loader, criterion):
    """Validate the model"""
    model.eval()
    running_loss = 0.0
    correct = 0
    total = 0
    
    all_preds = []
    all_labels = []
    
    pbar = tqdm(val_loader, desc="Validation")
    
    for inputs, labels in pbar:
        inputs, labels = inputs.to(config.DEVICE), labels.to(config.DEVICE)
        
        # Forward pass
        outputs = model(inputs)
        loss = criterion(outputs, labels)
        
        running_loss += loss.item()
        
        _, predicted = outputs.max(1)
        total += labels.size(0)
        correct += predicted.eq(labels).sum().item()
        
        all_preds.extend(predicted.cpu().numpy())
        all_labels.extend(labels.cpu().numpy())
        
        acc = 100. * correct / total
        pbar.set_postfix({'loss': f'{running_loss/(pbar.n+1):.4f}', 'acc': f'{acc:.2f}%'})
    
    avg_loss = running_loss / len(val_loader)
    accuracy = 100. * correct / total
    
    return avg_loss, accuracy, all_preds, all_labels

@torch.no_grad()
def validate_with_tta(model, val_loader, tta_transforms):
    """Validate with Test-Time Augmentation"""
    model.eval()
    
    all_preds_tta = []
    all_labels = []
    
    print(f"\n🔮 Running TTA with {len(tta_transforms)} transforms...")
    
    for inputs, labels in tqdm(val_loader, desc="TTA Validation"):
        inputs_orig = inputs.clone()
        labels = labels.to(config.DEVICE)
        all_labels.extend(labels.cpu().numpy())
        
        # Collect predictions from all TTA transforms
        batch_preds = []
        
        for tta_idx, tta_transform in enumerate(tta_transforms):
            # Apply TTA transform to each image
            tta_batch = []
            for img_tensor in inputs_orig:
                # Convert back to numpy for albumentations
                img_np = img_tensor.permute(1, 2, 0).numpy()
                # Denormalize
                img_np = img_np * np.array(config.STD) + np.array(config.MEAN)
                img_np = (img_np * 255).astype(np.uint8)
                # Apply TTA transform
                augmented = tta_transform(image=img_np)
                tta_batch.append(augmented['image'])
            
            tta_batch = torch.stack(tta_batch).to(config.DEVICE)
            
            # Get predictions
            outputs = model(tta_batch)
            probs = F.softmax(outputs, dim=1)
            batch_preds.append(probs.cpu().numpy())
        
        # Average predictions across all TTA transforms
        avg_probs = np.mean(batch_preds, axis=0)
        final_preds = np.argmax(avg_probs, axis=1)
        all_preds_tta.extend(final_preds)
    
    # Calculate accuracy
    accuracy = 100. * np.sum(np.array(all_preds_tta) == np.array(all_labels)) / len(all_labels)
    
    return accuracy, all_preds_tta, all_labels

print("✅ Training and validation functions ready!")
