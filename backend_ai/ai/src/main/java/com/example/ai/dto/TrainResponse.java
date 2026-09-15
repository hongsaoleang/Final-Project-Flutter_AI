package com.example.ai.dto;

import com.example.ai.model.JobStatus;
import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TrainResponse {
    private String jobId;
    private String modelName;
    private String modelType;
    private JobStatus status;
    private Integer currentEpoch;
    private Integer totalEpochs;
    private Double currentLoss;
    private Double accuracy;
    private List<Double> lossHistory;
    private String checkpointPath;
    private String message;
}
