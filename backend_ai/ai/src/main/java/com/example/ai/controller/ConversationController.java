package com.example.ai.controller;

import com.example.ai.model.ChatMessage;
import com.example.ai.model.Conversation;
import com.example.ai.repository.ChatMessageRepository;
import com.example.ai.repository.ConversationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/v1/conversations")
@RequiredArgsConstructor
public class ConversationController {

    private final ConversationRepository conversationRepository;
    private final ChatMessageRepository chatMessageRepository;

    @GetMapping
    public ResponseEntity<List<Conversation>> listConversations() {
        return ResponseEntity.ok(conversationRepository.findAllByOrderByUpdatedAtDesc());
    }

    @PostMapping
    public ResponseEntity<Conversation> createConversation(@RequestBody Map<String, String> payload) {
        String title = payload.getOrDefault("title", "New Conversation");
        Conversation conv = Conversation.builder()
                .conversationUuid("conv-" + UUID.randomUUID().toString().substring(0, 8))
                .title(title)
                .build();
        return ResponseEntity.ok(conversationRepository.save(conv));
    }

    @GetMapping("/{uuid}/messages")
    public ResponseEntity<List<ChatMessage>> getMessages(@PathVariable String uuid) {
        Optional<Conversation> convOpt = conversationRepository.findByConversationUuid(uuid);
        if (convOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(chatMessageRepository.findByConversationOrderByCreatedAtAsc(convOpt.get()));
    }

    @DeleteMapping("/{uuid}")
    public ResponseEntity<Void> deleteConversation(@PathVariable String uuid) {
        Optional<Conversation> convOpt = conversationRepository.findByConversationUuid(uuid);
        if (convOpt.isPresent()) {
            conversationRepository.delete(convOpt.get());
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}
