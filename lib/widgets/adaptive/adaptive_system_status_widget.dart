import 'package:flutter/material.dart';
import '../liquid_glass/system/liquid_system_status_widget.dart';
import '../material_expressive/system_status_widget.dart';
import '../fluent_design/fluent_system_status_widget.dart';
import '../../utils/platform_detector.dart';

/// Widget adaptivo que selecciona automáticamente entre Liquid Glass, Material Expressive y Fluent Design
/// basado en la plataforma del dispositivo
class AdaptiveSystemStatusWidget extends StatelessWidget {
  const AdaptiveSystemStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Seleccionar el widget apropiado basado en la plataforma
    switch (PlatformDetector.recommendedStyle) {
      case WidgetStyle.liquidGlass:
        return const LiquidSystemStatusWidget();
      case WidgetStyle.fluentDesign:
        return const FluentSystemStatusWidget();
      case WidgetStyle.materialExpressive:
        return const SystemStatusWidget();
    }
  }
}