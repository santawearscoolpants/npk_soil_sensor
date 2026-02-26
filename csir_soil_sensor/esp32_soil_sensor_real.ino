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
#define TFT_DC   27    // A0 / DC
#define TFT_RST  26    // RESET pin of TFT

Adafruit_ST7735 tft = Adafruit_ST7735(TFT_CS, TFT_DC, TFT_RST);

// Table layout constants (from calibrated.ino)
#define TABLE_HEADER_Y 10
#define TABLE_ROW_H    11
#define TABLE_COL1_X   0      // Parameter name (width: 35px)
#define TABLE_COL2_X   35     // RAW value (width: 40px)
#define TABLE_COL3_X   75     // CONV value (width: 40px)
#define TABLE_COL4_X   115    // CALIB value (width: 45px)

// Custom dark green color for table separators (RGB565: 0x03E0)
#define DARK_GREEN 0x03E0

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

// ============ UNIT CONVERSIONS (BEFORE CALIBRATION) ============
// EC: 1 dS/m = 1000 µS/cm
static inline float ec_uScm_to_dSm(float ec_uScm) {
  return ec_uScm / 1000.0f;
}

// N: % <-> mg/kg (unit-equivalent only)
static inline float n_mgkg_to_percent(float n_mgkg) {
  return n_mgkg / 10000.0f;
}

// K: mg/kg -> cmol(+)/kg for K+
// cmol(+)/kg = mg/kg / (39.10 * 10) = mg/kg / 391
static inline float k_mgkg_to_cmolkg(float k_mgkg) {
  return k_mgkg / 391.0f;
}

// ===== TFT TABLE RENDERING (from calibrated.ino) =====

// Draw horizontal line separator
void drawTableHLine(int y) {
  tft.drawFastHLine(0, y, tft.width(), DARK_GREEN);
}

// Draw vertical line separator
void drawTableVLine(int x) {
  tft.drawFastVLine(x, TABLE_HEADER_Y, tft.height() - TABLE_HEADER_Y, DARK_GREEN);
}

// Draw table header
void drawTableHeader() {
  tft.setTextSize(1);
  tft.setTextColor(ST77XX_GREEN, ST77XX_BLACK);
  
  // Clear header area
  tft.fillRect(0, TABLE_HEADER_Y, tft.width(), TABLE_ROW_H, ST77XX_BLACK);
  
  // Draw header text
  tft.setCursor(TABLE_COL1_X + 2, TABLE_HEADER_Y + 2);
  tft.print("Param");
  
  tft.setCursor(TABLE_COL2_X + 2, TABLE_HEADER_Y + 2);
  tft.print("RAW");
  
  tft.setCursor(TABLE_COL3_X + 2, TABLE_HEADER_Y + 2);
  tft.print("CONV");
  
  tft.setCursor(TABLE_COL4_X + 2, TABLE_HEADER_Y + 2);
  tft.print("CALIB");
  
  // Draw separator line below header
  drawTableHLine(TABLE_HEADER_Y + TABLE_ROW_H);
}

// Draw table title
void drawTftHead() {
  tft.fillScreen(ST77XX_BLACK);
  tft.setTextSize(1);
  tft.setCursor(0, 0);
  tft.setTextColor(ST77XX_GREEN, ST77XX_BLACK);
  tft.print("    LSACROFT SOIL SENSOR");
}

// Clear table data area
void clearTftDataArea() {
  tft.fillRect(0, TABLE_HEADER_Y + TABLE_ROW_H, tft.width(), 
                tft.height() - (TABLE_HEADER_Y + TABLE_ROW_H), ST77XX_BLACK);
}

