import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/user_location_service.dart';

class ShareLocationDialog extends StatefulWidget {
  final VoidCallback? onUseAsOrigin;

  const ShareLocationDialog({
    super.key,
    this.onUseAsOrigin,
  });

  @override
  State<ShareLocationDialog> createState() => _ShareLocationDialogState();
}

class _ShareLocationDialogState extends State<ShareLocationDialog> {
  final UserLocationService _userLocService = UserLocationService();
  bool _isFetchingGps = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _userLocService.addListener(_onLocationUpdated);

    // Auto-detect GPS when dialog is opened if not already locked
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_userLocService.isGpsActive) {
        _detectGps();
      }
    });
  }

  @override
  void dispose() {
    _userLocService.removeListener(_onLocationUpdated);
    super.dispose();
  }

  void _onLocationUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  LatLng get _currentCoords {
    if (_userLocService.isGpsActive && _userLocService.currentGpsPosition != null) {
      final pos = _userLocService.currentGpsPosition!;
      return LatLng(pos.latitude, pos.longitude);
    }
    return _userLocService.livingPlace.coordinates;
  }

  String get _currentPlaceName {
    if (_userLocService.isGpsActive && _userLocService.currentGpsPosition != null) {
      if (_userLocService.state.isNotEmpty && _userLocService.city.isNotEmpty && _userLocService.state != _userLocService.city) {
        return '${_userLocService.city}, ${_userLocService.state}';
      } else if (_userLocService.state.isNotEmpty) {
        return _userLocService.state;
      } else if (_userLocService.city.isNotEmpty) {
        return _userLocService.city;
      }
      return 'Live GPS Location';
    }
    return '${_userLocService.livingPlace.name}, ${_userLocService.city}';
  }

  String get _googleMapsUrl {
    final coords = _currentCoords;
    return 'https://www.google.com/maps?q=${coords.latitude.toStringAsFixed(6)},${coords.longitude.toStringAsFixed(6)}';
  }

  String get _formattedShareText {
    final coords = _currentCoords;
    final state = _userLocService.state;
    final city = _userLocService.city;
    final country = _userLocService.country;
    final address = _userLocService.formattedAddress;

    final buffer = StringBuffer();
    buffer.writeln('📍 My Current Location:');
    if (address.isNotEmpty) {
      buffer.writeln('🏠 Address: $address');
    }
    if (state.isNotEmpty) {
      buffer.writeln('🏛️ State/Province: $state');
    }
    if (city.isNotEmpty) {
      buffer.writeln('🏙️ City: $city');
    }
    if (country.isNotEmpty) {
      buffer.writeln('🌍 Country: $country');
    }
    buffer.writeln('🌐 Coordinates: ${coords.latitude.toStringAsFixed(6)}, ${coords.longitude.toStringAsFixed(6)}');
    buffer.writeln('🗺️ Google Maps: $_googleMapsUrl');
    return buffer.toString().trim();
  }

  Future<void> _detectGps() async {
    setState(() {
      _isFetchingGps = true;
      _statusMessage = null;
    });

    final res = await _userLocService.startLiveLocationTracking(continuous: true);

    if (mounted) {
      setState(() {
        _isFetchingGps = false;
        if (res.success && res.position != null) {
          _statusMessage = 'GPS coordinates locked! Resolving address & state...';
        } else {
          _statusMessage = res.message;
        }
      });
    }
  }

  Future<void> _shareViaNativeSheet() async {
    try {
      final shareText = _formattedShareText;
      final subject = _userLocService.state.isNotEmpty
          ? 'My Current Location in ${_userLocService.state}'
          : 'My Current Location';

      final box = context.findRenderObject() as RenderBox?;
      final originRect = box != null ? box.localToGlobal(Offset.zero) & box.size : null;

      await SharePlus.instance.share(
        ShareParams(
          text: shareText,
          subject: subject,
          title: subject,
          sharePositionOrigin: originRect,
        ),
      );
    } catch (e) {
      debugPrint('Native share error: $e');
      _copyToClipboard(_formattedShareText, 'Share text');
    }
  }

  Future<void> _openGoogleMaps() async {
    final uri = Uri.parse(_googleMapsUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      _copyToClipboard(_googleMapsUrl, 'Google Maps URL');
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
            const SizedBox(width: 8),
            Text('$label copied to clipboard!'),
          ],
        ),
        backgroundColor: AppTheme.cardDark,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coords = _currentCoords;
    final isGps = _userLocService.isGpsActive && _userLocService.currentGpsPosition != null;
    final state = _userLocService.state;
    final city = _userLocService.city;
    final country = _userLocService.country;
    final address = _userLocService.formattedAddress;

    return Dialog(
      backgroundColor: AppTheme.cardDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.share_location, color: AppTheme.primaryLight, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Share My Location',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isGps
                              ? (state.isNotEmpty ? 'Live in $state, $country' : 'Live Device/Emulator GPS Active')
                              : 'Defaulting to $city, $country',
                          style: TextStyle(
                            fontSize: 12,
                            color: isGps ? Colors.greenAccent : Colors.grey,
                            fontWeight: isGps ? FontWeight.w600 : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Location Preview Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isGps ? Colors.greenAccent.withValues(alpha: 0.5) : Colors.white12,
                    width: isGps ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location Title & Status Tag
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isGps ? Icons.gps_fixed : Icons.location_on,
                          color: isGps ? Colors.greenAccent : AppTheme.primaryLight,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentPlaceName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              if (state.isNotEmpty && state != city) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'State / Region: $state',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.greenAccent,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isGps
                                ? Colors.greenAccent.withValues(alpha: 0.15)
                                : Colors.amberAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isGps ? (state.isNotEmpty ? state.toUpperCase() : 'GPS ACTIVE') : 'BASE CITY',
                            style: TextStyle(
                              color: isGps ? Colors.greenAccent : Colors.amberAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (address.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        address,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          height: 1.35,
                        ),
                      ),
                    ],

                    if (_userLocService.isReverseGeocoding) ...[
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.greenAccent),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Resolving exact state & address...',
                            style: TextStyle(color: Colors.greenAccent, fontSize: 11),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 12),
                    // Coordinates snippet
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${coords.latitude.toStringAsFixed(6)}, ${coords.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          InkWell(
                            onTap: () => _copyToClipboard(
                              '${coords.latitude.toStringAsFixed(6)}, ${coords.longitude.toStringAsFixed(6)}',
                              'Coordinates',
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.copy, size: 13, color: AppTheme.primaryLight),
                                SizedBox(width: 4),
                                Text('Copy', style: TextStyle(color: AppTheme.primaryLight, fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (_statusMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  _statusMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.amberAccent, fontSize: 12),
                ),
              ],

              const SizedBox(height: 16),

              // 3. Primary Native System Share Button
              ElevatedButton.icon(
                icon: const Icon(Icons.share, size: 20),
                label: const Text(
                  'Share My Location (System Share)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
                onPressed: _shareViaNativeSheet,
              ),

              const SizedBox(height: 10),

              // 4. Secondary Action Row (Open Google Maps & Copy Formatted Text)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.map, size: 16),
                      label: const Text('Open Maps', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _openGoogleMaps,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy Details', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _copyToClipboard(_formattedShareText, 'Location summary'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // 5. GPS Refresh Button
              OutlinedButton.icon(
                icon: _isFetchingGps
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryLight),
                      )
                    : const Icon(Icons.my_location, size: 16),
                label: Text(_isFetchingGps ? 'Detecting emulator/device GPS...' : 'Refresh Exact GPS'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryLight,
                  side: const BorderSide(color: AppTheme.primaryLight),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isFetchingGps ? null : _detectGps,
              ),

              const SizedBox(height: 14),
              const Divider(color: Colors.white12),
              const SizedBox(height: 6),

              // 6. Action: Use as Route Origin
              ElevatedButton.icon(
                icon: const Icon(Icons.navigation, size: 16),
                label: const Text('Set as Route Starting Point'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onUseAsOrigin?.call();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
