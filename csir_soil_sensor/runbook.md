## CSIR Soil Sensor Runbook (Phase 1 MVP)

### 1. Bluetooth Connection

1. Launch the app on the device.
2. Navigate to the **Live Data** tab (bottom nav).
3. Tap the **Bluetooth icon** in the app bar (or the **"Manage"** button in the status card).
4. On the Bluetooth Connection screen:
   - Tap **"Scan for devices"** to search for nearby ESP32 devices.
   - Wait for the scan to complete (10 seconds).
   - Select your ESP32 device from the list.
   - Connection status will show:
     - 🟢 **Green dot**: Connected successfully
     - 🟠 **Orange dot**: Scanning or connecting
     - 🔴 **Red dot**: Disconnected or Bluetooth off
5. Once connected, tap **"Disconnect from device"** when done.
   - If you have unsaved readings, you'll be prompted to save or discard them.

### 2. Live Data Collection

1. After connecting to the ESP32, sensor readings will appear automatically on the **Live Data** tab.
2. Readings are automatically saved to the database as they arrive.
3. **Link to crop parameters** (optional):
   - Select a crop parameter set from the dropdown.
   - All readings received while this is selected will be linked to that parameter set.
4. **Save readings as a session**:
   - Tap **"Save readings (X)"** where X is the number of accumulated readings.
   - This creates a reading session that groups all pending readings together.
   - The session can later be viewed in History and exported.

### 3. Crop Parameters Management

1. Go to the **Crop Params** tab.
2. Fill in the form:
   - **Soil type** (required)
   - **Soil properties** (required)
   - **Leaf color** (required)
   - **Stem size (cm)** (required, numeric)
   - **Plant height (cm)** (required)
   - Optional **Notes**
3. Add images of the crop:
   - Tap **Camera** to capture a new photo, or
   - Tap **Gallery** to pick an existing photo.
   - Images are automatically relabeled as `tomato_001.jpg`, `tomato_002.jpg`, etc.
4. Tap **"Save parameters"**:
   - The app stores a new `CropParams` record.
   - Images are copied into app storage with sequential filenames.
   - Linked `CropImage` records are created.

#### Managing Saved Parameter Sets

- **Edit**: Tap the edit icon (✏️) next to a saved set to load it into the form for editing.
- **Delete**: Tap the delete icon (🗑️) next to a saved set to remove it (with confirmation).
- **Multi-select Delete**:
  - Tap the checklist icon (☑️) in the app bar to enter selection mode.
  - Checkboxes appear next to each parameter set.
  - Select multiple sets, then tap the delete icon in the app bar to remove them all.

### 4. Viewing History (Sessions)

1. Go to the **History** tab.
2. You'll see a list of all reading sessions, sorted by date (newest first).
3. Each session card shows:
   - Session number
   - Number of readings in the session
   - Creation date and time
4. **Tap a session** to view details:
   - Number of readings
   - Date and time range
   - Average values for all sensor parameters
   - Linked crop parameters (if any)
   - **Link/Unlink crop parameters**: Use the dropdown to link the session to a crop parameter set
   - **Delete session**: Remove the session and all its readings
5. **Clear all sessions**: Tap the delete icon in the app bar to remove all sessions.

### 5. Export & Share Data

1. Go to the **Export** tab.
2. **Select a session** (optional):
   - Choose a specific session from the dropdown, or
   - Select "All readings" to export everything.
3. Choose one of the export options:
   - **Export Sensor Data (CSV)**
     - Exports sensor readings with sequential IDs (starting from 1).
     - Includes: id, timestamp, moisture, ec, temperature, ph, nitrogen, phosphorus, potassium, salinity, cropParamsId.
   - **Export Sensor + Params (CSV)**
     - Combined export with readings and linked crop parameter fields.
     - Includes image filenames for linked parameters.
   - **Export PDF Report**
     - Generates a session-based summary report.
     - Shows average values for each session (not individual readings).
     - Includes date/time ranges, linked crop parameters, and summary sentences.
     - Includes a table of all crop parameter sets.
   - **Export Crop Parameters (CSV)**
     - Exports all crop parameter sets with their details and image filenames.
   - **Export Images**
     - Shares all uploaded crop images via the platform share sheet.
