import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/pepito_activity.dart';
import '../../widgets/material_expressive/status_card.dart' as m3_status;
import '../../widgets/material_expressive/activity_card.dart' as m3_activity;
import '../../widgets/material_expressive/statistics_widgets.dart' as m3_stats;
import '../../providers/pepito_providers.dart';
import '../../generated/app_localizations.dart';
import 'home_status_section.dart';

class Material3StatusSection extends ConsumerWidget {
  const Material3StatusSection({super.key});

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
      data: (status) => m3_status.StatusCard(
        status: status,
        onRefresh: () => ref.read(refreshProvider).refreshStatus(),
        isLoading: ref.watch(loadingProvider),
      ),
      loading: () => const LoadingStatusCard(),
      error: (error, stack) => ErrorCard(
        error: error.toString(),
        onRefresh: () => ref.read(refreshProvider).refreshAll(),
      ),
    );
  }
}

class Material3QuickStats extends ConsumerWidget {
  const Material3QuickStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allActivitiesAsync = ref.watch(allActivitiesProvider);

    return allActivitiesAsync.when(
      data: (activities) => Material3QuickStatsRow(activities: activities),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}

class Material3QuickStatsRow extends StatelessWidget {
  final List<PepitoActivity> activities;

  const Material3QuickStatsRow({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    final entryCount = activities.where((a) => a.type == 'in').length;
    final exitCount = activities.where((a) => a.type == 'out').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: m3_stats.StatisticsCard(
              title: 'Entradas',
              value: entryCount.toString(),
              icon: Icons.arrow_downward,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: m3_stats.StatisticsCard(
              title: 'Salidas',
              value: exitCount.toString(),
              icon: Icons.arrow_upward,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: m3_stats.StatisticsCard(
              title: 'Total',
              value: activities.length.toString(),
              icon: Icons.pie_chart,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}

class Material3RecentActivities extends ConsumerWidget {
  const Material3RecentActivities({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayActivitiesAsync = ref.watch(todayActivitiesProvider);

    return todayActivitiesAsync.when(
      data: (activities) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              AppLocalizations.of(context)!.recentActivities,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 8),
          ...activities
              .take(5)
              .map(
                (activity) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: m3_activity.ActivityCard(
                    activity: activity,
                    compact: true,
                  ),
                ),
              ),
        ],
      ),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}

class Material3QuickActions extends StatelessWidget {
  final VoidCallback onRefreshTap;
  final VoidCallback onActivitiesTap;
  final VoidCallback onStatisticsTap;

  const Material3QuickActions({
    super.key,
    required this.onRefreshTap,
    required this.onActivitiesTap,
    required this.onStatisticsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Acciones rápidas',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            QuickActionButton(
              icon: Icons.refresh,
              label: 'Actualizar',
              onTap: onRefreshTap,
            ),
            QuickActionButton(
              icon: Icons.list,
              label: AppLocalizations.of(context)!.activitiesTab,
              onTap: onActivitiesTap,
            ),
            QuickActionButton(
              icon: Icons.analytics,
              label: AppLocalizations.of(context)!.statistics,
              onTap: onStatisticsTap,
            ),
          ],
        ),
      ],
    );
  }
}

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FilledButton.tonal(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          child: Icon(icon),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
