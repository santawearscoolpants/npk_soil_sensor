# CSIR Soil Sensor App

Flutter app for farmers to read NPK soil data from an ESP32-WROOM-DA over Bluetooth Low Energy (BLE), store readings locally in sessions, associate them with crop parameters and images, and export CSV/PDF reports for sharing.

## Features

- **Bluetooth Connection**: Dedicated screen for scanning and connecting to ESP32 devices
- **Live Data Monitoring**: Real-time display of sensor readings with automatic saving
- **Session Management**: Group readings into logical sessions for better organization
- **Crop Parameters**: Define and manage crop parameter sets with image uploads
- **History View**: Browse reading sessions with detailed summaries
- **Interactive Charts**: Visualize sensor data trends with interactive line charts, filterable by session
- **Data Export**: Export sensor data as CSV or PDF reports, including chart exports
- **Offline-First**: All data stored locally using SQLite (Drift)

## Project Structure

- **lib/**
  - `main.dart`: App entry point, sets up Riverpod and navigation
  - `src/core/`: Theme, routing, and navigation
  - `src/data/`: 
    - Drift database schema and models
    - Repositories for sensor readings, crop parameters, and images
  - `src/features/`:
    - `bluetooth/`: Bluetooth connection and device scanning screen
    - `live/`: Live sensor data display with automatic session saving
    - `history/`: Session-based history view with detailed summaries
    - `charts/`: Interactive charts for visualizing sensor data trends
    - `crop_params/`: Crop parameter form with image uploads and management
    - `export/`: Export CSV/PDF reports and charts with session filtering
  - `src/services/`:
    - `bluetooth_service.dart`: BLE scanning, connection, and data reception
    - `export_service.dart`: CSV/PDF generation and sharing
    - `session_store.dart`: Session management using SharedPreferences
    - `permission_service.dart`: Runtime permission handling

## BLE Communication Protocol

### ESP32 Firmware Requirements

- **Service UUID**: `0000F001-0000-1000-8000-00805F9B34FB`
- **Characteristic UUID**: `0000F002-0000-1000-8000-00805F9B34FB`
- **Device name prefix**: `FARM-ESP32` (optional, for filtering)
- **Payload format**: UTF-8 JSON string sent as notifications

### JSON Payload Format

```json
{
  "timestamp": 1717434300,
  "moisture": 34.2,
  "ec": 1.8,
  "temperature": 27.4,
  "ph": 6.3,
  "nitrogen": 45,
  "phosphorus": 22,
  "potassium": 60,
  "salinity": 0.9
}
```

**Notes:**
- `timestamp` should be Unix timestamp (seconds since epoch). If timestamp is invalid or too small, the app will use the current time.
- The app subscribes to notifications on the characteristic and parses each JSON payload automatically.
- Readings are saved to the database immediately upon receipt.

## Key Dependencies

- **State Management**: `flutter_riverpod`
- **BLE**: `flutter_blue_plus`
- **Database**: `drift` + `sqlite3_flutter_libs`
- **Charts**: `fl_chart`
- **Images & Storage**: `image_picker`, `path_provider`, `permission_handler`
- **Export**: `csv`, `pdf`, `printing`, `share_plus`

## Setup & Running

### Prerequisites

1. Install Flutter SDK (latest stable version)
2. Set up Android Studio / Xcode for device/emulator
3. For iOS: Physical device required for BLE (simulator doesn't support BLE)

### Installation Steps

1. Clone the repository and navigate to the project directory

2. Install dependencies:
```bash
flutter pub get
```

3. For iOS, install CocoaPods dependencies:
```bash
cd ios
pod install --repo-update
cd ..
```

4. Run the app:
```bash
flutter run
```

### iOS Permissions

The app requires Bluetooth permissions on iOS. Add these to `ios/Runner/Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs Bluetooth to connect to soil sensor devices.</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app needs Bluetooth to connect to soil sensor devices.</string>
```

## App Usage Guide

### Bluetooth Connection

1. Navigate to the **Live Data** tab
2. Tap the Bluetooth icon in the app bar (or the "Manage" button in the status card)
3. Tap **"Scan for devices"** to search for nearby ESP32 devices
4. Select your device from the list to connect
5. Connection status is indicated by:
   - 🟢 **Green dot**: Connected
   - 🟠 **Orange dot**: Scanning/Connecting
   - 🔴 **Red dot**: Disconnected or Bluetooth off

### Live Data Collection

1. After connecting, sensor readings will appear automatically
2. Readings are automatically saved to the database every 5 seconds
3. Select a crop parameter set from the dropdown to link readings (optional)
4. Tap **"Save readings"** to create a session from accumulated readings
5. When disconnecting, you'll be prompted to save or discard any unsaved readings

### Session Management

- **History Tab**: View all reading sessions
  - Each session shows: number of readings, date, and time range
  - Tap a session to view:
    - Detailed summary with average values
    - Linked crop parameters
    - Option to link/unlink crop parameters
    - Option to delete the session

### Crop Parameters

1. Navigate to the **Crop Params** tab
2. Fill in the form with:
   - Soil type and properties
   - Leaf color
   - Stem size (cm)
   - Plant height (cm)
   - Notes (optional)
3. Upload images (automatically relabeled as `tomato_001.jpg`, `tomato_002.jpg`, etc.)
4. Tap **"Save parameters"** to create a new parameter set
5. **Manage saved sets**:
   - Edit: Tap the edit icon to modify an existing set
   - Delete: Tap the delete icon to remove a set
   - Multi-select: Tap the checklist icon to select multiple sets for bulk deletion

### Charts Visualization

1. Navigate to the **Charts** tab
2. **Filter by session**:
   - Tap the filter icon in the app bar
   - Select a session from the dropdown
   - The selected session persists across tab navigation
3. **View sensor charts**:
   - Use tabs to switch between: All, Moisture, EC, Temperature, pH, Nitrogen, Phosphorus, Potassium, Salinity
   - Your selected tab persists when navigating away and returning
   - Interactive charts show trends over time with touch tooltips
   - Charts only display data from saved sessions (no live updates)

### Data Export

1. Navigate to the **Export** tab
2. Select a session from the dropdown
3. Export options:
   - **Sensor Data (CSV)**: Raw sensor readings with sequential IDs (starting from 1)
   - **Sensor + Params (CSV)**: Combined data with crop parameters and image filenames
   - **PDF Report**: Session summaries with:
     - Average values for each parameter
     - Date and time ranges
     - Linked crop parameters
     - Summary sentences for each session
   - **Export Charts (PDF)**: Multi-page PDF with individual charts for each sensor
   - **Crop Parameters (CSV)**: All crop parameter sets
   - **Export Images**: Share all uploaded crop images
4. All exports use the platform share sheet for easy sharing

## Data Model

### Sensor Readings
- Stored in SQLite database (Drift)
- Each reading includes: timestamp, moisture, EC, temperature, pH, NPK values, salinity
- Can be linked to a crop parameter set (optional)

### Reading Sessions
- Groups of sensor reading IDs
- Created when user taps "Save readings"
- Stored in SharedPreferences as JSON
- Can be linked to crop parameters

### Crop Parameters
- Soil type, properties, leaf color, stem size, height, notes
- Linked images stored locally with sequential filenames
- Can be linked to multiple readings/sessions

## Export Format Details

### CSV Exports
- **IDs**: Sequential numbering starting from 1 for each export (not database IDs)
- **Sensor CSV**: All sensor fields + cropParamsId
- **Combined CSV**: Sensor data + crop parameter details + image filenames

### PDF Reports
- **Session-based summaries**: Shows average values instead of individual readings
- **Summary sentences**: Human-readable descriptions of each session
- **Crop parameters table**: All defined parameter sets
- **Filtering**: Can export a specific session or all sessions

## Notes for Embedded Developers

1. **BLE Payload Size**: Keep JSON payloads small (< 512 bytes recommended)
2. **Update Frequency**: Send readings every 1-2 seconds to avoid flooding BLE
3. **Timestamp Handling**: Use Unix timestamp (seconds). Invalid timestamps are replaced with current time
4. **UUID Format**: App handles both short (16-bit) and full (128-bit) UUID formats
5. **Schema Changes**: If adding new fields:
   - Update `LiveReading` class in `bluetooth_service.dart`
   - Update Drift schema in `app_database.dart`
   - Run `flutter pub run build_runner build` to regenerate code

## Troubleshooting

### iOS BLE Issues
- Ensure you're running on a **physical device** (not simulator)
- Check that Bluetooth permissions are granted
- Verify `Info.plist` contains required Bluetooth usage descriptions

### CocoaPods Issues
- Run `pod repo update` to update CocoaPods specs
- Try `cd ios && pod install --repo-update`

### Connection Issues
- Ensure ESP32 is powered on and advertising
- Check that device name matches expected prefix (optional)
- Verify service and characteristic UUIDs match exactly
- Ensure ESP32 is sending notifications (not just read values)


