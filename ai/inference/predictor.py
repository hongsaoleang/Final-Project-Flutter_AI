"""
MyAI - Inference Router Module
Handles model loading, forward-pass execution, and result formatting.
"""

from typing import Dict, Any, Optional
import os
import sys

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from training.trainer import run_inference


class ModelPredictor:
    """Dispatches inference requests to active trained models or checkpoints."""

    @staticmethod
    def predict(model_type: str, prompt: Optional[str] = None, features: Optional[list] = None) -> Dict[str, Any]:
        return run_inference(model_type=model_type, prompt=prompt, features=features)
