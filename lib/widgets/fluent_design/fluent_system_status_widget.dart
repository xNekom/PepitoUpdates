import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pepito_providers.dart';

/// System status widget implementing Windows Fluent Design
class FluentSystemStatusWidget extends ConsumerWidget {
  const FluentSystemStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fluentTheme = fluent.FluentTheme.of(context);
    final isDark = fluentTheme.brightness == Brightness.dark;
    final isConnected = ref.watch(connectionStatusProvider);
    final isLoading = ref.watch(loadingProvider);
    
    return fluent.Card(
      backgroundColor: isDark 
          ? const Color(0xFF2D2D2D) 
          : Colors.white,
      borderColor: isDark 
          ? const Color(0xFF404040) 
          : const Color(0xFFE0E0E0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Connection indicator
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isConnected 
                  ? fluent.Colors.green 
                  : fluent.Colors.red,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isConnected 
                      ? fluent.Colors.green 
                      : fluent.Colors.red).withValues(alpha: 0.3),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Status text
          Text(
            isConnected ? 'Conectado' : 'Sin conexión',
            style: fluentTheme.typography.body?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          // Loading indicator
          if (isLoading) ...[
            const SizedBox(width: 12),
            const SizedBox(
              width: 16,
              height: 16,
              child: fluent.ProgressRing(strokeWidth: 2),
            ),
          ],
          // API Status badge
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark 
                  ? const Color(0xFF383838) 
                  : const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isConnected 
                      ? fluent.FluentIcons.cloud
                      : fluent.FluentIcons.cloud_not_synced,
                  size: 14,
                  color: isConnected 
                      ? fluentTheme.accentColor.defaultBrushFor(fluentTheme.brightness)
                      : fluentTheme.typography.body?.color?.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 6),
                Text(
                  'API',
                  style: fluentTheme.typography.caption?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isConnected 
                        ? fluentTheme.accentColor.defaultBrushFor(fluentTheme.brightness)
                        : fluentTheme.typography.body?.color?.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
