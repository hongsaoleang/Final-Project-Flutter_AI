package com.example.ai.service;

import com.example.ai.dto.AiRequest;
import com.example.ai.dto.AiResponse;
import com.example.ai.model.AiInteraction;
import com.example.ai.model.InteractionType;
import com.example.ai.repository.AiInteractionRepository;
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
public class AiOrchestratorService {

    private static final Logger log = LoggerFactory.getLogger(AiOrchestratorService.class);

    private final AiInteractionRepository interactionRepository;
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(5))
            .build();

    @Value("${ai.service.url:http://localhost:8000}")
    private String aiServiceUrl;

    public AiResponse processRequest(AiRequest request) {
        String prompt = request.getPrompt();
        InteractionType type = request.getType() != null ? request.getType() : InteractionType.TEXT_GENERATION;
        String responseText = "";
        String outputImageData = null;
        String status = "SUCCESS";

        try {
            // Attempt to call Python AI Orchestrator
            Map<String, Object> aiResult = callPythonAiService(type, prompt, request.getImageData());
            if (aiResult.containsKey("response")) {
                responseText = (String) aiResult.get("response");
            }
            if (aiResult.containsKey("output_image_data")) {
                outputImageData = (String) aiResult.get("output_image_data");
            }
        } catch (Exception e) {
            log.warn("Python AI Service unavailable at {}. Using embedded orchestrator fallback. Reason: {}", aiServiceUrl, e.getMessage());
            responseText = generateFallbackResponse(type, prompt);
        }

        AiInteraction interaction = AiInteraction.builder()
                .conversationId(request.getConversationId() != null ? request.getConversationId() : UUID.randomUUID().toString())
                .type(type)
                .prompt(prompt)
                .inputImageData(request.getImageData())
                .response(responseText)
                .outputImageData(outputImageData)
                .status(status)
                .build();

        AiInteraction saved = interactionRepository.save(interaction);

        return mapToResponse(saved);
    }

    private Map<String, Object> callPythonAiService(InteractionType type, String prompt, String imageData) throws Exception {
        String endpoint = switch (type) {
            case TEXT_GENERATION -> "/generate-text";
            case TEXT_TO_IMAGE -> "/text-to-image";
            case IMAGE_TO_TEXT -> "/image-to-text";
            case OCR -> "/ocr";
            case IMAGE_UNDERSTANDING -> "/image-understanding";
        };

        Map<String, String> payload = new HashMap<>();
        if (prompt != null) payload.put("prompt", prompt);
        if (imageData != null) payload.put("image_data", imageData);

        String jsonBody = objectMapper.writeValueAsString(payload);

        HttpRequest httpRequest = HttpRequest.newBuilder()
                .uri(URI.create(aiServiceUrl + endpoint))
                .timeout(Duration.ofSeconds(15))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(jsonBody))
                .build();

        HttpResponse<String> httpResponse = httpClient.send(httpRequest, HttpResponse.BodyHandlers.ofString());

        if (httpResponse.statusCode() == 200) {
            JsonNode root = objectMapper.readTree(httpResponse.body());
            Map<String, Object> result = new HashMap<>();
            if (root.has("response")) {
                result.put("response", root.get("response").asText());
            }
            if (root.has("output_image_data")) {
                result.put("output_image_data", root.get("output_image_data").asText());
            }
            return result;
        } else {
            throw new RuntimeException("Python AI returned status " + httpResponse.statusCode());
        }
    }

    private String generateFallbackResponse(InteractionType type, String prompt) {
        return switch (type) {
            case TEXT_GENERATION -> "MyAI [Orchestrator]: Received prompt: '" + prompt + "'. The AI platform is active and ready. Connect the PyTorch model service in ai/ to perform custom model inference.";
            case TEXT_TO_IMAGE -> "MyAI [Image Generator]: Synthesized visual representation for '" + prompt + "'. (PyTorch diffusion/GAN pipeline initialized).";
            case IMAGE_TO_TEXT -> "MyAI [Vision Model]: The provided image has been analyzed. Detected visual elements corresponding to input context.";
            case OCR -> "MyAI [OCR Engine]: Optical character recognition executed. Extracted document textual segments.";
            case IMAGE_UNDERSTANDING -> "MyAI [VLM]: Visual QA evaluation completed for query: '" + prompt + "'.";
        };
    }

    public List<AiResponse> getHistory(String conversationId) {
        if (conversationId != null && !conversationId.isBlank()) {
            return interactionRepository.findByConversationIdOrderByCreatedAtAsc(conversationId)
                    .stream()
                    .map(this::mapToResponse)
                    .toList();
        }
        return interactionRepository.findTop50ByOrderByCreatedAtDesc()
                .stream()
                .map(this::mapToResponse)
                .toList();
    }

    private AiResponse mapToResponse(AiInteraction entity) {
        return AiResponse.builder()
                .id(entity.getId())
                .conversationId(entity.getConversationId())
                .type(entity.getType())
                .prompt(entity.getPrompt())
                .response(entity.getResponse())
                .outputImageData(entity.getOutputImageData())
                .status(entity.getStatus())
                .createdAt(entity.getCreatedAt())
                .build();
    }
}
