import 'package:flutter/material.dart';
import '../widgets/cat_paw_icon.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pepito_providers.dart';
import '../widgets/adaptive/adaptive_activity_card.dart';
import '../utils/theme_utils.dart';
import '../utils/date_utils.dart';
import '../models/pepito_activity.dart';
import '../generated/app_localizations.dart';
import '../widgets/liquid_glass/liquid_app_bar.dart';

class ActivitiesScreen extends ConsumerStatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  ConsumerState<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends ConsumerState<ActivitiesScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _isLoadingMore = false;
  List<PepitoActivity> _allActivities = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore) {
      _loadMoreActivities();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _currentPage = 1;
      _allActivities.clear();
    });
    await _loadMoreActivities();
  }

  Future<void> _loadMoreActivities() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final filter = ref.read(activityFilterProvider);
      final activitiesAsync = await ref.read(
        activitiesProvider(
          ActivitiesParams(
            offset: (_currentPage - 1) * _pageSize,
            limit: _pageSize,
            startDate: filter.dateRange?.start,
            endDate: filter.dateRange?.end,
          ),
        ).future,
      );

      setState(() {
        if (_currentPage == 1) {
          _allActivities = activitiesAsync;
        } else {
          _allActivities.addAll(activitiesAsync);
        }
        _currentPage++;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(colorScheme),
          _buildFilterSection(),
          _buildActivitiesList(),
          if (_isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
      floatingActionButton: _buildScrollToTopFab(),
    );
  }

  Widget _buildAppBar(ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LiquidAppBar(
      title: AppLocalizations.of(context)!.activities,
      actions: [
        IconButton(
          onPressed: _showFilterDialog,
          icon: Consumer(
            builder: (context, ref, child) {
              final filter = ref.watch(activityFilterProvider);
              final hasActiveFilters = filter.hasActiveFilters;
              return Stack(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  if (hasActiveFilters)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.warningColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        IconButton(
          onPressed: _loadInitialData,
          icon: Icon(
            Icons.refresh,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return SliverToBoxAdapter(
      child: Consumer(
        builder: (context, ref, child) {
          final filter = ref.watch(activityFilterProvider);

          if (!filter.hasActiveFilters) {
            return const SizedBox.shrink();
          }

          final screenWidth = MediaQuery.of(context).size.width;
          final isSmallScreen = screenWidth <= 600;
          final margin = isSmallScreen ? 12.0 : 16.0;
          final padding = isSmallScreen ? 8.0 : 12.0;
          final fontSize = isSmallScreen ? 12.0 : 14.0;

          return Container(
            margin: EdgeInsets.all(margin),
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      size: isSmallScreen ? 14 : 16,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Filtros activos',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        ref
                            .read(activityFilterProvider.notifier)
                            .clearFilters();
                        _loadInitialData();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 8 : 12,
                          vertical: isSmallScreen ? 4 : 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Limpiar',
                        style: TextStyle(fontSize: isSmallScreen ? 11 : 12),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),
                Wrap(
                  spacing: isSmallScreen ? 6 : 8,
                  runSpacing: 4,
                  children: [
                    if (filter.activityType != null)
                      _buildFilterChip(
                        label: filter.activityType == ActivityType.entrada
                            ? AppLocalizations.of(context)!.entries
                            : AppLocalizations.of(context)!.exits,
                        onRemove: () {
                          ref
                              .read(activityFilterProvider.notifier)
                              .setActivityType(null);
                          _loadInitialData();
                        },
                      ),
                    if (filter.dateRange != null)
                      _buildFilterChip(
                        label: _formatDateRange(filter.dateRange!),
                        onRemove: () {
                          ref
                              .read(activityFilterProvider.notifier)
                              .setDateRange(null);
                          _loadInitialData();
                        },
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onRemove,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 600;
    final fontSize = isSmallScreen ? 10.0 : 12.0;
    final iconSize = isSmallScreen ? 14.0 : 16.0;

    return Chip(
      label: Text(
        label,
        style: TextStyle(fontSize: fontSize),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      deleteIcon: Icon(Icons.close, size: iconSize),
      onDeleted: onRemove,
      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
      deleteIconColor: AppTheme.primaryColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: isSmallScreen
          ? VisualDensity.compact
          : VisualDensity.standard,
    );
  }

  Widget _buildActivitiesList() {
    if (_allActivities.isEmpty && !_isLoadingMore) {
      return SliverFillRemaining(child: _buildEmptyState());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index >= _allActivities.length) {
          return null;
        }

        final activity = _allActivities[index];
        final isToday = AppDateUtils.isToday(activity.dateTime);
        final isYesterday = AppDateUtils.isYesterday(activity.dateTime);
        // Show date header for first item or when date changes
        bool showDateHeader = false;
        if (index == 0) {
          showDateHeader = true;
        } else {
          final previousActivity = _allActivities[index - 1];
          final currentDate = AppDateUtils.startOfDay(activity.dateTime);
          final previousDate = AppDateUtils.startOfDay(previousActivity.dateTime);
          showDateHeader = !currentDate.isAtSameMomentAs(previousDate);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDateHeader)
              _buildDateHeader(
                context,
                activity.dateTime,
                isToday: isToday,
                isYesterday: isYesterday,
              ),
            AdaptiveActivityCard(
              activity: activity,
              showDate: false,
              onTap: () => _showActivityDetails(activity),
            ),
          ],
        );
      }, childCount: _allActivities.length),
    );
  }

  Widget _buildDateHeader(
    BuildContext context,
    DateTime date, {
    bool isToday = false,
    bool isYesterday = false,
  }) {
    String dateText;
    if (isToday) {
      dateText = AppLocalizations.of(context)!.today;
    } else if (isYesterday) {
      dateText = AppLocalizations.of(context)!.yesterday;
    } else {
      dateText = AppDateUtils.formatDate(date);
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        dateText,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CatPawIcon(
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.noActivities,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(
                context,
              )!.pepitoActivitiesWillAppearWhenAvailable,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadInitialData,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildScrollToTopFab() {
    return AnimatedBuilder(
      animation: _scrollController,
      builder: (context, child) {
        if (_scrollController.hasClients && _scrollController.offset > 500) {
          return FloatingActionButton(
            mini: true,
            onPressed: () {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            child: const Icon(Icons.keyboard_arrow_up),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _FilterBottomSheet(onApplyFilters: _loadInitialData),
    );
  }

  void _showActivityDetails(PepitoActivity activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.activityDetails,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: AdaptiveActivityCard(
                  activity: activity,
                  showDate: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateRange(DateRange range) {
    if (AppDateUtils.isSameDay(range.start, range.end)) {
      return AppDateUtils.formatDate(range.start);
    }
    return '${AppDateUtils.formatDateShort(range.start)} - ${AppDateUtils.formatDateShort(range.end)}';
  }
}

class _FilterBottomSheet extends ConsumerStatefulWidget {
  final VoidCallback onApplyFilters;

  const _FilterBottomSheet({required this.onApplyFilters});

  @override
  ConsumerState<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<_FilterBottomSheet> {
  ActivityType? _selectedActivityType;
  DateRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    final currentFilter = ref.read(activityFilterProvider);
    _selectedActivityType = currentFilter.activityType;
    _selectedDateRange = currentFilter.dateRange;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Filtrar actividades',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            _buildActivityTypeFilter(),
            const SizedBox(height: 24),
            _buildDateRangeFilter(),
            const Spacer(),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de actividad',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            _buildActivityTypeChip(
              label: 'Todas',
              isSelected: _selectedActivityType == null,
              onTap: () => setState(() => _selectedActivityType = null),
            ),
            _buildActivityTypeChip(
              label: AppLocalizations.of(context)!.entries,
              isSelected: _selectedActivityType == ActivityType.entrada,
              onTap: () =>
                  setState(() => _selectedActivityType = ActivityType.entrada),
            ),
            _buildActivityTypeChip(
              label: AppLocalizations.of(context)!.exits,
              isSelected: _selectedActivityType == ActivityType.salida,
              onTap: () =>
                  setState(() => _selectedActivityType = ActivityType.salida),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityTypeChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rango de fechas',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildDateRangeChip(
              label: AppLocalizations.of(context)!.today,
              dateRange: AppDateUtils.today,
            ),
            _buildDateRangeChip(
              label: AppLocalizations.of(context)!.yesterday,
              dateRange: AppDateUtils.yesterday,
            ),
            _buildDateRangeChip(
              label: AppLocalizations.of(context)!.thisWeek,
              dateRange: AppDateUtils.thisWeek,
            ),
            _buildDateRangeChip(
              label: AppLocalizations.of(context)!.lastWeek,
              dateRange: AppDateUtils.lastWeek,
            ),
            _buildDateRangeChip(
              label: 'Este mes',
              dateRange: AppDateUtils.thisMonth,
            ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _selectCustomDateRange,
          icon: const Icon(Icons.date_range),
          label: Text(
            _selectedDateRange != null &&
                    !_isPredefinedRange(_selectedDateRange!)
                ? 'Personalizado: ${_formatDateRange(_selectedDateRange!)}'
                : 'Seleccionar rango personalizado',
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeChip({
    required String label,
    required DateRange dateRange,
  }) {
    final isSelected =
        _selectedDateRange != null &&
        AppDateUtils.isSameDay(_selectedDateRange!.start, dateRange.start) &&
        AppDateUtils.isSameDay(_selectedDateRange!.end, dateRange.end);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedDateRange = isSelected ? null : dateRange;
        });
      },
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _selectedActivityType = null;
                _selectedDateRange = null;
              });
            },
            child: const Text('Limpiar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              ref
                  .read(activityFilterProvider.notifier)
                  .updateFilter(
                    activityType: _selectedActivityType,
                    dateRange: _selectedDateRange,
                  );
              Navigator.of(context).pop();
              widget.onApplyFilters();
            },
            child: const Text('Aplicar'),
          ),
        ),
      ],
    );
  }

  Future<void> _selectCustomDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange != null
          ? DateTimeRange(
              start: _selectedDateRange!.start,
              end: _selectedDateRange!.end,
            )
          : null,
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = DateRange(start: picked.start, end: picked.end);
      });
    }
  }

  bool _isPredefinedRange(DateRange range) {
    final predefined = [
      AppDateUtils.today,
      AppDateUtils.yesterday,
      AppDateUtils.thisWeek,
      AppDateUtils.lastWeek,
      AppDateUtils.thisMonth,
    ];

    return predefined.any(
      (predefinedRange) =>
          AppDateUtils.isSameDay(range.start, predefinedRange.start) &&
          AppDateUtils.isSameDay(range.end, predefinedRange.end),
    );
  }

  String _formatDateRange(DateRange range) {
    if (AppDateUtils.isSameDay(range.start, range.end)) {
      return AppDateUtils.formatDate(range.start);
    }
    return '${AppDateUtils.formatDateShort(range.start)} - ${AppDateUtils.formatDateShort(range.end)}';
  }
}
