package com.example.ai.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

import java.util.Map;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@JsonIgnoreProperties(ignoreUnknown = true)
public class InferenceResponse {
    @JsonProperty("model_used")
    private String modelUsed;

    private String output;

    private Double confidence;

    private Map<String, Object> details;
}
