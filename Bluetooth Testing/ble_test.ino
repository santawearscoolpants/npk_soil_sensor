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

/*
 we have some issues to resolve

 1. i checked the the sensor readings that was exported and realized in all that the timestamps were incorrect, i was seeing the year to be 1970.
 
 2. after clearing all the data at the exports session, the export selection still displays the saved sessions, until i reload the app.
 
 3. when i get to the corp params page, the page lags for a sec before it works, can you optimize that
 
 4. back to the issue at the live data page tab; still after selecting the device, the devices list still displays unless i when i tap on disconnect then i vanishes rather than showing. and when i tried to scan and connect again, after tapping on the "scan for devices" button, it loads for the 10secs without showing any devices below. 
 
 5. i did a test where the app read about 30 readings from the sensor, i then tapped on disconnet without saving the readings and the app lost all the data. let's make sure the user saves or discards the latest readings immediately the app disconnects.
 
 6. on the history page, it's not supposed to show every single reading we cannot scroll through thousands of readings, instead let it store the sensor reading sessions. so when the user taps on the session, it'll show the number of readings, crop parameter linked to or not, and other details. at this same page, we can allow the use to link the session to a crop param in case they forgot.
  
  7. in the sensor reading pdf report, the all the sensor reading values are not to show, it's redundant. instead we can show the average value for each parameter, the crop linked to (if any), date and time range of the readings, and other details. then we can add a summary of the readings in a short sentence. 

  