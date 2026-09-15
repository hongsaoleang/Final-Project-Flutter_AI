package com.example.ai.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TrainRequest {
    private String modelName;
    private String modelType; // 'neural_network', 'tiny_llm', 'logistic_regression'
    private Integer epochs;
    private Double learningRate;
    private String dataset;
}
