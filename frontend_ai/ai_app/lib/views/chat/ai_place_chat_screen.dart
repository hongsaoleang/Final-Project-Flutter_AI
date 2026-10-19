import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/chat_message.dart';
import '../../services/ai_service.dart';
import '../../services/map_service.dart';
import '../../services/user_location_service.dart';

class AiPlaceChatScreen extends StatefulWidget {
  final Function(String query)? onNavigateToMap;
  final VoidCallback? onOpenMenu;
  final VoidCallback? onOpenSettings;

  const AiPlaceChatScreen({
    super.key,
    this.onNavigateToMap,
    this.onOpenMenu,
    this.onOpenSettings,
  });

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
        sender: 'der_leng',
        text: '👋 Suosdei! I am **DER LENG**, your AI Travel & Navigation Guide in Cambodia.\n\nTell me where you want to go or what experience you are looking for in Cambodia! I will recommend popular spots across **Phnom Penh, Siem Reap, Kampot, Kep, Battambang, Mondulkiri, Koh Rong**, and plot the route directly from your location on the map.\n\n💡 Try asking:\n• *"Recommend the best places to visit in Siem Reap"*\n• *"What are common attractions in Phnom Penh?"*\n• *"Take me to Bokor Mountain in Kampot"*\n• *"Tell me about Battambang Bamboo Train"*\n• *"I want to see waterfalls and nature in Mondulkiri"*\n• *"How far is Angkor Wat from Phnom Penh?"*',
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

