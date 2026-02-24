import 'package:flutter/material.dart';

/// Widget de fondo con círculos animados para Liquid Glass
class CirclesBackground extends StatelessWidget {
  const CirclesBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
            ? [
                const Color(0xFF0F172A), // Dark Slate
                const Color(0xFF020617), // Darker Slate
                const Color(0xFF000000), // Pure Black
              ]
            : [
                const Color(0xFFE8F4FD), // Azul muy claro
                const Color(0xFFF1F8FF), // Casi blanco con tinte azul
                const Color(0xFFFAFBFF), // Blanco con muy poco azul
              ],
        ),
      ),
      child: Stack(
        children: [
          // Círculos decorativos simples
          Positioned(
            top: 100,
            left: 50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark 
                    ? Colors.blue.withValues(alpha: 0.04) 
                    : Colors.blue.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            right: 30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark 
                    ? Colors.purple.withValues(alpha: 0.03) 
                    : Colors.purple.withValues(alpha: 0.06),
              ),
            ),
          ),
        ],
      ),
    );
  }
}