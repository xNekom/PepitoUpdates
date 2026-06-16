import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'config/supabase_config.dart';
import 'config/environment_config.dart';
import 'config/api_config.dart';
import 'providers/pepito_providers.dart';
import 'utils/theme_utils.dart';
import 'utils/platform_detector.dart';
import 'utils/logger.dart';
import 'screens/home_screen.dart';
import 'generated/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar orientación (solo móviles)
  if (defaultTargetPlatform == TargetPlatform.android || 
      defaultTargetPlatform == TargetPlatform.iOS) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Configurar logging según entorno
  if (EnvironmentConfig.enableLogging) {
    Logger.info('Logger initialized');
  }

  // Inicializar Supabase
  await Supabase.initialize(
    url: ApiConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
    debug: EnvironmentConfig.enableDebugMode,
  );

  // Configurar manejo de errores en producción
  if (EnvironmentConfig.isProduction) {
    FlutterError.onError = (FlutterErrorDetails details) {
      Logger.error('Flutter Error', details.exception);
    };
  }

  runApp(
    ProviderScope(
      child: const PepitoApp(),
    ),
  );
}

class PepitoApp extends ConsumerWidget {
  const PepitoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appThemeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final platformStyle = ref.watch(platformStyleProvider);

    final brightness = appThemeMode == AppThemeMode.dark
        ? Brightness.dark
        : appThemeMode == AppThemeMode.light
            ? Brightness.light
            : PlatformDetector.isWindows ? Brightness.light : Brightness.dark;

    ThemeData? materialTheme;
    ThemeData? materialDarkTheme;
    fluent.FluentThemeData? fluentTheme;
    fluent.FluentThemeData? fluentDarkTheme;

    switch (platformStyle) {
      case WidgetStyle.liquidGlass:
        materialTheme = AppTheme.liquidGlassLightTheme;
        materialDarkTheme = AppTheme.liquidGlassDarkTheme;
      case WidgetStyle.fluentDesign:
        fluentTheme = AppTheme.fluentLightTheme;
        fluentDarkTheme = AppTheme.fluentDarkTheme;
      case WidgetStyle.materialExpressive:
        materialTheme = AppTheme.webTheme;
        materialDarkTheme = AppTheme.webDarkTheme;
    }

    final ThemeMode themeMode;
    if (appThemeMode == AppThemeMode.light) {
      themeMode = ThemeMode.light;
    } else if (appThemeMode == AppThemeMode.dark) {
      themeMode = ThemeMode.dark;
    } else {
      themeMode = ThemeMode.system;
    }

    Widget app = MaterialApp(
      title: 'Pépito Updates',
      debugShowCheckedModeBanner: EnvironmentConfig.enableDebugMode,
      themeMode: themeMode,
      theme: materialTheme,
      darkTheme: materialDarkTheme,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', ''),
        Locale('en', ''),
      ],
      home: const HomeScreen(),
    );

    if (platformStyle == WidgetStyle.fluentDesign && fluentTheme != null) {
      app = fluent.FluentTheme(
        data: brightness == Brightness.dark ? fluentDarkTheme! : fluentTheme,
        child: app,
      );
    }

    return app;
  }
}
