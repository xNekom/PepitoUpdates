import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class CirclesBackground extends StatefulWidget {
  final ScrollController? scrollController;
  final double parallaxFactor;
  final Color? accentColor;
  final int blobCount;

  const CirclesBackground({
    super.key,
    this.scrollController,
    this.parallaxFactor = 0.3,
    this.accentColor,
    this.blobCount = 5,
  });

  @override
  State<CirclesBackground> createState() => _CirclesBackgroundState();
}

class _CirclesBackgroundState extends State<CirclesBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (widget.scrollController?.hasClients ?? false) {
      setState(() {
        _scrollOffset = widget.scrollController!.offset;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = widget.accentColor ?? const Color(0xFFFF6B35);
    final hsl = HSLColor.fromColor(accent);

    final complementaryHue = (hsl.hue + 60) % 360;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF020617) : const Color(0xFFF9FAFB),
      ),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final t = _animationController.value * 2 * math.pi;

          return Stack(
            children: [
              _buildBlob(
                top: -80 + math.sin(t) * 60 + _scrollOffset * widget.parallaxFactor * 0.5,
                left: -80 + math.cos(t * 0.7) * 60,
                size: 380,
                color: (isDark ? accent.withValues(alpha: 0.12) : accent.withValues(alpha: 0.18)),
              ),
              _buildBlob(
                top: MediaQuery.of(context).size.height * 0.25 + math.cos(t * 1.3) * 70 + _scrollOffset * widget.parallaxFactor,
                right: -120 + math.sin(t * 1.1) * 50,
                size: 480,
                color: (isDark
                    ? HSLColor.fromAHSL(0.10, complementaryHue, 0.6, 0.3).toColor()
                    : HSLColor.fromAHSL(0.15, complementaryHue, 0.5, 0.7).toColor()),
              ),
              _buildBlob(
                top: MediaQuery.of(context).size.height * 0.65 + math.sin(t * 0.9) * 50 + _scrollOffset * widget.parallaxFactor * 1.5,
                left: MediaQuery.of(context).size.width * 0.15 + math.cos(t * 1.2) * 80,
                size: 420,
                color: (isDark
                    ? HSLColor.fromAHSL(0.08, (complementaryHue + 60) % 360, 0.5, 0.4).toColor()
                    : HSLColor.fromAHSL(0.12, (complementaryHue + 60) % 360, 0.4, 0.8).toColor()),
              ),
              if (widget.blobCount >= 4)
                _buildBlob(
                  top: MediaQuery.of(context).size.height * 0.45 + math.cos(t * 0.6) * 40 + _scrollOffset * widget.parallaxFactor * 0.8,
                  right: MediaQuery.of(context).size.width * 0.1 + math.sin(t * 0.8) * 60,
                  size: 300,
                  color: (isDark
                      ? accent.withValues(alpha: 0.06)
                      : accent.withValues(alpha: 0.10)),
                ),
              if (widget.blobCount >= 5)
                _buildBlob(
                  top: MediaQuery.of(context).size.height * 0.85 + math.sin(t * 1.4) * 30 + _scrollOffset * widget.parallaxFactor * 2.0,
                  left: MediaQuery.of(context).size.width * 0.7 + math.cos(t * 1.5) * 50,
                  size: 350,
                  color: (isDark
                      ? HSLColor.fromAHSL(0.07, (hsl.hue + 120) % 360, 0.5, 0.35).toColor()
                      : HSLColor.fromAHSL(0.10, (hsl.hue + 120) % 360, 0.4, 0.75).toColor()),
                ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80.0, sigmaY: 80.0),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBlob({
    required double top,
    double? left,
    double? right,
    required double size,
    required Color color,
  }) {
    assert(left != null || right != null, 'Either left or right must be provided');

    return Positioned(
      top: top,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: size / 2,
              spreadRadius: size / 4,
            ),
          ],
        ),
      ),
    );
  }
}
