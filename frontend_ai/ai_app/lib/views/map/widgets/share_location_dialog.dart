import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
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

  LatLng get _currentCoords {
    if (_userLocService.isGpsActive && _userLocService.currentGpsPosition != null) {
      final pos = _userLocService.currentGpsPosition!;
      return LatLng(pos.latitude, pos.longitude);
    }
    return _userLocService.livingPlace.coordinates;
  }

  String get _currentPlaceName {
    if (_userLocService.isGpsActive && _userLocService.currentGpsPosition != null) {
      return 'Live GPS Location (${_userLocService.city})';
    }
    return '${_userLocService.livingPlace.name}, ${_userLocService.city}';
  }

  String get _googleMapsUrl {
    final coords = _currentCoords;
    return 'https://www.google.com/maps?q=${coords.latitude.toStringAsFixed(6)},${coords.longitude.toStringAsFixed(6)}';
  }

  String get _formattedShareText {
    final coords = _currentCoords;
    return '📍 My current location: $_currentPlaceName\n'
        '🌐 Coordinates: ${coords.latitude.toStringAsFixed(6)}, ${coords.longitude.toStringAsFixed(6)}\n'
        '🗺️ View on Google Maps: $_googleMapsUrl';
  }

  Future<void> _detectGps() async {
    setState(() {
      _isFetchingGps = true;
      _statusMessage = null;
    });

    final position = await _userLocService.fetchCurrentGpsPosition();

    if (mounted) {
      setState(() {
        _isFetchingGps = false;
        if (position != null) {
          _statusMessage = 'GPS coordinates locked successfully!';
        } else {
          _statusMessage = 'Could not access GPS. Using ${_userLocService.city} base location.';
        }
      });
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

    return Dialog(
      backgroundColor: AppTheme.cardDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share_location, color: AppTheme.primaryLight, size: 28),
                ),
                const SizedBox(width: 14),
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
                        isGps ? 'Live Device GPS Active' : 'Based in ${_userLocService.city}, ${_userLocService.country}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isGps ? Colors.greenAccent : Colors.grey,
                        ),
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
            const SizedBox(height: 18),

            // Location Preview Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isGps ? Colors.greenAccent.withValues(alpha: 0.4) : Colors.white12,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isGps ? Icons.gps_fixed : Icons.home_filled,
                        color: isGps ? Colors.greenAccent : AppTheme.primaryLight,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _currentPlaceName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
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
                          isGps ? 'GPS ACTIVE' : 'BASE CITY',
                          style: TextStyle(
                            color: isGps ? Colors.greenAccent : Colors.amberAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black26,
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

            // GPS Refresh Button
            OutlinedButton.icon(
              icon: _isFetchingGps
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryLight),
                    )
                  : const Icon(Icons.my_location, size: 18),
              label: Text(_isFetchingGps ? 'Locating via GPS...' : 'Detect Exact Live GPS'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryLight,
                side: const BorderSide(color: AppTheme.primaryLight),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isFetchingGps ? null : _detectGps,
            ),

            const SizedBox(height: 14),
            const Divider(color: Colors.white12),
            const SizedBox(height: 8),

            // Share Actions Grid
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.link, size: 16),
                    label: const Text('Google Maps Link', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _copyToClipboard(_googleMapsUrl, 'Google Maps URL'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                    label: const Text('Share Text', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _copyToClipboard(_formattedShareText, 'Share Message'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Action: Use as Route Origin
            ElevatedButton.icon(
              icon: const Icon(Icons.navigation, size: 18),
              label: const Text('Set as Route Starting Point'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
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
    );
  }
}
