import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/map_route.dart';
import '../../../services/map_service.dart';
import '../../../services/user_location_service.dart';

class AiSearchDestinationDialog extends StatefulWidget {
  final Function(PlaceLocation destination, String prompt) onDestinationSelected;

  const AiSearchDestinationDialog({
    super.key,
    required this.onDestinationSelected,
  });

  @override
  State<AiSearchDestinationDialog> createState() => _AiSearchDestinationDialogState();
}

class _AiSearchDestinationDialogState extends State<AiSearchDestinationDialog> {
  final TextEditingController _promptController = TextEditingController();
  final MapService _mapService = MapService();
  final UserLocationService _userLocService = UserLocationService();
  bool _isAnalyzing = false;
  String? _errorMessage;

  final List<Map<String, String>> _quickDestinations = [
    {'title': 'Angkor Wat', 'icon': '🏛️', 'prompt': 'I want to go to Angkor Wat'},
    {'title': 'Aeon Mall Sen Sok', 'icon': '🛍️', 'prompt': 'Take me to Aeon Mall Sen Sok'},
    {'title': 'Sihanoukville Beach', 'icon': '🏖️', 'prompt': 'Guide me to Sihanoukville Beach'},
    {'title': 'Phnom Penh Airport', 'icon': '✈️', 'prompt': 'How to get to Phnom Penh Airport'},
    {'title': 'Riverside Promenade', 'icon': '🌆', 'prompt': 'Let\'s go to Riverside Promenade'},
    {'title': 'Pub Street Siem Reap', 'icon': '🍹', 'prompt': 'Take me to Pub Street'},
    {'title': 'Central Market (Phsar Thmey)', 'icon': '🏬', 'prompt': 'I want to go to Central Market'},
    {'title': 'Koh Rong Island', 'icon': '🏝️', 'prompt': 'Guide me to Koh Rong Ferry'},
  ];

  Future<void> _processAiSearch(String prompt) async {
    final query = prompt.trim();
    if (query.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      // 1. Extract target place using AI Natural Language parser
      final extractedPlace = MapService.extractDestinationFromPrompt(query);

      // 2. Search place with fallback scoping
      var results = await _mapService.searchPlace('$extractedPlace, ${_userLocService.city}, ${_userLocService.country}');
      if (results.isEmpty) {
        results = await _mapService.searchPlace(extractedPlace);
      }

      if (results.isNotEmpty) {
        final target = results.first;
        if (mounted) {
          Navigator.pop(context);
          widget.onDestinationSelected(target, query);
        }
      } else {
        setState(() {
          _errorMessage = 'Could not find "$extractedPlace". Try typing a specific landmark name or city.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'AI routing search encountered an issue: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.cardDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryColor, Colors.purpleAccent],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Where do you want to go?',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'From ${_userLocService.isGpsActive ? "Current Live GPS" : "${_userLocService.city} Home"}',
                        style: TextStyle(
                          fontSize: 12,
                          color: _userLocService.isGpsActive ? Colors.greenAccent : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // AI Natural Language Input
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.3)),
              ),
              child: TextField(
                controller: _promptController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'e.g. "I want to go to Siem Reap", "Take me to Aeon Mall", or "Guide me to Angkor Wat"...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                  contentPadding: EdgeInsets.all(16),
                  border: InputBorder.none,
                ),
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Submit Button
            ElevatedButton.icon(
              icon: _isAnalyzing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.navigation, size: 20),
              label: Text(
                _isAnalyzing ? 'AI Calculating Route...' : 'AI Guide Me There',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _isAnalyzing ? null : () => _processAiSearch(_promptController.text),
            ),

            const SizedBox(height: 18),
            const Divider(color: Colors.white12),
            const SizedBox(height: 8),

            // Quick Suggestions Section
            const Text(
              'Popular Destinations to Ask AI:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70),
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickDestinations.map((dest) {
                return ActionChip(
                  backgroundColor: AppTheme.surfaceDark,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                  avatar: Text(dest['icon'] ?? '📍', style: const TextStyle(fontSize: 14)),
                  label: Text(
                    dest['title']!,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  onPressed: () {
                    _promptController.text = dest['prompt']!;
                    _processAiSearch(dest['prompt']!);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ),
  );
  }
}
