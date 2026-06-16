import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pepito_providers.dart';
import '../liquid_glass/status/liquid_status_card.dart';
import '../material_expressive/status_card.dart' as m3;
import '../fluent_design/fluent_status_card.dart';

class AdaptiveStatusCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final style = ref.watch(platformStyleProvider);

    return switch (style) {
      WidgetStyle.liquidGlass => LiquidStatusCard(
        status: status,
        onRefresh: onRefresh,
        isLoading: isLoading,
      ),
      WidgetStyle.fluentDesign => FluentStatusCard(
        status: status,
        onRefresh: onRefresh,
        isLoading: isLoading,
      ),
      WidgetStyle.materialExpressive => m3.StatusCard(
        status: status,
        onRefresh: onRefresh,
        isLoading: isLoading,
      ),
    };
  }
}
