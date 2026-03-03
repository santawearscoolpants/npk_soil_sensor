import 'dart:convert';

import 'package:csir_soil_sensor/src/services/bluetooth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'splitJsonPayloads reassembles chunked BLE JSON and drops prefix noise',
    () {
      final firstPass = splitJsonPayloads(
        'Hello from ESP32!{"timestamp":123,"moisture":37.4,',
      );

      expect(firstPass.messages, isEmpty);
      expect(firstPass.remainder, '{"timestamp":123,"moisture":37.4,');

      final secondPass = splitJsonPayloads(
        '${firstPass.remainder}"ec":1.81,"temperature":28.2,"ph":6.5,"nitrogen":44,"phosphorus":21,"potassium":57,"salinity":0.8}',
      );

      expect(secondPass.messages, hasLength(1));
      expect(secondPass.remainder, isEmpty);

      final decoded =
          jsonDecode(secondPass.messages.single) as Map<String, dynamic>;
      expect(isSensorReadingPayload(decoded), isTrue);
      expect(decoded['moisture'], 37.4);
    },
  );

  test('LiveReading parses legacy BLE payloads without tds', () {
    final payload =
        jsonDecode('''
      {
        "timestamp": 123,
        "moisture": 37.4,
        "ec": 1.81,
        "temperature": 28.2,
        "ph": 6.5,
        "nitrogen": 44,
        "phosphorus": 21,
        "potassium": 57,
        "salinity": 0.8
      }
    ''')
            as Map<String, dynamic>;

    final reading = LiveReading.fromJson(payload);

    expect(reading.timestamp, 123);
    expect(reading.moisture, 37.4);
    expect(reading.tds, 0);
  });

  test('LiveReading parses numeric strings from BLE payloads', () {
    final payload = <String, dynamic>{
      'timestamp': '456',
      'moisture': '35.5',
      'ec': '1.20',
      'temperature': '27.3',
      'ph': '6.1',
      'nitrogen': '40',
      'phosphorus': '18',
      'potassium': '52',
      'salinity': '0.6',
      'tds': '310',
    };

    final reading = LiveReading.fromJson(payload);

    expect(reading.timestamp, 456);
    expect(reading.ec, 1.2);
    expect(reading.tds, 310);
  });

  test('LiveReading parses alternate calibrated firmware keys', () {
    final payload =
        jsonDecode('''
      {
        "timestamp": 1748,
        "moisture_pct": 0.0,
        "temperature_c": 30.1,
        "ec_dSm": 0.061,
        "ph": 5.73,
        "n_percent": 0.1148,
        "p_mgkg": 7.8,
        "k_cmolkg": 0.164,
        "salinity": 0.00,
        "tds": 0
      }
    ''')
            as Map<String, dynamic>;

    expect(isSensorReadingPayload(payload), isTrue);

    final reading = LiveReading.fromJson(payload);

    expect(reading.moisture, 0.0);
    expect(reading.temperature, 30.1);
    expect(reading.ecConv, 0.061);
    expect(reading.nConv, 0.1148);
    expect(reading.pConv, 7.8);
    expect(reading.kConv, 0.164);
    expect(reading.nitrogenDisplayUnit, '%');
    expect(reading.potassiumDisplayUnit, 'cmol(+)/kg');
  });

  test('isSensorReadingPayload ignores unrelated BLE JSON objects', () {
    expect(isSensorReadingPayload({'message': 'Hello from ESP32!'}), isFalse);
    expect(isSensorReadingPayload({'timestamp': 123}), isFalse);
  });
}
