import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

/// Statistics card widget implementing Windows Fluent Design
class FluentStatisticsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const FluentStatisticsCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fluentTheme = fluent.FluentTheme.of(context);
    final isDark = fluentTheme.brightness == Brightness.dark;
    final accentColor = color ?? fluentTheme.accentColor.defaultBrushFor(fluentTheme.brightness);
    
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: accentColor,
                      size: 22,
                    ),
                  ),
                  const Spacer(),
                  if (onTap != null)
                    Icon(
                      fluent.FluentIcons.chevron_right,
                      size: 12,
                      color: fluentTheme.typography.body?.color?.withValues(alpha: 0.4),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: fluentTheme.typography.caption?.copyWith(
                  color: fluentTheme.typography.body?.color?.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: fluentTheme.typography.title?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? const Color(0xFF383838) 
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    subtitle!,
                    style: fluentTheme.typography.caption?.copyWith(
                      color: fluentTheme.typography.body?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
