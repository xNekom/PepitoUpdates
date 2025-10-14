import 'package:flutter/cupertino.dart';

class MacOSGlassConfig {
  // macOS usa más espacio
  static const double cardPadding = 20.0;
  static const double iconSize = 28.0;

  // macOS NO tiene haptics
  static bool get supportsHaptics => false;

  // macOS usa sidebar y toolbar
  static const bool usesNativeTitleBar = true;
  static const bool usesSidebar = true;

  // Window controls (semáforo)
  static const bool showsTrafficLights = true;

  // Hover effects
  static const bool supportsHover = true;
  static const Duration hoverDuration = Duration(milliseconds: 150);

  // Configuración de ventana
  static const double minWindowWidth = 800.0;
  static const double minWindowHeight = 600.0;
  static const double defaultWindowWidth = 1200.0;
  static const double defaultWindowHeight = 800.0;

  // Sidebar
  static const double sidebarWidth = 280.0;
  static const double sidebarMinWidth = 200.0;
  static const double sidebarMaxWidth = 400.0;

  // Toolbar
  static const double toolbarHeight = 52.0;

  // Spacing más amplio
  static const double defaultSpacing = 16.0;
  static const double largeSpacing = 24.0;

  // Typography más grande
  static const double titleFontSize = 22.0;
  static const double bodyFontSize = 14.0;
  static const double captionFontSize = 12.0;

  // Cursor personalizado en hover
  static MouseCursor get clickableCursor => SystemMouseCursors.click;
  static MouseCursor get resizeCursor => SystemMouseCursors.resizeColumn;
}