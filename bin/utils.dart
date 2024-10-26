import 'dart:math';

/// Calculates the distance between two geographical coordinates in meters,
/// and performs a speed check to filter out unrealistic movement.
///
/// This function uses the Haversine formula to compute the shortest distance
/// over the earth’s surface between two latitude/longitude points. It also
/// calculates the speed based on the time difference between the two points
/// and filters out values where the speed exceeds 1200 km/h (interpreted as
/// potentially erroneous data).
///
/// Returns `null` if the calculated speed is above 1200 km/h, otherwise
/// returns the distance in meters.
///
/// Parameters:
/// - [lon1]: Longitude of the first point in decimal degrees.
/// - [lat1]: Latitude of the first point in decimal degrees.
/// - [lon2]: Longitude of the second point in decimal degrees.
/// - [lat2]: Latitude of the second point in decimal degrees.
/// - [time1]: Timestamp of the first point.
/// - [time2]: Timestamp of the second point.
///
/// Returns:
/// - `double?`: The distance in meters between the two points, or `null` if
///   the speed check fails.
double? calculateDistance(
  double lon1,
  double lat1,
  double lon2,
  double lat2,
  DateTime time1,
  DateTime time2,
) {
  const double R = 6371e3; // Radius of the Earth in meters
  final double phi1 = lat1 * pi / 180; // Latitude of the first point in radians
  final double phi2 =
      lat2 * pi / 180; // Latitude of the second point in radians
  final double deltaPhi =
      (lat2 - lat1) * pi / 180; // Latitude difference in radians
  final double deltaLambda =
      (lon2 - lon1) * pi / 180; // Longitude difference in radians

  // Haversine formula to calculate the distance
  final double a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
      cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  final double distance = R * c; // Distance in meters

  // Calculate time difference in seconds and filter based on speed
  final int timeDiff = time2.difference(time1).inSeconds;
  if (timeDiff > 0) {
    final double speed = (distance / timeDiff) * 3.6; // Speed in km/h
    if (speed > 1200) return null; // Filter out speeds over 1200 km/h
  }
  return distance;
}
