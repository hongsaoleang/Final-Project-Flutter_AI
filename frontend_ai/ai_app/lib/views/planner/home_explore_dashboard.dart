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
  String _selectedCategory = 'All';
  final Set<String> _bookmarkedPlaces = {'Angkor Wat'};

  final List<String> _categories = [
    'All',
    'Heritage',
    'Nature',
    'Culture',
    'Islands & Coast',
  ];

  // Common provinces & famous destinations across Cambodia
  final List<Map<String, String>> _cambodiaDestinations = [
    {
      'title': 'Siem Reap',
      'province': 'Siem Reap Province',
      'landmark': 'Angkor Wat',
      'category': 'Heritage',
      'tag': '🏛️ UNESCO World Heritage',
      'rating': '5.0 ★',
      'imageUrl': 'https://images.unsplash.com/photo-1544644181-1484b3fdfc62?auto=format&fit=crop&w=800&q=80',
      'description': 'Ancient Angkor empire, Bayon stone faces & Ta Prohm jungle temple.',
    },
    {
      'title': 'Phnom Penh',
      'province': 'Capital City',
      'landmark': 'Royal Palace',
      'category': 'Culture',
      'tag': '👑 Royal Heritage & Riverside',
      'rating': '4.9 ★',
      'imageUrl': 'https://images.unsplash.com/photo-1583417319070-4a69db38a482?auto=format&fit=crop&w=800&q=80',
      'description': 'Golden spired palace, Mekong riverside promenade & vibrant street culture.',
    },
    {
      'title': 'Kampot',
      'province': 'Kampot Province',
      'landmark': 'Bokor National Park',
      'category': 'Nature',
      'tag': '🌿 Misty Mountains & River',
      'rating': '4.8 ★',
      'imageUrl': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
      'description': 'Bokor plateau views, scenic river cruises & famous organic pepper farms.',
    },
    {
      'title': 'Mondulkiri',
      'province': 'Mondulkiri Province',
      'landmark': 'Bou Sra Waterfall',
      'category': 'Nature',
      'tag': '🐘 Highlands & Eco Sanctuaries',
      'rating': '4.9 ★',
      'imageUrl': 'https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=800&q=80',
      'description': 'Pine-covered hills, indigenous Bunong culture & thunderous jungle falls.',
    },
    {
      'title': 'Battambang',
      'province': 'Battambang Province',
      'landmark': 'Bamboo Train & Bat Caves',
      'category': 'Culture',
      'tag': '🚂 Art & Cultural Heartland',
      'rating': '4.8 ★',
      'imageUrl': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=800&q=80',
      'description': 'Historic French architecture, Bamboo Railway & Phnom Sampeau sunset.',
    },
    {
      'title': 'Koh Rong',
      'province': 'Preah Sihanouk Province',
      'landmark': 'Koh Rong Sanloem',
      'category': 'Islands & Coast',
      'tag': '🏝️ Turquoise Island & Coral',
      'rating': '4.9 ★',
      'imageUrl': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
      'description': 'Pure white sands, bioluminescent plankton & vibrant marine coral reefs.',
    },
    {
      'title': 'Kep',
      'province': 'Kep Province',
      'landmark': 'Kep Crab Market',
      'category': 'Islands & Coast',
      'tag': '🦀 Coastal Flavors & Rabbit Island',
      'rating': '4.7 ★',
      'imageUrl': 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=800&q=80',
      'description': 'Famous fresh blue crab with Kampot green pepper & tranquil coastal beaches.',
    },
  ];

  List<Map<String, String>> get _filteredDestinations {
    final query = _searchController.text.trim().toLowerCase();
    return _cambodiaDestinations.where((item) {
      final matchesCategory = _selectedCategory == 'All' ||
          item['category'] == _selectedCategory;
      final matchesQuery = query.isEmpty ||
          (item['title'] ?? '').toLowerCase().contains(query) ||
          (item['landmark'] ?? '').toLowerCase().contains(query) ||
          (item['province'] ?? '').toLowerCase().contains(query) ||
          (item['description'] ?? '').toLowerCase().contains(query) ||
          (item['tag'] ?? '').toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final destinations = _filteredDestinations;

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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.primaryLight.withValues(alpha: 0.25),
                        ),
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
                                errorBuilder: (ctx, err, stack) => const Icon(
                                  Icons.person,
                                  color: AppTheme.primaryLight,
                                ),
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
            const SizedBox(height: 20),

            // 2. Hero Banner
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
                    'Browse all destinations in a clean column view, get smart recommendations, and map your visual routes instantly.',
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

            // 3. Search Bar with instant filtering and clear button
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
                        hintText: 'Search destination, city, or landmark...',
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (q) => widget.onSearchDestination?.call(q),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                      },
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
            const SizedBox(height: 20),

            // 4. Quick Route Shortcuts (2x2 Grid Layout)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quick Route Highlights',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
                TextButton(
                  onPressed: widget.onOpenAiGuide,
                  child: const Text(
                    'AI Plan',
                    style: TextStyle(
                      color: AppTheme.primaryLight,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildQuickActionCard(
                  context: context,
                  icon: Icons.temple_buddhist_rounded,
                  title: 'Angkor Wat',
                  subtitle: 'Siem Reap',
                  color: const Color(0xFF10B981),
                  onTap: () => widget.onSearchDestination?.call('Angkor Wat'),
                ),
                const SizedBox(width: 12),
                _buildQuickActionCard(
                  context: context,
                  icon: Icons.location_city_rounded,
                  title: 'Royal Palace',
                  subtitle: 'Phnom Penh',
                  color: const Color(0xFF3B82F6),
                  onTap: () => widget.onSearchDestination?.call('Royal Palace, Phnom Penh'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildQuickActionCard(
                  context: context,
                  icon: Icons.landscape_rounded,
                  title: 'Bokor Hill',
                  subtitle: 'Kampot',
                  color: const Color(0xFFF59E0B),
                  onTap: () => widget.onSearchDestination?.call('Bokor Mountain, Kampot'),
                ),
                const SizedBox(width: 12),
                _buildQuickActionCard(
                  context: context,
                  icon: Icons.auto_awesome_rounded,
                  title: 'AI Guide',
                  subtitle: 'Instant Routes',
                  color: const Color(0xFF8B5CF6),
                  onTap: widget.onOpenAiGuide,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 5. Popular Places in Cambodia Header & Category Filters
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Popular Places in Cambodia',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${destinations.length} destinations available',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppTheme.accentMint : AppTheme.primaryLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
            const SizedBox(height: 12),

            // Category Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : (isDark ? AppTheme.cardDark : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : (isDark ? AppTheme.borderDark : const Color(0xFFE5E9E4)),
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                          ],
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : const Color(0xFF2C3E30)),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // 6. ALL DESTINATIONS DISPLAYED AS A COLUMN
            if (destinations.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppTheme.borderDark : const Color(0xFFE5E9E4),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.travel_explore_rounded,
                      size: 48,
                      color: isDark ? AppTheme.accentMint : AppTheme.primaryLight,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No destinations found',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Try adjusting your search or switching category filters.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = 'All';
                          _searchController.clear();
                        });
                      },
                      child: const Text('Reset Filters'),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: destinations.map((item) {
                  return _buildDestinationColumnCard(context, item, isDark);
                }).toList(),
              ),

            const SizedBox(height: 14),

            // 7. AI Bottom Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : const Color(0xFFEFF5F0),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark ? AppTheme.borderDark : const Color(0xFFD4E3D7),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
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
                        const SizedBox(height: 3),
                        Text(
                          'AI maps custom routes across all Cambodian provinces instantly.',
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
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Ask AI',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
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

  // Column Card for Each Destination
  Widget _buildDestinationColumnCard(
    BuildContext context,
    Map<String, String> item,
    bool isDark,
  ) {
    final isBookmarked = _bookmarkedPlaces.contains(item['landmark']);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : const Color(0xFFE5E9E4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              widget.onSearchDestination?.call(item['landmark'] ?? item['title']!);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Cover Image with Badges
                SizedBox(
                  height: 190,
                  width: double.infinity,
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
                      // Gradient overlay for bottom edge
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.35),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.65),
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),
                      // Top Row: Tag badge and Bookmark action
                      Positioned(
                        top: 12,
                        left: 12,
                        right: 12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                item['tag']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  final name = item['landmark']!;
                                  if (_bookmarkedPlaces.contains(name)) {
                                    _bookmarkedPlaces.remove(name);
                                  } else {
                                    _bookmarkedPlaces.add(name);
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                  color: isBookmarked ? const Color(0xFF10B981) : Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Bottom Row over Image: Rating and Province
                      Positioned(
                        bottom: 12,
                        left: 14,
                        right: 14,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.place_rounded, color: Color(0xFFA3B899), size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  item['province']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black87,
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item['rating']!,
                                style: const TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Card Details & Actions
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              item['landmark']!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item['title']!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['description']!,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.45,
                          color: isDark ? Colors.grey.shade300 : const Color(0xFF4A5568),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Divider(
                        height: 1,
                        color: isDark ? AppTheme.borderDark : const Color(0xFFEDF2EC),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.near_me_outlined,
                                size: 15,
                                color: isDark ? AppTheme.accentMint : AppTheme.primaryLight,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Interactive Route Map',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppTheme.accentMint : AppTheme.primaryLight,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              widget.onSearchDestination?.call(item['landmark'] ?? item['title']!);
                            },
                            icon: const Text(
                              'Explore Route',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            label: const Icon(Icons.arrow_forward_rounded, size: 15),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Quick Action Card (for 2x2 grid)
  Widget _buildQuickActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
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
  }
}
