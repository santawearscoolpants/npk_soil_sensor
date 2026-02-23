class SensorReading {
  final int id;
  final DateTime timestamp;
  final double moisture;
  final double ec;
  final double temperature;
  final double ph;
  final int nitrogen;
  final int phosphorus;
  final int potassium;
  final double salinity;
  final int? cropParamsId;

  // Optional converted + calibrated values (from firmware JSON)
  final double? ecConv; // EC converted (dS/m)
  final double? ecCal;  // EC calibrated (dS/m)
  final double? phConv;
  final double? phCal;
  final double? nConv;  // N converted (%)
  final double? nCal;   // N calibrated (%)
  final double? pConv;  // P converted (mg/kg)
  final double? pCal;   // P calibrated (mg/kg)
  final double? kConv;  // K converted (cmol(+)/kg)
  final double? kCal;   // K calibrated (cmol(+)/kg)

  SensorReading({
    required this.id,
    required this.timestamp,
    required this.moisture,
    required this.ec,
    required this.temperature,
    required this.ph,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.salinity,
    required this.cropParamsId,
    this.ecConv,
    this.ecCal,
    this.phConv,
    this.phCal,
    this.nConv,
    this.nCal,
    this.pConv,
    this.pCal,
    this.kConv,
    this.kCal,
  });
}


