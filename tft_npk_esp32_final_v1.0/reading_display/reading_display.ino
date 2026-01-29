#include <SPI.h>
#include <Adafruit_GFX.h>
#include <Adafruit_ST7735.h>
#include <Adafruit_ST77xx.h>
#include <ModbusMaster.h>

// ============ TFT DISPLAY (same as your working code) ============
#define TFT_CS   5    // CS
#define TFT_DC   4    // A0 / DC
#define TFT_RST  2    // RESET pin of TFT

Adafruit_ST7735 tft = Adafruit_ST7735(TFT_CS, TFT_DC, TFT_RST);

// ============ RS485 / NPK SENSOR ================================
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

// ============ UNIT CONVERSIONS (EC, N, K) =======================
// EC: 1 dS/m = 1000 uS/cm
static inline float ec_uScm_to_dSm(float ec_uScm) {
  return ec_uScm / 1000.0f;
}

// Total N: 1% = 10,000 mg/kg (unit conversion only)
// NOTE: Lab TN% is "total N". Sensor N mg/kg is usually "available N estimate".
// Converting units does NOT make them chemically identical.
static inline float n_mgkg_to_percent(float n_mgkg) {
  return n_mgkg / 10000.0f;
}
static inline float tn_percent_to_mgkg(float tn_percent) {
  return tn_percent * 10000.0f;
}

// Potassium: mg/kg <-> cmol(+)/kg
// cmol(+)/kg = (mg/kg) / (atomic_weight * 10) for K+
// atomic weight K = 39.10, charge = 1
static inline float k_mgkg_to_cmolkg(float k_mgkg) {
  return k_mgkg / (39.10f * 10.0f);
}
static inline float k_cmolkg_to_mgkg(float k_cmolkg) {
  return k_cmolkg * (39.10f * 10.0f);
}

void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.println("ESP32 + TFT + 7-in-1 NPK Sensor");

  // --- TFT setup (unchanged from your working code) ---
  SPI.begin();  // VSPI: SCK=18, MISO=19, MOSI=23

  tft.initR(INITR_BLACKTAB);
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
  digitalWrite(RE_DE_PIN, LOW);

  RS485Serial.begin(BAUD_RATE, SERIAL_8N1, RS485_RX, RS485_TX);

  node.begin(MODBUS_SLAVE_ID, RS485Serial);
  node.preTransmission(preTransmission);
  node.postTransmission(postTransmission);

  Serial.println("Setup complete.");
}

void loop() {
  // Read 9 holding registers starting at 0x0000
  uint8_t result = node.readHoldingRegisters(0x0000, 9);

  tft.fillScreen(ST77XX_BLACK);
  tft.setCursor(0, 0);
  tft.setTextSize(1);

  if (result == node.ku8MBSuccess) {
    uint16_t raw[9];
    for (int i = 0; i < 9; i++) {
      raw[i] = node.getResponseBuffer(i);
    }

    float moisture = raw[0] / 10.0f;
    float temp     = toSigned(raw[1]) / 10.0f;

    // Sensor EC is typically in uS/cm (raw number)
    float ec_uScm   = (float)raw[2];
    float ec_dSm    = ec_uScm_to_dSm(ec_uScm);

    float ph        = raw[3] / 10.0f;

    // Sensor N, P, K usually in mg/kg (ppm)
    float n_mgkg    = (float)raw[4];
    float p_mgkg    = (float)raw[5];
    float k_mgkg    = (float)raw[6];

    // Optional unit-only conversion to percent
    float n_percent_equiv = n_mgkg_to_percent(n_mgkg);

    // Convert K mg/kg -> cmol(+)/kg to match lab report exchangeable K unit
    float k_cmolkg  = k_mgkg_to_cmolkg(k_mgkg);

    int   sal       = raw[7];
    int   tds       = raw[8];

    // ---- Serial Output ----
    Serial.println("===== Soil Sensor Data =====");
    Serial.printf("Temperature : %.1f C\n", temp);
    Serial.printf("Moisture    : %.1f %%\n", moisture);

    // EC in both units
    Serial.printf("EC          : %.0f uS/cm  |  %.3f dS/m\n", ec_uScm, ec_dSm);

    Serial.printf("pH          : %.1f\n", ph);

    // N in mg/kg (sensor) + percent (unit-equivalent only)
    Serial.printf("Nitrogen    : %.0f mg/kg  |  %.4f %% (unit-equiv)\n", n_mgkg, n_percent_equiv);

    // K in mg/kg (sensor) + cmol(+)/kg (lab-style unit)
    Serial.printf("Potassium   : %.0f mg/kg  |  %.3f cmol(+)/kg\n", k_mgkg, k_cmolkg);

    // leave P raw in mg/kg since lab uses mg/kg for available P (not cmol)
    Serial.printf("Phosphorus  : %.0f mg/kg\n", p_mgkg);

    Serial.printf("Salinity    : %d\n", sal);
    Serial.printf("TDS         : %d\n", tds);
    Serial.println("----------------------------");

    // ---- TFT Output ----
    tft.setTextColor(ST77XX_GREEN);
    tft.println("Soil Sensor Readings");

    tft.setTextColor(ST77XX_WHITE);
    tft.printf("Temp: %.1f C\n", temp);
    tft.printf("Moist: %.1f %%\n", moisture);

    // Show EC converted to dS/m (lab unit)
    tft.printf("EC: %.3f dS/m\n", ec_dSm);

    tft.printf("pH: %.1f\n", ph);

    // Show N as mg/kg (sensor)
    tft.printf("N: %.0f mg/kg\n", n_mgkg);

    // Show K in lab unit
    tft.printf("K: %.3f cmol/kg\n", k_cmolkg);

    tft.printf("Sal: %d\n", sal);
    tft.printf("TDS: %d\n", tds);

  } else {
    Serial.print("Modbus Error: ");
    Serial.println(result);

    tft.setTextColor(ST77XX_RED);
    tft.println("Modbus Error");
    tft.printf("Code: %d\n", result);
  }

  delay(1500);
}
