import 'package:flutter/material.dart';

class PremiumTypography {
  static const String premiumFontFamily = 'Inter, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif';

  static TextTheme getLightTextTheme() {
    return _baseTextTheme(const Color(0xFF1F2937), const Color(0xFF4B5563));
  }

  static TextTheme getDarkTextTheme() {
    return _baseTextTheme(Colors.white, const Color(0xFFD1D5DB));
  }

  static TextTheme _baseTextTheme(Color titleColor, Color bodyColor) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: premiumFontFamily,
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: titleColor,
        height: 1.12,
      ),
      displayMedium: TextStyle(
        fontFamily: premiumFontFamily,
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: titleColor,
        height: 1.16,
      ),
      displaySmall: TextStyle(
        fontFamily: premiumFontFamily,
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: titleColor,
        height: 1.22,
      ),
      headlineLarge: TextStyle(
        fontFamily: premiumFontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: titleColor,
        height: 1.25,
      ),
      headlineMedium: TextStyle(
        fontFamily: premiumFontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        color: titleColor,
        height: 1.29,
      ),
      headlineSmall: TextStyle(
        fontFamily: premiumFontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: titleColor,
        height: 1.33,
      ),
      titleLarge: TextStyle(
        fontFamily: premiumFontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w600, // Slightly bolder for premium look
        letterSpacing: 0,
        color: titleColor,
        height: 1.27,
      ),
      titleMedium: TextStyle(
        fontFamily: premiumFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: titleColor,
        height: 1.5,
      ),
      titleSmall: TextStyle(
        fontFamily: premiumFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: titleColor,
        height: 1.43,
      ),
      bodyLarge: TextStyle(
        fontFamily: premiumFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: bodyColor,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: premiumFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: bodyColor,
        height: 1.43,
      ),
      bodySmall: TextStyle(
        fontFamily: premiumFontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: bodyColor,
        height: 1.33,
      ),
      labelLarge: TextStyle(
        fontFamily: premiumFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: titleColor,
        height: 1.43,
      ),
      labelMedium: TextStyle(
        fontFamily: premiumFontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: titleColor,
        height: 1.33,
      ),
      labelSmall: TextStyle(
        fontFamily: premiumFontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: titleColor,
        height: 1.45,
      ),
    );
  }
}
