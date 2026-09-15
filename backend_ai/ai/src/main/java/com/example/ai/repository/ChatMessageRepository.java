package com.example.ai.repository;

import com.example.ai.model.ChatMessage;
import com.example.ai.model.Conversation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {
    List<ChatMessage> findByConversationOrderByCreatedAtAsc(Conversation conversation);
    List<ChatMessage> findTop50ByOrderByCreatedAtDesc();
}
