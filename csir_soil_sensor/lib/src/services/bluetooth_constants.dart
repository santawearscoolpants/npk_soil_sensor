/// BLE UUIDs expected from the ESP32 firmware.
///
/// The ESP32 should expose a primary service with [soilSensorServiceUuid] and a
/// characteristic with [soilSensorCharacteristicUuid] that notifies JSON
/// payloads containing the soil readings.
///
/// Example JSON payload:
/// {
///   "timestamp": 1717434300,
///   "moisture": 34.2,
///   "ec": 1.8,
///   "temperature": 27.4,
///   "ph": 6.3,
///   "nitrogen": 45,
///   "phosphorus": 22,
///   "potassium": 60,
///   "salinity": 0.9
/// }

const String soilSensorServiceUuid = '0000F001-0000-1000-8000-00805F9B34FB';
const String soilSensorCharacteristicUuid =
    '0000F002-0000-1000-8000-00805F9B34FB';

/// BLE device name prefix that the app will filter for when scanning.
const String soilSensorDeviceNamePrefix = 'FARM-ESP32';


