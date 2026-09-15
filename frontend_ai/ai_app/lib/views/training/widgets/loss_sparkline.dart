import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class LossSparkline extends StatelessWidget {
  final List<double> lossHistory;

  const LossSparkline({super.key, required this.lossHistory});

  @override
  Widget build(BuildContext context) {
    if (lossHistory.isEmpty) return const SizedBox.shrink();

    final maxLoss = lossHistory.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Loss Reduction Curve:', style: TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: lossHistory.map((l) {
              final factor = maxLoss > 0 ? (l / maxLoss) : 0.5;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  height: 44 * factor,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
