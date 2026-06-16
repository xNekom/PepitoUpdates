import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/home/home.dart';
import '../widgets/liquid_glass/circles_background.dart';
import '../widgets/liquid_glass/liquid_app_bar.dart';
import '../utils/theme_utils.dart';
import '../generated/app_localizations.dart';
import '../providers/pepito_providers.dart';
import 'activities_screen.dart';
import 'advanced_statistics_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late RefreshController _refreshController;
  late ScrollController _scrollController;

  bool _isNavbarCollapsed = false;

  AnimationController? _bubbleAnimationController;
  Animation<double>? _bubbleAnimation;



  void _handleDatabaseError() {
    if (kDebugMode) print('DEBUG: Verificando estructura de datos...');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _refreshController.refreshAll();
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _bubbleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _bubbleAnimation = CurvedAnimation(
      parent: _bubbleAnimationController!,
      curve: Curves.easeInOut,
    );

    _handleDatabaseError();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshController = ref.read(refreshProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshController.refreshAll();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _scrollController.dispose();
    _bubbleAnimationController?.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (mounted) {
      _bubbleAnimationController?.reset();
      _bubbleAnimationController?.forward();

      setState(() {});
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
  }

  @override
  Widget build(BuildContext context) {
    final platformStyle = ref.watch(platformStyleProvider);

    return switch (platformStyle) {
      WidgetStyle.liquidGlass => _buildLiquidGlassUI(context),
      WidgetStyle.fluentDesign => _buildFluentUI(context),
      WidgetStyle.materialExpressive => _buildMaterial3ExpressiveUI(context),
    };
  }

  Widget _buildMaterial3ExpressiveUI(BuildContext context) {
    final colors = AppTheme.getColors(context);

    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMaterial3ExpressiveHomeTab(),
          const ActivitiesScreen(),
          const AdvancedStatisticsScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: HomeM3BottomNavigationBar(
        tabController: _tabController,
        colors: colors,
      ),
    );
  }

  Widget _buildLiquidGlassUI(BuildContext context) {
    final colors = AppTheme.getColors(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const CirclesBackground(),
          NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              if (notification.direction == ScrollDirection.reverse) {
                if (!_isNavbarCollapsed) {
                  setState(() => _isNavbarCollapsed = true);
                }
              } else if (notification.direction == ScrollDirection.forward) {
                if (_isNavbarCollapsed) {
                  setState(() => _isNavbarCollapsed = false);
                }
              }
              return true;
            },
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLiquidGlassHomeTab(),
                const ActivitiesScreen(),
                const AdvancedStatisticsScreen(),
                const SettingsScreen(),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: HomeLiquidGlassBottomNavigationBar(
              tabController: _tabController,
              colors: colors,
              isNavbarCollapsed: _isNavbarCollapsed,
              bubbleAnimation: _bubbleAnimation,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFluentUI(BuildContext context) {
    return fluent.NavigationView(
      pane: fluent.NavigationPane(
        selected: _tabController.index,
        onChanged: (index) {
          setState(() {
            _tabController.animateTo(index);
          });
        },
        displayMode: fluent.PaneDisplayMode.top,
        items: [
          fluent.PaneItem(
            icon: const Icon(fluent.FluentIcons.home),
            title: Text(AppLocalizations.of(context)!.home),
            body: _buildHomeTab(),
          ),
          fluent.PaneItem(
            icon: const Icon(fluent.FluentIcons.timeline),
            title: Text(AppLocalizations.of(context)!.activitiesTab),
            body: const ActivitiesScreen(),
          ),
          fluent.PaneItem(
            icon: const Icon(fluent.FluentIcons.chart),
            title: Text(AppLocalizations.of(context)!.statistics),
            body: const AdvancedStatisticsScreen(),
          ),
          fluent.PaneItem(
            icon: const Icon(fluent.FluentIcons.settings),
            title: Text(AppLocalizations.of(context)!.settings),
            body: const SettingsScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await _refreshController.refreshAll();
      },
      child: CustomScrollView(
        slivers: [
          const HomeAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const HomeStatusSection(),
                const SizedBox(height: 16),
                const HomeQuickStats(),
                const SizedBox(height: 16),
                HomeRecentActivities(
                  onViewAll: () => _tabController.animateTo(1),
                ),
                const SizedBox(height: 16),
                HomeQuickActions(
                  onStatisticsTap: _navigateToStatistics,
                  onNotificationsTap: _navigateToNotifications,
                  onRefreshTap: () => _refreshController.refreshAll(),
                  onClearDataTap: () => clearSupabaseData(context),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterial3ExpressiveHomeTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await _refreshController.refreshAll();
      },
      child: CustomScrollView(
        slivers: [
          const Material3AppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const Material3StatusSection(),
                const SizedBox(height: 16),
                const Material3QuickStats(),
                const SizedBox(height: 16),
                const Material3RecentActivities(),
                const SizedBox(height: 16),
                Material3QuickActions(
                  onRefreshTap: () => _refreshController.refreshAll(),
                  onActivitiesTap: () => _tabController.animateTo(1),
                  onStatisticsTap: () => _tabController.animateTo(2),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiquidGlassHomeTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await _refreshController.refreshAll();
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          LiquidAppBar(title: 'Pepito Updates'),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const LiquidGlassStatusSection(),
                const SizedBox(height: 16),
                const LiquidGlassQuickStats(),
                const SizedBox(height: 16),
                LiquidGlassRecentActivities(
                  onViewAll: () => _tabController.animateTo(1),
                ),
                const SizedBox(height: 16),
                LiquidGlassQuickActions(
                  onStatisticsTap: _navigateToStatistics,
                  onNotificationsTap: _navigateToNotifications,
                  onRefreshTap: () => _refreshController.refreshAll(),
                  onClearDataTap: () => clearSupabaseData(context),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  void _navigateToStatistics() {
    _tabController.animateTo(2);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📊 Estadísticas'),
        content: const Text(
          'Navegando a la pestaña de estadísticas donde puedes ver análisis detallados de la actividad de Pépito.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToNotifications() {
    _tabController.animateTo(3);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔔 Configuración'),
        content: const Text(
          'Navegando a la configuración donde puedes ajustar las notificaciones y otros ajustes de la aplicación.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
