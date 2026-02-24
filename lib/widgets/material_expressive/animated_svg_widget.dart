import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnimatedSvgWidget extends StatefulWidget {
  final String assetPath;
  final double width;
  final double height;
  final Color? color;
  final Duration duration;
  final bool autoStart;

  const AnimatedSvgWidget({
    super.key,
    required this.assetPath,
    this.width = 100,
    this.height = 100,
    this.color,
    this.duration = const Duration(seconds: 2),
    this.autoStart = true,
  });

  @override
  State<AnimatedSvgWidget> createState() => _AnimatedSvgWidgetState();
}

class _AnimatedSvgWidgetState extends State<AnimatedSvgWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.autoStart) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void startAnimation() {
    _controller.repeat(reverse: true);
  }

  void stopAnimation() {
    _controller.stop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: SvgPicture.asset(
                widget.assetPath,
                width: widget.width,
                height: widget.height,
                colorFilter: widget.color != null
                    ? ColorFilter.mode(
                        widget.color!,
                        BlendMode.srcIn,
                      )
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}

class HeartBeatWidget extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;

  const HeartBeatWidget({
    super.key,
    this.size = 24,
    this.color,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<HeartBeatWidget> createState() => _HeartBeatWidgetState();
}

class _HeartBeatWidgetState extends State<HeartBeatWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.1),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0),
        weight: 25,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat();
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
          child: SvgPicture.asset(
            'assets/animations/heart_beat.svg',
            width: widget.size,
            height: widget.size,
            colorFilter: widget.color != null
                ? ColorFilter.mode(
                    widget.color!,
                    BlendMode.srcIn,
                  )
                : null,
          ),
        );
      },
    );
  }
}

class WaveActivityWidget extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;

  const WaveActivityWidget({
    super.key,
    this.size = 24,
    this.color,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<WaveActivityWidget> createState() => _WaveActivityWidgetState();
}

class _WaveActivityWidgetState extends State<WaveActivityWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

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
      animation: _opacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: SvgPicture.asset(
            'assets/animations/wave_activity.svg',
            width: widget.size,
            height: widget.size,
            colorFilter: widget.color != null
                ? ColorFilter.mode(
                    widget.color!,
                    BlendMode.srcIn,
                  )
                : null,
          ),
        );
      },
    );
  }
}