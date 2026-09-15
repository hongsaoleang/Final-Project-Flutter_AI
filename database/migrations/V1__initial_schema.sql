-- ============================================================
-- PostgreSQL Database Schema Migration for MyAI Platform
-- Target Database: myai_db | Owner: user
-- ============================================================

CREATE TABLE IF NOT EXISTS conversations (
    id BIGSERIAL PRIMARY KEY,
    conversation_uuid VARCHAR(64) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS chat_messages (
    id BIGSERIAL PRIMARY KEY,
    conversation_id BIGINT NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender VARCHAR(32) NOT NULL,
    content TEXT NOT NULL,
    interaction_mode VARCHAR(64),
    image_url TEXT,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS ai_interactions (
    id BIGSERIAL PRIMARY KEY,
    conversation_id VARCHAR(64),
    type VARCHAR(64) NOT NULL,
    prompt TEXT,
    input_image_data TEXT,
    response TEXT,
    output_image_data TEXT,
    status VARCHAR(32) NOT NULL DEFAULT 'SUCCESS',
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS ai_training_jobs (
    id BIGSERIAL PRIMARY KEY,
    job_id VARCHAR(64) UNIQUE NOT NULL,
    model_name VARCHAR(128) NOT NULL,
    model_type VARCHAR(64) NOT NULL,
    epochs INT NOT NULL,
    learning_rate DOUBLE PRECISION NOT NULL,
    status VARCHAR(32) NOT NULL,
    current_epoch INT DEFAULT 0,
    final_loss DOUBLE PRECISION,
    final_accuracy DOUBLE PRECISION,
    loss_history_json TEXT,
    checkpoint_path VARCHAR(512),
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS uploaded_files (
    id BIGSERIAL PRIMARY KEY,
    file_uuid VARCHAR(64) UNIQUE NOT NULL,
    original_name VARCHAR(255) NOT NULL,
    content_type VARCHAR(128),
    file_size BIGINT,
    storage_path VARCHAR(512) NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indices for rapid lookup
CREATE INDEX IF NOT EXISTS idx_conversations_uuid ON conversations(conversation_uuid);
CREATE INDEX IF NOT EXISTS idx_chat_messages_conv ON chat_messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_training_jobs_id ON ai_training_jobs(job_id);
