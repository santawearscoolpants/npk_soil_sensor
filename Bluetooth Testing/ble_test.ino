#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

// Simple custom UUIDs for testing
#define SERVICE_UUID        "12345678-1234-1234-1234-1234567890ab"
#define CHARACTERISTIC_UUID "abcdefab-1234-1234-1234-abcdefabcdef"

BLEServer *pServer = nullptr;
BLECharacteristic *pCharacteristic = nullptr;
bool deviceConnected = false;

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
  Serial.println("Use nRF Connect / LightBlue on Android or iOS to scan & connect.");
}

void loop() {
  // No periodic notifications here.
  // Later you'll put your sensor reading + manual notify logic in this loop.
}
