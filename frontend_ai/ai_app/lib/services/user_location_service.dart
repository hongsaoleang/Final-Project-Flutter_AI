import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import '../core/constants/api_constants.dart';
import '../models/map_route.dart';
import 'map_service.dart';

enum GpsStatus {
  idle,
  locating,
  active,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  error,
}

class GpsResult {
  final bool success;
  final Position? position;
  final GpsStatus status;
  final String message;

  const GpsResult({
    required this.success,
    this.position,
    required this.status,
    required this.message,
  });
}

class CityInfo {
  final String name;
  final LatLng coordinates;
  final List<String> popularLandmarks;

  const CityInfo({
    required this.name,
    required this.coordinates,
    this.popularLandmarks = const [],
  });
}

class CountryInfo {
  final String name;
  final String flag;
  final List<CityInfo> cities;

  const CountryInfo({
    required this.name,
    required this.flag,
    required this.cities,
  });
}

class UserLocationService extends ChangeNotifier {
  static final UserLocationService _instance = UserLocationService._internal();
  factory UserLocationService() => _instance;
  UserLocationService._internal();

  static const List<CountryInfo> supportedCountries = [
    CountryInfo(
      name: 'Cambodia',
      flag: '🇰🇭',
      cities: [
        CityInfo(
          name: 'Phnom Penh',
          coordinates: LatLng(11.5564, 104.9282),
          popularLandmarks: ['Royal Palace', 'Central Market (Phsar Thmey)', 'Wat Phnom', 'Aeon Mall', 'Riverside Promenade'],
        ),
        CityInfo(
          name: 'Siem Reap',
          coordinates: LatLng(13.3671, 103.8448),
          popularLandmarks: ['Angkor Wat', 'Pub Street', 'Old Market', 'Bayon Temple'],
        ),
        CityInfo(
          name: 'Battambang',
          coordinates: LatLng(13.0957, 103.2022),
          popularLandmarks: ['Bamboo Train', 'Phnom Sampeau', 'Wat Ek Phnom'],
        ),
        CityInfo(
          name: 'Sihanoukville',
          coordinates: LatLng(10.6275, 103.5221),
          popularLandmarks: ['Ochheuteal Beach', 'Koh Rong Ferry Terminal', 'Otres Beach'],
        ),
        CityInfo(
          name: 'Kampot',
          coordinates: LatLng(10.5942, 104.1640),
          popularLandmarks: ['Bokor Mountain', 'Kampot River', 'Durian Roundabout'],
        ),
      ],
    ),
    CountryInfo(
      name: 'United States',
      flag: '🇺🇸',
      cities: [
        CityInfo(
          name: 'New York',
          coordinates: LatLng(40.7128, -74.0060),
          popularLandmarks: ['Times Square', 'Central Park', 'Empire State Building', 'Brooklyn Bridge'],
        ),
        CityInfo(
          name: 'Los Angeles',
          coordinates: LatLng(34.0522, -118.2437),
          popularLandmarks: ['Hollywood Sign', 'Santa Monica Pier', 'Griffith Observatory'],
        ),
        CityInfo(
          name: 'Mountain View',
          coordinates: LatLng(37.4220, -122.0841),
          popularLandmarks: ['Shoreline Amphitheatre', 'Googleplex Campus', 'Castro Street Downtown', 'Computer History Museum'],
        ),
        CityInfo(
          name: 'San Francisco',
          coordinates: LatLng(37.7749, -122.4194),
          popularLandmarks: ['Golden Gate Bridge', 'Fisherman\'s Wharf', 'Alcatraz'],
        ),
      ],
    ),
    CountryInfo(
      name: 'France',
      flag: '🇫🇷',
      cities: [
        CityInfo(
          name: 'Paris',
          coordinates: LatLng(48.8566, 2.3522),
          popularLandmarks: ['Eiffel Tower', 'Louvre Museum', 'Notre Dame', 'Arc de Triomphe'],
        ),
        CityInfo(
          name: 'Lyon',
          coordinates: LatLng(45.7640, 4.8357),
          popularLandmarks: ['Basilique Notre-Dame de Fourviere', 'Vieux Lyon', 'Parc de la Tete d\'Or'],
        ),
      ],
    ),
    CountryInfo(
      name: 'Japan',
      flag: '🇯🇵',
      cities: [
        CityInfo(
          name: 'Tokyo',
          coordinates: LatLng(35.6762, 139.6503),
          popularLandmarks: ['Tokyo Tower', 'Shibuya Crossing', 'Senso-ji Temple', 'Shinjuku Gyoen'],
        ),
        CityInfo(
          name: 'Kyoto',
          coordinates: LatLng(35.0116, 135.7681),
          popularLandmarks: ['Fushimi Inari Shrine', 'Kinkaku-ji', 'Arashiyama Bamboo Grove'],
        ),
      ],
    ),
    CountryInfo(
      name: 'Thailand',
      flag: '🇹🇭',
      cities: [
        CityInfo(
          name: 'Bangkok',
          coordinates: LatLng(13.7563, 100.5018),
          popularLandmarks: ['Grand Palace', 'Wat Arun', 'Chatuchak Weekend Market', 'Siam Paragon'],
        ),
        CityInfo(
          name: 'Chiang Mai',
          coordinates: LatLng(18.7883, 98.9853),
          popularLandmarks: ['Wat Phra That Doi Suthep', 'Old City Temples', 'Night Bazaar'],
        ),
      ],
    ),
    CountryInfo(
      name: 'United Kingdom',
      flag: '🇬🇧',
      cities: [
        CityInfo(
          name: 'London',
          coordinates: LatLng(51.5074, -0.1278),
          popularLandmarks: ['Big Ben', 'London Eye', 'Tower of London', 'Buckingham Palace'],
        ),
      ],
    ),
    CountryInfo(
      name: 'Vietnam',
      flag: '🇻🇳',
      cities: [
        CityInfo(
          name: 'Ho Chi Minh City',
          coordinates: LatLng(10.8231, 106.6297),
          popularLandmarks: ['Ben Thanh Market', 'Notre-Dame Cathedral', 'War Remnants Museum'],
        ),
        CityInfo(
          name: 'Hanoi',
          coordinates: LatLng(21.0285, 105.8542),
          popularLandmarks: ['Hoan Kiem Lake', 'Old Quarter', 'Temple of Literature'],
        ),
      ],
    ),
    CountryInfo(
      name: 'Singapore',
      flag: '🇸🇬',
      cities: [
        CityInfo(
          name: 'Singapore',
          coordinates: LatLng(1.3521, 103.8198),
          popularLandmarks: ['Marina Bay Sands', 'Gardens by the Bay', 'Sentosa Island'],
        ),
      ],
    ),
  ];

