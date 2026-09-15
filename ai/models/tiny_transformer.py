"""
MyAI - Step 6 & 7: Attention Mechanism and Transformer Architecture
Built with PyTorch / standard Python to illustrate scaled dot-product attention,
multi-head attention, positional encoding, and feed-forward networks.
"""

import math
try:
    import torch
    import torch.nn as nn
    import torch.nn.functional as F
    TORCH_AVAILABLE = True
except ImportError:
    TORCH_AVAILABLE = False


if TORCH_AVAILABLE:
    class ScaledDotProductAttention(nn.Module):
        def __init__(self, d_k: int):
            super().__init__()
            self.scale = 1.0 / math.sqrt(d_k)

        def forward(self, q, k, v, mask=None):
            # Q, K, V shapes: (batch, heads, seq_len, d_k)
            scores = torch.matmul(q, k.transpose(-2, -1)) * self.scale
            if mask is not None:
                scores = scores.masked_fill(mask == 0, -1e9)
            attn_weights = F.softmax(scores, dim=-1)
            return torch.matmul(attn_weights, v), attn_weights

    class MultiHeadAttention(nn.Module):
        def __init__(self, d_model: int = 64, num_heads: int = 4):
            super().__init__()
            assert d_model % num_heads == 0
            self.d_k = d_model // num_heads
            self.num_heads = num_heads

            self.w_q = nn.Linear(d_model, d_model)
            self.w_k = nn.Linear(d_model, d_model)
            self.w_v = nn.Linear(d_model, d_model)
            self.w_o = nn.Linear(d_model, d_model)
            self.attention = ScaledDotProductAttention(self.d_k)

        def forward(self, q, k, v, mask=None):
            batch_size = q.size(0)

            # Linear projections and split into num_heads
            q = self.w_q(q).view(batch_size, -1, self.num_heads, self.d_k).transpose(1, 2)
            k = self.w_k(k).view(batch_size, -1, self.num_heads, self.d_k).transpose(1, 2)
            v = self.w_v(v).view(batch_size, -1, self.num_heads, self.d_k).transpose(1, 2)

            out, weights = self.attention(q, k, v, mask=mask)
            out = out.transpose(1, 2).contiguous().view(batch_size, -1, self.num_heads * self.d_k)
            return self.w_o(out)

    class TransformerBlock(nn.Module):
        def __init__(self, d_model: int = 64, num_heads: int = 4, d_ff: int = 256, dropout: float = 0.1):
            super().__init__()
            self.attn = MultiHeadAttention(d_model, num_heads)
            self.norm1 = nn.LayerNorm(d_model)
            self.norm2 = nn.LayerNorm(d_model)
            self.ffn = nn.Sequential(
                nn.Linear(d_model, d_ff),
                nn.ReLU(),
                nn.Linear(d_ff, d_model)
            )
            self.dropout = nn.Dropout(dropout)

        def forward(self, x, mask=None):
            # Residual connection with layer normalization
            norm_x = self.norm1(x)
            attn_out = self.attn(norm_x, norm_x, norm_x, mask=mask)
            x = x + self.dropout(attn_out)

            norm_x2 = self.norm2(x)
            ffn_out = self.ffn(norm_x2)
            x = x + self.dropout(ffn_out)
            return x

    class TinyLanguageModel(nn.Module):
        """Minimal Decoder-Only Transformer for causal text generation."""
        def __init__(self, vocab_size: int = 1000, d_model: int = 64, num_heads: int = 4, num_layers: int = 2):
            super().__init__()
            self.token_embedding = nn.Embedding(vocab_size, d_model)
            self.pos_embedding = nn.Embedding(512, d_model)
            self.layers = nn.ModuleList([TransformerBlock(d_model, num_heads) for _ in range(num_layers)])
            self.norm_final = nn.LayerNorm(d_model)
            self.lm_head = nn.Linear(d_model, vocab_size)

        def forward(self, idx):
            b, t = idx.size()
            pos = torch.arange(0, t, device=idx.device).unsqueeze(0)
            x = self.token_embedding(idx) + self.pos_embedding(pos)

            # Causal mask for autoregressive generation
            mask = torch.tril(torch.ones(t, t, device=idx.device)).unsqueeze(0).unsqueeze(0)

            for layer in self.layers:
                x = layer(x, mask=mask)
            x = self.norm_final(x)
            return self.lm_head(x)
