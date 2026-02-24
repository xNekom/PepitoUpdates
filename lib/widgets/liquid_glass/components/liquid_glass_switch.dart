import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import '../../../theme/liquid_glass/glass_effects.dart';
import '../../../theme/liquid_glass/apple_colors.dart';
import '../../../models/pepito_activity.dart';

/// Switch personalizado con diseño Liquid Glass
class LiquidGlassSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;
  final double width;
  final double height;

  const LiquidGlassSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.width = 51,
    this.height = 31,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = this.activeColor ?? AppleColors.getActivityColor(ActivityType.entrada);

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height / 2),
          gradient: GlassEffects.glassGradient(
            accentColor: value ? activeColor : CupertinoColors.systemGrey4,
            brightness: Brightness.light,
          ),
          border: Border.all(
            color: (value ? activeColor : CupertinoColors.systemGrey4).withValues(alpha: GlassEffects.borderOpacity),
            width: 1.0,
          ),
          boxShadow: GlassEffects.glassShadows(
            accentColor: value ? activeColor : CupertinoColors.systemGrey4,
            intensity: 0.2,
          ),
        ),
        child: Stack(
          children: [
            // Blur background
            ClipRRect(
              borderRadius: BorderRadius.circular(height / 2),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: GlassEffects.blurSigmaLight,
                  sigmaY: GlassEffects.blurSigmaLight,
                ),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
            // Thumb
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? width - height + 2 : 2,
              top: 2,
              child: Container(
                width: height - 4,
                height: height - 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
// Theme-aware inactive thumb color
                  color: value 
                      ? activeColor 
                      : (Theme.of(context).brightness == Brightness.dark 
                          ? CupertinoColors.systemGrey 
                          : CupertinoColors.white),
                  border: Border.all(
                    color: value
                        ? activeColor.withValues(alpha: 0.3)
                        : CupertinoColors.systemGrey4,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (value ? activeColor : CupertinoColors.systemGrey4).withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}