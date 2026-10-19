import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/user_location_service.dart';

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

  // Specific well-known travel places, activities to play, and recommended hotels across Cambodia
  final List<Map<String, dynamic>> _cambodiaDestinations = [
    {
      'title': 'Angkor Wat & Ancient Temples',
      'province': 'Siem Reap Province',
      'landmark': 'Angkor Wat',
      'category': 'Heritage',
      'tag': '🏛️ UNESCO World Wonder',
      'rating': '5.0 ★',
      'imageUrl': 'https://images.unsplash.com/photo-1544644181-1484b3fdfc62?auto=format&fit=crop&w=800&q=80',
      'description': 'Ancient Khmer empire wonder with iconic lotus towers, the smiling stone faces of Bayon, and the jungle strangler roots of Ta Prohm.',
      'placesToTravel': [
        'Angkor Wat Central Sanctuary & Reflection Pool',
        'Bayon Temple (216 Giant Smiling Stone Faces)',
        'Ta Prohm (Tomb Raider Jungle Tree Roots)',
        'Banteay Srei (Pink Sandstone Citadel of Women)',
      ],
      'placesToPlay': [
        'Angkor Zipline Eco-Canopy Adventure',
        'Sunrise Hot Air Balloon Flight over Temples',
        'Phare Cambodian Circus Acrobatic Show',
        'Pub Street Night Market & Food Stroll',
      ],
      'hotels': [
        {
          'name': 'Jaya House RiverPark',
          'rating': '4.9 ★',
          'price': '\$\$\$\$',
          'type': 'Luxury Eco-Boutique',
          'perk': 'Saltwater pools & complimentary tuk-tuks',
        },
        {
          'name': 'Raffles Grand Hotel d\'Angkor',
          'rating': '5.0 ★',
          'price': '\$\$\$\$\$',
          'type': 'Historic Heritage 5-Star',
          'perk': 'French colonial grandeur & spa',
        },
        {
          'name': 'Lub d Cambodia Siem Reap',
          'rating': '4.8 ★',
          'price': '\$\$',
          'type': 'Trendy Boutique Resort',
          'perk': 'Swim-up pool bar & social game lounge',
        },
      ],
    },
    {
      'title': 'Royal Palace & Riverside Promenade',
      'province': 'Phnom Penh Capital',
      'landmark': 'Royal Palace',
      'category': 'Culture',
      'tag': '👑 Royal Heritage & Riverfront',
      'rating': '4.9 ★',
      'imageUrl': 'https://images.unsplash.com/photo-1583417319070-4a69db38a482?auto=format&fit=crop&w=800&q=80',
      'description': 'Classic golden Khmer spires, the sacred Silver Pagoda, and the scenic promenade along the Mekong and Tonle Sap river confluence.',
      'placesToTravel': [
        'Royal Palace Throne Hall & Silver Pagoda (Emerald Buddha)',
        'National Museum of Cambodia (Ancient Bronzes & Statues)',
        'Wat Phnom Historic Hilltop Sanctuary',
        'Sisowath Quay Riverfront Promenade',
      ],
      'placesToPlay': [
        'Sunset Boat Cruise on Mekong & Tonle Sap Confluence',
        'Koh Dach (Silk Island) Countryside Cycling Tour',
        'Bassac Lane Boutique Cocktails & Live Music',
        'Central Market (Phsar Thmey) & Night Food Bazaar',
      ],
      'hotels': [
        {
          'name': 'Rosewood Phnom Penh',
          'rating': '4.9 ★',
          'price': '\$\$\$\$\$',
          'type': 'Ultra-Luxury High-Rise',
          'perk': '39th-floor sky bar overlooking Mekong',
        },
        {
          'name': 'Plantation Urban Resort & Spa',
          'rating': '4.8 ★',
          'price': '\$\$\$',
          'type': 'Heritage Oasis Boutique',
          'perk': 'Lush garden pool behind Royal Palace',
        },
        {
          'name': 'Palace Gate Hotel & Resort',
          'rating': '4.8 ★',
          'price': '\$\$\$\$',
          'type': 'Royal French-Khmer Resort',
          'perk': 'Direct palace views & herbal spa',
        },
      ],
    },
    {
      'title': 'Preah Monivong Bokor National Park & Plateau',
      'province': 'Kampot Province',
      'landmark': 'Bokor Mountain',
      'category': 'Nature',
      'tag': '🌿 Misty Mountain & River Safaris',
      'rating': '4.8 ★',
      'imageUrl': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
      'description': 'Cool mountain plateau 1,000m high with historic 1920s French hill station relics, waterfalls, and cliff views over the Gulf of Thailand.',
      'placesToTravel': [
        'Old French Catholic Church & Bokor Palace Ruins',
        'Popokvil 2-Tier Waterfall & Mountain Pools',
        'Lok Yeay Mao 29m Giant Mountain Monument',
        'La Plantation Certified Organic Pepper Estate',
      ],
      'placesToPlay': [
        'Green Cathedral River Kayaking & Paddleboarding',
        'Evening Firefly Riverboat Safari on Kampot River',
        'Rainforest Hiking Trails & Cloud Lookout Points',
        'Scenic Motorbike Loop to Misty Ocean Cliffs',
      ],
      'hotels': [
        {
          'name': 'Castle Bayview Resort & Spa',
          'rating': '4.8 ★',
          'price': '\$\$\$',
          'type': 'Scenic Mountain Resort',
          'perk': 'Panoramic cliff views of the ocean',
        },
        {
          'name': 'Sabay Beach Eco-Resort',
          'rating': '4.8 ★',
          'price': '\$\$',
          'type': 'Riverfront Eco-Boutique',
          'perk': 'Private river beach & boat dock',
        },
        {
          'name': 'Rikitikitavi Kampot',
          'rating': '4.9 ★',
          'price': '\$\$',
          'type': 'Cozy Riverside Heritage',
          'perk': 'Rooftop cocktail deck & gourmet dining',
        },
      ],
    },
    {
      'title': 'Phnom Kulen Holy Waterfall & 1,000 Lingas',
      'province': 'Siem Reap Province',
      'landmark': 'Phnom Kulen',
      'category': 'Heritage',
      'tag': '🌊 Sacred Cascades & Holy Mountain',
      'rating': '4.9 ★',
      'imageUrl': 'https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=800&q=80',
      'description': 'Sacred birthplace of the Khmer Empire on a lush plateau with underwater stone carvings, multi-tiered waterfalls, and giant reclining Buddha.',
      'placesToTravel': [
        'Kbal Spean River of 1,000 Carved Lingas',
        'Preah Ang Thom 16th-Century Giant Reclining Buddha',
        'Phnom Kulen Grand Waterfall & Jungle Pool',
        'Srah Damrei (Sacred Giant Stone Elephant Pond)',
      ],
      'placesToPlay': [
        'Swimming in Refreshing Sacred Waterfall Pools',
        'Jungle Trail Quad-Biking & Buggy Safaris',
        'Bamboo Picnic Huts Over Running Mountain Streams',
        'Ethical Elephant Forest Trekking in Kulen Foothills',
      ],
      'hotels': [
        {
          'name': 'Kulen Elephant Forest Retreat',
          'rating': '4.9 ★',
          'price': '\$\$\$\$',
          'type': 'Eco-Glamping Sanctuary',
          'perk': 'Private forest tents & elephant walks',
        },
        {
          'name': 'Anantara Angkor Resort',
          'rating': '4.9 ★',
          'price': '\$\$\$\$\$',
          'type': 'Luxury All-Suite Resort',
          'perk': 'Curated Kulen day expeditions & spa',
        },
        {
          'name': 'Treasure Oasis Hotel',
          'rating': '4.7 ★',
          'price': '\$\$',
          'type': 'Comfortable Pool Resort',
          'perk': 'Large central pool & tour services',
        },
      ],
    },
    {
      'title': 'Norry Bamboo Railway & Bat Cave Sunset',
      'province': 'Battambang Province',
      'landmark': 'Bamboo Train',
      'category': 'Culture',
      'tag': '🚂 Bamboo Train Thrills & Cave Wonder',
      'rating': '4.8 ★',
      'imageUrl': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=800&q=80',
      'description': 'Legendary Norry open rail cars gliding past emerald rice fields, combined with the awe-inspiring dusk exodus of millions of bats at Phnom Sampeau.',
      'placesToTravel': [
        'Historic Norry Bamboo Train Tracks & Stations',
        'Phnom Sampeau Golden Hilltop Pagoda & Viewpoints',
        'Wat Banan 11th-Century Angkorian Hilltop Shrine',
        'Battambang Colonial French Heritage Quarter',
      ],
      'placesToPlay': [
        'Riding the Legendary 30 km/h Open Bamboo Norry Train',
        'Watching 2+ Million Bats Stream Out of Cave at Sunset',
        'Phare Ponleu Selpak Circus & Performing Arts Show',
        'Local Rice Paper, Banana Chips & Rice Wine Food Walk',
      ],
      'hotels': [
        {
          'name': 'Bambu Hotel Battambang',
          'rating': '4.8 ★',
          'price': '\$\$\$',
          'type': 'Colonial-Khmer Boutique',
          'perk': 'Saltwater pool surrounded by palms',
        },
        {
          'name': 'Maisons Wat Kor',
          'rating': '4.9 ★',
          'price': '\$\$\$',
          'type': 'Eco-Heritage Village Lodge',
          'perk': 'Traditional wooden stilt villas',
        },
        {
          'name': 'Battambang Resort',
          'rating': '4.8 ★',
          'price': '\$\$\$',
          'type': 'Garden Lake Resort',
          'perk': 'Tranquil lily ponds & gourmet restaurant',
        },
      ],
    },
    {
      'title': 'Saracen Bay & Coral Marine Reefs',
      'province': 'Preah Sihanouk Province',
      'landmark': 'Koh Rong Sanloem',
      'category': 'Islands & Coast',
      'tag': '🏝️ Turquoise Waters & Glowing Plankton',
      'rating': '4.9 ★',
      'imageUrl': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
      'description': 'Powdery white beaches, secluded sunset coves, tropical coral gardens, and nighttime bioluminescent plankton that lights up the ocean.',
      'placesToTravel': [
        'Saracen Bay 3km Crescent White Sand Beach',
        'Lazy Beach & Sunset Beach Secluded Coves',
        'Historic French Lighthouse Island Viewpoint',
        'Clear Water Bay Marine Sanctuary',
      ],
      'placesToPlay': [
        'Night Swimming with Glowing Bioluminescent Plankton',
        'Scuba Diving & Coral Reef Snorkeling Expeditions',
        'Sea Kayaking & Stand-Up Paddleboard Island Tours',
        'High Point Rope Park & Jungle Canopy Zipline',
      ],
      'hotels': [
        {
          'name': 'The Royal Sands Koh Rong',
          'rating': '5.0 ★',
          'price': '\$\$\$\$\$',
          'type': '5-Star Beachfront Luxury',
          'perk': 'Private plunge pool ocean villas',
        },
        {
          'name': 'Secret Garden Koh Rong Sanloem',
          'rating': '4.8 ★',
          'price': '\$\$\$',
          'type': 'Beachfront Eco-Boutique',
          'perk': 'Steps from turquoise waves & beachfront bar',
        },
        {
          'name': 'Sol Beach Resort',
          'rating': '4.9 ★',
          'price': '\$\$\$\$',
          'type': 'Khmer Architectural Villas',
          'perk': 'Open-air oceanfront dining',
        },
      ],
    },
    {
      'title': 'Bou Sra Jungle Cascades & Elephant Valleys',
      'province': 'Mondulkiri Province',
      'landmark': 'Bou Sra Waterfall',
      'category': 'Nature',
      'tag': '🐘 Wild Cascades & Highland Forests',
      'rating': '4.9 ★',
      'imageUrl': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=800&q=80',
      'description': 'Cambodia\'s most spectacular double-drop cascade tumbling through dense indigenous Bunong highland rainforest.',
      'placesToTravel': [
        'Bou Sra 3-Tier Thunderous Waterfalls',
        'Sea Forest (Samot Chhoeu) Mountain Viewpoint',
        'Sen Monorom Pine Tree Covered Rolling Hills',
        'Indigenous Bunong Traditional Community Villages',
      ],
      'placesToPlay': [
        'Ethical Elephant Bathing & Jungle Walk at Sanctuary',
        'Bou Sra Zipline Flying Directly Over the Waterfall',
        'Mondulkiri Highland Organic Coffee Farm Tasting',
        'Trekking with Indigenous Bunong Cultural Guides',
      ],
      'hotels': [
        {
          'name': 'Mayura Hill Resort',
          'rating': '4.9 ★',
          'price': '\$\$\$\$',
          'type': 'Luxury Highland Villas',
          'perk': 'Infinity pool overlooking pine forests',
        },
        {
          'name': 'Pidoma Resort',
          'rating': '4.8 ★',
          'price': '\$\$\$',
          'type': 'Modern Scenic Mountain Resort',
          'perk': 'Panoramic valley terraces',
        },
        {
          'name': 'Nature Lodge Mondulkiri',
          'rating': '4.7 ★',
          'price': '\$\$',
          'type': 'Rustic Eco-Cabins',
          'perk': 'Horse pastures & cozy outdoor hammocks',
        },
      ],
    },
    {
      'title': 'Kep Crab Market & Rabbit Island (Koh Tonsay)',
      'province': 'Kep Province',
      'landmark': 'Kep Crab Market',
      'category': 'Islands & Coast',
      'tag': '🦀 Blue Crabs & Rabbit Island Breeze',
      'rating': '4.7 ★',
      'imageUrl': 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=800&q=80',
      'description': 'Coastal seaside town renowned for blue swimmer crab cooked with fresh green pepper, peaceful Rabbit Island, and Kep National Park trails.',
      'placesToTravel': [
        'Lively Seaside Kep Crab Market (Phsar Kdam)',
        'Koh Tonsay (Rabbit Island) Golden Sand Shores',
        'Kep National Park Sunset Rock & 8km Trail',
        'Historic 1960s Modernist Villa Ruins',
      ],
      'placesToPlay': [
        'Feasting on Fresh Pepper Crab Cooked Right on Pier',
        'Wooden Longtail Boat Ride to Rabbit Island Hammocks',
        'Sea Sailing & Catamaran Sunset at Kep Sailing Club',
        'Hiking the Rainforest Circuit Trail with Ocean Views',
      ],
      'hotels': [
        {
          'name': 'Knai Bang Chatt Resort',
          'rating': '4.9 ★',
          'price': '\$\$\$\$\$',
          'type': 'Luxury Historic Seaside Villa',
          'perk': 'Private infinity ocean pool & sailing club',
        },
        {
          'name': 'Veranda Natural Resort',
          'rating': '4.8 ★',
          'price': '\$\$\$',
          'type': 'Hillside Eco-Retreat',
          'perk': 'Wooden sky-walks & famous French bakery',
        },
        {
          'name': 'Samanea Beach Resort & Spa',
          'rating': '4.8 ★',
          'price': '\$\$\$\$',
          'type': 'Botanical Mangrove Resort',
          'perk': 'Private beach jetty & seaside infinity pool',
        },
      ],
    },
    {
      'title': 'Yeak Laom Volcanic Crater Lake',
      'province': 'Ratanakiri Province',
      'landmark': 'Yeak Laom Lake',
      'category': 'Nature',
      'tag': '🌋 4,000-Yr Emerald Crater Lake',
      'rating': '4.9 ★',
      'imageUrl': 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=800&q=80',
      'description': 'A pristine circular volcanic lake formed 4,000 years ago, famous for exceptionally clear emerald water surrounded by dense jungle.',
      'placesToTravel': [
        'Yeak Laom Emerald Volcanic Crater Lake',
        'Ka Chhang & Cha Ong Jungle Waterfalls',
        'Lumphat Wildlife Protected Sanctuary',
        'Ethnic Tampuan Cultural & Handicraft Center',
      ],
      'placesToPlay': [
        'Swimming in Warm, Crystal-Clear Volcanic Waters',
        '3km Shaded Walking Loop Around the Crater Rim',
        'Traditional Tampuan Bamboo Weaving Workshops',
        'Gemstone Mining & Cutting Excursion in Bokeo',
      ],
      'hotels': [
        {
          'name': 'Terres Rouges Lodge',
          'rating': '4.8 ★',
          'price': '\$\$\$',
          'type': 'Colonial Lake-House Lodge',
          'perk': 'Teak wood cabins & tropical garden pool',
        },
        {
          'name': 'Yeak Loam Hotel Banlung',
          'rating': '4.6 ★',
          'price': '\$\$',
          'type': 'Town-Center Comfort',
          'perk': 'Convenient base for regional excursions',
        },
      ],
    },
    {
      'title': 'Preah Vihear Temple Cliff Sanctuary',
      'province': 'Preah Vihear Province',
      'landmark': 'Preah Vihear Temple',
      'category': 'Heritage',
      'tag': '⛰️ UNESCO Cliff-Top Sanctuary',
      'rating': '4.9 ★',
      'imageUrl': 'https://images.unsplash.com/photo-1544644181-1484b3fdfc62?auto=format&fit=crop&w=800&q=80',
      'description': 'Majestic 11th-century temple complex perched on a 525-meter cliff in the Dângrêk Mountains with panoramic views across Cambodia and Thailand.',
      'placesToTravel': [
        'Preah Vihear Temple Sanctuary & 5 Gopura Pavilions',
        'Peah En Te Cliff Viewpoint (525m Drop)',
        'Grand Naga Balustrade Stairway',
        'Koh Ker 7-Tier Pyramid Temple Complex (Nearby)',
      ],
      'placesToPlay': [
        'Thrilling 4WD Mountain Climb up the Dângrêk Escarpment',
        'Panoramic Edge Photography Over Endless Plains',
        'Exploring the 7-Tier Pyramid of Prasat Thom at Koh Ker',
        'Sunrise Mountain Ridge Meditation & Walk',
      ],
      'hotels': [
        {
          'name': 'Preah Vihear Boutique Hotel',
          'rating': '4.7 ★',
          'price': '\$\$\$',
          'type': 'Mountain-Base Resort',
          'perk': 'Large pool & mountain backdrop',
        },
        {
          'name': 'Koh Ker Jungle Lodge',
          'rating': '4.8 ★',
          'price': '\$\$\$',
          'type': 'Heritage Eco-Stay',
          'perk': 'Immersive archaeological setting',
        },
      ],
    },
    {
      'title': 'Prey Veng & Ba Phnom Historical Sanctuary',
      'province': 'Prey Veng Province',
      'landmark': 'Prey Veng',
      'category': 'Culture',
      'tag': '🌾 Funan Heritage & Sacred Hill',
      'rating': '4.8 ★',
      'imageUrl': 'https://images.unsplash.com/photo-1544644181-1484b3fdfc62?auto=format&fit=crop&w=800&q=80',
      'description': 'Ancient cradle of the pre-Angkorian Funan kingdom, featuring sacred Ba Phnom hill, tranquil lotus lakes, and Krong Prey Veng riverside promenade.',
      'placesToTravel': [
        'Ba Phnom Sacred Hill & Ancient Funan Shrines',
        'Wat Vihear Chan & Preah Vihear Thom Pagoda',
        'Krong Prey Veng Lake & Scenic Riverside Promenade',
        'Chhrouy Chek Eco-Tourism Reservoir & Lotus Fields',
      ],
      'placesToPlay': [
        'Hiking up Ba Phnom Sacred Hill for 360° floodplain panoramas',
        'Sunset boat cruising and freshwater fish cuisine at Chhrouy Chek',
        'Strolling Krong Prey Veng lakeside night market and promenade',
        'Rural cycling through traditional silk weaving and lotus farms',
      ],
      'hotels': [
        {
          'name': 'Prey Veng River Hotel & City Lodge',
          'rating': '4.7 ★',
          'price': '\$\$',
          'type': 'Central Town Hotel',
          'perk': 'AC rooms, lake views & friendly local service',
        },
        {
          'name': 'Mittapheap Hotel Prey Veng',
          'rating': '4.6 ★',
          'price': '\$',
          'type': 'Provincial Comfort Stay',
          'perk': 'Near Krong Prey Veng central market & dining',
        },
        {
          'name': 'Kirirom Guesthouse & Garden Resort',
          'rating': '4.6 ★',
          'price': '\$',
          'type': 'Quiet Garden Lodge',
          'perk': 'Peaceful green courtyard & family hospitality',
        },
      ],
    },
  ];

  List<Map<String, dynamic>> get _filteredDestinations {
    final query = _searchController.text.trim().toLowerCase();
    return _cambodiaDestinations.where((item) {
      final matchesCategory = _selectedCategory == 'All' ||
          item['category'] == _selectedCategory;
      final title = (item['title'] as String? ?? '').toLowerCase();
      final landmark = (item['landmark'] as String? ?? '').toLowerCase();
      final province = (item['province'] as String? ?? '').toLowerCase();
      final description = (item['description'] as String? ?? '').toLowerCase();
      final tag = (item['tag'] as String? ?? '').toLowerCase();

      final matchesQuery = query.isEmpty ||
          title.contains(query) ||
          landmark.contains(query) ||
          province.contains(query) ||
          description.contains(query) ||
          tag.contains(query);
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
                            'DER LENG',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
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
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
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
                                  size: 13,
                                  color: isGps ? Colors.greenAccent : AppTheme.primaryLight,
                                ),
                                const SizedBox(width: 4),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 80),
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
                              ],
                            ),
                          ),
                        );
                      },
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

            // 5. Well-Known Places in Cambodia Header & Category Filters
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Well-Known Places to Travel',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${destinations.length} specific destinations • Travel, Play & Hotels',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppTheme.accentMint : AppTheme.primaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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

  // Column Card for Each Destination with Travel, Play & Hotel Highlights
  Widget _buildDestinationColumnCard(
    BuildContext context,
    Map<String, dynamic> item,
    bool isDark,
  ) {
    final landmarkName = item['landmark'] as String? ?? '';
    final isBookmarked = _bookmarkedPlaces.contains(landmarkName);
    final placesToPlay = (item['placesToPlay'] as List<dynamic>?)?.cast<String>() ?? [];
    final hotels = (item['hotels'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 22),
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
              _showPlaceDetailsModal(context, item, isDark);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Cover Image with Badges
                SizedBox(
                  height: 195,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        item['imageUrl'] as String? ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          color: AppTheme.primaryLight,
                          child: const Icon(Icons.landscape, size: 48, color: Colors.white70),
                        ),
                      ),
                      // Gradient overlay for readability
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.38),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.75),
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
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                item['tag'] as String? ?? '',
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
                                  if (_bookmarkedPlaces.contains(landmarkName)) {
                                    _bookmarkedPlaces.remove(landmarkName);
                                  } else {
                                    _bookmarkedPlaces.add(landmarkName);
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
                      // Bottom Row over Image: Province and Rating
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
                                  item['province'] as String? ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    shadows: [
                                      Shadow(color: Colors.black87, blurRadius: 4),
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
                                item['rating'] as String? ?? '5.0 ★',
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

                // Card Details
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Specific Place Name (Not just province!)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'] as String? ?? '',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.near_me_rounded, size: 12, color: Color(0xFF10B981)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Landmark: ${item['landmark']}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppTheme.accentMint : AppTheme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item['category'] as String? ?? '',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Text(
                        item['description'] as String? ?? '',
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.45,
                          color: isDark ? Colors.grey.shade300 : const Color(0xFF4A5568),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 🎯 Recommended Places to Play / Activities Preview
                      if (placesToPlay.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF2F7F3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? AppTheme.borderDark : const Color(0xFFE2EBE3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.sports_esports_rounded, size: 15, color: Color(0xFF059669)),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Places to Play & Activities:',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF059669),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: placesToPlay.take(3).map((act) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppTheme.cardDark : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isDark ? AppTheme.borderDark : const Color(0xFFD4E3D7),
                                      ),
                                    ),
                                    child: Text(
                                      '• $act',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? Colors.white70 : const Color(0xFF2D3748),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 8),

                      // 🏨 Recommended Hotels Preview
                      if (hotels.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? AppTheme.borderDark : const Color(0xFFFDE68A),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.hotel_rounded, size: 15, color: Color(0xFFD97706)),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Recommended Hotels & Stays:',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFD97706),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: hotels.take(2).map((h) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppTheme.cardDark : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isDark ? AppTheme.borderDark : const Color(0xFFFDE68A),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          h['name'] as String? ?? '',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? Colors.white70 : const Color(0xFF2D3748),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '(${h['rating']})',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFD97706),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 14),
                      Divider(
                        height: 1,
                        color: isDark ? AppTheme.borderDark : const Color(0xFFEDF2EC),
                      ),
                      const SizedBox(height: 12),

                      // Card Action Buttons
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _showPlaceDetailsModal(context, item, isDark);
                              },
                              icon: const Icon(Icons.visibility_outlined, size: 15),
                              label: const Text(
                                'Travel & Hotels',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDark ? AppTheme.accentMint : AppTheme.primaryColor,
                                side: BorderSide(
                                  color: isDark ? AppTheme.accentMint : AppTheme.primaryColor,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                widget.onSearchDestination?.call(item['landmark'] ?? item['title']!);
                              },
                              icon: const Icon(Icons.near_me_rounded, size: 15),
                              label: const Text(
                                'Route Map',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
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

  // Modal Details Sheet Showing Specific Places to Travel, Places to Play, and Recommended Hotels
  void _showPlaceDetailsModal(
    BuildContext context,
    Map<String, dynamic> item,
    bool isDark,
  ) {
    final placesToTravel = (item['placesToTravel'] as List<dynamic>?)?.cast<String>() ?? [];
    final placesToPlay = (item['placesToPlay'] as List<dynamic>?)?.cast<String>() ?? [];
    final hotels = (item['hotels'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.85,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.backgroundDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            children: [
              // Top drag indicator
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Header bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String? ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.place_rounded, size: 13, color: Color(0xFF10B981)),
                              const SizedBox(width: 4),
                              Text(
                                '${item['province']} • ${item['category']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppTheme.accentMint : AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Scrollable Details
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Overview
                    Text(
                      item['description'] as String? ?? '',
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.5,
                        color: isDark ? Colors.grey.shade300 : const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // SECTION 1: 🏛️ MUST-VISIT PLACES TO TRAVEL
                    _buildModalSectionHeader(
                      icon: Icons.account_balance_rounded,
                      iconColor: const Color(0xFF3B82F6),
                      title: 'Top Places to Travel & Must-See Sights',
                      subtitle: 'Historical monuments, viewpoints & natural wonders',
                    ),
                    const SizedBox(height: 10),
                    ...placesToTravel.map((spot) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.cardDark : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark ? AppTheme.borderDark : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Color(0xFF3B82F6), size: 16),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  spot,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),

                    const SizedBox(height: 20),

                    // SECTION 2: 🎯 PLACES TO PLAY & ENTERTAINMENT
                    _buildModalSectionHeader(
                      icon: Icons.sports_esports_rounded,
                      iconColor: const Color(0xFF10B981),
                      title: 'Places to Play & Top Activities',
                      subtitle: 'Adventures, entertainment, water sports & cultural experiences',
                    ),
                    const SizedBox(height: 10),
                    ...placesToPlay.map((act) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.cardDark : const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark ? AppTheme.borderDark : const Color(0xFFDCFCE7),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.attractions_rounded, color: Color(0xFF10B981), size: 16),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  act,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),

                    const SizedBox(height: 20),

                    // SECTION 3: 🏨 RECOMMENDED HOTELS & RESORTS
                    _buildModalSectionHeader(
                      icon: Icons.hotel_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      title: 'Recommended Hotels & Accommodations',
                      subtitle: 'Hand-picked luxury, boutique & eco stays with ratings',
                    ),
                    const SizedBox(height: 10),
                    ...hotels.map((h) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.cardDark : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? AppTheme.borderDark : const Color(0xFFFDE68A),
                              width: 1.2,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      h['name'] as String? ?? '',
                                      style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${h['rating']} • ${h['price']}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF92400E),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                h['type'] as String? ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppTheme.accentMint : AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      h['perk'] as String? ?? '',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Bottom Button Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardDark : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppTheme.borderDark : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      widget.onSearchDestination?.call(item['landmark'] ?? item['title']!);
                    },
                    icon: const Icon(Icons.near_me_rounded),
                    label: Text(
                      'Plot Route to ${item['title']} on Live Map',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
        );
      },
    );
  }

  Widget _buildModalSectionHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
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
