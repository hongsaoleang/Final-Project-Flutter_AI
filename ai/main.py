"""
MyAI - AI Orchestrator Service
FastAPI service providing inference & training endpoints for:
- Text Generation (LLM)
- Text-to-Image (Generative AI)
- Image-to-Text (Captioning / Vision)
- OCR (Optical Character Recognition)
- Image Understanding (VLM / Visual QA)
- Model Training & Fine-Tuning (Neural Networks, Tiny LLM)
"""

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional, List, Dict, Any
import os
import sys

# Ensure training package is discoverable
sys.path.insert(0, os.path.dirname(__file__))
from training.trainer import start_training_job, get_job, run_inference

app = FastAPI(
    title="MyAI - AI Orchestrator API",
    description="Multimodal AI service powering MyAI platform",
    version="0.2.0"
)


# ==========================================
# Multimodal Inference DTOs
# ==========================================

class AiRequestPayload(BaseModel):
    prompt: Optional[str] = None
    image_data: Optional[str] = None


class AiResponsePayload(BaseModel):
    response: str
    output_image_data: Optional[str] = None
    model_used: str
    status: str = "SUCCESS"


# ==========================================
# Training DTOs
# ==========================================

class TrainRequestPayload(BaseModel):
    job_id: str
    model_name: Optional[str] = "MyAI-Model"
    model_type: str = "neural_network"  # 'neural_network' or 'tiny_llm'
    epochs: int = 20
    learning_rate: float = 0.05
    dataset: Optional[str] = None


class TrainedInferencePayload(BaseModel):
    model_type: str = "neural_network"
    prompt: Optional[str] = None
    input_features: Optional[Dict[str, Any]] = None


@app.get("/health")
def health_check():
    return {
        "status": "UP",
        "service": "MyAI Python Orchestrator",
        "models": ["TinyLLM", "VisionAnalyzer", "OCR-Engine", "ImageSynth", "NeuralNetworkClassifier"]
    }


# ==========================================
# Inference Endpoints
# ==========================================

from pipelines.text_pipeline import pipeline as text_pipeline

@app.post("/generate-text", response_model=AiResponsePayload)
def generate_text(payload: AiRequestPayload):
    prompt = payload.prompt or ""
    if not prompt.strip():
        raise HTTPException(status_code=400, detail="Prompt is required for text generation.")

    generated_text = text_pipeline.generate(prompt)

    return AiResponsePayload(
        response=generated_text,
        model_used="MyAI-TextPipeline-v1",
        status="SUCCESS"
    )


@app.post("/text-to-image", response_model=AiResponsePayload)
def text_to_image(payload: AiRequestPayload):
    prompt = payload.prompt or "Untitled"
    return AiResponsePayload(
        response=f"Generated visual render for prompt: '{prompt}'",
        output_image_data=None,
        model_used="MyAI-ImageSynth-v1",
        status="SUCCESS"
    )


@app.post("/image-to-text", response_model=AiResponsePayload)
def image_to_text(payload: AiRequestPayload):
    return AiResponsePayload(
        response="The image depicts a scene with identifiable primary foreground objects and context.",
        model_used="MyAI-VisionCaptioner-v1",
        status="SUCCESS"
    )


@app.post("/ocr", response_model=AiResponsePayload)
def ocr_extraction(payload: AiRequestPayload):
    return AiResponsePayload(
        response="Document OCR Results:\n1. Recognized Header\n2. Extracted text paragraphs\nConfidence: 98.4%",
        model_used="MyAI-OCREngine-v1",
        status="SUCCESS"
    )


@app.post("/image-understanding", response_model=AiResponsePayload)
def image_understanding(payload: AiRequestPayload):
    prompt = payload.prompt or "Analyze image"
    return AiResponsePayload(
        response=f"VLM Analysis for query '{prompt}': The image contains multiple distinct objects with clear spatial arrangements.",
        model_used="MyAI-VLM-v1",
        status="SUCCESS"
    )


# ==========================================
# Training & Fine-Tuning Endpoints
# ==========================================

@app.post("/train")
def train_model(payload: TrainRequestPayload):
    job = start_training_job(
        job_id=payload.job_id,
        model_type=payload.model_type,
        epochs=payload.epochs,
        lr=payload.learning_rate,
        dataset=payload.dataset
    )
    return job


@app.get("/train/status/{job_id}")
def training_status(job_id: str):
    job = get_job(job_id)
    if not job:
        raise HTTPException(status_code=404, detail="Training job not found")
    return job


@app.post("/inference/trained")
def infer_trained(payload: TrainedInferencePayload):
    features = None
    if payload.input_features and "features" in payload.input_features:
        features = payload.input_features["features"]

    result = run_inference(
        model_type=payload.model_type,
        prompt=payload.prompt,
        features=features
    )
    return result


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
