import 'package:flutter/material.dart';
import '../liquid_glass/activity/liquid_activity_card.dart';
import '../material_expressive/activity_card.dart';
import '../fluent_design/fluent_activity_card.dart';
import '../../utils/platform_detector.dart';

/// Widget adaptivo que selecciona automáticamente entre Liquid Glass, Material Expressive y Fluent Design
/// basado en la plataforma del dispositivo
class AdaptiveActivityCard extends StatelessWidget {
  final dynamic activity;
  final VoidCallback? onTap;
  final bool showDate;
  final bool compact;

  const AdaptiveActivityCard({
    super.key,
    required this.activity,
    this.onTap,
    this.showDate = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    // Seleccionar el widget apropiado basado en la plataforma
    switch (PlatformDetector.recommendedStyle) {
      case WidgetStyle.liquidGlass:
        return LiquidActivityCard(
          activity: activity,
          onTap: onTap,
          showDate: showDate,
          compact: compact,
        );
      case WidgetStyle.fluentDesign:
        return FluentActivityCard(
          activity: activity,
          onTap: onTap,
          showDate: showDate,
          compact: compact,
        );
      case WidgetStyle.materialExpressive:
        return ActivityCard(
          activity: activity,
          onTap: onTap,
          showDate: showDate,
          compact: compact,
        );
    }
  }
}