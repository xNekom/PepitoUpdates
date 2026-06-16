import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class Logger {
  static void info(String message) {
    developer.log(message, name: 'Pepito.INFO');
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: 'Pepito.ERROR',
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void warning(String message) {
    developer.log(message, name: 'Pepito.WARNING');
  }

  static void debug(String message) {
    if (kDebugMode) {
      developer.log(message, name: 'Pepito.DEBUG');
    }
  }
}
