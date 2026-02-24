import 'package:flutter/material.dart';
import '../../theme/liquid_glass/apple_colors.dart';

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
    
    // Capitalize title
    final capitalizedTitle = title.isNotEmpty 
        ? '${title[0].toUpperCase()}${title.substring(1)}' 
        : title;

    return SliverAppBar(
      title: Text(
        capitalizedTitle,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: Colors.transparent,
      foregroundColor: isDark ? Colors.white : Colors.black,
      pinned: pinned,
      floating: false,
      snap: false,
      actions: actions,
    );
  }
}
