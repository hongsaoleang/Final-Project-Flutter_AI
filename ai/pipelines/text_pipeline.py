"""
MyAI - Text Generation Pipeline
================================
This is your primary module to customize and build how MyAI generates text!

Flow:
Prompt -> Tokenization -> Forward Pass through your Transformer/LLM -> Logits -> Sampling -> Output
"""

import os
import sys
import torch
import torch.nn.functional as F

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from training.trainer import TRAINED_MODELS, TinyLanguageModel


class TextGenerationPipeline:
    """
    CUSTOMIZABLE TEXT GENERATION PIPELINE
    Modify the generate() method below to plug in your own custom models,
    tokenizers, sampling algorithms (Greedy, Top-K, Top-P Nucleus, Temperature).
    """

    def __init__(self, model_checkpoint_path: str = None):
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        self.model = None
        self.char_to_ix = {}
        self.ix_to_char = {}

        if model_checkpoint_path and os.path.exists(model_checkpoint_path):
            self.load_checkpoint(model_checkpoint_path)

    def load_checkpoint(self, path: str):
        """Loads weights from a saved checkpoint."""
        checkpoint = torch.load(path, map_location=self.device)
        self.char_to_ix = checkpoint.get("char_to_ix", {})
        self.ix_to_char = checkpoint.get("ix_to_char", {})
        vocab_size = checkpoint.get("vocab_size", len(self.char_to_ix))

        self.model = TinyLanguageModel(vocab_size=vocab_size)
        self.model.load_state_dict(checkpoint["model_state"])
        self.model.to(self.device)
        self.model.eval()

    def generate(self, prompt: str, max_new_tokens: int = 50, temperature: float = 0.7, top_k: int = 10) -> str:
        """
        *** CUSTOMIZE THIS METHOD ***
        This is where you decide how your AI generates tokens from a prompt.
        """
        # 1. Check if a trained model exists in memory from the Training Studio
        if "tiny_llm" in TRAINED_MODELS:
            info = TRAINED_MODELS["tiny_llm"]
            model = info["model"]
            char_to_ix = info["char_to_ix"]
            ix_to_char = info["ix_to_char"]

            # Tokenize prompt to indices
            tokens = [char_to_ix.get(ch, 0) for ch in prompt]
            if not tokens:
                tokens = [0]
            idx = torch.tensor([tokens], dtype=torch.long, device=self.device)

            model.eval()
            with torch.no_grad():
                for _ in range(max_new_tokens):
                    idx_cond = idx[:, -64:]
                    logits, _ = model(idx_cond)
                    logits = logits[:, -1, :] / max(temperature, 1e-5)

                    # Top-K filtering
                    if top_k > 0 and top_k < logits.size(-1):
                        v, _ = torch.topk(logits, min(top_k, logits.size(-1)))
                        logits[logits < v[:, [-1]]] = -float('Inf')

                    probs = F.softmax(logits, dim=-1)
                    idx_next = torch.multinomial(probs, num_samples=1)
                    idx = torch.cat((idx, idx_next), dim=1)

            generated = "".join([ix_to_char.get(t, "") for t in idx[0].tolist()])
            return generated

        # 2. Default learning response if the model hasn't been trained yet
        return (
            f"[MyAI Engine - Custom Pipeline]:\n"
            f"Prompt received: '{prompt}'.\n"
            f"You can customize this logic directly in `ai/pipelines/text_pipeline.py`. "
            f"Train your model in the 'Train AI' studio to activate your custom Transformer weights!"
        )


# Global singleton instance for your pipeline
pipeline = TextGenerationPipeline()
