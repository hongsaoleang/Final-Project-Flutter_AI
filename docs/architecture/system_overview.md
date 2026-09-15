# MyAI Architecture & System Overview

MyAI is an integrated multimodal artificial intelligence platform combining language modeling, computer vision, OCR, and image generation.

## 1. High-Level Topology

```text
┌──────────────────────────────────────────┐
│             Flutter Frontend             │
│  (Chat, Training Studio, History, Config)│
└────────────────────┬─────────────────────┘
                     │ REST API
                     ▼
┌──────────────────────────────────────────┐
│           Spring Boot Backend            │
│ (Auth, Orchestration, Validation, Storage│
└────────────┬──────────────────┬──────────┘
             │                  │
             │ HTTP             │ PostgreSQL (5433)
             ▼                  ▼
┌────────────────────────┐  ┌──────────────┐
│    Python AI Engine    │  │  myai_db     │
│ (PyTorch, FastAPI,     │  │              │
│  Checkpoints, ML)      │  └──────────────┘
└────────────────────────┘
```

## 2. Responsibilities
- **Frontend (Flutter)**: User interaction, real-time metrics display, image uploads.
- **Backend (Spring Boot)**: Persistence, session tracking, job management.
- **AI Service (FastAPI / PyTorch)**: Autoregressive text generation, model training, computer vision inference.
- **Database (PostgreSQL)**: Stores conversation history, training progress, and file metadata.
