"""
MyAI - Phase 1: Machine Learning Fundamentals
Module: Linear Regression from Scratch (NumPy)

Provides:
- Analytical Solution (Normal Equation / OLS)
- Iterative Solution (Gradient Descent)
- Evaluation Metrics: MSE, MAE, R^2 Score
"""

import numpy as np
from typing import Tuple, Dict, Optional


class LinearRegressionFromScratch:
    """
    Linear Regression implemented strictly using NumPy.
    
    Hypothesis:
        y_hat = X * w + b
        
    Cost Function (Mean Squared Error):
        J(w, b) = (1 / 2n) * sum((y_hat_i - y_i)^2)
        
    Gradients:
        dJ/dw = (1 / n) * X^T * (y_hat - y)
        dJ/db = (1 / n) * sum(y_hat - y)
    """

    def __init__(self, learning_rate: float = 0.01, n_iterations: int = 1000, method: str = "gradient_descent"):
        """
        Args:
            learning_rate: Step size alpha for gradient descent.
            n_iterations: Maximum training epochs.
            method: 'gradient_descent' or 'normal_equation'
        """
        self.learning_rate = learning_rate
        self.n_iterations = n_iterations
        self.method = method
        self.weights: Optional[np.ndarray] = None
        self.bias: float = 0.0
        self.loss_history: list[float] = []

    def fit(self, X: np.ndarray, y: np.ndarray) -> "LinearRegressionFromScratch":
        """
        Train the linear model on features X and targets y.
        
        Args:
            X: Input feature matrix of shape (n_samples, n_features)
            y: Target values of shape (n_samples,) or (n_samples, 1)
        """
        X = np.asarray(X, dtype=np.float64)
        y = np.asarray(y, dtype=np.float64).reshape(-1, 1)
        n_samples, n_features = X.shape

        if self.method == "normal_equation":
            # Analytical OLS solution: theta = (X_b^T * X_b)^(-1) * X_b^T * y
            X_b = np.c_[np.ones((n_samples, 1)), X]
            try:
                theta = np.linalg.pinv(X_b.T @ X_b) @ X_b.T @ y
                self.bias = float(theta[0, 0])
                self.weights = theta[1:]
            except np.linalg.LinAlgError:
                # Fallback to gradient descent if matrix is singular
                self._fit_gradient_descent(X, y, n_samples, n_features)
        else:
            self._fit_gradient_descent(X, y, n_samples, n_features)

        return self

    def _fit_gradient_descent(self, X: np.ndarray, y: np.ndarray, n_samples: int, n_features: int) -> None:
        # Initialize parameters
        self.weights = np.zeros((n_features, 1))
        self.bias = 0.0
        self.loss_history = []

        for epoch in range(self.n_iterations):
            # Forward pass (predictions)
            y_hat = self._predict_raw(X)

            # Compute error residual
            error = y_hat - y

            # Compute cost (MSE)
            loss = float(np.mean(error ** 2)) / 2.0
            self.loss_history.append(loss)

            # Backward pass (gradients)
            dw = (1.0 / n_samples) * (X.T @ error)
            db = float((1.0 / n_samples) * np.sum(error))

            # Parameter update step
            self.weights -= self.learning_rate * dw
            self.bias -= self.learning_rate * db

    def _predict_raw(self, X: np.ndarray) -> np.ndarray:
        return X @ self.weights + self.bias

    def predict(self, X: np.ndarray) -> np.ndarray:
        """Generate predictions for given feature matrix X."""
        X = np.asarray(X, dtype=np.float64)
        preds = self._predict_raw(X)
        return preds.ravel()


# ==========================================
# Fundamental Evaluation Metrics from Scratch
# ==========================================

def mean_squared_error(y_true: np.ndarray, y_pred: np.ndarray) -> float:
    """MSE = (1 / n) * sum((y_true - y_pred)^2)"""
    return float(np.mean((y_true.ravel() - y_pred.ravel()) ** 2))


def mean_absolute_error(y_true: np.ndarray, y_pred: np.ndarray) -> float:
    """MAE = (1 / n) * sum(|y_true - y_pred|)"""
    return float(np.mean(np.abs(y_true.ravel() - y_pred.ravel())))


def r2_score(y_true: np.ndarray, y_pred: np.ndarray) -> float:
    """
    R^2 = 1 - (SS_res / SS_tot)
    Measures proportion of variance in the dependent variable predictable from features.
    """
    y_true_flat = y_true.ravel()
    y_pred_flat = y_pred.ravel()
    ss_res = np.sum((y_true_flat - y_pred_flat) ** 2)
    ss_tot = np.sum((y_true_flat - np.mean(y_true_flat)) ** 2)
    if ss_tot == 0:
        return 1.0
    return float(1.0 - (ss_res / ss_tot))
