import 'package:flutter/material.dart';

/// Device-size responsive scaling — separate from accessibility text
/// scaling, which Flutter's MediaQuery.textScaler already handles for
/// free based on the user's OS Text Size setting. This only adjusts
/// for screen size (small phone vs tablet).
class AppScale {
  AppScale._();

  static const double _referenceWidth = 375; // iPhone 14/15/16 base
  static const double _minScale = 0.85;
  static const double _maxScale = 1.25;

  static double factor(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return (width / _referenceWidth).clamp(_minScale, _maxScale);
  }

  static double scale(BuildContext context, double value) {
    return value * factor(context);
  }
}