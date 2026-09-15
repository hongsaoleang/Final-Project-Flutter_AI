# MyAI — Personal Multimodal AI Platform

**MyAI** is a personal AI project designed to build and understand an intelligent multimodal AI system from the ground up. The project aims to combine multiple AI capabilities into a single platform, including text generation, image generation, image understanding, OCR, image-to-text, text-to-image, and eventually audio and other multimodal capabilities.

The main purpose of this project is not simply to use existing AI APIs, but to learn how modern AI systems work internally and progressively build, train, evaluate, fine-tune, and deploy AI models.

---

## Project Goals

The project follows a progressive learning and development approach:

1. Learn the fundamentals of Machine Learning.
2. Understand the mathematics and optimization algorithms behind AI.
3. Build neural networks from scratch using NumPy.
4. Learn PyTorch and use it to train more advanced models.
5. Study Deep Learning architectures.
6. Understand Attention mechanisms.
7. Build Transformer architectures.
8. Build and train a small Language Model from scratch.
9. Learn fine-tuning and LLM engineering.
10. Deploy AI models as real-world services.

---

## AI Capabilities

The long-term goal is for MyAI to support several types of input and output:

### 1. Text Generation
The system should be able to understand a user's text prompt and generate an appropriate text response.

* **Example:**
  * **User:** "Explain how a computer network works."
  * **MyAI:** "A computer network is a system that allows devices to communicate and share resources..."

### 2. Text-to-Image
The system should be able to generate an image from a natural-language description.

* **Example:** "Generate an image of a futuristic city in Cambodia at night."
* The AI processes the text prompt and generates an image based on the description.

### 3. Image-to-Text
The system should be able to analyze an image and generate a textual description.

* **Example:**
  * **Input:** An image containing a person riding a bicycle.
  * **Output:** "The image shows a person riding a bicycle on a road."

### 4. Image-to-Text with OCR
The system should be able to scan images containing text and convert the visual text into machine-readable text.

* **Example:**
  * **Input:** Photograph of a document.
  * **Output:** The recognized text from the document.
* The OCR pipeline includes image preprocessing, text detection, text recognition, and postprocessing.

### 5. Image Understanding
The system should eventually be able to answer questions about an uploaded image.

* **Example:**
  * **User:** "What objects are visible in this image?"
  * **MyAI:** "The image contains a laptop, a mobile phone, a cup, and a notebook."

### 6. Image-to-Image
The system should eventually support image transformation and editing.

* **Example:** "Convert this image into a watercolor style."
* The system receives the original image and generates a modified version according to the user's instruction.

---

## System Architecture

MyAI is designed as a multi-component AI platform rather than one enormous model:

```text
                    MyAI Platform
                         │
                         ▼
                  AI Orchestrator
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
     Text AI         Vision AI        Image AI
        │                │                │
        ▼                ▼                ▼
       LLM              VLM        Image Generator
                         │
                         ▼
                        OCR
```

Each component can be developed, trained, evaluated, and improved independently.

---

## Technology Stack

### AI / Machine Learning (`ai/`)
* **Language & Core:** Python, NumPy, Pandas, Matplotlib
* **Deep Learning Framework:** PyTorch, Torchvision, Torchaudio
* **Architectures:** Transformers, Custom Neural Networks, Vision Models (VLM/CNN/ViT), OCR Pipelines
* **Deployment / Serving:** FastAPI, Uvicorn

### Backend (`backend_ai/ai/`)
* **Framework:** Java 17+, Spring Boot 4.x / 3.x, Spring Web MVC, Spring Data JPA
* **Security:** Spring Security
* **Database:** PostgreSQL (user: `user`)
* **Containerization:** Docker & Docker Compose

### Frontend (`frontend_ai/ai_app/`)
* **Framework:** Flutter & Dart
* **Platforms:** Mobile (Android/iOS), Desktop, Web

---

## Project Architecture

```text
                    Flutter Application
                           │
                           │ REST API
                           ▼
                    Spring Boot Backend
                           │
                           ▼
                    AI Orchestrator
                           │
          ┌────────────────┼─────────────────┐
          │                │                 │
          ▼                ▼                 ▼
      Text Model       Vision Model     Image Model
          │                │                 │
          ▼                ▼                 ▼
    Text Generation    Image Analysis   Image Generation
                           │
                           ▼
                          OCR
                           │
                           ▼
                     Text Extraction
```

---

## Database Configuration

* **Database Engine:** PostgreSQL
* **Username:** `user`
* **Password:** `leang30122006`
* **Default Database:** `myai_db`
* **Default Port:** `5432`

---

## Development Philosophy

MyAI will be developed progressively:

```text
Machine Learning
       ↓
Mathematics
       ↓
Optimization
       ↓
Neural Networks
       ↓
PyTorch
       ↓
Deep Learning
       ↓
Attention
       ↓
Transformers
       ↓
Tiny LLM
       ↓
Fine-Tuning
       ↓
Multimodal AI
       ↓
AI Application
       ↓
Deployment
```

---

## Long-Term Vision

```text
                 ┌───────────────┐
                 │     MyAI      │
                 └───────┬───────┘
                         │
        ┌────────────────┼─────────────────┐
        │                │                 │
        ▼                ▼                 ▼
       Text            Images            Audio
        │                │                 │
        ▼                ▼                 ▼
   Generation         Vision            Speech
        │                │                 │
        └────────────────┼─────────────────┘
                         │
                         ▼
                   Multimodal AI
```

Future capabilities include:
* Text generation
* Image generation
* Image understanding & OCR
* Speech-to-text & Text-to-speech
* Audio & Video understanding
* Retrieval-Augmented Generation (RAG)
* Autonomous AI agents & Tool calling
* Multimodal conversations
