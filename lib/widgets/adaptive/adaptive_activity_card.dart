import 'package:flutter/material.dart';
import '../liquid_glass/activity/liquid_activity_card.dart';

/// Widget que ahora renderiza Liquid Glass como estándar premium para toda la app.
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
    return LiquidActivityCard(
      activity: activity,
      onTap: onTap,
      showDate: showDate,
      compact: compact,
    );
  }
}