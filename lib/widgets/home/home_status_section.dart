import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/adaptive/adaptive_status_card.dart';
import '../../widgets/adaptive/adaptive_skeleton.dart';
import '../../widgets/liquid_glass/statistics/liquid_statistics_card.dart';
import '../../theme/liquid_glass/apple_colors.dart';
import '../../models/pepito_activity.dart';
import '../../providers/pepito_providers.dart';
import '../../utils/theme_utils.dart';

class HomeStatusSection extends ConsumerWidget {
  const HomeStatusSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(pepitoStatusProvider);
    final error = ref.watch(errorProvider);

    if (error != null) {
      return ErrorCard(
        error: error,
        onRefresh: () => ref.read(refreshProvider).refreshAll(),
      );
    }

    return statusAsync.when(
      data: (status) => AdaptiveStatusCard(
        status: status,
        onRefresh: () => ref.read(refreshProvider).refreshStatus(),
        isLoading: ref.watch(loadingProvider),
      ),
      loading: () => const AdaptiveCardSkeleton(height: 200),
      error: (error, stack) => ErrorCard(
        error: error.toString(),
        onRefresh: () => ref.read(refreshProvider).refreshAll(),
      ),
    );
  }
}

class HomeQuickStats extends ConsumerWidget {
  const HomeQuickStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allActivitiesAsync = ref.watch(allActivitiesProvider);

    return allActivitiesAsync.when(
      data: (activities) => QuickStatsRow(activities: activities),
      loading: () => const AdaptiveStatsRowSkeleton(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}

class LoadingStatusCard extends StatelessWidget {
  const LoadingStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptiveCardSkeleton(height: 200);
  }
}

class LoadingStatsRow extends StatelessWidget {
  const LoadingStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptiveStatsRowSkeleton();
  }
}

class QuickStatsRow extends StatelessWidget {
  final List<PepitoActivity> activities;

  const QuickStatsRow({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    final entryCount = activities.where((a) => a.type == 'in').length;
    final exitCount = activities.where((a) => a.type == 'out').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: LiquidStatisticsCard(
              title: 'Entradas',
              value: entryCount.toString(),
              icon: CupertinoIcons.arrow_down_circle_fill,
              color: AppleColors.successGreen,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LiquidStatisticsCard(
              title: 'Salidas',
              value: exitCount.toString(),
              icon: CupertinoIcons.arrow_up_circle_fill,
              color: AppleColors.warningOrange,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LiquidStatisticsCard(
              title: 'Total',
              value: activities.length.toString(),
              icon: CupertinoIcons.chart_pie_fill,
              color: AppleColors.infoBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class ErrorCard extends StatelessWidget {
  final String error;
  final VoidCallback onRefresh;

  const ErrorCard({super.key, required this.error, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text(
              'Error al cargar datos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.getColors(
                  context,
                ).onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
