import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FrostedPanel extends StatelessWidget {
  final Widget child;
  final double blurIntensity;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final bool showBorder;
  /// If true, the background will be completely transparent (only blur effect)
  final bool fullyTransparent;

  const FrostedPanel({
    super.key,
    required this.child,
    this.blurIntensity = 20.0,
    this.backgroundColor,
    this.padding,
    this.borderRadius,
    this.showBorder = true,
    this.fullyTransparent = false,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final defaultBgColor = brightness == Brightness.dark
        ? CupertinoColors.black.withValues(alpha: 0.3)
        : CupertinoColors.white.withValues(alpha: 0.3);

    final radius = borderRadius ?? BorderRadius.circular(0);
    
    // If fullyTransparent is true, use completely transparent color
    // Otherwise, use the provided backgroundColor or default themed color
    final Color effectiveColor;
    if (fullyTransparent || backgroundColor == Colors.transparent) {
      effectiveColor = Colors.transparent;
    } else if (backgroundColor != null) {
      effectiveColor = backgroundColor!;
    } else {
      effectiveColor = defaultBgColor;
    }
    
    // Border color based on theme
    final borderColor = (brightness == Brightness.dark
        ? CupertinoColors.white
        : CupertinoColors.black).withValues(alpha: 0.15);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurIntensity, sigmaY: blurIntensity),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: effectiveColor,
            borderRadius: radius,
            border: showBorder ? Border.all(
              color: borderColor,
              width: 0.5,
            ) : null,
          ),
          child: child,
        ),
      ),
    );
  }
}