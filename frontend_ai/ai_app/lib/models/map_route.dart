import 'package:latlong2/latlong.dart';

enum TravelMode {
  driving,
  walking,
  cycling;

  String get osrmProfile {
    switch (this) {
      case TravelMode.driving:
        return 'driving';
      case TravelMode.walking:
        return 'foot';
      case TravelMode.cycling:
        return 'bicycle';
    }
  }

  String get label {
    switch (this) {
      case TravelMode.driving:
        return 'Drive';
      case TravelMode.walking:
        return 'Walk';
      case TravelMode.cycling:
        return 'Cycle';
    }
  }
}

class PlaceLocation {
  final String name;
  final String displayName;
  final LatLng coordinates;
  final String? type;

  PlaceLocation({
    required this.name,
    required this.displayName,
    required this.coordinates,
    this.type,
  });

  factory PlaceLocation.fromJson(Map<String, dynamic> json) {
    final lat = double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0;
    final lon = double.tryParse(json['lon']?.toString() ?? '0') ?? 0.0;
    return PlaceLocation(
      name: json['name']?.toString().isNotEmpty == true
          ? json['name'].toString()
          : (json['display_name']?.toString().split(',').first ?? 'Location'),
      displayName: json['display_name']?.toString() ?? 'Selected Location',
      coordinates: LatLng(lat, lon),
      type: json['type']?.toString(),
    );
  }
}

class RouteStep {
  final String instruction;
  final double distanceMeters;
  final double durationSeconds;

  RouteStep({
    required this.instruction,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  String get formattedDistance {
    if (distanceMeters >= 1000) {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    }
    return '${distanceMeters.toStringAsFixed(0)} m';
  }
}

class RouteResult {
  final PlaceLocation origin;
  final PlaceLocation destination;
  final double distanceMeters;
  final double durationSeconds;
  final List<LatLng> polylinePoints;
  final List<RouteStep> steps;
  final TravelMode travelMode;
  final String aiGuideNotes;

  RouteResult({
    required this.origin,
    required this.destination,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.polylinePoints,
    required this.steps,
    required this.travelMode,
    required this.aiGuideNotes,
  });

  double get distanceKm => distanceMeters / 1000;
  double get distanceMiles => distanceMeters * 0.000621371;

  String get formattedDistance {
    if (distanceKm >= 1.0) {
      return '${distanceKm.toStringAsFixed(1)} km (${distanceMiles.toStringAsFixed(1)} mi)';
    }
    return '${distanceMeters.toStringAsFixed(0)} m';
  }

  String get formattedDuration {
    final minutes = (durationSeconds / 60).round();
    if (minutes < 60) {
      return '$minutes mins';
    }
    final hours = minutes ~/ 60;
    final remMins = minutes % 60;
    return '${hours}h ${remMins}m';
  }
}
