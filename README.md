# Google Takeout Location Data Processor

<img width="1371" alt="image" src="https://github.com/user-attachments/assets/116b46a5-dbe2-4e4e-8ccb-1bdef8af3607">

This project processes location data extracted via Google Takeout. It reads location records from a JSON file, calculates daily statistics based on movement data (walking, cycling, vehicle travel, etc.), and generates yearly summaries in Excel format.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Command-Line Arguments](#command-line-arguments)
- [Output](#output)
- [Data Privacy](#data-privacy)

## Overview

Google Takeout provides a JSON file containing detailed location and activity records. This project reads and parses the JSON data, calculates various daily metrics (such as distance traveled by foot or vehicle), and organizes these metrics into an Excel report per year.

## Features

- **JSON Parsing**: Reads Google Takeout JSON location data with nested activity details.
- **Daily Metrics Calculation**: Calculates daily travel distances, active time, and average speed for different activities (e.g., on foot, by bicycle, in a vehicle).
- **Excel Output**: Generates yearly Excel sheets summarizing calculated metrics for each day, with support for custom output directories.
- **CLI Support**: Easily specify input files and output directories via command-line arguments.

## Installation

Ensure you have Dart SDK installed on your system.

1. Clone this repository:
   ```bash
   git clone https://github.com/artemkulyk/takeout_cli
   cd google-takeout-processor
   ```

2. Install dependencies:
   ```bash
   dart pub get
   ```

## Usage

Run the program by specifying the input file and optional output directory:

```bash
dart run bin/takeout_cli.dart -i path/to/Records.json -o path/to/output/folder
```

### Command-Line Arguments

- `-i` : Specifies the path to the Google Takeout JSON file. If not provided, defaults to `Records.json` in the current directory.
- `-o` : Specifies the output directory where Excel files will be saved. If not provided, defaults to the current directory. The directory will be created if it does not exist.

### Example

```bash
dart run bin/takeout_cli.dart -i ./data/Records.json -o ./out
```

### Output

The program outputs yearly Excel files in the specified directory, named `Statistics_<year>.xlsx`, containing columns for:

- Date
- Point Count
- Total Distance (m)
- Active Time (min)
- Foot Distance (m)
- Bicycle Distance (m)
- Vehicle Distance (m)
- Vehicle Max Speed (m/s)
- Vehicle Avg Speed (m/s)
- Vehicle Time (min)

Each row represents daily statistics for that date.

## Data Privacy

This project works entirely offline and does not share or upload any data. The processed data remains on your local machine. **Ensure that you manage your data responsibly** as Google Takeout location files contain sensitive location and activity information.
