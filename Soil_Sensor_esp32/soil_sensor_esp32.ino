#include <ModbusMaster.h>

// === RS485 control (MAX485) ===
#define RE_DE_PIN 22
#define RS485_RX 17
#define RS485_TX 16

#define MODBUS_SLAVE_ID 1
#define BAUD_RATE 4800

HardwareSerial RS485Serial(1);
ModbusMaster node;

int16_t toSigned(uint16_t v) {
  return (v & 0x8000) ? (v - 65536) : v;
}

void preTransmission() {
  digitalWrite(RE_DE_PIN, HIGH);
}

void postTransmission() {
  digitalWrite(RE_DE_PIN, LOW);
}

void setup() {
  Serial.begin(115200);
  delay(1000);

  Serial.println("=== RS485 Soil Sensor RAW Test ===");

  pinMode(RE_DE_PIN, OUTPUT);
  digitalWrite(RE_DE_PIN, LOW);

  RS485Serial.begin(BAUD_RATE, SERIAL_8N1, RS485_RX, RS485_TX);

  node.begin(MODBUS_SLAVE_ID, RS485Serial);
  node.preTransmission(preTransmission);
  node.postTransmission(postTransmission);

  Serial.println("Setup complete.\n");
}

void loop() {

  uint8_t result = node.readHoldingRegisters(0x0000, 9);

  if (result == node.ku8MBSuccess) {

    uint16_t raw[9];
    for (int i = 0; i < 9; i++) {
      raw[i] = node.getResponseBuffer(i);
    }

    Serial.println("===== RAW REGISTERS =====");
    for (int i = 0; i < 9; i++) {
      Serial.print("Reg[");
      Serial.print(i);
      Serial.print("] = ");
      Serial.println(raw[i]);
    }

    float moisture = raw[0] / 10.0;
    float temp     = toSigned(raw[1]) / 10.0;
    float ec       = raw[2];
    float ph       = raw[3] / 10.0;
    int   n        = raw[4];
    int   p        = raw[5];
    int   k        = raw[6];
    int   sal      = raw[7];
    int   tds      = raw[8];

    Serial.println("===== PARSED VALUES =====");
    Serial.print("Temperature : "); Serial.print(temp); Serial.println(" C");
    Serial.print("Moisture    : "); Serial.print(moisture); Serial.println(" %");
    Serial.print("EC          : "); Serial.println(ec);
    Serial.print("pH          : "); Serial.println(ph);
    Serial.print("Nitrogen    : "); Serial.println(n);
    Serial.print("Phosphorus  : "); Serial.println(p);
    Serial.print("Potassium   : "); Serial.println(k);
    Serial.print("Salinity    : "); Serial.println(sal);
    Serial.print("TDS         : "); Serial.println(tds);

  } 
  else {
    Serial.print(" Modbus Error: ");
    Serial.println(result);
  }

  Serial.println("----------------------------");
  delay(1500);   // 
}