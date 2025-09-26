# Evaluation script for cat breed classification
import torch
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score, precision_recall_fscore_support
from tqdm import tqdm
import pandas as pd
from PIL import Image
import os

from config import *
from model import load_model
from data_loader import get_data_loaders, get_class_names

# Set style for plots
plt.style.use('default')
sns.set_palette("husl")


def evaluate_model(model, test_loader, criterion, device, class_names):
    """Evaluate model on test set"""
    model.eval()
    running_loss = 0.0
    all_preds = []
    all_labels = []
    all_probs = []

    print("Evaluating model on test set...")

    with torch.no_grad():
        pbar = tqdm(test_loader, desc='Evaluating')
        for inputs, labels in pbar:
            inputs, labels = inputs.to(device), labels.to(device)

            # Forward pass
            outputs = model(inputs)
            loss = criterion(outputs, labels)

            # Get predictions and probabilities
            probs = torch.exp(outputs)  # Convert log probabilities to probabilities
            _, preds = torch.max(outputs, 1)

            # Accumulate statistics
            running_loss += loss.item() * inputs.size(0)
            all_preds.extend(preds.cpu().numpy())
            all_labels.extend(labels.cpu().numpy())
            all_probs.extend(probs.cpu().numpy())

    # Calculate metrics
    test_loss = running_loss / len(test_loader.dataset)
    test_acc = accuracy_score(all_labels, all_preds) * 100

    # Detailed classification report
    report = classification_report(all_labels, all_preds, target_names=class_names, output_dict=True)

    print(".4f")
    print(".2f")

    return test_loss, test_acc, all_preds, all_labels, all_probs, report


def plot_confusion_matrix(y_true, y_pred, class_names, save_path='confusion_matrix.png'):
    """Plot confusion matrix"""
    cm = confusion_matrix(y_true, y_pred)

    plt.figure(figsize=(20, 16))
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues',
                xticklabels=class_names, yticklabels=class_names,
                cbar_kws={'label': 'Number of predictions'})

    plt.title('Confusion Matrix - Cat Breed Classification', fontsize=16, pad=20)
    plt.xlabel('Predicted Breed', fontsize=12)
    plt.ylabel('True Breed', fontsize=12)
    plt.xticks(rotation=45, ha='right')
    plt.yticks(rotation=0)

    plt.tight_layout()
    plt.savefig(save_path, dpi=300, bbox_inches='tight')
    plt.show()

    print(f"Confusion matrix saved as: {save_path}")


def plot_top_errors(model, test_loader, class_names, all_probs, all_labels, all_preds, top_k=10):
    """Plot top prediction errors"""
    # Convert to numpy arrays
    probs = np.array(all_probs)
    labels = np.array(all_labels)
    preds = np.array(all_preds)

    # Find incorrect predictions
    incorrect_mask = preds != labels
    incorrect_probs = probs[incorrect_mask]
    incorrect_labels = labels[incorrect_mask]
    incorrect_preds = preds[incorrect_mask]

    # Get confidence scores for incorrect predictions (probability of predicted class)
    incorrect_confidences = []
    for i, pred in enumerate(incorrect_preds):
        incorrect_confidences.append(incorrect_probs[i, pred])

    incorrect_confidences = np.array(incorrect_confidences)

    # Get top k most confident incorrect predictions
    top_indices = np.argsort(incorrect_confidences)[-top_k:][::-1]

    print(f"\nTop {top_k} most confident incorrect predictions:")
    print("-" * 60)

    for i, idx in enumerate(top_indices):
        true_label = class_names[incorrect_labels[idx]]
        pred_label = class_names[incorrect_preds[idx]]
        confidence = incorrect_confidences[idx] * 100

        print(f"{i+1}. True: {true_label}")
        print(f"   Predicted: {pred_label}")
        print(".2f")
        print()


def analyze_predictions_by_breed(report, class_names):
    """Analyze predictions for each breed"""
    print("\nDetailed Analysis by Breed:")
    print("=" * 80)

    # Convert to DataFrame for easier analysis
    metrics_df = pd.DataFrame(report).T
    breed_metrics = metrics_df.iloc[:-3]  # Exclude macro/micro avg and weighted avg

    # Sort by F1-score
    breed_metrics = breed_metrics.sort_values('f1-score', ascending=False)

    print("Breeds sorted by F1-Score:")
    print("-" * 40)

    for idx, row in breed_metrics.iterrows():
        breed_name = class_names[int(idx)] if isinstance(idx, str) and idx.isdigit() else str(idx)
        print("30"
              "6.2f"
              "6.2f"
              "6.2f"
              "6.0f")

    # Find best and worst performing breeds
    best_breed_idx = breed_metrics.index[0]
    worst_breed_idx = breed_metrics.index[-1]

    print(f"\nBest performing breed: {class_names[int(best_breed_idx)]}")
    print(".4f")

    print(f"Worst performing breed: {class_names[int(worst_breed_idx)]}")
    print(".4f")


def predict_single_image(model, image_path, class_names, device, transform=None):
    """Predict breed for a single image"""
    from data_loader import get_transforms

    if transform is None:
        _, _, transform = get_transforms()

    # Load and preprocess image
    image = Image.open(image_path).convert('RGB')
    image_tensor = transform(image).unsqueeze(0).to(device)

    # Make prediction
    model.eval()
    with torch.no_grad():
        outputs = model(image_tensor)
        probs = torch.exp(outputs)
        confidence, predicted = torch.max(probs, 1)

    predicted_class = class_names[predicted.item()]
    confidence_score = confidence.item() * 100

    # Get top 3 predictions
    top3_probs, top3_indices = torch.topk(probs, 3)
    top3_predictions = [(class_names[idx.item()], prob.item() * 100)
                       for idx, prob in zip(top3_indices[0], top3_probs[0])]

    return predicted_class, confidence_score, top3_predictions


def run_evaluation():
    """Main evaluation function"""
    print("Loading model and data for evaluation...")

    # Load model
    model, _, _, class_names, _ = load_model(MODEL_SAVE_PATH)

    # Get data loaders
    _, _, test_loader = get_data_loaders()

    # Get training components
    criterion = torch.nn.NLLLoss()

    # Evaluate model
    test_loss, test_acc, all_preds, all_labels, all_probs, report = evaluate_model(
        model, test_loader, criterion, DEVICE, class_names
    )

    # Plot confusion matrix
    plot_confusion_matrix(all_labels, all_preds, class_names)

    # Analyze predictions by breed
    analyze_predictions_by_breed(report, class_names)

    # Show top errors
    plot_top_errors(model, test_loader, class_names, all_probs, all_labels, all_preds)

    print("\nEvaluation completed!")
    print(f"Results saved as: confusion_matrix.png")

    return test_loss, test_acc, report


if __name__ == "__main__":
    # Run evaluation
    test_loss, test_acc, report = run_evaluation()

    print("Final Results:")
    print(".4f")
    print(".2f")