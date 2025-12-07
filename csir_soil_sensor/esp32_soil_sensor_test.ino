#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>

// BLE UUIDs (must match app expectations)
#define SERVICE_UUID        "0000F001-0000-1000-8000-00805F9B34FB"
#define CHARACTERISTIC_UUID "0000F002-0000-1000-8000-00805F9B34FB"

BLEServer *pServer = nullptr;
BLECharacteristic *pCharacteristic = nullptr;
bool deviceConnected = false;

// Sensor data update interval (milliseconds)
const unsigned long UPDATE_INTERVAL = 2000; // Send data every 2 seconds
unsigned long lastUpdateTime = 0;

// Base sensor values (will be varied slightly each update)
float baseMoisture = 35.0;
float baseEC = 1.5;
float baseTemperature = 25.0;
float basePH = 6.2;
int baseNitrogen = 45;
int basePhosphorus = 25;
int basePotassium = 60;
float baseSalinity = 0.7;

// ---- Server connection callbacks ----
class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) override {
    deviceConnected = true;
    Serial.println("BLE client CONNECTED.");
  }

  void onDisconnect(BLEServer* pServer) override {
    deviceConnected = false;
    Serial.println("BLE client DISCONNECTED.");

    // Restart advertising so another device can connect again
    pServer->getAdvertising()->start();
    Serial.println("Advertising restarted.");
  }
};

// ---- Characteristic write callback ----
class MyCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) override {
    String value = pCharacteristic->getValue();  // Arduino String

    if (value.length() > 0) {
      Serial.print("Received from BLE client: ");
      Serial.println(value);
    }
  }
};

// Generate a random float between min and max
float randomFloat(float min, float max) {
  return min + (max - min) * (random(0, 1000) / 1000.0);
}

// Generate sensor reading JSON string (optimized to use char array instead of String)
void generateSensorData(char* buffer, size_t bufferSize) {
  // Add small random variations to base values
  float moisture = constrain(baseMoisture + randomFloat(-3.0, 3.0), 25.0, 55.0);
  float ec = constrain(baseEC + randomFloat(-0.2, 0.2), 1.0, 2.5);
  float temperature = constrain(baseTemperature + randomFloat(-1.5, 1.5), 22.0, 30.0);
  float ph = constrain(basePH + randomFloat(-0.3, 0.3), 5.5, 7.0);
  int nitrogen = constrain(baseNitrogen + random(-5, 6), 30, 70);
  int phosphorus = constrain(basePhosphorus + random(-3, 4), 15, 45);
  int potassium = constrain(basePotassium + random(-5, 6), 40, 80);
  float salinity = constrain(baseSalinity + randomFloat(-0.1, 0.1), 0.3, 1.1);
  
  // Get current Unix timestamp (simplified - uses millis since boot)
  unsigned long timestamp = millis() / 1000;
  
  // Build JSON string directly into buffer (more memory efficient)
  snprintf(buffer, bufferSize,
    "{\"timestamp\":%lu,\"moisture\":%.1f,\"ec\":%.2f,\"temperature\":%.1f,\"ph\":%.1f,\"nitrogen\":%d,\"phosphorus\":%d,\"potassium\":%d,\"salinity\":%.2f}",
    timestamp, moisture, ec, temperature, ph, nitrogen, phosphorus, potassium, salinity);
}

void setup() {
  Serial.begin(115200);
  delay(1000);

  Serial.println();
  Serial.println("Booting ESP32 BLE test...");

  // 1. Initialize BLE device (name appears in BLE apps on Android & iOS)
  BLEDevice::init("ESP32_BLE_TEST");

  // 2. Create BLE server
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // 3. Create BLE service
  BLEService *pService = pServer->createService(SERVICE_UUID);

  // 4. Create BLE characteristic (read/write/notify/indicate)
  pCharacteristic = pService->createCharacteristic(
    CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_READ   |
    BLECharacteristic::PROPERTY_WRITE  |
    BLECharacteristic::PROPERTY_NOTIFY |
    BLECharacteristic::PROPERTY_INDICATE
  );

  // Add descriptor for notifications (required for iOS)
  pCharacteristic->addDescriptor(new BLE2902());
  
  pCharacteristic->setCallbacks(new MyCallbacks());
  pCharacteristic->setValue("Hello from ESP32!");

  // 5. Start the service
  pService->start();

  // 6. Start advertising so phones can discover the ESP32
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);  // recommended values for iOS
  pAdvertising->setMinPreferred(0x12);

  BLEDevice::startAdvertising();

  Serial.println("BLE started.");
  Serial.println("Now advertising as: ESP32_BLE_TEST");
  Serial.println("Waiting for app connection...");
  Serial.println("Sensor data will be sent every 2 seconds when connected.");
  
  // Initialize random seed
  randomSeed(analogRead(0));
}

void loop() {
  // Send sensor data periodically when connected
  if (deviceConnected && (millis() - lastUpdateTime >= UPDATE_INTERVAL)) {
    char sensorData[200]; // Buffer for JSON string
    generateSensorData(sensorData, sizeof(sensorData));
    
    // Send data via BLE characteristic notification
    pCharacteristic->setValue(sensorData);
    pCharacteristic->notify();
    
    Serial.print("Sent sensor data: ");
    Serial.println(sensorData);
    
    lastUpdateTime = millis();
  }
  
  // Small delay to prevent watchdog issues
  delay(10);
}
