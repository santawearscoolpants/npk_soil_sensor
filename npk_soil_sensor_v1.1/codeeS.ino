#include <SPI.h>
#include <Adafruit_GFX.h>
#include <Adafruit_ST7735.h>
#include <Adafruit_ST77xx.h>
#include <ModbusMaster.h>
#include <WiFi.h>
#include "ThingSpeak.h"

// ============ TFT DISPLAY (same as your working code) ============
#define TFT_CS   5    // CS
#define TFT_DC   4    // A0 / DC
#define TFT_RST  2    // RESET pin of TFT

Adafruit_ST7735 tft = Adafruit_ST7735(TFT_CS, TFT_DC, TFT_RST);

const char* ssid = "DC_01";
const char* password = "!@insti_hpc";

WiFiClient  client;

unsigned long myChannelNumber = 3190911;       
const char * myWriteAPIKey = "KLXLH4XEA6YTYQ97";

// Timer variables
unsigned long lastTime = 0;
unsigned long timerDelay = 30000;


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

void setup() {
  Serial.begin(115200);
  delay(1000);

  WiFi.mode(WIFI_STA);   
  
  ThingSpeak.begin(client);  // Initialize ThingSpeak

  Serial.println("ESP32 + TFT + 7-in-1 NPK Sensor");

  // --- TFT setup (unchanged from your working code) ---
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

  Serial.println("Setup complete.");
}

void loop() {
  if ((millis() - lastTime) > timerDelay) {
    
    // Connect or reconnect to WiFi
    if(WiFi.status() != WL_CONNECTED){
      Serial.print("Attempting to connect");
      while(WiFi.status() != WL_CONNECTED){
        WiFi.begin(ssid, password); 
        delay(5000);     
      } 
      Serial.println("\nConnected.");
    }
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

    float moisture = raw[0] / 10.0;
    float temp     = toSigned(raw[1]) / 10.0;
    float ec       = raw[2];
    float ph       = raw[3] / 10.0;
    int   n        = raw[4];
    int   p        = raw[5];
    int   k        = raw[6];
    int   sal      = raw[7];
    int   tds      = raw[8];

     // set the fields with the values
    ThingSpeak.setField(1, temp);
    ThingSpeak.setField(2, moisture);
    ThingSpeak.setField(3, ec);
    ThingSpeak.setField(4, ph);
    ThingSpeak.setField(5, n);
    ThingSpeak.setField(6, p);
    ThingSpeak.setField(7, k);
    ThingSpeak.setField(8, sal);

    // Write to ThingSpeak.
    // pieces of information in a channel.  Here, we write to field 1.
    int x = ThingSpeak.writeFields(myChannelNumber, myWriteAPIKey);


    if(x == 200){
      Serial.println("Channel update successful.");
    }
    else{
      Serial.println("Problem updating channel. HTTP error code " + String(x));
    }
    lastTime = millis();


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
    tft.printf("Sal:    %d\n", sal);
    tft.printf("TDS:    %d\n", tds);

  } else {
    Serial.print("❌ Modbus Error: ");
    Serial.println(result);

    tft.setTextColor(ST77XX_RED);
    tft.println("Modbus Error");
    tft.printf("Code: %d\n", result);
  }

  delay(1500);
}
}