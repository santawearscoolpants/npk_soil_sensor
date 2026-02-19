#include <SPI.h>
#include <Adafruit_GFX.h>
#include <Adafruit_ST7735.h>
#include <Adafruit_ST77xx.h>
#include <ModbusMaster.h>

// ============ TFT DISPLAY ============
#define TFT_CS   5
#define TFT_DC   27
#define TFT_RST  26  
#define TFT_SCLK 18
#define TFT_MISO 19
#define TFT_MOSI 23
#define TFT_INITR_TAB INITR_BLACKTAB

#define TFT_DATA_Y 14
#define TFT_LINE_H 14
Adafruit_ST7735 tft = Adafruit_ST7735(TFT_CS, TFT_DC, TFT_RST);

// Table layout constants
#define TABLE_START_Y 20
#define TABLE_HEADER_Y 20
#define TABLE_ROW_H 11
#define TABLE_COL1_X 0      // Parameter name (width: 35px)
#define TABLE_COL2_X 35     // RAW value (width: 40px)
#define TABLE_COL3_X 75     // CONV value (width: 40px)
#define TABLE_COL4_X 115    // CALIB value (width: 45px)
#define TABLE_COL_WIDTH 40

// ============ RS485 / NPK SENSOR =====
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

// N: % <-> mg/kg (unit-equivalent only)
static inline float n_mgkg_to_percent(float n_mgkg) {
  return n_mgkg / 10000.0f;
}

// K: mg/kg -> cmol(+)/kg for K+
// cmol(+)/kg = mg/kg / (39.10 * 10) = mg/kg / 391
static inline float k_mgkg_to_cmolkg(float k_mgkg) {
  return k_mgkg / 391.0f;
}

// Custom dark green color for table separators (RGB565: 0x03E0)
#define DARK_GREEN 0x03E0

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
  tft.println("LSACROFT SOIL SENSOR");
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
  
  // Draw parameter name (left column) - right-aligned for consistency
  tft.setTextColor(color, ST77XX_BLACK);
  tft.setCursor(TABLE_COL1_X + 2, y + 2);
  tft.print(paramName);
  
  // Draw RAW value - right-aligned
  tft.setCursor(TABLE_COL2_X + 2, y + 2);
  tft.print(rawVal);
  
  // Draw CONV value - right-aligned
  tft.setCursor(TABLE_COL3_X + 2, y + 2);
  tft.print(convVal);
  
  // Draw CALIB value - right-aligned
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

void setup() {
  Serial.begin(115200);
  delay(1000);

  // Explicit ESP32 VSPI pin mapping avoids board-default mismatches.
  SPI.begin(TFT_SCLK, TFT_MISO, TFT_MOSI, TFT_CS);
  tft.initR(TFT_INITR_TAB);
  tft.setRotation(1);
  tft.setTextWrap(false);

  // Boot color sweep verifies TFT init visually.
  tft.fillScreen(ST77XX_RED);
  delay(200);
  tft.fillScreen(ST77XX_GREEN);
  delay(200);
  tft.fillScreen(ST77XX_BLUE);
  delay(200);

  // Display boot message
  drawTftHead();
  tft.setTextSize(1);
  tft.setTextColor(ST77XX_WHITE, ST77XX_BLACK);
  tft.setCursor(0, TABLE_HEADER_Y + 5);
  tft.print("Booting sensor...");

  pinMode(RE_DE_PIN, OUTPUT);
  digitalWrite(RE_DE_PIN, LOW);

  RS485Serial.begin(BAUD_RATE, SERIAL_8N1, RS485_RX, RS485_TX);

  node.begin(MODBUS_SLAVE_ID, RS485Serial);
  node.preTransmission(preTransmission);
  node.postTransmission(postTransmission);

  Serial.println("System Ready");
}

void loop() {
  uint8_t result = node.readHoldingRegisters(0x0000, 9);
  char line[48];
  clearTftDataArea();

  if (result == node.ku8MBSuccess) {
    uint16_t raw[9];
    for (int i = 0; i < 9; i++) raw[i] = node.getResponseBuffer(i);

    float moisture = raw[0] / 10.0f;
    float temp     = toSigned(raw[1]) / 10.0f;

    // ---- RAW SENSOR VALUES (as read) ----
    float ec_raw_uScm = (float)raw[2];      // typically µS/cm
    float ph_raw      = raw[3] / 10.0f;     // pH
    float n_raw_mgkg  = (float)raw[4];      // mg/kg (sensor claim)
    float p_raw_mgkg  = (float)raw[5];      // mg/kg
    float k_raw_mgkg  = (float)raw[6];      // mg/kg

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
    
    // EC row
    snprintf(rawStr, sizeof(rawStr), "%.0f", ec_raw_uScm);
    snprintf(convStr, sizeof(convStr), "%.2f", ec_sensor);
    snprintf(calibStr, sizeof(calibStr), "%.2f", ec_std);
    drawTableRow(2, "EC", ST77XX_WHITE, rawStr, convStr, calibStr);
    
    // pH row
    snprintf(rawStr, sizeof(rawStr), "%.1f", ph_raw);
    snprintf(convStr, sizeof(convStr), "%.1f", ph_sensor);
    snprintf(calibStr, sizeof(calibStr), "%.1f", ph_std);
    drawTableRow(3, "pH", ST77XX_WHITE, rawStr, convStr, calibStr);
    
    // N row
    snprintf(rawStr, sizeof(rawStr), "%.0f", n_raw_mgkg);
    snprintf(convStr, sizeof(convStr), "%.3f", n_sensor);
    snprintf(calibStr, sizeof(calibStr), "%.3f", n_std);
    drawTableRow(4, "N", ST77XX_WHITE, rawStr, convStr, calibStr);
    
    // P row
    snprintf(rawStr, sizeof(rawStr), "%.0f", p_raw_mgkg);
    snprintf(convStr, sizeof(convStr), "%.1f", p_sensor);
    snprintf(calibStr, sizeof(calibStr), "%.1f", p_std);
    drawTableRow(5, "P", ST77XX_WHITE, rawStr, convStr, calibStr);
    
    // K row
    snprintf(rawStr, sizeof(rawStr), "%.0f", k_raw_mgkg);
    snprintf(convStr, sizeof(convStr), "%.3f", k_sensor);
    snprintf(calibStr, sizeof(calibStr), "%.3f", k_std);
    drawTableRow(6, "K", ST77XX_WHITE, rawStr, convStr, calibStr);

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
