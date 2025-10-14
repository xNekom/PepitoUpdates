import 'dart:ui';
import 'package:flutter/cupertino.dart';

class FrostedPanel extends StatelessWidget {
  final Widget child;
  final double blurIntensity;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final bool showBorder;

  const FrostedPanel({
    super.key,
    required this.child,
    this.blurIntensity = 20.0,
    this.backgroundColor,
    this.padding,
    this.borderRadius,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness ?? Brightness.light;
    final defaultBgColor = brightness == Brightness.dark
        ? CupertinoColors.black.withOpacity(0.3)
        : CupertinoColors.white.withOpacity(0.3);

    final radius = borderRadius ?? BorderRadius.circular(0);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurIntensity, sigmaY: blurIntensity),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? defaultBgColor,
            borderRadius: radius,
            border: showBorder ? Border.all(
              color: (brightness == Brightness.dark
                  ? CupertinoColors.white
                  : CupertinoColors.black).withOpacity(0.1),
              width: 1.0,
            ) : null,
          ),
          child: child,
        ),
      ),
    );
  }
}