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
    url: ApiConfig.supabaseUrl,  // Cambiado para usar proxy en desarrollo web
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
    final themeMode = _convertToThemeMode(appThemeMode);
    final locale = ref.watch(localeProvider);
    
    // Inicializar servicios
    ref.read(apiServiceProvider).initialize();
    
    // Notificaciones deshabilitadas por ahora
    // TODO: Implementar notificaciones si es necesario
    
    ref.read(sseServiceProvider).connect();
    
    // Determinar qué tipo de app usar según la plataforma
    if (kIsWeb) {
      return _buildMaterialApp(themeMode, locale);
    } else if (defaultTargetPlatform == TargetPlatform.windows) {
      return _buildFluentApp(themeMode, locale);
    } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      return _buildLiquidGlassApp(themeMode, locale);
    } else {
      return _buildMaterialApp(themeMode, locale);
    }
  }
  
  ThemeMode _convertToThemeMode(AppThemeMode appThemeMode) {
    switch (appThemeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
  
  Widget _buildMaterialApp(ThemeMode themeMode, Locale locale) {
    return MaterialApp(
      title: 'Pépito',
      debugShowCheckedModeBanner: EnvironmentConfig.enableDebugMode,
      themeMode: themeMode,
      theme: kIsWeb ? AppTheme.webTheme : AppTheme.lightTheme,
      darkTheme: kIsWeb ? AppTheme.webDarkTheme : AppTheme.darkTheme,
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
      home: const SelectionArea(child: HomeScreen()),
    );
  }

  Widget _buildLiquidGlassApp(ThemeMode themeMode, Locale locale) {
    return MaterialApp(
      title: 'Pépito - Liquid Glass',
      debugShowCheckedModeBanner: EnvironmentConfig.enableDebugMode,
      themeMode: themeMode,
      theme: AppTheme.liquidGlassLightTheme,
      darkTheme: AppTheme.liquidGlassDarkTheme,
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
  }
  
  Widget _buildFluentApp(ThemeMode themeMode, Locale locale) {
    return fluent.FluentApp(
      title: 'Pépito',
      debugShowCheckedModeBanner: EnvironmentConfig.enableDebugMode,
      themeMode: themeMode,
      theme: AppTheme.fluentLightTheme,
      darkTheme: AppTheme.fluentDarkTheme,
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
  }
}
