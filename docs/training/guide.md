# MyAI Training & Fine-Tuning Guide

This guide covers everything you need to know about training, fine-tuning, and evaluating models in the **MyAI** platform.

---

## 1. Overview of Trainable Models

| Model Architecture | Task | Input Format | Output | Default Checkpoint |
| :--- | :--- | :--- | :--- | :--- |
| **NeuralNetworkClassifier** | Tabular multi-class classification | Numerical feature array (e.g. 4 features) | Class probabilities | `ai/models/checkpoints/classifier.pt` |
| **TinyLanguageModel** | Autoregressive character/subword LM | Text strings / token ID sequences | Next-token text generation | `ai/models/checkpoints/tiny_llm.pt` |
| **Linear Regression** | Continuous value regression | Numerical feature vector | Single scalar prediction | In-memory / weights array |
| **Logistic Regression** | Binary classification | Numerical feature vector | Probability in [0, 1] | In-memory / weights array |

---

## 2. Dataset Preparation

### Tabular Classification (`ai/data/raw/classification_data.csv`)
CSV with comma-separated features and an integer `label` column:
```csv
f1,f2,f3,f4,label
5.1,3.5,1.4,0.2,0
4.9,3.0,1.4,0.2,0
7.0,3.2,4.7,1.4,1
6.3,3.3,6.0,2.5,2
```

### Text Corpus (`ai/data/raw/corpus.txt`)
Plain UTF-8 text file. The tokenizer builds character-level or subword vocabularies automatically:
```text
Artificial intelligence is the intelligence of machines...
```

To tokenize and generate pre-processed sequences:
```bash
python ai/scripts/download_data.py
```

---

## 3. Training via Command Line Interface (CLI)

You can launch standalone training jobs using the helper script:

```bash
# Train Neural Network Classifier
python ai/scripts/train.py --model classifier --epochs 50 --batch_size 16 --lr 0.01

# Train Tiny Language Model (Causal Transformer)
python ai/scripts/train.py --model tiny_llm --epochs 30 --batch_size 8 --lr 0.003
```

### Hyperparameters:
- `--epochs`: Number of complete passes over the training dataset (default: 20).
- `--batch_size`: Mini-batch size for gradient descent (default: 16).
- `--lr`: Learning rate for Adam/SGD optimizer (default: 0.001).
- `--device`: Target execution device (`cpu` or `cuda` if an NVIDIA GPU is available).

---

## 4. Training via REST API & Backend Orchestrator

The system provides asynchronous background training managed through Spring Boot and executed by the Python engine.

### Step 1: Trigger Training Job
Send a POST request to Spring Boot:
```http
POST http://localhost:8080/api/v1/ai/train
Content-Type: application/json

{
  "modelType": "tiny_llm",
  "epochs": 25,
  "batchSize": 8,
  "learningRate": 0.002
}
```

Response:
```json
{
  "jobId": "job-d4a8e2",
  "status": "RUNNING",
  "modelType": "tiny_llm",
  "epochs": 25,
  "currentEpoch": 0,
  "progress": 0.0,
  "message": "Training job dispatched to Python AI engine"
}
```

### Step 2: Poll Training Status
```http
GET http://localhost:8080/api/v1/ai/train/status/job-d4a8e2
```

---

## 5. Training via Flutter UI

1. Launch the Flutter app (`flutter run -d chrome` or desktop/mobile).
2. Open the sidebar and navigate to **Training Studio** (Brain icon).
3. Select the model architecture (**Neural Network Classifier** or **Tiny Language Model**).
4. Adjust the **Epochs**, **Batch Size**, and **Learning Rate** sliders.
5. Click **Start Training Job**.
6. Monitor live progress, loss curves, and epoch counters in real-time.
7. Once finished, click **Test Model** to send real-time inference requests to your newly trained checkpoint.

---

## 6. Evaluating Model Performance

Run the evaluation script to compute metrics (Loss, Accuracy, R^2):

```bash
# Evaluate Classifier
python ai/scripts/evaluate.py --model classifier

# Evaluate Tiny Language Model
python ai/scripts/evaluate.py --model tiny_llm
```
