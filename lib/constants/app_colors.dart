import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF05B084); // Green from image/text
  static const Color secondary = Color(0xFF015A84); // Blue from image
  static const Color background = Color(0xFFF1EDEA); // From image
  static const Color accentLight = Color(0xFFBADFCD); // From image

  // Text Colors
  static const Color primaryText = Color(0xFF0F2A3C); // Dark Blue for Titles
  static const Color bodyText = Color(0xFF4B5563);
  static const Color mutedText = Color(0xFF8A9AA5);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Functional Colors
  static const Color success = Color(0xFF2ECC71); // From image
  static const Color warning = Color(0xFFF4A261); // From image
  static const Color alert = Color(0xFFE76F51); // From image

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
