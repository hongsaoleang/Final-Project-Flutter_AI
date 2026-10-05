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

        # 2. Intelligent conversational & travel assistant engine when model is not yet trained
        clean_p = prompt.strip().lower()

        # Name & Identity
        if any(w in clean_p for w in ["your name", "what is your name", "who are you", "what are you called", "what's your name"]):
            return (
                "👋 My name is **MyAI**!\n\n"
                "I am your personal AI Assistant, Travel & Navigation Companion. "
                "You can ask me anything you want—from directions, travel routes, and famous landmarks, to general questions, advice, and tips!"
            )

        # Greetings
        if clean_p in ["hi", "hello", "hey", "good morning", "good afternoon", "good evening", "howdy", "sup", "yo"]:
            return (
                "👋 Hello! I am your AI Assistant & Travel Guide.\n\n"
                "How can I help you today? You can ask me:\n"
                "• Any question you'd like to ask\n"
                "• Where you want to go (e.g. 'Take me to Angkor Wat')\n"
                "• Local travel tips, food recommendations, and landmarks\n"
                "• Or switch to the Map tab to view interactive live routes!"
            )

        # Well-being / Chat
        if any(w in clean_p for w in ["how are you", "how are you doing", "how's it going", "how are u"]):
            return (
                "😊 I'm doing great, thank you for asking! How are you doing today?\n\n"
                "Feel free to ask me whatever is on your mind, whether it's travel, destinations, or any question you have!"
            )

        # Gratitude
        if any(w in clean_p for w in ["thank", "thanks", "thank you", "appreciate"]):
            return "🙏 You're very welcome! Let me know if there's anything else you need help with."

        # Capabilities
        if any(w in clean_p for w in ["what can you do", "help me", "features"]):
            return (
                "🤖 I am your versatile AI Companion! Here is what I can do for you:\n\n"
                "1. 💬 **Answer Any Question**: Ask whatever you want—general questions, facts, or travel advice.\n"
                "2. 🗺️ **Map & Navigation Guidance**: Plot live routes, calculate distances, and give turn-by-turn guidance.\n"
                "3. 📷 **Landmark & Place Scanner**: Upload or snap a picture of any landmark to identify it instantly.\n"
                "4. 📍 **Location Sharing**: Share your live GPS location or coordinates with friends."
            )

        # Place recommendations & queries
        if any(w in clean_p for w in ["siem reap", "angkor", "wat phnom", "phnom penh", "kampot", "sihanoukville", "aeon", "beach", "temple", "museum", "market"]):
            return (
                f"🗺️ AI Travel Insights for '{prompt}':\n\n"
                "• **Overview**: One of the most sought-after destinations in the region with rich cultural heritage and scenic views.\n"
                "• **Navigation Tip**: Check the **Map Guide** screen to see the optimal polyline route from your current location or home base with live ETA.\n"
                "• **Best Time to Visit**: Early mornings (6:00 AM - 9:00 AM) or late afternoons (4:30 PM - 6:30 PM) offer cooler weather and beautiful lighting.\n"
                "• **Recommended Mode**: Driving or tuk-tuk for city distances; walking for temple and market grounds."
            )

        # Route requests like "go to", "guide to", "how to get to"
        if any(w in clean_p for w in ["go to", "guide", "route", "direction", "how to get", "travel to", "drive to", "walk to"]):
            return (
                f"🧭 AI Navigation Assistant:\n\n"
                f"I've mapped out guidance for: **{prompt}**\n\n"
                "• **Departure**: Your current GPS / living home base.\n"
                "• **Live Route Available**: Head over to the **Map Guide** tab where the polyline route, precise road distances, and step-by-step turn guidance are already plotted for you.\n"
                "• **Safety Tip**: Always maintain road awareness, avoid peak congestion hours (7:30 - 8:30 AM & 5:00 - 6:30 PM), and stay hydrated."
            )

        # General conversational response
        return (
            f"💡 AI Travel Guide:\n\n"
            f"Regarding your query: \"{prompt}\"\n\n"
            "I'm ready to assist with your journey! Ask me about specific destinations (like Angkor Wat, Phnom Penh, Kampot, or local restaurants), or use the Map Guide tab for live directions and GPS navigation."
        )


# Global singleton instance for your pipeline
pipeline = TextGenerationPipeline()
