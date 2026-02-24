import 'package:flutter/material.dart';
import 'dart:math';

class LiquidBubblesTransition extends StatefulWidget {
  static _LiquidBubblesTransitionState? of(BuildContext context) {
    return context.findAncestorStateOfType<_LiquidBubblesTransitionState>();
  }

  final Widget child;
  final int bubbleCount;
  final Duration duration;
  final Curve curve;
  final Color bubbleColor;

  const LiquidBubblesTransition({
    super.key,
    required this.child,
    this.bubbleCount = 8,
    this.duration = const Duration(milliseconds: 450),
    this.curve = Curves.easeInOut,
    this.bubbleColor = const Color(0x60FFFFFF),
  });

  @override
  State<LiquidBubblesTransition> createState() =>
      _LiquidBubblesTransitionState();
}

class _LiquidBubblesTransitionState extends State<LiquidBubblesTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final Random _random = Random();
  final List<BubbleData> _bubbles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);

    // Inicializar burbujas
    _initializeBubbles();
  }

  void _initializeBubbles() {
    _bubbles.clear();
    for (int i = 0; i < widget.bubbleCount; i++) {
      _bubbles.add(
        BubbleData(
          size: _random.nextDouble() * 20 + 8, // 8-28px
          opacity: _random.nextDouble() * 0.4 + 0.2, // 0.2-0.6
          startX: _random.nextDouble(),
          startY: _random.nextDouble(),
          endX: _random.nextDouble(),
          endY: _random.nextDouble(),
          delay: _random.nextDouble() * 0.3, // 0-0.3s delay
        ),
      );
    }
  }

  void startAnimation() {
    if (_controller.status != AnimationStatus.forward) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(LiquidBubblesTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bubbleCount != widget.bubbleCount) {
      _initializeBubbles();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [widget.child, ..._buildBubbles()]);
  }

  List<Widget> _buildBubbles() {
    return _bubbles.map((bubble) {
      return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final animationValue = _animation.value;
          final delayedValue =
              max(0.0, animationValue - bubble.delay) / (1 - bubble.delay);

          if (delayedValue <= 0) return const SizedBox.shrink();

          final currentX =
              bubble.startX + (bubble.endX - bubble.startX) * delayedValue;
          final currentY =
              bubble.startY + (bubble.endY - bubble.startY) * delayedValue;
          final currentOpacity = bubble.opacity * delayedValue;
          final currentSize = bubble.size * (0.8 + 0.4 * delayedValue);

          return Positioned(
            left: currentX * MediaQuery.of(context).size.width,
            top: currentY * MediaQuery.of(context).size.height,
            child: Opacity(
              opacity: currentOpacity,
              child: Container(
                width: currentSize,
                height: currentSize,
                decoration: BoxDecoration(
                  color: widget.bubbleColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.bubbleColor.withValues(alpha: 0.5),
                      blurRadius: currentSize / 2,
                      spreadRadius: currentSize / 4,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }
}

class BubbleData {
  final double size;
  final double opacity;
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double delay;

  BubbleData({
    required this.size,
    required this.opacity,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.delay,
  });
}
