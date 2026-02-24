import 'package:flutter/material.dart';
import 'dart:ui';

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
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  (isDark ? Colors.black : Colors.white).withValues(alpha: 0.4),
                  (isDark ? Colors.black : Colors.white).withValues(alpha: 0.1),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                  width: 1.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
