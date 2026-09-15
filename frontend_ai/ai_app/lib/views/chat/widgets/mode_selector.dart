import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/chat_message.dart';

class ModeSelector extends StatelessWidget {
  final AiMode selectedMode;
  final ValueChanged<AiMode> onModeSelected;

  const ModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      color: AppTheme.cardDark.withValues(alpha: 0.5),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: AiMode.values.map((mode) {
          final isSelected = mode == selectedMode;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              avatar: Icon(
                mode.icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey[400],
              ),
              label: Text(mode.title),
              selected: isSelected,
              selectedColor: AppTheme.primaryColor,
              checkmarkColor: Colors.white,
              backgroundColor: const Color(0xFF334155),
              labelStyle: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.grey[300],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (val) => onModeSelected(mode),
            ),
          );
        }).toList(),
      ),
    );
  }
}
