import 'package:flutter/material.dart';
import '../../generated/app_localizations.dart';
import '../../models/pepito_activity.dart';
import '../../utils/date_utils.dart';
import '../../utils/theme_utils.dart';

class StatisticsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const StatisticsCard({
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cardColor = color ?? colorScheme.primary;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 600;
    
    // Responsive sizing
    final iconSize = isSmallScreen ? 16.0 : 20.0;
    final valueFontSize = isSmallScreen ? 20.0 : 24.0;
    final titleFontSize = isSmallScreen ? 12.0 : 14.0;
    final subtitleFontSize = isSmallScreen ? 10.0 : 12.0;
    final padding = isSmallScreen ? 12.0 : 16.0;
    
    return Card(
      elevation: 8, // M3E: Elevación expresiva
      shadowColor: cardColor.withValues(alpha: 0.3), // M3E: Sombra colorida
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24), // M3E: Bordes más expresivos
        side: BorderSide(
          color: cardColor.withValues(alpha: 0.2), // M3E: Borde sutil colorido
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24), // M3E: Bordes consistentes
        child: Container(
          constraints: BoxConstraints(
            minHeight: isSmallScreen ? 90 : 120, // M3E: Altura más expresiva
          ),
          padding: EdgeInsets.all(padding * 1.2), // M3E: Padding más generoso
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cardColor.withValues(alpha: 0.15), // M3E: Gradiente más visible
                cardColor.withValues(alpha: 0.08),
                AppTheme.expressiveTeal.withValues(alpha: 0.05), // M3E: Color secundario
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 10 : 12), // M3E: Padding más expresivo
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cardColor.withValues(alpha: 0.3), // M3E: Gradiente expresivo
                          AppTheme.expressivePurple.withValues(alpha: 0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16), // M3E: Bordes más expresivos
                      boxShadow: [
                        BoxShadow(
                          color: cardColor.withValues(alpha: 0.2), // M3E: Sombra colorida
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: cardColor,
                      size: iconSize * 1.2, // M3E: Icono más prominente
                    ),
                  ),
                  const Spacer(),
                  if (onTap != null)
                    Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      size: iconSize,
                    ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: valueFontSize,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              SizedBox(height: isSmallScreen ? 2 : 4),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: isSmallScreen ? 1 : 2,
                ),
              ),
              if (subtitle != null && !isSmallScreen) ...[
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
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

class ActivityChart extends StatelessWidget {
  final List<PepitoActivity> activities;
  final String title;
  final DateRange dateRange;

  const ActivityChart({
    super.key,
    required this.activities,
    required this.title,
    required this.dateRange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 600;
    
    // Responsive padding and sizing
    final padding = isSmallScreen ? 12.0 : 16.0;
    final margin = isSmallScreen ? 12.0 : 16.0;
    final chartHeight = isSmallScreen ? 150.0 : 200.0;
    final titleFontSize = isSmallScreen ? 16.0 : 18.0;
    
    return Card(
      elevation: 12, // M3E: Elevación expresiva para gráficos
      shadowColor: AppTheme.primaryOrange.withValues(alpha: 0.3), // M3E: Sombra colorida
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28), // M3E: Bordes más expresivos
        side: BorderSide(
          color: AppTheme.expressiveTeal.withValues(alpha: 0.2), // M3E: Borde colorido
          width: 2,
        ),
      ),
      margin: EdgeInsets.all(margin),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryOrange.withValues(alpha: 0.08), // M3E: Gradiente expresivo
              AppTheme.expressiveTeal.withValues(alpha: 0.05),
              AppTheme.expressivePurple.withValues(alpha: 0.03),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(padding * 1.3), // M3E: Padding más generoso
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: isSmallScreen ? 1 : 2,
                ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: chartHeight,
                    minHeight: 100,
                  ),
                  child: _buildChart(colorScheme, context),
                ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              _buildLegend(colorScheme, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart(ColorScheme colorScheme, BuildContext context) {
    final dailyActivities = _groupActivitiesByDay();
    final maxActivities = dailyActivities.values.isEmpty 
        ? 1 
        : dailyActivities.values.reduce((a, b) => a > b ? a : b);
    
    if (dailyActivities.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noDataAvailable,
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      );
    }
    
    if (maxActivities == 0) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noActivitiesInPeriod,
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      );
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth <= 600;
        final maxHeight = constraints.maxHeight - 40; // Reserve space for labels
        final barSpacing = isSmallScreen ? 1.0 : 2.0;
        final fontSize = isSmallScreen ? 10.0 : 12.0;
        
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
            ),
            child: IntrinsicWidth(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: dailyActivities.entries.map((entry) {
                  final day = entry.key;
                  final count = entry.value;
                  final height = (count / maxActivities) * maxHeight;
                  
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: barSpacing),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Container(
                              width: double.infinity,
                              height: height.clamp(4.0, maxHeight),
                              constraints: BoxConstraints(
                                minHeight: count > 0 ? 4.0 : 0.0,
                                maxHeight: maxHeight,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    AppTheme.primaryOrange, // M3E: Gradiente expresivo
                                    AppTheme.expressiveTeal,
                                    AppTheme.expressivePurple.withValues(alpha: 0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12), // M3E: Bordes más expresivos
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryOrange.withValues(alpha: 0.3), // M3E: Sombra colorida
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Flexible(
                            child: Text(
                              AppDateUtils.formatDayShort(day),
                              style: TextStyle(
                                fontSize: fontSize,
                                color: colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegend(ColorScheme colorScheme, BuildContext context) {
    final entryCount = activities.where((a) => a.isEntry).length;
    final exitCount = activities.where((a) => !a.isEntry).length;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 600;
    
    if (isSmallScreen) {
      // Layout vertical para pantallas pequeñas
      return Column(
        children: [
          _buildLegendItem(
          color: AppTheme.successColor,
          label: AppLocalizations.of(context)!.entries,
          count: entryCount,
          colorScheme: colorScheme,
          context: context,
        ),
          const SizedBox(height: 8),
          _buildLegendItem(
          color: AppTheme.warningColor,
          label: AppLocalizations.of(context)!.exits,
          count: exitCount,
          colorScheme: colorScheme,
          context: context,
        ),
        ],
      );
    }
    
    // Layout horizontal para pantallas más grandes
    return Wrap(
      alignment: WrapAlignment.spaceAround,
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem(
          color: AppTheme.successColor,
          label: AppLocalizations.of(context)!.entries,
          count: entryCount,
          colorScheme: colorScheme,
          context: context,
        ),
        _buildLegendItem(
          color: AppTheme.warningColor,
          label: AppLocalizations.of(context)!.exits,
          count: exitCount,
          colorScheme: colorScheme,
          context: context,
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required int count,
    required ColorScheme colorScheme,
    required BuildContext context,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 600;
    final fontSize = isSmallScreen ? 12.0 : 14.0;
    final iconSize = isSmallScreen ? 10.0 : 12.0;
    
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '$label ($count)',
              style: TextStyle(
                fontSize: fontSize,
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Map<DateTime, int> _groupActivitiesByDay() {
    final Map<DateTime, int> dailyActivities = {};
    
    // Initialize all days in the range with 0
    DateTime current = AppDateUtils.startOfDay(dateRange.start);
    final end = AppDateUtils.startOfDay(dateRange.end);
    
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      dailyActivities[current] = 0;
      current = current.add(const Duration(days: 1));
    }
    
    // Count activities for each day
    for (final activity in activities) {
      final day = AppDateUtils.startOfDay(activity.dateTime);
      if (dailyActivities.containsKey(day)) {
        dailyActivities[day] = dailyActivities[day]! + 1;
      }
    }
    
    return dailyActivities;
  }
}

class ActivitySummaryCard extends StatelessWidget {
  final List<PepitoActivity> activities;
  final String period;

  const ActivitySummaryCard({
    super.key,
    required this.activities,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final entryActivities = activities.where((a) => a.isEntry).toList();
    final exitActivities = activities.where((a) => !a.isEntry).toList();
    
    return Card(
      elevation: 10, // M3E: Elevación expresiva
      shadowColor: AppTheme.expressiveTeal.withValues(alpha: 0.3), // M3E: Sombra colorida
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26), // M3E: Bordes más expresivos
        side: BorderSide(
          color: AppTheme.primaryOrange.withValues(alpha: 0.2), // M3E: Borde colorido
          width: 1.8,
        ),
      ),
      margin: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.expressiveTeal.withValues(alpha: 0.08), // M3E: Gradiente expresivo
              AppTheme.primaryOrange.withValues(alpha: 0.05),
              AppTheme.expressivePurple.withValues(alpha: 0.03),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20), // M3E: Padding más generoso
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppLocalizations.of(context)!.summaryOf} $period',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      icon: Icons.home,
                      label: AppLocalizations.of(context)!.entries,
                      count: entryActivities.length,
                      color: AppTheme.successColor,
                      colorScheme: colorScheme,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryItem(
                      icon: Icons.logout,
                      label: AppLocalizations.of(context)!.exits,
                      count: exitActivities.length,
                      color: AppTheme.warningColor,
                      colorScheme: colorScheme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTimeAnalysis(colorScheme, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.all(20), // M3E: Padding más expresivo
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15), // M3E: Gradiente expresivo
            AppTheme.expressiveTeal.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20), // M3E: Bordes más expresivos
        border: Border.all(
          color: color.withValues(alpha: 0.4), // M3E: Borde más visible
          width: 2, // M3E: Borde más prominente
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2), // M3E: Sombra colorida
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeAnalysis(ColorScheme colorScheme, BuildContext context) {
    if (activities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          AppLocalizations.of(context)!.noActivitiesInPeriod,
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      );
    }
    
    final mostActiveHour = _getMostActiveHour();
    // Calculate days in the actual period instead of assuming 7 days
    final daysDifference = activities.isNotEmpty 
        ? activities.map((a) => DateTime(a.dateTime.year, a.dateTime.month, a.dateTime.day))
            .toSet().length
        : 1;
    final averageDaily = daysDifference > 0 
        ? (activities.length / daysDifference).toStringAsFixed(1)
        : '0.0';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.timeAnalysis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              Text(
                '${AppLocalizations.of(context)!.mostActiveHour}: ${mostActiveHour}h',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.trending_up,
                size: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              Text(
                '${AppLocalizations.of(context)!.dailyAverage}: $averageDaily ${AppLocalizations.of(context)!.activities}',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _getMostActiveHour() {
    final hourCounts = <int, int>{};
    
    for (final activity in activities) {
      final hour = activity.dateTime.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }
    
    if (hourCounts.isEmpty) return 12;
    
    return hourCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}

class QuickStatsRow extends StatelessWidget {
  final List<PepitoActivity> todayActivities;
  final PepitoStatus? status;

  const QuickStatsRow({
    super.key,
    required this.todayActivities,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    final entryCount = todayActivities.where((a) => a.isEntry).length;
    final exitCount = todayActivities.where((a) => !a.isEntry).length;
    final timeAtHome = _calculateTimeAtHome(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 600;
    
    // Para pantallas muy pequeñas, usar layout vertical
    if (isSmallScreen && screenWidth <= 400) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            StatisticsCard(
              title: AppLocalizations.of(context)!.entriesToday,
              value: entryCount.toString(),
              icon: Icons.home,
              color: AppTheme.successColor,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: StatisticsCard(
                    title: AppLocalizations.of(context)!.exitsToday,
                    value: exitCount.toString(),
                    icon: Icons.logout,
                    color: AppTheme.warningColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatisticsCard(
                    title: AppLocalizations.of(context)!.timeAtHome,
                    value: timeAtHome,
                    icon: Icons.schedule,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    
    // Layout horizontal normal con espaciado responsive
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final spacing = constraints.maxWidth > 600 ? 12.0 : 
                         constraints.maxWidth > 400 ? 8.0 : 4.0;
          
          return Row(
            children: [
              Expanded(
                child: StatisticsCard(
                  title: AppLocalizations.of(context)!.entriesToday,
                  value: entryCount.toString(),
                  icon: Icons.home,
                  color: AppTheme.successColor,
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: StatisticsCard(
                  title: AppLocalizations.of(context)!.exitsToday,
                  value: exitCount.toString(),
                  icon: Icons.logout,
                  color: AppTheme.warningColor,
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: StatisticsCard(
                  title: AppLocalizations.of(context)!.timeAtHome,
                  value: timeAtHome,
                  icon: Icons.schedule,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _calculateTimeAtHome(BuildContext context) {
    // Si no hay estado actual, mostrar estado desconocido
    if (status == null) return 'N/A';
    
    // Si no hay actividades hoy, mostrar solo el estado actual
    if (todayActivities.isEmpty) {
      return status!.isHome 
          ? AppLocalizations.of(context)!.atHomeStatus
          : AppLocalizations.of(context)!.awayStatus;
    }
    
    // Calcular tiempo real basado en las actividades del día
    final now = DateTime.now();
    
    // Ordenar actividades por timestamp
    final sortedActivities = List<PepitoActivity>.from(todayActivities)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    Duration totalTimeAtHome = Duration.zero;
    DateTime? lastEntryTime;
    
    for (final activity in sortedActivities) {
      if (activity.isEntry) {
        lastEntryTime = activity.dateTime;
      } else if (lastEntryTime != null) {
        // Calcular tiempo entre entrada y salida
        final timeAtHome = activity.dateTime.difference(lastEntryTime);
        totalTimeAtHome += timeAtHome;
        lastEntryTime = null;
      }
    }
    
    // Si la última actividad fue una entrada y está en casa, agregar tiempo hasta ahora
    if (lastEntryTime != null && status!.isHome) {
      final timeFromLastEntry = now.difference(lastEntryTime);
      totalTimeAtHome += timeFromLastEntry;
    }
    
    // Formatear el tiempo total
    final hours = totalTimeAtHome.inHours;
    final minutes = totalTimeAtHome.inMinutes % 60;
    
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return status!.isHome 
          ? AppLocalizations.of(context)!.atHomeStatus
          : AppLocalizations.of(context)!.awayStatus;
    }
  }
}