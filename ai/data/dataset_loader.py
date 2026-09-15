"""
MyAI - Data Management & Loading Module
Provides utilities for generating and loading synthetic and real datasets for:
- Regression
- Classification
- Language Modeling
"""

import numpy as np
from typing import Tuple


def load_synthetic_classification_data(n_samples: int = 600, n_features: int = 4, n_classes: int = 3) -> Tuple[np.ndarray, np.ndarray]:
    """Generates non-linear multi-class cluster data for neural network training."""
    np.random.seed(42)
    X = np.random.randn(n_samples, n_features)
    y = ((X[:, 0] * 1.5 + X[:, 1] ** 2) > 1.2).astype(int) + ((X[:, 2] - X[:, 3]) > 0.5).astype(int)
    y = np.clip(y, 0, n_classes - 1)
    return X, y


def load_synthetic_regression_data(n_samples: int = 500, n_features: int = 2) -> Tuple[np.ndarray, np.ndarray]:
    """Generates synthetic linear regression data with known ground truth weights."""
    np.random.seed(42)
    true_w = np.array([[3.5], [-1.8]])
    true_b = 4.2
    X = np.random.randn(n_samples, n_features) * 2.0
    noise = np.random.randn(n_samples, 1) * 0.5
    y = X @ true_w + true_b + noise
    return X, y.ravel()


def load_corpus_text() -> str:
    """Returns the foundational text corpus for Tiny Language Model training."""
    return (
        "Artificial intelligence is an intelligent system capable of learning from data. "
        "Neural networks learn representations through optimization and backpropagation. "
        "Attention mechanisms allow models to focus on relevant context dynamically. "
        "Transformers process sequence data in parallel using self-attention. "
        "Language models predict the next token to generate coherent natural language. "
        "MyAI multimodal platform combines text, vision, ocr, and image synthesis."
    )
