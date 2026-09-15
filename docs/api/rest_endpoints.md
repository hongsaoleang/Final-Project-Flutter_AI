# MyAI REST API Specifications

Base URL: `http://localhost:8080/api/v1`

## AI Inference
- `POST /ai/generate-text` — Autoregressive text generation
- `POST /ai/text-to-image` — Text-to-image synthesis
- `POST /ai/image-to-text` — Image captioning
- `POST /ai/ocr` — Optical character recognition
- `POST /ai/image-understanding` — Visual QA
- `GET /ai/health` — Service health check

## AI Model Training
- `POST /ai/train` — Start training job (`modelType`, `epochs`, `learningRate`)
- `GET /ai/train/status/{jobId}` — Poll live training progress & loss curve
- `GET /ai/train/jobs` — List past training runs from PostgreSQL
- `POST /ai/infer-trained` — Run inference using trained checkpoint

## Conversation Management
- `GET /conversations` — List all user conversations
- `POST /conversations` — Create a new conversation session
- `GET /conversations/{uuid}/messages` — Get conversation message history
- `DELETE /conversations/{uuid}` — Delete conversation

## File Management
- `POST /files/upload` — Multipart document or image upload
- `GET /files/{uuid}` — Retrieve file metadata
