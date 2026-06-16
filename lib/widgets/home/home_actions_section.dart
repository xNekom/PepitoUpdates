import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../utils/theme_utils.dart';
import '../../generated/app_localizations.dart';

class HomeQuickActions extends StatelessWidget {
  final VoidCallback onStatisticsTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onRefreshTap;
  final VoidCallback? onClearDataTap;

  const HomeQuickActions({
    super.key,
    required this.onStatisticsTap,
    required this.onNotificationsTap,
    required this.onRefreshTap,
    this.onClearDataTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: AppTheme.primaryColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Acciones rápidas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getColors(context).onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                ActionCard(
                  icon: Icons.timeline,
                  title: AppLocalizations.of(context)!.statistics,
                  subtitle: AppLocalizations.of(context)!.viewDetailedAnalysis,
                  color: AppTheme.primaryColor,
                  onTap: onStatisticsTap,
                ),
                const SizedBox(height: 12),
                ActionCard(
                  icon: Icons.notifications,
                  title: AppLocalizations.of(context)!.notifications,
                  subtitle: AppLocalizations.of(context)!.configureAlerts,
                  color: AppTheme.warningColor,
                  onTap: onNotificationsTap,
                ),
                const SizedBox(height: 12),
                ActionCard(
                  icon: Icons.refresh,
                  title: 'Actualizar datos',
                  subtitle: 'Sincronizar información',
                  color: AppTheme.successColor,
                  onTap: onRefreshTap,
                ),
                const SizedBox(height: 12),
                if (kDebugMode && onClearDataTap != null)
                  ActionCard(
                    icon: Icons.delete_sweep,
                    title: '🧹 [DEBUG] Limpiar Duplicados',
                    subtitle: 'Solo disponible en desarrollo',
                    color: Colors.orange.withValues(alpha: 0.5),
                    onTap: onClearDataTap!,
                  ),
                const SizedBox(height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.05),
            color.withValues(alpha: 0.02),
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getColors(context).onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.getColors(
                            context,
                          ).onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color.withValues(alpha: 0.6),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
