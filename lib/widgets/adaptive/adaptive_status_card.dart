import 'package:flutter/material.dart';
import '../liquid_glass/status/liquid_status_card.dart';

/// Widget que ahora renderiza Liquid Glass como estándar premium para toda la app.
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
    return LiquidStatusCard(
      status: status,
      onRefresh: onRefresh,
      isLoading: isLoading,
    );
  }
}