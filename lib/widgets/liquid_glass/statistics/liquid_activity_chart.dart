import 'package:flutter/cupertino.dart';
import 'dart:ui';
import '../../../models/pepito_activity.dart';
import '../../../generated/app_localizations.dart';
import '../../../utils/date_utils.dart';
import '../../../theme/liquid_glass/glass_effects.dart';
import '../../../theme/liquid_glass/apple_colors.dart';
import '../../../utils/platform_detector.dart';
import '../components/glass_card.dart';

class LiquidActivityChart extends StatelessWidget {
  final List<PepitoActivity> activities;
  final int daysToShow;
  final bool showLabels;

  const LiquidActivityChart({
    super.key,
    required this.activities,
    this.daysToShow = 7,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = PlatformDetector.isDesktop;
    final chartData = _prepareChartData();

    return GlassCard(
      accentColor: CupertinoColors.activeBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLabels) ...[
            Text(
              'Actividad Semanal',
              style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
            ),
            const SizedBox(height: 16.0),
          ],
          SizedBox(
            height: isDesktop ? 200.0 : 150.0,
            child: _buildChart(context, chartData),
          ),
          if (showLabels) ...[
            const SizedBox(height: 12.0),
            _buildLegend(context),
          ],
        ],
      ),
    );
  }

  Map<String, List<int>> _prepareChartData() {
    final now = DateTime.now();
    final data = <String, List<int>>{};

    // Inicializar datos para los últimos N días
    for (int i = daysToShow - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = AppDateUtils.formatDayShort(date);
      data[dateKey] = [0, 0]; // [entradas, salidas]
    }

    // Contar actividades por día
    for (final activity in activities) {
      final dateKey = AppDateUtils.formatDayShort(activity.dateTime);
      if (data.containsKey(dateKey)) {
        if (activity.isEntry) {
          data[dateKey]![0]++;
        } else {
          data[dateKey]![1]++;
        }
      }
    }

    return data;
  }

  Widget _buildChart(BuildContext context, Map<String, List<int>> data) {
    final maxValue = data.values
        .expand((counts) => counts)
        .reduce((a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.entries.map((entry) {
        final date = entry.key;
        final counts = entry.value;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Barra de salidas (arriba)
                if (counts[1] > 0)
                  _buildBarSegment(
                    context,
                    counts[1],
                    maxValue,
                    AppleColors.errorRed,
                    false,
                  ),
                // Barra de entradas (abajo)
                if (counts[0] > 0)
                  _buildBarSegment(
                    context,
                    counts[0],
                    maxValue,
                    AppleColors.successGreen,
                    true,
                  ),
                // Etiqueta de fecha
                const SizedBox(height: 8.0),
                Text(
                  date,
                  style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.copyWith(
                    fontSize: 10.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBarSegment(BuildContext context, int value, int maxValue, Color color, bool isBottom) {
    final height = maxValue > 0 ? (value / maxValue) * 100.0 : 0.0;

    return Container(
      height: height,
      margin: EdgeInsets.only(bottom: isBottom ? 0.0 : 2.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.8),
        borderRadius: BorderRadius.vertical(
          top: isBottom ? Radius.zero : const Radius.circular(4.0),
          bottom: isBottom ? const Radius.circular(4.0) : Radius.zero,
        ),
        boxShadow: GlassEffects.glassShadows(accentColor: color, intensity: 0.3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: isBottom ? Radius.zero : const Radius.circular(4.0),
          bottom: isBottom ? const Radius.circular(4.0) : Radius.zero,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: 0.9),
                  color.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Center(
              child: Text(
                value.toString(),
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 10.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(context, AppLocalizations.of(context)!.entries, AppleColors.successGreen),
        const SizedBox(width: 16.0),
        _buildLegendItem(context, AppLocalizations.of(context)!.exits, AppleColors.errorRed),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12.0,
          height: 12.0,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.0),
          ),
        ),
        const SizedBox(width: 6.0),
        Text(
          label,
          style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle,
        ),
      ],
    );
  }
}