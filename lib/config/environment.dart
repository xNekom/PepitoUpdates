import 'package:flutter/foundation.dart';

class Environment {
  Environment._();

  static const String _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static String get supabaseUrl {
    if (_supabaseUrl.isEmpty) {
      if (kDebugMode) return 'https://ewxarmlqoowlxdqoebcb.supabase.co';
      throw StateError('SUPABASE_URL no configurada. Usa --dart-define=SUPABASE_URL=...');
    }
    return _supabaseUrl;
  }

  static String get supabaseAnonKey {
    if (_supabaseAnonKey.isEmpty) {
      if (kDebugMode) return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV3eGFybWxxb293bHhkcW9lYmNiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ3Mjc0NDksImV4cCI6MjA3MDMwMzQ0OX0.WnAVs80JTH9zZvzI4TV0zsXJVEz0eDn81nfM2UPVJug';
      throw StateError('SUPABASE_ANON_KEY no configurada. Usa --dart-define=SUPABASE_ANON_KEY=...');
    }
    return _supabaseAnonKey;
  }
}
