package com.example.ai.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "ai_training_jobs")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TrainingJob {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "job_id", unique = true, nullable = false)
    private String jobId;

    @Column(name = "model_name", nullable = false)
    private String modelName;

    @Column(name = "model_type", nullable = false)
    private String modelType;

    @Column(nullable = false)
    private Integer epochs;

    @Column(name = "learning_rate", nullable = false)
    private Double learningRate;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private JobStatus status;

    @Column(name = "current_epoch")
    private Integer currentEpoch;

    @Column(name = "final_loss")
    private Double finalLoss;

    @Column(name = "final_accuracy")
    private Double finalAccuracy;

    @Column(columnDefinition = "TEXT", name = "loss_history_json")
    private String lossHistoryJson;

    @Column(name = "checkpoint_path")
    private String checkpointPath;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        if (this.status == null) {
            this.status = JobStatus.QUEUED;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}
