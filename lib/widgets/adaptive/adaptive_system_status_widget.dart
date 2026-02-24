import 'package:flutter/material.dart';
import '../liquid_glass/system/liquid_system_status_widget.dart';

/// Widget que ahora renderiza Liquid Glass como estándar premium para toda la app.
class AdaptiveSystemStatusWidget extends StatelessWidget {
  const AdaptiveSystemStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const LiquidSystemStatusWidget();
  }
}