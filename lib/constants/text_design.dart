import 'package:flutter/material.dart';
import 'app_colors.dart';

class TextDesign {
  static TextStyle get h1 =>
      const TextStyle(fontSize: 26, fontWeight: FontWeight.w700);

  static TextStyle get h2 =>
      const TextStyle(fontSize: 20, fontWeight: FontWeight.w600);

  static TextStyle get h3 =>
      const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

  static TextStyle get body =>
      const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.4);

  static TextStyle get small =>
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w400);

  static TextStyle get buttonText =>
      const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

  static TextStyle get button => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white, // Buttons usually have white text on colored bg
  );

  static TextStyle get caption => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.primary, // Caption can keep primary color
  );

  static TextStyle get pageTitle => const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white, // Page titles on backgrounds usually stay white
  );

  static TextStyle get pageSubtitle => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.white.withOpacity(0.9),
  );
}
