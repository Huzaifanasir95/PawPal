# Main script for cat breed classification
import argparse
import sys
import os

from config import *
from data_loader import get_data_loaders, validate_dataset
from model import create_model, get_criterion_optimizer_scheduler
from train import train_model
from evaluate import run_evaluation


def main():
    parser = argparse.ArgumentParser(description='Cat Breed Classification Training and Evaluation')
    parser.add_argument('--mode', type=str, choices=['train', 'evaluate', 'validate'],
                       default='train', help='Mode: train, evaluate, or validate dataset')
    parser.add_argument('--epochs', type=int, default=NUM_EPOCHS,
                       help=f'Number of training epochs (default: {NUM_EPOCHS})')
    parser.add_argument('--batch_size', type=int, default=BATCH_SIZE,
                       help=f'Batch size (default: {BATCH_SIZE})')
    parser.add_argument('--model_path', type=str, default=MODEL_SAVE_PATH,
                       help=f'Path to save/load model (default: {MODEL_SAVE_PATH})')

    args = parser.parse_args()

    print("=" * 60)
    print("Cat Breed Classification - PawPal ML Model")
    print("=" * 60)
    print(f"Mode: {args.mode}")
    print(f"Device: {DEVICE}")
    print(f"Dataset: {DATASET_ROOT}")
    print("-" * 60)

    if args.mode == 'validate':
        print("Validating dataset...")
        validate_dataset()
        print("Dataset validation completed!")
        return

    elif args.mode == 'train':
        print("Starting training...")
        print(f"Epochs: {args.epochs}")
        print(f"Batch size: {args.batch_size}")
        print(f"Model save path: {args.model_path}")
        print("-" * 60)

        # Validate dataset first
        validate_dataset()

        # Get data loaders
        train_loader, val_loader, _ = get_data_loaders(batch_size=args.batch_size)

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
            num_epochs=args.epochs,
            save_path=args.model_path
        )

        print("\nTraining completed successfully!")
        print(f"Model saved to: {args.model_path}")

    elif args.mode == 'evaluate':
        print("Starting evaluation...")
        print(f"Model path: {args.model_path}")
        print("-" * 60)

        # Check if model exists
        if not os.path.exists(args.model_path):
            print(f"Error: Model file not found at {args.model_path}")
            sys.exit(1)

        # Run evaluation
        test_loss, test_acc, report = run_evaluation()

        print("\nEvaluation completed successfully!")

    print("\n" + "=" * 60)
    print("Process completed!")
    print("=" * 60)


if __name__ == "__main__":
    main()