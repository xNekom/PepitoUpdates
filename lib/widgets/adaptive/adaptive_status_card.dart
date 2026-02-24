import 'package:flutter/material.dart';
import '../liquid_glass/status/liquid_status_card.dart';
import '../material_expressive/status_card.dart';
import '../fluent_design/fluent_status_card.dart';
import '../../utils/platform_detector.dart';

/// Widget adaptivo que selecciona automáticamente entre Liquid Glass, Material Expressive y Fluent Design
/// basado en la plataforma del dispositivo
class AdaptiveStatusCard extends StatelessWidget {
  final dynamic status;
  final VoidCallback? onRefresh;
  final bool isLoading;

  const AdaptiveStatusCard({
    super.key,
    required this.status,
    this.onRefresh,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Seleccionar el widget apropiado basado en la plataforma
    switch (PlatformDetector.recommendedStyle) {
      case WidgetStyle.liquidGlass:
        return LiquidStatusCard(
          status: status,
          onRefresh: onRefresh,
          isLoading: isLoading,
        );
      case WidgetStyle.fluentDesign:
        return FluentStatusCard(
          status: status,
          onRefresh: onRefresh,
          isLoading: isLoading,
        );
      case WidgetStyle.materialExpressive:
        return StatusCard(
          status: status,
          onRefresh: onRefresh,
          isLoading: isLoading,
        );
    }
  }
}