import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../core/theme/app_theme.dart';
import 'map/map_guide_screen.dart';
import 'scan/place_scanner_screen.dart';
import 'chat/ai_place_chat_screen.dart';
import 'places/saved_places_screen.dart';
import 'settings/settings_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  final GlobalKey<MapGuideScreenState> _mapGuideKey = GlobalKey<MapGuideScreenState>();

  void _navigateToMapWithPlace(String placeName) {
    setState(() {
      _selectedIndex = 0; // Switch to Map Guide
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapGuideKey.currentState?.navigateToDestinationName(placeName);
    });
  }

  void _navigateToScannedPlace(String placeName, LatLng coordinates) {
    _mapGuideKey.currentState?.setTargetDestination(placeName, coordinates);
    setState(() {
      _selectedIndex = 0; // Switch to Map Guide
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      MapGuideScreen(key: _mapGuideKey),
      PlaceScannerScreen(onNavigateToPlace: _navigateToScannedPlace),
      AiPlaceChatScreen(onNavigateToMap: _navigateToMapWithPlace),
      SavedPlacesScreen(onSelectPlace: _navigateToMapWithPlace),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppTheme.cardDark,
        indicatorColor: AppTheme.primaryColor.withValues(alpha: 0.3),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map, color: AppTheme.primaryLight),
            label: 'Map Guide',
          ),
          NavigationDestination(
            icon: Icon(Icons.document_scanner_outlined),
            selectedIcon: Icon(Icons.document_scanner, color: AppTheme.primaryLight),
            label: 'Scan Place',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome, color: AppTheme.primaryLight),
            label: 'AI Guide',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore, color: AppTheme.primaryLight),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: AppTheme.primaryLight),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
