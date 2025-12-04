## CSIR Soil Sensor App

Flutter app for farmers to read NPK soil data from an ESP32-WROOM-DA over BLE, store readings locally, associate them with tomato crop parameters and images, and export CSV/PDF reports for sharing (e.g. Google Drive, email).

### Project structure

- **lib/**
  - `main.dart`: app entrypoint, sets up Riverpod and bottom navigation.
  - `src/core/`: theme and routing.
  - `src/data/`: Drift database, models, repositories.
  - `src/features/`:
    - `live/`: live BLE readings and “Save Reading”.
    - `history/`: list of past readings.
    - `crop_params/`: tomato parameters form + image + history list.
    - `export/`: export CSV/PDF and share.
  - `src/services/`:
    - `bluetooth_service.dart`: BLE handling + demo mode.
    - `export_service.dart`: CSV/PDF generation and sharing.
    - `image_service.dart` (future extension point).

### BLE expectations (for ESP32 firmware)

- **Service UUID**: `0000F001-0000-1000-8000-00805F9B34FB`
- **Characteristic UUID**: `0000F002-0000-1000-8000-00805F9B34FB`
- **Device name prefix**: `FARM-ESP32`
- **Payload format**: UTF‑8 JSON string, for example:

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

The app subscribes to notifications on the characteristic and parses each JSON payload into a reading.

### Dependencies (key)

- **State management**: `flutter_riverpod`
- **BLE**: `flutter_blue_plus`
- **DB**: `drift` + `sqlite3_flutter_libs`
- **Images & storage**: `image_picker`, `path_provider`
- **Export**: `csv`, `pdf`, `printing`, `share_plus`

### Running the app

1. Install Flutter and set up an emulator or physical device.
2. From the project root:

```bash
flutter pub get
```

3. For iOS, install pods (after ensuring CocoaPods specs are up to date):

```bash
cd ios
pod install --repo-update
cd ..
```

4. Run:

```bash
flutter run
```

> **Note (BLE on iOS)**  
> - Real BLE scanning/connection only works on a **physical iOS device**, not the simulator.  
> - The first scan/connection will trigger the iOS Bluetooth permission dialog (make sure you accept).

### Demo mode vs real BLE

- On the **Live Data** tab, tap the bug icon in the app bar to inject a mock reading using the same JSON format as the ESP32.
- For real devices, ensure:
  - The ESP32 advertises a name starting with `FARM-ESP32`.
  - The BLE service/characteristic UUIDs and JSON payload match the constants in `src/services/bluetooth_constants.dart`.

On the Live Data screen:

- Tap **Scan for devices** to start a BLE scan (Android + iOS).  
- A list of nearby BLE devices appears; tap the correct device to connect.  
- The status line shows:
  - A **green dot** and `Connected (device name)` when connected.
  - Orange while **Scanning/Connecting**.
  - Red with an explanatory message if disconnected or if Bluetooth is off.

### Data export

- **CSV**:
  - Sensor-only readings.
  - Combined readings + linked crop parameters.
- **PDF**:
  - Basic report with tomato parameter sets and up to 50 recent readings.
- All exports go through the platform share sheet so the user can send them to Google Drive, Files, email, etc.

### Notes for embedded developer

- Keep payloads small and periodic (e.g. 1–2 seconds) to avoid flooding BLE.
- If you change field names or add new metrics, update:
  - `LiveReading.fromJson` in `bluetooth_service.dart`.
  - The Drift schema in `app_database.dart` and rerun `build_runner`.

