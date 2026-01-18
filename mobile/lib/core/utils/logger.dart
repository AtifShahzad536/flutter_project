import 'package:flutter/foundation.dart';

class AppLogger {
  static void debug(String message) {
    if (kDebugMode) {
      print('DEBUG: $message');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      print('INFO: $message');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('ERROR: $message');
      if (error != null) print('Error Details: $error');
      if (stackTrace != null) print('Stack Trace: $stackTrace');
    }
  }
}
