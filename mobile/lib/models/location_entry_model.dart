class LocationEntry {
  final int? id;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? accuracy;
  final double? altitude;

  LocationEntry({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracy,
    this.altitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'accuracy': accuracy,
      'altitude': altitude,
    };
  }

  /// Serialization for the backend API (`/api/v1/locationEntries/`),
  /// which expects `locationTimestamp` instead of `timestamp`.
  Map<String, dynamic> toApiMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'locationTimestamp': timestamp.toIso8601String(),
      'accuracy': accuracy,
      'altitude': altitude,
    };
  }

  factory LocationEntry.fromMap(Map<String, dynamic> map) {
    return LocationEntry(
      id: map['id'] as int?,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp'] as String),
      accuracy: map['accuracy'] != null ? (map['accuracy'] as num).toDouble() : null,
      altitude: map['altitude'] != null ? (map['altitude'] as num).toDouble() : null,
    );
  }
}

