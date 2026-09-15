"""
MyAI - Phase 1: Machine Learning Fundamentals
Experiment: Training & Evaluating Logistic Regression from Scratch

Validates:
1. Binary classification on non-trivial separable clusters
2. Loss curve progression (BCE convergence)
3. Confusion matrix, Accuracy, Precision, Recall, F1-Score
"""

import numpy as np
import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from models.logistic_regression import (
    LogisticRegressionFromScratch,
    confusion_matrix,
    accuracy_score,
    precision_score,
    recall_score,
    f1_score
)


def run_classification_experiment():
    print("=" * 60)
    print("MyAI Phase 1: Logistic Regression & Classification Experiment")
    print("=" * 60)

    # 1. Synthesize 2-Class Gaussian Clusters
    np.random.seed(42)
    n_samples_per_class = 250

    # Class 0 centered at (-1.5, -1.5)
    X_class0 = np.random.randn(n_samples_per_class, 2) * 1.0 + np.array([-1.5, -1.5])
    y_class0 = np.zeros((n_samples_per_class, 1))

    # Class 1 centered at (1.5, 1.5)
    X_class1 = np.random.randn(n_samples_per_class, 2) * 1.0 + np.array([1.5, 1.5])
    y_class1 = np.ones((n_samples_per_class, 1))

    X = np.vstack([X_class0, X_class1])
    y = np.vstack([y_class0, y_class1])

    # Shuffle dataset
    indices = np.random.permutation(len(X))
    X = X[indices]
    y = y[indices]

    # Train / Test Split (80% / 20%)
    split_idx = int(len(X) * 0.8)
    X_train, X_test = X[:split_idx], X[split_idx:]
    y_train, y_test = y[:split_idx], y[split_idx:]

    print(f"Total dataset: {len(X)} samples across 2 classes (Balanced: 50% / 50%)")
    print(f"Train set: {len(X_train)} samples | Test set: {len(X_test)} samples")
    print("-" * 60)

    # 2. Train Logistic Regression
    print("Training Logistic Regression (lr=0.1, epochs=1000)...")
    clf = LogisticRegressionFromScratch(learning_rate=0.1, n_iterations=1000)
    clf.fit(X_train, y_train)

    # 3. Evaluate on Test Set
    preds = clf.predict(X_test)
    probs = clf.predict_proba(X_test)

    cm = confusion_matrix(y_test, preds)
    acc = accuracy_score(y_test, preds)
    prec = precision_score(y_test, preds)
    rec = recall_score(y_test, preds)
    f1 = f1_score(y_test, preds)

    w = clf.weights.ravel()
    print(f"Learned Decision Boundary: {w[0]:.4f} * x1 + {w[1]:.4f} * x2 + ({clf.bias:.4f}) = 0")
    print("-" * 60)
    print("Confusion Matrix:")
    print(f"  True Positives (TP):  {cm['TP']} | False Positives (FP): {cm['FP']}")
    print(f"  False Negatives (FN): {cm['FN']} | True Negatives (TN):  {cm['TN']}")
    print("-" * 60)
    print(f"Accuracy:  {acc * 100:.2f}%")
    print(f"Precision: {prec * 100:.2f}%")
    print(f"Recall:    {rec * 100:.2f}%")
    print(f"F1-Score:  {f1:.4f}")
    print("-" * 60)
    print(f"Initial BCE Loss (Epoch 0):   {clf.loss_history[0]:.4f}")
    print(f"Final BCE Loss   (Epoch 999): {clf.loss_history[-1]:.4f}")
    print("=" * 60)


if __name__ == "__main__":
    run_classification_experiment()
