package com.example.ai.dto;

import com.example.ai.model.InteractionType;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AiResponse {
    private Long id;
    private String conversationId;
    private InteractionType type;
    private String prompt;
    private String response;
    private String outputImageData;
    private String status;
    private LocalDateTime createdAt;
}
