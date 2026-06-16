import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
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

void _validateEnvironment() {
  if (!kDebugMode && !kProfileMode) return;

  final required = {
    'SUPABASE_URL': const String.fromEnvironment('SUPABASE_URL'),
    'SUPABASE_ANON_KEY': const String.fromEnvironment('SUPABASE_ANON_KEY'),
  };

  final missing = <String>[];
  for (final entry in required.entries) {
    if (entry.value.isEmpty) missing.add(entry.key);
  }

  if (missing.isNotEmpty) {
    Logger.warning(
      'Variables de entorno no configuradas: ${missing.join(', ')}. '
      'Usa --dart-define=CLAVE=VALOR o --dart-define-from-file=.env',
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _validateEnvironment();

  await SentryFlutter.init(
    (options) {
      options.dsn = const String.fromEnvironment('SENTRY_DSN');
      options.tracesSampleRate = 0.1;
    },
    appRunner: () async {
      if (defaultTargetPlatform == TargetPlatform.android || 
          defaultTargetPlatform == TargetPlatform.iOS) {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }

      if (EnvironmentConfig.enableLogging) {
        Logger.info('Logger initialized');
      }

      await Supabase.initialize(
        url: ApiConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
        debug: kDebugMode,
      );

      runApp(
        ProviderScope(
          child: const PepitoApp(),
        ),
      );
    },
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
      debugShowCheckedModeBanner: kDebugMode,
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
