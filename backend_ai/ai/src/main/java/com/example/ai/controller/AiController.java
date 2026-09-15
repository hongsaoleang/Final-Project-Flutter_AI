package com.example.ai.controller;

import com.example.ai.dto.*;
import com.example.ai.model.InteractionType;
import com.example.ai.model.TrainingJob;
import com.example.ai.service.AiOrchestratorService;
import com.example.ai.service.AiTrainingService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/ai")
@RequiredArgsConstructor
public class AiController {

    private final AiOrchestratorService orchestratorService;
    private final AiTrainingService trainingService;

    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> healthCheck() {
        Map<String, Object> health = new HashMap<>();
        health.put("status", "UP");
        health.put("service", "MyAI Spring Boot Backend");
        health.put("database", "PostgreSQL (myai_db)");
        return ResponseEntity.ok(health);
    }

    // ==========================================
    // Multimodal Inference Endpoints
    // ==========================================

    @PostMapping("/generate-text")
    public ResponseEntity<AiResponse> generateText(@RequestBody AiRequest request) {
        request.setType(InteractionType.TEXT_GENERATION);
        return ResponseEntity.ok(orchestratorService.processRequest(request));
    }

    @PostMapping("/text-to-image")
    public ResponseEntity<AiResponse> textToImage(@RequestBody AiRequest request) {
        request.setType(InteractionType.TEXT_TO_IMAGE);
        return ResponseEntity.ok(orchestratorService.processRequest(request));
    }

    @PostMapping("/image-to-text")
    public ResponseEntity<AiResponse> imageToText(@RequestBody AiRequest request) {
        request.setType(InteractionType.IMAGE_TO_TEXT);
        return ResponseEntity.ok(orchestratorService.processRequest(request));
    }

    @PostMapping("/ocr")
    public ResponseEntity<AiResponse> ocr(@RequestBody AiRequest request) {
        request.setType(InteractionType.OCR);
        return ResponseEntity.ok(orchestratorService.processRequest(request));
    }

    @PostMapping("/image-understanding")
    public ResponseEntity<AiResponse> imageUnderstanding(@RequestBody AiRequest request) {
        request.setType(InteractionType.IMAGE_UNDERSTANDING);
        return ResponseEntity.ok(orchestratorService.processRequest(request));
    }

    @GetMapping("/history")
    public ResponseEntity<List<AiResponse>> getHistory(
            @RequestParam(value = "conversationId", required = false) String conversationId) {
        return ResponseEntity.ok(orchestratorService.getHistory(conversationId));
    }

    // ==========================================
    // AI Model Training & Fine-Tuning Endpoints
    // ==========================================

    @PostMapping("/train")
    public ResponseEntity<TrainResponse> startTraining(@RequestBody TrainRequest request) {
        return ResponseEntity.ok(trainingService.startTraining(request));
    }

    @GetMapping("/train/status/{jobId}")
    public ResponseEntity<TrainResponse> getTrainingStatus(@PathVariable String jobId) {
        return ResponseEntity.ok(trainingService.getTrainingStatus(jobId));
    }

    @GetMapping("/train/jobs")
    public ResponseEntity<List<TrainingJob>> getRecentJobs() {
        return ResponseEntity.ok(trainingService.getRecentJobs());
    }

    @PostMapping("/infer-trained")
    public ResponseEntity<InferenceResponse> inferTrainedModel(@RequestBody InferenceRequest request) {
        return ResponseEntity.ok(trainingService.runTrainedInference(request));
    }
}
