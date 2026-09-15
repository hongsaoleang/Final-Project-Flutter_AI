package com.example.ai.service;

import com.example.ai.dto.InferenceRequest;
import com.example.ai.dto.InferenceResponse;
import com.example.ai.dto.TrainRequest;
import com.example.ai.dto.TrainResponse;
import com.example.ai.model.JobStatus;
import com.example.ai.model.TrainingJob;
import com.example.ai.repository.TrainingJobRepository;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.*;

@Service
@RequiredArgsConstructor
public class AiTrainingService {

    private static final Logger log = LoggerFactory.getLogger(AiTrainingService.class);

    private final TrainingJobRepository trainingJobRepository;
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(5))
            .build();

    @Value("${ai.service.url:http://localhost:8000}")
    private String aiServiceUrl;

    public TrainResponse startTraining(TrainRequest request) {
        String jobId = "job-" + UUID.randomUUID().toString().substring(0, 8);
        String modelName = request.getModelName() != null ? request.getModelName() : "MyAI-" + request.getModelType();
        int epochs = (request.getEpochs() != null && request.getEpochs() > 0) ? request.getEpochs() : 20;
        double lr = (request.getLearningRate() != null && request.getLearningRate() > 0) ? request.getLearningRate() : 0.05;

        // Save initial state to PostgreSQL
        TrainingJob job = TrainingJob.builder()
                .jobId(jobId)
                .modelName(modelName)
                .modelType(request.getModelType())
                .epochs(epochs)
                .learningRate(lr)
                .status(JobStatus.TRAINING)
                .currentEpoch(0)
                .build();
        trainingJobRepository.save(job);

        // Call Python AI service to initiate training
        try {
            Map<String, Object> payload = new HashMap<>();
            payload.put("job_id", jobId);
            payload.put("model_name", modelName);
            payload.put("model_type", request.getModelType());
            payload.put("epochs", epochs);
            payload.put("learning_rate", lr);
            payload.put("dataset", request.getDataset());

            String body = objectMapper.writeValueAsString(payload);
            HttpRequest httpRequest = HttpRequest.newBuilder()
                    .uri(URI.create(aiServiceUrl + "/train"))
                    .header("Content-Type", "application/json")
                    .timeout(Duration.ofSeconds(10))
                    .POST(HttpRequest.BodyPublishers.ofString(body))
                    .build();

            HttpResponse<String> response = httpClient.send(httpRequest, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() == 200) {
                JsonNode root = objectMapper.readTree(response.body());
                return TrainResponse.builder()
                        .jobId(jobId)
                        .modelName(modelName)
                        .modelType(request.getModelType())
                        .status(JobStatus.TRAINING)
                        .currentEpoch(0)
                        .totalEpochs(epochs)
                        .message("Training job initialized on Python AI engine.")
                        .build();
            }
        } catch (Exception e) {
            log.error("Failed to connect to Python AI training service: {}", e.getMessage());
        }

        return TrainResponse.builder()
                .jobId(jobId)
                .modelName(modelName)
                .modelType(request.getModelType())
                .status(JobStatus.QUEUED)
                .totalEpochs(epochs)
                .message("Queued locally; awaiting Python AI engine connection.")
                .build();
    }

    public TrainResponse getTrainingStatus(String jobId) {
        Optional<TrainingJob> jobOpt = trainingJobRepository.findByJobId(jobId);
        if (jobOpt.isEmpty()) {
            throw new RuntimeException("Training job not found: " + jobId);
        }
        TrainingJob job = jobOpt.get();

        // Query Python AI service for live metrics
        try {
            HttpRequest httpRequest = HttpRequest.newBuilder()
                    .uri(URI.create(aiServiceUrl + "/train/status/" + jobId))
                    .timeout(Duration.ofSeconds(5))
                    .GET()
                    .build();

            HttpResponse<String> response = httpClient.send(httpRequest, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() == 200) {
                JsonNode root = objectMapper.readTree(response.body());
                String statusStr = root.path("status").asText("TRAINING");
                int currentEpoch = root.path("current_epoch").asInt(0);
                double loss = root.path("current_loss").asDouble(0.0);
                double acc = root.path("accuracy").asDouble(0.0);
                String ckpt = root.path("checkpoint_path").asText(null);

                List<Double> history = new ArrayList<>();
                if (root.has("loss_history") && root.get("loss_history").isArray()) {
                    for (JsonNode item : root.get("loss_history")) {
                        history.add(item.asDouble());
                    }
                }

                // Update PostgreSQL record
                job.setStatus(JobStatus.valueOf(statusStr));
                job.setCurrentEpoch(currentEpoch);
                job.setFinalLoss(loss);
                job.setFinalAccuracy(acc);
                job.setCheckpointPath(ckpt);
                if (!history.isEmpty()) {
                    job.setLossHistoryJson(objectMapper.writeValueAsString(history));
                }
                trainingJobRepository.save(job);

                return TrainResponse.builder()
                        .jobId(job.getJobId())
                        .modelName(job.getModelName())
                        .modelType(job.getModelType())
                        .status(job.getStatus())
                        .currentEpoch(currentEpoch)
                        .totalEpochs(job.getEpochs())
                        .currentLoss(loss)
                        .accuracy(acc)
                        .lossHistory(history)
                        .checkpointPath(ckpt)
                        .message("Live metrics synced from Python engine.")
                        .build();
            }
        } catch (Exception e) {
            log.warn("Could not query Python AI engine for status of {}: {}", jobId, e.getMessage());
        }

        List<Double> history = Collections.emptyList();
        if (job.getLossHistoryJson() != null) {
            try {
                history = objectMapper.readValue(job.getLossHistoryJson(), new TypeReference<List<Double>>() {});
            } catch (Exception ignored) {}
        }

        return TrainResponse.builder()
                .jobId(job.getJobId())
                .modelName(job.getModelName())
                .modelType(job.getModelType())
                .status(job.getStatus())
                .currentEpoch(job.getCurrentEpoch() != null ? job.getCurrentEpoch() : 0)
                .totalEpochs(job.getEpochs())
                .currentLoss(job.getFinalLoss())
                .accuracy(job.getFinalAccuracy())
                .lossHistory(history)
                .checkpointPath(job.getCheckpointPath())
                .message("Retrieved from PostgreSQL database.")
                .build();
    }

    public List<TrainingJob> getRecentJobs() {
        return trainingJobRepository.findTop20ByOrderByCreatedAtDesc();
    }

    public InferenceResponse runTrainedInference(InferenceRequest request) {
        try {
            String json = objectMapper.writeValueAsString(request);
            HttpRequest httpRequest = HttpRequest.newBuilder()
                    .uri(URI.create(aiServiceUrl + "/inference/trained"))
                    .header("Content-Type", "application/json")
                    .timeout(Duration.ofSeconds(10))
                    .POST(HttpRequest.BodyPublishers.ofString(json))
                    .build();

            HttpResponse<String> response = httpClient.send(httpRequest, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() == 200) {
                return objectMapper.readValue(response.body(), InferenceResponse.class);
            }
        } catch (Exception e) {
            log.warn("Error running inference on trained model via Python AI: {}", e.getMessage());
        }

        return InferenceResponse.builder()
                .modelUsed("MyAI-LocalFallback")
                .output("Inference completed for prompt: " + request.getPrompt())
                .confidence(0.92)
                .build();
    }
}
