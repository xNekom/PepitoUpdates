import 'package:flutter/foundation.dart';
import '../utils/platform_detector.dart';

class PlatformStyleProvider extends ChangeNotifier {
  WidgetStyle? _manualOverride;

  WidgetStyle get currentStyle {
    // Si hay override manual (para desarrollo/testing)
    if (_manualOverride != null) {
      return _manualOverride!;
    }

    // Si no, usar el recomendado por plataforma
    return PlatformDetector.recommendedStyle;
  }

  bool get isLiquidGlass => currentStyle == WidgetStyle.liquidGlass;
  bool get isMaterialExpressive => currentStyle == WidgetStyle.materialExpressive;

  // Para desarrollo: forzar un estilo específico
  void setManualStyle(WidgetStyle? style) {
    _manualOverride = style;
    notifyListeners();
  }

  void resetToDefault() {
    _manualOverride = null;
    notifyListeners();
  }

  // Info de plataforma
  String get platformInfo {
    final platform = PlatformDetector.currentPlatform;
    final style = currentStyle;
    return 'Platform: ${platform.name} | Style: ${style.name}';
  }

  // Información detallada para debugging
  String get debugInfo {
    final platform = PlatformDetector.currentPlatform;
    final recommended = PlatformDetector.recommendedStyle;
    final current = currentStyle;
    final override = _manualOverride;

    return '''
Platform Detection:
- Current Platform: ${platform.name}
- Is Apple Ecosystem: ${PlatformDetector.isAppleEcosystem}
- Is Mobile: ${PlatformDetector.isMobile}
- Is Desktop: ${PlatformDetector.isDesktop}
- Supports Cupertino: ${PlatformDetector.supportsCupertinoWidgets}
- Supports Haptics: ${PlatformDetector.supportsHaptics}

Style Configuration:
- Recommended Style: ${recommended.name}
- Current Style: ${current.name}
- Manual Override: ${override?.name ?? 'None'}
- Using Liquid Glass: $isLiquidGlass
- Using Material Expressive: $isMaterialExpressive
''';
  }
}