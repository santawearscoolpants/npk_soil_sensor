## 7-in-1 NPK Soil Sensor Project

This repository contains Arduino sketches for reading a **7‑in‑1 NPK soil sensor** over RS485/Modbus and (optionally) displaying the values on a small TFT screen.

The typical sensor exposes:
- **Soil moisture**
- **Temperature**
- **Electrical conductivity (EC)**
- **pH**
- **Nitrogen (N)**
- **Phosphorus (P)**
- **Potassium (K)**
- **Salinity**
- **TDS**

The sketches here are intended as a solid starting point for experiments and integration into larger projects.

---

## Repository structure

- `Soil_Sensor_esp32/soil_sensor_esp32.ino`  
  ESP32 sketch that communicates with the soil sensor via RS485 using **Modbus RTU** and prints raw and parsed values to the serial monitor.

- `tft_display/tft_display.ino`  
  Arduino sketch for a small **ST7735**-based TFT display. Currently shows demo text and placeholders where soil sensor readings can be rendered later.

- `tft_npk_esp32_final_v1.0/reading_display.ino`  
  ESP32 sketch that **reads the RS485 soil sensor and paints the live values on the 1.8" ST7735 TFT**. Ideal when you only need a local display.

- `npk_soil_sensor_v1.1/codeeS.ino`  
  ESP32 sketch that combines **Modbus sensor reads, TFT rendering, Wi‑Fi connectivity, and ThingSpeak uploads**.

- `7in1_Soil_sensor_arduino/7in1_Soil_sensor.ino`  
  Additional/earlier Arduino sketch for this sensor (kept for reference or alternative boards).

---

## Hardware used

### Microcontrollers
- **ESP32** (tested with an ESP32 DevKit‑style board) for `Soil_Sensor_esp32.ino`.
- **Arduino‑compatible board** (e.g. Uno / Nano) for `tft_display.ino` and `7in1_Soil_sensor_arduino.ino`.

### Soil sensor
- Halisense 7‑in‑1 RS485 **NPK soil sensor** (Modbus RTU).

### RS485 interface
- Typical **MAX485 / SP3485** RS485‑to‑TTL module.

### Display
- **1.8\" ST7735 TFT** display (128×160), using `Adafruit_GFX` and `Adafruit_ST7735` libraries.

---

