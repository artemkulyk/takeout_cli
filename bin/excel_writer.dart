import 'package:excel/excel.dart';
import 'dart:io';

/// A utility class for writing statistical data to an Excel file.
///
/// This class allows creating an Excel file with location statistics
/// organized by year. Each year's data is written to a separate sheet
/// within the Excel workbook.
class ExcelWriter {
  /// Writes the provided statistical data to an Excel file for the given year.
  ///
  /// [year] represents the year for which data is being written.
  /// [outputFolder] specifies the folder where the Excel file will be saved.
  /// Other parameters are maps containing various types of daily statistics.
  Future<void> writeExcel(
    int year,
    Map<String, int> dailyPointCounts,
    Map<String, double> dailyDistances,
    Map<String, double> dailyFootDistance,
    Map<String, double> dailyBicycleDistance,
    Map<String, double> dailyVehicleDistance,
    Map<String, double> dailyVehicleMaxSpeed,
    Map<String, double> dailyVehicleAvgSpeed,
    Map<String, int> dailyActiveTime,
    Map<String, int> dailyVehicleTime,
    String outputFolder, // Directory to save the file
  ) async {
    // Check if the output folder exists, and create it if it doesn't
    final directory = Directory(outputFolder);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
      print('Output folder created: $outputFolder');
    }

    var excel = Excel.createExcel();
    Sheet sheet = excel['Statistics_$year'];

    // Column headers
    List<CellValue?> headers = [
      TextCellValue("Date"),
      TextCellValue("Point Count"),
      TextCellValue("Total Distance (m)"),
      TextCellValue("Active Time (min)"),
      TextCellValue("Foot Distance (m)"),
      TextCellValue("Bicycle Distance (m)"),
      TextCellValue("Vehicle Distance (m)"),
      TextCellValue("Vehicle Max Speed (m/s)"),
      TextCellValue("Vehicle Avg Speed (m/s)"),
      TextCellValue("Vehicle Time (min)")
    ];
    sheet.appendRow(headers);

    // Fill rows with data
    dailyPointCounts.forEach((date, count) {
      List<CellValue?> row = [
        TextCellValue(date),
        IntCellValue(count),
        DoubleCellValue(dailyDistances[date] ?? 0),
        IntCellValue(dailyActiveTime[date] ?? 0),
        DoubleCellValue(dailyFootDistance[date] ?? 0),
        DoubleCellValue(dailyBicycleDistance[date] ?? 0),
        DoubleCellValue(dailyVehicleDistance[date] ?? 0),
        DoubleCellValue(dailyVehicleMaxSpeed[date] ?? 0),
        DoubleCellValue(dailyVehicleAvgSpeed[date] ?? 0),
        IntCellValue(dailyVehicleTime[date] ?? 0),
      ];
      sheet.appendRow(row);
    });

    // Save the Excel file in the specified output folder
    var fileBytes = excel.save(fileName: 'Statistics_$year.xlsx');
    final outputFilePath = '$outputFolder/Statistics_$year.xlsx';
    File(outputFilePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);
    print('Excel file created at: $outputFilePath');
  }
}
