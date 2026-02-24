import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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
    
    // Proveer una única y espectacular experiencia Premium UI para todas las plataformas
    return _buildLiquidGlassApp(themeMode, locale);
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

}
