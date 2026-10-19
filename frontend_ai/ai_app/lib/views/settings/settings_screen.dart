import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../services/ai_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AiService _aiService = AiService();
  late TextEditingController _hostController;
  bool _isTestingConnection = false;
  String? _connectionStatus;
  bool? _connectionSuccess;

  @override
  void initState() {
    super.initState();
    _hostController = TextEditingController(text: ApiConstants.serverHost);
  }

  @override
  void dispose() {
    _hostController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTestingConnection = true;
      _connectionStatus = null;
      _connectionSuccess = null;
    });

    try {
      final res = await _aiService.checkHealth();
      setState(() {
        _isTestingConnection = false;
        _connectionSuccess = true;
        _connectionStatus = 'Connected: ${res['service'] ?? 'Backend Online'} (${res['status'] ?? 'UP'})';
      });
    } catch (e) {
      setState(() {
        _isTestingConnection = false;
        _connectionSuccess = false;
        _connectionStatus = 'Connection error: $e\nEnsure phone and PC are on the same Wi-Fi and host is correct.';
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        children: [
          // App Logo and Identity Header
          Center(
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(
                      color: isDark ? AppTheme.borderDark : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'DER LENG',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Personal Multimodal AI Platform',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Appearance Section Header
          Text(
            'APPEARANCE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 14),

          // Theme Selector Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppTheme.borderDark : Colors.grey.shade200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: isDark ? const Color(0xFF818CF8) : Colors.amber,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Theme Mode',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose between dark and light appearance across all screens.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_outlined),
                        label: Text('Dark Mode'),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_outlined),
                        label: Text('Light Mode'),
                      ),
                    ],
                    selected: {AppTheme.themeNotifier.value},
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        AppTheme.themeNotifier.value = newSelection.first;
                      });
                    },
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Platform & Backend Connection Section Header
          Text(
            'BACKEND SERVER & DEVICE CONNECTION',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 14),

          // Server Connection Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppTheme.borderDark : Colors.grey.shade200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
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
                    Row(
                      children: [
                        Icon(
                          kIsWeb
                              ? Icons.language_rounded
                              : (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)
                                  ? Icons.phone_android_rounded
                                  : Icons.desktop_windows_rounded,
                          color: AppTheme.primaryLight,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          kIsWeb
                              ? 'Web Browser'
                              : (defaultTargetPlatform == TargetPlatform.android)
                                  ? 'Android Device'
                                  : (defaultTargetPlatform == TargetPlatform.iOS)
                                      ? 'iOS Device'
                                      : 'Desktop (Windows)',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Multi-Platform',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryLight),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Server Host / IP Address:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _hostController,
                  decoration: InputDecoration(
                    hintText: 'e.g. 172.20.10.2 or localhost',
                    prefixIcon: const Icon(Icons.dns_outlined, size: 20),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check_circle_outline, color: AppTheme.primaryLight),
                      tooltip: 'Apply Host',
                      onPressed: () {
                        setState(() {
                          ApiConstants.serverHost = _hostController.text;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Server host set to: ${ApiConstants.serverHost}')),
                        );
                      },
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1B2329) : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  onSubmitted: (val) {
                    setState(() {
                      ApiConstants.serverHost = val;
                    });
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  'Quick Connect Presets:',
                  style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.wifi, size: 14),
                      label: const Text('Phone Wi-Fi (172.20.10.2)', style: TextStyle(fontSize: 11)),
                      onPressed: () {
                        _hostController.text = '172.20.10.2';
                        setState(() => ApiConstants.serverHost = '172.20.10.2');
                      },
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.android, size: 14),
                      label: const Text('Emulator (10.0.2.2)', style: TextStyle(fontSize: 11)),
                      onPressed: () {
                        _hostController.text = '10.0.2.2';
                        setState(() => ApiConstants.serverHost = '10.0.2.2');
                      },
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.computer, size: 14),
                      label: const Text('Localhost (127.0.0.1)', style: TextStyle(fontSize: 11)),
                      onPressed: () {
                        _hostController.text = '127.0.0.1';
                        setState(() => ApiConstants.serverHost = '127.0.0.1');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isTestingConnection ? null : _testConnection,
                    icon: _isTestingConnection
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.network_check_rounded, size: 18),
                    label: Text(_isTestingConnection ? 'Testing Connection...' : 'Test Backend Connection'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                if (_connectionStatus != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _connectionSuccess == true
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _connectionSuccess == true ? Colors.green : Colors.redAccent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _connectionSuccess == true ? Icons.check_circle : Icons.error_outline,
                          color: _connectionSuccess == true ? Colors.green : Colors.redAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _connectionStatus!,
                            style: TextStyle(
                              fontSize: 12,
                              color: _connectionSuccess == true
                                  ? (isDark ? Colors.greenAccent : Colors.green.shade800)
                                  : (isDark ? Colors.redAccent : Colors.red.shade800),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),

          // About Section Header
          Text(
            'ABOUT APPLICATION',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppTheme.borderDark : Colors.grey.shade200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildInfoTile(
                  icon: Icons.flag_rounded,
                  title: 'Destination Focus',
                  value: 'Cambodia (25 Provinces)',
                  isDark: isDark,
                ),
                const Divider(height: 20),
                _buildInfoTile(
                  icon: Icons.map_rounded,
                  title: 'Routing & Navigation',
                  value: 'Live GPS + Google Maps Sync',
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: isDark ? AppTheme.primaryLight : AppTheme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
