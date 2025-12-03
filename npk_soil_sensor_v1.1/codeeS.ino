#include <ModbusMaster.h>

// === RS485 control (MAX485) ===
#define RE_DE_PIN 4
#define RS485_RX 17
#define RS485_TX 16

#define MODBUS_SLAVE_ID 1
#define BAUD_RATE 4800

HardwareSerial RS485Serial(1);
ModbusMaster node;

// Convert unsigned to signed
int16_t toSigned(uint16_t v) {
  return (v & 0x8000) ? (v - 65536) : v;
}

// RS485 control functions
void preTransmission() { digitalWrite(RE_DE_PIN, HIGH); }
void postTransmission() { digitalWrite(RE_DE_PIN, LOW); }

void setup() {
  Serial.begin(115200);
  delay(1000);

  Serial.println("=== RS485 Soil Sensor Monitor ===");

  // RS485 Driver Control
  pinMode(RE_DE_PIN, OUTPUT);
  digitalWrite(RE_DE_PIN, LOW);

  // RS485 Serial
  RS485Serial.begin(BAUD_RATE, SERIAL_8N1, RS485_RX, RS485_TX);

  // Modbus
  node.begin(MODBUS_SLAVE_ID, RS485Serial);
  node.preTransmission(preTransmission);
  node.postTransmission(postTransmission);

  Serial.println("Setup complete.\n");
}

void loop() {
  uint8_t result = node.readHoldingRegisters(0x0000, 9); // read 9 registers

  if (result == node.ku8MBSuccess) {
    uint16_t raw[9];
    for (int i = 0; i < 9; i++) raw[i] = node.getResponseBuffer(i);

    float moisture = raw[0] / 10.0;
    float temp     = toSigned(raw[1]) / 10.0;
    float ec       = raw[2];
    float ph       = raw[3] / 10.0;
    int   n        = raw[4];
    int   p        = raw[5];
    int   k        = raw[6];
    int   sal      = raw[7];
    int   tds      = raw[8];

    // ---- Serial Output ----
    Serial.println("===== Soil Sensor Data =====");
    Serial.printf("Temperature : %.1f C\n", temp);
    Serial.printf("Moisture    : %.1f %%\n", moisture);
    Serial.printf("EC          : %.0f\n", ec);
    Serial.printf("pH          : %.1f\n", ph);
    Serial.printf("Nitrogen    : %d\n", n);
    Serial.printf("Phosphorus  : %d\n", p);
    Serial.printf("Potassium   : %d\n", k);
    Serial.printf("Salinity    : %d\n", sal);
    Serial.printf("TDS         : %d\n", tds);
    Serial.println("----------------------------");

  } else {
    Serial.print("❌ Modbus Error: ");
    Serial.println(result);
  }

  delay(1500);
}