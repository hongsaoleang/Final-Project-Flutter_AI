package com.example.ai.repository;

import com.example.ai.model.AiInteraction;
import com.example.ai.model.InteractionType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AiInteractionRepository extends JpaRepository<AiInteraction, Long> {

    List<AiInteraction> findByConversationIdOrderByCreatedAtAsc(String conversationId);

    List<AiInteraction> findTop50ByOrderByCreatedAtDesc();

    List<AiInteraction> findByTypeOrderByCreatedAtDesc(InteractionType type);
}
