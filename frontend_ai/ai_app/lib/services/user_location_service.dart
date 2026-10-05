import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/map_route.dart';
import 'map_service.dart';

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
  String _city = 'Phnom Penh';
  PlaceLocation _livingPlace = PlaceLocation(
    name: 'Phnom Penh Home',
    displayName: 'Phnom Penh, Cambodia',
    coordinates: const LatLng(11.5564, 104.9282),
    type: 'home',
  );

  Position? _currentGpsPosition;
  bool _isGpsActive = false;

  String get country => _country;
  String get city => _city;
  PlaceLocation get livingPlace => _livingPlace;
  Position? get currentGpsPosition => _currentGpsPosition;
  bool get isGpsActive => _isGpsActive;

  PlaceLocation get effectiveOrigin {
    if (_isGpsActive && _currentGpsPosition != null) {
      return PlaceLocation(
        name: 'My GPS Location',
        displayName: 'Live GPS (${_currentGpsPosition!.latitude.toStringAsFixed(4)}, ${_currentGpsPosition!.longitude.toStringAsFixed(4)})',
        coordinates: LatLng(_currentGpsPosition!.latitude, _currentGpsPosition!.longitude),
        type: 'gps',
      );
    }
    return _livingPlace;
  }

  /// Request GPS permission and fetch live device coordinates
  Future<Position?> fetchCurrentGpsPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      _currentGpsPosition = position;
      _isGpsActive = true;
      notifyListeners();
      return position;
    } catch (e) {
      debugPrint('Error getting GPS location: $e');
      return null;
    }
  }

  void disableGps() {
    _isGpsActive = false;
    notifyListeners();
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
}
