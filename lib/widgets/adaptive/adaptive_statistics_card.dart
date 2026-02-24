import 'package:flutter/material.dart';
import '../liquid_glass/statistics/liquid_statistics_card.dart';
import '../material_expressive/statistics_widgets.dart';
import '../fluent_design/fluent_statistics_card.dart';
import '../../utils/platform_detector.dart';

/// Widget adaptivo que selecciona automáticamente entre Liquid Glass, Material Expressive y Fluent Design
/// basado en la plataforma del dispositivo
class AdaptiveStatisticsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const AdaptiveStatisticsCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Seleccionar el widget apropiado basado en la plataforma
    switch (PlatformDetector.recommendedStyle) {
      case WidgetStyle.liquidGlass:
        return LiquidStatisticsCard(
          title: title,
          value: value,
          subtitle: subtitle,
          icon: icon,
          color: color,
          onTap: onTap,
        );
      case WidgetStyle.fluentDesign:
        return FluentStatisticsCard(
          title: title,
          value: value,
          subtitle: subtitle,
          icon: icon,
          color: color,
          onTap: onTap,
        );
      case WidgetStyle.materialExpressive:
        return StatisticsCard(
          title: title,
          value: value,
          subtitle: subtitle,
          icon: icon,
          color: color,
          onTap: onTap,
        );
    }
  }
}