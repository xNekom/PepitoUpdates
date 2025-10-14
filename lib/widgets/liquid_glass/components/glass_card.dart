import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../theme/liquid_glass/glass_effects.dart';
import '../../../utils/platform_detector.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final double? blurSigma;
  final Color? accentColor;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool enableHover;
  final List<BoxShadow>? customShadows;

  const GlassCard({
    super.key,
    required this.child,
    this.blurSigma,
    this.accentColor,
    this.borderRadius,
    this.padding,
    this.onTap,
    this.enableHover = true,
    this.customShadows,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: GlassEffects.quickAnimation,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: GlassEffects.appleCurve,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _scaleController.forward();
      // Haptic feedback en iOS
      if (PlatformDetector.supportsHaptics) {
        HapticFeedback.lightImpact();
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness ?? Brightness.light;
    final accentColor = widget.accentColor ?? CupertinoColors.systemBlue;
    final borderRadius = widget.borderRadius ??
        BorderRadius.circular(GlassEffects.radiusMedium);
    final blurSigma = widget.blurSigma ?? GlassEffects.blurSigmaLight;

    final isDesktop = PlatformDetector.isDesktop;
    final backgroundOpacity = brightness == Brightness.dark
        ? GlassEffects.backgroundOpacityMedium
        : GlassEffects.backgroundOpacityLight;

    return MouseRegion(
      onEnter: isDesktop && widget.enableHover
          ? (event) => setState(() => _isHovered = true)
          : null,
      onExit: isDesktop && widget.enableHover
          ? (event) => setState(() => _isHovered = false)
          : null,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: widget.padding ?? const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  color: const Color(0xFF000000).withOpacity(backgroundOpacity),
                  gradient: GlassEffects.glassGradient(
                    accentColor: accentColor,
                    brightness: brightness,
                  ),
                  border: Border.all(
                    color: accentColor.withOpacity(
                      _isHovered ? GlassEffects.borderOpacity * 1.5 : GlassEffects.borderOpacity,
                    ),
                    width: 1.0,
                  ),
                  boxShadow: widget.customShadows ?? GlassEffects.glassShadows(
                    accentColor: accentColor,
                    intensity: _isHovered ? 1.2 : 1.0,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                    child: widget.child,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}