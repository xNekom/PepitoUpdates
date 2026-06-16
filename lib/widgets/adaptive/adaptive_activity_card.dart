import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pepito_providers.dart';
import '../liquid_glass/activity/liquid_activity_card.dart';
import '../material_expressive/activity_card.dart' as m3;
import '../fluent_design/fluent_activity_card.dart';

class AdaptiveActivityCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final style = ref.watch(platformStyleProvider);

    return switch (style) {
      WidgetStyle.liquidGlass => LiquidActivityCard(
        activity: activity,
        onTap: onTap,
        showDate: showDate,
        compact: compact,
      ),
      WidgetStyle.fluentDesign => FluentActivityCard(
        activity: activity,
        onTap: onTap,
        showDate: showDate,
        compact: compact,
      ),
      WidgetStyle.materialExpressive => m3.ActivityCard(
        activity: activity,
        onTap: onTap,
        showDate: showDate,
        compact: compact,
      ),
    };
  }
}
