import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/api_constants.dart';
import '../../models/map_route.dart';
import '../../services/map_service.dart';
import '../../services/user_location_service.dart';
import 'widgets/select_living_place_dialog.dart';
import 'widgets/share_location_dialog.dart';
import 'widgets/ai_search_destination_dialog.dart';

class MapGuideScreen extends StatefulWidget {
  const MapGuideScreen({super.key});

  @override
  State<MapGuideScreen> createState() => MapGuideScreenState();
}

class MapGuideScreenState extends State<MapGuideScreen> {
  final MapController _mapController = MapController();
  final MapService _mapService = MapService();
  final UserLocationService _userLocService = UserLocationService();
  final TextEditingController _searchController = TextEditingController();

  late PlaceLocation _origin;
  late PlaceLocation _destination;

  TravelMode _selectedMode = TravelMode.driving;
  RouteResult? _currentRoute;
  bool _isLoading = false;
  String _selectedTileLayer = 'google_standard';
  bool _showTraffic = false;

  String get _currentTileUrl {
    final keyParam = ApiConstants.googleMapsApiKey.isNotEmpty
        ? '&key=${ApiConstants.googleMapsApiKey}'
        : '';

    switch (_selectedTileLayer) {
      case 'google_standard':
        return _showTraffic
            ? 'https://mt{s}.google.com/vt/lyrs=m,traffic&x={x}&y={y}&z={z}$keyParam'
            : 'https://mt{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}$keyParam';

      case 'google_hybrid':
        return _showTraffic
            ? 'https://mt{s}.google.com/vt/lyrs=y,traffic&x={x}&y={y}&z={z}$keyParam'
            : 'https://mt{s}.google.com/vt/lyrs=y&x={x}&y={y}&z={z}$keyParam';

      case 'google_satellite':
        return 'https://mt{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}$keyParam';

      case 'google_terrain':
        return _showTraffic
            ? 'https://mt{s}.google.com/vt/lyrs=p,traffic&x={x}&y={y}&z={z}$keyParam'
            : 'https://mt{s}.google.com/vt/lyrs=p&x={x}&y={y}&z={z}$keyParam';

      case 'carto_dark':
        return 'https://basemaps.cartocdn.com/rastertiles/dark_all/{z}/{x}/{y}@2x.png';

      case 'osm':
      default:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  String get _layerDisplayName {
    switch (_selectedTileLayer) {
      case 'google_standard':
        return _showTraffic ? 'Google Maps (Traffic)' : 'Google Maps';
      case 'google_hybrid':
        return _showTraffic ? 'Google Hybrid (Traffic)' : 'Google Hybrid';
      case 'google_satellite':
        return 'Google Satellite';
      case 'google_terrain':
        return _showTraffic ? 'Google Terrain (Traffic)' : 'Google Terrain';
      case 'carto_dark':
        return 'Dark Mode';
      case 'osm':
      default:
        return 'OpenStreetMap';
    }
  }

  final List<Map<String, String>> _cambodiaQuickDestinations = [
    {'name': 'Siem Reap', 'label': 'Siem Reap'},
    {'name': 'Angkor Wat', 'label': 'Angkor Wat'},
    {'name': 'Phnom Penh', 'label': 'Phnom Penh'},
    {'name': 'Royal Palace, Phnom Penh', 'label': 'Royal Palace'},
    {'name': 'Bokor Mountain, Kampot', 'label': 'Kampot (Bokor)'},
    {'name': 'Battambang', 'label': 'Battambang'},
    {'name': 'Kep', 'label': 'Kep'},
    {'name': 'Bou Sra Waterfall, Mondulkiri', 'label': 'Mondulkiri'},
    {'name': 'Koh Rong', 'label': 'Koh Rong'},
    {'name': 'Sihanoukville', 'label': 'Sihanoukville'},
    {'name': 'Preah Vihear Temple', 'label': 'Preah Vihear'},
  ];

  bool _isFollowingUser = false;

  @override
  void initState() {
    super.initState();
    _userLocService.addListener(_onLocationServiceUpdate);
    _origin = _userLocService.effectiveOrigin;
    final landmarks = _userLocService.popularLandmarksInCity;
    final targetName = landmarks.isNotEmpty ? landmarks.first : 'City Center';
    _destination = PlaceLocation(
      name: targetName,
      displayName: '$targetName, ${_userLocService.city}',
      coordinates: LatLng(
        _origin.coordinates.latitude + 0.015,
        _origin.coordinates.longitude + 0.015,
      ),
    );
    _calculateRoute();

    // Auto-detect and connect live phone GPS on startup for mobile devices
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
        _detectAndCenterGps(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _userLocService.removeListener(_onLocationServiceUpdate);
    _searchController.dispose();
    super.dispose();
  }

  void _onLocationServiceUpdate() {
    if (!mounted) return;

    if (_userLocService.isGpsActive && _userLocService.currentGpsPosition != null) {
      final pos = _userLocService.currentGpsPosition!;
      final newCoords = LatLng(pos.latitude, pos.longitude);

      if (_isFollowingUser) {
        _mapController.move(newCoords, _mapController.camera.zoom);
      }

      if (_origin.type == 'gps') {
        _origin = _userLocService.effectiveOrigin;
      }
    }

    setState(() {});
  }

  void _openShareLocationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => ShareLocationDialog(
        onUseAsOrigin: () {
          setState(() {
            _origin = _userLocService.effectiveOrigin;
          });
          _mapController.move(_origin.coordinates, 14.5);
          _calculateRoute(customPrompt: 'Guiding from shared location ${_origin.name} to ${_destination.name}');
        },
      ),
    );
  }

  Future<void> _detectAndCenterGps({bool silent = false}) async {
    setState(() => _isLoading = true);
    final res = await _userLocService.startLiveLocationTracking(continuous: true);
    setState(() => _isLoading = false);

    if (res.success && res.position != null) {
      final pos = res.position!;
      final gpsCoords = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _origin = _userLocService.effectiveOrigin;
        _isFollowingUser = true;
      });
      _mapController.move(gpsCoords, 15.0);
      _calculateRoute(customPrompt: 'Guiding from user live GPS location to ${_destination.name}');
      if (mounted && !silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.gps_fixed, color: Colors.greenAccent, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Live GPS Active! Accuracy: ${pos.accuracy.toStringAsFixed(0)}m',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.cardDark,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else if (!silent) {
      _showLocationPermissionDialog(res);
    }
  }