  String _country = 'Cambodia';
  String _state = 'Phnom Penh';
  String _city = 'Phnom Penh';
  String _formattedAddress = 'Phnom Penh, Cambodia';
  bool _usePhnomPenhLocation = false;
  bool _isReverseGeocoding = false;
  DateTime? _lastReverseGeocodeTime;
  LatLng? _lastGeocodedCoords;
  bool _hasInitialized = false;

  PlaceLocation _livingPlace = PlaceLocation(
    name: 'Phnom Penh',
    displayName: 'Phnom Penh, Cambodia',
    coordinates: const LatLng(11.5564, 104.9282),
    type: 'home',
  );

  Position? _currentGpsPosition;
  bool _isGpsActive = false;
  bool _isLiveTracking = false;
  GpsStatus _gpsStatus = GpsStatus.idle;
  StreamSubscription<Position>? _positionStreamSub;
  double? _heading;
  double? _speed;
  double? _accuracy;

  String get country => _country;
  String get state => _state;
  String get city => _city;
  String get formattedAddress => _formattedAddress;
  String get stateOrCity => _state.isNotEmpty ? _state : _city;
  bool get isReverseGeocoding => _isReverseGeocoding;
  PlaceLocation get livingPlace => _livingPlace;
  Position? get currentGpsPosition => _currentGpsPosition;
  Position? get currentPosition => _currentGpsPosition;
  bool get isGpsActive => _isGpsActive;
  bool get isLiveTracking => _isLiveTracking;
  bool get usePhnomPenhLocation => _usePhnomPenhLocation;
  GpsStatus get gpsStatus => _gpsStatus;
  double? get heading => _heading;
  double? get speed => _speed;
  double? get accuracy => _accuracy;

