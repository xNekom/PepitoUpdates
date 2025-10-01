import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart';

class AppTheme {
  // M3E - Colores expresivos y emocionales de Pépito
  static const Color primaryOrange = Color(0xFFFF6B35); // Naranja vibrante M3E
  static const Color secondaryOrange = Color(0xFFFF8C42); // Naranja cálido expresivo
  static const Color accentGreen = Color(0xFF00B894); // Verde energético
  static const Color backgroundLight = Color(0xFFFFFBF7); // Blanco cálido expresivo
  static const Color backgroundDark = Color(0xFF0D1117); // Negro profundo con matiz
  
  // M3E - Colores de estado expresivos
  static const Color successColor = Color(0xFF00B894); // Verde vibrante
  static const Color warningColor = Color(0xFFFFAB00); // Ámbar expresivo
  static const Color errorColor = Color(0xFFE74C3C); // Rojo emocional
  static const Color infoColor = Color(0xFF3498DB); // Azul expresivo
  
  // M3E - Colores expresivos adicionales
  static const Color expressivePurple = Color(0xFF9B59B6); // Púrpura creativo
  static const Color expressiveTeal = Color(0xFF1ABC9C); // Verde azulado dinámico
  static const Color expressiveIndigo = Color(0xFF6C5CE7); // Índigo moderno
  
  // Colores adicionales para web moderna
  static const Color neutralGray50 = Color(0xFFF9FAFB);
  static const Color neutralGray100 = Color(0xFFF3F4F6);
  static const Color neutralGray200 = Color(0xFFE5E7EB);
  static const Color neutralGray300 = Color(0xFFD1D5DB);
  static const Color neutralGray400 = Color(0xFF9CA3AF);
  static const Color neutralGray500 = Color(0xFF6B7280);
  static const Color neutralGray600 = Color(0xFF4B5563);
  static const Color neutralGray700 = Color(0xFF374151);
  static const Color neutralGray800 = Color(0xFF1F2937);
  static const Color neutralGray900 = Color(0xFF111827);
  
  // Alias para compatibilidad
  static Color get primaryColor => primaryOrange;

  // Generar esquema de colores Material 3
  static ColorScheme _generateColorScheme(Color seedColor, Brightness brightness) {
    final scheme = CorePalette.of(seedColor.toARGB32());
    
    if (brightness == Brightness.light) {
      return ColorScheme(
        brightness: Brightness.light,
        primary: Color(scheme.primary.get(40)),
        onPrimary: Color(scheme.primary.get(100)),
        primaryContainer: Color(scheme.primary.get(90)),
        onPrimaryContainer: Color(scheme.primary.get(10)),
        secondary: Color(scheme.secondary.get(40)),
        onSecondary: Color(scheme.secondary.get(100)),
        secondaryContainer: Color(scheme.secondary.get(90)),
        onSecondaryContainer: Color(scheme.secondary.get(10)),
        tertiary: Color(scheme.tertiary.get(40)),
        onTertiary: Color(scheme.tertiary.get(100)),
        tertiaryContainer: Color(scheme.tertiary.get(90)),
        onTertiaryContainer: Color(scheme.tertiary.get(10)),
        error: Color(scheme.error.get(40)),
        onError: Color(scheme.error.get(100)),
        errorContainer: Color(scheme.error.get(90)),
        onErrorContainer: Color(scheme.error.get(10)),
        surface: Color(scheme.neutral.get(99)),
        onSurface: Color(scheme.neutral.get(10)),
        surfaceContainerHighest: Color(scheme.neutralVariant.get(90)),
        onSurfaceVariant: Color(scheme.neutralVariant.get(30)),
        outline: Color(scheme.neutralVariant.get(50)),
        outlineVariant: Color(scheme.neutralVariant.get(80)),
        shadow: Color(scheme.neutral.get(0)),
        scrim: Color(scheme.neutral.get(0)),
        inverseSurface: Color(scheme.neutral.get(20)),
        onInverseSurface: Color(scheme.neutral.get(95)),
        inversePrimary: Color(scheme.primary.get(80)),
        surfaceTint: Color(scheme.primary.get(40)),
      );
    } else {
      return ColorScheme(
        brightness: Brightness.dark,
        primary: Color(scheme.primary.get(80)),
        onPrimary: Color(scheme.primary.get(20)),
        primaryContainer: Color(scheme.primary.get(30)),
        onPrimaryContainer: Color(scheme.primary.get(90)),
        secondary: Color(scheme.secondary.get(80)),
        onSecondary: Color(scheme.secondary.get(20)),
        secondaryContainer: Color(scheme.secondary.get(30)),
        onSecondaryContainer: Color(scheme.secondary.get(90)),
        tertiary: Color(scheme.tertiary.get(80)),
        onTertiary: Color(scheme.tertiary.get(20)),
        tertiaryContainer: Color(scheme.tertiary.get(30)),
        onTertiaryContainer: Color(scheme.tertiary.get(90)),
        error: Color(scheme.error.get(80)),
        onError: Color(scheme.error.get(20)),
        errorContainer: Color(scheme.error.get(30)),
        onErrorContainer: Color(scheme.error.get(90)),
        surface: Color(scheme.neutral.get(10)),
        onSurface: Color(scheme.neutral.get(90)),
        surfaceContainerHighest: Color(scheme.neutralVariant.get(30)),
        onSurfaceVariant: Color(scheme.neutralVariant.get(80)),
        outline: Color(scheme.neutralVariant.get(60)),
        outlineVariant: Color(scheme.neutralVariant.get(30)),
        shadow: Color(scheme.neutral.get(0)),
        scrim: Color(scheme.neutral.get(0)),
        inverseSurface: Color(scheme.neutral.get(90)),
        onInverseSurface: Color(scheme.neutral.get(20)),
        inversePrimary: Color(scheme.primary.get(40)),
        surfaceTint: Color(scheme.primary.get(80)),
      );
    }
  }

