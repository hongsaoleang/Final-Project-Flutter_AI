"""
MyAI - Step 3: Neural Network from Scratch using NumPy
Demonstrating fundamental ML math: matrix multiplications, activations (ReLU, Softmax),
cross-entropy loss, and backpropagation.
"""

import numpy as np


class DenseLayer:
    def __init__(self, input_dim: int, output_dim: int):
        # He / Xavier initialization
        self.weights = np.random.randn(input_dim, output_dim) * np.sqrt(2.0 / input_dim)
        self.biases = np.zeros((1, output_dim))
        self.inputs = None
        self.dweights = None
        self.dbiases = None

    def forward(self, inputs: np.ndarray) -> np.ndarray:
        self.inputs = inputs
        return np.dot(inputs, self.weights) + self.biases

    def backward(self, dvalues: np.ndarray, learning_rate: float = 0.01) -> np.ndarray:
        self.dweights = np.dot(self.inputs.T, dvalues)
        self.dbiases = np.sum(dvalues, axis=0, keepdims=True)
        dinputs = np.dot(dvalues, self.weights.T)

        # SGD parameter update
        self.weights -= learning_rate * self.dweights
        self.biases -= learning_rate * self.dbiases
        return dinputs


class ActivationReLU:
    def forward(self, inputs: np.ndarray) -> np.ndarray:
        self.inputs = inputs
        return np.maximum(0, inputs)

    def backward(self, dvalues: np.ndarray) -> np.ndarray:
        dinputs = dvalues.copy()
        dinputs[self.inputs <= 0] = 0
        return dinputs


class ActivationSoftmax:
    def forward(self, inputs: np.ndarray) -> np.ndarray:
        exp_values = np.exp(inputs - np.max(inputs, axis=-1, keepdims=True))
        self.output = exp_values / np.sum(exp_values, axis=-1, keepdims=True)
        return self.output


class LossCategoricalCrossEntropy:
    def forward(self, y_pred: np.ndarray, y_true: np.ndarray) -> float:
        samples = len(y_pred)
        y_pred_clipped = np.clip(y_pred, 1e-7, 1.0 - 1e-7)

        if len(y_true.shape) == 1:
            correct_confidences = y_pred_clipped[range(samples), y_true]
        else:
            correct_confidences = np.sum(y_pred_clipped * y_true, axis=1)

        negative_log_likelihoods = -np.log(correct_confidences)
        return float(np.mean(negative_log_likelihoods))

    def backward(self, dvalues: np.ndarray, y_true: np.ndarray) -> np.ndarray:
        samples = len(dvalues)
        dinputs = dvalues.copy()
        if len(y_true.shape) == 1:
            dinputs[range(samples), y_true] -= 1
        else:
            dinputs -= y_true
        return dinputs / samples


class ScratchNeuralNetwork:
    """A Multi-Layer Perceptron built strictly from scratch with NumPy."""
    def __init__(self, input_dim: int, hidden_dim: int, output_dim: int):
        self.layer1 = DenseLayer(input_dim, hidden_dim)
        self.relu = ActivationReLU()
        self.layer2 = DenseLayer(hidden_dim, output_dim)
        self.softmax = ActivationSoftmax()
        self.loss_fn = LossCategoricalCrossEntropy()

    def forward(self, x: np.ndarray) -> np.ndarray:
        z1 = self.layer1.forward(x)
        a1 = self.relu.forward(z1)
        z2 = self.layer2.forward(a1)
        return self.softmax.forward(z2)

    def train_step(self, x: np.ndarray, y: np.ndarray, lr: float = 0.05) -> float:
        probs = self.forward(x)
        loss = self.loss_fn.forward(probs, y)

        # Backpropagation
        dloss = self.loss_fn.backward(probs, y)
        dz2 = self.layer2.backward(dloss, learning_rate=lr)
        da1 = self.relu.backward(dz2)
        self.layer1.backward(da1, learning_rate=lr)
        return loss
