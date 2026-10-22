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
      if (!mounted) return;
      setState(() {
        _isTestingConnection = false;
        _connectionSuccess = true;
        _connectionStatus = (res['status'] == 'UP') ? 'Online' : 'Connected';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isTestingConnection = false;
        _connectionSuccess = false;
        _connectionStatus = 'Offline';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          // App Header
          Center(
            child: Column(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? Colors.cyanAccent.withValues(alpha: 0.6)
                          : AppTheme.primaryColor.withValues(alpha: 0.8),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.cyanAccent : AppTheme.primaryColor)
                            .withValues(alpha: 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/icon/logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/images/logo.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) => const Icon(
                          Icons.travel_explore,
                          size: 38,
                          color: AppTheme.primaryLight,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'DER LENG',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Appearance
          Text(
            'APPEARANCE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppTheme.borderDark : Colors.grey.shade200,
              ),
            ),
            child: SwitchListTile(
              secondary: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: isDark ? Colors.cyanAccent : Colors.amber,
                size: 22,
              ),
              title: const Text(
                'Dark Mode',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              value: AppTheme.themeNotifier.value == ThemeMode.dark,
              activeThumbColor: Colors.cyanAccent,
              onChanged: (val) {
                setState(() {
                  AppTheme.themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                });
              },
            ),
          ),
          const SizedBox(height: 24),

          // Server Connection
          Text(
            'SERVER',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppTheme.borderDark : Colors.grey.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Host Address',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    if (_connectionStatus != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _connectionSuccess == true
                              ? Colors.green.withValues(alpha: 0.15)
                              : Colors.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _connectionSuccess == true ? Colors.green : Colors.redAccent,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _connectionSuccess == true ? Icons.check_circle : Icons.cancel_outlined,
                              size: 12,
                              color: _connectionSuccess == true ? Colors.greenAccent : Colors.redAccent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _connectionStatus!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _connectionSuccess == true ? Colors.greenAccent : Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _hostController,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.dns_rounded, size: 18),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check_rounded, size: 18, color: Colors.cyanAccent),
                      tooltip: 'Save',
                      onPressed: () {
                        setState(() {
                          ApiConstants.serverHost = _hostController.text.trim();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Host saved'),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1B2329) : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isTestingConnection ? null : _testConnection,
                    icon: _isTestingConnection
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.wifi_tethering_rounded, size: 16),
                    label: Text(
                      _isTestingConnection ? 'Testing...' : 'Test Connection',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
