"""
MyAI - Command-Line Model Training Tool
Usage:
    python ai/scripts/train.py --model neural_network --epochs 20 --lr 0.05
    python ai/scripts/train.py --model tiny_llm --epochs 25 --lr 0.01
"""

import argparse
import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from training.trainer import start_training_job, get_job
import time


def main():
    parser = argparse.ArgumentParser(description="Train a MyAI neural model from scratch")
    parser.add_argument("--model", type=str, default="neural_network", choices=["neural_network", "tiny_llm"], help="Model architecture")
    parser.add_argument("--epochs", type=int, default=20, help="Number of training epochs")
    parser.add_argument("--lr", type=float, default=0.05, help="Learning rate")
    args = parser.parse_args()

    job_id = f"cli-job-{int(time.time())}"
    print(f"==================================================")
    print(f"Starting training for {args.model.upper()}...")
    print(f"Job ID: {job_id} | Epochs: {args.epochs} | Learning Rate: {args.lr}")
    print(f"==================================================")

    start_training_job(job_id=job_id, model_type=args.model, epochs=args.epochs, lr=args.lr)

    while True:
        job = get_job(job_id)
        if job:
            status = job.get("status")
            cur = job.get("current_epoch", 0)
            loss = job.get("current_loss")
            acc = job.get("accuracy")
            print(f"Epoch [{cur}/{args.epochs}] - Loss: {loss} - Accuracy: {acc}%", end="\r")
            if status in ["COMPLETED", "FAILED"]:
                print(f"\nTraining {status}! Checkpoint saved to: {job.get('checkpoint_path')}")
                break
        time.sleep(0.2)


if __name__ == "__main__":
    main()