  void _showLocationPermissionDialog(GpsResult res) {
    if (!mounted) return;

    if (res.status == GpsStatus.serviceDisabled) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.location_off_rounded, color: Colors.amberAccent),
              SizedBox(width: 10),
              Expanded(
                child: Text('Device Location Disabled', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
          content: const Text(
            'GPS / Location Services are currently turned off on your device. Please turn on Location in your phone settings to enable live GPS navigation.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.settings, size: 16),
              label: const Text('Open Location Settings'),
              onPressed: () {
                Navigator.pop(ctx);
                _userLocService.openLocationSettings();
              },
            ),
          ],
        ),
      );
    } else if (res.status == GpsStatus.permissionDeniedForever) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.lock_rounded, color: Colors.redAccent),
              SizedBox(width: 10),
              Expanded(
                child: Text('Location Permission Required', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
          content: const Text(
            'Location permission is permanently denied for DER LENG. To see your live location on the map and calculate real-time routes, please enable Location in App Settings.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.settings_applications, size: 16),
              label: const Text('Open App Settings'),
              onPressed: () {
                Navigator.pop(ctx);
                _userLocService.openAppSettings();
              },
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message),
          backgroundColor: AppTheme.cardDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openAiSearchDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AiSearchDestinationDialog(
        onDestinationSelected: (destination, prompt) {
          setState(() {
            _origin = _userLocService.effectiveOrigin;
            _destination = destination;
            _searchController.text = destination.name;
          });
          _mapController.move(destination.coordinates, 14.0);
          _calculateRoute(customPrompt: prompt);
          // Auto-show guidance sheet after calculating
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted && _currentRoute != null) {
              _showGuidanceDetailsModal();
            }
          });
        },
      ),
    );
  }

  void _openLivingPlaceSelector() {
    showDialog(
      context: context,
      builder: (ctx) => SelectLivingPlaceDialog(
        onLocationSelected: (country, city, coords, address) async {
          setState(() {
            _origin = _userLocService.livingPlace;
            _isLoading = true;
          });
          final landmarks = _userLocService.popularLandmarksInCity;
          if (landmarks.isNotEmpty) {
            final targetName = landmarks.first;
            final searchResults = await _mapService.searchPlace('$targetName, $city, $country');
            if (searchResults.isNotEmpty) {
              setState(() => _destination = searchResults.first);
            } else {
              setState(() {
                _destination = PlaceLocation(
                  name: targetName,
                  displayName: '$targetName, $city',
                  coordinates: LatLng(coords.latitude + 0.015, coords.longitude + 0.015),
                );
              });
            }
          }
          _mapController.move(coords, 13.5);
          _calculateRoute();
        },
      ),
    );
  }

  void setTargetDestination(String name, LatLng coords) {
    setState(() {
      _origin = _userLocService.effectiveOrigin;
      _destination = PlaceLocation(
        name: name,
        displayName: name,
        coordinates: coords,
      );
    });
    _mapController.move(coords, 14.0);
    _calculateRoute(customPrompt: 'Guiding from ${_origin.name} to scanned landmark $name');
  }

  Future<void> navigateToDestinationName(String placeName) async {
    _searchController.text = placeName;
    await _onSearchSubmit(placeName);
  }

  void _onSelectTravelMode(TravelMode mode) {
    if (_selectedMode == mode) return;

    setState(() {
      _selectedMode = mode;
      if (_currentRoute != null) {
        _currentRoute = _mapService.recalculateForMode(_currentRoute!, mode);
      }
    });

    _calculateRoute();
  }

  Future<void> _calculateRoute({String? customPrompt}) async {
    setState(() => _isLoading = true);
    try {
      final route = await _mapService.getRoute(
        origin: _origin,
        destination: _destination,
        mode: _selectedMode,
        userPrompt: customPrompt,
      );

      setState(() {
        _currentRoute = route;
      });

      // Fit map camera bounds to show both points and the route
      _fitRouteBounds();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to calculate route: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _fitRouteBounds() {
    if (_currentRoute == null || _currentRoute!.polylinePoints.isEmpty) return;
    final points = _currentRoute!.polylinePoints;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLon = points.first.longitude;
    double maxLon = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLon) minLon = p.longitude;
      if (p.longitude > maxLon) maxLon = p.longitude;
    }

    final centerLat = (minLat + maxLat) / 2;
    final centerLon = (minLon + maxLon) / 2;

    _mapController.move(LatLng(centerLat, centerLon), 13.5);
  }

  Future<void> _onSearchSubmit(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isLoading = true);

    try {
      // 1. Check if prompt is "A to B" format like "Phnom Penh to Siem Reap" or "from Central Park to Brooklyn Bridge"
      if (query.toLowerCase().contains(' to ')) {
        final parts = query.split(RegExp(r'\s+to\s+', caseSensitive: false));
        if (parts.length >= 2) {
          final originName = parts[0].replaceAll(RegExp(r'^(?:from|start from|i want to go from)\s+', caseSensitive: false), '').trim();
          final destName = MapService.extractDestinationFromPrompt(parts[1]);
          final originResults = await _mapService.searchPlace(originName);
          final destResults = await _mapService.searchPlace(destName);

          if (originResults.isNotEmpty && destResults.isNotEmpty) {
            setState(() {
              _origin = originResults.first;
              _destination = destResults.first;
            });
            await _calculateRoute(customPrompt: query);
            return;
          }
        }
      }

      // 2. Extract natural language target destination (e.g. "I want to go to Angkor Wat" -> "Angkor Wat")
      final targetPlace = MapService.extractDestinationFromPrompt(query);

      // Single destination query - guide from user's current effective location (live GPS or home)
      var results = await _mapService.searchPlace(targetPlace);
      if (results.isEmpty) {
        results = await _mapService.searchPlace('$targetPlace, Cambodia');
      }
      if (results.isNotEmpty) {
        setState(() {
          _origin = _userLocService.effectiveOrigin;
          _destination = results.first;
        });
        await _calculateRoute(customPrompt: 'Guiding from ${_origin.name} to $targetPlace ($query)');
        // If user asked in conversational / navigation tone, auto-open the AI guidance details modal
        final isConversational = query.toLowerCase().contains('go to') ||
            query.toLowerCase().contains('take me') ||
            query.toLowerCase().contains('guide') ||
            query.toLowerCase().contains('how to');
        if (isConversational) {
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted && _currentRoute != null) {
              _showGuidanceDetailsModal();
            }
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Place "$targetPlace" not found. Try another landmark or city.')),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _swapOriginDestination() {
    setState(() {
      final temp = _origin;
      _origin = _destination;
      _destination = temp;
    });
    _calculateRoute();
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    // Show quick sheet to set point as Origin or Destination
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.touch_app, color: AppTheme.primaryLight),
                  const SizedBox(width: 8),
                  Text(
                    'Selected Coordinates: ${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.trip_origin, color: Colors.greenAccent),
                title: const Text('Set as Origin (Start Point)', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _origin = PlaceLocation(
                      name: 'Custom Origin',
                      displayName: 'Lat: ${point.latitude.toStringAsFixed(4)}, Lon: ${point.longitude.toStringAsFixed(4)}',
                      coordinates: point,
                    );
                  });
                  _calculateRoute();
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_on, color: Colors.redAccent),
                title: const Text('Set as Destination (Get Directions)', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _destination = PlaceLocation(
                      name: 'Custom Destination',
                      displayName: 'Lat: ${point.latitude.toStringAsFixed(4)}, Lon: ${point.longitude.toStringAsFixed(4)}',
                      coordinates: point,
                    );
                  });
                  _calculateRoute();
                },
              ),
              ListTile(
                leading: const Icon(Icons.map_rounded, color: Color(0xFF1A73E8)),
                title: const Text('Open in Google Maps', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(ctx);
                  _mapService.openGoogleMapsDirections(
                    origin: _origin.coordinates,
                    destination: point,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGuidanceDetailsModal() {
    if (_currentRoute == null) return;
    final route = _currentRoute!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          expand: false,
          builder: (_, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade600,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'AI Map Guide & Turn-by-Turn',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // AI Notes Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    route.aiGuideNotes,
                    style: const TextStyle(color: Colors.white, height: 1.45, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 20),

                // Range / Metrics breakdown
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        icon: Icons.straighten,
                        title: 'Total Distance',
                        value: route.formattedDistance,
                        color: Colors.cyanAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricTile(
                        icon: Icons.timer,
                        title: 'Estimated Time',
                        value: route.formattedDuration,
                        color: Colors.amberAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Open in Google Maps action button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.navigation_rounded, color: Colors.white, size: 18),
                    label: const Text(
                      'Open in Google Maps (Turn-by-Turn GPS)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A73E8), // Google Maps Blue
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      _mapService.openGoogleMapsDirections(
                        origin: _origin.coordinates,
                        destination: _destination.coordinates,
                        mode: _selectedMode,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Navigation Steps',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),

                ...route.steps.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final step = entry.value;
                  return Card(
                    color: AppTheme.surfaceDark,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          '$idx',
                          style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        step.instruction,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      trailing: Text(
                        step.formattedDistance,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }

  void _showMapLayersBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade600,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.layers_rounded, color: Colors.cyanAccent, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Google Map Layers',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Section: Map Types
                    const Text(
                      'MAP TYPE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildLayerTypeOption(
                          label: 'Default',
                          icon: Icons.map_outlined,
                          isSelected: _selectedTileLayer == 'google_standard',
                          onTap: () {
                            setState(() => _selectedTileLayer = 'google_standard');
                            setSheetState(() {});
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildLayerTypeOption(
                          label: 'Hybrid',
                          icon: Icons.travel_explore_rounded,
                          isSelected: _selectedTileLayer == 'google_hybrid',
                          onTap: () {
                            setState(() => _selectedTileLayer = 'google_hybrid');
                            setSheetState(() {});
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildLayerTypeOption(
                          label: 'Satellite',
                          icon: Icons.satellite_alt_rounded,
                          isSelected: _selectedTileLayer == 'google_satellite',
                          onTap: () {
                            setState(() => _selectedTileLayer = 'google_satellite');
                            setSheetState(() {});
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildLayerTypeOption(
                          label: 'Terrain',
                          icon: Icons.terrain_rounded,
                          isSelected: _selectedTileLayer == 'google_terrain',
                          onTap: () {
                            setState(() => _selectedTileLayer = 'google_terrain');
                            setSheetState(() {});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Section: Map Details & Overlays
                    const Text(
                      'MAP DETAILS & OVERLAYS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Live Traffic Toggle
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _showTraffic
                              ? Colors.greenAccent.withValues(alpha: 0.6)
                              : AppTheme.borderDark,
                        ),
                      ),
                      child: SwitchListTile(
                        value: _showTraffic,
                        onChanged: (val) {
                          setState(() => _showTraffic = val);
                          setSheetState(() {});
                        },
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.traffic_rounded, color: Colors.greenAccent, size: 22),
                        ),
                        title: const Text(
                          'Live Traffic Conditions',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: const Text(
                          'Real-time green/orange/red traffic flow on roads',
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                        activeThumbColor: Colors.greenAccent,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Other styles row (Dark Mode & OpenStreetMap)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _selectedTileLayer == 'carto_dark' ? Colors.cyanAccent : Colors.grey,
                              side: BorderSide(
                                color: _selectedTileLayer == 'carto_dark' ? Colors.cyanAccent : AppTheme.borderDark,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.dark_mode_outlined, size: 16),
                            label: const Text('Dark Mode', style: TextStyle(fontSize: 12)),
                            onPressed: () {
                              setState(() => _selectedTileLayer = 'carto_dark');
                              setSheetState(() {});
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _selectedTileLayer == 'osm' ? Colors.cyanAccent : Colors.grey,
                              side: BorderSide(
                                color: _selectedTileLayer == 'osm' ? Colors.cyanAccent : AppTheme.borderDark,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.public_rounded, size: 16),
                            label: const Text('OpenStreetMap', style: TextStyle(fontSize: 12)),
                            onPressed: () {
                              setState(() => _selectedTileLayer = 'osm');
                              setSheetState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLayerTypeOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withValues(alpha: 0.3)
                : AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF10B981) : AppTheme.borderDark,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF10B981) : Colors.white70,
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. The Interactive Map
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _origin.coordinates,
            initialZoom: 13.0,
            onTap: _onMapTap,
            onPositionChanged: (camera, hasGesture) {
              if (hasGesture && _isFollowingUser) {
                setState(() => _isFollowingUser = false);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: _currentTileUrl,
              subdomains: const ['0', '1', '2', '3'],
              userAgentPackageName: 'com.example.ai_app',
              maxZoom: 20,
            ),
            if (_userLocService.isGpsActive && _userLocService.currentGpsPosition != null)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: LatLng(
                      _userLocService.currentGpsPosition!.latitude,
                      _userLocService.currentGpsPosition!.longitude,
                    ),
                    radius: (_userLocService.accuracy ?? 25.0).clamp(14.0, 50.0),
                    useRadiusInMeter: false,
                    color: const Color(0xFF10B981).withValues(alpha: 0.16),
                    borderColor: const Color(0xFF10B981).withValues(alpha: 0.5),
                    borderStrokeWidth: 1.5,
                  ),
                ],
              ),
            if (_currentRoute != null && _currentRoute!.polylinePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  // Outer glow
                  Polyline(
                    points: _currentRoute!.polylinePoints,
                    strokeWidth: 7.0,
                    color: Colors.blue.withValues(alpha: 0.4),
                  ),
                  // Inner solid line
                  Polyline(
                    points: _currentRoute!.polylinePoints,
                    strokeWidth: 4.5,
                    color: const Color(0xFF2563EB),
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                // Origin Pin (adapts to live GPS or base living location)
                Marker(
                  point: _origin.coordinates,
                  width: 90,
                  height: 65,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _userLocService.isGpsActive ? const Color(0xFF059669) : Colors.green.shade700,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_userLocService.isGpsActive)
                              Container(
                                width: 5,
                                height: 5,
                                margin: const EdgeInsets.only(right: 4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            Flexible(
                              child: Text(
                                _userLocService.isGpsActive
                                    ? (_userLocService.accuracy != null
                                        ? 'Live GPS (±${_userLocService.accuracy!.toStringAsFixed(0)}m)'
                                        : 'Live GPS')
                                    : _origin.name,
                                style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      _userLocService.isGpsActive
                          ? Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.6),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(Icons.navigation, color: Colors.white, size: 12),
                              ),
                            )
                          : const Icon(
                              Icons.trip_origin,
                              color: Colors.greenAccent,
                              size: 28,
                            ),
                    ],
                  ),
                ),
                // Destination Pin
                Marker(
                  point: _destination.coordinates,
                  width: 70,
                  height: 60,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _destination.name,
                          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.location_on, color: Colors.redAccent, size: 34),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        // 2. Top Floating AI Search & Controls Bar
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Location Bar: Living City Banner + Share Location + GPS Locate Button
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Base Living City
                      InkWell(
                        onTap: _openLivingPlaceSelector,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.cardDark.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.3)),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.home, color: Colors.greenAccent, size: 15),
                              const SizedBox(width: 5),
                              Text(
                                '${_userLocService.city}, ${_userLocService.country}',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('Change', style: TextStyle(color: AppTheme.primaryLight, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Share My Location Button
                      InkWell(
                        onTap: _openShareLocationDialog,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.cardDark.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.4)),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.share_location, color: Colors.cyanAccent, size: 15),
                              SizedBox(width: 5),
                              Text(
                                'Share Location',
                                style: TextStyle(color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Live GPS Button
                      InkWell(
                        onTap: _detectAndCenterGps,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _userLocService.isGpsActive
                                ? Colors.green.shade900.withValues(alpha: 0.85)
                                : AppTheme.cardDark.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _userLocService.isGpsActive ? Colors.greenAccent : Colors.white24,
                            ),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _userLocService.isGpsActive ? Icons.gps_fixed : Icons.my_location,
                                color: _userLocService.isGpsActive ? Colors.greenAccent : Colors.white70,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _userLocService.isGpsActive ? 'Live GPS Active' : 'Locate Me',
                                style: TextStyle(
                                  color: _userLocService.isGpsActive ? Colors.greenAccent : Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // 2. Search Input with direct "Ask AI" trigger
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                    ],
                    border: Border.all(color: Colors.white12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Where to? (e.g. "I want to go to Siem Reap")',
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.auto_awesome, color: AppTheme.primaryLight),
                        tooltip: 'AI Travel Assistant',
                        onPressed: _openAiSearchDialog,
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white54, size: 16),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            ),
                          _isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryLight),
                                  ),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.search, color: Colors.white70),
                                  onPressed: () => _onSearchSubmit(_searchController.text),
                                ),
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.auto_awesome, size: 12),
                              label: const Text('Ask AI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: _openAiSearchDialog,
                            ),
                          ),
                        ],
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onSubmitted: _onSearchSubmit,
                  ),
                ),
                const SizedBox(height: 8),

                // 3. Travel Mode Chips + Dynamic Local City Landmarks
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...TravelMode.values.map((mode) {
                        final isSelected = _selectedMode == mode;
                        IconData icon;
                        switch (mode) {
                          case TravelMode.driving:
                            icon = Icons.directions_car;
                            break;
                          case TravelMode.walking:
                            icon = Icons.directions_walk;
                            break;
                          case TravelMode.cycling:
                            icon = Icons.directions_bike;
                            break;
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(icon, size: 14, color: isSelected ? Colors.white : Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  mode.label,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey,
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            selected: isSelected,
                            selectedColor: AppTheme.primaryColor,
                            backgroundColor: AppTheme.cardDark.withValues(alpha: 0.9),
                            onSelected: (val) {
                              if (val) {
                                _onSelectTravelMode(mode);
                              }
                            },
                          ),
                        );
                      }),
                      // 1. My Current Location Quick Action Chip
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          backgroundColor: _userLocService.isGpsActive
                              ? (_isFollowingUser ? const Color(0xFF0F5132) : const Color(0xFF1B4332))
                              : AppTheme.cardDark.withValues(alpha: 0.95),
                          side: BorderSide(
                            color: _userLocService.isGpsActive
                                ? (_isFollowingUser ? Colors.cyanAccent : const Color(0xFF10B981))
                                : AppTheme.primaryLight,
                            width: 1.5,
                          ),
                          avatar: Icon(
                            _userLocService.isGpsActive ? Icons.gps_fixed : Icons.my_location,
                            size: 14,
                            color: _userLocService.isGpsActive
                                ? (_isFollowingUser ? Colors.cyanAccent : const Color(0xFF10B981))
                                : AppTheme.primaryLight,
                          ),
                          label: Text(
                            _userLocService.isGpsActive
                                ? (_isFollowingUser ? '📍 Following GPS' : '📍 My Live GPS')
                                : '📍 Enable Live GPS',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            if (_userLocService.isGpsActive && _userLocService.currentPosition != null) {
                              final pos = _userLocService.currentPosition!;
                              setState(() => _isFollowingUser = true);
                              _mapController.move(LatLng(pos.latitude, pos.longitude), 15.5);
                            } else {
                              _detectAndCenterGps();
                            }
                          },
                        ),
                      ),
                      // 2. Cambodian Common Destination Chips
                      ..._cambodiaQuickDestinations.map((dest) {
                        final isDest = _destination.name.toLowerCase().contains(dest['name']!.toLowerCase());
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ActionChip(
                            backgroundColor: isDest ? AppTheme.primaryColor : AppTheme.cardDark.withValues(alpha: 0.9),
                            side: BorderSide(
                              color: isDest ? const Color(0xFF10B981) : Colors.white24,
                            ),
                            avatar: Icon(
                              Icons.location_on,
                              size: 13,
                              color: isDest ? Colors.white : AppTheme.primaryLight,
                            ),
                            label: Text(
                              dest['label']!,
                              style: TextStyle(
                                color: isDest ? Colors.white : Colors.white70,
                                fontSize: 11,
                                fontWeight: isDest ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            onPressed: () async {
                              _searchController.text = dest['name']!;
                              await _onSearchSubmit(dest['name']!);
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. Compact Floating Map Tools (Positioned relative to bottom to avoid overlapping top chips or bottom route sheet)
        Positioned(
          right: 14,
          bottom: _currentRoute != null ? 180 : 28,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardDark.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _userLocService.isGpsActive && _isFollowingUser
                    ? Colors.cyanAccent.withValues(alpha: 0.6)
                    : Colors.white12,
              ),
              boxShadow: [
                BoxShadow(
                  color: _userLocService.isGpsActive && _isFollowingUser
                      ? Colors.cyanAccent.withValues(alpha: 0.2)
                      : Colors.black38,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. My GPS Location Button
                IconButton(
                  icon: Icon(
                    _userLocService.isGpsActive ? Icons.gps_fixed : Icons.my_location,
                    color: _userLocService.isGpsActive
                        ? (_isFollowingUser ? Colors.cyanAccent : Colors.greenAccent)
                        : AppTheme.primaryLight,
                    size: 20,
                  ),
                  tooltip: _isFollowingUser && _userLocService.isGpsActive
                      ? 'Following Live Location (Locked)'
                      : 'Center on Live Location',
                  onPressed: () {
                    if (_userLocService.isGpsActive && _userLocService.currentPosition != null) {
                      final pos = _userLocService.currentPosition!;
                      setState(() => _isFollowingUser = true);
                      _mapController.move(LatLng(pos.latitude, pos.longitude), 15.5);
                    } else {
                      _detectAndCenterGps();
                    }
                  },
                ),
                const Divider(color: Colors.white12, height: 1),
                // 2. Recenter / Fit Route Bounds Button
                IconButton(
                  icon: const Icon(Icons.center_focus_strong, color: Colors.white, size: 20),
                  tooltip: 'Fit Route Bounds',
                  onPressed: _fitRouteBounds,
                ),
                const Divider(color: Colors.white12, height: 1),
                // 3. Layer Selector (Google Maps Standard, Hybrid, Satellite, Terrain, Traffic, Dark, OSM)
                IconButton(
                  icon: const Icon(Icons.layers_rounded, color: Colors.cyanAccent, size: 20),
                  tooltip: 'Google Map Layers & Traffic',
                  onPressed: _showMapLayersBottomSheet,
                ),
                const Divider(color: Colors.white12, height: 1),
                // 4. Zoom In
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white70, size: 18),
                  tooltip: 'Zoom In',
                  onPressed: () {
                    final zoom = _mapController.camera.zoom + 1;
                    _mapController.move(_mapController.camera.center, zoom);
                  },
                ),
                const Divider(color: Colors.white12, height: 1),
                // 5. Zoom Out
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.white70, size: 18),
                  tooltip: 'Zoom Out',
                  onPressed: () {
                    final zoom = _mapController.camera.zoom - 1;
                    _mapController.move(_mapController.camera.center, zoom);
                  },
                ),
              ],
            ),
          ),
        ),

        // Floating Active Layer Indicator Badge (tap to change layer)
        Positioned(
          left: 14,
          bottom: _currentRoute != null ? 180 : 28,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showMapLayersBottomSheet,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _selectedTileLayer.startsWith('google')
                        ? Colors.cyanAccent.withValues(alpha: 0.5)
                        : Colors.white24,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _selectedTileLayer.startsWith('google') ? Icons.map_rounded : Icons.layers_outlined,
                      size: 14,
                      color: Colors.cyanAccent,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _layerDisplayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_showTraffic && _selectedTileLayer.startsWith('google')) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'TRAFFIC',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),

        // 4. Bottom Floating Range & Guidance Card
        if (_currentRoute != null)
          Positioned(
            left: 14,
            right: 14,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.cardDark.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 16, offset: Offset(0, 6)),
                ],
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Origin -> Destination with Swap
                  Row(
                    children: [
                      const Icon(Icons.trip_origin, color: Colors.greenAccent, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _origin.name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.swap_horiz, color: AppTheme.primaryLight, size: 22),
                        tooltip: 'Swap locations',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: _swapOriginDestination,
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _destination.name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 14),

                  // Distance, Duration & Quick Navigation Buttons (Responsive for Mobile)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Distance badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.straighten, size: 13, color: Colors.cyanAccent),
                              const SizedBox(width: 4),
                              Text(
                                _currentRoute!.formattedDistance,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.cyanAccent, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Duration badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.schedule, size: 13, color: Colors.amberAccent),
                              const SizedBox(width: 4),
                              Text(
                                _currentRoute!.formattedDuration,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amberAccent, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // AI Guide button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: _showGuidanceDetailsModal,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.assistant_navigation, size: 13),
                              SizedBox(width: 4),
                              Text('Guide', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Google Maps button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A73E8),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            _mapService.openGoogleMapsDirections(
                              origin: _origin.coordinates,
                              destination: _destination.coordinates,
                              mode: _selectedMode,
                            );
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.navigation_rounded, size: 13, color: Colors.white),
                              SizedBox(width: 4),
                              Text('Maps', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
