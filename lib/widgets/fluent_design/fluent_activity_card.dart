import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:intl/intl.dart';
import '../../models/pepito_activity.dart';

/// Activity card widget implementing Windows Fluent Design
class FluentActivityCard extends StatelessWidget {
  final dynamic activity;
  final VoidCallback? onTap;
  final bool showDate;
  final bool compact;

  const FluentActivityCard({
    super.key,
    required this.activity,
    this.onTap,
    this.showDate = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final fluentTheme = fluent.FluentTheme.of(context);
    final isDark = fluentTheme.brightness == Brightness.dark;
    
    // Parse activity data
    final PepitoActivity? pepitoActivity = activity is PepitoActivity 
        ? activity 
        : null;
    final isEntry = pepitoActivity?.isEntry ?? false;
    final timestamp = pepitoActivity?.timestamp ?? DateTime.now();
    final description = pepitoActivity?.event ?? 'Actividad desconocida';
    
    final accentColor = isEntry 
        ? fluent.Colors.green 
        : fluent.Colors.orange;
    
    return fluent.GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
        child: fluent.Card(
          backgroundColor: isDark 
              ? const Color(0xFF2D2D2D) 
              : Colors.white,
          borderColor: isDark 
              ? const Color(0xFF404040) 
              : const Color(0xFFE0E0E0),
          padding: EdgeInsets.all(compact ? 12 : 16),
          child: Row(
            children: [
              // Activity icon with colored background
              Container(
                width: compact ? 40 : 48,
                height: compact ? 40 : 48,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isEntry 
                      ? fluent.FluentIcons.arrow_down_right8 
                      : fluent.FluentIcons.arrow_up_right8,
                  color: accentColor,
                  size: compact ? 20 : 24,
                ),
              ),
              const SizedBox(width: 16),
              // Activity details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEntry ? 'Entrada' : 'Salida',
                      style: (compact 
                          ? fluentTheme.typography.body 
                          : fluentTheme.typography.bodyStrong)?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: fluentTheme.typography.caption?.copyWith(
                          color: fluentTheme.typography.body?.color?.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Time and date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('HH:mm').format(timestamp),
                    style: fluentTheme.typography.body?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                  if (showDate) ...[
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('dd/MM').format(timestamp),
                      style: fluentTheme.typography.caption?.copyWith(
                        color: fluentTheme.typography.body?.color?.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ],
              ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                Icon(
                  fluent.FluentIcons.chevron_right,
                  size: 12,
                  color: fluentTheme.typography.body?.color?.withValues(alpha: 0.4),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
