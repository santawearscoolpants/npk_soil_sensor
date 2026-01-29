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
#define RE_DE_PIN 21
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

// ============ UNIT CONVERSIONS (BEFORE CALIBRATION) ============
// EC: 1 dS/m = 1000 µS/cm
static inline float ec_uScm_to_dSm(float ec_uScm) {
  return ec_uScm / 1000.0f;
}

// N: mg/kg -> % (unit-equivalent only)
static inline float n_mgkg_to_percent(float n_mgkg) {
  return n_mgkg / 10000.0f;
}

// K: mg/kg -> cmol(+)/kg for K+
// cmol(+)/kg = mg/kg / (39.10 * 10) = mg/kg / 391
static inline float k_mgkg_to_cmolkg(float k_mgkg) {
  return k_mgkg / 391.0f;
}

// ============ CALIBRATION EQUATIONS (Sensor -> Standard) ============
static const float EC_M = 0.220636585f;
static const float EC_B = 0.06098882155f;

static const float PH_M = 0.06749371859f;
static const float PH_B = 5.126893844f;

static const float N_M  = 0.005542328042f;
static const float N_B  = 0.1148412698f;

static const float P_M  = 0.0414315776f;
static const float P_B  = 7.840383242f;

static const float K_M  = 0.3580341716f;
static const float K_B  = 0.1642282588f;

// ---- BLE Server connection callbacks ----
class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) override {
    deviceConnected = true;
    Serial.println("BLE client CONNECTED.");
  }

  void onDisconnect(BLEServer* pServer) override {
    deviceConnected = false;
    Serial.println("BLE client DISCONNECTED.");
    pServer->getAdvertising()->start();
    Serial.println("Advertising restarted.");
  }
};

// ---- BLE Characteristic write callback ----
class MyCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) override {
    std::string rx = pCharacteristic->getValue();
    if (!rx.empty()) {
      Serial.print("Received from BLE client: ");
      Serial.println(rx.c_str());
    }
  }
};

// Generate sensor reading JSON string from calibrated “standard” values
void generateSensorDataJSON(char* buffer, size_t bufferSize,
                            float moisture_pct,
                            float ec_std_dSm,
                            float temperature_C,
                            float ph_std,
                            float n_std_percent,
                            float p_std_mgkg,
                            float k_std_cmolkg,
                            float salinity,
                            int tds) {
  unsigned long timestamp = millis() / 1000;

  // Keep field names stable + explicit units in names where helpful
  snprintf(buffer, bufferSize,
    "{\"timestamp\":%lu,"
    "\"moisture_pct\":%.1f,"
    "\"temperature_c\":%.1f,"
    "\"ec_dSm\":%.3f,"
    "\"ph\":%.2f,"
    "\"n_percent\":%.4f,"
    "\"p_mgkg\":%.1f,"
    "\"k_cmolkg\":%.3f,"
    "\"salinity\":%.2f,"
    "\"tds\":%d}",
    timestamp,
    moisture_pct,
    temperature_C,
    ec_std_dSm,
    ph_std,
    n_std_percent,
    p_std_mgkg,
    k_std_cmolkg,
    salinity,
    tds
  );
}

