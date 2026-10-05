import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class HomeExploreDashboard extends StatefulWidget {
  final VoidCallback? onOpenMenu;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onOpenItinerary;
  final Function(String query)? onSearchDestination;
  final VoidCallback? onOpenAiGuide;

  const HomeExploreDashboard({
    super.key,
    this.onOpenMenu,
    this.onOpenSettings,
    this.onOpenItinerary,
    this.onSearchDestination,
    this.onOpenAiGuide,
  });

  @override
  State<HomeExploreDashboard> createState() => _HomeExploreDashboardState();
}

class _HomeExploreDashboardState extends State<HomeExploreDashboard> {
  final TextEditingController _searchController = TextEditingController();

  // Common provinces & famous destinations across Cambodia
  final List<Map<String, String>> _cambodiaDestinations = [
    {
      'title': 'Siem Reap',
      'province': 'Siem Reap Province',
      'landmark': 'Angkor Wat',
      'tag': '🏛️ UNESCO World Heritage',
      'rating': '5.0 ★',
      'imageUrl': 'https://images.unsplash.com/photo-1544644181-1484b3fdfc62?auto=format&fit=crop&w=800&q=80',
      'description': 'Ancient Angkor empire, Bayon stone faces & Ta Prohm',
    },
    {
      'title': 'Phnom Penh',
      'province': 'Capital City',
      'landmark': 'Royal Palace',
      'tag': '👑 Royal Heritage & Riverside',
      'rating': '4.9 ★',
      'imageUrl': 'https://images.unsplash.com/photo-1583417319070-4a69db38a482?auto=format&fit=crop&w=800&q=80',
      'description': 'Golden spired palace, Mekong riverside & vibrant street culture',
    },
    {
      'title': 'Kampot',
      'province': 'Kampot Province',
      'landmark': 'Bokor National Park',
      'tag': '🌿 Misty Mountains & River',
      'rating': '4.8 ★',
      'imageUrl': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
      'description': 'Bokor plateau views, scenic river cruises & famous pepper farms',
    },
    {
      'title': 'Mondulkiri',
      'province': 'Mondulkiri Province',
      'landmark': 'Bou Sra Waterfall',
      'tag': '🐘 Highlands & Eco Sanctuaries',
      'rating': '4.9 ★',
      'imageUrl': 'https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=800&q=80',
      'description': 'Pine-covered hills, indigenous Bunong culture & thunderous falls',
    },
    {
      'title': 'Battambang',
      'province': 'Battambang Province',
      'landmark': 'Bamboo Train & Bat Caves',
      'tag': '🚂 Art & Cultural Heartland',
      'rating': '4.8 ★',
      'imageUrl': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=800&q=80',
      'description': 'Historic French architecture, Bamboo Train & Phnom Sampeau sunset',
    },
    {
      'title': 'Koh Rong',
      'province': 'Preah Sihanouk Province',
      'landmark': 'Koh Rong Sanloem',
      'tag': '🏝️ Turquoise Island & Coral',
      'rating': '4.9 ★',
      'imageUrl': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
      'description': 'Pure white sands, bioluminescent plankton & marine reefs',
    },
    {
      'title': 'Kep',
      'province': 'Kep Province',
      'landmark': 'Kep Crab Market',
      'tag': '🦀 Coastal Flavors & Rabbit Island',
      'rating': '4.7 ★',
      'imageUrl': 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=800&q=80',
      'description': 'Famous fresh blue crab with Kampot pepper & tranquil beaches',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // 1. Header (Minimalist top bar with menu and profile avatar)
            Row(
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Text('🇰🇭 ', style: TextStyle(fontSize: 14)),
                          Text(
                            'Cambodia Guide',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: widget.onOpenSettings,
                      child: Stack(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
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
                                errorBuilder: (ctx, err, stack) => const Icon(Icons.person, color: AppTheme.primaryLight),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 2,
                            bottom: 2,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? AppTheme.backgroundDark : Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 22),

            // 2. Hero Banner ("Your Journey Across Cambodia, Intelligently Planned.")
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF26392D), const Color(0xFF1B2820)]
                      : [const Color(0xFF3B5344), const Color(0xFF4F6D5B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.4 : 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, color: Color(0xFFA3B899), size: 14),
                        SizedBox(width: 6),
                        Text(
                          'AI-POWERED LOCAL ROUTING',
                          style: TextStyle(
                            color: Color(0xFFDDE8E0),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Explore Cambodia,\nFrom Where You Are.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tell AI what you want to experience — get smart recommendations and instant visual routes across all provinces.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Search Bar (Floating pill-shaped input with green action button)
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isDark ? AppTheme.borderDark : const Color(0xFFE5E9E4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(
                    Icons.location_on_outlined,
                    color: isDark ? AppTheme.accentMint : AppTheme.primaryLight,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search city or landmark (e.g. Angkor Wat)...',
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (q) => widget.onSearchDestination?.call(q),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                      onPressed: () {
                        final text = _searchController.text.trim();
                        if (text.isNotEmpty) {
                          widget.onSearchDestination?.call(text);
                        } else {
                          widget.onOpenAiGuide?.call();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. Horizontal Carousel ("Inspiring Destinations in Cambodia")
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Popular Places in Cambodia',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
                TextButton(
                  onPressed: widget.onOpenItinerary,
                  child: const Text(
                    'Full Itinerary',
                    style: TextStyle(
                      color: AppTheme.primaryLight,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 240,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _cambodiaDestinations.length,
                separatorBuilder: (context, index) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final item = _cambodiaDestinations[index];
                  return GestureDetector(
                    onTap: () {
                      widget.onSearchDestination?.call(item['landmark'] ?? item['title']!);
                    },
                    child: Container(
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              item['imageUrl']!,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => Container(
                                color: AppTheme.primaryLight,
                                child: const Icon(Icons.landscape, size: 48, color: Colors.white70),
                              ),
                            ),
                            // Dark gradient overlay for text readability
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.2),
                                    Colors.black.withValues(alpha: 0.88),
                                  ],
                                  stops: const [0.25, 0.55, 1.0],
                                ),
                              ),
                            ),
                            // Top Tag & Rating
                            Positioned(
                              top: 12,
                              left: 12,
                              right: 12,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        item['tag']!,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.95),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      item['rating']!,
                                      style: const TextStyle(
                                        color: Color(0xFF1E293B),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Bottom Title & Description
                            Positioned(
                              bottom: 14,
                              left: 14,
                              right: 14,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['landmark']!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    item['province']!,
                                    style: const TextStyle(
                                      color: Color(0xFFA3B899),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['description']!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.85),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 26),

            // 5. Quick Actions Grid (Icon grid with shortcuts)
            const Text(
              'Route from Your Location',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _buildQuickAction(
                  context: context,
                  icon: Icons.temple_buddhist_rounded,
                  label: 'Angkor Wat',
                  color: const Color(0xFF10B981),
                  onTap: () => widget.onSearchDestination?.call('Angkor Wat'),
                ),
                const SizedBox(width: 8),
                _buildQuickAction(
                  context: context,
                  icon: Icons.location_city_rounded,
                  label: 'Phnom Penh',
                  color: const Color(0xFF3B82F6),
                  onTap: () => widget.onSearchDestination?.call('Royal Palace, Phnom Penh'),
                ),
                const SizedBox(width: 8),
                _buildQuickAction(
                  context: context,
                  icon: Icons.landscape_rounded,
                  label: 'Bokor Kampot',
                  color: const Color(0xFFF59E0B),
                  onTap: () => widget.onSearchDestination?.call('Bokor Mountain, Kampot'),
                ),
                const SizedBox(width: 8),
                _buildQuickAction(
                  context: context,
                  icon: Icons.auto_awesome_rounded,
                  label: 'Ask AI Guide',
                  color: const Color(0xFF8B5CF6),
                  onTap: widget.onOpenAiGuide,
                ),
              ],
            ),
            const SizedBox(height: 26),

            // 6. AI Bottom Banner ("Tell AI where you want to go")
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : const Color(0xFFEFF5F0),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppTheme.borderDark : const Color(0xFFD4E3D7),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tell AI your dream trip',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'AI plots your route across Cambodia instantly.',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: widget.onOpenAiGuide,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Ask AI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppTheme.borderDark : const Color(0xFFE5E9E4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
