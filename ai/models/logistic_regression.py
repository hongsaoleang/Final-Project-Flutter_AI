"""
MyAI - Phase 1: Machine Learning Fundamentals
Module: Logistic Regression & Classification from Scratch (NumPy)

Provides:
- Binary Logistic Regression (Sigmoid activation + Binary Cross-Entropy)
- Classification Metrics: Confusion Matrix, Accuracy, Precision, Recall, F1-Score
"""

import numpy as np
from typing import Dict, Tuple, Optional


def sigmoid(z: np.ndarray) -> np.ndarray:
    """
    Numerically stable sigmoid function:
    sigma(z) = 1 / (1 + exp(-z))
    """
    z = np.asarray(z, dtype=np.float64)
    # Clip to avoid overflow in exp(-z)
    z = np.clip(z, -500.0, 500.0)
    return 1.0 / (1.0 + np.exp(-z))


class LogisticRegressionFromScratch:
    """
    Logistic Regression classifier implemented strictly with NumPy.
    
    Hypothesis:
        z = X * w + b
        y_hat = sigmoid(z) = P(y = 1 | X)
        
    Binary Cross-Entropy Loss:
        J(w, b) = -(1 / n) * sum( y * log(y_hat) + (1 - y) * log(1 - y_hat) )
        
    Gradients:
        dJ/dw = (1 / n) * X^T * (y_hat - y)
        dJ/db = (1 / n) * sum(y_hat - y)
    """

    def __init__(self, learning_rate: float = 0.05, n_iterations: int = 1000):
        self.learning_rate = learning_rate
        self.n_iterations = n_iterations
        self.weights: Optional[np.ndarray] = None
        self.bias: float = 0.0
        self.loss_history: list[float] = []

    def fit(self, X: np.ndarray, y: np.ndarray) -> "LogisticRegressionFromScratch":
        X = np.asarray(X, dtype=np.float64)
        y = np.asarray(y, dtype=np.float64).reshape(-1, 1)
        n_samples, n_features = X.shape

        self.weights = np.zeros((n_features, 1))
        self.bias = 0.0
        self.loss_history = []

        eps = 1e-15  # Avoid log(0)

        for epoch in range(self.n_iterations):
            # 1. Linear combination
            z = X @ self.weights + self.bias
            # 2. Sigmoid activation
            y_hat = sigmoid(z)

            # 3. Binary Cross-Entropy Loss
            y_hat_clipped = np.clip(y_hat, eps, 1.0 - eps)
            loss = -np.mean(y * np.log(y_hat_clipped) + (1.0 - y) * np.log(1.0 - y_hat_clipped))
            self.loss_history.append(float(loss))

            # 4. Compute gradients
            error = y_hat - y
            dw = (1.0 / n_samples) * (X.T @ error)
            db = float((1.0 / n_samples) * np.sum(error))

            # 5. Parameter update
            self.weights -= self.learning_rate * dw
            self.bias -= self.learning_rate * db

        return self

    def predict_proba(self, X: np.ndarray) -> np.ndarray:
        """Returns predicted probabilities of the positive class."""
        X = np.asarray(X, dtype=np.float64)
        z = X @ self.weights + self.bias
        return sigmoid(z).ravel()

    def predict(self, X: np.ndarray, threshold: float = 0.5) -> np.ndarray:
        """Returns binary predictions (0 or 1) based on probability threshold."""
        probs = self.predict_proba(X)
        return (probs >= threshold).astype(int)


# ==========================================
# Classification Evaluation Metrics from Scratch
# ==========================================

def confusion_matrix(y_true: np.ndarray, y_pred: np.ndarray) -> Dict[str, int]:
    """
    Computes 2x2 binary confusion matrix:
    TP: True Positive, FP: False Positive, TN: True Negative, FN: False Negative
    """
    y_true_flat = np.asarray(y_true).ravel().astype(int)
    y_pred_flat = np.asarray(y_pred).ravel().astype(int)

    tp = int(np.sum((y_true_flat == 1) & (y_pred_flat == 1)))
    tn = int(np.sum((y_true_flat == 0) & (y_pred_flat == 0)))
    fp = int(np.sum((y_true_flat == 0) & (y_pred_flat == 1)))
    fn = int(np.sum((y_true_flat == 1) & (y_pred_flat == 0)))

    return {"TP": tp, "FP": fp, "TN": tn, "FN": fn}


def accuracy_score(y_true: np.ndarray, y_pred: np.ndarray) -> float:
    cm = confusion_matrix(y_true, y_pred)
    total = cm["TP"] + cm["TN"] + cm["FP"] + cm["FN"]
    return float((cm["TP"] + cm["TN"]) / total) if total > 0 else 0.0


def precision_score(y_true: np.ndarray, y_pred: np.ndarray) -> float:
    cm = confusion_matrix(y_true, y_pred)
    denom = cm["TP"] + cm["FP"]
    return float(cm["TP"] / denom) if denom > 0 else 0.0


def recall_score(y_true: np.ndarray, y_pred: np.ndarray) -> float:
    cm = confusion_matrix(y_true, y_pred)
    denom = cm["TP"] + cm["FN"]
    return float(cm["TP"] / denom) if denom > 0 else 0.0


def f1_score(y_true: np.ndarray, y_pred: np.ndarray) -> float:
    p = precision_score(y_true, y_pred)
    r = recall_score(y_true, y_pred)
    return float(2.0 * (p * r) / (p + r)) if (p + r) > 0 else 0.0
