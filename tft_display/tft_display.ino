

#include <SPI.h>
#include <Adafruit_GFX.h>
#include <Adafruit_ST7735.h>
#include <Adafruit_ST77xx.h>

// Matches the existing wiring on the ILI9341 setup.
#define TFT_DC 4
#define TFT_CS 5
#define TFT_RST -1  // Tie RESET to MCU reset if you don't have a spare pin.

// Use hardware SPI (MOSI=11, SCLK=13 on Uno) plus the control pins above.
Adafruit_ST7735 tft = Adafruit_ST7735(TFT_CS, TFT_DC, TFT_RST);

void setup() {
  //Serial.begin(9600);
  //Serial.println("ILI9341 Test!"); 
 
  tft.initR(INITR_BLACKTAB);  // Initialize the 1.8" 128x160 panel
  tft.setRotation(1);
  tft.fillScreen(ST77XX_BLACK);

}

void loop(void) {

  tft.setCursor(0, 0);
  tft.setTextColor(ST77XX_WHITE);  tft.setTextSize(1);
  tft.println("Hello World!");
  tft.setTextColor(ST77XX_YELLOW); tft.setTextSize(2);
  tft.println(1234.56);
  tft.setTextColor(ST77XX_RED);    tft.setTextSize(3);
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

}



