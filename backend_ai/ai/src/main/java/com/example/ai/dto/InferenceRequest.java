package com.example.ai.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

import java.util.Map;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class InferenceRequest {
    @JsonProperty("model_type")
    private String modelType;

    private String prompt;

    @JsonProperty("input_features")
    private Map<String, Object> inputFeatures;
}
