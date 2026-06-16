import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../../generated/app_localizations.dart';
import '../../models/pepito_activity.dart';
import '../../theme/liquid_glass/apple_colors.dart';
import '../../utils/theme_utils.dart';

class HomeBottomNavigationBar extends StatelessWidget {
  final TabController tabController;
  final AppColors colors;

  const HomeBottomNavigationBar({
    super.key,
    required this.tabController,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: TabBar(
        controller: tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: colors.onSurface.withValues(alpha: 0.6),
        indicatorColor: AppTheme.primaryColor,
        tabs: [
          Tab(
            icon: const Icon(Icons.home),
            text: AppLocalizations.of(context)!.home,
          ),
          Tab(
            icon: const Icon(Icons.list),
            text: AppLocalizations.of(context)!.activitiesTab,
          ),
          Tab(
            icon: const Icon(Icons.analytics),
            text: AppLocalizations.of(context)!.statistics,
          ),
          Tab(
            icon: const Icon(Icons.settings),
            text: AppLocalizations.of(context)!.settings,
          ),
        ],
      ),
    );
  }
}

class HomeM3BottomNavigationBar extends StatelessWidget {
  final TabController tabController;
  final AppColors colors;

  const HomeM3BottomNavigationBar({
    super.key,
    required this.tabController,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: tabController.index,
      onDestinationSelected: (index) => tabController.animateTo(index),
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home),
          label: AppLocalizations.of(context)!.home,
        ),
        NavigationDestination(
          icon: const Icon(Icons.list),
          label: AppLocalizations.of(context)!.activitiesTab,
        ),
        NavigationDestination(
          icon: const Icon(Icons.analytics),
          label: AppLocalizations.of(context)!.statistics,
        ),
        NavigationDestination(
          icon: const Icon(Icons.settings),
          label: AppLocalizations.of(context)!.settings,
        ),
      ],
    );
  }
}

class HomeLiquidGlassBottomNavigationBar extends StatelessWidget {
  final TabController tabController;
  final AppColors colors;
  final bool isNavbarCollapsed;
  final Animation<double>? bubbleAnimation;

