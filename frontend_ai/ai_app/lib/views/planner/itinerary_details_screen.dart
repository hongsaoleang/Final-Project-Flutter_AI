import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ItineraryDetailsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final Function(String placeName)? onNavigateToPlace;

  const ItineraryDetailsScreen({
    super.key,
    this.onBack,
    this.onNavigateToPlace,
  });

  @override
  State<ItineraryDetailsScreen> createState() => _ItineraryDetailsScreenState();
}

class _ItineraryDetailsScreenState extends State<ItineraryDetailsScreen> {
  int _selectedTabIndex = 0;
  bool _isBookmarked = true;

  final List<String> _tabs = ['Itinerary', 'Transport', 'Stay', 'Recommendations'];

  final List<Map<String, dynamic>> _cambodiaDays = [
    {
      'day': 'Day 1',
      'title': 'Phnom Penh Royal Heritage & Riverside',
      'time': '08:00 AM - 05:30 PM',
      'location': 'Royal Palace, Silver Pagoda & Sisowath Quay',
      'province': 'Phnom Penh',
      'ecoBadge': '🌱 Electric Tuk-Tuk Tour',
      'description': 'Explore the golden spires of the Royal Palace, National Museum Khmer artifacts, and an evening sunset boat on the Mekong.',
      'imageUrl': 'https://images.unsplash.com/photo-1583417319070-4a69db38a482?auto=format&fit=crop&w=600&q=80',
    },
    {
      'day': 'Day 2',
      'title': 'Kampot River & Bokor Hill Station',
      'time': '07:30 AM - 05:00 PM',
      'location': 'Preah Monivong Bokor National Park & Teuk Chhou',
      'province': 'Kampot',
      'ecoBadge': '🍃 Organic Pepper Plantation',
      'description': 'Climb up Bokor Mountain through misty clouds, visit old colonial relics, scenic waterfalls, and a relaxing river kayak.',
      'imageUrl': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=600&q=80',
    },
    {
      'day': 'Day 3',
      'title': 'Angkor Wat Sunrise & Ancient Temples',
      'time': '05:00 AM - 04:30 PM',
      'location': 'Angkor Wat, Bayon & Ta Prohm',
      'province': 'Siem Reap',
      'ecoBadge': '🚲 Solar E-Bike Trail',
      'description': 'Iconic sunrise over Angkor Wat reflection pond, 216 giant smiling stone faces of Bayon, and the roots of Ta Prohm.',
      'imageUrl': 'https://images.unsplash.com/photo-1544644181-1484b3fdfc62?auto=format&fit=crop&w=600&q=80',
    },
    {
      'day': 'Day 4',
      'title': 'Phnom Kulen Waterfall & River of Lingas',
      'time': '08:00 AM - 03:30 PM',
      'location': 'Phnom Kulen National Park',
      'province': 'Siem Reap',
      'ecoBadge': '🌊 Sacred Forest & Falls',
      'description': 'Sacred birthplace of the Khmer Empire, 1,000 carved lingas under crystal clear stream waters, and refreshing jungle falls.',
      'imageUrl': 'https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=600&q=80',
    },
    {
      'day': 'Day 5',
      'title': 'Battambang Bamboo Train & Bat Cave',
      'time': '09:00 AM - 06:30 PM',
      'location': 'Wat Banan, Bamboo Railway & Phnom Sampeau',
      'province': 'Battambang',
      'ecoBadge': '🚂 Local Community Railway',
      'description': 'Ride the legendary bamboo norry train through rice paddies, visit hilltop pagodas, and witness millions of bats emerging at dusk.',
      'imageUrl': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=600&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: isDark ? Colors.white : const Color(0xFF1C2820)),
                    onPressed: widget.onBack,
                  ),
                  const Expanded(
                    child: Text(
                      'Cambodia Grand Route',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: _isBookmarked ? AppTheme.primaryColor : Colors.grey,
                    ),
                    onPressed: () => setState(() => _isBookmarked = !_isBookmarked),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert_rounded),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Route options: Export route, Save offline, Share with friends')),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Content List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // 2. Trip Meta Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? AppTheme.borderDark : const Color(0xFFE5E9E4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Cambodia Discovery',
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.edit_outlined, size: 18, color: AppTheme.primaryLight),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Participant Avatars
                            SizedBox(
                              width: 60,
                              height: 28,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: AppTheme.primaryLight,
                                      child: const Text('K', style: TextStyle(color: Colors.white, fontSize: 11)),
                                    ),
                                  ),
                                  Positioned(
                                    left: 18,
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: const Color(0xFF10B981),
                                      child: const Text('P', style: TextStyle(color: Colors.white, fontSize: 11)),
                                    ),
                                  ),
                                  Positioned(
                                    left: 36,
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: const Color(0xFFF59E0B),
                                      child: const Text('+3', style: TextStyle(color: Colors.white, fontSize: 9)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Phnom Penh ➔ Kampot ➔ Siem Reap ➔ Battambang',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppTheme.accentMint : AppTheme.primaryLight,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded, size: 13, color: AppTheme.primaryColor),
                                  SizedBox(width: 6),
                                  Text(
                                    '5 Days / 4 Nights',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Kingdom of Cambodia',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. AI Route Optimization Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF26392D), const Color(0xFF1C2C22)]
                            : [const Color(0xFFEBF3ED), const Color(0xFFDFECE3)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? AppTheme.borderDark : const Color(0xFFBFD8C6),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.alt_route_rounded, color: Colors.white, size: 16),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'AI Inter-Province Route',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                '✓ Optimized',
                                style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(child: _buildMetricItem(title: 'Road Range', value: '314 km', icon: Icons.straighten_rounded)),
                            Container(width: 1, height: 28, color: Colors.grey.withValues(alpha: 0.3)),
                            Expanded(child: _buildMetricItem(title: 'Bus/Taxi', value: '~\$18 - \$45', icon: Icons.payments_outlined)),
                            Container(width: 1, height: 28, color: Colors.grey.withValues(alpha: 0.3)),
                            Expanded(child: _buildMetricItem(title: 'Via Expressway', value: 'National R6', icon: Icons.navigation_outlined, highlight: true)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 4. Tab Switcher
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_tabs.length, (index) {
                        final isSelected = _selectedTabIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(_tabs[index]),
                            selected: isSelected,
                            onSelected: (val) {
                              setState(() => _selectedTabIndex = index);
                            },
                            selectedColor: AppTheme.primaryColor,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : (isDark ? Colors.grey.shade300 : const Color(0xFF2C3E35)),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13,
                            ),
                            backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
                            side: BorderSide(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : (isDark ? AppTheme.borderDark : const Color(0xFFE5E9E4)),
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. Timeline List (Step-by-step Cambodian destinations)
                  ..._cambodiaDays.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark ? AppTheme.borderDark : const Color(0xFFE5E9E4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(
                                  item['imageUrl'],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => Container(
                                    width: 80,
                                    height: 80,
                                    color: AppTheme.primaryLight,
                                    child: const Icon(Icons.place, color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryLight.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${item['day']} • ${item['province']}',
                                            style: const TextStyle(
                                              color: AppTheme.primaryLight,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          item['time'],
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item['title'],
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.place_outlined, size: 13, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            item['location'],
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item['ecoBadge'],
                                        style: const TextStyle(
                                          color: Color(0xFF10B981),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {
                                  widget.onNavigateToPlace?.call(item['location']);
                                },
                                icon: const Icon(Icons.navigation_outlined, size: 14),
                                label: const Text('View on Map', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primaryLight,
                                  side: BorderSide(color: AppTheme.primaryLight.withValues(alpha: 0.5)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            // 6. Bottom Action
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppTheme.borderDark : const Color(0xFFE5E9E4),
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    widget.onNavigateToPlace?.call('Angkor Wat, Siem Reap');
                  },
                  icon: const Icon(Icons.map_rounded, size: 20),
                  label: const Text(
                    'Plot Full Route on Map',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required String title,
    required String value,
    required IconData icon,
    bool highlight = false,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: highlight ? const Color(0xFF10B981) : Colors.grey),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: highlight ? const Color(0xFF10B981) : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}
