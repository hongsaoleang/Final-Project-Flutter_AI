import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'planner/home_explore_dashboard.dart';
import 'planner/itinerary_details_screen.dart';
import 'planner/bookings_boarding_pass_screen.dart';
import 'map/map_guide_screen.dart';
import 'chat/ai_place_chat_screen.dart';
import 'settings/settings_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  final GlobalKey<MapGuideScreenState> _mapGuideKey = GlobalKey<MapGuideScreenState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _navigateToMapWithPlace(String placeName) {
    setState(() {
      _selectedIndex = 2; // Switch to Map Guide tab
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapGuideKey.currentState?.navigateToDestinationName(placeName);
    });
  }

  void _openItineraryScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => ItineraryDetailsScreen(
          onBack: () => Navigator.pop(ctx),
          onNavigateToPlace: (place) {
            Navigator.pop(ctx);
            _navigateToMapWithPlace(place);
          },
        ),
      ),
    );
  }

  void _openBookingsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => BookingsBoardingPassScreen(
          onBack: () => Navigator.pop(ctx),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width >= 850;

    final screens = [
      AiPlaceChatScreen(
        onNavigateToMap: _navigateToMapWithPlace,
        onOpenMenu: () => _scaffoldKey.currentState?.openDrawer(),
        onOpenSettings: () => setState(() => _selectedIndex = 3),
      ),
      HomeExploreDashboard(
        onOpenMenu: () => _scaffoldKey.currentState?.openDrawer(),
        onOpenSettings: () => setState(() => _selectedIndex = 3),
        onOpenItinerary: _openItineraryScreen,
        onSearchDestination: _navigateToMapWithPlace,
        onOpenAiGuide: () => setState(() => _selectedIndex = 0),
      ),
      MapGuideScreen(key: _mapGuideKey),
      const SettingsScreen(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.primaryLight, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/logo.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => const Icon(Icons.eco, color: AppTheme.primaryLight),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DER LENG', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Cambodia Eco Edition', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.auto_awesome_outlined),
                title: const Text('AI Guide'),
                selected: _selectedIndex == 0,
                selectedColor: AppTheme.primaryLight,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedIndex = 0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.explore_outlined),
                title: const Text('Explore'),
                selected: _selectedIndex == 1,
                selectedColor: AppTheme.primaryLight,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedIndex = 1);
                },
              ),
              ListTile(
                leading: const Icon(Icons.map_outlined),
                title: const Text('Map'),
                selected: _selectedIndex == 2,
                selectedColor: AppTheme.primaryLight,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedIndex = 2);
                },
              ),
              ListTile(
                leading: const Icon(Icons.route_outlined),
                title: const Text('Itinerary Details'),
                onTap: () {
                  Navigator.pop(context);
                  _openItineraryScreen();
                },
              ),
              ListTile(
                leading: const Icon(Icons.confirmation_number_outlined),
                title: const Text('Bookings & Passes'),
                onTap: () {
                  Navigator.pop(context);
                  _openBookingsScreen();
                },
              ),
              const Spacer(),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Setting'),
                selected: _selectedIndex == 3,
                selectedColor: AppTheme.primaryLight,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedIndex = 3);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      body: isWide
          ? Row(
              children: [
                NavigationRail(
                  backgroundColor: Theme.of(context).cardColor,
                  indicatorColor: AppTheme.primaryColor.withValues(alpha: 0.22),
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primaryLight, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/images/logo.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => const Icon(Icons.eco, color: AppTheme.primaryLight),
                        ),
                      ),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.auto_awesome_outlined),
                      selectedIcon: Icon(Icons.auto_awesome, color: AppTheme.primaryLight),
                      label: Text('AI Guide'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.explore_outlined),
                      selectedIcon: Icon(Icons.explore, color: AppTheme.primaryLight),
                      label: Text('Explore'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.map_outlined),
                      selectedIcon: Icon(Icons.map, color: AppTheme.primaryLight),
                      label: Text('Map'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings, color: AppTheme.primaryLight),
                      label: Text('Setting'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: screens,
                  ),
                ),
              ],
            )
          : IndexedStack(
              index: _selectedIndex,
              children: screens,
            ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              backgroundColor: Theme.of(context).cardColor,
              indicatorColor: AppTheme.primaryColor.withValues(alpha: 0.22),
              selectedIndex: _selectedIndex,
              onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
              destinations: const [
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
                  icon: Icon(Icons.map_outlined),
                  selectedIcon: Icon(Icons.map, color: AppTheme.primaryLight),
                  label: 'Map',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings, color: AppTheme.primaryLight),
                  label: 'Setting',
                ),
              ],
            ),
    );
  }
}
