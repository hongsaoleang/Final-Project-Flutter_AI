"""
MyAI - Multimodal Orchestration Pipeline
=========================================
Unified pipeline integrating Text, Vision, OCR, and Image Generation.
"""

from typing import Dict, Any, Optional
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from text_pipeline import pipeline as text_pipe
from vision_pipeline import vision_pipeline
from ocr_pipeline import ocr_pipeline
from image_pipeline import image_pipeline


class MultimodalPipeline:
    """Central orchestrator determining which modality sub-pipeline to invoke."""

    def route_request(self, modality: str, prompt: Optional[str] = None, image_data: Optional[str] = None) -> Dict[str, Any]:
        if modality == "text_generation":
            out = text_pipe.generate(prompt or "")
            return {"modality": "text", "output": out}
        elif modality == "text_to_image":
            return image_pipeline.generate_from_text(prompt or "")
        elif modality == "image_to_text":
            return vision_pipeline.describe_image(image_data or "")
        elif modality == "ocr":
            return ocr_pipeline.extract_text(image_data or "")
        elif modality == "image_understanding":
            return vision_pipeline.answer_visual_question(image_data or "", prompt or "")
        else:
            return {"error": f"Unknown modality: {modality}"}


multimodal_orchestrator = MultimodalPipeline()
