import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/ai_service.dart';
import 'chat/chat_screen.dart';
import 'training/training_screen.dart';
import 'history/history_screen.dart';
import 'settings/settings_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  final AiService _aiService = AiService();
  String _statusText = 'Checking backend...';
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _checkHealth();
  }

  Future<void> _checkHealth() async {
    try {
      final health = await _aiService.checkHealth();
      setState(() {
        _statusText = 'Online (${health['database']})';
        _isOnline = true;
      });
    } catch (_) {
      setState(() {
        _statusText = 'Offline (Spring Boot unreachable)';
        _isOnline = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = const [
      ChatScreen(),
      TrainingScreen(),
      HistoryScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.psychology, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MyAI Multimodal Platform',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isOnline ? Colors.greenAccent : Colors.amberAccent,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _statusText,
                      style: TextStyle(
                        fontSize: 11,
                        color: _isOnline ? Colors.greenAccent : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Status',
            icon: const Icon(Icons.refresh),
            onPressed: _checkHealth,
          ),
        ],
      ),
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
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble, color: AppTheme.primaryLight),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.model_training_outlined),
            selectedIcon: Icon(Icons.model_training, color: AppTheme.primaryLight),
            label: 'Train AI',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: AppTheme.primaryLight),
            label: 'History',
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