// Draw a table row with parameter name and three values
void drawTableRow(uint8_t rowIndex, const char* paramName, uint16_t color,
                  const char* rawVal, const char* convVal, const char* calibVal) {
  int y = TABLE_HEADER_Y + TABLE_ROW_H + 1 + (rowIndex * TABLE_ROW_H);
  
  // Clear row area
  tft.fillRect(0, y, tft.width(), TABLE_ROW_H, ST77XX_BLACK);
  
  // Draw parameter name (left column)
  tft.setTextColor(color, ST77XX_BLACK);
  tft.setCursor(TABLE_COL1_X + 2, y + 2);
  tft.print(paramName);
  
  // Draw RAW value
  tft.setCursor(TABLE_COL2_X + 2, y + 2);
  tft.print(rawVal);
  
  // Draw CONV value
  tft.setCursor(TABLE_COL3_X + 2, y + 2);
  tft.print(convVal);
  
  // Draw CALIB value
  tft.setCursor(TABLE_COL4_X + 2, y + 2);
  tft.print(calibVal);
  
  // Draw horizontal separator line
  drawTableHLine(y + TABLE_ROW_H);
}

// Draw vertical column separators
void drawTableSeparators() {
  drawTableVLine(TABLE_COL2_X);
  drawTableVLine(TABLE_COL3_X);
  drawTableVLine(TABLE_COL4_X);
}

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

