import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/app_localizations.dart';
import '../../providers/pepito_providers.dart';
import '../../utils/theme_utils.dart';
import '../adaptive/adaptive_skeleton.dart';
import 'home.dart';

class HomeWebSidebar extends StatelessWidget {
  final TabController tabController;
  final AppColors colors;
  final bool isLargeScreen;
  final bool isMediumScreen;
  final bool isSmallScreen;

  const HomeWebSidebar({
    super.key,
    required this.tabController,
    required this.colors,
    required this.isLargeScreen,
    required this.isMediumScreen,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    double sidebarWidth;
    double minSidebarWidth;
    bool showLabels;
    double fontSize;
    double iconSize;
    double headerPadding;

    if (isSmallScreen) {
      sidebarWidth = 64.0;
      minSidebarWidth = 64.0;
      showLabels = false;
      fontSize = 12.0;
      iconSize = 18.0;
      headerPadding = 8.0;
    } else if (isMediumScreen && !isLargeScreen) {
      sidebarWidth = 180.0;
      minSidebarWidth = 64.0;
      showLabels = true;
      fontSize = 13.0;
      iconSize = 18.0;
      headerPadding = 12.0;
    } else {
      sidebarWidth = 260.0;
      minSidebarWidth = 64.0;
      showLabels = true;
      fontSize = 14.0;
      iconSize = 20.0;
      headerPadding = 16.0;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: sidebarWidth,
      constraints: BoxConstraints(
        minWidth: minSidebarWidth,
        maxWidth: sidebarWidth,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  AppTheme.expressivePurple.withValues(alpha: 0.08),
                  AppTheme.expressiveTeal.withValues(alpha: 0.05),
                  colors.surface,
                ]
              : [
                  AppTheme.primaryOrange.withValues(alpha: 0.06),
                  AppTheme.expressiveTeal.withValues(alpha: 0.04),
                  const Color(0xFFFAFAFA),
                ],
        ),
        border: Border(
          right: BorderSide(
            color: isDark
                ? AppTheme.expressiveTeal.withValues(alpha: 0.3)
                : AppTheme.primaryOrange.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppTheme.expressivePurple.withValues(alpha: 0.2)
                : AppTheme.primaryOrange.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(3, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(headerPadding),
            child: Row(
              mainAxisAlignment: isSmallScreen
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryOrange.withValues(alpha: 0.2),
                        AppTheme.expressiveTeal.withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.pets,
                    color: AppTheme.primaryOrange,
                    size: iconSize * 1.1,
                  ),
                ),
                if (showLabels) ...[
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Pépito App',
                          style: TextStyle(
                            fontSize: fontSize + 2,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? colors.onSurface
                                : const Color(0xFF1F2937),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        if (isLargeScreen)
                          Text(
                            'Dashboard',
                            style: TextStyle(
                              fontSize: fontSize - 2,
                              color: isDark
                                  ? colors.onSurface.withValues(alpha: 0.6)
                                  : const Color(0xFF6B7280),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 6 : 10,
                vertical: 8,
              ),
              children: [
                HomeWebNavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: AppLocalizations.of(context)!.home,
                  isSelected: tabController.index == 0,
                  showLabels: showLabels,
                  isSmallScreen: isSmallScreen,
                  fontSize: fontSize,
                  iconSize: iconSize,
                  onTap: () => tabController.animateTo(0),
                ),
                HomeWebNavItem(
                  icon: Icons.list_outlined,
                  selectedIcon: Icons.list,
                  label: AppLocalizations.of(context)!.activitiesTab,
                  isSelected: tabController.index == 1,
                  showLabels: showLabels,
                  isSmallScreen: isSmallScreen,
                  fontSize: fontSize,
                  iconSize: iconSize,
                  onTap: () => tabController.animateTo(1),
                ),
                HomeWebNavItem(
                  icon: Icons.analytics_outlined,
                  selectedIcon: Icons.analytics,
                  label: AppLocalizations.of(context)!.statistics,
                  isSelected: tabController.index == 2,
                  showLabels: showLabels,
                  isSmallScreen: isSmallScreen,
                  fontSize: fontSize,
                  iconSize: iconSize,
                  onTap: () => tabController.animateTo(2),
                ),
                HomeWebNavItem(
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                  label: AppLocalizations.of(context)!.settings,
                  isSelected: tabController.index == 3,
                  showLabels: showLabels,
                  isSmallScreen: isSmallScreen,
                  fontSize: fontSize,
                  iconSize: iconSize,
                  onTap: () => tabController.animateTo(3),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(headerPadding * 0.75),
            child: Consumer(
              builder: (context, ref, child) {
                final isLoading = ref.watch(loadingProvider);

                if (isSmallScreen) {
                  return Center(
                    child: IconButton(
                      onPressed: isLoading
                          ? null
                          : () => ref.read(refreshProvider).refreshAll(),
                      icon: isLoading
                          ? SizedBox(
                              width: iconSize - 2,
                              height: iconSize - 2,
                              child: AdaptiveSkeleton(borderRadius: (iconSize - 2) / 2),
                            )
                          : Icon(Icons.refresh, size: iconSize - 2),
                      tooltip: 'Actualizar',
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                        foregroundColor: const Color(0xFFFF6B35),
                        minimumSize: Size(iconSize + 16, iconSize + 16),
                        padding: EdgeInsets.all(8),
                      ),
                    ),
                  );
                }

                return SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => ref.read(refreshProvider).refreshAll(),
                    icon: isLoading
                        ? SizedBox(
                            width: iconSize - 4,
                            height: iconSize - 4,
                            child: AdaptiveSkeleton(borderRadius: (iconSize - 4) / 2),
                          )
                        : Icon(Icons.refresh, size: iconSize - 4),
                    label: showLabels
                        ? Text(
                            'Actualizar',
                            style: TextStyle(fontSize: fontSize),
                            overflow: TextOverflow.ellipsis,
                          )
                        : const SizedBox.shrink(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: showLabels ? 12 : 8,
                        vertical: 10,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HomeWebHomeTab extends StatelessWidget {
  final bool isLargeScreen;
  final bool isMediumScreen;
  final VoidCallback onRefresh;
  final VoidCallback onViewAllActivities;
  final VoidCallback onStatisticsTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onRefreshTap;
  final VoidCallback onClearDataTap;

  const HomeWebHomeTab({
    super.key,
    required this.isLargeScreen,
    required this.isMediumScreen,
    required this.onRefresh,
    required this.onViewAllActivities,
    required this.onStatisticsTap,
    required this.onNotificationsTap,
    required this.onRefreshTap,
    required this.onClearDataTap,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: CustomScrollView(
        slivers: [
          const HomeWebAppBar(),
          SliverToBoxAdapter(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1400),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
                child: isLargeScreen
                    ? HomeLargeScreenLayout(
                        onViewAllActivities: onViewAllActivities,
                        onStatisticsTap: onStatisticsTap,
                        onNotificationsTap: onNotificationsTap,
                        onRefreshTap: onRefreshTap,
                        onClearDataTap: onClearDataTap,
                      )
                    : isMediumScreen
                    ? HomeMediumScreenLayout(
                        onViewAllActivities: onViewAllActivities,
                        onStatisticsTap: onStatisticsTap,
                        onNotificationsTap: onNotificationsTap,
                        onRefreshTap: onRefreshTap,
                        onClearDataTap: onClearDataTap,
                      )
                    : HomeSmallScreenLayout(
                        onViewAllActivities: onViewAllActivities,
                        onStatisticsTap: onStatisticsTap,
                        onNotificationsTap: onNotificationsTap,
                        onRefreshTap: onRefreshTap,
                        onClearDataTap: onClearDataTap,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeWebAppBar extends StatelessWidget {
  const HomeWebAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withValues(alpha: 0.05),
                AppTheme.primaryColor.withValues(alpha: 0.02),
              ],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(Icons.pets, size: 32, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: constraints.maxHeight * 0.6,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Dashboard de Pépito',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.getColors(context).onSurface,
                                letterSpacing: -0.8,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: constraints.maxHeight * 0.3,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.appDescription,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppTheme.getColors(context).onSurface.withValues(alpha: 0.7),
                              height: 1.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Consumer(
                builder: (context, ref, child) {
                  final isLoading = ref.watch(loadingProvider);
                  return Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: isLoading
                          ? null
                          : () => ref.read(refreshProvider).refreshAll(),
                      icon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: AdaptiveSkeleton(borderRadius: 10),
                            )
                          : Icon(
                              Icons.refresh_rounded,
                              color: AppTheme.primaryColor,
                              size: 24,
                            ),
                      tooltip: 'Actualizar datos',
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeLargeScreenLayout extends StatelessWidget {
  final VoidCallback onViewAllActivities;
  final VoidCallback onStatisticsTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onRefreshTap;
  final VoidCallback onClearDataTap;

  const HomeLargeScreenLayout({
    super.key,
    required this.onViewAllActivities,
    required this.onStatisticsTap,
    required this.onNotificationsTap,
    required this.onRefreshTap,
    required this.onClearDataTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const HomeStatusSection(),
        const SizedBox(height: 32),
        const HomeQuickStats(),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: HomeRecentActivities(
                onViewAll: onViewAllActivities,
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  HomeQuickActions(
                    onStatisticsTap: onStatisticsTap,
                    onNotificationsTap: onNotificationsTap,
                    onRefreshTap: onRefreshTap,
                    onClearDataTap: onClearDataTap,
                  ),
                  const SizedBox(height: 24),
                  const HomeWebInsights(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class HomeMediumScreenLayout extends StatelessWidget {
  final VoidCallback onViewAllActivities;
  final VoidCallback onStatisticsTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onRefreshTap;
  final VoidCallback onClearDataTap;

  const HomeMediumScreenLayout({
    super.key,
    required this.onViewAllActivities,
    required this.onStatisticsTap,
    required this.onNotificationsTap,
    required this.onRefreshTap,
    required this.onClearDataTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const HomeStatusSection(),
        const SizedBox(height: 24),
        const HomeQuickStats(),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: HomeRecentActivities(
                onViewAll: onViewAllActivities,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 1,
              child: HomeQuickActions(
                onStatisticsTap: onStatisticsTap,
                onNotificationsTap: onNotificationsTap,
                onRefreshTap: onRefreshTap,
                onClearDataTap: onClearDataTap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class HomeSmallScreenLayout extends StatelessWidget {
  final VoidCallback onViewAllActivities;
  final VoidCallback onStatisticsTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onRefreshTap;
  final VoidCallback onClearDataTap;

  const HomeSmallScreenLayout({
    super.key,
    required this.onViewAllActivities,
    required this.onStatisticsTap,
    required this.onNotificationsTap,
    required this.onRefreshTap,
    required this.onClearDataTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const HomeStatusSection(),
        const SizedBox(height: 16),
        const HomeQuickStats(),
        const SizedBox(height: 16),
        HomeRecentActivities(
          onViewAll: onViewAllActivities,
        ),
        const SizedBox(height: 16),
        HomeQuickActions(
          onStatisticsTap: onStatisticsTap,
          onNotificationsTap: onNotificationsTap,
          onRefreshTap: onRefreshTap,
          onClearDataTap: onClearDataTap,
        ),
      ],
    );
  }
}

class HomeWebInsights extends ConsumerWidget {
  const HomeWebInsights({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Insights',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getColors(context).onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final statusAsync = ref.watch(pepitoStatusProvider);
                final todayActivitiesAsync = ref.watch(todayActivitiesProvider);

                return Column(
                  children: [
                    HomeInsightItem(
                      icon: Icons.schedule,
                      title: AppLocalizations.of(context)!.lastActivity,
                      value: statusAsync.when(
                        data: (status) => _formatLastActivity(status.lastSeen, context),
                        loading: () => AppLocalizations.of(context)!.loading,
                        error: (error, stackTrace) =>
                            AppLocalizations.of(context)!.error,
                      ),
                    ),
                    const SizedBox(height: 12),
                    HomeInsightItem(
                      icon: Icons.today,
                      title: AppLocalizations.of(context)!.activitiesToday,
                      value: todayActivitiesAsync.when(
                        data: (activities) => '${activities.length}',
                        loading: () => '...',
                        error: (error, stackTrace) => '0',
                      ),
                    ),
                    const SizedBox(height: 12),
                    HomeInsightItem(
                      icon: Icons.trending_up,
                      title: AppLocalizations.of(context)!.status,
                      value: statusAsync.when(
                        data: (status) => status.isHome
                            ? AppLocalizations.of(context)!.atHome
                            : AppLocalizations.of(context)!.awayFromHome,
                        loading: () => '...',
                        error: (error, stackTrace) =>
                            AppLocalizations.of(context)!.error,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class HomeInsightItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const HomeInsightItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppTheme.primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.getColors(context).onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getColors(context).onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _formatLastActivity(DateTime? lastActivity, BuildContext context) {
  if (lastActivity == null) return AppLocalizations.of(context)!.noActivity;
  final now = DateTime.now();
  final difference = now.difference(lastActivity);

  if (difference.inMinutes < 1) {
    return AppLocalizations.of(context)!.justNow;
  } else if (difference.inHours < 1) {
    return AppLocalizations.of(context)!.minutesAgo(difference.inMinutes);
  } else if (difference.inDays < 1) {
    return AppLocalizations.of(context)!.hoursAgo(difference.inHours);
  } else {
    return AppLocalizations.of(context)!.daysAgo(difference.inDays);
  }
}
