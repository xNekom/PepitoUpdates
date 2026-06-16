import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/platform_detector.dart';

class PlatformStyleNotifier extends Notifier<WidgetStyle> {
  WidgetStyle? _manualOverride;

  @override
  WidgetStyle build() {
    if (_manualOverride != null) {
      return _manualOverride!;
    }
    return PlatformDetector.recommendedStyle;
  }

  bool get isLiquidGlass => state == WidgetStyle.liquidGlass;
  bool get isMaterialExpressive => state == WidgetStyle.materialExpressive;

  void setManualStyle(WidgetStyle? style) {
    _manualOverride = style;
    state = style ?? PlatformDetector.recommendedStyle;
  }

  void resetToDefault() {
    _manualOverride = null;
    state = PlatformDetector.recommendedStyle;
  }

  String get platformInfo {
    final platform = PlatformDetector.currentPlatform;
    return 'Platform: ${platform.name} | Style: ${state.name}';
  }

  String get debugInfo {
    final platform = PlatformDetector.currentPlatform;
    final recommended = PlatformDetector.recommendedStyle;
    final current = state;
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
