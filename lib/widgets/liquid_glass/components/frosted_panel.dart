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
  final bool fullyTransparent;
  final EdgeInsets? margin;

  const FrostedPanel({
    super.key,
    required this.child,
    this.blurIntensity = 20.0,
    this.backgroundColor,
    this.padding,
    this.borderRadius,
    this.showBorder = true,
    this.fullyTransparent = false,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final defaultBgColor = brightness == Brightness.dark
        ? CupertinoColors.black.withValues(alpha: 0.3)
        : CupertinoColors.white.withValues(alpha: 0.3);

    final radius = borderRadius ?? BorderRadius.circular(12);

    final Color effectiveColor;
    if (fullyTransparent || backgroundColor == Colors.transparent) {
      effectiveColor = Colors.transparent;
    } else if (backgroundColor != null) {
      effectiveColor = backgroundColor!;
    } else {
      effectiveColor = defaultBgColor;
    }

    final borderColor = (brightness == Brightness.dark
        ? CupertinoColors.white
        : CupertinoColors.black).withValues(alpha: 0.12);

    Widget panel = ClipRRect(
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

    if (margin != null) {
      panel = Container(margin: margin, child: panel);
    }

    return panel;
  }
}
