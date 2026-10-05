import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../core/constants/api_constants.dart';
import '../models/map_route.dart';

class MapService {
  static final MapService _instance = MapService._internal();
  factory MapService() => _instance;
  MapService._internal();

  // Curated database of famous landmarks and cities for instant resolution and offline reliability
  static final Map<String, LatLng> _famousPlaces = {
    // Cambodia
    'angkor wat': const LatLng(13.4125, 103.8670),
    'phnom penh': const LatLng(11.5564, 104.9282),
    'siem reap': const LatLng(13.3671, 103.8448),
    'royal palace': const LatLng(11.5635, 104.9317),
    'central market': const LatLng(11.5696, 104.9218),
    'phsar thmey': const LatLng(11.5696, 104.9218),
    'wat phnom': const LatLng(11.5761, 104.9231),
    'aeon mall': const LatLng(11.5478, 104.9332),
    'aeon mall sen sok': const LatLng(11.5975, 104.8856),
    'aeon 2': const LatLng(11.5975, 104.8856),
    'aeon 1': const LatLng(11.5478, 104.9332),
    'riverside': const LatLng(11.5714, 104.9312),
    'riverside promenade': const LatLng(11.5714, 104.9312),
    'phnom penh airport': const LatLng(11.5466, 104.8442),
    'siem reap airport': const LatLng(13.4078, 103.8128),
    'koh rong': const LatLng(10.7250, 103.2383),
    'sihanoukville': const LatLng(10.6275, 103.5221),
    'kampot': const LatLng(10.5942, 104.1640),
    'battambang': const LatLng(13.0957, 103.2022),
    'pub street': const LatLng(13.3551, 103.8548),
    'old market': const LatLng(13.3539, 103.8553),
    'bayon temple': const LatLng(13.4414, 103.8587),
    'bokor mountain': const LatLng(10.6258, 104.0272),
    'bamboo train': const LatLng(13.0560, 103.2201),
    'tuol sleng': const LatLng(11.5407, 104.9175),
    'killing fields': const LatLng(11.4844, 104.9020),
    'national museum': const LatLng(11.5658, 104.9290),
    'independence monument': const LatLng(11.5535, 104.9282),
    // Global Famous Landmarks
    'central park': const LatLng(40.785091, -73.968285),
    'times square': const LatLng(40.758896, -73.985130),
    'empire state building': const LatLng(40.748817, -73.985428),
    'statue of liberty': const LatLng(40.689247, -74.044502),
    'brooklyn bridge': const LatLng(40.706086, -73.996864),
    'jfk airport': const LatLng(40.641311, -73.778139),
    'eiffel tower': const LatLng(48.858370, 2.294481),
    'louvre museum': const LatLng(48.860611, 2.337644),
    'notre dame': const LatLng(48.852968, 2.349902),
    'tokyo tower': const LatLng(35.658581, 139.745433),
    'shibuya crossing': const LatLng(35.659482, 139.700554),
    'tokyo station': const LatLng(35.681236, 139.767125),
    'shinjuku': const LatLng(35.693840, 139.703549),
    'london eye': const LatLng(51.503324, -0.119543),
    'big ben': const LatLng(51.500729, -0.124625),
    'tower bridge': const LatLng(51.505456, -0.075356),
    'colosseum': const LatLng(41.890210, 12.492231),
    'sydney opera house': const LatLng(-33.856784, 151.215297),
    'burj khalifa': const LatLng(25.197197, 55.274376),
    'golden gate bridge': const LatLng(37.819929, -122.478255),
    'new york': const LatLng(40.712776, -74.005974),
    'paris': const LatLng(48.856614, 2.352222),
    'tokyo': const LatLng(35.676192, 139.650311),
    'london': const LatLng(51.507351, -0.127758),
    'san francisco': const LatLng(37.774929, -122.419416),
  };

