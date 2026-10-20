import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web/web.dart' as web;

void main() {
  runApp(const ScanGetApp());
}

class ScanGetApp extends StatelessWidget {
  const ScanGetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Get DER LENG AI App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.light,
        ),
        fontFamily: 'Segoe UI',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Segoe UI',
      ),
      themeMode: ThemeMode.system,
      home: const DownloadLandingScreen(),
    );
  }
}

class DownloadLandingScreen extends StatefulWidget {
  const DownloadLandingScreen({super.key});

  @override
  State<DownloadLandingScreen> createState() => _DownloadLandingScreenState();
}

class _DownloadLandingScreenState extends State<DownloadLandingScreen> {
  final String apkFileName = 'app-release.apk';

  String get _apkDownloadUrl {
    final origin = Uri.base.origin;
    if (origin.isNotEmpty && origin != 'null') {
      final base = origin.endsWith('/') ? origin : '$origin/';
      return '$base$apkFileName';
    }
    return '/$apkFileName';
  }

  void _downloadApkFile() {
    try {
      final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
      anchor.href = _apkDownloadUrl;
      anchor.setAttribute('download', apkFileName);
      anchor.click();
    } catch (_) {
      launchUrl(Uri.parse(_apkDownloadUrl), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 48.0 : 20.0,
            vertical: 24.0,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(isDark),
                  const SizedBox(height: 24),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: _buildAppInfoSection(theme, isDark)),
                        const SizedBox(width: 36),
                        Expanded(flex: 4, child: _buildQrAndDownloadSection(theme, isDark)),
                      ],
                    )
                  else ...[
                    _buildAppInfoSection(theme, isDark),
                    const SizedBox(height: 24),
                    _buildQrAndDownloadSection(theme, isDark),
                  ],
                  const SizedBox(height: 36),
                  _buildInstallSteps(theme, isDark),
                  const SizedBox(height: 48),
                  Center(
                    child: Text(
                      'DER LENG AI • Android APK Portal',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white38 : Colors.black45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              'app_icon.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.android_rounded, size: 36, color: Color(0xFF4F46E5)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DER LENG AI',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Official Android APK Portal',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ),
        const Spacer(),
        Chip(
          avatar: const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
          label: const Text('Verified APK'),
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          side: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
        ),
      ],
    );
  }

  Widget _buildAppInfoSection(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'READY FOR INSTALLATION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4F46E5),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'DIRECT APK',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Experience AI on your Android Device',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Download the complete DER LENG AI mobile app. Scan the QR code with your mobile camera or download directly below.',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: isDark ? Colors.white70 : const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildBadge(Icons.android_outlined, 'Android', 'Platform', isDark),
              _buildBadge(Icons.inventory_2_outlined, 'APK Package', 'Format', isDark),
              _buildBadge(Icons.verified_outlined, 'Release', 'Build', isDark),
              _buildBadge(Icons.security_outlined, 'Verified', 'Safe', isDark),
            ],
          ),
          const SizedBox(height: 28),
          const Divider(),
          const SizedBox(height: 20),
          const Text(
            'Features:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildFeatureBullet(Icons.camera_alt_outlined, 'Live Camera Object & OCR Scanning', isDark),
          _buildFeatureBullet(Icons.smart_toy_outlined, 'Intelligent AI Interaction & Conversation', isDark),
          _buildFeatureBullet(Icons.speed_rounded, 'Optimized performance and quick response', isDark),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String title, String subtitle, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF4F46E5)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBullet(IconData icon, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF4F46E5)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : const Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrAndDownloadSection(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.qr_code_scanner, color: Color(0xFF4F46E5)),
              const SizedBox(width: 8),
              Text(
                'Scan with Phone Camera',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Point phone camera at code to instantly download APK',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: QrImageView(
              data: _apkDownloadUrl,
              version: QrVersions.auto,
              size: 210,
              gapless: false,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _downloadApkFile,
              icon: const Icon(Icons.download_rounded, size: 22),
              label: const Text(
                'Download APK File',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstallSteps(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.install_mobile_rounded, color: Color(0xFF4F46E5)),
              ),
              const SizedBox(width: 14),
              const Text(
                'How to Install on Android',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 650;
              final steps = [
                _buildStepCard(
                  step: '1',
                  icon: Icons.qr_code_2,
                  title: 'Scan or Download',
                  desc: 'Scan the QR code with phone camera or tap "Download APK File" in browser.',
                  isDark: isDark,
                ),
                _buildStepCard(
                  step: '2',
                  icon: Icons.security,
                  title: 'Allow Installation',
                  desc: 'If Android prompts "File might be harmful", tap "Download anyway" -> "Settings" -> "Allow from this source".',
                  isDark: isDark,
                ),
                _buildStepCard(
                  step: '3',
                  icon: Icons.check_circle_outline,
                  title: 'Tap Install & Open',
                  desc: 'Open the downloaded APK file, tap "Install", and enjoy DER LENG AI!',
                  isDark: isDark,
                ),
              ];

              if (isSmall) {
                return Column(
                  children: steps.map((s) => Padding(padding: const EdgeInsets.only(bottom: 12), child: s)).toList(),
                );
              }
              return Row(
                children: [
                  Expanded(child: steps[0]),
                  const SizedBox(width: 16),
                  Expanded(child: steps[1]),
                  const SizedBox(width: 16),
                  Expanded(child: steps[2]),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required String step,
    required IconData icon,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFF4F46E5),
                child: Text(
                  step,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              Icon(icon, color: const Color(0xFF4F46E5), size: 22),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
