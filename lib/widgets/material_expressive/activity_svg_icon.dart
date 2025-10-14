import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/pepito_activity.dart';
import '../utils/theme_utils.dart';

class ActivitySvgIcon extends StatelessWidget {
  final PepitoActivity activity;
  final double size;
  final bool showAnimation;

  const ActivitySvgIcon({
    super.key,
    required this.activity,
    this.size = 24,
    this.showAnimation = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getActivityColor(activity.type);
    final svgPath = _getSvgPath();
    final containerSize = size + 16;
    
    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: SvgPicture.asset(
          svgPath,
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(
            color,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  String _getSvgPath() {
    // Determinar qué imagen SVG usar basado en el tipo de actividad y hora
    final hour = activity.dateTime.hour;
    
    if (activity.isEntry) {
      // Actividades de entrada (llegada a casa)
      if (hour >= 22 || hour <= 6) {
        // Horario de sueño
        return 'assets/images/cat_sleeping.svg';
      } else if (hour >= 7 && hour <= 11) {
        // Horario de comida (mañana)
        return 'assets/images/cat_eating.svg';
      } else if (hour >= 12 && hour <= 18) {
        // Horario activo
        return 'assets/images/cat_active.svg';
      } else {
        // Horario de juego (tarde/noche)
        return 'assets/images/cat_playing.svg';
      }
    } else {
      // Actividades de salida (exploración)
      if (hour >= 6 && hour <= 12) {
        // Mañana - activo
        return 'assets/images/cat_active.svg';
      } else if (hour >= 13 && hour <= 19) {
        // Tarde - jugando/explorando
        return 'assets/images/cat_playing.svg';
      } else {
        // Noche - menos activo pero despierto
        return 'assets/images/cat_active.svg';
      }
    }
  }
}

class ActivityAnimatedIcon extends StatefulWidget {
  final PepitoActivity activity;
  final double size;

  const ActivityAnimatedIcon({
    super.key,
    required this.activity,
    this.size = 24,
  });

  @override
  State<ActivityAnimatedIcon> createState() => _ActivityAnimatedIconState();
}

class _ActivityAnimatedIconState extends State<ActivityAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    // Iniciar animación si es una actividad reciente (menos de 5 minutos)
    final now = DateTime.now();
    final difference = now.difference(widget.activity.dateTime);
    if (difference.inMinutes < 5) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: ActivitySvgIcon(
            activity: widget.activity,
            size: widget.size,
          ),
        );
      },
    );
  }
}