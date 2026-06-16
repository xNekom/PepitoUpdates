import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pepito_providers.dart';
import '../liquid_glass/system/liquid_system_status_widget.dart';
import '../material_expressive/system_status_widget.dart' as m3;
import '../fluent_design/fluent_system_status_widget.dart';

class AdaptiveSystemStatusWidget extends ConsumerWidget {
  const AdaptiveSystemStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = ref.watch(platformStyleProvider);

    return switch (style) {
      WidgetStyle.liquidGlass => const LiquidSystemStatusWidget(),
      WidgetStyle.fluentDesign => const FluentSystemStatusWidget(),
      WidgetStyle.materialExpressive => const m3.SystemStatusWidget(),
    };
  }
}
