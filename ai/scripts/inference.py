"""
MyAI - Command-Line Model Inference Tool
Usage:
    python ai/scripts/inference.py --model tiny_llm --prompt "Neural networks"
    python ai/scripts/inference.py --model neural_network
"""

import argparse
import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from training.trainer import run_inference


def main():
    parser = argparse.ArgumentParser(description="Run inference using trained MyAI models")
    parser.add_argument("--model", type=str, default="tiny_llm", choices=["tiny_llm", "neural_network"])
    parser.add_argument("--prompt", type=str, default="Artificial intelligence", help="Input prompt for LLM")
    args = parser.parse_args()

    print(f"Running inference on {args.model}...")
    res = run_inference(model_type=args.model, prompt=args.prompt, features=[1.2, -0.4, 0.8, -1.0])
    print(f"\nModel: {res.get('model_used')}")
    print(f"Confidence: {res.get('confidence')}")
    print(f"Output:\n{res.get('output')}")


if __name__ == "__main__":
    main()
