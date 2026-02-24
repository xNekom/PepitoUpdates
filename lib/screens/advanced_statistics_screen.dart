import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/pepito_providers.dart';
import '../utils/theme_utils.dart';
import '../widgets/liquid_glass/components/glass_card.dart';
import '../widgets/liquid_glass/components/frosted_panel.dart';
import '../widgets/material_expressive/statistics_widgets.dart' as m3_stats;
import '../theme/liquid_glass/apple_colors.dart';
import '../theme/liquid_glass/glass_effects.dart';
import '../widgets/liquid_glass/liquid_app_bar.dart';

class AdvancedStatisticsScreen extends ConsumerWidget {
  const AdvancedStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _buildLiquidGlassUI(context, ref);
  }

  Widget _buildLiquidGlassUI(BuildContext context, WidgetRef ref) {
    final colors = AppTheme.getColors(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          LiquidAppBar(title: 'Estadísticas Avanzadas'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildHeader(context, colors),
                  const SizedBox(height: 24),

                  // Estadísticas principales
                  _buildMainStats(context, ref, colors),
                  const SizedBox(height: 24),

                  // Gráfico de líneas - Actividad por día
                  _buildActivityTrendChart(context, ref, colors),
                  const SizedBox(height: 24),

                  // Gráfico circular - Distribución
                  _buildActivityDistributionChart(context, ref, colors),
                  const SizedBox(height: 24),

                  // Gráfico de barras - Actividad por hora
                  _buildHourlyActivityChart(context, ref, colors),
                  const SizedBox(height: 24),

                  // Análisis de patrones
                  _buildPatternAnalysis(context, ref, colors),
                  
                  // Padding extra for bottom navbar
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterial3ExpressiveUI(BuildContext context, WidgetRef ref) {
    final colors = AppTheme.getColors(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas Avanzadas'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 4,
        shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMaterial3ExpressiveHeader(context, colors),
            const SizedBox(height: 24),

            // Estadísticas principales
            _buildMaterial3ExpressiveMainStats(context, ref, colors),
            const SizedBox(height: 24),

            // Gráfico de líneas - Actividad por día
            _buildMaterial3ExpressiveActivityTrendChart(context, ref, colors),
            const SizedBox(height: 24),

            // Gráfico circular - Distribución
            _buildMaterial3ExpressiveActivityDistributionChart(context, ref, colors),
            const SizedBox(height: 24),

            // Gráfico de barras - Actividad por hora
            _buildMaterial3ExpressiveHourlyActivityChart(context, ref, colors),
            const SizedBox(height: 24),

            // Análisis de patrones
            _buildMaterial3ExpressivePatternAnalysis(context, ref, colors),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppColors colors) {
    return GlassCard(
      accentColor: AppleColors.getActivityColor(ActivityType.entrada),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppleColors.getActivityColor(ActivityType.entrada).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppleColors.getActivityColor(ActivityType.entrada).withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: GlassEffects.glassShadows(
                accentColor: AppleColors.getActivityColor(ActivityType.entrada),
                intensity: 0.3,
              ),
            ),
            child: Icon(
              CupertinoIcons.chart_bar_fill,
              color: AppleColors.getActivityColor(ActivityType.entrada),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Análisis Avanzado de Pépito',
                  style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gráficos detallados y análisis de patrones',
                  style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.copyWith(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterial3ExpressiveHeader(BuildContext context, AppColors colors) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 8,
      shadowColor: colorScheme.primary.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.analytics_rounded,
                color: colorScheme.primary,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Análisis Avanzado de Pépito',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gráficos detallados y análisis de patrones',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainStats(BuildContext context, WidgetRef ref, AppColors colors) {
    final statsAsync = ref.watch(statisticsProvider(
      const StatisticsParams(),
    ));

    return statsAsync.when(
      data: (stats) => _buildStatsGrid(context, stats, colors),
      loading: () => _buildLoadingStats(),
      error: (error, stack) => _buildErrorStats(error.toString()),
    );
  }

  Widget _buildMaterial3ExpressiveMainStats(BuildContext context, WidgetRef ref, AppColors colors) {
    final statsAsync = ref.watch(statisticsProvider(
      const StatisticsParams(),
    ));

    return statsAsync.when(
      data: (stats) => _buildMaterial3ExpressiveStatsGrid(context, stats, colors),
      loading: () => _buildLoadingStats(),
      error: (error, stack) => _buildErrorStats(error.toString()),
    );
  }

  Widget _buildMaterial3ExpressiveActivityTrendChart(BuildContext context, WidgetRef ref, AppColors colors) {
    return _buildActivityTrendChart(context, ref, colors);
  }

  Widget _buildMaterial3ExpressiveActivityDistributionChart(BuildContext context, WidgetRef ref, AppColors colors) {
    return _buildActivityDistributionChart(context, ref, colors);
  }

  Widget _buildMaterial3ExpressiveHourlyActivityChart(BuildContext context, WidgetRef ref, AppColors colors) {
    return _buildHourlyActivityChart(context, ref, colors);
  }

  Widget _buildMaterial3ExpressivePatternAnalysis(BuildContext context, WidgetRef ref, AppColors colors) {
    return _buildPatternAnalysis(context, ref, colors);
  }

  Widget _buildStatsGrid(BuildContext context, Map<String, dynamic> stats, AppColors colors) {
    final totalActivities = stats['total_activities'] ?? 0;
    final totalEntries = stats['total_entries'] ?? 0;
    final totalExits = stats['total_exits'] ?? 0;
    final entryPercentage = stats['entry_percentage'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Total',
            totalActivities.toString(),
            Icons.timeline,
            AppTheme.primaryColor,
            colors,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Entradas',
            totalEntries.toString(),
            Icons.login,
            AppTheme.successColor,
            colors,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Salidas',
            totalExits.toString(),
            Icons.logout,
            AppTheme.warningColor,
            colors,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'En Casa',
            '$entryPercentage%',
            Icons.home,
            AppTheme.expressiveTeal,
            colors,
          ),
        ),
      ],
    );
  }

  Widget _buildMaterial3ExpressiveStatsGrid(BuildContext context, Map<String, dynamic> stats, AppColors colors) {
    final totalActivities = stats['total_activities'] ?? 0;
    final totalEntries = stats['total_entries'] ?? 0;
    final totalExits = stats['total_exits'] ?? 0;
    final entryPercentage = stats['entry_percentage'] ?? 0;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width > 600 ? 200 : double.infinity,
          child: m3_stats.StatisticsCard(
            title: 'Total',
            value: totalActivities.toString(),
            icon: Icons.timeline,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width > 600 ? 200 : double.infinity,
          child: m3_stats.StatisticsCard(
            title: 'Entradas',
            value: totalEntries.toString(),
            icon: Icons.login,
            color: Colors.green,
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width > 600 ? 200 : double.infinity,
          child: m3_stats.StatisticsCard(
            title: 'Salidas',
            value: totalExits.toString(),
            icon: Icons.logout,
            color: Colors.orange,
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width > 600 ? 200 : double.infinity,
          child: m3_stats.StatisticsCard(
            title: 'En Casa',
            value: '$entryPercentage%',
            icon: Icons.home,
            color: Colors.teal,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color, AppColors colors) {
    return FrostedPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: color.withValues(alpha: 0.1),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            title,
            style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.copyWith(
              fontSize: 12,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTrendChart(BuildContext context, WidgetRef ref, AppColors colors) {
    final statsAsync = ref.watch(statisticsProvider(
      const StatisticsParams(),
    ));
    
    return GlassCard(
      accentColor: AppleColors.getActivityColor(ActivityType.entrada),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tendencia de Actividad (Últimos 7 días)',
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: statsAsync.when(
              data: (stats) {
                final activities = stats['activities'] as List? ?? [];
                
                if (activities.isEmpty) {
                  return _buildNoDataChart(colors, 'Sin actividades para mostrar tendencia');
                }
                
                return LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final date = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
                            return Text(
                              DateFormat('dd/MM').format(date),
                              style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.copyWith(
                                fontSize: 10,
                                color: CupertinoColors.systemGrey,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _generateRealTrendData(activities), // ✅ DATOS REALES
                        isCurved: true,
                        color: AppleColors.getActivityColor(ActivityType.entrada),
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppleColors.getActivityColor(ActivityType.entrada).withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => _buildLoadingChart(),
              error: (error, stack) => _buildErrorChart(error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityDistributionChart(BuildContext context, WidgetRef ref, AppColors colors) {
    final statsAsync = ref.watch(statisticsProvider(
      const StatisticsParams(),
    ));

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribución de Actividades',
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(
              color: AppleColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 20),
          statsAsync.when(
            data: (stats) {
              final totalEntries = stats['total_entries'] ?? 0;
              final totalExits = stats['total_exits'] ?? 0;
              final total = totalEntries + totalExits;

              if (total == 0) {
                return _buildNoDataChart(colors, 'Sin datos suficientes para el gráfico');
              }

              return SizedBox(
                height: 200,
                child: Row(
                  children: [
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: totalEntries.toDouble(),
                              title: 'Entradas\n$totalEntries',
                              color: AppleColors.successGreen,
                              radius: 80,
                              titleStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: totalExits.toDouble(),
                              title: 'Salidas\n$totalExits',
                              color: AppleColors.warningOrange,
                              radius: 80,
                              titleStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegendItem('Entradas', AppleColors.successGreen, totalEntries, total),
                        const SizedBox(height: 8),
                        _buildLegendItem('Salidas', AppleColors.warningOrange, totalExits, total),
                      ],
                    ),
                  ],
                ),
              );
            },
            loading: () => _buildLoadingChart(),
            error: (error, stack) => _buildErrorChart(error.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyActivityChart(BuildContext context, WidgetRef ref, AppColors colors) {
    final statsAsync = ref.watch(statisticsProvider(
      const StatisticsParams(),
    ));
    
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actividad por Hora del Día',
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(
              color: AppleColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: statsAsync.when(
              data: (stats) {
                final activities = stats['activities'] as List? ?? [];
                
                return BarChart(
                  BarChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}h',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppleColors.textSecondary(context),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: true),
                    barGroups: _generateRealHourlyData(activities), // ✅ DATOS REALES
                  ),
                );
              },
              loading: () => _buildLoadingChart(),
              error: (error, stack) => _buildErrorChart(error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternAnalysis(BuildContext context, WidgetRef ref, AppColors colors) {
    final statsAsync = ref.watch(statisticsProvider(
      const StatisticsParams(),
    ));

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Análisis de Patrones',
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(
              color: AppleColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 20),
          statsAsync.when(
            data: (stats) => _buildPatternInsights(stats, colors),
            loading: () => _buildLoadingPattern(),
            error: (error, stack) => _buildErrorPattern(error.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternInsights(Map<String, dynamic> stats, AppColors colors) {
    final activities = stats['activities'] as List? ?? [];

    return Column(
      children: [
        _buildInsightCard(
          'Hora más activa',
          _getRealMostActiveHour(activities), // ✅ DATOS REALES
          Icons.schedule,
          AppTheme.primaryColor,
          colors,
        ),
        const SizedBox(height: 12),
        _buildInsightCard(
          'Tiempo promedio en casa',
          _getRealAverageTimeAtHome(activities), // ✅ DATOS REALES
          Icons.home_filled,
          AppTheme.successColor,
          colors,
        ),
        const SizedBox(height: 12),
        _buildInsightCard(
          'Patrón de actividad',
          _getRealActivityPattern(activities), // ✅ DATOS REALES
          Icons.trending_up,
          AppTheme.expressiveTeal,
          colors,
        ),
        const SizedBox(height: 12),
        _buildInsightCard(
          'Última actividad',
          _getRealLastActivityTime(activities), // ✅ DATOS REALES
          Icons.access_time,
          AppTheme.warningColor,
          colors,
        ),
      ],
    );
  }

  Widget _buildInsightCard(String title, String value, IconData icon, Color color, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
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
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int value, int total) {
    final percentage = total > 0 ? (value / total * 100).round() : 0;
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$value ($percentage%)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ✅ CORREGIDO: Generar datos reales desde Supabase
  List<FlSpot> _generateRealTrendData(List activities) {
    if (activities.isEmpty) {
      return [FlSpot(0, 0)]; // Sin datos
    }
    
    // Agrupar actividades por día de los últimos 7 días
    final now = DateTime.now();
    final last7Days = <DateTime, int>{};
    
    // Inicializar últimos 7 días con 0
    for (int i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day - i);
      last7Days[day] = 0;
    }
    
    // Contar actividades reales por día
    for (final activity in activities) {
      final activityDay = DateTime(
        activity.timestamp.year,
        activity.timestamp.month,
        activity.timestamp.day,
      );
      
      if (last7Days.containsKey(activityDay)) {
        last7Days[activityDay] = last7Days[activityDay]! + 1;
      }
    }
    
    // Convertir a FlSpot
    final spots = <FlSpot>[];
    int index = 0;
    for (final entry in last7Days.entries) {
      spots.add(FlSpot(index.toDouble(), entry.value.toDouble()));
      index++;
    }
    
    return spots;
  }

  List<BarChartGroupData> _generateRealHourlyData(List activities) {
    if (activities.isEmpty) {
      // Retornar barras vacías
      return List.generate(24, (index) => BarChartGroupData(
        x: index,
        barRods: [BarChartRodData(toY: 0, color: AppTheme.primaryColor, width: 12)],
      ));
    }
    
    // Contar actividades reales por hora
    final hourlyCount = List.filled(24, 0);
    
    for (final activity in activities) {
      final hour = activity.timestamp.hour;
      hourlyCount[hour]++;
    }
    
    // Convertir a BarChartGroupData
    return List.generate(24, (index) => BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: hourlyCount[index].toDouble(),
          color: AppTheme.primaryColor,
          width: 12,
          borderRadius: BorderRadius.circular(2),
        ),
      ],
    ));
  }

  // ✅ CORREGIDO: Análisis real de patrones
  String _getRealMostActiveHour(List activities) {
    if (activities.isEmpty) return 'Sin datos suficientes';
    
    // Contar actividades por hora
    final hourlyCount = <int, int>{};
    for (final activity in activities) {
      final hour = activity.timestamp.hour;
      hourlyCount[hour] = (hourlyCount[hour] ?? 0) + 1;
    }
    
    if (hourlyCount.isEmpty) return 'Sin datos';
    
    // Encontrar la hora con más actividad
    final mostActiveHour = hourlyCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    return '${mostActiveHour.toString().padLeft(2, '0')}:00 - ${(mostActiveHour + 1).toString().padLeft(2, '0')}:00';
  }

  String _getRealAverageTimeAtHome(List activities) {
    if (activities.length < 2) return 'Datos insuficientes';
    
    // Calcular tiempo en casa basado en entradas y salidas
    final entries = activities.where((a) => 
      a.type.toString().contains('entry') || 
      a.type.toString().contains('in')
    ).toList();
    
    final exits = activities.where((a) => 
      a.type.toString().contains('exit') || 
      a.type.toString().contains('out')
    ).toList();
    
    if (entries.isEmpty && exits.isEmpty) return 'Sin datos de movimiento';
    
    // Análisis simplificado: si hay más entradas que salidas, está más tiempo en casa
    final entryPercentage = entries.length / activities.length * 100;
    final hoursAtHome = (entryPercentage / 100 * 24).round();
    
    return '$hoursAtHome horas/día (aprox.)';
  }

  String _getRealActivityPattern(List activities) {
    if (activities.isEmpty) return 'Sin datos suficientes';
    
    // Analizar patrones por hora del día
    final morningCount = activities.where((a) => 
      a.timestamp.hour >= 6 && a.timestamp.hour < 12
    ).length;
    
    final afternoonCount = activities.where((a) => 
      a.timestamp.hour >= 12 && a.timestamp.hour < 18
    ).length;
    
    final eveningCount = activities.where((a) => 
      a.timestamp.hour >= 18 && a.timestamp.hour < 24
    ).length;
    
    final nightCount = activities.where((a) => 
      a.timestamp.hour >= 0 && a.timestamp.hour < 6
    ).length;
    
    // Encontrar el período más activo
    final periods = {
      'mañana': morningCount,
      'tarde': afternoonCount,
      'noche': eveningCount,
      'madrugada': nightCount,
    };
    
    final mostActivePeriod = periods.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    return 'Más activo en la $mostActivePeriod';
  }

  String _getRealLastActivityTime(List activities) {
    if (activities.isEmpty) return 'Sin actividades registradas';
    
    try {
      // Ordenar por timestamp descendente y tomar la primera
      final sortedActivities = activities.toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      final lastActivity = sortedActivities.first;
      final now = DateTime.now();
      final difference = now.difference(lastActivity.timestamp);
      
      if (difference.inMinutes < 1) {
        return 'Hace menos de 1 minuto';
      } else if (difference.inMinutes < 60) {
        return 'Hace ${difference.inMinutes} minutos';
      } else if (difference.inHours < 24) {
        return 'Hace ${difference.inHours} horas';
      } else {
        return 'Hace ${difference.inDays} días';
      }
    } catch (e) {
      return 'Error calculando tiempo';
    }
  }

  // Widgets de loading y error
  Widget _buildLoadingStats() {
    return Row(
      children: List.generate(4, (index) =>
        Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < 3 ? 12 : 0),
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingChart() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildLoadingPattern() {
    return Column(
      children: List.generate(4, (index) =>
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildErrorStats(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('Error: $error'),
    );
  }

  Widget _buildErrorChart(String error) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: Text('Error en gráfico: $error')),
    );
  }

  Widget _buildErrorPattern(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('Error en análisis: $error'),
    );
  }

  Widget _buildNoDataChart(AppColors colors, String message) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 48,
              color: colors.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Los gráficos se mostrarán cuando haya más datos',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}