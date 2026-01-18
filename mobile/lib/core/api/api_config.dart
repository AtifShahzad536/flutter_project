import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _scheme = 'http';
  static const String _path = '/api/v1';

  static const String _hostFromEnv = String.fromEnvironment('API_HOST');

  static String get host {
    if (_hostFromEnv.isNotEmpty) return _hostFromEnv;
    if (kIsWeb) return 'localhost:8000';
    if (defaultTargetPlatform == TargetPlatform.android) return '10.0.2.2:8000';
    return 'localhost:8000';
  }

  static String get baseUrl => '$_scheme://$host$_path';
}
