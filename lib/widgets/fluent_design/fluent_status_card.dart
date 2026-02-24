import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

/// Status card widget implementing Windows Fluent Design
class FluentStatusCard extends StatelessWidget {
  final dynamic status;
  final VoidCallback? onRefresh;
  final bool isLoading;

  const FluentStatusCard({
    super.key,
    required this.status,
    this.onRefresh,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final fluentTheme = fluent.FluentTheme.of(context);
    final isDark = fluentTheme.brightness == Brightness.dark;
    
    // Determine status info
    final isOnline = status?.isOnline ?? false;
    final statusText = isOnline ? 'En línea' : 'Sin conexión';
    final lastSeen = status?.lastSeenFormatted ?? 'Desconocido';
    
    return fluent.Card(
      backgroundColor: isDark 
          ? const Color(0xFF2D2D2D) 
          : Colors.white,
      borderColor: isDark 
          ? const Color(0xFF404040) 
          : const Color(0xFFE0E0E0),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isOnline 
                      ? fluent.Colors.green 
                      : fluent.Colors.grey,
                  shape: BoxShape.circle,
                  boxShadow: isOnline ? [
                    BoxShadow(
                      color: fluent.Colors.green.withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ] : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Estado de Pépito',
                  style: fluentTheme.typography.subtitle?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: fluent.ProgressRing(strokeWidth: 2),
                )
              else if (onRefresh != null)
                fluent.IconButton(
                  icon: const Icon(fluent.FluentIcons.refresh, size: 18),
                  onPressed: onRefresh,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isOnline
                  ? fluent.Colors.green.withValues(alpha: 0.1)
                  : (isDark ? const Color(0xFF383838) : const Color(0xFFF5F5F5)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isOnline 
                      ? fluent.FluentIcons.completed
                      : fluent.FluentIcons.status_circle_block,
                  size: 16,
                  color: isOnline 
                      ? fluent.Colors.green 
                      : fluentTheme.typography.body?.color?.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: fluentTheme.typography.body?.copyWith(
                    color: isOnline 
                        ? fluent.Colors.green 
                        : null,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Última conexión: $lastSeen',
            style: fluentTheme.typography.caption?.copyWith(
              color: fluentTheme.typography.body?.color?.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