  // Tema claro
  static ThemeData get lightTheme {
    final colorScheme = _generateColorScheme(primaryOrange, Brightness.light);
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Roboto',
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Cards
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: colorScheme.surface,
      ),
      
      // Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // M3E Inputs - Formas expresivas y feedback dinámico
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundLight.withValues(alpha: 0.8), // M3E: Fondo expresivo
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20), // M3E: Bordes más expresivos
          borderSide: BorderSide(
            color: primaryOrange.withValues(alpha: 0.2), // M3E: Borde sutil colorido
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: primaryOrange.withValues(alpha: 0.3), // M3E: Borde expresivo habilitado
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: expressiveTeal, // M3E: Color contrastante en foco
            width: 3, // M3E: Grosor expresivo
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: errorColor, // M3E: Color de error expresivo
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: errorColor,
            width: 3, // M3E: Feedback de error expresivo
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // M3E: Padding generoso
        labelStyle: TextStyle(
          color: primaryOrange, // M3E: Etiquetas coloridas
          fontWeight: FontWeight.w600,
        ),
        floatingLabelStyle: TextStyle(
          color: expressiveTeal, // M3E: Etiqueta flotante expresiva
          fontWeight: FontWeight.w700,
        ),
      ),
      
      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Dividers
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withValues(alpha: 0.2),
        thickness: 1,
      ),
      
      // List Tiles
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Tema oscuro
  static ThemeData get darkTheme {
    final colorScheme = _generateColorScheme(primaryOrange, Brightness.dark);
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Roboto',
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Cards
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: colorScheme.surface,
      ),
      
      // Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Dividers
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withValues(alpha: 0.2),
        thickness: 1,
      ),
      
      // List Tiles
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Tema específico para Windows (Fluent Design)
  static ThemeData get windowsTheme {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.windows) return lightTheme;
    
    final colorScheme = _generateColorScheme(primaryOrange, Brightness.light);
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Segoe UI',
      
      // Estilo más cuadrado para Windows
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: colorScheme.surface,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  // Tema específico para Web (Diseño moderno y plano)
  static ThemeData get webTheme {
    final colorScheme = _generateColorScheme(primaryOrange, Brightness.light);
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Inter, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
      
      // Tipografía moderna inspirada en NYT
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
          color: neutralGray900,
          height: 1.12,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: neutralGray900,
          height: 1.16,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: neutralGray900,
          height: 1.22,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          color: neutralGray900,
          height: 1.25,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25,
          color: neutralGray900,
          height: 1.29,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: neutralGray900,
          height: 1.33,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          color: neutralGray900,
          height: 1.27,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          color: neutralGray900,
          height: 1.5,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: neutralGray900,
          height: 1.43,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          color: neutralGray700,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: neutralGray700,
          height: 1.43,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          color: neutralGray600,
          height: 1.33,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: neutralGray900,
          height: 1.43,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: neutralGray900,
          height: 1.33,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: neutralGray900,
          height: 1.45,
        ),
      ),
      
      // M3E AppBar - Tipografía expresiva y presencia dinámica
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundLight,
        foregroundColor: neutralGray900,
        elevation: 8, // M3E: Elevación expresiva
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: primaryOrange, // M3E: Color primario expresivo
          fontSize: 32, // M3E: Tamaño más prominente
          fontWeight: FontWeight.w800, // M3E: Peso ultra expresivo
          letterSpacing: -1.0, // M3E: Espaciado más dramático
          height: 1.1,
        ),
        shadowColor: primaryOrange.withValues(alpha: 0.2), // M3E: Sombra colorida
        surfaceTintColor: primaryOrange.withValues(alpha: 0.05), // M3E: Tinte sutil
        toolbarHeight: 80, // M3E: Altura más expresiva
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24), // M3E: Forma expresiva
            bottomRight: Radius.circular(24),
          ),
        ),
      ),
      
      // M3E Cards - Formas expresivas y contención dinámica
      cardTheme: CardThemeData(
        elevation: 4, // M3E: Elevación expresiva
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // M3E: Bordes más expresivos
          side: BorderSide(
            color: primaryOrange.withValues(alpha: 0.1), // M3E: Borde sutil con color primario
            width: 1.5,
          ),
        ),
        color: backgroundLight,
        shadowColor: primaryOrange.withValues(alpha: 0.15), // M3E: Sombra con color expresivo
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // M3E Botones - Formas expresivas y movimiento dinámico
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 6, // M3E: Elevación expresiva
          shadowColor: primaryOrange.withValues(alpha: 0.3), // M3E: Sombra colorida
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // M3E: Bordes más expresivos
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20), // M3E: Padding generoso
          textStyle: const TextStyle(
            fontSize: 16, // M3E: Texto más prominente
            fontWeight: FontWeight.w700, // M3E: Peso más expresivo
            letterSpacing: 0.5, // M3E: Espaciado expresivo
          ),
          minimumSize: const Size(140, 60), // M3E: Tamaño más expresivo
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                return secondaryOrange; // M3E: Color secundario en hover
              }
              if (states.contains(WidgetState.pressed)) {
                return expressiveTeal; // M3E: Color contrastante en press
              }
              return primaryOrange;
            },
          ),
          elevation: WidgetStateProperty.resolveWith<double?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                return 12; // M3E: Elevación dinámica en hover
              }
              if (states.contains(WidgetState.pressed)) {
                return 2; // M3E: Reducción expresiva en press
              }
              return 6;
            },
          ),
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                return Colors.white.withValues(alpha: 0.15); // M3E: Overlay más visible
              }
              if (states.contains(WidgetState.pressed)) {
                return Colors.white.withValues(alpha: 0.25); // M3E: Feedback táctil expresivo
              }
              return null;
            },
          ),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          minimumSize: const Size(120, 54),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                return const Color(0xFFD04E00); // Naranja más oscuro en hover
              }
              if (states.contains(WidgetState.pressed)) {
                return const Color(0xFFB8440A); // Aún más oscuro en press
              }
              return primaryOrange;
            },
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryOrange,
          side: BorderSide(color: primaryOrange, width: 1.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          backgroundColor: Colors.transparent,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          minimumSize: const Size(120, 54),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                return primaryOrange.withValues(alpha: 0.04);
              }
              if (states.contains(WidgetState.pressed)) {
                return primaryOrange.withValues(alpha: 0.08);
              }
              return Colors.transparent;
            },
          ),
          side: WidgetStateProperty.resolveWith<BorderSide?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                return BorderSide(color: const Color(0xFFD04E00), width: 1.5);
              }
              return BorderSide(color: primaryOrange, width: 1.5);
            },
          ),
        ),
      ),
      
      // Inputs modernos para web - estilo PostMuse
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: neutralGray50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: neutralGray200, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: neutralGray200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        labelStyle: TextStyle(
          color: neutralGray600,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        hintStyle: TextStyle(
          color: neutralGray400,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: TextStyle(
          color: primaryOrange,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Navegación estilo web - diseño PostMuse
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        height: 84,
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: neutralGray700,
            letterSpacing: 0.1,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(color: primaryOrange, size: 24);
            }
            return IconThemeData(
              color: neutralGray500,
              size: 24,
            );
          },
        ),
        indicatorColor: primaryOrange.withValues(alpha: 0.08),
        surfaceTintColor: Colors.transparent,
      ),
      
      // Dividers más sutiles - estilo moderno
      dividerTheme: DividerThemeData(
        color: neutralGray200,
        thickness: 1,
        space: 1,
      ),
      
      // List Tiles estilo web - más elegantes
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.transparent,
        selectedTileColor: primaryOrange.withValues(alpha: 0.06),
        iconColor: neutralGray600,
        textColor: neutralGray800,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: neutralGray800,
          letterSpacing: 0.1,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: neutralGray600,
        ),
      ),
      
      // Scaffold con fondo web
      scaffoldBackgroundColor: const Color(0xFFFCFCFC),
    );
  }

  // Tema oscuro para web
  static ThemeData get webDarkTheme {
    final colorScheme = _generateColorScheme(primaryOrange, Brightness.dark);
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Inter, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
      
      // Tipografía moderna para tema oscuro
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
          color: Colors.white,
          height: 1.12,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: Colors.white,
          height: 1.16,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: Colors.white,
          height: 1.22,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          color: Colors.white,
          height: 1.25,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25,
          color: Colors.white,
          height: 1.29,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: Colors.white,
          height: 1.33,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          color: Colors.white,
          height: 1.27,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          color: const Color(0xFFE5E5E5),
          height: 1.5,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: const Color(0xFFE5E5E5),
          height: 1.43,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          color: const Color(0xFFD1D5DB),
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: const Color(0xFFD1D5DB),
          height: 1.43,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          color: const Color(0xFF9CA3AF),
          height: 1.33,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: const Color(0xFFE5E5E5),
          height: 1.43,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: const Color(0xFFE5E5E5),
          height: 1.33,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: const Color(0xFFE5E5E5),
          height: 1.45,
        ),
      ),
      
      // M3E AppBar Oscuro - Tipografía expresiva y presencia dinámica
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundDark,
        foregroundColor: Colors.white,
        elevation: 8, // M3E: Elevación expresiva
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: primaryOrange, // M3E: Color primario expresivo
          fontSize: 32, // M3E: Tamaño más prominente
          fontWeight: FontWeight.w800, // M3E: Peso ultra expresivo
          letterSpacing: -1.0, // M3E: Espaciado más dramático
          height: 1.1,
        ),
        shadowColor: primaryOrange.withValues(alpha: 0.4), // M3E: Sombra colorida más visible
        surfaceTintColor: primaryOrange.withValues(alpha: 0.1), // M3E: Tinte expresivo
        toolbarHeight: 80, // M3E: Altura más expresiva
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24), // M3E: Forma expresiva
            bottomRight: Radius.circular(24),
          ),
        ),
      ),
      
      // M3E Cards Oscuro - Formas expresivas y contención dinámica
      cardTheme: CardThemeData(
        elevation: 6, // M3E: Elevación expresiva
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // M3E: Bordes más expresivos
          side: BorderSide(
            color: primaryOrange.withValues(alpha: 0.2), // M3E: Borde colorido
            width: 1.5,
          ),
        ),
        color: backgroundDark,
        shadowColor: primaryOrange.withValues(alpha: 0.3), // M3E: Sombra colorida expresiva
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Botones estilo web oscuro moderno
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          minimumSize: const Size(120, 54),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                return const Color(0xFFD04E00);
              }
              if (states.contains(WidgetState.pressed)) {
                return const Color(0xFFB8440A);
              }
              return primaryOrange;
            },
          ),
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                return Colors.white.withValues(alpha: 0.08);
              }
              if (states.contains(WidgetState.pressed)) {
                return Colors.white.withValues(alpha: 0.16);
              }
              return null;
            },
          ),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          minimumSize: const Size(120, 54),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                return const Color(0xFFD04E00);
              }
              if (states.contains(WidgetState.pressed)) {
                return const Color(0xFFB8440A);
              }
              return primaryOrange;
            },
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryOrange,
          side: BorderSide(color: primaryOrange, width: 1.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          backgroundColor: Colors.transparent,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          minimumSize: const Size(120, 54),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                return primaryOrange.withValues(alpha: 0.08);
              }
              if (states.contains(WidgetState.pressed)) {
                return primaryOrange.withValues(alpha: 0.16);
              }
              return Colors.transparent;
            },
          ),
          side: WidgetStateProperty.resolveWith<BorderSide?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                return BorderSide(color: const Color(0xFFD04E00), width: 1.5);
              }
              return BorderSide(color: primaryOrange, width: 1.5);
            },
          ),
        ),
      ),
      
      // Inputs modernos para web oscuro
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF374151),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFF4B5563), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFF4B5563), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        labelStyle: TextStyle(
          color: const Color(0xFF9CA3AF),
          fontSize: 15,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        hintStyle: TextStyle(
          color: const Color(0xFF6B7280),
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: TextStyle(
          color: primaryOrange,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Navegación estilo web oscuro
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF1F2937),
        elevation: 0,
        height: 84,
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFD1D5DB),
            letterSpacing: 0.1,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(color: primaryOrange, size: 24);
            }
            return IconThemeData(
              color: const Color(0xFF9CA3AF),
              size: 24,
            );
          },
        ),
        indicatorColor: primaryOrange.withValues(alpha: 0.12),
        surfaceTintColor: Colors.transparent,
      ),
      
      // Dividers más sutiles para tema oscuro
      dividerTheme: DividerThemeData(
        color: const Color(0xFF374151),
        thickness: 1,
        space: 1,
      ),
      
      // List Tiles estilo web oscuro
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.transparent,
        selectedTileColor: primaryOrange.withValues(alpha: 0.12),
        iconColor: const Color(0xFF9CA3AF),
        textColor: const Color(0xFFE5E7EB),
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFE5E7EB),
          letterSpacing: 0.1,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF9CA3AF),
        ),
      ),
      
      // Scaffold con fondo oscuro elegante
      scaffoldBackgroundColor: const Color(0xFF111827),
    );
  }

  // Temas para Fluent Design (Windows)
  static fluent.FluentThemeData get fluentLightTheme {
    return fluent.FluentThemeData(
      brightness: Brightness.light,
      accentColor: fluent.Colors.orange,
      visualDensity: VisualDensity.standard,
    );
  }
  
  static fluent.FluentThemeData get fluentDarkTheme {
    return fluent.FluentThemeData(
      brightness: Brightness.dark,
      accentColor: fluent.Colors.orange,
      visualDensity: VisualDensity.standard,
    );
  }

  // Tema Cupertino con Liquid Glass Design (iOS/macOS)
  static CupertinoThemeData get cupertinoLightTheme {
    return CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: primaryOrange,
      primaryContrastingColor: Colors.white,
      scaffoldBackgroundColor: const Color(0xFFF2F2F7), // Liquid Glass background
      barBackgroundColor: Colors.white.withValues(alpha: 0.8), // Translucent bar
      textTheme: CupertinoTextThemeData(
        primaryColor: primaryOrange,
        textStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          color: const Color(0xFF1C1C1E),
          fontSize: 17,
          fontWeight: FontWeight.w400,
        ),
        navTitleTextStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          color: const Color(0xFF1C1C1E),
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          color: primaryOrange,
          fontSize: 34,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static CupertinoThemeData get cupertinoDarkTheme {
    return CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryOrange,
      primaryContrastingColor: Colors.black,
      scaffoldBackgroundColor: const Color(0xFF000000), // Pure black for Liquid Glass
      barBackgroundColor: const Color(0xFF1C1C1E).withValues(alpha: 0.8), // Translucent dark bar
      textTheme: CupertinoTextThemeData(
        primaryColor: primaryOrange,
        textStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w400,
        ),
        navTitleTextStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          color: primaryOrange,
          fontSize: 34,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
  
  // Obtener el tema según la plataforma
  static ThemeData getPlatformTheme(Brightness brightness) {
    if (kIsWeb) {
      return brightness == Brightness.light ? webTheme : webDarkTheme;
    }
    
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      return windowsTheme;
    }
    
    return brightness == Brightness.light ? lightTheme : darkTheme;
  }

  // Colores de estado para actividades
  static Color getActivityColor(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'entrada':
        return successColor;
      case 'salida':
        return warningColor;
      default:
        return infoColor;
    }
  }

  // Gradientes
  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [primaryOrange, secondaryOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get successGradient => const LinearGradient(
    colors: [successColor, Color(0xFF66BB6A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get warningGradient => const LinearGradient(
    colors: [warningColor, Color(0xFFFFB74D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Helper para obtener colores compatibles con ambos tipos de tema
  static AppColors getColors(BuildContext context) {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      final fluentTheme = fluent.FluentTheme.of(context);
      return AppColors(
        primary: fluentTheme.accentColor.defaultBrushFor(fluentTheme.brightness),
        onPrimary: fluentTheme.brightness == fluent.Brightness.light ? Colors.white : Colors.black,
        surface: fluentTheme.micaBackgroundColor,
        onSurface: fluentTheme.typography.body?.color ?? Colors.black,
        onSurfaceVariant: (fluentTheme.typography.body?.color ?? Colors.black).withValues(alpha: 0.7),
        error: errorColor,
      );
    } else {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      return AppColors(
        primary: colorScheme.primary,
        onPrimary: colorScheme.onPrimary,
        surface: colorScheme.surface,
        onSurface: colorScheme.onSurface,
        onSurfaceVariant: colorScheme.onSurfaceVariant,
        error: colorScheme.error,
      );
    }
  }
}

class AppColors {
  final Color primary;
  final Color onPrimary;
  final Color surface;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color error;
  
  const AppColors({
    required this.primary,
    required this.onPrimary,
    required this.surface,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.error,
  });
}