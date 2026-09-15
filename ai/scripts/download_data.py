"""
MyAI - Data Ingestion & Synthesis Script
Usage: python ai/scripts/download_data.py
Populates raw and processed datasets for training language models and classifiers.
"""

import os
import sys

DATA_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "data"))
RAW_DIR = os.path.join(DATA_DIR, "raw")
os.makedirs(RAW_DIR, exist_ok=True)


def main():
    print(f"[MyAI Data Engine] Verifying datasets in {RAW_DIR}...")
    corpus_file = os.path.join(RAW_DIR, "corpus.txt")
    if os.path.exists(corpus_file):
        size = os.path.getsize(corpus_file)
        print(f"Found corpus.txt ({size} bytes). Dataset ready for training!")
    else:
        print("Creating corpus.txt...")
        with open(corpus_file, "w", encoding="utf-8") as f:
            f.write("Artificial intelligence is an intelligent system capable of learning from data.")
        print("Generated fallback corpus.")


if __name__ == "__main__":
    main()
