package com.example.ai.dto;

import com.example.ai.model.InteractionType;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AiRequest {
    private String conversationId;
    private InteractionType type;
    private String prompt;
    private String imageData; // Base64 encoded or URL
}
