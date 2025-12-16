# CSIR-INSTI Soil Atlas
### A Low-Cost Hardware–Mobile Platform for Comprehensive Soil Monitoring, Crop Phenotype, and Image Dataset Acquisition

## What It Is
- ESP32-based NPK soil sensor + BLE + TFT
- Flutter mobile app for live monitoring, session storage, and exports
- Local-first architecture: SQLite (Drift) on device, shareable CSV/PDF
- Crop parameter capture with images for phenotype context

## Why It Matters
- Affordable, portable field kit for farmers and researchers
- Faster agronomic decisions with live guidance and session history
- Data stays local; share on demand for collaboration or advisory services
- Builds labeled image and sensor datasets for future ML models

## Hardware Snapshot
- ESP32-WROOM-DA + Modbus NPK/EC/pH/temp sensor
- BLE notifications with compact JSON payloads
- On-device TFT for quick visual feedback
- Sample rate: 1–2s; payload <512 bytes

## Mobile App Features
- BLE scan/connect with status indicators
- Live readings saved automatically; prompt to save/discard on disconnect
- Session management: history, summaries, crop links, deletion
- Interactive charts: per-sensor tabs, persisted tab selection
  - Multi-session overlay with color legend
  - Threshold guides (tomato defaults) as dashed lines + ideal-range hints
  - Chart export to PDF
- Crop parameters: soil traits, height, stem size, leaf color, notes, images
- Exports: CSV (sensors, sensors+params, crop params), PDF reports, images
- Offline-first: everything works without network

## How Data Flows
1) ESP32 reads sensors → emits JSON over BLE notifications  
2) App subscribes → parses → writes to SQLite and in-memory session buffer  
3) User saves a session → readings grouped + optional crop params/images link  
4) Visualization/export → charts, CSV/PDF, share sheet

## Protocol (BLE)
- Service UUID: `0000F001-0000-1000-8000-00805F9B34FB`
- Characteristic UUID: `0000F002-0000-1000-8000-00805F9B34FB`
- JSON fields: timestamp, moisture, ec, temperature, ph, nitrogen, phosphorus, potassium, salinity
- App auto-corrects bad timestamps to current time

## Data Model (On-Device)
- Sensor readings: timestamp, moisture, EC, temp, pH, N, P, K, salinity, optional cropParamsId
- Sessions: lists of reading IDs, created on save
- Crop params: soil traits + notes + images stored locally with sequential names

## Typical Workflow (Demo)
1. Open Live Data → scan and connect (look for FARM-ESP32)  
2. Watch live readings; select crop params (optional)  
3. Tap “Save readings” → creates a session  
4. Go to Charts → pick session(s), view overlays + thresholds  
5. Export CSV/PDF or share images from Export tab  

## Deployment Notes
- Android/iOS; iOS requires physical device for BLE
- Permissions: Bluetooth (iOS Info.plist), storage/photos for exports/images
- Build: `flutter pub get` → `flutter run`; `pod install` inside `ios/` for iOS

## Extensibility
- Swap threshold profiles per crop (Tomato defaults provided)
- Add cloud sync/analytics without changing on-device model
- Extend sensor set (e.g., light, CO₂) by updating schema + payload parser