// Generate sensor reading JSON string including raw, converted, and calibrated values
void generateSensorDataJSON(char* buffer, size_t bufferSize,
                            float moisture,
                            float ec_raw_uScm, float ec_sensor, float ec_std,
                            float temperature,
                            float ph_raw, float ph_sensor, float ph_std,
                            float n_raw_mgkg, float n_sensor, float n_std,
                            float p_raw_mgkg, float p_sensor, float p_std,
                            float k_raw_mgkg, float k_sensor, float k_std,
                            float salinity_raw, float salinity, float tds) {
  // Get current Unix timestamp (simplified - uses millis since boot)
  unsigned long timestamp = millis() / 1000;

  // Build JSON string directly into buffer (more memory efficient)
  // Top-level "raw" fields are kept for backward compatibility with the app.
  // Additional *_conv and *_cal fields expose converted + calibrated values.
  snprintf(
    buffer,
    bufferSize,
    "{"
      "\"timestamp\":%lu,"
      "\"moisture\":%.1f,"
      "\"ec\":%.0f,"                // raw EC (µS/cm)
      "\"temperature\":%.1f,"
      "\"ph\":%.1f,"                // raw pH
      "\"nitrogen\":%.0f,"          // raw N (mg/kg)
      "\"phosphorus\":%.0f,"        // raw P (mg/kg)
      "\"potassium\":%.0f,"         // raw K (mg/kg)
      "\"salinity_raw\":%.0f,"
      "\"salinity\":%.1f,"
      "\"tds\":%.0f,"
      "\"ec_conv\":%.3f,"
      "\"ec_cal\":%.3f,"
      "\"ph_conv\":%.2f,"
      "\"ph_cal\":%.2f,"
      "\"n_conv\":%.4f,"
      "\"n_cal\":%.4f,"
      "\"p_conv\":%.2f,"
      "\"p_cal\":%.2f,"
      "\"k_conv\":%.3f,"
      "\"k_cal\":%.3f"
    "}",
    timestamp,
    moisture,
    ec_raw_uScm,
    temperature,
    ph_raw,
    n_raw_mgkg,
    p_raw_mgkg,
    k_raw_mgkg,
    salinity_raw,
    salinity,
    tds,
    ec_sensor,
    ec_std,
    ph_sensor,
    ph_std,
    n_sensor,
    n_std,
    p_sensor,
    p_std,
    k_sensor,
    k_std
  );
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
  uint8_t result = node.readHoldingRegisters(0x0000, 9);
  char line[48];
  clearTftDataArea();

  if (result == node.ku8MBSuccess) {
    uint16_t raw[9];
    for (int i = 0; i < 9; i++) raw[i] = node.getResponseBuffer(i);

    float moisture    = raw[0] / 10.0f;
    float temp        = toSigned(raw[1]) / 10.0f;
    float salinityRaw = (float)raw[7];       // salinity register
    float salinity    = raw[7] / 10.0f;      // salinity in usual units
    float tds         = (float)raw[8];       // TDS (Total Dissolved Solids)

    // ---- RAW SENSOR VALUES (as read) ----
    float ec_raw_uScm = (float)raw[2];       // typically µS/cm
    float ph_raw      = raw[3] / 10.0f;      // pH
    float n_raw_mgkg  = (float)raw[4];       // mg/kg (sensor claim)
    float p_raw_mgkg  = (float)raw[5];       // mg/kg
    float k_raw_mgkg  = (float)raw[6];       // mg/kg

    // ---- UNIT CONVERSIONS (BEFORE EQUATIONS) ----
    float ec_sensor = ec_uScm_to_dSm(ec_raw_uScm);     // now in dS/m
    float ph_sensor = ph_raw;                          // already pH
    float n_sensor  = n_mgkg_to_percent(n_raw_mgkg);   // now in %
    float p_sensor  = p_raw_mgkg;                      // already mg/kg
    float k_sensor  = k_mgkg_to_cmolkg(k_raw_mgkg);    // now in cmol(+)/kg

    // ===== CALIBRATION EQUATIONS (Sensor -> Standard) =====
    float ec_std = 0.220636585f * ec_sensor + 0.06098882155f;   // dS/m
    float ph_std = 0.06749371859f * ph_sensor + 5.126893844f;   // pH
    float n_std  = 0.005542328042f * n_sensor  + 0.1148412698f; // %
    float p_std  = 0.0414315776f   * p_sensor  + 7.840383242f;  // mg/kg
    float k_std  = 0.3580341716f   * k_sensor  + 0.1642282588f; // cmol(+)/kg

    // ===== SERIAL OUTPUT =====
    Serial.println("==== SOIL (RAW -> CONVERTED -> CALIBRATED) ====");
    Serial.printf("Temp: %.1f C | Moist: %.1f %%\n", temp, moisture);
    Serial.printf("Salinity raw: %.0f | Salinity: %.1f\n", salinityRaw, salinity);
    Serial.printf("TDS: %.0f\n", tds);

    Serial.printf("EC raw: %.0f uS/cm | EC sensor: %.3f dS/m | EC std: %.3f dS/m\n",
                  ec_raw_uScm, ec_sensor, ec_std);

    Serial.printf("pH raw: %.2f | pH sensor: %.2f | pH std: %.2f\n",
                  ph_raw, ph_sensor, ph_std);

    Serial.printf("N raw: %.0f mg/kg | N sensor: %.4f %% | N std: %.4f %%\n",
                  n_raw_mgkg, n_sensor, n_std);

    Serial.printf("P raw: %.0f mg/kg | P sensor: %.2f mg/kg | P std: %.2f mg/kg\n",
                  p_raw_mgkg, p_sensor, p_std);

    Serial.printf("K raw: %.0f mg/kg | K sensor: %.3f cmol/kg | K std: %.3f cmol/kg\n",
                  k_raw_mgkg, k_sensor, k_std);

    Serial.println("================================================");

    // ===== TFT OUTPUT (organized table format) =====
    drawTftHead();
    drawTableHeader();
    drawTableSeparators();
    
    char rawStr[10], convStr[10], calibStr[10];
    
    // Temperature row
    snprintf(rawStr, sizeof(rawStr), "%.1f", temp);
    snprintf(convStr, sizeof(convStr), "-");
    snprintf(calibStr, sizeof(calibStr), "-");
    drawTableRow(0, "Temp", ST77XX_YELLOW, rawStr, convStr, calibStr);
    
    // Moisture row
    snprintf(rawStr, sizeof(rawStr), "%.1f", moisture);
    snprintf(convStr, sizeof(convStr), "-");
    snprintf(calibStr, sizeof(calibStr), "-");
    drawTableRow(1, "Moist", ST77XX_YELLOW, rawStr, convStr, calibStr);
    
    // Salinity row
    snprintf(rawStr, sizeof(rawStr), "%.0f", salinityRaw);
    snprintf(convStr, sizeof(convStr), "%.1f", salinity);
    snprintf(calibStr, sizeof(calibStr), "-");
    drawTableRow(2, "Salin", ST77XX_YELLOW, rawStr, convStr, calibStr);
    
    // TDS row
    snprintf(rawStr, sizeof(rawStr), "%.0f", tds);
    snprintf(convStr, sizeof(convStr), "-");
    snprintf(calibStr, sizeof(calibStr), "-");
    drawTableRow(3, "TDS", ST77XX_YELLOW, rawStr, convStr, calibStr);
    
    // EC row
    snprintf(rawStr, sizeof(rawStr), "%.0f", ec_raw_uScm);
    snprintf(convStr, sizeof(convStr), "%.2f", ec_sensor);
    snprintf(calibStr, sizeof(calibStr), "%.2f", ec_std);
    drawTableRow(4, "EC", ST77XX_WHITE, rawStr, convStr, calibStr);
    
    // pH row
    snprintf(rawStr, sizeof(rawStr), "%.1f", ph_raw);
    snprintf(convStr, sizeof(convStr), "%.1f", ph_sensor);
    snprintf(calibStr, sizeof(calibStr), "%.1f", ph_std);
    drawTableRow(5, "pH", ST77XX_WHITE, rawStr, convStr, calibStr);
    
    // N row
    snprintf(rawStr, sizeof(rawStr), "%.0f", n_raw_mgkg);
    snprintf(convStr, sizeof(convStr), "%.3f", n_sensor);
    snprintf(calibStr, sizeof(calibStr), "%.3f", n_std);
    drawTableRow(6, "N", ST77XX_WHITE, rawStr, convStr, calibStr);
    
    // P row
    snprintf(rawStr, sizeof(rawStr), "%.0f", p_raw_mgkg);
    snprintf(convStr, sizeof(convStr), "%.1f", p_sensor);
    snprintf(calibStr, sizeof(calibStr), "%.1f", p_std);
    drawTableRow(7, "P", ST77XX_WHITE, rawStr, convStr, calibStr);
    
    // K row
    snprintf(rawStr, sizeof(rawStr), "%.0f", k_raw_mgkg);
    snprintf(convStr, sizeof(convStr), "%.3f", k_sensor);
    snprintf(calibStr, sizeof(calibStr), "%.3f", k_std);
    drawTableRow(8, "K", ST77XX_WHITE, rawStr, convStr, calibStr);

    // ===== BLE OUTPUT (JSON for app) =====
    if (deviceConnected && (millis() - lastUpdateTime >= UPDATE_INTERVAL)) {
      char sensorData[512]; // Buffer for JSON string
      generateSensorDataJSON(
        sensorData,
        sizeof(sensorData),
        moisture,
        ec_raw_uScm, ec_sensor, ec_std,
        temp,
        ph_raw, ph_sensor, ph_std,
        n_raw_mgkg, n_sensor, n_std,
        p_raw_mgkg, p_sensor, p_std,
        k_raw_mgkg, k_sensor, k_std,
        salinityRaw, salinity, tds
      );

      pCharacteristic->setValue(sensorData);
      pCharacteristic->notify();

      Serial.print("Sent sensor data via BLE: ");
      Serial.println(sensorData);

      lastUpdateTime = millis();
    }

  } else {
    Serial.print("Modbus Error: ");
    Serial.println(result);
    
    // Display error on TFT
    drawTftHead();
    tft.setTextSize(1);
    tft.setTextColor(ST77XX_RED, ST77XX_BLACK);
    tft.setCursor(0, TABLE_HEADER_Y + 5);
    tft.print("Modbus Error");
    snprintf(line, sizeof(line), "Code: %d", result);
    tft.setCursor(0, TABLE_HEADER_Y + TABLE_ROW_H + 5);
    tft.print(line);
  }

  delay(1500);
}
