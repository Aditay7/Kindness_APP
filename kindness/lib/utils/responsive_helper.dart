import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double getWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double getFontSize(BuildContext context, double size) {
    double width = getWidth(context);
    if (width < 600) return size * 0.9;
    if (width < 1200) return size * 1.0;
    return size * 1.1;
  }

  static double getPaddingValue(BuildContext context) {
    double width = getWidth(context);
    if (width < 600) return 12.0;
    if (width < 1200) return 16.0;
    return 20.0;
  }

  static EdgeInsets getPadding(BuildContext context) {
    double padding = getPaddingValue(context);
    return EdgeInsets.all(padding);
  }

  static double getMaxWidth(BuildContext context) {
    double width = getWidth(context);
    if (width < 600) return width;
    if (width < 1200) return 700;
    return 1000;
  }
}
