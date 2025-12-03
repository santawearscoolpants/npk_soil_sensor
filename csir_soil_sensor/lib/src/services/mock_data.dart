import 'dart:math';

/// Generates a mock JSON string payload that matches the expected ESP32 format.
String generateMockPayload() {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final rand = Random();

  final moisture = 25 + rand.nextDouble() * 30;
  final ec = 1 + rand.nextDouble() * 1.5;
  final temperature = 22 + rand.nextDouble() * 8;
  final ph = 5.5 + rand.nextDouble() * 1.5;
  final nitrogen = 30 + rand.nextInt(40);
  final phosphorus = 15 + rand.nextInt(30);
  final potassium = 40 + rand.nextInt(40);
  final salinity = 0.3 + rand.nextDouble() * 0.8;

  return '''
{
  "timestamp": $now,
  "moisture": ${moisture.toStringAsFixed(1)},
  "ec": ${ec.toStringAsFixed(2)},
  "temperature": ${temperature.toStringAsFixed(1)},
  "ph": ${ph.toStringAsFixed(1)},
  "nitrogen": $nitrogen,
  "phosphorus": $phosphorus,
  "potassium": $potassium,
  "salinity": ${salinity.toStringAsFixed(2)}
}
''';
}


