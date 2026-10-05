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
        text: '👋 Suosdei! I am your **Cambodia AI Travel & Route Guide**.\n\nTell me where you want to go or what experience you are looking for in Cambodia! I will recommend popular spots across **Phnom Penh, Siem Reap, Kampot, Kep, Battambang, Mondulkiri, Koh Rong**, and plot the route directly from your location on the map.\n\n💡 Try asking:\n• *"Recommend the best places to visit in Siem Reap"*\n• *"What are common attractions in Phnom Penh?"*\n• *"Take me to Bokor Mountain in Kampot"*\n• *"Tell me about Battambang Bamboo Train"*\n• *"I want to see waterfalls and nature in Mondulkiri"*\n• *"How far is Angkor Wat from Phnom Penh?"*',
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

              responseText = '''📏 **Calculated Range Across Cambodia**:
• **From**: ${p1Results.first.name}
• **To**: ${p2Results.first.name}
• **Direct Distance**: ${dKm.toStringAsFixed(1)} km (${dMiles.toStringAsFixed(1)} miles)
• **Driving ETA (est.)**: ~${(dKm / 55.0 * 60).round()} mins via National Highway

💡 *Tap below to plot the interactive route on the **Live Map**!*''';
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
      return 'Royal Palace, Phnom Penh';
    }

    // Common Cambodian landmarks & cities
    final places = [
      'Angkor Wat', 'Bayon Temple', 'Ta Prohm', 'Banteay Srei', 'Phnom Kulen', 'Pub Street', 'Siem Reap',
      'Royal Palace', 'Wat Phnom', 'Central Market', 'Riverside Promenade', 'Tuol Sleng', 'Bassac Lane', 'Phnom Penh',
      'Bokor Mountain', 'Bokor National Park', 'Kampot River', 'Secret Lake', 'Teuk Chhou', 'Kampot',
      'Kep Crab Market', 'Rabbit Island', 'Koh Tonsay', 'Kep',
      'Bamboo Train', 'Phnom Sampeau', 'Wat Banan', 'Wat Ek Phnom', 'Battambang',
      'Koh Rong Sanloem', 'Koh Rong', 'Otres Beach', 'Sihanoukville',
      'Bou Sra Waterfall', 'Sen Monorom', 'Mondulkiri',
      'Yeak Laom Lake', 'Ratanakiri',
      'Preah Vihear Temple', 'Preah Vihear',
      'Sambor Prei Kuk', 'Kampong Thom',
      'Bamboo Bridge', 'Koh Pen', 'Kampong Cham',
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

    // Smart defaults for concept keywords
    if (lowerQuery.contains('waterfall') || lowerQuery.contains('nature')) {
      return 'Bou Sra Waterfall, Mondulkiri';
    }
    if (lowerQuery.contains('temple') || lowerQuery.contains('heritage')) {
      return 'Angkor Wat, Siem Reap';
    }
    if (lowerQuery.contains('beach') || lowerQuery.contains('island')) {
      return 'Koh Rong Sanloem';
    }
    if (lowerQuery.contains('river') || lowerQuery.contains('relax')) {
      return 'Kampot River, Kampot';
    }

    return null;
  }

  Future<String> _generateRichTravelGuidance(String query) async {
    final locService = UserLocationService();
    final originName = '${locService.city}, Cambodia';

    // Smart thematic recommendations for Cambodia
    final lower = query.toLowerCase();
    String destCandidate = '';
    String thematicIntro = '';

    if (lower.contains('waterfall') || lower.contains('cascade')) {
      destCandidate = 'Bou Sra Waterfall, Mondulkiri';
      thematicIntro = '🌊 **AI Recommendation**: Bou Sra Waterfall in Mondulkiri is Cambodia\'s most breathtaking multi-tiered natural cascade, surrounded by lush jungle and indigenous Bunong villages.';
    } else if (lower.contains('siem reap') || lower.contains('angkor') || lower.contains('temple')) {
      destCandidate = 'Angkor Wat, Siem Reap';
      thematicIntro = '🏛️ **AI Recommendation**: Angkor Wat in Siem Reap is the ultimate Khmer wonder — best visited at sunrise, followed by Bayon and Ta Prohm.';
    } else if (lower.contains('phnom penh') || lower.contains('capital') || lower.contains('city')) {
      destCandidate = 'Royal Palace, Phnom Penh';
      thematicIntro = '👑 **AI Recommendation**: The Royal Palace and riverside promenade in Phnom Penh showcase the Kingdom\'s regal history, Silver Pagoda, and bustling street cafes.';
    } else if (lower.contains('kampot') || lower.contains('bokor') || lower.contains('river')) {
      destCandidate = 'Bokor Mountain, Kampot';
      thematicIntro = '🌿 **AI Recommendation**: Bokor National Park in Kampot offers panoramic ocean-facing mountain views, cool misty hill stations, and riverside firefly tours.';
    } else if (lower.contains('battambang') || lower.contains('bamboo')) {
      destCandidate = 'Bamboo Train, Battambang';
      thematicIntro = '🚂 **AI Recommendation**: Battambang is Cambodia\'s cultural heartland, famed for the historic Bamboo Train (Norry) and the spectacular Phnom Sampeau bat cave sunset.';
    } else if (lower.contains('beach') || lower.contains('island') || lower.contains('sea')) {
      destCandidate = 'Koh Rong Sanloem';
      thematicIntro = '🏖️ **AI Recommendation**: Koh Rong Sanloem features pristine turquoise waters, powdery white sand bays, and relaxed eco-bungalows.';
    } else if (lower.contains('kep') || lower.contains('crab')) {
      destCandidate = 'Kep Crab Market, Kep';
      thematicIntro = '🦀 **AI Recommendation**: Kep is famous for its lively seaside Crab Market serving fried crab with fresh Kampot green pepper, alongside peaceful trails in Kep National Park.';
    } else {
      destCandidate = query
          .replaceAll(
            RegExp(
              r'(i want to go to|how to go to|guide me to|take me to|navigate to|go to|directions to|travel to|where is|tell me about|recommend|show me)',
              caseSensitive: false,
            ),
            '',
          )
          .trim();
      if (destCandidate.isEmpty) destCandidate = 'Angkor Wat, Siem Reap';
    }

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

      return '''${thematicIntro.isNotEmpty ? '$thematicIntro\n\n' : ''}📍 **AI Route & Travel Plan**:
• **From (Your Current Location)**: $originName
• **Recommended Destination**: ${destPlace.displayName}
• **Distance from You**: ${distKm.toStringAsFixed(1)} km (${distMiles.toStringAsFixed(1)} miles)
• **Estimated Travel Time**: ~$driveTimeText via national highway

🚗 **Travel Advice & Transport**:
• Regular express buses (Giant Ibis, Larryta, Virak Buntham), private taxis, or local transit connect directly to this destination.
• ${distKm > 200 ? 'Domestic flights from Phnom Penh to Siem Reap Angkor International (SAI) take just 45 mins.' : 'Comfortable road trip with scenic countryside stops.'}

💡 **Instant Live Route**:
• Tap the button below to draw the exact route from your location on the **Live Map**!''';
    }

    return '''🧭 **Cambodia AI Travel Assistant**:
Here is my recommendation for "$query":
• **Your Current Location**: $originName
• Common popular Cambodian destinations include **Siem Reap (Angkor Wat)**, **Phnom Penh (Royal Palace)**, **Kampot (Bokor Mountain)**, and **Battambang (Bamboo Train)**.
• Tap below or switch to the **Map** tab to explore interactive routes across Cambodia!''';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      bottom: false,
      child: Column(
      children: [
        // Suggested Questions Header (Cambodia Focused)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: isDark ? AppTheme.cardDark : Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPromptChip('Angkor Wat from Phnom Penh', isDark),
                const SizedBox(width: 8),
                _buildPromptChip('Best places in Kampot & Kep', isDark),
                const SizedBox(width: 8),
                _buildPromptChip('Top landmarks in Phnom Penh', isDark),
                const SizedBox(width: 8),
                _buildPromptChip('Waterfalls in Mondulkiri', isDark),
                const SizedBox(width: 8),
                _buildPromptChip('Battambang Bamboo Train', isDark),
                const SizedBox(width: 8),
                _buildPromptChip('Island trip to Koh Rong', isDark),
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
                    maxWidth: MediaQuery.of(context).size.width * 0.86,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppTheme.primaryColor
                        : (isDark ? AppTheme.cardDark : Colors.white),
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomRight: isUser ? const Radius.circular(2) : const Radius.circular(16),
                      bottomLeft: !isUser ? const Radius.circular(2) : const Radius.circular(16),
                    ),
                    border: Border.all(
                      color: isUser
                          ? Colors.transparent
                          : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
                            color: isUser
                                ? Colors.white70
                                : (isDark ? AppTheme.primaryLight : AppTheme.primaryColor),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isUser ? 'You' : 'AI Map Guide',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isUser
                                  ? Colors.white70
                                  : (isDark ? AppTheme.primaryLight : AppTheme.primaryColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SelectableText(
                        msg.text,
                        style: TextStyle(
                          color: isUser
                              ? Colors.white
                              : (isDark ? Colors.white : const Color(0xFF1E293B)),
                          fontSize: 13.5,
                          height: 1.45,
                        ),
                      ),
                      if (!isUser && msg.destinationPlace != null && msg.destinationPlace!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black38 : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.primaryLight.withValues(alpha: 0.35),
                            ),
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
                                      style: TextStyle(
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                                  icon: const Icon(Icons.navigation_rounded, size: 14),
                                  label: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Open Map & Guide to ${msg.destinationPlace}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    elevation: 1,
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : Colors.white,
            border: Border(
              top: BorderSide(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Ask about any place in Cambodia...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: isDark ? AppTheme.surfaceDark : const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      : Icon(Icons.send_rounded, color: isDark ? AppTheme.primaryLight : AppTheme.primaryColor),
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

  Widget _buildPromptChip(String text, bool isDark) {
    return ActionChip(
      backgroundColor: isDark ? AppTheme.surfaceDark : const Color(0xFFF1F5F9),
      side: BorderSide(
        color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
      ),
      label: Text(
        text,
        style: TextStyle(
          color: isDark ? Colors.white70 : const Color(0xFF334155),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: () => _sendMessage(text),
    );
  }
}
