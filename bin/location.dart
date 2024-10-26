/// Data model representing an activity type and its confidence level.
class ActivityType {
  final String type;
  final int confidence;

  /// Constructs an [ActivityType] with the given [type] and [confidence].
  ActivityType({required this.type, required this.confidence});

  /// Factory constructor to create an [ActivityType] instance from JSON.
  ///
  /// Parameters:
  /// - [json]: A map representing the JSON data to parse.
  factory ActivityType.fromJson(Map<String, dynamic> json) {
    return ActivityType(
      type: json['type'],
      confidence: json['confidence'],
    );
  }

  @override
  String toString() {
    return 'ActivityType(type: $type, confidence: $confidence)';
  }
}

/// Data model representing an activity that includes a timestamp.
class Activity {
  final List<ActivityType> activity;
  final DateTime timestamp;

  /// Constructs an [Activity] with a list of [activity] types and a [timestamp].
  Activity({required this.activity, required this.timestamp});

  /// Factory constructor to create an [Activity] instance from JSON.
  ///
  /// Parameters:
  /// - [json]: A map representing the JSON data to parse.
  factory Activity.fromJson(Map<String, dynamic> json) {
    var activities = (json['activity'] as List)
        .map((item) => ActivityType.fromJson(item))
        .toList();
    return Activity(
      activity: activities,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  @override
  String toString() {
    return 'Activity(timestamp: ${timestamp.toIso8601String()}, activity: $activity)';
  }
}

/// Data model representing a Wi-Fi access point.
class AccessPoint {
  final String mac;
  final int strength;
  final int frequencyMhz;

  /// Constructs an [AccessPoint] with the given [mac] address, [strength], and [frequencyMhz].
  AccessPoint({
    required this.mac,
    required this.strength,
    required this.frequencyMhz,
  });

  /// Factory constructor to create an [AccessPoint] instance from JSON.
  ///
  /// Parameters:
  /// - [json]: A map representing the JSON data to parse.
  factory AccessPoint.fromJson(Map<String, dynamic> json) {
    return AccessPoint(
      mac: json['mac'],
      strength: json['strength'],
      frequencyMhz: json['frequencyMhz'],
    );
  }

  @override
  String toString() {
    return 'AccessPoint(mac: $mac, strength: $strength, frequencyMhz: $frequencyMhz)';
  }
}

/// Data model representing a Wi-Fi scan with multiple access points.
class WifiScan {
  final List<AccessPoint> accessPoints;

  /// Constructs a [WifiScan] with a list of [accessPoints].
  WifiScan({required this.accessPoints});

  /// Factory constructor to create a [WifiScan] instance from JSON.
  ///
  /// Parameters:
  /// - [json]: A map representing the JSON data to parse.
  factory WifiScan.fromJson(Map<String, dynamic> json) {
    var aps = (json['accessPoints'] as List)
        .map((item) => AccessPoint.fromJson(item))
        .toList();
    return WifiScan(accessPoints: aps);
  }

  @override
  String toString() {
    return 'WifiScan(accessPoints: $accessPoints)';
  }
}

/// Data model representing metadata for a location, including a Wi-Fi scan.
class LocationMetadata {
  final WifiScan? wifiScan;
  final DateTime timestamp;

  /// Constructs [LocationMetadata] with an optional [wifiScan] and a [timestamp].
  LocationMetadata({this.wifiScan, required this.timestamp});

  /// Factory constructor to create a [LocationMetadata] instance from JSON.
  ///
  /// Parameters:
  /// - [json]: A map representing the JSON data to parse.
  factory LocationMetadata.fromJson(Map<String, dynamic> json) {
    WifiScan? wifiScan;
    if (json.containsKey('wifiScan')) {
      wifiScan = WifiScan.fromJson(json['wifiScan']);
    }
    return LocationMetadata(
      wifiScan: wifiScan,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  @override
  String toString() {
    return 'LocationMetadata(timestamp: ${timestamp.toIso8601String()}, wifiScan: $wifiScan)';
  }
}

/// Data model representing inferred location data, including coordinates and accuracy.
class InferredLocation {
  final DateTime timestamp;
  final int latitudeE7;
  final int longitudeE7;
  final int accuracy;

  /// Constructs an [InferredLocation] with [timestamp], [latitudeE7], [longitudeE7], and [accuracy].
  InferredLocation({
    required this.timestamp,
    required this.latitudeE7,
    required this.longitudeE7,
    required this.accuracy,
  });

  /// Factory constructor to create an [InferredLocation] instance from JSON.
  ///
  /// Parameters:
  /// - [json]: A map representing the JSON data to parse.
  factory InferredLocation.fromJson(Map<String, dynamic> json) {
    return InferredLocation(
      timestamp: DateTime.parse(json['timestamp']),
      latitudeE7: json['latitudeE7'],
      longitudeE7: json['longitudeE7'],
      accuracy: json['accuracy'],
    );
  }

  @override
  String toString() {
    return 'InferredLocation(timestamp: ${timestamp.toIso8601String()}, latitudeE7: $latitudeE7, longitudeE7: $longitudeE7, accuracy: $accuracy)';
  }
}

/// Data model representing a location, with various optional metadata.
class Location {
  final int latitudeE7;
  final int longitudeE7;
  final int accuracy;
  final List<Activity>? activities;
  final String source;
  final int deviceTag;
  final DateTime timestamp;
  final int? velocity;
  final int? altitude;
  final int? verticalAccuracy;
  final String? platformType;
  final List<LocationMetadata>? locationMetadata;
  final List<InferredLocation>? inferredLocation;
  final int? osLevel;
  final DateTime? serverTimestamp;
  final DateTime? deviceTimestamp;
  final bool? batteryCharging;
  final String? formFactor;

  /// Constructs a [Location] instance with required latitude, longitude, accuracy, source, device tag,
  /// and timestamp. Includes optional parameters for additional metadata such as velocity, altitude,
  /// platform type, and battery status.
  Location({
    required this.latitudeE7,
    required this.longitudeE7,
    required this.accuracy,
    this.activities,
    required this.source,
    required this.deviceTag,
    required this.timestamp,
    this.velocity,
    this.altitude,
    this.verticalAccuracy,
    this.platformType,
    this.locationMetadata,
    this.inferredLocation,
    this.osLevel,
    this.serverTimestamp,
    this.deviceTimestamp,
    this.batteryCharging,
    this.formFactor,
  });

  /// Factory constructor to create a [Location] instance from JSON.
  ///
  /// Parses various optional lists such as activities, metadata, and inferred locations.
  ///
  /// Parameters:
  /// - [json]: A map representing the JSON data to parse.
  factory Location.fromJson(Map<String, dynamic> json) {
    List<Activity>? activities;
    if (json.containsKey('activity')) {
      activities = (json['activity'] as List)
          .map((item) => Activity.fromJson(item))
          .toList();
    }

    List<LocationMetadata>? metadata;
    if (json.containsKey('locationMetadata')) {
      metadata = (json['locationMetadata'] as List)
          .map((item) => LocationMetadata.fromJson(item))
          .toList();
    }

    List<InferredLocation>? inferred;
    if (json.containsKey('inferredLocation')) {
      inferred = (json['inferredLocation'] as List)
          .map((item) => InferredLocation.fromJson(item))
          .toList();
    }

    return Location(
      latitudeE7: json['latitudeE7'],
      longitudeE7: json['longitudeE7'],
      accuracy: json['accuracy'],
      activities: activities,
      source: json['source'],
      deviceTag: json['deviceTag'],
      timestamp: DateTime.parse(json['timestamp']),
      velocity: json['velocity'],
      altitude: json['altitude'],
      verticalAccuracy: json['verticalAccuracy'],
      platformType: json['platformType'],
      locationMetadata: metadata,
      inferredLocation: inferred,
      osLevel: json['osLevel'],
      serverTimestamp: json.containsKey('serverTimestamp')
          ? DateTime.parse(json['serverTimestamp'])
          : null,
      deviceTimestamp: json.containsKey('deviceTimestamp')
          ? DateTime.parse(json['deviceTimestamp'])
          : null,
      batteryCharging:
          json.containsKey('batteryCharging') ? json['batteryCharging'] : null,
      formFactor: json['formFactor'],
    );
  }

  @override
  String toString() {
    return 'Location(latitudeE7: $latitudeE7, longitudeE7: $longitudeE7, accuracy: $accuracy, '
        'activities: $activities, source: $source, deviceTag: $deviceTag, '
        'timestamp: ${timestamp.toIso8601String()}, velocity: $velocity, altitude: $altitude, '
        'verticalAccuracy: $verticalAccuracy, platformType: $platformType, '
        'locationMetadata: $locationMetadata, inferredLocation: $inferredLocation, '
        'osLevel: $osLevel, serverTimestamp: $serverTimestamp, deviceTimestamp: $deviceTimestamp, '
        'batteryCharging: $batteryCharging, formFactor: $formFactor)';
  }
}
