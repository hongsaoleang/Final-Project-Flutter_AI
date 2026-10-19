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

        # Specific Place & Travel recommendations with Travel sights, Places to Play, and Recommended Hotels
        travel_catalog = {
            "angkor": {
                "title": "Angkor Wat & Archaeological Park (Siem Reap)",
                "travel": ["Angkor Wat Central Sanctuary", "Bayon Temple Faces", "Ta Prohm Overgrown Ruins", "Banteay Srei Carvings"],
                "play": ["Sunrise hot air balloon flight over Angkor", "Quad bike countryside safari", "Phare Cambodian Circus show", "Angkor Zipline eco-adventure"],
                "hotels": ["Phum Baitang (5★ luxury resort villas)", "Sofitel Angkor Phokeethra Golf & Spa", "Lub d Cambodia Siem Reap (trendy budget boutique)"],
            },
            "phnom penh": {
                "title": "Royal Palace & Riverside Promenade (Phnom Penh)",
                "travel": ["Royal Palace & Silver Pagoda", "National Museum of Cambodia", "Wat Phnom Hill Sanctuary", "Central Market (Phsar Thmey)"],
                "play": ["Mekong & Tonle Sap sunset river cruise", "Street food & rooftop craft beer tasting", "Bassac Lane jazz & nightlife tour", "Mekong Islands cycling excursion"],
                "hotels": ["Rosewood Phnom Penh (5★ ultra-luxury with Sky Bar)", "Plantation Urban Resort & Spa", "Aquarius Hotel & Urban Park"],
            },
            "kampot": {
                "title": "Preah Monivong Bokor National Park & Plateau (Kampot)",
                "travel": ["Old French Palace & Casino ruins", "Wat Sampov Pram cloud cliff", "Lok Yeay Mao Giant Monument", "Popokvil 2-tier Waterfall"],
                "play": ["Kayaking the Green Cathedral loop", "Bokor summit downhill cycling", "La Plantation pepper farm tasting & cooking class", "Evening firefly river cruise"],
                "hotels": ["Thansur Sokha Bokor Hotel (mountaintop luxury)", "Castle Bayview Resort & Spa", "GreenHouse Eco-Lodge (riverfront bungalow)"],
            },
            "battambang": {
                "title": "Norry Bamboo Railway & Bat Caves (Battambang)",
                "travel": ["Phnom Sampeau Bat Caves & Killing Caves", "Wat Ek Phnom 11th-century ruins", "Colonial Heritage Old Quarter", "Wat Banan temple hill"],
                "play": ["Riding the famous Norry Bamboo Train", "Watching millions of bats at dusk from cliffside", "Phare Ponleu Selpak arts school circus workshop", "Sompov Mountain mountain-bike trail"],
                "hotels": ["Bambu Battambang Hotel (boutique colonial)", "Classy Hotel & Spa", "Maisons Wat Kor (authentic Khmer heritage villas)"],
            },
            "sihanoukville": {
                "title": "Saracen Bay Coral Reefs & Koh Rong Sanloem (Preah Sihanouk)",
                "travel": ["Saracen Bay pristine white-sand beach", "Lazy Beach jungle cove", "Clear Water Bay", "Koh Rong Lighthouse viewpoint"],
                "play": ["Night swim with bioluminescent plankton", "Coral reef scuba diving & snorkeling safari", "Stand-up paddleboarding across turquoise lagoons", "Jungle trekking to secluded bays"],
                "hotels": ["The One Resort (Saracen Bay beachfront villas)", "Sol Beach Resort (Khmer-style beachfront)", "Lazy Beach Eco Bungalows"],
            },
            "mondulkiri": {
                "title": "Bou Sra Jungle Cascades & Elephant Valley (Mondulkiri)",
                "travel": ["Bou Sra double-tier giant waterfall", "Doh Kramom Hill panoramic sunset point", "Sea Forest (Samot Chhoeu) canopy lookout", "Bunong Indigenous Cultural Village"],
                "play": ["Ethical elephant watching & river washing at Elephant Valley", "Bou Sra gorge canopy zipline adventure", "Coffee plantation tasting tour", "Pine forest dirt biking trails"],
                "hotels": ["Mayura Hill Resort (luxury hilltop wooden villas)", "Pidoma Resort (infinity pool with jungle valley views)", "Emario Mondulkiri Resort"],
            },
            "kep": {
                "title": "Kep Crab Market & Rabbit Island (Kep)",
                "travel": ["Famous Seaside Kep Crab Market", "Koh Tonsay (Rabbit Island) crescent beaches", "Kep National Park sunset trail", "Vintage French colonial modernist villas"],
                "play": ["Savoring fresh fried crab with green Kampot peppercorns", "Longtail boat day trip to Rabbit Island for beach swimming", "Sunset ocean sailing at Kep Sailing Club", "Hiking the 8km Stairway to Heaven jungle circuit"],
                "hotels": ["Knai Bang Chatt Resort (coastal 5★ barefoot luxury)", "Veranda Natural Resort (hillside wooden eco-treehouses)", "Saravoan Kep Hotel"],
            },
            "ratanakiri": {
                "title": "Yeak Laom Volcanic Crater Lake (Ratanakiri)",
                "travel": ["Yeak Laom 4,000-year-old emerald volcanic crater lake", "Ka Chanh & Cha Ong jungle waterfalls", "Lumphat Wildlife Sanctuary", "Eisey Patamak Buddha Hilltop"],
                "play": ["Swimming in pristine 50m-deep volcanic crater water", "Hiking the 3km protected rainforest ring trail", "Gemstone mining village cultural tour", "Ziplining across Ka Chanh waterfalls"],
                "hotels": ["Yeak Loam Hotel (comfortable lake-adjacent resort)", "Terres Rouges Lodge (charming riverside boutique lodge)", "Ratanakiri Boutique Hotel"],
            },
            "preah vihear": {
                "title": "Preah Vihear Cliff Sanctuary (Preah Vihear)",
                "travel": ["Prasat Preah Vihear UNESCO 525m Dângrêk cliff temple", "Gopura V ornate stone gates", "Peah Vihear cliff-edge panorama over Cambodia plains"],
                "play": ["Thrilling 4x4 pickup truck mountain ascent", "Guided archaeological history tour of Khmer Empire architecture", "Cliffside photography at sunrise above cloud sea", "Bird watching in the Dângrêk natural forest reserve"],
                "hotels": ["Preah Vihear Boutique Hotel (scenic mountain view)", "Sopheak Mongkul Hotel", "Javier Guesthouse (cozy base in Sra'aem)"],
            },
        }

        matched_dest = None
        for key, dest in travel_catalog.items():
            if key in clean_p:
                matched_dest = dest
                break

        if matched_dest:
            return (
                f"🗺️ **Well-Known Destination Spotlight**:\n"
                f"### 📍 {matched_dest['title']}\n\n"
                f"🏛️ **Must-See Places to Travel & Sights**:\n" +
                "\n".join([f"  • {item}" for item in matched_dest['travel']]) +
                f"\n\n🎯 **Exciting Places to Play & Activities**:\n" +
                "\n".join([f"  • {item}" for item in matched_dest['play']]) +
                f"\n\n🏨 **Recommended Hotels & Stays**:\n" +
                "\n".join([f"  • {item}" for item in matched_dest['hotels']]) +
                f"\n\n💡 *Tip: Switch to the Map tab to view the live GPS route, road distance, and step-by-step navigation directly to this place!*"
            )

        if any(w in clean_p for w in ["recommend", "hotel", "play", "travel", "place", "where to go", "tourist", "vacation", "trip", "visit", "destination"]):
            return (
                "🗺️ **Cambodia Well-Known Travel Recommendations**:\n\n"
                "Here are top-tier specific destinations with places to travel, play, and stay:\n\n"
                "1. 🏛️ **Angkor Wat & Archaeological Park (Siem Reap)**\n"
                "   • *Travel*: Angkor Wat Sanctuary, Bayon Face Towers, Ta Prohm Ruins\n"
                "   • *Play*: Sunrise hot air balloon, quad bike countryside safari, Phare Circus\n"
                "   • *Stay*: Phum Baitang (5★ luxury), Sofitel Angkor Golf & Spa, Lub d Siem Reap\n\n"
                "2. 🏛️ **Preah Monivong Bokor Plateau (Kampot)**\n"
                "   • *Travel*: Old French Palace ruins, Popokvil waterfall, Lok Yeay Mao Monument\n"
                "   • *Play*: Green Cathedral river kayaking, downhill mountain biking, pepper farm tasting\n"
                "   • *Stay*: Thansur Sokha Bokor Hotel, GreenHouse Eco-Lodge, Castle Bayview\n\n"
                "3. 🏛️ **Saracen Bay & Koh Rong Sanloem (Preah Sihanouk)**\n"
                "   • *Travel*: Saracen Bay white sands, Lazy Beach, Coral Reefs\n"
                "   • *Play*: Night swimming with glowing bioluminescent plankton, coral reef scuba diving\n"
                "   • *Stay*: The One Resort, Sol Beach Resort, Lazy Beach Eco Bungalows\n\n"
                "4. 🏛️ **Bou Sra Jungle Cascades (Mondulkiri)**\n"
                "   • *Travel*: Bou Sra giant double waterfall, Sea Forest canopy, Bunong village\n"
                "   • *Play*: Ethical elephant washing, gorge canopy zipline, coffee plantation tour\n"
                "   • *Stay*: Mayura Hill Resort, Pidoma Resort, Emario Resort\n\n"
                "5. 🏛️ **Norry Bamboo Railway & Bat Caves (Battambang)**\n"
                "   • *Travel*: Phnom Sampeau Bat Caves, Wat Ek Phnom, Colonial Heritage Quarter\n"
                "   • *Play*: Norry Bamboo Train ride, dusk bat exodus viewing, Phare circus workshop\n"
                "   • *Stay*: Bambu Battambang Hotel, Classy Hotel & Spa, Maisons Wat Kor\n\n"
                "👉 *Ask about any specific landmark or province for in-depth activities, routes, and hotel details!*"
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
