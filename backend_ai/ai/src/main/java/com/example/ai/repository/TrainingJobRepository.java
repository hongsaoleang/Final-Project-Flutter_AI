package com.example.ai.repository;

import com.example.ai.model.TrainingJob;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TrainingJobRepository extends JpaRepository<TrainingJob, Long> {
    Optional<TrainingJob> findByJobId(String jobId);
    List<TrainingJob> findTop20ByOrderByCreatedAtDesc();
}
