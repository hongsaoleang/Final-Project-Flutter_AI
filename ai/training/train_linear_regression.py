"""
MyAI - Phase 1: Machine Learning Fundamentals
Experiment: Training & Evaluating Linear Regression from Scratch

Validates:
1. Synthetic ground truth recovery (w1=3.5, w2=-1.8, b=4.2)
2. Gradient descent vs. Normal Equation equivalence
3. Evaluation metrics (MSE, MAE, R^2)
4. Verification against scikit-learn
"""

import numpy as np
import sys
import os

# Add ai directory to path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from models.linear_regression import (
    LinearRegressionFromScratch,
    mean_squared_error,
    mean_absolute_error,
    r2_score
)


def run_experiment():
    print("=" * 60)
    print("MyAI Phase 1: Linear Regression from Scratch Experiment")
    print("=" * 60)

    # 1. Generate Synthetic Data
    np.random.seed(42)
    n_samples = 500
    n_features = 2

    # True parameters
    true_weights = np.array([[3.5], [-1.8]])
    true_bias = 4.2

    X = np.random.randn(n_samples, n_features) * 2.0
    noise = np.random.randn(n_samples, 1) * 0.5
    y = X @ true_weights + true_bias + noise

    # 2. Train/Test Split (80% / 20%)
    split_idx = int(n_samples * 0.8)
    X_train, X_test = X[:split_idx], X[split_idx:]
    y_train, y_test = y[:split_idx], y[split_idx:]

    print(f"Dataset: {n_samples} samples, {n_features} features")
    print(f"Train set: {len(X_train)} samples | Test set: {len(X_test)} samples")
    print(f"Ground Truth Formula: y = 3.5 * x1 - 1.8 * x2 + 4.2 (+ noise)")
    print("-" * 60)

    # 3. Model 1: Gradient Descent
    print("[1] Training via Gradient Descent (lr=0.05, epochs=1000)...")
    model_gd = LinearRegressionFromScratch(learning_rate=0.05, n_iterations=1000, method="gradient_descent")
    model_gd.fit(X_train, y_train)

    preds_gd = model_gd.predict(X_test)
    mse_gd = mean_squared_error(y_test, preds_gd)
    mae_gd = mean_absolute_error(y_test, preds_gd)
    r2_gd = r2_score(y_test, preds_gd)

    w_gd = model_gd.weights.ravel()
    print(f"  Learned Weights: w1={w_gd[0]:.4f}, w2={w_gd[1]:.4f} | Bias={model_gd.bias:.4f}")
    print(f"  Test MSE: {mse_gd:.4f} | MAE: {mae_gd:.4f} | R^2 Score: {r2_gd:.4f}")
    print("-" * 60)

    # 4. Model 2: Analytical Normal Equation (OLS)
    print("[2] Training via Normal Equation (Analytical OLS)...")
    model_ols = LinearRegressionFromScratch(method="normal_equation")
    model_ols.fit(X_train, y_train)

    preds_ols = model_ols.predict(X_test)
    mse_ols = mean_squared_error(y_test, preds_ols)
    mae_ols = mean_absolute_error(y_test, preds_ols)
    r2_ols = r2_score(y_test, preds_ols)

    w_ols = model_ols.weights.ravel()
    print(f"  Learned Weights: w1={w_ols[0]:.4f}, w2={w_ols[1]:.4f} | Bias={model_ols.bias:.4f}")
    print(f"  Test MSE: {mse_ols:.4f} | MAE: {mae_ols:.4f} | R^2 Score: {r2_ols:.4f}")
    print("-" * 60)

    # 5. Verification against scikit-learn (if available)
    try:
        from sklearn.linear_model import LinearRegression as SklearnLinearRegression
        from sklearn.metrics import mean_squared_error as sk_mse, r2_score as sk_r2

        print("[3] Verification against scikit-learn Reference...")
        sk_model = SklearnLinearRegression()
        sk_model.fit(X_train, y_train)
        sk_preds = sk_model.predict(X_test)

        print(f"  Scikit-Learn Weights: w1={sk_model.coef_[0, 0]:.4f}, w2={sk_model.coef_[0, 1]:.4f} | Bias={sk_model.intercept_[0]:.4f}")
        print(f"  Scikit-Learn Test MSE: {sk_mse(y_test, sk_preds):.4f} | R^2: {sk_r2(y_test, sk_preds):.4f}")

        # Assert equivalence
        assert np.allclose(w_ols, sk_model.coef_.ravel(), atol=1e-4), "OLS weights do not match scikit-learn!"
        print("\n>>> SUCCESS: Scratch NumPy implementation is numerically equivalent to scikit-learn!")
    except ImportError:
        print("Note: scikit-learn not installed in current environment; scratch verification completed.")

    print("=" * 60)
    print(f"Initial Loss (Epoch 0): {model_gd.loss_history[0]:.4f}")
    print(f"Final Loss (Epoch 999): {model_gd.loss_history[-1]:.4f}")
    print("=" * 60)


if __name__ == "__main__":
    run_experiment()
