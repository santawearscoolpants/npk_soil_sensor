#include <SPI.h>
#include <Adafruit_GFX.h>
#include <Adafruit_ST7735.h>
#include <Adafruit_ST77xx.h>
#include <ModbusMaster.h>

// ============ TFT DISPLAY ============
#define TFT_CS   5
#define TFT_DC   4
#define TFT_RST  2
Adafruit_ST7735 tft = Adafruit_ST7735(TFT_CS, TFT_DC, TFT_RST);

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

void setup() {
  Serial.begin(115200);
  delay(1000);

  SPI.begin();
  tft.initR(INITR_BLACKTAB);
  tft.setRotation(1);

  tft.fillScreen(ST77XX_BLACK);
  tft.setTextColor(ST77XX_WHITE);
  tft.setCursor(0, 0);
  tft.setTextSize(1);
  tft.println("Soil Sensor Boot");

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

  tft.fillScreen(ST77XX_BLACK);
  tft.setCursor(0, 0);
  tft.setTextSize(1);

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

    // ===== TFT OUTPUT (show calibrated “Standard”) =====
    tft.setTextColor(ST77XX_GREEN);
    tft.println("Calibrated (Std)");

    tft.setTextColor(ST77XX_WHITE);
    tft.printf("EC: %.3f dS/m\n", ec_std);
    tft.printf("pH: %.2f\n", ph_std);
    tft.printf("N:  %.4f %%\n", n_std);
    tft.printf("P:  %.1f mg/kg\n", p_std);
    tft.printf("K:  %.3f cmol/kg\n", k_std);

  } else {
    Serial.print("Modbus Error: ");
    Serial.println(result);

    tft.setTextColor(ST77XX_RED);
    tft.println("Modbus Error");
    tft.printf("Code: %d\n", result);
  }

  delay(1500);
}