4. On the platform share sheet:
   - Choose **Google Drive**, **Files**, **Email**, etc. to send or store the export.

### 6. BLE Payload and Firmware Integration

#### ESP32 BLE Configuration

- **Service UUID**: `0000F001-0000-1000-8000-00805F9B34FB`
- **Characteristic UUID**: `0000F002-0000-1000-8000-00805F9B34FB`
- **Device name prefix**: `FARM-ESP32` (optional, for filtering)
- **Notifications**: Must enable notifications on the characteristic for iOS compatibility

#### JSON Payload Format

UTF-8 encoded JSON string sent as BLE notifications:

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

**Field Requirements:**
- `timestamp`: Unix timestamp (seconds since epoch). If invalid or too small, app uses current time.
- `moisture`: double, percentage
- `ec`: double, mS/cm
- `temperature`: double, °C
- `ph`: double
- `nitrogen`, `phosphorus`, `potassium`: int, mg/kg
- `salinity`: double

**App Integration Points:**
- JSON parsing: `LiveReading.fromJson` in `bluetooth_service.dart`
- UUIDs and constants: `bluetooth_constants.dart`
- UUID normalization: App handles both short (16-bit) and full (128-bit) UUID formats

### 7. Troubleshooting

#### BLE Connection Issues

- **No BLE devices found**
  - Check that ESP32 is powered on and advertising.
  - Ensure Bluetooth is enabled on your phone.
  - Verify the device name if filtering is enabled.
  - On iOS: Must run on a physical device (simulator doesn't support BLE).

- **Connection fails**
  - Verify service and characteristic UUIDs match exactly.
  - Ensure ESP32 is sending notifications (not just read values).
  - Check that BLE permissions are granted (iOS will prompt on first use).

- **Readings don't appear**
  - Verify the JSON payload exactly matches the expected field names.
  - Check for parse errors in the connection status.
  - Ensure notifications are enabled on the characteristic.
  - Verify timestamp format (Unix seconds, not milliseconds).

#### Data Issues

- **Readings not saving**
  - Check that readings are accumulating (pending count should increase).
  - Tap "Save readings" to create a session.
  - Ensure database has sufficient storage space.

- **Sessions not appearing in History**
  - Make sure you've tapped "Save readings" to create a session.
  - Refresh the History tab by navigating away and back.

#### Export Issues

- **Export fails or share sheet doesn't open**
  - Ensure storage permission is granted (Android).
  - Check that device has free storage space.
  - Try exporting a smaller dataset if the database is very large.
  - Verify the selected session exists and has readings.

- **PDF shows wrong data**
  - Ensure you've selected the correct session in the Export tab.
  - Check that sessions have been properly saved.

#### UI Issues

- **Keyboard doesn't dismiss**
  - Tap outside text fields to dismiss the keyboard.
  - Navigate to another tab.

- **Crop parameter form validation**
  - Red outlines appear only after attempting to save.
  - Fill in all required fields before saving.

### 8. Best Practices

1. **Session Management**
   - Save readings regularly to create manageable sessions.
   - Link sessions to crop parameters for better organization.
   - Review sessions in History before exporting.

2. **Crop Parameters**
   - Create parameter sets before starting data collection for easier linking.
   - Use descriptive notes to identify different growing conditions.
   - Upload clear images for better documentation.

3. **Data Export**
   - Export sessions individually for focused analysis.
   - Use "All readings" only when you need a complete dataset.
   - PDF reports are best for summaries; CSV for detailed analysis.

4. **BLE Connection**
   - Disconnect properly to avoid data loss (you'll be prompted to save).
   - Keep ESP32 within range during data collection.
   - Monitor connection status to ensure continuous data flow.
