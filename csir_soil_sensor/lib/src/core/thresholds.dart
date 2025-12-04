import 'package:flutter/material.dart';

/// Threshold ranges for tomato growing (ideal ranges based on agricultural standards).
/// Used to color-code sensor readings: green (ideal), amber (acceptable), red (needs attention).
class TomatoThresholds {
  // Moisture: 30-50% is ideal for tomatoes
  static const double moistureLow = 30.0;
  static const double moistureHigh = 50.0;
  static const String moistureTooltip =
      'Soil moisture. Ideal: 30-50%. Too low: plants stress. Too high: root rot risk.';

  // EC (Electrical Conductivity): 1.5-2.5 mS/cm ideal for tomatoes
  static const double ecLow = 1.5;
  static const double ecHigh = 2.5;
  static const String ecTooltip =
      'Electrical Conductivity measures dissolved salts. Ideal: 1.5-2.5 mS/cm. Higher = more nutrients/salts.';

  // Temperature: 20-30°C ideal for tomato growth
  static const double temperatureLow = 20.0;
  static const double temperatureHigh = 30.0;
  static const String temperatureTooltip =
      'Soil temperature. Ideal: 20-30°C. Too cold: slow growth. Too hot: stress.';

  // pH: 6.0-7.0 ideal for tomatoes (slightly acidic to neutral)
  static const double phLow = 6.0;
  static const double phHigh = 7.0;
  static const String phTooltip =
      'Soil pH (acidity). Ideal: 6.0-7.0. Too low: nutrient lockout. Too high: iron deficiency.';

  // Nitrogen: 40-80 mg/kg ideal
  static const double nitrogenLow = 40.0;
  static const double nitrogenHigh = 80.0;
  static const String nitrogenTooltip =
      'Nitrogen (N) in mg/kg. Ideal: 40-80. Low: yellow leaves, stunted growth. High: excessive foliage, fewer fruits.';

  // Phosphorus: 15-50 mg/kg ideal
  static const double phosphorusLow = 15.0;
  static const double phosphorusHigh = 50.0;
  static const String phosphorusTooltip =
      'Phosphorus (P) in mg/kg. Ideal: 15-50. Low: poor root development, delayed flowering. High: can lock out other nutrients.';

  // Potassium: 30-100 mg/kg ideal
  static const double potassiumLow = 30.0;
  static const double potassiumHigh = 100.0;
  static const String potassiumTooltip =
      'Potassium (K) in mg/kg. Ideal: 30-100. Low: weak stems, poor fruit quality. High: usually not harmful.';

  // Salinity: 0.5-1.5 dS/m (or mS/cm) ideal
  static const double salinityLow = 0.5;
  static const double salinityHigh = 1.5;
  static const String salinityTooltip =
      'Soil salinity. Ideal: 0.5-1.5. High salinity can burn roots and reduce water uptake.';

  /// Returns a color based on value and thresholds.
  /// Green: within ideal range (middle 50% of range)
  /// Amber: acceptable but outside ideal (outer 25% on each side)
  /// Red: outside acceptable range
  static Color getColorForValue(
    double value,
    double lowThreshold,
    double highThreshold,
  ) {
    if (value < lowThreshold || value > highThreshold) {
      return Colors.red;
    }
    final range = highThreshold - lowThreshold;
    final midLow = lowThreshold + range * 0.25;
    final midHigh = lowThreshold + range * 0.75;
    if (value < midLow || value > midHigh) {
      return Colors.amber;
    }
    return Colors.green;
  }
}

