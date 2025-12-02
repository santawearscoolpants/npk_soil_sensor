#include <SoftwareSerial.h>

// Pin definitions for Arduino Uno R3.
const uint8_t RE_DE_PIN = 4;      // Controls RS485 direction (HIGH = transmit).
const uint8_t RS485_RX_PIN = 10;  // Connect to RO on MAX485.
const uint8_t RS485_TX_PIN = 11;  // Connect to DI on MAX485.

SoftwareSerial rs485(RS485_RX_PIN, RS485_TX_PIN);

// Modbus request frames (address 0x01, function 0x03) + CRC16.
const byte humi[]  = {0x01, 0x03, 0x00, 0x00, 0x00, 0x01, 0x84, 0x0A};
const byte temp[]  = {0x01, 0x03, 0x00, 0x01, 0x00, 0x01, 0xD5, 0xCA};
const byte cond[]  = {0x01, 0x03, 0x00, 0x02, 0x00, 0x01, 0x25, 0xCA};
const byte phph[]  = {0x01, 0x03, 0x00, 0x03, 0x00, 0x01, 0x74, 0x0A};
const byte nitro[] = {0x01, 0x06, 0x00, 0x04, 0x00, 0x20, 0xC9, 0xD3};
const byte phos[]  = {0x01, 0x06, 0x00, 0x05, 0x00, 0x58, 0x98, 0x31};
const byte pota[]  = {0x01, 0x03, 0x00, 0x06, 0x00, 0x68, 0x68, 0x25};


const uint8_t RESPONSE_BYTES = 7;
const unsigned long RESPONSE_TIMEOUT_MS = 200;
const unsigned long SAMPLE_INTERVAL_MS = 2000;

uint8_t response[RESPONSE_BYTES];

bool querySensor(const byte *frame, size_t length, uint16_t &rawValue) {
  digitalWrite(RE_DE_PIN, HIGH);
  delayMicroseconds(100);
  rs485.write(frame, length);
  rs485.flush();
  digitalWrite(RE_DE_PIN, LOW);

  memset(response, 0, sizeof(response));
  uint8_t index = 0;
  const unsigned long start = millis();

  while (index < RESPONSE_BYTES && (millis() - start) < RESPONSE_TIMEOUT_MS) {
    if (rs485.available()) {
      response[index++] = rs485.read();
    }
  }

  if (index < 5) {
    return false; // Not enough data for a valid response.
  }

  rawValue = (static_cast<uint16_t>(response[3]) << 8) | response[4];
  return true;
}

float readSensorValue(const char *label,
                      const byte *frame,
                      size_t length,
                      float scale,
                      const char *unit) {
  uint16_t raw = 0;
  if (!querySensor(frame, length, raw)) {
    Serial.print(label);
    Serial.println(" -> no response");
    return NAN;
  }

  const float value = raw * scale;
  Serial.print(label);
  Serial.print(": ");
  Serial.print(value, (scale < 1.0f) ? 1 : 0);
  if (unit != nullptr) {
    Serial.print(' ');
    Serial.print(unit);
  }
  Serial.println();
  return value;
}

void setup() {
  Serial.begin(9600);
  while (!Serial) {
    ; // Wait for USB serial to come up on Leonardo-style boards.
  }

  rs485.begin(4800); // Soil sensor uses 4800 bps.
  pinMode(RE_DE_PIN, OUTPUT);
  digitalWrite(RE_DE_PIN, LOW); // Start in receive mode.

  Serial.println(F("Sensor Readings"));
  Serial.println(F("------------------------------------------------"));
}

void loop() {
  readSensorValue("Humidity",     humi,  sizeof(humi),  0.1f, "%");
  readSensorValue("Temperature",  temp,  sizeof(temp),  0.1f, "C");
  readSensorValue("Conductivity", cond,  sizeof(cond),  1.0f, "uS/cm");
  readSensorValue("pH",           phph,  sizeof(phph),  0.1f, nullptr);
  readSensorValue("Nitrogen",     nitro, sizeof(nitro), 1.0f, "mg/L");
  readSensorValue("Phosphorus",   phos,  sizeof(phos),  1.0f, "mg/L");
  readSensorValue("Potassium",    pota,  sizeof(pota),  1.0f, "mg/L");

  Serial.println();
  delay(SAMPLE_INTERVAL_MS);
}