## Wiring
- [Full wiring diagram (Cirkit Designer project)](https://app.cirkitdesigner.com/project/8f170237-9afc-4cfa-946d-e55d664006a7)

### ESP32 ⇄ RS485 module ⇄ Soil sensor

The ESP32 sketch `Soil_Sensor_esp32.ino` expects the following pins:

- **RE/DE (RS485 direction control)** → ESP32 pin `22` (`RE_DE_PIN`)
- **RO (RS485 RX)** → ESP32 pin `17` (`RS485_RX`)
- **DI (RS485 TX)** → ESP32 pin `16` (`RS485_TX`)
- **VCC / GND** of the RS485 module → ESP32 `3V3`/`5V` (depending on module) and `GND`
- **A / B** lines of RS485 module → A / B lines of the soil sensor
- Soil sensor power supply as specified by the sensor (often 12 V); **do not power it directly from the ESP32 5 V pin unless your sensor explicitly supports that.**

Make sure **A ↔ A** and **B ↔ B** are matched between the RS485 module and the sensor.

---

### Arduino ⇄ ST7735 TFT display

For `tft_display.ino` the following pins are used (as typical for an Arduino Uno):

- **TFT_CS** → Arduino D5 (`#define TFT_CS 5`)
- **TFT_DC** → Arduino D4 (`#define TFT_DC 4`)
- **TFT_RST** → tied to MCU RESET (sketch uses `-1` for reset pin)
- **MOSI** → Arduino D11 (hardware SPI)
- **SCK**  → Arduino D13 (hardware SPI)
- **VCC / GND** → 5 V / GND (or 3.3 V depending on your specific display)

Check your specific display’s documentation for any voltage‑level requirements.

---

## Sketch details

### `Soil_Sensor_esp32/soil_sensor_esp32.ino`

Key points:
- Uses **`ModbusMaster`** and an **RS485Serial** hardware UART on the ESP32.
- Configures:
  - Modbus slave ID: `1` (`MODBUS_SLAVE_ID`)
  - Baud rate: `4800` (`BAUD_RATE`)
- On each loop it:
  1. Performs `node.readHoldingRegisters(0x0000, 9)` to read 9 registers starting at address `0x0000`.
  2. Prints all 9 **raw register** values.
  3. Converts these registers into human‑readable measurements:
     - Moisture, temperature, pH with proper scaling
     - EC, N, P, K, salinity, TDS as integer values
  4. Prints parsed values to the serial monitor every ~1.5 seconds.

This sketch is ideal to:
- **Verify wiring and Modbus configuration**
- Understand the **register mapping** used by your particular sensor
- Serve as a base for integrating the sensor into other projects.

#### Serial output example

You should see output similar to:

- A block of `RAW REGISTERS` with `Reg[0]`…`Reg[8]`
- A `PARSED VALUES` block showing temperature (°C), moisture (%), EC, pH, N, P, K, salinity, and TDS.

If you only see **Modbus Error codes**, double‑check:
- RS485 wiring (A/B swapped?)
- Sensor power and common ground
- Slave address and baud rate

---

### `tft_display/tft_display.ino`

Key points:
- Uses `Adafruit_GFX`, `Adafruit_ST7735`, and `Adafruit_ST77xx`.
- Initializes the display with `tft.initR(INITR_BLACKTAB);` and `tft.setRotation(1);`.
- Currently prints:
  - “Hello World!”
  - Some demo numeric and hex output
  - Sample text (e.g. “Soil Sensor Readings”, “Temp:”, “Hum:”, “N:”, “P:”, “K:”, “Cond:”).

This sketch is a **template** for a UI:
- You can replace the dummy values and labels with **live values** from the soil sensor once you combine the sensor‑reading code and display code on the same board.

---

### `tft_npk_esp32_final_v1.0/reading_display.ino`

Key points:
- Runs entirely on an **ESP32**, so it can talk to the RS485 sensor and draw the values on the **ST7735** without a second MCU.
- Uses the same SPI pinout as `tft_display.ino` for the screen and `RE_DE_PIN = 21`, `RS485_RX = 17`, `RS485_TX = 16` for the MAX485 interface.
- Each loop reads 9 Modbus registers, scales them into human‑readable units, prints them to `Serial`, and refreshes the TFT screen.
- Displays clear labels for Temp, Moisture, EC, pH, N, P, K, Salinity, and TDS, plus a red error banner if the Modbus transaction fails.

Use it when you want a **stand‑alone ESP32 + TFT** dashboard without cloud publishing.

---

### `npk_soil_sensor_v1.1/codeeS.ino`

Key points:
- Builds on the previous ESP32 display sketch but also connects to Wi‑Fi and **pushes the readings to ThingSpeak**.
- Keeps the TFT UI identical (same pinout, fonts, and layout) so you get both a local dashboard and a cloud feed.
- Includes a `timerDelay` (30 s by default) to throttle uploads and automatically reconnects to Wi‑Fi if the link drops.
- Uses `ThingSpeak.setField()` for Temp, Moisture, EC, pH, N, P, K, and Salinity before `ThingSpeak.writeFields()`. TDS stays local-only, but you can map it to another channel if needed.
- Serial output mirrors what’s shown on the screen so debugging stays straightforward.

Use it when you need **local visualization + remote logging**.

---

## How to use

### 1. Read soil sensor values with ESP32

1. Open `Soil_Sensor_esp32/soil_sensor_esp32.ino` in the Arduino IDE or PlatformIO.
2. Install the `ModbusMaster` library (via Library Manager or manually).
3. Select your ESP32 board and the correct serial port.
4. Flash the sketch.
5. Open the **Serial Monitor** at **115200 baud**.
6. Verify that raw registers and parsed values are printed without errors.

---

### 2. Test the TFT display

1. Wire the ST7735 TFT to your Arduino as described above.
2. Open `tft_display/tft_display.ino`.
3. Install `Adafruit_GFX`, `Adafruit_ST7735`, and `Adafruit_ST77xx` libraries.
4. Select the correct board/port and upload.
5. Confirm that the demo text and numbers are displayed.

---

### 3. Combining sensor and display (next steps)

This repository currently keeps:
- Sensor reading (ESP32) and
- Display demo (Arduino)

in **separate sketches** for clarity.

To build a full system that **reads the sensor and shows live values on the TFT**:
- Choose a single MCU platform (ESP32 is often convenient for the Modbus side).
- Merge:
  - The Modbus code from `soil_sensor_esp32.ino`.
  - The display code from `tft_display.ino`.
- Update pin definitions to match your chosen board.
- Replace the placeholder display text with actual measured values.

---

## Troubleshooting

- **No sensor data / Modbus errors**
  - Check sensor power and required voltage.
  - Confirm RS485 A/B lines are not swapped.
  - Ensure common ground between all modules.
  - Verify Modbus address, baud rate, and parity match your sensor’s documentation.

- **Garbled serial output**
  - Check that the Serial Monitor baud rate is set to **115200** (for the ESP32 sketch).

- **Blank or white TFT screen**
  - Double‑check the SPI pins and CS/DC assignments.
  - Verify you are using the correct `initR()` variant for your display (e.g. `INITR_BLACKTAB`).
  - Make sure the display is powered with correct voltage and has a common ground with the MCU.

---

## License

If you plan to publish this project publicly, you can add your preferred license here (e.g. MIT). For now, treat this as open example code for experimentation and learning unless otherwise specified.


