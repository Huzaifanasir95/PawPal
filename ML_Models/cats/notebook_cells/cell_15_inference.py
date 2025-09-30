def predict_breed(image_path, model, class_names, use_tta=True):
    """
    Predict cat breed from image path
    
    Args:
        image_path: Path to image file
        model: Trained model
        class_names: List of class names
        use_tta: Whether to use Test-Time Augmentation
    
    Returns:
        predicted_breed: Predicted breed name
        confidence: Confidence score (0-100)
        top5_breeds: List of top 5 predictions with probabilities
    """
    model.eval()
    
    # Load image
    image = cv2.imread(image_path)
    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    
    if use_tta and config.USE_TTA:
        # Use TTA for more robust predictions
        tta_transforms = get_tta_transforms()
        all_probs = []
        
        for tta_transform in tta_transforms:
            augmented = tta_transform(image=image)
            img_tensor = augmented['image'].unsqueeze(0).to(config.DEVICE)
            
            with torch.no_grad():
                outputs = model(img_tensor)
                probs = F.softmax(outputs, dim=1)
                all_probs.append(probs.cpu().numpy())
        
        # Average predictions
        avg_probs = np.mean(all_probs, axis=0)[0]
        
    else:
        # Single prediction
        val_transform = get_val_transforms()
        augmented = val_transform(image=image)
        img_tensor = augmented['image'].unsqueeze(0).to(config.DEVICE)
        
        with torch.no_grad():
            outputs = model(img_tensor)
            probs = F.softmax(outputs, dim=1)
            avg_probs = probs.cpu().numpy()[0]
    
    # Get top 5 predictions
    top5_indices = np.argsort(avg_probs)[-5:][::-1]
    top5_breeds = [(class_names[idx], float(avg_probs[idx] * 100)) for idx in top5_indices]
    
    # Best prediction
    predicted_idx = top5_indices[0]
    predicted_breed = class_names[predicted_idx]
    confidence = float(avg_probs[predicted_idx] * 100)
    
    return predicted_breed, confidence, top5_breeds

def visualize_prediction(image_path, predicted_breed, confidence, top5_breeds):
    """Visualize prediction with image and top 5 predictions"""
    # Load and display image
    image = cv2.imread(image_path)
    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Show image
    ax1.imshow(image)
    ax1.axis('off')
    ax1.set_title(f'Predicted: {predicted_breed}\\nConfidence: {confidence:.2f}%', 
                 fontsize=14, fontweight='bold',
                 color='green' if confidence > 80 else 'orange')
    
    # Show top 5 predictions
    breeds = [b[0] for b in top5_breeds]
    probs = [b[1] for b in top5_breeds]
    colors = ['green' if i == 0 else 'skyblue' for i in range(len(breeds))]
    
    ax2.barh(range(len(breeds)), probs, color=colors, alpha=0.7, edgecolor='black')
    ax2.set_yticks(range(len(breeds)))
    ax2.set_yticklabels(breeds)
    ax2.set_xlabel('Confidence (%)', fontsize=12)
    ax2.set_title('Top 5 Predictions', fontsize=14, fontweight='bold')
    ax2.invert_yaxis()
    ax2.grid(True, alpha=0.3, axis='x')
    
    for i, (breed, prob) in enumerate(top5_breeds):
        ax2.text(prob + 1, i, f'{prob:.1f}%', va='center', fontsize=10)
    
    plt.tight_layout()
    plt.show()

# Example: Predict on a sample from validation set
print("\\n🔮 Example Prediction:\\n")

# Get a random sample from validation dataset
sample_idx = np.random.randint(0, len(val_dataset))
sample_path, true_label = val_dataset.dataset.samples[sample_idx]
true_breed = idx_to_class[true_label]

print(f"Sample image: {sample_path}")
print(f"True breed: {true_breed}\\n")

# Make prediction
predicted_breed, confidence, top5_breeds = predict_breed(sample_path, model, class_names, use_tta=True)

print(f"✅ Predicted breed: {predicted_breed}")
print(f"✅ Confidence: {confidence:.2f}%")
print(f"\\nTop 5 predictions:")
for i, (breed, prob) in enumerate(top5_breeds, 1):
    marker = "✓" if breed == true_breed else " "
    print(f"  {i}. {breed:30s} : {prob:5.2f}% {marker}")

# Visualize
visualize_prediction(sample_path, predicted_breed, confidence, top5_breeds)

# Function to save for future use
print("\\n" + "="*70)
print("💾 SAVING INFERENCE COMPONENTS")
print("="*70)

# Save model
torch.save({
    'model_state_dict': model.state_dict(),
    'class_names': class_names,
    'config': {
        'MODEL_NAME': config.MODEL_NAME,
        'IMAGE_SIZE': config.IMAGE_SIZE,
        'NUM_CLASSES': config.NUM_CLASSES,
        'MEAN': config.MEAN,
        'STD': config.STD,
    }
}, os.path.join(config.OUTPUT_DIR, 'cat_breed_classifier_complete.pth'))

print(f"\\n✅ Complete model saved to: {config.OUTPUT_DIR}/cat_breed_classifier_complete.pth")
print(f"\\n📦 To use this model later:")
print(f"   1. Load the checkpoint")
print(f"   2. Create model with timm.create_model()")
print(f"   3. Load state_dict")
print(f"   4. Use predict_breed() function")

print(f"\\n" + "="*70)
print(f"🎉 ALL DONE! Model trained and ready for deployment!")
print(f"="*70)
print(f"\\n📊 Summary:")
print(f"   • Final Accuracy: {final_acc:.2f}%")
print(f"   • Model: {config.MODEL_NAME}")
print(f"   • Classes: {config.NUM_CLASSES} cat breeds")
print(f"   • Training Time: ~{len(history['train_loss'])} epochs")
print(f"   • Status: {'✅ TARGET ACHIEVED!' if final_acc >= 90 else '⚠️ Consider more training'}")
print(f"\\n🚀 Ready for production use!")
