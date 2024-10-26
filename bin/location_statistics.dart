import 'location.dart'; // Location model is declared here

/// Manages statistical data aggregation for location points over days,
/// calculating distances and times based on activity types.
class LocationStatistics {
  final Map<String, int> dailyPointCounts = {};
  final Map<String, double> dailyDistances = {};
  final Map<String, double> dailyFootDistance = {};
  final Map<String, double> dailyBicycleDistance = {};
  final Map<String, double> dailyVehicleDistance = {};
  final Map<String, double> dailyVehicleMaxSpeed = {};
  final Map<String, double> dailyVehicleAvgSpeed = {};
  final Map<String, int> dailyActiveTime = {};
  final Map<String, int> dailyVehicleTime = {};

  /// Updates statistics for a given date based on location, distance traveled,
  /// and active time. It categorizes distance based on activity type with
  /// confidence levels greater than 50%.
  ///
  /// Parameters:
  /// - [date]: The date of the activity in string format.
  /// - [location]: A [Location] object representing the current location point.
  /// - [distance]: The distance traveled in meters.
  /// - [activeTime]: The duration in minutes spent in the activity.
  ///
  /// Activity types with high confidence are categorized as follows:
  /// - `ON_FOOT`, `WALKING`, `RUNNING` -> Foot Distance.
  /// - `ON_BICYCLE` -> Bicycle Distance.
  /// - `IN_VEHICLE`, `IN_CAR`, `IN_BUS` -> Vehicle Distance.
  ///
  /// The vehicle activities also track maximum and average speeds.
  void update(String date, Location location, double distance, int activeTime) {
    dailyPointCounts[date] = (dailyPointCounts[date] ?? 0) + 1;
    dailyDistances[date] = (dailyDistances[date] ?? 0) + distance;

    loop:
    for (final activity in location.activities ?? <Activity>[]) {
      for (final act in activity.activity) {
        if (act.confidence > 50) {
          switch (act.type) {
            case 'ON_FOOT':
            case 'WALKING':
            case 'RUNNING':
              dailyFootDistance[date] =
                  (dailyFootDistance[date] ?? 0) + distance;
              dailyActiveTime[date] = (dailyActiveTime[date] ?? 0) + activeTime;
              break loop;
            case 'ON_BICYCLE':
              dailyBicycleDistance[date] =
                  (dailyBicycleDistance[date] ?? 0) + distance;
              dailyActiveTime[date] = (dailyActiveTime[date] ?? 0) + activeTime;
              break loop;
            case 'IN_VEHICLE':
            case 'IN_CAR':
            case 'IN_BUS':
              dailyVehicleDistance[date] =
                  (dailyVehicleDistance[date] ?? 0) + distance;
              dailyVehicleTime[date] =
                  (dailyVehicleTime[date] ?? 0) + activeTime;
              final currentVelocity = location.velocity?.toDouble() ?? 0;
              dailyVehicleMaxSpeed[date] =
                  (dailyVehicleMaxSpeed[date] ?? 0).clamp(0, currentVelocity);
              final avgSpeed = ((dailyVehicleAvgSpeed[date] ?? 0) *
                          (dailyVehicleTime[date]! - 1) +
                      currentVelocity) /
                  dailyVehicleTime[date]!;
              dailyVehicleAvgSpeed[date] = avgSpeed;
              break loop;
          }
        }
      }
    }
  }

  /// Clears all accumulated statistics, resetting all daily metrics.
  void clear() {
    dailyPointCounts.clear();
    dailyDistances.clear();
    dailyFootDistance.clear();
    dailyBicycleDistance.clear();
    dailyVehicleDistance.clear();
    dailyVehicleMaxSpeed.clear();
    dailyVehicleAvgSpeed.clear();
    dailyActiveTime.clear();
    dailyVehicleTime.clear();
  }
}