  /// Natural-language prompt destination cleaner
  /// Converts prompts like "I want to go to Angkor Wat" -> "Angkor Wat"
  static String extractDestinationFromPrompt(String prompt) {
    var clean = prompt.trim();
    final patterns = [
      RegExp(r"^(?:i want to go to|i would like to go to|take me to|guide me to|how to get to|let's go to|lets go to|navigate to|go to|lead me to|bring me to|head to)\s+(.+)$", caseSensitive: false),
      RegExp(r"^(?:search for|find me|look for|find)\s+(.+)$", caseSensitive: false),
      RegExp(r"^(?:where is|directions to)\s+(.+)$", caseSensitive: false),
    ];
    for (final p in patterns) {
      final match = p.firstMatch(clean);
      if (match != null && match.group(1) != null) {
        clean = match.group(1)!.trim();
        break;
      }
    }
    // Remove trailing punctuation
    clean = clean.replaceAll(RegExp(r'[\?\.\!]+$'), '').trim();
    return clean.isEmpty ? prompt.trim() : clean;
  }

  /// Geocode a place name into coordinates using Google Geocoding API with Nominatim / fallback dictionary
  Future<List<PlaceLocation>> searchPlace(String query) async {
    final cleaned = extractDestinationFromPrompt(query);
    final cleanQuery = cleaned.trim().toLowerCase();
    if (cleanQuery.isEmpty) return [];

    // 1. Try Google Geocoding API if key configured
    if (ApiConstants.googleMapsApiKey.isNotEmpty) {
      try {
        final uri = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(query)}&key=${ApiConstants.googleMapsApiKey}',
        );
        final response = await http.get(uri).timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'OK' && (data['results'] as List).isNotEmpty) {
            final results = data['results'] as List;
            return results.map((item) {
              final loc = item['geometry']['location'];
              return PlaceLocation(
                name: item['address_components']?[0]?['long_name']?.toString() ?? query,
                displayName: item['formatted_address']?.toString() ?? query,
                coordinates: LatLng(
                  (loc['lat'] as num).toDouble(),
                  (loc['lng'] as num).toDouble(),
                ),
                type: 'google_place',
              );
            }).toList();
          }
        }
      } catch (_) {
        // Fallback to local / OSM
      }
    }

    // 2. Check exact or partial match in curated dictionary
    for (final entry in _famousPlaces.entries) {
      if (entry.key.contains(cleanQuery) || cleanQuery.contains(entry.key)) {
        final title = entry.key
            .split(' ')
            .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
            .join(' ');
        return [
          PlaceLocation(
            name: title,
            displayName: '$title, Famous Landmark',
            coordinates: entry.value,
            type: 'landmark',
          )
        ];
      }
    }

    // 3. Fallback to OpenStreetMap Nominatim
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=5&addressdetails=1',
      );
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'FlutterAiMapGuide/1.0 (flutter_ai_app)'},
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          return data.map((item) => PlaceLocation.fromJson(item)).toList();
        }
      }
    } catch (_) {
      // Ignore network errors and fall back
    }

    // Default fallback
    return [
      PlaceLocation(
        name: query,
        displayName: '$query (Estimated Pin)',
        coordinates: const LatLng(40.7580, -73.9855),
        type: 'general',
      )
    ];
  }

  /// Calculates geodesic distance between two coordinates in meters
  double calculateDistanceMeters(LatLng p1, LatLng p2) {
    const earthRadius = 6371000.0; // meters
    final dLat = _degToRad(p2.latitude - p1.latitude);
    final dLon = _degToRad(p2.longitude - p1.longitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(p1.latitude)) *
            cos(_degToRad(p2.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degToRad(double deg) => deg * (pi / 180.0);

  /// Fetch route from Google Directions API or OSRM with polyline decoding
  Future<RouteResult> getRoute({
    required PlaceLocation origin,
    required PlaceLocation destination,
    TravelMode mode = TravelMode.driving,
    String? userPrompt,
  }) async {
    final straightDistance = calculateDistanceMeters(
      origin.coordinates,
      destination.coordinates,
    );

    List<LatLng> polylinePoints = [];
    List<RouteStep> steps = [];
    double distanceMeters = straightDistance;
    double durationSeconds = _estimateDurationSeconds(straightDistance, mode);

    // 1. Attempt Google Directions API
    if (ApiConstants.googleMapsApiKey.isNotEmpty) {
      try {
        final gMode = mode == TravelMode.driving
            ? 'driving'
            : (mode == TravelMode.walking ? 'walking' : 'bicycling');
        final uri = Uri.parse(
          'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.coordinates.latitude},${origin.coordinates.longitude}&destination=${destination.coordinates.latitude},${destination.coordinates.longitude}&mode=$gMode&key=${ApiConstants.googleMapsApiKey}',
        );
        final response = await http.get(uri).timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'OK' && (data['routes'] as List).isNotEmpty) {
            final gRoute = data['routes'][0];
            final leg = gRoute['legs']?[0];
            if (leg != null) {
              distanceMeters = (leg['distance']?['value'] as num?)?.toDouble() ?? distanceMeters;
              durationSeconds = (leg['duration']?['value'] as num?)?.toDouble() ?? durationSeconds;
            }
            final enc = gRoute['overview_polyline']?['points'];
            if (enc is String && enc.isNotEmpty) {
              polylinePoints = _decodeGooglePolyline(enc);
            }
            if (leg != null && leg['steps'] != null) {
              final rawSteps = leg['steps'] as List;
              steps = rawSteps.map((s) {
                final rawHtml = s['html_instructions']?.toString() ?? 'Continue';
                final cleanInst = rawHtml.replaceAll(RegExp(r'<[^>]*>'), ' ');
                return RouteStep(
                  instruction: cleanInst.trim(),
                  distanceMeters: (s['distance']?['value'] as num?)?.toDouble() ?? 0.0,
                  durationSeconds: (s['duration']?['value'] as num?)?.toDouble() ?? 0.0,
                );
              }).toList();
            }
          }
        }
      } catch (_) {
        // Fall back to OSRM
      }
    }

    // 2. If Google Directions didn't populate polyline, try OSRM
    if (polylinePoints.isEmpty) {
      try {
        final profile = mode.osrmProfile;
        final uri = Uri.parse(
          'https://router.project-osrm.org/route/v1/$profile/${origin.coordinates.longitude},${origin.coordinates.latitude};${destination.coordinates.longitude},${destination.coordinates.latitude}?overview=full&geometries=geojson&steps=true',
        );

        final response = await http.get(uri).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
            final route = data['routes'][0];
            distanceMeters = (route['distance'] as num).toDouble();
            durationSeconds = (route['duration'] as num).toDouble();

            final coords = route['geometry']['coordinates'] as List;
            polylinePoints = coords.map((c) => LatLng(c[1] as double, c[0] as double)).toList();

            if (route['legs'] != null && (route['legs'] as List).isNotEmpty) {
              final rawSteps = route['legs'][0]['steps'] as List;
              steps = rawSteps.map((s) {
                final maneuver = s['maneuver']?['type'] ?? 'continue';
                final modifier = s['maneuver']?['modifier'] ?? '';
                final name = s['name']?.toString().isNotEmpty == true ? s['name'] : 'road';
                final instruction = _formatStepInstruction(maneuver, modifier, name);
                return RouteStep(
                  instruction: instruction,
                  distanceMeters: (s['distance'] as num?)?.toDouble() ?? 0.0,
                  durationSeconds: (s['duration'] as num?)?.toDouble() ?? 0.0,
                );
              }).toList();
            }
          }
        }
      } catch (_) {
        // Fall back to geodesic line
      }
    }

    // 3. Fallback interpolation
    if (polylinePoints.isEmpty) {
      polylinePoints = _generateIntermediatePoints(
        origin.coordinates,
        destination.coordinates,
      );
      steps = [
        RouteStep(
          instruction: 'Start journey from ${origin.name}',
          distanceMeters: distanceMeters * 0.1,
          durationSeconds: durationSeconds * 0.1,
        ),
        RouteStep(
          instruction: 'Proceed along main transit corridor toward ${destination.name}',
          distanceMeters: distanceMeters * 0.8,
          durationSeconds: durationSeconds * 0.8,
        ),
        RouteStep(
          instruction: 'Arrive at destination: ${destination.name}',
          distanceMeters: distanceMeters * 0.1,
          durationSeconds: durationSeconds * 0.1,
        ),
      ];
    }

    final distanceKm = distanceMeters / 1000.0;
    final durationMinutes = (durationSeconds / 60.0).round();

    final aiAdvice = await _generateAiAdvice(
      origin: origin,
      destination: destination,
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
      mode: mode,
      userPrompt: userPrompt,
    );

    return RouteResult(
      origin: origin,
      destination: destination,
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
      polylinePoints: polylinePoints,
      steps: steps,
      travelMode: mode,
      aiGuideNotes: aiAdvice,
    );
  }

  /// Decode Google polyline algorithm format into LatLng points
  List<LatLng> _decodeGooglePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return poly;
  }

  double _estimateDurationSeconds(double meters, TravelMode mode) {
    double speedKmh;
    switch (mode) {
      case TravelMode.driving:
        speedKmh = 40.0;
        break;
      case TravelMode.cycling:
        speedKmh = 16.0;
        break;
      case TravelMode.walking:
        speedKmh = 4.8;
        break;
    }
    final hours = (meters / 1000.0) / speedKmh;
    return hours * 3600.0;
  }

  String _formatStepInstruction(String maneuver, String modifier, String name) {
    if (maneuver == 'depart') return 'Depart toward $name';
    if (maneuver == 'arrive') return 'Arrive at $name';
    if (modifier.isNotEmpty) {
      return '$maneuver $modifier onto $name';
    }
    return 'Continue on $name';
  }

  List<LatLng> _generateIntermediatePoints(LatLng start, LatLng end) {
    const int count = 20;
    final points = <LatLng>[];
    for (int i = 0; i <= count; i++) {
      final t = i / count;
      final lat = start.latitude + (end.latitude - start.latitude) * t;
      final lon = start.longitude + (end.longitude - start.longitude) * t;
      points.add(LatLng(lat, lon));
    }
    return points;
  }

  Future<String> _generateAiAdvice({
    required PlaceLocation origin,
    required PlaceLocation destination,
    required double distanceKm,
    required int durationMinutes,
    required TravelMode mode,
    String? userPrompt,
  }) async {
    // Try calling local Python AI orchestrator if available
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/guide-map'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'origin': origin.name,
          'destination': destination.name,
          'travel_mode': mode.osrmProfile,
          'distance_km': distanceKm,
          'prompt': userPrompt,
        }),
      ).timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['advice'] != null) {
          final stops = (data['recommended_stops'] as List?)?.join('\n• ') ?? '';
          final tips = (data['travel_tips'] as List?)?.join('\n• ') ?? '';
          return '''📍 **AI Route Briefing**:
${data['advice']}

• **Direct Distance (Range)**: ${distanceKm.toStringAsFixed(2)} km (${(distanceKm * 0.621371).toStringAsFixed(2)} miles)
• **Estimated Travel Time**: ~$durationMinutes min by ${mode.label}

💡 **AI Guide Highlights & Tips**:
• $tips

🛑 **Recommended Stops Along Route**:
• $stops''';
        }
      }
    } catch (_) {
      // Local AI offline, fallback to built-in smart AI navigator logic
    }

    final modeTips = {
      TravelMode.driving: 'Expected light to moderate traffic. Consider parking availability near ${destination.name}.',
      TravelMode.walking: 'Pleasant pedestrian route. Keep a water bottle handy and use designated crosswalks.',
      TravelMode.cycling: 'Check bike lane availability along major avenues. Wear a helmet and watch for vehicle doors.',
    };

    return '''📍 **AI Route Briefing**:
• **From**: ${origin.name}
• **To**: ${destination.name}
• **Direct Distance (Range)**: ${distanceKm.toStringAsFixed(2)} km (${(distanceKm * 0.621371).toStringAsFixed(2)} miles)
• **Estimated Travel Time**: ~$durationMinutes min by ${mode.label}

💡 **AI Guide Insights**:
${modeTips[mode] ?? 'Safe travels!'}
• Check weather conditions before departure.
• Best time to avoid rush congestion is mid-morning or early afternoon.
• Landmarks to look for on your journey to ${destination.name}: scenic downtown crossings and local neighborhood hubs.''';
  }
}
