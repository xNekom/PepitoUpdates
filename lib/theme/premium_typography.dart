import 'package:flutter/material.dart';
import '../utils/platform_detector.dart';

class PremiumTypography {
  static String defaultFontFamily() {
    return 'Inter, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif';
  }

  static String platformFontFamilyFor(BuildContext context) {
    final platform = PlatformDetector.currentPlatform;
    switch (platform) {
      case AppPlatform.iOS:
        return '.SF Pro Display';
      case AppPlatform.macOS:
        return '.SF Pro Display';
      case AppPlatform.windows:
        return 'Segoe UI Variable, Segoe UI';
      case AppPlatform.android:
        return 'Roboto';
      case AppPlatform.web:
        return defaultFontFamily();
      case AppPlatform.other:
        return defaultFontFamily();
    }
  }

  static TextTheme getLightTextTheme() {
    return _baseTextTheme(const Color(0xFF1F2937), const Color(0xFF4B5563), defaultFontFamily());
  }

  static TextTheme getDarkTextTheme() {
    return _baseTextTheme(Colors.white, const Color(0xFFD1D5DB), defaultFontFamily());
  }

  static TextTheme platformAwareTextTheme(BuildContext context, Brightness brightness) {
    final family = platformFontFamilyFor(context);
    final titleColor = brightness == Brightness.dark ? Colors.white : const Color(0xFF1F2937);
    final bodyColor = brightness == Brightness.dark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563);
    return _baseTextTheme(titleColor, bodyColor, family);
  }

  static TextTheme _baseTextTheme(Color titleColor, Color bodyColor, String fontFamily) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: titleColor,
        height: 1.12,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: titleColor,
        height: 1.16,
      ),
      displaySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: titleColor,
        height: 1.22,
      ),
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: titleColor,
        height: 1.25,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        color: titleColor,
        height: 1.29,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: titleColor,
        height: 1.33,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: titleColor,
        height: 1.27,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: titleColor,
        height: 1.5,
      ),
      titleSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: titleColor,
        height: 1.43,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: bodyColor,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: bodyColor,
        height: 1.43,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: bodyColor,
        height: 1.33,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: titleColor,
        height: 1.43,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: titleColor,
        height: 1.33,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: titleColor,
        height: 1.45,
      ),
    );
  }
}
