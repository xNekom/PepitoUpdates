import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';

/// Modern fluid mesh gradient background for Liquid Glass aesthetic
class CirclesBackground extends StatefulWidget {
  const CirclesBackground({super.key});

  @override
  State<CirclesBackground> createState() => _CirclesBackgroundState();
}

class _CirclesBackgroundState extends State<CirclesBackground> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              // Gran mancha superior izquierda
              Positioned(
                top: -100 + math.sin(t) * 50,
                left: -100 + math.cos(t) * 50,
                child: _buildBlob(
                  size: 400,
                  color: isDark 
                      ? const Color(0xFF1E3A8A).withValues(alpha: 0.15) // Deep blue
                      : const Color(0xFF93C5FD).withValues(alpha: 0.20), // Light blue
                ),
              ),
              // Mancha central derecha
              Positioned(
                top: MediaQuery.of(context).size.height * 0.3 + math.cos(t * 1.5) * 60,
                right: -150 + math.sin(t * 1.2) * 40,
                child: _buildBlob(
                  size: 500,
                  color: isDark 
                      ? const Color(0xFF4C1D95).withValues(alpha: 0.1) // Deep purple
                      : const Color(0xFFC4B5FD).withValues(alpha: 0.15), // Light purple
                ),
              ),
              // Mancha inferior
              Positioned(
                bottom: -150 + math.sin(t * 0.8) * 40,
                left: MediaQuery.of(context).size.width * 0.1 + math.cos(t * 1.1) * 70,
                child: _buildBlob(
                  size: 450,
                  color: isDark 
                      ? const Color(0xFF0EA5E9).withValues(alpha: 0.1) // Sky blue
                      : const Color(0xFF7DD3FC).withValues(alpha: 0.15), // Light sky blue
                ),
              ),
              // Capa de desenfoque general para mezclar los gradientes
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

  Widget _buildBlob({required double size, required Color color}) {
    return Container(
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
    );
  }
}