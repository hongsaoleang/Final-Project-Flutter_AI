"""
MyAI - Evaluation & Metrics Module
Provides standardized evaluation calculations for regression, classification, and language models.
"""

import numpy as np
from typing import Dict, Any


def evaluate_regression(y_true: np.ndarray, y_pred: np.ndarray) -> Dict[str, float]:
    y_true_f = y_true.ravel()
    y_pred_f = y_pred.ravel()
    mse = float(np.mean((y_true_f - y_pred_f) ** 2))
    mae = float(np.mean(np.abs(y_true_f - y_pred_f)))
    ss_tot = float(np.sum((y_true_f - np.mean(y_true_f)) ** 2))
    r2 = float(1.0 - (np.sum((y_true_f - y_pred_f) ** 2) / ss_tot)) if ss_tot != 0 else 1.0
    return {"mse": round(mse, 4), "mae": round(mae, 4), "r2_score": round(r2, 4)}


def evaluate_classification(y_true: np.ndarray, y_pred: np.ndarray) -> Dict[str, Any]:
    y_t = y_true.ravel().astype(int)
    y_p = y_pred.ravel().astype(int)
    accuracy = float(np.mean(y_t == y_p))
    return {"accuracy": round(accuracy * 100, 2), "total_samples": len(y_t)}