void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.println();
  Serial.println("ESP32 + TFT + 7-in-1 NPK Sensor + BLE (Calibrated)");

  // --- TFT setup ---
  SPI.begin();  // VSPI: SCK=18, MISO=19, MOSI=23

  tft.initR(INITR_BLACKTAB);
  tft.setRotation(1);

  // Quick color test on boot
  tft.fillScreen(ST77XX_RED);
  delay(250);
  tft.fillScreen(ST77XX_GREEN);
  delay(250);
  tft.fillScreen(ST77XX_BLUE);
  delay(250);
  tft.fillScreen(ST77XX_BLACK);

  tft.setCursor(0, 0);
  tft.setTextColor(ST77XX_WHITE);
  tft.setTextSize(1);
  tft.println("Booting soil sensor...");
  tft.println("Calibrations enabled");

  // --- RS485 / Modbus setup ---
  pinMode(RE_DE_PIN, OUTPUT);
  digitalWrite(RE_DE_PIN, LOW); // receive mode by default

  RS485Serial.begin(BAUD_RATE, SERIAL_8N1, RS485_RX, RS485_TX);

  node.begin(MODBUS_SLAVE_ID, RS485Serial);
  node.preTransmission(preTransmission);
  node.postTransmission(postTransmission);

  // --- BLE setup ---
  BLEDevice::init("ESP32_BLE_TEST");

  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  BLEService *pService = pServer->createService(SERVICE_UUID);

  pCharacteristic = pService->createCharacteristic(
    CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_READ   |
    BLECharacteristic::PROPERTY_WRITE  |
    BLECharacteristic::PROPERTY_NOTIFY |
    BLECharacteristic::PROPERTY_INDICATE
  );

  pCharacteristic->addDescriptor(new BLE2902());
  pCharacteristic->setCallbacks(new MyCallbacks());
  pCharacteristic->setValue("Hello from ESP32!");

  pService->start();

  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);
  pAdvertising->setMinPreferred(0x12);

  BLEDevice::startAdvertising();

  Serial.println("BLE started.");
  Serial.println("Advertising as: ESP32_BLE_TEST");
  Serial.println("Sending calibrated data every 2s when connected.");
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

    // ---- RAW PARSE (as read) ----
    float moisture = raw[0] / 10.0f;
    float temp     = toSigned(raw[1]) / 10.0f;

    float ec_raw_uScm = (float)raw[2];     // typically µS/cm
    float ph_raw      = raw[3] / 10.0f;    // pH

    float n_raw_mgkg  = (float)raw[4];     // mg/kg
    float p_raw_mgkg  = (float)raw[5];     // mg/kg
    float k_raw_mgkg  = (float)raw[6];     // mg/kg

    int   sal_raw     = (int)raw[7];       // sensor-specific scaling
    int   tds         = (int)raw[8];

    float salinity = sal_raw / 10.0f;

    // ---- UNIT CONVERSIONS (BEFORE EQUATIONS) ----
    float ec_sensor = ec_uScm_to_dSm(ec_raw_uScm);    // dS/m
    float ph_sensor = ph_raw;                         // pH
    float n_sensor  = n_mgkg_to_percent(n_raw_mgkg);  // %
    float p_sensor  = p_raw_mgkg;                     // mg/kg
    float k_sensor  = k_mgkg_to_cmolkg(k_raw_mgkg);   // cmol(+)/kg

    // ---- CALIBRATION (Sensor -> Standard) ----
    float ec_std = EC_M * ec_sensor + EC_B;  // dS/m
    float ph_std = PH_M * ph_sensor + PH_B;  // pH
    float n_std  = N_M  * n_sensor  + N_B;   // %
    float p_std  = P_M  * p_sensor  + P_B;   // mg/kg
    float k_std  = K_M  * k_sensor  + K_B;   // cmol(+)/kg

    // ---- TFT Output (Calibrated “Std”) ----
    tft.setTextColor(ST77XX_GREEN);
    tft.println("Calibrated (Std)");

    tft.setTextColor(ST77XX_WHITE);
    tft.printf("Temp: %.1f C\n", temp);
    tft.printf("Moist: %.1f %%\n", moisture);

    tft.printf("EC: %.3f dS/m\n", ec_std);
    tft.printf("pH: %.2f\n", ph_std);
    tft.printf("N:  %.4f %%\n", n_std);
    tft.printf("P:  %.1f mg/kg\n", p_std);
    tft.printf("K:  %.3f cmol/kg\n", k_std);

    tft.printf("Sal: %.1f\n", salinity);
    tft.printf("TDS: %d\n", tds);

    // ---- BLE JSON notify every 2s ----
    if (deviceConnected && (millis() - lastUpdateTime >= UPDATE_INTERVAL)) {
      char sensorData[220];

      generateSensorDataJSON(sensorData, sizeof(sensorData),
                             moisture,
                             ec_std,
                             temp,
                             ph_std,
                             n_std,
                             p_std,
                             k_std,
                             salinity,
                             tds);

      pCharacteristic->setValue((uint8_t*)sensorData, strlen(sensorData));
      pCharacteristic->notify();

      Serial.print("Sent BLE JSON: ");
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

  delay(100);
}
