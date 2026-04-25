import 'package:flutter/material.dart';

class AppResponsive {
  static const double _designWidth = 375.0;
  static const double _designHeight = 812.0;

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide >= 600;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  /// Scales a width value relative to design width (375)
  static double w(BuildContext context, double value) {
    return value * (screenWidth(context) / _designWidth);
  }

  /// Scales a height value relative to design height (812)
  static double h(BuildContext context, double value) {
    return value * (screenHeight(context) / _designHeight);
  }

  /// Scales a radius value (uses the smaller of width/height ratio)
  static double r(BuildContext context, double value) {
    final scale = (screenWidth(context) / _designWidth).clamp(0.8, 1.3);
    return value * scale;
  }

  /// Scales font size (respects system font scale too)
  static double sp(BuildContext context, double value) {
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final widthScale = screenWidth(context) / _designWidth;
    return value * widthScale.clamp(0.85, 1.2) / textScale.clamp(0.85, 1.3);
  }

  /// Returns appropriate grid column count based on screen width
  static int gridColumns(
    BuildContext context, {
    int phone = 2,
    int tablet = 3,
  }) {
    return isTablet(context) ? tablet : phone;
  }

  /// Responsive padding
  static EdgeInsets padding(
    BuildContext context, {
    double horizontal = 20,
    double vertical = 20,
  }) {
    return EdgeInsets.symmetric(
      horizontal: w(context, horizontal),
      vertical: w(context, vertical),
    );
  }

  /// Responsive horizontal gap
  static SizedBox hGap(BuildContext context, double value) {
    return SizedBox(width: w(context, value));
  }

  /// Responsive vertical gap
  static SizedBox vGap(BuildContext context, double value) {
    return SizedBox(height: h(context, value));
  }
}
