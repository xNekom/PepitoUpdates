import 'dart:ui';
import 'package:flutter/cupertino.dart';

class GlassEffects {
  // Blur - VisionOS Apple-like look
  static const double blurSigmaLight = 20.0;
  static const double blurSigmaHeavy = 35.0;

  // Opacidades - Adjusted for solid frosted contrast
  static const double backgroundOpacityLight = 0.50; // Blanco más solido para luz
  static const double backgroundOpacityMedium = 0.35; // Oscuro translúcido
  static const double backgroundOpacityHeavy = 0.60;

  static const double borderOpacity = 0.20;
  static const double shadowOpacity = 0.04;

  // Border radius
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;

  // Animaciones Apple
  static const Duration quickAnimation = Duration(milliseconds: 200);
  static const Duration standardAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 400);

  static const Curve appleCurve = Curves.easeInOutCubic;

  // Sombras glass
  static List<BoxShadow> glassShadows({
    required Color accentColor,
    double intensity = 1.0,
  }) {
    return [
      BoxShadow(
        color: accentColor.withValues(alpha: shadowOpacity * intensity),
        blurRadius: 30.0 * intensity,
        spreadRadius: 0.0,
        offset: Offset(0, 8 * intensity),
      ),
    ];
  }

  // Gradientes glass
  static LinearGradient glassGradient({
    required Color accentColor,
    required Brightness brightness,
  }) {
    if (brightness == Brightness.dark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accentColor.withValues(alpha: 0.15),
          accentColor.withValues(alpha: 0.08),
          accentColor.withValues(alpha: 0.05),
        ],
        stops: const [0.0, 0.5, 1.0],
      );
    } else {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accentColor.withValues(alpha: 0.12),
          accentColor.withValues(alpha: 0.06),
          accentColor.withValues(alpha: 0.03),
        ],
        stops: const [0.0, 0.5, 1.0],
      );
    }
  }

  // Border shimmer
  static BoxDecoration shimmerBorder({
    required Color accentColor,
    required BorderRadius borderRadius,
  }) {
    return BoxDecoration(
      borderRadius: borderRadius,
      border: Border.all(
        color: accentColor.withValues(alpha: borderOpacity),
        width: 0.5,
      ),
      boxShadow: [
        BoxShadow(
          color: accentColor.withValues(alpha: 0.05),
          blurRadius: 10.0,
          spreadRadius: 0.0,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Efecto de brillo sutil
  static BoxDecoration subtleGlow({
    required Color accentColor,
    required BorderRadius borderRadius,
    double intensity = 1.0,
  }) {
    return BoxDecoration(
      borderRadius: borderRadius,
      boxShadow: [
        BoxShadow(
          color: accentColor.withValues(alpha: 0.08 * intensity),
          blurRadius: 12.0 * intensity,
          spreadRadius: 1.0 * intensity,
        ),
        BoxShadow(
          color: accentColor.withValues(alpha: 0.04 * intensity),
          blurRadius: 24.0 * intensity,
          spreadRadius: 0.5 * intensity,
        ),
      ],
    );
  }

  // Configuración de backdrop filter
  static BackdropFilter glassBackdropFilter({
    double sigma = blurSigmaLight,
  }) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: Container(
        color: const Color(0x00000000), // Transparent
      ),
    );
  }

  // Container con efecto glass completo - ESTRUCTURA CORREGIDA
  static Widget glassContainer({
    required Widget child,
    required Color accentColor,
    required Brightness brightness,
    required BorderRadius borderRadius,
    double blurSigma = blurSigmaLight,
    EdgeInsets? padding,
  }) {
    final backgroundColor = brightness == Brightness.dark
        ? const Color(0xFF000000).withValues(alpha: backgroundOpacityMedium)
        : const Color(0xFFFFFFFF).withValues(alpha: backgroundOpacityLight);

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: glassShadows(accentColor: accentColor),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor,
              gradient: glassGradient(
                accentColor: accentColor,
                brightness: brightness,
              ),
              border: Border.all(
                color: accentColor.withValues(alpha: borderOpacity),
                width: 0.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}