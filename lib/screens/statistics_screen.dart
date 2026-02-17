import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pepito_providers.dart';
import '../widgets/statistics_widgets.dart';
import '../utils/theme_utils.dart';
import '../utils/date_utils.dart';
import '../models/pepito_activity.dart';
import '../generated/app_localizations.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late TabController _tabController;
  DateRange _selectedPeriod = AppDateUtils.thisWeek;

  final List<DateRange> _predefinedPeriods = [
    AppDateUtils.today,
    AppDateUtils.thisWeek,
    AppDateUtils.thisMonth,
    DateRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    ),
  ];

  List<String> get _periodLabels => [
    AppLocalizations.of(context)!.today,
    AppLocalizations.of(context)!.thisWeek,
    AppLocalizations.of(context)!.thisMonth,
    AppLocalizations.of(context)!.last30Days,
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildAppBar(colorScheme),
          _buildPeriodSelector(),
          _buildTabBar(colorScheme),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildChartsTab(),
            _buildInsightsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(ColorScheme colorScheme) {
    return SliverAppBar(
      title: Text(
        AppLocalizations.of(context)!.statistics,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      floating: true,
      snap: true,
      actions: [
        IconButton(
          onPressed: _selectCustomPeriod,
          icon: const Icon(Icons.date_range),
        ),
        IconButton(
          onPressed: () => _refreshData(),
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return SliverToBoxAdapter(
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _predefinedPeriods.length,
          itemBuilder: (context, index) {
            final period = _predefinedPeriods[index];
            final label = _periodLabels[index];
            final isSelected = _isPeriodSelected(period);

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    _selectedPeriod = period;
                  });
                  _refreshData();
                },
                selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                checkmarkColor: AppTheme.primaryColor,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabBar(ColorScheme colorScheme) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverTabBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.6),
          indicatorColor: AppTheme.primaryColor,
          tabs: [
            Tab(text: AppLocalizations.of(context)!.overview),
            Tab(text: AppLocalizations.of(context)!.charts),
            Tab(text: AppLocalizations.of(context)!.analysis),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer(
      builder: (context, ref, child) {
        final statisticsAsync = ref.watch(
          statisticsProvider(
            StatisticsParams(
              startDate: _selectedPeriod.start,
              endDate: _selectedPeriod.end,
            ),
          ),
        );

        return statisticsAsync.when(
          data: (statistics) => _buildOverviewContent(statistics),
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(error.toString()),
        );
      },
    );
  }

  Widget _buildOverviewContent(Map<String, dynamic> statistics) {
    final activities = statistics['activities'] as List<PepitoActivity>? ?? [];
    final entryCount = activities.where((a) => a.isEntry).length;
    final exitCount = activities.where((a) => !a.isEntry).length;
    final totalActivities = activities.length;
    final daysInPeriod = _getDaysInPeriod();
    final averageDaily = daysInPeriod > 0
        ? totalActivities / daysInPeriod
        : 0.0;
    final note = statistics['note'] as String?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Información sobre limitaciones de datos
          if (note != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.infoColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.infoColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.importantInformation,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.infoColor,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          note,
                          style: TextStyle(
                            color: AppTheme.infoColor.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${AppLocalizations.of(context)!.currentStatusOnly} (${activities.isNotEmpty ? activities.first.displayTypeLocalized(context) : AppLocalizations.of(context)!.noData}).',
                          style: TextStyle(
                            color: AppTheme.infoColor.withValues(alpha: 0.8),
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          // Quick stats grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              StatisticsCard(
                title: AppLocalizations.of(context)!.totalActivities,
                value: totalActivities.toString(),
                subtitle: AppLocalizations.of(context)!.inSelectedPeriod,
                icon: Icons.timeline,
                color: AppTheme.primaryColor,
              ),
              StatisticsCard(
                title: AppLocalizations.of(context)!.entries,
                value: entryCount.toString(),
                subtitle: totalActivities > 0
                    ? '${((entryCount / totalActivities) * 100).toStringAsFixed(1)}${AppLocalizations.of(context)!.percentOfTotal}'
                    : '0${AppLocalizations.of(context)!.percentOfTotal}',
                icon: Icons.home,
                color: AppTheme.successColor,
              ),
              StatisticsCard(
                title: AppLocalizations.of(context)!.exits,
                value: exitCount.toString(),
                subtitle: totalActivities > 0
                    ? '${((exitCount / totalActivities) * 100).toStringAsFixed(1)}${AppLocalizations.of(context)!.percentOfTotal}'
                    : '0${AppLocalizations.of(context)!.percentOfTotal}',
                icon: Icons.logout,
                color: AppTheme.warningColor,
              ),
              StatisticsCard(
                title: AppLocalizations.of(context)!.dailyAverage,
                value: averageDaily.toStringAsFixed(1),
                subtitle: AppLocalizations.of(context)!.activitiesPerDay,
                icon: Icons.trending_up,
                color: AppTheme.infoColor,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Activity summary
          ActivitySummaryCard(
            activities: activities,
            period: _getPeriodLabel(),
          ),
          const SizedBox(height: 16),
          // Time analysis
          _buildTimeAnalysisCard(activities),
        ],
      ),
    );
  }

  Widget _buildChartsTab() {
    return Consumer(
      builder: (context, ref, child) {
        final statisticsAsync = ref.watch(
          statisticsProvider(
            StatisticsParams(
              startDate: _selectedPeriod.start,
              endDate: _selectedPeriod.end,
            ),
          ),
        );

        return statisticsAsync.when(
          data: (statistics) => _buildChartsContent(statistics),
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(error.toString()),
        );
      },
    );
  }

  Widget _buildChartsContent(Map<String, dynamic> statistics) {
    final activities = statistics['activities'] as List<PepitoActivity>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Activity chart
          ActivityChart(
            activities: activities,
            title: AppLocalizations.of(context)!.activitiesPerDay,
            dateRange: _selectedPeriod,
          ),
          const SizedBox(height: 16),
          // Hourly distribution
          _buildHourlyDistributionChart(activities),
          const SizedBox(height: 16),
          // Weekly pattern
          if (_selectedPeriod.start
                  .difference(_selectedPeriod.end)
                  .inDays
                  .abs() >=
              7)
            _buildWeeklyPatternChart(activities),
        ],
      ),
    );
  }

  Widget _buildInsightsTab() {
    return Consumer(
      builder: (context, ref, child) {
        final statisticsAsync = ref.watch(
          statisticsProvider(
            StatisticsParams(
              startDate: _selectedPeriod.start,
              endDate: _selectedPeriod.end,
            ),
          ),
        );

        return statisticsAsync.when(
          data: (statistics) => _buildInsightsContent(statistics),
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(error.toString()),
        );
      },
    );
  }

  Widget _buildInsightsContent(Map<String, dynamic> statistics) {
    final activities = statistics['activities'] as List<PepitoActivity>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildBehaviorInsights(activities),
          const SizedBox(height: 16),
          _buildPatternInsights(activities),
          const SizedBox(height: 16),
          _buildRecommendations(activities),
        ],
      ),
    );
  }

  Widget _buildTimeAnalysisCard(List<PepitoActivity> activities) {
    if (activities.isEmpty) {
      return const SizedBox.shrink();
    }

    final mostActiveHour = _getMostActiveHour(activities);
    final leastActiveHour = _getLeastActiveHour(activities);
    final averageConfidence = _getAverageConfidence(activities);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.timeAnalysis,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildInsightRow(
              icon: Icons.schedule,
              title: AppLocalizations.of(context)!.mostActiveHour,
              value: '$mostActiveHour:00',
              color: AppTheme.successColor,
            ),
            const SizedBox(height: 8),
            _buildInsightRow(
              icon: Icons.schedule_outlined,
              title: AppLocalizations.of(context)!.leastActiveHour,
              value: '$leastActiveHour:00',
              color: AppTheme.infoColor,
            ),
            const SizedBox(height: 8),
            _buildInsightRow(
              icon: Icons.verified,
              title: AppLocalizations.of(context)!.averageConfidence,
              value: '${(averageConfidence * 100).toStringAsFixed(1)}%',
              color: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyDistributionChart(List<PepitoActivity> activities) {
    final hourlyData = _getHourlyDistribution(activities);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.hourlyDistribution,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(24, (hour) {
                  final count = hourlyData[hour] ?? 0;
                  final maxCount = hourlyData.values.isEmpty
                      ? 1
                      : hourlyData.values.reduce((a, b) => a > b ? a : b);
                  final height = maxCount > 0 ? (count / maxCount) * 160 : 0.0;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: height,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.8,
                              ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (hour % 4 == 0)
                            Text(
                              '${hour}h',
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyPatternChart(List<PepitoActivity> activities) {
    final weeklyData = _getWeeklyDistribution(activities);
    final weekdays = [
      AppLocalizations.of(context)!.monday,
      AppLocalizations.of(context)!.tuesday,
      AppLocalizations.of(context)!.wednesday,
      AppLocalizations.of(context)!.thursday,
      AppLocalizations.of(context)!.friday,
      AppLocalizations.of(context)!.saturday,
      AppLocalizations.of(context)!.sunday,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.weeklyPattern,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (dayIndex) {
                  final count = weeklyData[dayIndex + 1] ?? 0;
                  final maxCount = weeklyData.values.isEmpty
                      ? 1
                      : weeklyData.values.reduce((a, b) => a > b ? a : b);
                  final height = maxCount > 0 ? (count / maxCount) * 160 : 0.0;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: height,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.8,
                              ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            weekdays[dayIndex],
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBehaviorInsights(List<PepitoActivity> activities) {
    final insights = _generateBehaviorInsights(activities);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.behaviorInsights,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...insights.map((insight) => _buildInsightItem(insight)),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternInsights(List<PepitoActivity> activities) {
    final patterns = _generatePatternInsights(activities);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.detectedPatterns,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...patterns.map((pattern) => _buildInsightItem(pattern)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(List<PepitoActivity> activities) {
    final recommendations = _generateRecommendations(activities);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.recommendations,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...recommendations.map(
              (recommendation) => _buildRecommendationItem(recommendation),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightItem(String insight) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, size: 16, color: AppTheme.warningColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              insight,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String recommendation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.recommend, size: 16, color: AppTheme.successColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              recommendation,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.errorLoadingStatistics,
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
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshData,
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  bool _isPeriodSelected(DateRange period) {
    return AppDateUtils.isSameDay(_selectedPeriod.start, period.start) &&
        AppDateUtils.isSameDay(_selectedPeriod.end, period.end);
  }

  String _getPeriodLabel() {
    final index = _predefinedPeriods.indexWhere((p) => _isPeriodSelected(p));
    if (index != -1) {
      return _periodLabels[index].toLowerCase();
    }
    return AppLocalizations.of(context)!.customPeriod;
  }

  int _getDaysInPeriod() {
    final days =
        _selectedPeriod.end.difference(_selectedPeriod.start).inDays + 1;
    return days > 0
        ? days
        : 1; // Ensure at least 1 day to avoid division by zero
  }

  int _getMostActiveHour(List<PepitoActivity> activities) {
    final hourCounts = _getHourlyDistribution(activities);
    if (hourCounts.isEmpty) return 12;
    return hourCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  int _getLeastActiveHour(List<PepitoActivity> activities) {
    final hourCounts = _getHourlyDistribution(activities);
    if (hourCounts.isEmpty) return 3;
    return hourCounts.entries.reduce((a, b) => a.value < b.value ? a : b).key;
  }

  double _getAverageConfidence(List<PepitoActivity> activities) {
    final activitiesWithConfidence = activities.where(
      (a) => a.confidence != null,
    );
    if (activitiesWithConfidence.isEmpty) return 0.0;
    return activitiesWithConfidence
            .map((a) => a.confidence!)
            .reduce((a, b) => a + b) /
        activitiesWithConfidence.length;
  }

  Map<int, int> _getHourlyDistribution(List<PepitoActivity> activities) {
    final Map<int, int> hourCounts = {};
    for (final activity in activities) {
      final hour = activity.dateTime.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }
    return hourCounts;
  }

  Map<int, int> _getWeeklyDistribution(List<PepitoActivity> activities) {
    final Map<int, int> weekdayCounts = {};
    for (final activity in activities) {
      final weekday = activity.dateTime.weekday;
      weekdayCounts[weekday] = (weekdayCounts[weekday] ?? 0) + 1;
    }
    return weekdayCounts;
  }

  List<String> _generateBehaviorInsights(List<PepitoActivity> activities) {
    final insights = <String>[];

    if (activities.isEmpty) {
      insights.add(AppLocalizations.of(context)!.notEnoughDataInsights);
      return insights;
    }

    final entryCount = activities.where((a) => a.isEntry).length;
    final exitCount = activities.where((a) => !a.isEntry).length;

    if (entryCount > exitCount) {
      insights.add(AppLocalizations.of(context)!.spendsMoreTimeInside);
    } else if (exitCount > entryCount) {
      insights.add(AppLocalizations.of(context)!.adventurousOutside);
    }

    final mostActiveHour = _getMostActiveHour(activities);
    if (mostActiveHour >= 6 && mostActiveHour <= 10) {
      insights.add(AppLocalizations.of(context)!.moreActiveMornings);
    } else if (mostActiveHour >= 18 && mostActiveHour <= 22) {
      insights.add(AppLocalizations.of(context)!.prefersEveningActivities);
    }

    return insights;
  }

  List<String> _generatePatternInsights(List<PepitoActivity> activities) {
    final patterns = <String>[];

    if (activities.isEmpty) {
      patterns.add(AppLocalizations.of(context)!.notEnoughDataPatterns);
      return patterns;
    }

    final weeklyData = _getWeeklyDistribution(activities);
    final maxWeekday = weeklyData.entries.isEmpty
        ? 1
        : weeklyData.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    final weekdays = [
      '',
      AppLocalizations.of(context)!.monday.toLowerCase(),
      AppLocalizations.of(context)!.tuesday.toLowerCase(),
      AppLocalizations.of(context)!.wednesday.toLowerCase(),
      AppLocalizations.of(context)!.thursday.toLowerCase(),
      AppLocalizations.of(context)!.friday.toLowerCase(),
      AppLocalizations.of(context)!.saturday.toLowerCase(),
      AppLocalizations.of(context)!.sunday.toLowerCase(),
    ];
    patterns.add(
      AppLocalizations.of(context)!.mostActiveDays(weekdays[maxWeekday]),
    );

    final daysInPeriod = _getDaysInPeriod();
    final averageDaily = daysInPeriod > 0
        ? activities.length / daysInPeriod
        : 0.0;
    if (averageDaily > 5) {
      patterns.add(AppLocalizations.of(context)!.regularActivityPattern);
    } else if (averageDaily < 2) {
      patterns.add(AppLocalizations.of(context)!.lowActivityPeriods);
    }

    return patterns;
  }

  List<String> _generateRecommendations(List<PepitoActivity> activities) {
    final recommendations = <String>[];

    if (activities.isEmpty) {
      recommendations.add(AppLocalizations.of(context)!.configureNotifications);
      return recommendations;
    }

    final averageConfidence = _getAverageConfidence(activities);
    if (averageConfidence < 0.7) {
      recommendations.add(
        AppLocalizations.of(context)!.adjustSensorConfiguration,
      );
    }

    final entryCount = activities.where((a) => a.isEntry).length;
    final exitCount = activities.where((a) => !a.isEntry).length;

    if (exitCount > entryCount * 1.5) {
      recommendations.add(AppLocalizations.of(context)!.checkOutdoorSafety);
    }

    recommendations.add(
      AppLocalizations.of(context)!.reviewStatisticsRegularly,
    );

    return recommendations;
  }

  Future<void> _selectCustomPeriod() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _selectedPeriod.start,
        end: _selectedPeriod.end,
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedPeriod = DateRange(start: picked.start, end: picked.end);
      });
      _refreshData();
    }
  }

  void _refreshData() {
    ref.invalidate(statisticsProvider);
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
