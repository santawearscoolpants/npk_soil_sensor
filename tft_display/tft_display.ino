#include <SPI.h>
#include <Adafruit_GFX.h>
#include <Adafruit_ST7735.h>
#include <Adafruit_ST77xx.h>

// Pins for ESP32
#define TFT_CS   5    // CS
#define TFT_DC   4    // A0 / DC
#define TFT_RST  2    // RESET pin of TFT (or -1 if tied to EN)

// Hardware SPI (on ESP32 VSPI: SCK=18, MOSI=23 by default)
Adafruit_ST7735 tft = Adafruit_ST7735(TFT_CS, TFT_DC, TFT_RST);

void setup() {
  SPI.begin();  // uses default VSPI pins: SCK=18, MISO=19, MOSI=23

  // Try different tab types here if needed:
  tft.initR(INITR_BLACKTAB);  
  // tft.initR(INITR_REDTAB);
  // or:
  // tft.initR(INITR_GREENTAB);

  tft.setRotation(1);

  // Color test: if this works, wiring+init are OK
  tft.fillScreen(ST77XX_RED);
  delay(500);
  tft.fillScreen(ST77XX_GREEN);
  delay(500);
  tft.fillScreen(ST77XX_BLUE);
  delay(500);
  tft.fillScreen(ST77XX_BLACK);
}

void loop() {
  tft.fillScreen(ST77XX_BLACK);

  tft.setCursor(0, 0);
  tft.setTextColor(ST77XX_WHITE);
  tft.setTextSize(1);
  tft.println("Hello World!");

  tft.setTextColor(ST77XX_YELLOW);
  tft.setTextSize(2);
  tft.println(1234.56);

  tft.setTextColor(ST77XX_RED);
  tft.setTextSize(3);
  tft.println(0xDEADBEEF, HEX);
  tft.println();

  tft.setTextColor(ST77XX_GREEN);
  tft.setTextSize(5);
  tft.println("CSRI");

  tft.setTextSize(2);
  tft.println("INSTI,");

  tft.setTextSize(1);
  tft.println("Soil Sensor Readings");
  tft.println("Temp: ");
  tft.println("Hum: ");
  tft.println("N: ");
  tft.println("P: ");
  tft.println("K: ");
  tft.println("Cond: ");

  delay(1000);
}
