import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../../models/pepito_activity.dart';
import '../../theme/liquid_glass/apple_colors.dart';
import '../../theme/liquid_glass/glass_effects.dart';
import '../../widgets/liquid_glass/components/glass_card.dart';
import '../../widgets/liquid_glass/components/frosted_panel.dart';
import '../../generated/app_localizations.dart';
import 'home_status_section.dart';
import 'home_activities_section.dart';

class LiquidGlassStatusSection extends StatelessWidget {
  const LiquidGlassStatusSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: HomeStatusSection(),
    );
  }
}

class LiquidGlassQuickStats extends StatelessWidget {
  const LiquidGlassQuickStats({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeQuickStats();
  }
}

class LiquidGlassRecentActivities extends StatelessWidget {
  final VoidCallback? onViewAll;

  const LiquidGlassRecentActivities({super.key, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return HomeRecentActivities(onViewAll: onViewAll);
  }
}

class LiquidGlassQuickActions extends StatelessWidget {
  final VoidCallback onStatisticsTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onRefreshTap;
  final VoidCallback? onClearDataTap;

  const LiquidGlassQuickActions({
    super.key,
    required this.onStatisticsTap,
    required this.onNotificationsTap,
    required this.onRefreshTap,
    this.onClearDataTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      accentColor: AppleColors.getActivityColor(ActivityType.entrada),
      padding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppleColors.getActivityColor(
                      ActivityType.entrada,
                    ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppleColors.getActivityColor(
                        ActivityType.entrada,
                      ).withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: GlassEffects.glassShadows(
                      accentColor: AppleColors.getActivityColor(
                        ActivityType.entrada,
                      ),
                      intensity: 0.3,
                    ),
                  ),
                  child: Icon(
                    CupertinoIcons.bolt_fill,
                    color: AppleColors.getActivityColor(ActivityType.entrada),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Acciones rápidas',
                  style: CupertinoTheme.of(context).textTheme.navTitleTextStyle
                      .copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppleColors.textPrimary(context),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LiquidGlassActionCard(
                  icon: CupertinoIcons.chart_bar,
                  title: AppLocalizations.of(context)!.statistics,
                  subtitle: AppLocalizations.of(context)!.viewDetailedAnalysis,
                  color: AppleColors.infoBlue,
                  onTap: onStatisticsTap,
                ),
                const SizedBox(height: 12),
                LiquidGlassActionCard(
                  icon: CupertinoIcons.bell,
                  title: AppLocalizations.of(context)!.notifications,
                  subtitle: AppLocalizations.of(context)!.configureAlerts,
                  color: AppleColors.warningOrange,
                  onTap: onNotificationsTap,
                ),
                const SizedBox(height: 12),
                LiquidGlassActionCard(
                  icon: CupertinoIcons.refresh,
                  title: 'Actualizar datos',
                  subtitle: 'Sincronizar información',
                  color: AppleColors.successGreen,
                  onTap: onRefreshTap,
                ),
                const SizedBox(height: 12),
                if (kDebugMode && onClearDataTap != null)
                  LiquidGlassActionCard(
                    icon: CupertinoIcons.trash,
                    title: '🧹 [DEBUG] Limpiar Duplicados',
                    subtitle: 'Solo disponible en desarrollo',
                    color: AppleColors.warningOrange,
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

class LiquidGlassActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const LiquidGlassActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FrostedPanel(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: color.withValues(alpha: 0.1),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: GlassEffects.glassShadows(
                  accentColor: color,
                  intensity: 0.2,
                ),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: CupertinoTheme.of(context).textTheme.textStyle
                        .copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppleColors.textPrimary(context),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: CupertinoTheme.of(context)
                        .textTheme
                        .tabLabelTextStyle
                        .copyWith(
                          fontSize: 13,
                          color: AppleColors.textSecondary(context),
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: color.withValues(alpha: 0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
