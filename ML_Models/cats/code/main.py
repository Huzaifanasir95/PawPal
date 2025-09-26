# Main script for cat breed classification
import argparse
import sys
import os

from config import *
from data_loader import get_data_loaders, validate_dataset, get_class_names, get_labels_for_class_weights
from model import create_enhanced_model, get_enhanced_criterion_optimizer_scheduler
from train import progressive_training


def main():
    parser = argparse.ArgumentParser(description='Cat Breed Classification Training and Evaluation')
    parser.add_argument('--mode', type=str, choices=['train', 'evaluate', 'validate', 'revalidate'],
                       default='train', help='Mode: train, evaluate, validate, or revalidate dataset')
    parser.add_argument('--epochs', type=int, default=NUM_EPOCHS,
                       help=f'Number of training epochs (default: {NUM_EPOCHS})')
    parser.add_argument('--batch_size', type=int, default=BATCH_SIZE,
                       help=f'Batch size (default: {BATCH_SIZE})')
    parser.add_argument('--model_path', type=str, default=MODEL_SAVE_PATH,
                       help=f'Path to save/load model (default: {MODEL_SAVE_PATH})')
    parser.add_argument('--force_revalidate', action='store_true',
                       help='Force revalidation of dataset images (ignore cache)')

    args = parser.parse_args()

    print("=" * 60)
    print("Cat Breed Classification - PawPal ML Model")
    print("=" * 60)
    print(f"Mode: {args.mode}")
    print(f"Device: {DEVICE}")
    print(f"Dataset: {DATASET_ROOT}")
    print("-" * 60)

    if args.mode == 'validate':
        print("🔍 Validating dataset (using cached results if available)...")
        from data_loader import validate_dataset_once
        validate_dataset_once(force_revalidate=args.force_revalidate)
        print("✅ Dataset validation completed!")
        return

    elif args.mode == 'revalidate':
        print("🔄 Force revalidating entire dataset...")
        from data_loader import validate_dataset_once
        validate_dataset_once(force_revalidate=True)
        print("✅ Dataset revalidation completed!")
        return

    elif args.mode == 'train':
        print("🚀 Starting enhanced training...")
        print(f"Epochs: {args.epochs}")
        print(f"Batch size: {args.batch_size}")
        print(f"Model save path: {args.model_path}")
        print(f"Force revalidate: {args.force_revalidate}")
        print("-" * 60)

        # Get data loaders and class names (will use cached validation)
        train_loader, val_loader, _ = get_data_loaders(batch_size=args.batch_size)
        class_names = get_class_names()

        # Create enhanced model
        model = create_enhanced_model(len(class_names), model_name=MODEL_NAME)

        # Get enhanced training components with class weights
        labels = get_labels_for_class_weights()
        criterion, optimizer, scheduler = get_enhanced_criterion_optimizer_scheduler(
            model, labels, class_names
        )

        # Train with progressive learning
        history = progressive_training(
            model=model,
            train_loader=train_loader,
            val_loader=val_loader,
            criterion=criterion,
            optimizer=optimizer,
            scheduler=scheduler,
            num_epochs=args.epochs,
            save_path=args.model_path,
            class_names=class_names,
            labels=labels
        )

        print("\n🎉 Enhanced training completed successfully!")
        print(f"Model saved to: {args.model_path}")

    elif args.mode == 'evaluate':
        print("Starting evaluation...")
        print(f"Model path: {args.model_path}")
        print("-" * 60)

        # Check if model exists
        if not os.path.exists(args.model_path):
            print(f"Error: Model file not found at {args.model_path}")
            sys.exit(1)

        # TODO: Implement enhanced evaluation
        print("Enhanced evaluation coming soon!")
        print("Use the trained model for inference with the enhanced techniques.")

    print("\n" + "=" * 60)
    print("Process completed!")
    print("=" * 60)


if __name__ == "__main__":
    main()