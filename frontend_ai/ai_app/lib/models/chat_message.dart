import 'package:flutter/material.dart';

enum AiMode {
  textGeneration('Text AI', Icons.chat_bubble_outline),
  textToImage('Text to Image', Icons.image_outlined),
  imageToText('Image to Text', Icons.image_search_outlined),
  ocr('OCR Scanner', Icons.document_scanner_outlined),
  imageUnderstanding('Vision QA', Icons.visibility_outlined);

  final String title;
  final IconData icon;

  const AiMode(this.title, this.icon);
}

class ChatMessageModel {
  final String sender; // 'user' or 'myai'
  final String text;
  final AiMode mode;
  final DateTime timestamp;
  final String? imageUrl;

  ChatMessageModel({
    required this.sender,
    required this.text,
    required this.mode,
    required this.timestamp,
    this.imageUrl,
  });

  bool get isUser => sender == 'user';
}
