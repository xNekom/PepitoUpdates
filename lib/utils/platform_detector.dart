import 'dart:io';
import 'package:flutter/foundation.dart';

enum AppPlatform {
  iOS,
  macOS,
  android,
  web,
  other,
}

enum WidgetStyle {
  materialExpressive,  // Android/Web/Windows/Linux
  liquidGlass,        // iOS/macOS
}

class PlatformDetector {
  static AppPlatform get currentPlatform {
    if (kIsWeb) return AppPlatform.web;

    if (Platform.isIOS) return AppPlatform.iOS;
    if (Platform.isMacOS) return AppPlatform.macOS;
    if (Platform.isAndroid) return AppPlatform.android;

    return AppPlatform.other;
  }

  static bool get isAppleEcosystem {
    return currentPlatform == AppPlatform.iOS ||
           currentPlatform == AppPlatform.macOS;
  }

  static WidgetStyle get recommendedStyle {
    return isAppleEcosystem
        ? WidgetStyle.liquidGlass
        : WidgetStyle.materialExpressive;
  }

  static bool get supportsCupertinoWidgets => isAppleEcosystem;
  static bool get supportsBackdropFilter => !kIsWeb || kIsWeb; // Web también soporta
  static bool get supportsHaptics => currentPlatform == AppPlatform.iOS;
  static bool get isMobile => currentPlatform == AppPlatform.iOS ||
                               currentPlatform == AppPlatform.android;
  static bool get isDesktop => currentPlatform == AppPlatform.macOS ||
                                currentPlatform == AppPlatform.other;

  static String get platformName {
    switch (currentPlatform) {
      case AppPlatform.iOS:
        return 'iOS';
      case AppPlatform.macOS:
        return 'macOS';
      case AppPlatform.android:
        return 'Android';
      case AppPlatform.web:
        return 'Web';
      case AppPlatform.other:
        return 'Other';
    }
  }

  static String get styleName {
    return recommendedStyle == WidgetStyle.liquidGlass
        ? 'Liquid Glass'
        : 'Material Expressive';
  }
}