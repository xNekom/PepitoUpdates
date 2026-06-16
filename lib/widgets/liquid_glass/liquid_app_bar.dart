import 'package:flutter/material.dart';
import 'dart:ui';
import '../../theme/premium_typography.dart';
import 'components/vibrancy_text.dart';

class LiquidAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final bool pinned;
  final bool centerTitle;

  const LiquidAppBar({
    super.key,
    required this.title,
    this.actions,
    this.pinned = true,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleText = title.isNotEmpty
        ? '${title[0].toUpperCase()}${title.substring(1)}'
        : title;

    return SliverAppBar(
      title: VibrancyText(
        text: titleText,
        style: const TextStyle(fontWeight: FontWeight.bold),
        vibrantColor: isDark ? Colors.white : Colors.black,
      ),
      centerTitle: centerTitle,
      backgroundColor: Colors.transparent,
      foregroundColor: isDark ? Colors.white : Colors.black,
      pinned: pinned,
      floating: false,
      snap: false,
      actions: actions,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  (isDark ? Colors.black : Colors.white).withValues(alpha: 0.5),
                  (isDark ? Colors.black : Colors.white).withValues(alpha: 0.15),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LiquidLargeTitleAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final bool pinned;

  const LiquidLargeTitleAppBar({
    super.key,
    required this.title,
    this.actions,
    this.pinned = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typography = PremiumTypography.platformAwareTextTheme(
      context,
      isDark ? Brightness.dark : Brightness.light,
    );

    return SliverAppBar(
      title: VibrancyText(
        text: title,
        style: typography.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        vibrantColor: isDark ? Colors.white : Colors.black,
      ),
      centerTitle: false,
      backgroundColor: Colors.transparent,
      foregroundColor: isDark ? Colors.white : Colors.black,
      pinned: pinned,
      floating: true,
      snap: true,
      expandedHeight: 120,
      actions: actions,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                  width: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
