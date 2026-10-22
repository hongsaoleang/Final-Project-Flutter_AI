import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/api_constants.dart';
import '../models/map_route.dart';

class MapService {
  static final MapService _instance = MapService._internal();
  factory MapService() => _instance;
  MapService._internal();

  // Curated database of famous landmarks, cities, and all 25 provinces in Cambodia
  static final Map<String, LatLng> _famousPlaces = {
    // Cambodia Provinces & Cities
    'phnom penh': const LatLng(11.5564, 104.9282),
    'siem reap': const LatLng(13.3671, 103.8448),
    'angkor wat': const LatLng(13.4125, 103.8670),
    'bayon temple': const LatLng(13.4414, 103.8587),
    'ta prohm': const LatLng(13.4348, 103.8893),
    'banteay srei': const LatLng(13.5989, 103.9630),
    'phnom kulen': const LatLng(13.5667, 104.1000),
    'tonle sap': const LatLng(13.0000, 104.0000),
    'pub street': const LatLng(13.3551, 103.8548),
    'old market': const LatLng(13.3539, 103.8553),
    'royal palace': const LatLng(11.5635, 104.9317),
    'central market': const LatLng(11.5696, 104.9218),
    'phsar thmey': const LatLng(11.5696, 104.9218),
    'wat phnom': const LatLng(11.5761, 104.9231),
    'riverside': const LatLng(11.5714, 104.9312),
    'riverside promenade': const LatLng(11.5714, 104.9312),
    'tuol sleng': const LatLng(11.5407, 104.9175),
    'killing fields': const LatLng(11.4844, 104.9020),
    'national museum': const LatLng(11.5658, 104.9290),
    'independence monument': const LatLng(11.5535, 104.9282),
    'bassac lane': const LatLng(11.5502, 104.9310),
    'aeon mall': const LatLng(11.5478, 104.9332),
    'aeon mall sen sok': const LatLng(11.5975, 104.8856),
    'kampot': const LatLng(10.5942, 104.1640),
    'bokor mountain': const LatLng(10.6258, 104.0272),
    'teuk chhou': const LatLng(10.6653, 104.2253),
    'kep': const LatLng(10.4828, 104.2941),
    'kep crab market': const LatLng(10.4862, 104.2965),
    'rabbit island': const LatLng(10.4372, 104.3283),
    'koh tonsay': const LatLng(10.4372, 104.3283),
    'battambang': const LatLng(13.0957, 103.2022),
    'bamboo train': const LatLng(13.0560, 103.2201),
    'phnom sampeau': const LatLng(13.0239, 103.0984),
    'wat banan': const LatLng(12.9667, 103.1500),
    'wat ek phnom': const LatLng(13.1583, 103.1833),
    'sihanoukville': const LatLng(10.6275, 103.5221),
    'koh rong': const LatLng(10.7250, 103.2383),
    'koh rong sanloem': const LatLng(10.6083, 103.2986),
    'otres beach': const LatLng(10.5739, 103.5519),
    'mondulkiri': const LatLng(12.4558, 107.1881),
    'sen monorom': const LatLng(12.4558, 107.1881),
    'bou sra waterfall': const LatLng(12.5694, 107.4194),
    'ratanakiri': const LatLng(13.7394, 106.9873),
    'banlung': const LatLng(13.7394, 106.9873),
    'yeak laom lake': const LatLng(13.7317, 107.0189),
    'preah vihear': const LatLng(13.8072, 104.9814),
    'preah vihear temple': const LatLng(14.3908, 104.6800),
    'kampong cham': const LatLng(11.9934, 105.4635),
    'kampong chhnang': const LatLng(12.2500, 104.6667),
    'kampong speu': const LatLng(11.4533, 104.5208),
    'kampong thom': const LatLng(12.7111, 104.8889),
    'sambor prei kuk': const LatLng(12.8711, 105.0400),
    'kandal': const LatLng(11.4833, 104.9500),
    'takhmao': const LatLng(11.4833, 104.9500),
    'koh kong': const LatLng(11.6153, 102.9838),
    'kratie': const LatLng(12.4881, 106.0188),
    'pailin': const LatLng(12.8489, 102.6092),
    'pursat': const LatLng(12.5388, 103.9192),
    'prey veng': const LatLng(11.4751, 105.3381),
    'krong prey veng': const LatLng(11.4751, 105.3381),
    'prey veng province': const LatLng(11.3660, 105.4557),
    'ba phnom': const LatLng(11.2333, 105.3500),
    'chhrouy chek': const LatLng(11.5167, 105.3667),
    'stung treng': const LatLng(13.5259, 105.9683),
    'svay rieng': const LatLng(11.0879, 105.7993),
    'takeo': const LatLng(10.9908, 104.7850),
    'tboung khmum': const LatLng(11.9167, 105.6500),
    'oddar meanchey': const LatLng(14.1833, 103.5167),
  };

