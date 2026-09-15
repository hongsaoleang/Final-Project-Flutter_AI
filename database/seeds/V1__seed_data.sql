-- ============================================================
-- Initial Seed Data for MyAI Platform
-- ============================================================

INSERT INTO conversations (conversation_uuid, title, created_at, updated_at)
VALUES 
('conv-seed-01', 'Welcome to MyAI Platform', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (conversation_uuid) DO NOTHING;

INSERT INTO chat_messages (conversation_id, sender, content, interaction_mode, created_at)
SELECT id, 'myai', 'Welcome to MyAI! Your personal multimodal platform is active and ready to train.', 'TEXT_GENERATION', CURRENT_TIMESTAMP
FROM conversations WHERE conversation_uuid = 'conv-seed-01'
ON CONFLICT DO NOTHING;
