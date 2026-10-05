import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/chat_message.dart';
import '../../services/ai_service.dart';
import '../../services/map_service.dart';
import '../../services/user_location_service.dart';

class AiPlaceChatScreen extends StatefulWidget {
  final Function(String query)? onNavigateToMap;

  const AiPlaceChatScreen({super.key, this.onNavigateToMap});

  @override
  State<AiPlaceChatScreen> createState() => _AiPlaceChatScreenState();
}

class _AiPlaceChatScreenState extends State<AiPlaceChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessageModel> _messages = [];
  final AiService _aiService = AiService();
  final MapService _mapService = MapService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessageModel(
        sender: 'myai',
        text: '👋 Hello! I am your **AI Map & Travel Guide**.\n\nAsk me about any place in the world, distance between cities, recommended attractions, or directions! For example:\n• *"How far is Paris from London?"*\n• *"Best places to visit in Tokyo"*\n• *"Guide me to Central Park"*',
        mode: AiMode.textGeneration,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> _sendMessage(String text) async {
    final clean = text.trim();
    if (clean.isEmpty) return;
    _controller.clear();

    setState(() {
      _messages.add(
        ChatMessageModel(
          sender: 'user',
          text: clean,
          mode: AiMode.textGeneration,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      // Check if user is asking for distance / range between two places
      final lower = clean.toLowerCase();
      String responseText = '';

      if (lower.contains('distance') || lower.contains('how far') || lower.contains('range')) {
        // Try to parse places
        final words = clean.replaceAll(RegExp(r'[?.,!]'), '').split(' ');
        if (words.contains('between') && words.contains('and')) {
          final betweenIdx = words.indexOf('between');
          final andIdx = words.indexOf('and');
          if (andIdx > betweenIdx) {
            final p1Name = words.sublist(betweenIdx + 1, andIdx).join(' ');
            final p2Name = words.sublist(andIdx + 1).join(' ');

            final p1Results = await _mapService.searchPlace(p1Name);
            final p2Results = await _mapService.searchPlace(p2Name);

            if (p1Results.isNotEmpty && p2Results.isNotEmpty) {
              final dMeters = _mapService.calculateDistanceMeters(
                p1Results.first.coordinates,
                p2Results.first.coordinates,
              );
              final dKm = dMeters / 1000.0;
              final dMiles = dKm * 0.621371;

              responseText = '''📏 **Calculated Range & Distance**:
• **From**: ${p1Results.first.name}
• **To**: ${p2Results.first.name}
• **Straight-line Distance**: ${dKm.toStringAsFixed(2)} km (${dMiles.toStringAsFixed(2)} miles)
• **Driving ETA (est.)**: ~${(dKm / 50.0 * 60).round()} mins

💡 *Tip: Head over to the **Map Guide** tab to view the visual route line and turn-by-turn guidance!*''';
            }
          }
        }
      }

      if (responseText.isEmpty) {
        // Query backend AI
        try {
          final res = await _aiService.sendMultimodalPrompt(
            mode: AiMode.textGeneration,
            prompt: clean,
          );
          if (res.isNotEmpty &&
              !res.contains('Connect the PyTorch model service') &&
              !res.contains('The AI platform is active and ready')) {
            responseText = res;
          }
        } catch (_) {}
      }

      // If backend didn't provide a substantive answer, generate rich spatial travel guidance
      if (responseText.isEmpty) {
        responseText = await _generateRichTravelGuidance(clean);
      }
      final detectedPlace = _detectDestinationPlace(clean, responseText);

      setState(() {
        _messages.add(
          ChatMessageModel(
            sender: 'myai',
            text: responseText,
            mode: AiMode.textGeneration,
            timestamp: DateTime.now(),
            destinationPlace: detectedPlace,
          ),
        );
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessageModel(
            sender: 'myai',
            text: 'Could not process travel query: $e',
            mode: AiMode.textGeneration,
            timestamp: DateTime.now(),
          ),
        );
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  String? _detectDestinationPlace(String userQuery, String aiResponse) {
    final lowerQuery = userQuery.toLowerCase();
    final lowerResp = aiResponse.toLowerCase();

    // Specific famous Q&A pairs (e.g. capital of Cambodia)
    if (lowerQuery.contains('capital') && lowerQuery.contains('cambodia')) {
      return 'Phnom Penh';
    }
    if (lowerQuery.contains('capital') && lowerQuery.contains('france')) {
      return 'Paris';
    }
    if (lowerQuery.contains('capital') && lowerQuery.contains('japan')) {
      return 'Tokyo';
    }

    // Curated famous landmarks & cities
    final places = [
      'Angkor Wat', 'Phnom Penh', 'Siem Reap', 'Royal Palace', 'Central Market',
      'Wat Phnom', 'Aeon Mall Sen Sok', 'Aeon Mall', 'Riverside Promenade',
      'Sihanoukville', 'Kampot', 'Battambang', 'Pub Street', 'Old Market',
      'Bayon Temple', 'Bokor Mountain', 'Bamboo Train', 'Koh Rong',
      'Eiffel Tower', 'Times Square', 'Central Park', 'Louvre Museum',
      'Tokyo Tower', 'Shibuya Crossing', 'Big Ben', 'Colosseum',
    ];

    for (final p in places) {
      if (lowerQuery.contains(p.toLowerCase())) {
        return p;
      }
    }

    // Check prompt cleaner candidate
    final candidate = MapService.extractDestinationFromPrompt(userQuery);
    if (candidate.isNotEmpty && candidate.toLowerCase() != userQuery.toLowerCase() && candidate.length > 2) {
      return candidate;
    }

    // Check if the AI's response explicitly mentions a key destination
    for (final p in places) {
      if (lowerResp.contains(p.toLowerCase())) {
        return p;
      }
    }

    return null;
  }

  Future<String> _generateRichTravelGuidance(String query) async {
    final locService = UserLocationService();
    final originName = '${locService.city}, ${locService.country}';

    // Extract destination candidate from query
    String destCandidate = query
        .replaceAll(
          RegExp(
            r'(i want to go to|how to go to|guide me to|take me to|navigate to|go to|directions to|travel to|where is|tell me about)',
            caseSensitive: false,
          ),
          '',
        )
        .trim();
    if (destCandidate.isEmpty) destCandidate = query;

    final results = await _mapService.searchPlace(destCandidate);
    if (results.isNotEmpty) {
      final destPlace = results.first;
      final distMeters = _mapService.calculateDistanceMeters(
        locService.livingPlace.coordinates,
        destPlace.coordinates,
      );
      final distKm = distMeters / 1000.0;
      final distMiles = distKm * 0.621371;
      final estDriveHours = (distKm / 55.0);
      final driveTimeText = estDriveHours < 1.0
          ? '${(estDriveHours * 60).round()} mins'
          : '${estDriveHours.floor()}h ${((estDriveHours - estDriveHours.floor()) * 60).round()}m';

      return '''📍 **AI Travel Guide: ${destPlace.name}**
• **Departure (Where you live)**: $originName
• **Destination**: ${destPlace.displayName}
• **Direct Distance (Range)**: ${distKm.toStringAsFixed(1)} km (${distMiles.toStringAsFixed(1)} miles)
• **Estimated Travel Time**: ~$driveTimeText by road / transit

🚗 **Transportation & Route Advice**:
• Express vans, intercity buses, or private taxis are widely available for this route.
${distKm > 200 ? '• Domestic and regional flights may also be available for quicker travel.' : '• Follow designated highways and monitor real-time traffic.'}

🏛️ **Attractions & Things to Do**:
• Explore landmark historical sites, local cultural centers, and dining districts.
• Ideal visiting duration: ${distKm > 100 ? '2 to 3 days' : 'Half-day to 1 day'}.

💡 **AI Navigation Tip**:
• Switch over to the **Map Guide** tab to view your route drawn in real-time with turn-by-turn guidance!''';
    }

    return '''🧭 **AI Travel Assistant**:
Here is guidance for "$query":
• **Your Current Living Base**: $originName
• To see this destination on the interactive map with live route polylines and turn-by-turn directions, switch to the **Map Guide** tab or type the place name in the map search bar.
• Optimal visiting hours are generally morning or late afternoon for smaller crowds.''';
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
    return SafeArea(
      child: Column(
      children: [
        // Suggested Questions Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: AppTheme.cardDark,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPromptChip('Distance between Paris and London'),
                const SizedBox(width: 8),
                _buildPromptChip('Guide me to Times Square'),
                const SizedBox(width: 8),
                _buildPromptChip('Distance between Tokyo and Kyoto'),
                const SizedBox(width: 8),
                _buildPromptChip('Top landmarks in New York'),
              ],
            ),
          ),
        ),

        // Message List
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (ctx, i) {
              final msg = _messages[i];
              final isUser = msg.sender == 'user';
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.82,
                  ),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isUser ? AppTheme.primaryColor : AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
                      bottomLeft: !isUser ? const Radius.circular(0) : const Radius.circular(16),
                    ),
                    border: Border.all(
                      color: isUser ? Colors.transparent : Colors.white12,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isUser ? Icons.person : Icons.assistant_navigation,
                            size: 14,
                            color: isUser ? Colors.white70 : AppTheme.primaryLight,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isUser ? 'You' : 'AI Map Guide',
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
                        msg.text,
                        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                      ),
                      if (!isUser && msg.destinationPlace != null && msg.destinationPlace!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.35)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Destination: ${msg.destinationPlace}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.map, size: 15),
                                  label: Text(
                                    'Open on Map & Guide Me to ${msg.destinationPlace}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    elevation: 2,
                                  ),
                                  onPressed: () {
                                    widget.onNavigateToMap?.call(msg.destinationPlace!);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Input Field
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: AppTheme.cardDark,
            border: Border(top: BorderSide(color: Colors.white10)),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ask about any place or distance...',
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                      filled: true,
                      fillColor: AppTheme.surfaceDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryLight),
                        )
                      : const Icon(Icons.send, color: AppTheme.primaryLight),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildPromptChip(String text) {
    return ActionChip(
      backgroundColor: AppTheme.surfaceDark,
      label: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      onPressed: () => _sendMessage(text),
    );
  }
}
