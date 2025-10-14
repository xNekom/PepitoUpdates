import 'package:flutter/services.dart';

class IOSGlassConfig {
  // iOS usa cards más compactas
  static const double cardPadding = 16.0;
  static const double iconSize = 24.0;

  // iOS tiene haptics
  static bool get supportsHaptics => true;

  // Feedback háptico
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  // iOS usa navigation bar translúcida
  static const bool useBlurredNavigationBar = true;

  // Safe area para notch/dynamic island
  static const bool respectsSafeArea = true;

  // Configuración de scroll
  static const bool useBouncingScroll = true;

  // Animaciones específicas iOS
  static const Duration quickTransition = Duration(milliseconds: 200);
  static const Duration standardTransition = Duration(milliseconds: 300);
}