  const HomeLiquidGlassBottomNavigationBar({
    super.key,
    required this.tabController,
    required this.colors,
    required this.isNavbarCollapsed,
    this.bubbleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: isNavbarCollapsed ? 70 : 90,
      child: isNavbarCollapsed
          ? Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
                  child: Container(
                    width: 260,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        HomeCollapsedNavItem(
                          icon: CupertinoIcons.home,
                          isSelected: tabController.index == 0,
                          isDark: isDark,
                          onTap: () => tabController.animateTo(0),
                          bubbleAnimation: bubbleAnimation,
                        ),
                        HomeCollapsedNavItem(
                          icon: CupertinoIcons.list_bullet,
                          isSelected: tabController.index == 1,
                          isDark: isDark,
                          onTap: () => tabController.animateTo(1),
                          bubbleAnimation: bubbleAnimation,
                        ),
                        HomeCollapsedNavItem(
                          icon: CupertinoIcons.chart_bar,
                          isSelected: tabController.index == 2,
                          isDark: isDark,
                          onTap: () => tabController.animateTo(2),
                          bubbleAnimation: bubbleAnimation,
                        ),
                        HomeCollapsedNavItem(
                          icon: CupertinoIcons.settings,
                          isSelected: tabController.index == 3,
                          isDark: isDark,
                          onTap: () => tabController.animateTo(3),
                          bubbleAnimation: bubbleAnimation,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
                child: Container(
                  color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.2),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: HomeNavItem(
                          icon: CupertinoIcons.home,
                          label: AppLocalizations.of(context)!.home,
                          isSelected: tabController.index == 0,
                          isDark: isDark,
                          onTap: () => tabController.animateTo(0),
                          bubbleAnimation: bubbleAnimation,
                        ),
                      ),
                      Expanded(
                        child: HomeNavItem(
                          icon: CupertinoIcons.list_bullet,
                          label: AppLocalizations.of(context)!.activitiesTab,
                          isSelected: tabController.index == 1,
                          isDark: isDark,
                          onTap: () => tabController.animateTo(1),
                          bubbleAnimation: bubbleAnimation,
                        ),
                      ),
                      Expanded(
                        child: HomeNavItem(
                          icon: CupertinoIcons.chart_bar,
                          label: AppLocalizations.of(context)!.statistics,
                          isSelected: tabController.index == 2,
                          isDark: isDark,
                          onTap: () => tabController.animateTo(2),
                          bubbleAnimation: bubbleAnimation,
                        ),
                      ),
                      Expanded(
                        child: HomeNavItem(
                          icon: CupertinoIcons.settings,
                          label: AppLocalizations.of(context)!.settings,
                          isSelected: tabController.index == 3,
                          isDark: isDark,
                          onTap: () => tabController.animateTo(3),
                          bubbleAnimation: bubbleAnimation,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class HomeNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;
  final Animation<double>? bubbleAnimation;

  const HomeNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
    this.bubbleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final inactiveColor = isDark
        ? CupertinoColors.systemGrey
        : CupertinoColors.systemGrey2;

    final bubbleColor = isSelected
        ? AppleColors.infoBlue
        : AppleColors.getActivityColor(ActivityType.entrada);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (isSelected && bubbleAnimation != null)
            AnimatedBuilder(
              animation: bubbleAnimation!,
              builder: (context, child) {
                final animationValue = bubbleAnimation!.value;
                final scale = 1.0 + (animationValue * 0.15);

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          bubbleColor.withValues(alpha: 0.9),
                          bubbleColor.withValues(alpha: 0.6),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: bubbleColor.withValues(alpha: 0.6),
                          blurRadius: 25,
                          spreadRadius: 5,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.4),
                          blurRadius: 15,
                          spreadRadius: -5,
                          offset: const Offset(-5, -5),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.transparent,
            ),
            constraints: const BoxConstraints(minHeight: 40, maxHeight: 48),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : inactiveColor,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeCollapsedNavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;
  final Animation<double>? bubbleAnimation;

  const HomeCollapsedNavItem({
    super.key,
    required this.icon,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
    this.bubbleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final inactiveColor = isDark
        ? CupertinoColors.systemGrey
        : CupertinoColors.systemGrey2;

    final bubbleColor = isSelected
        ? AppleColors.infoBlue
        : AppleColors.getActivityColor(ActivityType.entrada);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (isSelected && bubbleAnimation != null)
            AnimatedBuilder(
              animation: bubbleAnimation!,
              builder: (context, child) {
                final animationValue = bubbleAnimation!.value;
                final scale = 1.0 + (animationValue * 0.15);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          bubbleColor.withValues(alpha: 0.9),
                          bubbleColor.withValues(alpha: 0.6),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: bubbleColor.withValues(alpha: 0.6),
                          blurRadius: 25,
                          spreadRadius: 5,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.4),
                          blurRadius: 15,
                          spreadRadius: -5,
                          offset: const Offset(-5, -5),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.transparent,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : inactiveColor,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeWebNavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final bool showLabels;
  final bool isSmallScreen;
  final double fontSize;
  final double iconSize;
  final VoidCallback onTap;

  const HomeWebNavItem({
    super.key,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.showLabels,
    required this.isSmallScreen,
    required this.fontSize,
    required this.iconSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isSmallScreen) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Tooltip(
          message: label,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: iconSize + 32,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryOrange.withValues(alpha: 0.2),
                          AppTheme.expressiveTeal.withValues(alpha: 0.15),
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(18),
                border: isSelected
                    ? Border.all(
                        color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                        width: 2,
                      )
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryOrange.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Icon(
                  isSelected ? selectedIcon : icon,
                  color: isSelected
                      ? AppTheme.primaryOrange
                      : (Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.getColors(context).onSurface.withValues(alpha: 0.6)
                            : const Color(0xFF6B7280)),
                  size: iconSize * 1.1,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryOrange.withValues(alpha: 0.15),
                  AppTheme.expressiveTeal.withValues(alpha: 0.1),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(20),
        border: isSelected
            ? Border.all(
                color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                width: 2,
              )
            : null,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppTheme.primaryOrange.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ListTile(
        dense: true,
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryOrange.withValues(alpha: 0.2),
                      AppTheme.expressivePurple.withValues(alpha: 0.15),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isSelected ? selectedIcon : icon,
            color: isSelected
                ? AppTheme.primaryOrange
                : (Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.getColors(context).onSurface.withValues(alpha: 0.6)
                      : const Color(0xFF6B7280)),
            size: iconSize * 1.1,
          ),
        ),
        title: showLabels
            ? Text(
                label,
                style: TextStyle(
                  fontSize: fontSize * 1.05,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppTheme.primaryOrange
                      : (Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.getColors(context).onSurface
                            : const Color(0xFF374151)),
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              )
            : null,
        selected: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: showLabels ? 16 : 12,
          vertical: 6,
        ),
        minLeadingWidth: iconSize + 16,
        onTap: onTap,
      ),
    );
  }
}
