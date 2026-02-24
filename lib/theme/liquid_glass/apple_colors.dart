import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/pepito_activity.dart';

class AppleColors {
  // Colores primarios del sistema
  static const Color successGreen = Color(0xFF34C759);
  static const Color warningOrange = Color(0xFFFF9500);
  static const Color errorRed = Color(0xFFFF3B30);
  static const Color infoBlue = Color(0xFF007AFF);
  static const Color accentPurple = Color(0xFFAF52DE);
  static const Color accentTeal = Color(0xFF5AC8FA);
  static const Color accentPink = Color(0xFFFF2D55);

  // Colores para actividades
  static Color getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.entrada:
        return successGreen;
      case ActivityType.salida:
        return infoBlue;
      case ActivityType.all:
        return accentPurple;
    }
  }

  // Colores para estados
  static Color getStatusColor(bool isHome) {
    return isHome ? successGreen : warningOrange;
  }

  // Colores para confianza
  static Color getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return successGreen;
    } else if (confidence >= 0.6) {
      return warningOrange;
    } else {
      return errorRed;
    }
  }

  // Colores de background según modo
  static Color backgroundPrimary(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? CupertinoColors.black
        : CupertinoColors.white;
  }

  static Color backgroundSecondary(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? CupertinoColors.systemGrey6.darkColor
        : CupertinoColors.systemGrey6.color;
  }

  // Colores de texto adaptativos
  static Color textPrimary(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? CupertinoColors.white
        : CupertinoColors.black;
  }

  static Color textSecondary(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? CupertinoColors.systemGrey
        : CupertinoColors.systemGrey2.darkColor;
  }

  // Gradientes para diferentes estados
  static LinearGradient successGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        successGreen.withValues(alpha: 0.8),
        successGreen.withValues(alpha: 0.6),
        successGreen.withValues(alpha: 0.4),
      ],
    );
  }

  static LinearGradient warningGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        warningOrange.withValues(alpha: 0.8),
        warningOrange.withValues(alpha: 0.6),
        warningOrange.withValues(alpha: 0.4),
      ],
    );
  }

  static LinearGradient errorGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        errorRed.withValues(alpha: 0.8),
        errorRed.withValues(alpha: 0.6),
        errorRed.withValues(alpha: 0.4),
      ],
    );
  }

  // Colores para gráficos y estadísticas
  static List<Color> chartColors() {
    return [
      infoBlue,
      successGreen,
      accentPurple,
      accentTeal,
      warningOrange,
      accentPink,
      errorRed,
    ];
  }

  // Colores para diferentes niveles de intensidad
  static Color withIntensity(Color color, double intensity) {
    return color.withValues(alpha: intensity.clamp(0.0, 1.0));
  }

  // Método para obtener colores complementarios
  static Color complementaryColor(Color color) {
    // Lógica simple para obtener colores complementarios
    final hsl = HSLColor.fromColor(color);
    return hsl.withHue((hsl.hue + 180) % 360).toColor();
  }
}