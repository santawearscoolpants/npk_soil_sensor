#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>
#include <SPI.h>
#include <Adafruit_GFX.h>
#include <Adafruit_ST7735.h>
#include <Adafruit_ST77xx.h>
#include <ModbusMaster.h>

// ============ BLE CONFIGURATION ====================================
#define SERVICE_UUID        "0000F001-0000-1000-8000-00805F9B34FB"
#define CHARACTERISTIC_UUID "0000F002-0000-1000-8000-00805F9B34FB"

BLEServer *pServer = nullptr;
BLECharacteristic *pCharacteristic = nullptr;
bool deviceConnected = false;

// Sensor data update interval (milliseconds)
const unsigned long UPDATE_INTERVAL = 2000; // Send data every 2 seconds
unsigned long lastUpdateTime = 0;

// ============ TFT DISPLAY ===========================================
#define TFT_CS   5    // CS
#define TFT_DC   4    // A0 / DC
#define TFT_RST  2    // RESET pin of TFT

Adafruit_ST7735 tft = Adafruit_ST7735(TFT_CS, TFT_DC, TFT_RST);

// ============ RS485 / NPK SENSOR ====================================
#define RE_DE_PIN 21   // moved from 4 to 21
#define RS485_RX  17
#define RS485_TX  16

#define MODBUS_SLAVE_ID 1
#define BAUD_RATE 4800

HardwareSerial RS485Serial(1);
ModbusMaster node;

// Convert unsigned to signed
int16_t toSigned(uint16_t v) {
  return (v & 0x8000) ? (v - 65536) : v;
}

// RS485 control
void preTransmission()  { digitalWrite(RE_DE_PIN, HIGH); }
void postTransmission() { digitalWrite(RE_DE_PIN, LOW);  }

// ---- BLE Server connection callbacks ----
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

// ---- BLE Characteristic write callback ----
class MyCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) override {
    String value = pCharacteristic->getValue();  // Arduino String

    if (value.length() > 0) {
      Serial.print("Received from BLE client: ");
      Serial.println(value);
    }
  }
};

// Generate sensor reading JSON string from actual sensor data
void generateSensorDataJSON(char* buffer, size_t bufferSize, 
                            float moisture, float ec, float temperature, 
                            float ph, int nitrogen, int phosphorus, 
                            int potassium, float salinity) {
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
  Serial.println("ESP32 + TFT + 7-in-1 NPK Sensor + BLE");

  // --- TFT setup ---
  SPI.begin();  // VSPI: SCK=18, MISO=19, MOSI=23

  tft.initR(INITR_BLACKTAB);  // same TAB you used before
  tft.setRotation(1);

  // Quick color test on boot
  tft.fillScreen(ST77XX_RED);
  delay(300);
  tft.fillScreen(ST77XX_GREEN);
  delay(300);
  tft.fillScreen(ST77XX_BLUE);
  delay(300);
  tft.fillScreen(ST77XX_BLACK);

  tft.setCursor(0, 0);
  tft.setTextColor(ST77XX_WHITE);
  tft.setTextSize(1);
  tft.println("Booting soil sensor...");

  // --- RS485 / Modbus setup ---
  pinMode(RE_DE_PIN, OUTPUT);
  digitalWrite(RE_DE_PIN, LOW);    // receive mode by default

  RS485Serial.begin(BAUD_RATE, SERIAL_8N1, RS485_RX, RS485_TX);

  node.begin(MODBUS_SLAVE_ID, RS485Serial);
  node.preTransmission(preTransmission);
  node.postTransmission(postTransmission);

  // --- BLE setup ---
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
  Serial.println("Setup complete.");
}

void loop() {
  // Read sensor data from Modbus
  uint8_t result = node.readHoldingRegisters(0x0000, 9);

  // Update TFT display
  tft.fillScreen(ST77XX_BLACK);
  tft.setCursor(0, 0);
  tft.setTextSize(1);

  if (result == node.ku8MBSuccess) {
    uint16_t raw[9];
    for (int i = 0; i < 9; i++) {
      raw[i] = node.getResponseBuffer(i);
    }

    // Parse sensor data
    float moisture = raw[0] / 10.0;
    float temp     = toSigned(raw[1]) / 10.0;
    float ec       = raw[2];
    float ph       = raw[3] / 10.0;
    int   n        = raw[4];
    int   p        = raw[5];
    int   k        = raw[6];
    int   sal      = raw[7];
    int   tds      = raw[8];
    float salinity = sal / 10.0;  // Convert to float for JSON

    // ---- Serial Output ----
    Serial.println("===== Soil Sensor Data =====");
    Serial.printf("Temperature : %.1f C\n", temp);
    Serial.printf("Moisture    : %.1f %%\n", moisture);
    Serial.printf("EC          : %.0f\n", ec);
    Serial.printf("pH          : %.1f\n", ph);
    Serial.printf("Nitrogen    : %d\n", n);
    Serial.printf("Phosphorus  : %d\n", p);
    Serial.printf("Potassium   : %d\n", k);
    Serial.printf("Salinity    : %.1f\n", salinity);
    Serial.printf("TDS         : %d\n", tds);
    Serial.println("----------------------------");

    // ---- TFT Output ----
    tft.setTextColor(ST77XX_GREEN);
    tft.println("Soil Sensor Readings");

    tft.setTextColor(ST77XX_WHITE);
    tft.printf("Temp:   %.1f C\n", temp);
    tft.printf("Moist:  %.1f %%\n", moisture);
    tft.printf("EC:     %.0f\n", ec);
    tft.printf("pH:     %.1f\n", ph);
    tft.printf("N:      %d\n", n);
    tft.printf("P:      %d\n", p);
    tft.printf("K:      %d\n", k);
    tft.printf("Sal:    %.1f\n", salinity);
    tft.printf("TDS:    %d\n", tds);

    // Send sensor data via BLE periodically when connected
    if (deviceConnected && (millis() - lastUpdateTime >= UPDATE_INTERVAL)) {
      char sensorData[200]; // Buffer for JSON string
      generateSensorDataJSON(sensorData, sizeof(sensorData),
                            moisture, ec, temp, ph, n, p, k, salinity);
      
      // Send data via BLE characteristic notification
      pCharacteristic->setValue(sensorData);
      pCharacteristic->notify();
      
      Serial.print("Sent sensor data via BLE: ");
      Serial.println(sensorData);
      
      lastUpdateTime = millis();
    }

  } else {
    Serial.print("❌ Modbus Error: ");
    Serial.println(result);

    tft.setTextColor(ST77XX_RED);
    tft.println("Modbus Error");
    tft.printf("Code: %d\n", result);
  }

  // Small delay to prevent watchdog issues
  delay(100);
}
