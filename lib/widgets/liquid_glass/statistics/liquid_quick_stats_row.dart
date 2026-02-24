import 'package:flutter/cupertino.dart';
import '../../../models/pepito_activity.dart';
import '../../../generated/app_localizations.dart';
import '../../../theme/liquid_glass/apple_colors.dart';
import '../../../utils/platform_detector.dart';
import 'liquid_statistics_card.dart';

class LiquidQuickStatsRow extends StatelessWidget {
  final List<PepitoActivity> todayActivities;
  final bool compact;

  const LiquidQuickStatsRow({
    super.key,
    required this.todayActivities,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();
    final isDesktop = PlatformDetector.isDesktop;

    return Row(
      children: [
        Expanded(
          child: LiquidStatisticsCard(
            title: AppLocalizations.of(context)!.entriesToday,
            value: stats.entries.toString(),
            icon: CupertinoIcons.arrow_down_circle_fill,
            color: AppleColors.successGreen,
          ),
        ),
        SizedBox(width: compact ? 8.0 : 12.0),
        Expanded(
          child: LiquidStatisticsCard(
            title: AppLocalizations.of(context)!.exitsToday,
            value: stats.exits.toString(),
            icon: CupertinoIcons.arrow_up_circle_fill,
            color: AppleColors.errorRed,
          ),
        ),
        SizedBox(width: compact ? 8.0 : 12.0),
        Expanded(
          child: LiquidStatisticsCard(
            title: AppLocalizations.of(context)!.totalActivities,
            value: stats.total.toString(),
            icon: CupertinoIcons.chart_bar_fill,
            color: AppleColors.infoBlue,
          ),
        ),
        if (!compact && isDesktop) ...[
          SizedBox(width: 12.0),
          Expanded(
            child: LiquidStatisticsCard(
            title: 'Confianza Promedio',
              value: '${stats.avgConfidence}%',
              icon: CupertinoIcons.star_fill,
              color: AppleColors.getConfidenceColor(stats.avgConfidence / 100.0),
            ),
          ),
        ],
      ],
    );
  }

  _StatsData _calculateStats() {
    if (todayActivities.isEmpty) {
      return _StatsData(0, 0, 0, 0.0);
    }

    int entries = 0;
    int exits = 0;
    double totalConfidence = 0.0;
    int confidenceCount = 0;

    for (final activity in todayActivities) {
      if (activity.isEntry) {
        entries++;
      } else {
        exits++;
      }

      if (activity.confidence != null) {
        totalConfidence += activity.confidence!;
        confidenceCount++;
      }
    }

    final avgConfidence = confidenceCount > 0
        ? (totalConfidence / confidenceCount * 100).round()
        : 0;

    return _StatsData(entries, exits, entries + exits, avgConfidence.toDouble());
  }
}

class _StatsData {
  final int entries;
  final int exits;
  final int total;
  final double avgConfidence;

  const _StatsData(this.entries, this.exits, this.total, this.avgConfidence);
}