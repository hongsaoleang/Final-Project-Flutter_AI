import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SavedPlacesScreen extends StatelessWidget {
  final Function(String placeName)? onSelectPlace;

  const SavedPlacesScreen({super.key, this.onSelectPlace});

  static const List<Map<String, String>> _curatedPlaces = [
    {
      'name': 'Central Park',
      'city': 'New York, USA',
      'desc': '843-acre iconic urban park in Manhattan featuring lakes, meadows, and walking paths.',
      'category': 'Park & Nature',
      'icon': 'park',
    },
    {
      'name': 'Times Square',
      'city': 'New York, USA',
      'desc': 'Vibrant commercial intersection renowned for dazzling digital billboards and Broadway theaters.',
      'category': 'Landmark',
      'icon': 'theater_comedy',
    },
    {
      'name': 'Eiffel Tower',
      'city': 'Paris, France',
      'desc': 'Wrought-iron lattice tower on the Champ de Mars, the global cultural icon of France.',
      'category': 'Monument',
      'icon': 'apartment',
    },
    {
      'name': 'Louvre Museum',
      'city': 'Paris, France',
      'desc': 'The world\'s most-visited museum and historic landmark hosting Mona Lisa and the glass pyramid.',
      'category': 'Museum',
      'icon': 'museum',
    },
    {
      'name': 'Tokyo Tower',
      'city': 'Tokyo, Japan',
      'desc': 'Communications and observation tower in Minato, offering panoramic views of Mount Fuji.',
      'category': 'Observatory',
      'icon': 'tower',
    },
    {
      'name': 'Shibuya Crossing',
      'city': 'Tokyo, Japan',
      'desc': 'World\'s busiest pedestrian intersection, bustling with neon lights and urban energy.',
      'category': 'Urban Hub',
      'icon': 'traffic',
    },
    {
      'name': 'Colosseum',
      'city': 'Rome, Italy',
      'desc': 'The largest ancient amphitheatre ever built, holding grand gladiatorial contests.',
      'category': 'Historic',
      'icon': 'account_balance',
    },
    {
      'name': 'Sydney Opera House',
      'city': 'Sydney, Australia',
      'desc': 'Multi-venue performing arts centre famous for its expressive sail-shaped shell design.',
      'category': 'Architecture',
      'icon': 'music_note',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.explore, color: AppTheme.primaryLight, size: 28),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore Top Destinations',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tap any destination to calculate directions, range, and AI travel tips.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'Featured Landmarks',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 12),

        ..._curatedPlaces.map((place) {
          return Card(
            color: AppTheme.cardDark,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Colors.white10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.place, color: AppTheme.primaryLight, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place['name']!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              place['city']!,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          place['category']!,
                          style: const TextStyle(fontSize: 11, color: Colors.cyanAccent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    place['desc']!,
                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.35),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.directions, size: 16),
                      label: const Text('Guide on Map'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        if (onSelectPlace != null) {
                          onSelectPlace!(place['name']!);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Switched target to ${place['name']}')),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    ),
  );
}
}