  PlaceLocation get effectiveOrigin {
    if (!_usePhnomPenhLocation &&
        _isGpsActive &&
        _currentGpsPosition != null &&
        (_currentGpsPosition!.latitude.abs() > 0.05 || _currentGpsPosition!.longitude.abs() > 0.05)) {
      String placeName;
      if (_city.isNotEmpty && _state.isNotEmpty && _city != _state) {
        placeName = '$_city, $_state';
      } else if (_state.isNotEmpty) {
        placeName = _state;
      } else if (_city.isNotEmpty) {
        placeName = _city;
      } else {
        placeName = 'Live GPS Location';
      }

      final disp = _formattedAddress.isNotEmpty
          ? _formattedAddress
          : 'Live GPS (${_currentGpsPosition!.latitude.toStringAsFixed(4)}, ${_currentGpsPosition!.longitude.toStringAsFixed(4)})';

      return PlaceLocation(
        name: placeName,
        displayName: disp,
        coordinates: LatLng(_currentGpsPosition!.latitude, _currentGpsPosition!.longitude),
        type: 'gps',
      );
    }
    return _livingPlace;
  }

  /// Select Phnom Penh as the active share and routing location
  void selectPhnomPenhLocation({
    String name = 'Phnom Penh',
    String specificAddress = 'Phnom Penh, Cambodia',
    LatLng coordinates = const LatLng(11.5564, 104.9282),
  }) {
    _usePhnomPenhLocation = true;
    _country = 'Cambodia';
    _state = 'Phnom Penh';
    _city = 'Phnom Penh';
    _formattedAddress = specificAddress;
    _livingPlace = PlaceLocation(
      name: name,
      displayName: specificAddress,
      coordinates: coordinates,
      type: 'home',
    );
    notifyListeners();
  }

  void switchToDeviceGps() {
    _usePhnomPenhLocation = false;
    notifyListeners();
  }

  /// Automatically initialize location tracking on app startup
  Future<void> initLocationOnStartup() async {
    if (_hasInitialized) return;
    _hasInitialized = true;
    try {
      await startLiveLocationTracking(continuous: true);
    } catch (e) {
      debugPrint('Startup location init error: $e');
    }
  }

  void updateGpsPosition(Position pos) => _updateGpsPosition(pos);

  void _updateGpsPosition(Position pos) {
    // Ignore invalid / uncalibrated (0, 0) coordinates (Null Island in open ocean)
    if (pos.latitude.abs() < 0.05 && pos.longitude.abs() < 0.05) {
      debugPrint('Ignoring zero/ocean GPS coordinates: ${pos.latitude}, ${pos.longitude}');
      return;
    }

    _currentGpsPosition = pos;
    _heading = pos.heading;
    _speed = pos.speed;
    _accuracy = pos.accuracy;
    _isGpsActive = true;
    _gpsStatus = GpsStatus.active;
    notifyListeners();

    // Trigger reverse geocoding asynchronously to resolve real State, City & Country
    _reverseGeocode(pos.latitude, pos.longitude);
  }

