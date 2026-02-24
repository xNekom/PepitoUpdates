import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';
import '../../../models/pepito_activity.dart';
import '../../../theme/liquid_glass/apple_colors.dart';
import '../../../theme/liquid_glass/glass_effects.dart';

class LiquidActivityIcon extends StatelessWidget {
  final PepitoActivity activity;
  final double size;
  final bool showAnimation;

  const LiquidActivityIcon({
    super.key,
    required this.activity,
    this.size = 24,
    this.showAnimation = false,
  });

  @override
  Widget build(BuildContext context) {
    final activityType = _getActivityType();
    final color = AppleColors.getActivityColor(activityType);
    final iconData = _getIconData(); // Cambiado de _getSvgPath
    final containerSize = size + 16;

    // Verificar si es reciente para animación
    final now = DateTime.now();
    final difference = now.difference(activity.dateTime);
    final isRecent = difference.inMinutes < 5;

    final iconWidget = Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.1),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: GlassEffects.glassShadows(
          accentColor: color,
          intensity: 0.5,
        ),
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Center(
            child: Icon(
              iconData,
              size: size,
              color: color,
            ),
          ),
        ),
      ),
    );

    if (isRecent && showAnimation) {
      return _AnimatedIcon(child: iconWidget);
    }

    return iconWidget;
  }

  ActivityType _getActivityType() {
    switch (activity.type) {
      case 'in':
        return ActivityType.entrada;
      case 'out':
        return ActivityType.salida;
      default:
        return ActivityType.entrada; // Default a entrada
    }
  }

  IconData _getIconData() {
    final hour = activity.dateTime.hour;

    if (activity.isEntry) {
      if (hour >= 22 || hour <= 6) {
        return CupertinoIcons.moon_fill; // Durmiendo
      } else if (hour >= 6 && hour <= 12) {
        return CupertinoIcons.sun_max_fill; // Comiendo/Mañana
      } else {
        return CupertinoIcons.paw_solid; // Activo
      }
    } else {
      if (hour >= 6 && hour <= 12) {
        return CupertinoIcons.sun_haze_fill; // Comiendo/Mañana
      } else if (hour >= 12 && hour <= 18) {
        return CupertinoIcons.game_controller_solid; // Jugando
      } else {
        return CupertinoIcons.moon_zzz_fill; // Durmiendo
      }
    }
  }
}

class _AnimatedIcon extends StatefulWidget {
  final Widget child;

  const _AnimatedIcon({required this.child});

  @override
  State<_AnimatedIcon> createState() => _AnimatedIconState();
}

class _AnimatedIconState extends State<_AnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppleColors.getActivityColor(ActivityType.entrada).withValues(alpha: _glowAnimation.value),
                blurRadius: 20 * _glowAnimation.value,
                spreadRadius: 5 * _glowAnimation.value,
              ),
            ],
          ),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}