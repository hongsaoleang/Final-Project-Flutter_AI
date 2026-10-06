import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessageModel message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primaryColor : AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isUser ? Colors.transparent : AppTheme.borderDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUser ? Icons.person : Icons.auto_awesome,
                  size: 14,
                  color: isUser ? Colors.white70 : AppTheme.primaryLight,
                ),
                const SizedBox(width: 6),
                Text(
                  isUser ? 'You' : 'DER LENG (${message.mode.title})',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isUser ? Colors.white70 : AppTheme.primaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SelectableText(
              message.text,
              style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