  static String _formatPlaceTitle(String key) {
    return key
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : '')
        .join(' ');
  }

  /// Resolve a landmark/place name to curated exact coordinates (avoiding rivers/water)
  LatLng? getFamousPlaceCoordinates(String name) {
    final clean = name.toLowerCase().trim();
    if (_famousPlaces.containsKey(clean)) return _famousPlaces[clean];
    for (final entry in _famousPlaces.entries) {
      if (clean.contains(entry.key) || entry.key.contains(clean)) {
        return entry.value;
      }
    }
    return null;
  }

  /// Launch Google Maps navigation between origin and destination with active travel mode
  Future<bool> openGoogleMapsDirections({
    required LatLng origin,
    required LatLng destination,
    TravelMode mode = TravelMode.driving,
  }) async {
    final origLat = origin.latitude;
    final origLng = origin.longitude;
    final destLat = destination.latitude;
    final destLng = destination.longitude;

    final url =
        'https://www.google.com/maps/dir/?api=1&origin=$origLat,$origLng&destination=$destLat,$destLng&travelmode=${mode.googleMode}';
    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        return await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      return await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  /// Natural-language prompt destination cleaner
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
    clean = clean.replaceAll(RegExp(r'[\?\.\!]+$'), '').trim();
    return clean.isEmpty ? prompt.trim() : clean;
  }

  /// Geocode a place name into coordinates using local dictionary, Nominatim, or Google Geocoding
  Future<List<PlaceLocation>> searchPlace(String query) async {
    final cleaned = extractDestinationFromPrompt(query);
    final cleanQuery = cleaned.trim().toLowerCase();
    if (cleanQuery.isEmpty) return [];

    // 1. Direct exact match in curated Cambodian places dictionary
    if (_famousPlaces.containsKey(cleanQuery)) {
      final coords = _famousPlaces[cleanQuery]!;
      final title = _formatPlaceTitle(cleanQuery);
      return [
        PlaceLocation(
          name: title,
          displayName: '$title, Cambodia',
          coordinates: coords,
          type: 'landmark',
        )
      ];
    }

    // 2. Substring match prioritizing keys that appear at the beginning or have longer match
    final matchingKeys = _famousPlaces.keys
        .where((k) => cleanQuery.startsWith(k) || cleanQuery.contains(k) || k.contains(cleanQuery))
        .toList();
    if (matchingKeys.isNotEmpty) {
      matchingKeys.sort((a, b) {
        final aIdx = cleanQuery.indexOf(a);
        final bIdx = cleanQuery.indexOf(b);
        if (aIdx != -1 && bIdx != -1 && aIdx != bIdx) {
          return aIdx.compareTo(bIdx); // Appears earlier in prompt
        }
        return b.length.compareTo(a.length); // Longer match first
      });
      final bestKey = matchingKeys.first;
      final coords = _famousPlaces[bestKey]!;
      final title = _formatPlaceTitle(bestKey);
      return [
        PlaceLocation(
          name: title,
          displayName: '$title, Cambodia',
          coordinates: coords,
          type: 'landmark',
        )
      ];
    }

    // 3. Fallback to OpenStreetMap Nominatim API
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent('$cleaned, Cambodia')}&format=json&limit=5&countrycodes=kh',
      );
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'DerLengTravelApp/1.0 (cambodia.travel.app)'},
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          return data.map((item) => PlaceLocation.fromJson(item)).toList();
        }
      }
    } catch (_) {}

    // 4. Try Google Geocoding API if configured
    if (ApiConstants.googleMapsApiKey.isNotEmpty) {
      try {
        final uri = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent('$cleaned, Cambodia')}&key=${ApiConstants.googleMapsApiKey}',
        );
        final response = await http.get(uri).timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'OK' && (data['results'] as List).isNotEmpty) {
            final results = data['results'] as List;
            return results.map((item) {
              final loc = item['geometry']['location'];
              return PlaceLocation(
                name: item['address_components']?[0]?['long_name']?.toString() ?? cleaned,
                displayName: item['formatted_address']?.toString() ?? cleaned,
                coordinates: LatLng(
                  (loc['lat'] as num).toDouble(),
                  (loc['lng'] as num).toDouble(),
                ),
                type: (item['types'] as List?)?.firstOrNull?.toString(),
              );
            }).toList();
          }
        }
      } catch (_) {}
    }

    return [];
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

  /// Computes realistic, logical distance and duration for Drive, Walk, and Cycle
  ModeMetrics computeModeMetrics({
    required double baselineRoadMeters,
    required double straightMeters,
    required TravelMode mode,
  }) {
    final km = baselineRoadMeters / 1000.0;
    double distMeters;
    double speedKmh;

    switch (mode) {
      case TravelMode.driving:
        distMeters = baselineRoadMeters;
        if (km < 8.0) {
          speedKmh = 28.0; // Urban city traffic / signals
        } else if (km < 40.0) {
          speedKmh = 45.0; // Suburban / regional roads
        } else {
          speedKmh = 62.0; // National highway / intercity
        }
        break;

      case TravelMode.walking:
        if (km < 5.0) {
          // Pedestrians can take shortcuts, alleys, footpaths
          distMeters = max(straightMeters * 1.12, baselineRoadMeters * 0.92);
        } else if (km < 25.0) {
          distMeters = baselineRoadMeters * 0.95;
        } else {
          // Intercity walking along local secondary roads
          distMeters = baselineRoadMeters * 1.03;
        }
        speedKmh = 4.8; // Average human walking speed (4.8 km/h)
        break;

      case TravelMode.cycling:
        if (km < 10.0) {
          distMeters = max(straightMeters * 1.15, baselineRoadMeters * 0.94);
          speedKmh = 14.5; // City cycling pace
        } else {
          distMeters = baselineRoadMeters * 0.98;
          speedKmh = 17.5; // Open road touring cycling
        }
        break;
    }

    final durationSec = (distMeters / 1000.0) / speedKmh * 3600.0;
    return ModeMetrics(
      distanceMeters: distMeters,
      durationSeconds: durationSec,
    );
  }

  /// Recalculates metrics and steps instantly for an existing route when the user taps Drive, Walk, or Cycle
  RouteResult recalculateForMode(RouteResult baseRoute, TravelMode newMode) {
    final straightDist = calculateDistanceMeters(
      baseRoute.origin.coordinates,
      baseRoute.destination.coordinates,
    );
    final baselineRoadMeters = baseRoute.baseRoadDistanceMeters > 0
        ? baseRoute.baseRoadDistanceMeters
        : baseRoute.distanceMeters;

    final metrics = computeModeMetrics(
      baselineRoadMeters: baselineRoadMeters,
      straightMeters: straightDist,
      mode: newMode,
    );

    final updatedSteps = _formatStepsForMode(baseRoute.steps, newMode);

    return RouteResult(
      origin: baseRoute.origin,
      destination: baseRoute.destination,
      distanceMeters: metrics.distanceMeters,
      durationSeconds: metrics.durationSeconds,
      polylinePoints: baseRoute.polylinePoints,
      steps: updatedSteps,
      travelMode: newMode,
      aiGuideNotes: _generateLocalAiAdvice(
        origin: baseRoute.origin,
        destination: baseRoute.destination,
        distanceKm: metrics.distanceMeters / 1000.0,
        durationMinutes: (metrics.durationSeconds / 60.0).round(),
        mode: newMode,
      ),
      baseRoadDistanceMeters: baselineRoadMeters,
    );
  }

  /// Fetch route from OSRM or fallback with polyline and mode-accurate calculation
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
    double baseRoadDistance = straightDistance * 1.25;

    // 1. Fetch road geometry from OSRM
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
          baseRoadDistance = (route['distance'] as num).toDouble();

          final coords = route['geometry']['coordinates'] as List;
          polylinePoints = coords.map((c) => LatLng(c[1] as double, c[0] as double)).toList();

          if (route['legs'] != null && (route['legs'] as List).isNotEmpty) {
            final rawSteps = route['legs'][0]['steps'] as List;
            steps = rawSteps.map((s) {
              final maneuver = s['maneuver']?['type'] ?? 'continue';
              final modifier = s['maneuver']?['modifier'] ?? '';
              final name = s['name']?.toString().isNotEmpty == true ? s['name'] : 'road';
              final instruction = _formatStepInstruction(maneuver, modifier, name, mode);
              final stepDist = (s['distance'] as num?)?.toDouble() ?? 0.0;
              final loc = s['maneuver']?['location'] as List?;
              final stepCoord = (loc != null && loc.length >= 2)
                  ? LatLng((loc[1] as num).toDouble(), (loc[0] as num).toDouble())
                  : null;
              return RouteStep(
                instruction: instruction,
                distanceMeters: stepDist,
                durationSeconds: _estimateDurationSeconds(stepDist, mode),
                coordinate: stepCoord,
              );
            }).toList();
          }
        }
      }
    } catch (_) {
      // Fall back to intermediate points
    }

    // 2. Fallback interpolation if network returned no points
    if (polylinePoints.isEmpty) {
      polylinePoints = _generateIntermediatePoints(
        origin.coordinates,
        destination.coordinates,
      );
      final action = mode == TravelMode.walking
          ? 'Walk'
          : (mode == TravelMode.cycling ? 'Cycle' : 'Drive');
      steps = [
        RouteStep(
          instruction: 'Start journey from ${origin.name}',
          distanceMeters: baseRoadDistance * 0.1,
          durationSeconds: _estimateDurationSeconds(baseRoadDistance * 0.1, mode),
          coordinate: origin.coordinates,
        ),
        RouteStep(
          instruction: '$action along main transit corridor toward ${destination.name}',
          distanceMeters: baseRoadDistance * 0.8,
          durationSeconds: _estimateDurationSeconds(baseRoadDistance * 0.8, mode),
          coordinate: polylinePoints.length > 2 ? polylinePoints[polylinePoints.length ~/ 2] : null,
        ),
        RouteStep(
          instruction: 'Arrive at destination: ${destination.name}',
          distanceMeters: baseRoadDistance * 0.1,
          durationSeconds: _estimateDurationSeconds(baseRoadDistance * 0.1, mode),
          coordinate: destination.coordinates,
        ),
      ];
    }

    // 3. Compute mathematically sound metrics for the requested mode
    final metrics = computeModeMetrics(
      baselineRoadMeters: baseRoadDistance,
      straightMeters: straightDistance,
      mode: mode,
    );

    final distanceKm = metrics.distanceMeters / 1000.0;
    final durationMinutes = (metrics.durationSeconds / 60.0).round();

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
      distanceMeters: metrics.distanceMeters,
      durationSeconds: metrics.durationSeconds,
      polylinePoints: polylinePoints,
      steps: steps,
      travelMode: mode,
      aiGuideNotes: aiAdvice,
      baseRoadDistanceMeters: baseRoadDistance,
    );
  }

  double _estimateDurationSeconds(double meters, TravelMode mode) {
    double speedKmh;
    switch (mode) {
      case TravelMode.driving:
        speedKmh = 45.0;
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

  String _formatStepInstruction(String maneuver, String modifier, String name, TravelMode mode) {
    String action;
    switch (mode) {
      case TravelMode.driving:
        action = 'Drive';
        break;
      case TravelMode.walking:
        action = 'Walk';
        break;
      case TravelMode.cycling:
        action = 'Cycle';
        break;
    }

    if (maneuver == 'depart') return '$action toward $name';
    if (maneuver == 'arrive') return 'Arrive at $name';
    if (modifier.isNotEmpty) {
      return '$maneuver $modifier onto $name';
    }
    return '$action along $name';
  }

  List<RouteStep> _formatStepsForMode(List<RouteStep> steps, TravelMode mode) {
    String actionWord;
    switch (mode) {
      case TravelMode.driving:
        actionWord = 'Drive';
        break;
      case TravelMode.walking:
        actionWord = 'Walk';
        break;
      case TravelMode.cycling:
        actionWord = 'Cycle';
        break;
    }

    return steps.map((s) {
      var inst = s.instruction;
      inst = inst.replaceAll(RegExp(r'\b(Drive|Walk|Cycle|Ride)\b', caseSensitive: false), actionWord);
      return RouteStep(
        instruction: inst,
        distanceMeters: s.distanceMeters,
        durationSeconds: _estimateDurationSeconds(s.distanceMeters, mode),
      );
    }).toList();
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

  String _formatDurationString(int durationMinutes) {
    if (durationMinutes < 60) {
      return '$durationMinutes mins';
    }
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    if (hours >= 24) {
      final days = hours ~/ 24;
      final remH = hours % 24;
      return '${days}d ${remH}h ($hours hrs)';
    }
    return '${hours}h ${mins}m';
  }

  String _generateLocalAiAdvice({
    required PlaceLocation origin,
    required PlaceLocation destination,
    required double distanceKm,
    required int durationMinutes,
    required TravelMode mode,
  }) {
    final modeTips = {
      TravelMode.driving: 'Expected moderate traffic. Consider parking availability near ${destination.name}. Drive with care on national roads.',
      TravelMode.walking: 'Pedestrian route. Wear comfortable shoes, stay hydrated under the sun, and use designated sidewalks or road shoulders.',
      TravelMode.cycling: 'Scenic cycling route. Check tire pressure, wear a helmet, and keep an eye on traffic along major intersections.',
    };

    final timeFormatted = _formatDurationString(durationMinutes);

    return '''📍 **AI Route Briefing**:
• **From**: ${origin.name}
• **To**: ${destination.name}
• **Distance (${mode.label})**: ${distanceKm.toStringAsFixed(1)} km (${(distanceKm * 0.621371).toStringAsFixed(1)} miles)
• **Estimated Time**: ~$timeFormatted by ${mode.label}

💡 **AI Guide Insights for ${mode.label}**:
• ${modeTips[mode] ?? 'Safe travels!'}
• Check weather conditions before departure.
• Best time to travel is morning or late afternoon to avoid midday tropical heat.''';
  }

  Future<String> _generateAiAdvice({
    required PlaceLocation origin,
    required PlaceLocation destination,
    required double distanceKm,
    required int durationMinutes,
    required TravelMode mode,
    String? userPrompt,
  }) async {
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
          final timeFormatted = _formatDurationString(durationMinutes);
          return '''📍 **AI Route Briefing**:
${data['advice']}

• **Direct Distance**: ${distanceKm.toStringAsFixed(1)} km (${(distanceKm * 0.621371).toStringAsFixed(1)} miles)
• **Estimated Time**: ~$timeFormatted by ${mode.label}

💡 **AI Guide Highlights & Tips**:
• $tips

🛑 **Recommended Stops Along Route**:
• $stops''';
        }
      }
    } catch (_) {
      // Local AI offline, fallback to built-in smart AI advice
    }

    return _generateLocalAiAdvice(
      origin: origin,
      destination: destination,
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
      mode: mode,
    );
  }
}
