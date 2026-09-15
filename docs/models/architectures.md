# MyAI Model Architectures & Mathematical Foundations

## 1. Linear & Logistic Regression
- **Linear**: $\hat{y} = X w + b$, optimized with MSE: $J = \frac{1}{2n}\|Xw + b - y\|^2$.
- **Logistic**: $\hat{y} = \sigma(Xw + b)$, optimized with Binary Cross-Entropy.

## 2. Multi-Layer Perceptron (MLP)
- Built from scratch in NumPy (`ai/models/neural_network.py`) and PyTorch (`ai/training/trainer.py`).
- Linear projection -> ReLU -> Linear projection -> Softmax -> Cross-Entropy.
- Trained using backpropagation and Adam optimizer.

## 3. Tiny Language Model (Causal Transformer)
- Architecture:
  - Token Embedding + Learned Positional Embedding
  - $N$ Transformer Blocks with **Causal Multi-Head Self-Attention**
  - Layer Normalization + Feed-Forward Network (GELU/ReLU)
  - Linear Language Model Head
- Causal Masking ensures token $t$ attends only to tokens $\le t$.
