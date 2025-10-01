import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static const String _languageKey = 'selected_language';
  
  static const List<Locale> supportedLocales = [
    Locale('es', ''), // Español
    Locale('en', ''), // Inglés
  ];
  
  static Future<Locale> getStoredLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);
    
    if (languageCode != null) {
      return Locale(languageCode);
    }
    
    // Si no hay idioma guardado, usar el idioma del sistema si está soportado
    final systemLocale = PlatformDispatcher.instance.locale;
    if (supportedLocales.any((locale) => locale.languageCode == systemLocale.languageCode)) {
      return Locale(systemLocale.languageCode);
    }
    
    // Por defecto, usar español
    return const Locale('es');
  }
  
  static Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
  }
  
  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      default:
        return languageCode;
    }
  }
}