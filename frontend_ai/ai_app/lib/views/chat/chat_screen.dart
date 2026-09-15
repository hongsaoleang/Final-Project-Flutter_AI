import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/chat_message.dart';
import '../../services/ai_service.dart';
import 'widgets/message_bubble.dart';
import 'widgets/mode_selector.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessageModel> _messages = [];
  final AiService _aiService = AiService();
  bool _isLoading = false;
  AiMode _selectedMode = AiMode.textGeneration;
  Map<String, dynamic>? _attachedFile;

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty && _attachedFile == null) return;
    final userText = text.trim().isEmpty ? 'Process attached file: ${_attachedFile!['originalName']}' : text.trim();
    _controller.clear();

    final currentAttachment = _attachedFile;
    setState(() {
      _messages.add(
        ChatMessageModel(
          sender: 'user',
          text: currentAttachment != null ? '$userText\n[Attached: ${currentAttachment['originalName']}]' : userText,
          mode: _selectedMode,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = true;
      _attachedFile = null;
    });
    _scrollToBottom();

    try {
      final responseText = await _aiService.sendMultimodalPrompt(
        mode: _selectedMode,
        prompt: userText,
        imageData: currentAttachment != null ? (currentAttachment['url'] ?? currentAttachment['fileUuid']) : null,
      );

      setState(() {
        _messages.add(
          ChatMessageModel(
            sender: 'myai',
            text: responseText,
            mode: _selectedMode,
            timestamp: DateTime.now(),
          ),
        );
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessageModel(
            sender: 'myai',
            text: 'Error contacting AI backend: $e',
            mode: _selectedMode,
            timestamp: DateTime.now(),
          ),
        );
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _showAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Upload & Test Attachment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              const Text('Select a test document or dataset to upload to MyAI storage:', style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 20),
              ListTile(
                leading: const CircleAvatar(backgroundColor: AppTheme.primaryColor, child: Icon(Icons.description, color: Colors.white)),
                title: const Text('Sample Document (OCR Test)', style: TextStyle(color: Colors.white)),
                subtitle: const Text('ai/data/datasets/sample_document.txt', style: TextStyle(color: Colors.grey, fontSize: 12)),
                onTap: () => _uploadSampleFile('sample_document.txt', 'MyAI OCR Document Test\nHeading: Deep Learning Foundations\nDate: 2026-09-15', AiMode.ocr),
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.menu_book, color: Colors.white)),
                title: const Text('AI Text Corpus (LM Test)', style: TextStyle(color: Colors.white)),
                subtitle: const Text('ai/data/raw/corpus.txt', style: TextStyle(color: Colors.grey, fontSize: 12)),
                onTap: () => _uploadSampleFile('corpus.txt', 'Artificial intelligence and transformer self-attention mechanisms.', AiMode.textGeneration),
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.purple, child: Icon(Icons.table_chart, color: Colors.white)),
                title: const Text('Classification Dataset', style: TextStyle(color: Colors.white)),
                subtitle: const Text('ai/data/raw/classification_data.csv', style: TextStyle(color: Colors.grey, fontSize: 12)),
                onTap: () => _uploadSampleFile('classification_data.csv', 'f1,f2,f3,f4,label\n5.1,3.5,1.4,0.2,0\n6.0,3.0,4.8,1.8,2', AiMode.imageUnderstanding),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadSampleFile(String filename, String content, AiMode targetMode) async {
    Navigator.pop(context);
    setState(() => _isLoading = true);
    try {
      final bytes = utf8.encode(content);
      final result = await _aiService.uploadFile(filename: filename, bytes: bytes);
      setState(() {
        _attachedFile = result;
        _selectedMode = targetMode;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Uploaded $filename as ${result['fileUuid']}! Switched mode to ${targetMode.title}.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ModeSelector(
          selectedMode: _selectedMode,
          onModeSelected: (mode) => setState(() => _selectedMode = mode),
        ),
        Expanded(
          child: _messages.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) => MessageBubble(message: _messages[index]),
                ),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 8),
                Text('MyAI is thinking...', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        if (_attachedFile != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.attach_file, size: 16, color: AppTheme.primaryLight),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Attached: ${_attachedFile!['originalName']} (${_attachedFile!['fileUuid']})',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _attachedFile = null),
                  child: const Icon(Icons.close, size: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          color: AppTheme.cardDark,
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Upload Document / Image',
                  icon: Icon(
                    Icons.attach_file,
                    color: _attachedFile != null ? AppTheme.primaryLight : Colors.grey,
                  ),
                  onPressed: _showAttachmentSheet,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Prompt for ${_selectedMode.title}...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: AppTheme.backgroundDark,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor.withValues(alpha: 0.15),
            ),
            child: const Icon(Icons.auto_awesome, size: 48, color: AppTheme.primaryLight),
          ),
          const SizedBox(height: 16),
          const Text('MyAI Multimodal Assistant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Select an AI mode above and start chatting.', style: TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }
}
