import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../theme/liquid_glass/glass_effects.dart';
import '../../../utils/platform_detector.dart';

class ApplePressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? accentColor;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final bool enabled;

  const ApplePressable({
    super.key,
    required this.child,
    this.onPressed,
    this.accentColor,
    this.padding,
    this.borderRadius,
    this.enabled = true,
  });

  @override
  State<ApplePressable> createState() => _ApplePressableState();
}

class _ApplePressableState extends State<ApplePressable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: GlassEffects.quickAnimation,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: GlassEffects.appleCurve),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: GlassEffects.appleCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enabled && widget.onPressed != null) {
      _controller.forward();
      // Haptic feedback en iOS
      if (PlatformDetector.supportsHaptics) {
        HapticFeedback.lightImpact();
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enabled) {
      _controller.reverse();
      widget.onPressed?.call();
    }
  }

  void _handleTapCancel() {
    if (widget.enabled) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.accentColor ?? CupertinoColors.activeBlue;
    final borderRadius = widget.borderRadius ??
        BorderRadius.circular(GlassEffects.radiusSmall);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: widget.padding ?? const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  color: accentColor.withValues(
                    alpha: widget.enabled ? 0.1 : 0.05,
                  ),
                  border: Border.all(
                    color: accentColor.withValues(
                      alpha: widget.enabled ? 0.3 : 0.1,
                    ),
                    width: 1.0,
                  ),
                ),
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}