package com.example.ai.repository;

import com.example.ai.model.Conversation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ConversationRepository extends JpaRepository<Conversation, Long> {
    Optional<Conversation> findByConversationUuid(String conversationUuid);
    List<Conversation> findAllByOrderByUpdatedAtDesc();
}
