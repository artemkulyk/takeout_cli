import 'location.dart';
import 'dart:convert';
import 'dart:io';

/// Class for reading and iterating through `Location` objects from a JSON file.
///
/// This class is designed to read location data from a JSON file, specifically
/// handling large files where the entire JSON might not fit into memory. It
/// parses the file chunk-by-chunk, streaming each `Location` object one at a
/// time as it is read from the file.
class LocationReader {
  /// Path to the JSON file containing location data.
  final String filePath;

  /// Constructs a [LocationReader] with the provided file path.
  LocationReader(this.filePath);

  /// Reads and returns a stream of `Location` objects from the JSON file.
  ///
  /// This method parses the file in chunks, identifying JSON objects within the
  /// "locations" array. It maintains a buffer of characters and processes each
  /// JSON object individually to avoid memory overload.
  ///
  /// Throws:
  /// - [Exception] if the file is not found.
  Stream<Location> readLocations() async* {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File not found: $filePath');
    }

    final inputStream = file.openRead();

    // Stream transformation to decode bytes to UTF-8 characters.
    final utf8Stream = inputStream.transform(utf8.decoder);

    // Buffer for accumulating data from the stream.
    String buffer = '';

    // Parsing states to manage JSON object extraction.
    bool inLocationsArray = false;
    bool insideObject = false;
    bool insideString = false;
    bool escapeNext = false;
    int braceLevel = 0;
    String currentObject = '';

    // Regular expression to locate the start of the "locations" array.
    final locationsStartPattern = '"locations"\\s*:\\s*\\[';
    final locationsStartRegex = RegExp(locationsStartPattern);

    await for (final chunk in utf8Stream) {
      buffer += chunk;

      int index = 0;

      while (index < buffer.length) {
        if (!inLocationsArray) {
          // Look for the start of the "locations" array.
          final match = locationsStartRegex.firstMatch(buffer.substring(index));
          if (match != null) {
            inLocationsArray = true;
            index += match.end;
            continue;
          } else {
            // Retain the last 100 characters if "locations" array is not found.
            if (buffer.length - index > 100) {
              buffer = buffer.substring(buffer.length - 100);
              index = 0;
            }
            break;
          }
        }

        if (inLocationsArray) {
          if (!insideObject) {
            // Look for the start of a JSON object.
            int objStart = buffer.indexOf('{', index);
            if (objStart == -1) {
              // Retain the last 100 characters if no '{' is found.
              if (buffer.length - index > 100) {
                buffer = buffer.substring(buffer.length - 100);
              }
              break;
            }
            index = objStart;
            insideObject = true;
            braceLevel = 0;
            currentObject = '';
          }

          // Process characters to accumulate a complete JSON object.
          for (; index < buffer.length; index++) {
            final char = buffer[index];

            if (insideString) {
              if (escapeNext) {
                escapeNext = false;
              } else if (char == '\\') {
                escapeNext = true;
              } else if (char == '"') {
                insideString = false;
              }
              currentObject += char;
              continue;
            } else if (char == '"') {
              insideString = true;
            }

            if (char == '{') {
              braceLevel++;
            } else if (char == '}') {
              braceLevel--;
            }

            currentObject += char;

            // If a complete JSON object is detected, decode and yield it.
            if (braceLevel == 0 && insideObject && char == '}') {
              try {
                final Map<String, dynamic> decoded = json.decode(currentObject);
                yield Location.fromJson(decoded);
              } catch (e) {
                print('JSON object decoding error: $e');
                print('Object:\n$currentObject');
                // Optional: choose to skip the object or halt parsing here.
              }

              insideObject = false;
              currentObject = '';

              // Move index past the closing brace.
              index++;

              // Skip commas and whitespace.
              while (index < buffer.length &&
                  (buffer[index] == ',' || buffer[index].trim().isEmpty)) {
                index++;
              }

              // Check if the "locations" array has ended.
              if (index < buffer.length && buffer[index] == ']') {
                // End of the "locations" array.
                return;
              }

              break; // Proceed to next object.
            }
          }

          // Trim processed buffer content.
          if (index >= buffer.length) {
            buffer = '';
            break;
          } else {
            buffer = buffer.substring(index);
            index = 0;
          }
        }
      }
    }
  }
}
