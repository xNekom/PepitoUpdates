import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pepito_providers.dart';
import '../liquid_glass/statistics/liquid_statistics_card.dart';
import '../material_expressive/statistics_widgets.dart' as m3;
import '../fluent_design/fluent_statistics_card.dart';

class AdaptiveStatisticsCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final style = ref.watch(platformStyleProvider);

    return switch (style) {
      WidgetStyle.liquidGlass => LiquidStatisticsCard(
        title: title,
        value: value,
        subtitle: subtitle,
        icon: icon,
        color: color,
        onTap: onTap,
      ),
      WidgetStyle.fluentDesign => FluentStatisticsCard(
        title: title,
        value: value,
        subtitle: subtitle,
        icon: icon,
        color: color,
        onTap: onTap,
      ),
      WidgetStyle.materialExpressive => m3.StatisticsCard(
        title: title,
        value: value,
        subtitle: subtitle,
        icon: icon,
        color: color,
        onTap: onTap,
      ),
    };
  }
}
