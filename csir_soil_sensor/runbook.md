## CSIR Soil Sensor Runbook (Phase 1 MVP)

### 1. Live data and BLE

1. Launch the app on the device.
2. Go to the **Live Data** tab (bottom nav).
3. To use **demo mode**:
   - Tap the bug icon in the top-right of the app bar.
   - A mock sensor reading appears in the “Latest Reading” card.
4. To use a **real ESP32**:
   - Power the ESP32 and ensure it advertises with a name starting with `FARM-ESP32`.
   - Tap **Scan & Connect**.
   - Wait for status to change to **Connected**.
   - The latest reading card should update whenever the ESP32 sends a JSON payload.
5. When you see a reading you want to keep, tap **Save Reading**.

### 2. Tomato crop parameters + image

1. Go to the **Crop Params** tab.
2. Fill in the form:
   - **Soil type**
   - **Soil properties**
   - **Leaf color**
   - **Stem description**
   - **Plant height (cm)**
   - Optional **Notes**
3. Add an image of the crop:
   - Tap **Camera** to capture a new photo, or
   - Tap **Gallery** to pick an existing photo.
4. Tap **Save parameters**:
   - The app stores/updates a `CropParams` record.
   - The image is copied into app storage and renamed to  
     `tomato_<cropParamsId>_<timestamp>.jpg`.
   - A linked `CropImage` record is created with the new file path.
5. Scroll down to **Saved parameter sets** to see the history of parameter sets.

### 3. Viewing history of readings

1. Go to the **History** tab.
2. You’ll see a list of all saved readings, newest last (per Drift query).
3. Tap any reading:
   - A dialog shows the full details (moisture, EC, temperature, pH, N, P, K, salinity, timestamp).
   - Future versions can join and show linked crop parameters here.

### 4. Export & share data

1. Go to the **Export** tab.
2. Choose one of:
   - **Export Sensor Data (CSV)**  
     Exports all sensor readings to `sensor_readings.csv` and opens the share sheet.
   - **Export Sensor + Params (CSV)**  
     Exports a joined file with readings and any linked crop parameter fields to `combined_data.csv`.
   - **Export PDF Report**  
     Generates a PDF report (`soil_report.pdf`) with:
       - Summary table of tomato parameter sets.
       - Table of up to 50 recent readings.
3. On the platform share sheet:
   - Choose **Google Drive**, **Files**, **Email**, etc. to send or store the export.

### 5. BLE payload and firmware integration checklist

- ESP32 BLE configuration:
  - Service UUID: `0000F001-0000-1000-8000-00805F9B34FB`
  - Characteristic UUID: `0000F002-0000-1000-8000-00805F9B34FB`
  - Device name prefix: `FARM-ESP32`
- Payload:
  - UTF‑8 encoded JSON string with at least:
    - `timestamp` (seconds since epoch)
    - `moisture` (double, %)
    - `ec` (double, mS/cm)
    - `temperature` (double, °C)
    - `ph` (double)
    - `nitrogen`, `phosphorus`, `potassium` (int, mg/kg or ppm)
    - `salinity` (double)
- App integration points:
  - JSON parsing: `LiveReading.fromJson` in `bluetooth_service.dart`.
  - UUIDs and name filter: `bluetooth_constants.dart`.

### 6. Troubleshooting

- **No BLE devices found**
  - Check that ESP32 is powered and advertising.
  - Confirm name starts with `FARM-ESP32`.
  - Ensure Bluetooth and location permissions are granted on the phone.
- **Readings don’t appear**
  - Verify the JSON payload exactly matches the expected field names.
  - Check for parse errors in the status text on the Live Data screen.
- **Export fails or share sheet doesn’t open**
  - Make sure the device has free storage space.
  - Try again with a smaller dataset if the database is very large.