      // Direct handle for user asking for current state or location
      if (lower.contains('share location') ||
          lower.contains('my location') ||
          lower.contains('where am i') ||
          lower.contains('current state') ||
          lower.contains('current location') ||
          lower.contains('my state')) {
        final loc = UserLocationService();
        final state = loc.state;
        final city = loc.city;
        final country = loc.country;
        final addr = loc.formattedAddress;
        final coords = loc.effectiveOrigin.coordinates;
        final coordsStr = '${coords.latitude.toStringAsFixed(6)}, ${coords.longitude.toStringAsFixed(6)}';
        final mapsLink = 'https://www.google.com/maps?q=$coordsStr';

        final stateLine = state.isNotEmpty ? '• **State / Region**: $state\n' : '';
        final cityLine = city.isNotEmpty ? '• **City / Municipality**: $city\n' : '';
        final addrLine = addr.isNotEmpty ? '• **Address**: $addr\n' : '';

        setState(() {
          _messages.add(
            ChatMessageModel(
              sender: 'myai',
              text: '''📍 **Your Current State & Location**:
$stateLine$cityLine• **Country**: $country
$addrLine• **Coordinates**: `$coordsStr`
• **Google Maps**: $mapsLink

💡 Tap the **Share Location** chip at the top right to open the system share sheet, or view it on the Live Map!''',
              mode: AiMode.textGeneration,
              timestamp: DateTime.now(),
            ),
          );
          _isLoading = false;
        });
        _scrollToBottom();
        return;
      }

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
              !res.contains('The AI platform is active and ready') &&
              !res.contains('The destination has been identified in our spatial navigation engine')) {
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
      'Prey Veng', 'Krong Prey Veng', 'Ba Phnom', 'Chhrouy Chek',
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
      'Kratie', 'Stung Treng', 'Svay Rieng', 'Takeo', 'Pursat',
    ];

    for (final p in places) {
      if (lowerQuery.contains(p.toLowerCase())) {
        return p;
      }
    }

    // Check prompt cleaner candidate
    final candidate = MapService.extractDestinationFromPrompt(userQuery);
    if (candidate.isNotEmpty && candidate.length > 2) {
      for (final p in places) {
        if (p.toLowerCase().contains(candidate.toLowerCase()) || candidate.toLowerCase().contains(p.toLowerCase())) {
          return p;
        }
      }
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

    // Smart conversational & greeting handling
    final cleanTrim = query.trim().toLowerCase();
    if (['hi', 'hello', 'hey', 'suosdei', 'good morning', 'good evening', 'yo', 'salut'].contains(cleanTrim)) {
      return '👋 **Suosdei & Welcome!**\n\n'
          'I am **MyAI**, your personal AI assistant and Cambodia travel guide!\n\n'
          'I can help you with:\n'
          '• **Specific Travel Destinations**: Curated sights across Prey Veng, Siem Reap, Phnom Penh, Kampot, Kep, Battambang, Mondulkiri, Koh Rong, Ratanakiri & Preah Vihear.\n'
          '• **Exciting Places to Play**: Adventures, river kayaking, zip lines, night markets & cultural shows.\n'
          '• **Recommended Hotels & Stays**: Top-rated luxury resorts, boutique villas & eco-lodges.\n'
          '• **Live GPS Navigation**: Real-time road distances, drive times, and interactive map routes.\n\n'
          'Where would you like to travel, or what questions can I answer for you today?';
    }

    if (cleanTrim.contains('who are you') || cleanTrim.contains('your name') || cleanTrim.contains('what is myai')) {
      return '🤖 I am **MyAI**, your intelligent travel guide and assistant for Cambodia.\n\n'
          'You can ask me about travel destinations, exciting places to play, recommended hotels, or request live directions and map routes!';
    }

    if (cleanTrim.contains('thank') || cleanTrim.contains('arkun')) {
      return '🙏 **Arkun chroen!** You are very welcome! Let me know whenever you need more travel tips, hotel recommendations, or directions!';
    }

    // Smart thematic recommendations for Cambodia with specific place, play, and hotel details
    final lower = query.toLowerCase();
    String destCandidate = '';
    String thematicIntro = '';
    String placesToPlayText = '';
    String hotelsText = '';

    if (lower.contains('prey veng') || lower.contains('ba phnom') || lower.contains('chhrouy chek')) {
      destCandidate = 'Prey Veng';
      thematicIntro = '🌾 **Specific Destination**: **Krong Prey Veng & Sacred Ba Phnom Hill** (Prey Veng Province)\n• Historic cradle of the ancient Funan kingdom and Nokor Phnom, tranquil lotus lakes, and panoramic southeastern Mekong floodplains.';
      placesToPlayText = '🎯 **Places to Play & Activities**:\n• Hiking up sacred Ba Phnom hill to visit ancient Funan shrines and century-old Wat Vihear Chan\n• Scenic sunset stroll along Krong Prey Veng lakeside promenade and provincial park\n• Eco-boat cruise and fresh local fish cuisine at Chhrouy Chek reservoir\n• Exploring rural lotus fields and local traditional silk and craft communities';
      hotelsText = '🏨 **Recommended Hotels & Stays**:\n• **Prey Veng River Hotel & City Lodge** (4.7 ★, Convenient central town stay with AC & lake views)\n• **Mittapheap Hotel Prey Veng** (4.6 ★, Comfortable provincial hotel near town market)\n• **Kirirom Guesthouse & Garden Resort** (4.6 ★, Relaxing local garden stay with green courtyard)';
    } else if (lower.contains('waterfall') || lower.contains('cascade') || lower.contains('mondulkiri')) {
      destCandidate = 'Bou Sra Waterfall, Mondulkiri';
      thematicIntro = '🌊 **Specific Destination**: **Bou Sra Jungle Cascades & Elephant Valleys** (Mondulkiri Province)\n• Multi-tier thunderous waterfalls surrounded by highland pine forests and indigenous Bunong ethnic villages.';
      placesToPlayText = '🎯 **Places to Play & Activities**:\n• Ethical elephant river bathing & sanctuary jungle walk\n• Canopy zipline flying directly over Bou Sra waterfall\n• Organic Mondulkiri highland coffee farm tasting tour\n• 4x4 off-road safari & camping on rolling green plateaus';
      hotelsText = '🏨 **Recommended Hotels & Stays**:\n• **Mayura Hill Resort** (4.9 ★, Luxury Highland Villas with forest infinity pool)\n• **Pidoma Resort** (4.8 ★, Modern Mountain Resort with valley views)\n• **Nature Lodge Mondulkiri** (4.7 ★, Eco-Cabins with hammocks & horse pastures)';
    } else if (lower.contains('siem reap') || lower.contains('angkor') || lower.contains('temple')) {
      destCandidate = 'Angkor Wat, Siem Reap';
      thematicIntro = '🏛️ **Specific Destination**: **Angkor Wat & Ancient Temples** (Siem Reap Province)\n• UNESCO World Heritage wonder featuring the lotus towers of Angkor Wat, 216 stone faces of Bayon, and the jungle strangler roots of Ta Prohm.';
      placesToPlayText = '🎯 **Places to Play & Activities**:\n• Angkor Zipline eco-canopy obstacle course in the temple park\n• Sunrise hot air balloon tethered flight over the ruins\n• Phare Cambodian Circus acrobatic & theatrical evening show\n• Pub Street night market stroll, pottery workshops & street dining';
      hotelsText = '🏨 **Recommended Hotels & Stays**:\n• **Jaya House RiverPark** (4.9 ★, Luxury Eco-Boutique with saltwater pools)\n• **Raffles Grand Hotel d\'Angkor** (5.0 ★, Historic 5-Star French colonial luxury)\n• **Lub d Cambodia Siem Reap** (4.8 ★, Trendy Boutique Resort with swim-up bar)';
    } else if (lower.contains('phnom penh') || lower.contains('capital') || lower.contains('city')) {
      destCandidate = 'Royal Palace, Phnom Penh';
      thematicIntro = '👑 **Specific Destination**: **Royal Palace & Riverside Promenade** (Phnom Penh Capital)\n• Golden Khmer palace spires, the sacred Emerald Buddha at Silver Pagoda, and breezy riverside dining on Sisowath Quay.';
      placesToPlayText = '🎯 **Places to Play & Activities**:\n• Sunset river cruise on the Mekong and Tonle Sap confluence\n• Silk Island (Koh Dach) rural cycling and silk weaving workshop\n• Bassac Lane boutique cocktail bar crawl and live acoustic music\n• Night market street food tasting and Central Market (Phsar Thmey)';
      hotelsText = '🏨 **Recommended Hotels & Stays**:\n• **Rosewood Phnom Penh** (4.9 ★, Ultra-Luxury with 39th-floor sky bar)\n• **Plantation Urban Resort & Spa** (4.8 ★, Heritage Oasis with lush garden pool)\n• **Palace Gate Hotel & Resort** (4.8 ★, Royal French-Khmer resort by palace)';
    } else if (lower.contains('kampot') || lower.contains('bokor') || lower.contains('river')) {
      destCandidate = 'Bokor Mountain, Kampot';
      thematicIntro = '🌿 **Specific Destination**: **Preah Monivong Bokor National Park & Plateau** (Kampot Province)\n• 1,000m high misty mountain plateau with historic 1920s French colonial relics, waterfalls, and cliff views over the Gulf of Thailand.';
      placesToPlayText = '🎯 **Places to Play & Activities**:\n• Green Cathedral river kayaking & stand-up paddleboarding\n• Evening sunset and firefly riverboat safari along Kampot River\n• Scenic mountain motorbike loop and rainforest trekking\n• Visiting La Plantation organic pepper estate for pepper tasting';
      hotelsText = '🏨 **Recommended Hotels & Stays**:\n• **Castle Bayview Resort & Spa** (4.8 ★, Scenic Mountain Stay with ocean cliff views)\n• **Sabay Beach Eco-Resort** (4.8 ★, Riverfront Eco-Boutique with private dock)\n• **Rikitikitavi Kampot** (4.9 ★, Cozy Riverside Heritage with gourmet dining)';
    } else if (lower.contains('battambang') || lower.contains('bamboo')) {
      destCandidate = 'Bamboo Train, Battambang';
      thematicIntro = '🚂 **Specific Destination**: **Norry Bamboo Railway & Phnom Sampeau Bat Caves** (Battambang Province)\n• Iconic open-air bamboo train gliding through rice fields, paired with the mesmerizing dusk spectacle of 2+ million bats flying out of the cliff cave.';
      placesToPlayText = '🎯 **Places to Play & Activities**:\n• Riding the thrilling 30 km/h Norry Bamboo Train on historic rails\n• Watching millions of bats stream across the evening sky at Phnom Sampeau\n• Attending Phare Ponleu Selpak cultural circus performance\n• Countryside bicycle food tour (rice paper, banana chips & rice wine)';
      hotelsText = '🏨 **Recommended Hotels & Stays**:\n• **Bambu Hotel Battambang** (4.8 ★, Colonial-Khmer Boutique with saltwater pool)\n• **Maisons Wat Kor** (4.9 ★, Eco-Heritage Village Lodge in wooden stilt villas)\n• **Battambang Resort** (4.8 ★, Garden Lake Resort with lily ponds)';
    } else if (lower.contains('beach') || lower.contains('island') || lower.contains('sea') || lower.contains('koh rong')) {
      destCandidate = 'Koh Rong Sanloem';
      thematicIntro = '🏖️ **Specific Destination**: **Saracen Bay & Coral Marine Reefs** (Koh Rong Sanloem, Preah Sihanouk)\n• Powdery white sand bays, turquoise waters, vibrant coral gardens, and glowing nocturnal bioluminescent plankton.';
      placesToPlayText = '🎯 **Places to Play & Activities**:\n• Swimming at night with glowing blue bioluminescent plankton\n• Coral reef scuba diving and snorkeling boat expeditions\n• Sea kayaking across Saracen Bay and Lazy Beach sunset coves\n• High Point Rope Park and jungle canopy zipline challenge';
      hotelsText = '🏨 **Recommended Hotels & Stays**:\n• **The Royal Sands Koh Rong** (5.0 ★, 5-Star Beachfront Luxury with private plunge pools)\n• **Secret Garden Koh Rong Sanloem** (4.8 ★, Beachfront Eco-Boutique on soft white sands)\n• **Sol Beach Resort** (4.9 ★, Khmer Architecture beachfront villas)';
    } else if (lower.contains('kep') || lower.contains('crab')) {
      destCandidate = 'Kep Crab Market, Kep';
      thematicIntro = '🦀 **Specific Destination**: **Kep Crab Market & Rabbit Island (Koh Tonsay)** (Kep Province)\n• Famous blue swimmer crab caught and sautéed with fresh green Kampot pepper, Rabbit Island beach relaxation, and Kep National Park trails.';
      placesToPlayText = '🎯 **Places to Play & Activities**:\n• Feasting on fresh blue crab cooked right on the waterfront wooden pier\n• Taking a wooden longtail boat to Rabbit Island (Koh Tonsay) for hammock lounging\n• Sea sailing, kayaking, and sunset drinks at Kep Sailing Club\n• Hiking the 8km Stairway to Heaven jungle trail in Kep National Park';
      hotelsText = '🏨 **Recommended Hotels & Stays**:\n• **Knai Bang Chatt Resort** (4.9 ★, Luxury Historic Seaside Villa with infinity pool)\n• **Veranda Natural Resort** (4.8 ★, Hillside Eco-Retreat with wooden sky-walks)\n• **Samanea Beach Resort & Spa** (4.8 ★, Botanical Mangrove Resort with private jetty)';
    } else {
      destCandidate = query
          .replaceAll(
            RegExp(
              r'(i want to go to|how to go to|guide me to|take me to|navigate to|go to|directions to|travel to|where is|tell me about|recommend|show me|hotel|play)',
              caseSensitive: false,
            ),
            '',
          )
          .trim();
      if (destCandidate.isEmpty) destCandidate = 'Prey Veng';
      thematicIntro = '📍 **Specific Destination**: $destCandidate, Cambodia';
      placesToPlayText = '🎯 **Places to Play & Activities**:\n• Local cultural sightseeing, historic discovery & photography\n• Scenic walking routes, regional food spots & local markets';
      hotelsText = '🏨 **Recommended Hotels & Stays**:\n• Top-rated local hotels and boutique stays in $destCandidate';
    }

    final results = await _mapService.searchPlace(destCandidate);
    if (results.isNotEmpty) {
      final destPlace = results.first;
      final distMeters = _mapService.calculateDistanceMeters(
        locService.effectiveOrigin.coordinates,
        destPlace.coordinates,
      );
      final distKm = distMeters / 1000.0;
      final distMiles = distKm * 0.621371;
      final estDriveHours = (distKm / 55.0);
      final driveTimeText = estDriveHours < 1.0
          ? '${(estDriveHours * 60).round()} mins'
          : '${estDriveHours.floor()}h ${((estDriveHours - estDriveHours.floor()) * 60).round()}m';

      return '''$thematicIntro

$placesToPlayText

$hotelsText

🗺️ **Live Navigation & Route Guidance**:
• **From**: $originName
• **To**: ${destPlace.displayName}
• **Distance**: ${distKm.toStringAsFixed(1)} km (${distMiles.toStringAsFixed(1)} miles)
• **Estimated Time**: ~$driveTimeText via national highway

💡 *Tap below to plot the interactive route directly on the **Live Map**!*''';
    }

    return '''🧭 **Cambodia AI Travel & Hotel Guide**:
Here is my recommendation for "$query":
$thematicIntro

$placesToPlayText

$hotelsText

• Tap below or switch to the **Map** tab to explore interactive routes!''';
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

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
        // Top Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: widget.onOpenMenu ?? widget.onOpenSettings,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppTheme.borderDark : const Color(0xFFE5E9E4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.sort_rounded,
                    color: isDark ? AppTheme.accentMint : AppTheme.primaryColor,
                    size: 22,
                  ),
                ),
              ),
              // Live Location & Share Button
              ListenableBuilder(
                listenable: UserLocationService(),
                builder: (context, _) {
                  final loc = UserLocationService();
                  final isGps = loc.isGpsActive && loc.currentGpsPosition != null;
                  final displayLoc = isGps
                      ? (loc.state.isNotEmpty ? loc.state : loc.city)
                      : loc.city;

                  return InkWell(
                    onTap: () => UserLocationService().shareLiveLocation(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isGps
                            ? Colors.greenAccent.withValues(alpha: 0.15)
                            : AppTheme.primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isGps
                              ? Colors.greenAccent.withValues(alpha: 0.6)
                              : AppTheme.primaryLight.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isGps ? Icons.gps_fixed : Icons.share_location,
                            size: 14,
                            color: isGps ? Colors.greenAccent : AppTheme.primaryLight,
                          ),
                          const SizedBox(width: 5),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 120),
                            child: Text(
                              displayLoc,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isGps
                                    ? Colors.greenAccent
                                    : (isDark ? Colors.white : AppTheme.primaryColor),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.share,
                            size: 11,
                            color: isGps ? Colors.greenAccent : AppTheme.primaryLight,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              GestureDetector(
                onTap: widget.onOpenSettings,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryLight,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => const Icon(
                        Icons.person,
                        color: AppTheme.primaryLight,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

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
