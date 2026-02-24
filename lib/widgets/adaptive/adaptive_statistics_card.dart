import 'package:flutter/material.dart';
import '../liquid_glass/statistics/liquid_statistics_card.dart';

/// Widget que ahora renderiza Liquid Glass como estándar premium para toda la app.
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
    return LiquidStatisticsCard(
      title: title,
      value: value,
      subtitle: subtitle,
      icon: icon,
      color: color,
      onTap: onTap,
    );
  }
}