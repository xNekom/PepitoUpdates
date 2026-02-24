import 'dart:io';
import 'package:flutter/foundation.dart';

enum AppPlatform {
  iOS,
  macOS,
  android,
  windows,
  web,
  other,
}

enum WidgetStyle {
  materialExpressive,  // Android/Web
  liquidGlass,        // iOS/macOS
  fluentDesign,       // Windows
}

class PlatformDetector {
  static AppPlatform get currentPlatform {
    if (kIsWeb) return AppPlatform.web;

    if (Platform.isIOS) return AppPlatform.iOS;
    if (Platform.isMacOS) return AppPlatform.macOS;
    if (Platform.isAndroid) return AppPlatform.android;
    if (Platform.isWindows) return AppPlatform.windows;

    return AppPlatform.other;
  }

  static bool get isAppleEcosystem {
    return currentPlatform == AppPlatform.iOS ||
           currentPlatform == AppPlatform.macOS;
  }

  static bool get isWindows => currentPlatform == AppPlatform.windows;

  static WidgetStyle get recommendedStyle {
    if (isAppleEcosystem) {
      return WidgetStyle.liquidGlass;
    } else if (isWindows) {
      return WidgetStyle.fluentDesign;
    } else {
      return WidgetStyle.materialExpressive;
    }
  }

  static bool get supportsCupertinoWidgets => isAppleEcosystem;
  static bool get supportsBackdropFilter => !kIsWeb || kIsWeb; // Web también soporta
  static bool get supportsHaptics => currentPlatform == AppPlatform.iOS;
  static bool get isMobile => currentPlatform == AppPlatform.iOS ||
                               currentPlatform == AppPlatform.android;
  static bool get isDesktop => currentPlatform == AppPlatform.macOS ||
                                currentPlatform == AppPlatform.windows ||
                                currentPlatform == AppPlatform.other;

  static String get platformName {
    switch (currentPlatform) {
      case AppPlatform.iOS:
        return 'iOS';
      case AppPlatform.macOS:
        return 'macOS';
      case AppPlatform.android:
        return 'Android';
      case AppPlatform.windows:
        return 'Windows';
      case AppPlatform.web:
        return 'Web';
      case AppPlatform.other:
        return 'Other';
    }
  }

  static String get styleName {
    switch (recommendedStyle) {
      case WidgetStyle.liquidGlass:
        return 'Liquid Glass';
      case WidgetStyle.fluentDesign:
        return 'Fluent Design';
      case WidgetStyle.materialExpressive:
        return 'Material Expressive';
    }
  }
}