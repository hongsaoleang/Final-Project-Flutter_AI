# MyAI — Phase 1: Machine Learning Fundamentals

## 1. Overview & Context in MyAI

Before building neural networks, transformers, and large multimodal models, we must understand the core principles of **parametric machine learning**:
* How models learn parameters ($w, b$) from empirical observations.
* How loss functions quantify prediction errors.
* How optimization algorithms (Analytical Normal Equations vs. Iterative Gradient Descent) update parameters.
* How evaluation metrics quantify real-world model reliability.

Every linear layer in modern Deep Learning (`nn.Linear`, Transformer Query/Key/Value projection matrices, classification heads) is an extension of **Linear and Logistic Regression**.

---

## 2. Linear Regression from Scratch

### 2.1 What it is & Why we need it
Linear Regression models a continuous target variable $y \in \mathbb{R}$ as a linear combination of input features $x \in \mathbb{R}^d$.

It introduces:
* **Features ($X$)** and **Targets ($y$)**
* **Weights ($w$)** and **Bias ($b$)**
* **Mean Squared Error (MSE)** loss
* The contrast between **Analytical Solutions (OLS)** and **Iterative Optimization (Gradient Descent)**.

### 2.2 Mathematical Formulation

1. **Hypothesis Function (Vectorized)**:
   $$\hat{y} = X w + b$$
   Where $X \in \mathbb{R}^{n \times d}$, $w \in \mathbb{R}^{d \times 1}$, and $b \in \mathbb{R}$.

2. **Cost Function (Mean Squared Error)**:
   $$J(w, b) = \frac{1}{2n} \sum_{i=1}^n (\hat{y}_i - y_i)^2 = \frac{1}{2n} \| Xw + b - y \|_2^2$$

3. **Gradients via Matrix Calculus**:
   $$\frac{\partial J}{\partial w} = \frac{1}{n} X^T (\hat{y} - y)$$
   $$\frac{\partial J}{\partial b} = \frac{1}{n} \sum_{i=1}^n (\hat{y}_i - y_i)$$

4. **Gradient Descent Update Rule**:
   $$w \leftarrow w - \alpha \frac{\partial J}{\partial w}$$
   $$b \leftarrow b - \alpha \frac{\partial J}{\partial b}$$
   Where $\alpha$ is the learning rate.

5. **Analytical Solution (Normal Equation / OLS)**:
   Augmenting $X$ with a column of ones $X_b = [1, X]$:
   $$\theta^* = (X_b^T X_b)^{-1} X_b^T y$$

### 2.3 Evaluation Metrics
* **Mean Squared Error (MSE)**: $\text{MSE} = \frac{1}{n} \sum (\hat{y}_i - y_i)^2$
* **Mean Absolute Error (MAE)**: $\text{MAE} = \frac{1}{n} \sum |\hat{y}_i - y_i|$
* **Coefficient of Determination ($R^2$)**: $R^2 = 1 - \frac{\sum (y_i - \hat{y}_i)^2}{\sum (y_i - \bar{y})^2}$

---

## 3. Logistic Regression & Classification from Scratch

### 3.1 What it is & Why we need it
Linear regression outputs values in $(-\infty, +\infty)$, making it unsuitable for probabilities. Logistic regression wraps the linear combination in a non-linear **Sigmoid ($\sigma$)** activation function, mapping predictions to probabilities $P(y=1|X) \in (0, 1)$.

### 3.2 Mathematical Formulation

1. **Sigmoid Activation Function**:
   $$\sigma(z) = \frac{1}{1 + e^{-z}}$$
   $$\hat{y} = \sigma(X w + b)$$

2. **Binary Cross-Entropy (Log-Loss)**:
   $$J(w, b) = -\frac{1}{n} \sum_{i=1}^n \left[ y_i \ln(\hat{y}_i) + (1 - y_i) \ln(1 - \hat{y}_i) \right]$$

3. **Gradients**:
   Applying the chain rule $\frac{\partial J}{\partial w} = \frac{\partial J}{\partial \hat{y}} \cdot \frac{\partial \hat{y}}{\partial z} \cdot \frac{\partial z}{\partial w}$:
   $$\frac{\partial J}{\partial w} = \frac{1}{n} X^T (\hat{y} - y)$$
   $$\frac{\partial J}{\partial b} = \frac{1}{n} \sum_{i=1}^n (\hat{y}_i - y_i)$$

   > **Crucial Insight:** The gradient equation for Logistic Regression with Cross-Entropy has the identical algebraic structure as Linear Regression with MSE! This mathematical synergy is why Cross-Entropy is standard for classification in neural networks.

### 3.3 Classification Metrics
* **Confusion Matrix**: True Positives (TP), False Positives (FP), True Negatives (TN), False Negatives (FN).
* **Accuracy**: $\frac{TP + TN}{TP + TN + FP + FN}$
* **Precision**: $\frac{TP}{TP + FP}$ (Quality of positive predictions)
* **Recall / Sensitivity**: $\frac{TP}{TP + FN}$ (Coverage of actual positive samples)
* **F1-Score**: $2 \cdot \frac{\text{Precision} \cdot \text{Recall}}{\text{Precision} + \text{Recall}}$ (Harmonic mean)

---

## 4. Experimental Results

### Linear Regression (`ai/training/train_linear_regression.py`)
* **Ground Truth Formula**: $y = 3.5 x_1 - 1.8 x_2 + 4.2 + \epsilon$
* **Learned via Gradient Descent**: $w_1 = 3.5073, w_2 = -1.7888, b = 4.2349$
* **Learned via Normal Equation**: $w_1 = 3.5073, w_2 = -1.7888, b = 4.2349$
* **Test MSE**: `0.2578` | **$R^2$ Score**: `0.9952` (99.52% variance explained)

### Logistic Regression (`ai/training/train_logistic_regression.py`)
* **Initial Loss (Epoch 0)**: `0.6931` ($-\ln(0.5)$)
* **Final Loss (Epoch 999)**: `0.0464`
* **Test Accuracy**: `98.00%`
* **Precision**: `96.30%` | **Recall**: `100.00%` | **F1-Score**: `0.9811`

---

## 5. Connection to the Larger MyAI Platform

1. **Neurons**: A single artificial neuron is precisely a logistic regression unit (linear projection + activation).
2. **Multi-Class / Softmax**: In Phase 2 & 3, we generalize Sigmoid to Softmax across $K$ classes:
   $$\text{Softmax}(z)_i = \frac{e^{z_i}}{\sum_j e^{z_j}}$$
   This powers language model next-token prediction heads.
3. **Deep Learning**: Stacking multiple linear transformations separated by non-linear activations forms Multi-Layer Perceptrons (MLPs), which are the building blocks of Transformer Feed-Forward Networks (FFNs).
