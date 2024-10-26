import 'dart:io';
import 'location_reader.dart';
import 'location_statistics.dart';
import 'excel_writer.dart';
import 'utils.dart';
import 'location.dart';

/// Main function that processes location data from a JSON file, calculates
/// daily statistics for various activities, and writes them to an Excel file.
///
/// This application reads location records, calculates distances and activity
/// times for each day, and then saves this information yearly into an Excel file.
/// It uses the `LocationReader` for reading the JSON file, `LocationStatistics`
/// to store daily statistics, and `ExcelWriter` to output the data to Excel format.
void main(List<String> args) async {
  // Parse command-line arguments
  final inputFile = getArgumentValue(args, '-i') ?? 'Records.json';
  final outputFolder = getArgumentValue(args, '-o') ?? '.';

  if (!File(inputFile).existsSync()) {
    print('Error: Input file "$inputFile" does not exist.');
    return;
  }

  // Check if output folder exists, create it if not
  if (!Directory(outputFolder).existsSync()) {
    print(
        'Output folder "$outputFolder" does not exist. Creating the directory.');
    Directory(outputFolder).createSync(recursive: true);
  }

  final reader = LocationReader(inputFile); // JSON location data reader
  final statistics = LocationStatistics(); // Stores daily statistics
  final writer = ExcelWriter(); // Writes data to Excel
  print("Start processing");

  int? currentYear;
  late DateTime lastTimestamp;
  List<double>?
      lastCoordinates; // Stores last known coordinates for distance calculation
  final Stopwatch stopwatch = Stopwatch()..start(); // Tracks execution time

  await for (final Location location in reader.readLocations()) {
    final int year = location.timestamp.year;
    final String date =
        '${location.timestamp.year}-${location.timestamp.month.toString().padLeft(2, '0')}-${location.timestamp.day.toString().padLeft(2, '0')}';

    // Checks for year change to separate data into yearly Excel sheets
    if (currentYear == null || year != currentYear) {
      if (currentYear != null) {
        // Writes yearly statistics to Excel when year changes
        await writer.writeExcel(
          currentYear,
          statistics.dailyPointCounts,
          statistics.dailyDistances,
          statistics.dailyFootDistance,
          statistics.dailyBicycleDistance,
          statistics.dailyVehicleDistance,
          statistics.dailyVehicleMaxSpeed,
          statistics.dailyVehicleAvgSpeed,
          statistics.dailyActiveTime,
          statistics.dailyVehicleTime,
          outputFolder, // Output directory for the Excel file
        );
        statistics.clear(); // Resets statistics for the new year
      }
      currentYear = year;
    }

    // Calculate distance if there are previous coordinates and a timestamp
    if (lastCoordinates != null) {
      final double? distance = calculateDistance(
          lastCoordinates[0],
          lastCoordinates[1],
          location.longitudeE7 / 1e7,
          location.latitudeE7 / 1e7,
          lastTimestamp,
          location.timestamp);

      if (distance != null) {
        final int timeDifference =
            location.timestamp.difference(lastTimestamp).inMinutes;
        statistics.update(date, location, distance, timeDifference);
      }
    }

    // Update the last known coordinates and timestamp for next iteration
    lastTimestamp = location.timestamp;
    lastCoordinates = [location.longitudeE7 / 1e7, location.latitudeE7 / 1e7];
  }

  // Final data writing for the last processed year
  if (currentYear != null) {
    await writer.writeExcel(
      currentYear,
      statistics.dailyPointCounts,
      statistics.dailyDistances,
      statistics.dailyFootDistance,
      statistics.dailyBicycleDistance,
      statistics.dailyVehicleDistance,
      statistics.dailyVehicleMaxSpeed,
      statistics.dailyVehicleAvgSpeed,
      statistics.dailyActiveTime,
      statistics.dailyVehicleTime,
      outputFolder, // Output directory for the Excel file
    );
  }

  stopwatch.stop();
  print('Execution time: ${stopwatch.elapsed}'); // Prints execution time
  print("End processing");
}

/// Helper function to retrieve command-line argument values.
///
/// Takes a list of arguments and an argument key (e.g., '-i' or '-o').
/// Returns the value following the key if found, or `null` if not found.
String? getArgumentValue(List<String> args, String key) {
  final index = args.indexOf(key);
  if (index != -1 && index + 1 < args.length) {
    return args[index + 1];
  }
  return null;
}