  /// Reverse geocode coordinates to extract real State, City, Country and Address
  Future<void> _reverseGeocode(double lat, double lng) async {
    // If Phnom Penh is explicitly selected as share location, do not overwrite with emulator coordinates
    if (_usePhnomPenhLocation) {
      return;
    }

    // Prevent duplicate calls if moved less than 150m within 15 seconds
    if (_lastGeocodedCoords != null && _lastReverseGeocodeTime != null) {
      final elapsed = DateTime.now().difference(_lastReverseGeocodeTime!);
      if (elapsed < const Duration(seconds: 15)) {
        final dist = MapService().calculateDistanceMeters(
          _lastGeocodedCoords!,
          LatLng(lat, lng),
        );
        if (dist < 150) return;
      }
    }

    _lastGeocodedCoords = LatLng(lat, lng);
    _lastReverseGeocodeTime = DateTime.now();
    _isReverseGeocoding = true;

    try {
      // 1. Query Nominatim with English localization
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json&accept-language=en',
      );
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'DerLengTravelApp/1.0 (cambodia.travel.app)'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final addr = data['address'] as Map<String, dynamic>?;
        if (addr != null) {
          final fetchedCountry = addr['country']?.toString() ?? '';
          final fetchedState = addr['state']?.toString() ??
              addr['province']?.toString() ??
              addr['region']?.toString() ??
              '';
          final fetchedCity = addr['city']?.toString() ??
              addr['town']?.toString() ??
              addr['municipality']?.toString() ??
              addr['village']?.toString() ??
              addr['county']?.toString() ??
              '';
          final displayName = data['display_name']?.toString() ?? '';

          if (fetchedCountry.isNotEmpty) _country = fetchedCountry;
          if (fetchedState.isNotEmpty) _state = fetchedState;
          if (fetchedCity.isNotEmpty) _city = fetchedCity;
          if (displayName.isNotEmpty) _formattedAddress = displayName;

          _isReverseGeocoding = false;
          notifyListeners();
          return;
        }
      }
    } catch (e) {
      debugPrint('Nominatim reverse geocode error: $e');
    }

    // 2. Fallback to Google Geocoding if configured
    if (ApiConstants.googleMapsApiKey.isNotEmpty) {
      try {
        final gUri = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=${ApiConstants.googleMapsApiKey}&language=en',
        );
        final gRes = await http.get(gUri).timeout(const Duration(seconds: 4));
        if (gRes.statusCode == 200) {
          final gData = json.decode(gRes.body);
          if (gData['status'] == 'OK' && (gData['results'] as List).isNotEmpty) {
            final firstResult = gData['results'][0];
            _formattedAddress = firstResult['formatted_address']?.toString() ?? _formattedAddress;
            final components = firstResult['address_components'] as List? ?? [];
            for (final comp in components) {
              final types = (comp['types'] as List?)?.map((t) => t.toString()).toList() ?? [];
              if (types.contains('administrative_area_level_1')) {
                _state = comp['long_name']?.toString() ?? _state;
              }
              if (types.contains('locality') || types.contains('administrative_area_level_2')) {
                _city = comp['long_name']?.toString() ?? _city;
              }
              if (types.contains('country')) {
                _country = comp['long_name']?.toString() ?? _country;
              }
            }
            _isReverseGeocoding = false;
            notifyListeners();
            return;
          }
        }
      } catch (e) {
        debugPrint('Google Geocoding error: $e');
      }
    }

    _isReverseGeocoding = false;
    notifyListeners();
  }

  /// Start live continuous location tracking on the device or emulator
  Future<GpsResult> startLiveLocationTracking({bool continuous = true}) async {
    try {
      _gpsStatus = GpsStatus.locating;
      notifyListeners();

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _gpsStatus = GpsStatus.serviceDisabled;
        notifyListeners();
        return const GpsResult(
          success: false,
          status: GpsStatus.serviceDisabled,
          message: 'Location services are turned off on your device. Please turn on GPS in emulator settings.',
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _gpsStatus = GpsStatus.permissionDenied;
          notifyListeners();
          return const GpsResult(
            success: false,
            status: GpsStatus.permissionDenied,
            message: 'Location permission was denied. Please allow location access.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _gpsStatus = GpsStatus.permissionDeniedForever;
        notifyListeners();
        return const GpsResult(
          success: false,
          status: GpsStatus.permissionDeniedForever,
          message: 'Location permission is permanently denied. Please enable it in Settings.',
        );
      }

      Position? currentPos;

      // 1. Fast initial lock: check last known position (often immediately available on emulators)
      try {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          currentPos = lastKnown;
          _updateGpsPosition(lastKnown);
        }
      } catch (e) {
        debugPrint('getLastKnownPosition error: $e');
      }

      // 2. Start continuous stream immediately so any fix from FusedLocation/Mock is captured
      if (continuous) {
        await _positionStreamSub?.cancel();
        const settings = LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 2,
        );
        _positionStreamSub = Geolocator.getPositionStream(locationSettings: settings).listen(
          (pos) {
            _updateGpsPosition(pos);
          },
          onError: (err) {
            debugPrint('Location stream error: $err');
          },
        );
        _isLiveTracking = true;
      }

      // 3. If last known wasn't available, request current position with best accuracy
      if (currentPos == null) {
        try {
          currentPos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.best,
              timeLimit: Duration(seconds: 4),
            ),
          );
          _updateGpsPosition(currentPos);
        } catch (e) {
          debugPrint('High accuracy getCurrentPosition failed/timed out: $e');
          // 4. Fallback: query low/medium accuracy or stream's first event
          if (currentPos == null && _currentGpsPosition == null) {
            try {
              currentPos = await Geolocator.getCurrentPosition(
                locationSettings: const LocationSettings(
                  accuracy: LocationAccuracy.low,
                  timeLimit: Duration(seconds: 4),
                ),
              );
              _updateGpsPosition(currentPos);
            } catch (e2) {
              debugPrint('Low accuracy fallback failed: $e2');
            }
          }
        }
      }

      final effectivePos = currentPos ?? _currentGpsPosition;
      if (effectivePos != null && (effectivePos.latitude.abs() > 0.05 || effectivePos.longitude.abs() > 0.05)) {
        _updateGpsPosition(effectivePos);
        return GpsResult(
          success: true,
          position: effectivePos,
          status: GpsStatus.active,
          message: 'Live GPS connected! Accuracy: ${effectivePos.accuracy.toStringAsFixed(1)}m',
        );
      } else {
        return const GpsResult(
          success: false,
          status: GpsStatus.error,
          message: 'Waiting for location signal. Ensure Location is enabled in Android Emulator.',
        );
      }
    } catch (e) {
      debugPrint('Error starting live location: $e');
      if (_currentGpsPosition != null) {
        return GpsResult(
          success: true,
          position: _currentGpsPosition,
          status: GpsStatus.active,
          message: 'Live GPS connected using available position.',
        );
      }
      _gpsStatus = GpsStatus.error;
      notifyListeners();
      return GpsResult(
        success: false,
        status: GpsStatus.error,
        message: 'Could not acquire live location: $e',
      );
    }
  }

  /// Single GPS fetch fallback
  Future<Position?> fetchCurrentGpsPosition() async {
    final res = await startLiveLocationTracking(continuous: true);
    return res.position;
  }

  void stopLiveTracking() {
    _positionStreamSub?.cancel();
    _positionStreamSub = null;
    _isLiveTracking = false;
    notifyListeners();
  }

  void disableGps() {
    stopLiveTracking();
    _isGpsActive = false;
    _gpsStatus = GpsStatus.idle;
    notifyListeners();
  }

  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  List<String> get popularLandmarksInCity {
    for (final c in supportedCountries) {
      if (c.name.toLowerCase() == _country.toLowerCase()) {
        for (final ci in c.cities) {
          if (ci.name.toLowerCase() == _city.toLowerCase()) {
            return ci.popularLandmarks;
          }
        }
      }
    }
    return ['City Center', 'Main Market', 'Central Station', 'Popular Cafe', 'Public Hospital'];
  }

  void setLivingPlace({
    required String country,
    required String city,
    required LatLng coordinates,
    String? specificAddress,
  }) {
    _country = country;
    _city = city;
    _livingPlace = PlaceLocation(
      name: specificAddress != null && specificAddress.isNotEmpty
          ? specificAddress
          : '$city Home',
      displayName: '$city, $country',
      coordinates: coordinates,
      type: 'home',
    );
    notifyListeners();
  }

  Future<bool> setCustomLocation(String customQuery) async {
    final results = await MapService().searchPlace(customQuery);
    if (results.isNotEmpty) {
      final loc = results.first;
      _city = loc.name;
      _country = 'Custom';
      _livingPlace = PlaceLocation(
        name: '${loc.name} Home',
        displayName: loc.displayName,
        coordinates: loc.coordinates,
        type: 'home',
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  /// One-tap direct share of current live location where the user is located right now
  Future<void> shareLiveLocation(
    BuildContext context, {
    PlaceLocation? destination,
    RouteResult? route,
    TravelMode? mode,
    bool forceLiveGps = true,
  }) async {
    return shareRealTimeLiveGps(
      context,
      includeDestination: destination != null,
      destination: destination,
      route: route,
      mode: mode,
    );
  }

  /// Direct method to share the real-time sensor GPS live location from phone/emulator
  Future<void> shareRealTimeLiveGps(
    BuildContext context, {
    bool includeDestination = false,
    PlaceLocation? destination,
    RouteResult? route,
    TravelMode? mode,
  }) async {
    // 1. Ensure live tracking is active
    if (!_isGpsActive || _currentGpsPosition == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.greenAccent),
                ),
                SizedBox(width: 10),
                Text('Getting location...'),
              ],
            ),
            backgroundColor: Color(0xFF1E293B),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      final res = await startLiveLocationTracking(continuous: true);
      if (!res.success && _currentGpsPosition == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res.message),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
    }

    // Ensure fresh real-time sensor GPS position where the user is currently located
    Position? pos = _currentGpsPosition;
    try {
      final fresh = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 4),
        ),
      );
      if (fresh.latitude.abs() > 0.05 || fresh.longitude.abs() > 0.05) {
        pos = fresh;
        _updateGpsPosition(fresh);
      }
    } catch (_) {
      pos ??= await Geolocator.getLastKnownPosition();
    }

    if (pos == null || (pos.latitude.abs() <= 0.05 && pos.longitude.abs() <= 0.05)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not acquire current GPS location. Please enable Location in Settings.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final coords = LatLng(pos.latitude, pos.longitude);

    final googleMapsUrl = 'https://www.google.com/maps?q=${coords.latitude.toStringAsFixed(6)},${coords.longitude.toStringAsFixed(6)}';

    // Share ONLY the direct location URL so mobile OS shares a rich location pin, NOT text
    final String shareText;
    if (includeDestination && destination != null) {
      final destCoords = destination.coordinates;
      shareText = 'https://www.google.com/maps/dir/?api=1&origin=${coords.latitude.toStringAsFixed(6)},${coords.longitude.toStringAsFixed(6)}&destination=${destCoords.latitude.toStringAsFixed(6)},${destCoords.longitude.toStringAsFixed(6)}';
    } else {
      shareText = googleMapsUrl;
    }

    // Copy direct location link to clipboard immediately
    await Clipboard.setData(ClipboardData(text: shareText));

    try {
      Rect? originRect;
      if (context.mounted) {
        try {
          final box = context.findRenderObject() as RenderBox?;
          if (box != null && box.hasSize && box.attached) {
            originRect = box.localToGlobal(Offset.zero) & box.size;
          }
        } catch (_) {}
      }

      await SharePlus.instance.share(
        ShareParams(
          text: shareText,
          subject: 'My Current Location',
          title: 'Share Location',
          sharePositionOrigin: originRect,
        ),
      );
    } catch (e) {
      debugPrint('Share location error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location link copied: $googleMapsUrl'),
            backgroundColor: const Color(0xFF1E293B),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
