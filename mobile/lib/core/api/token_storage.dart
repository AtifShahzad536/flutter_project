import 'package:shared_preferences/shared_preferences.dart';
import 'package:export_trix/core/utils/logger.dart';

class TokenStorage {
  static const _tokenKey = 'token';
  static const _roleKey = 'role';

  // In-memory cache for faster access and to prevent race conditions during navigation
  static String? _cachedToken;
  static String? _cachedRole;

  static Future<String?> getToken() async {
    if (_cachedToken != null && _cachedToken != 'null') return _cachedToken;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    // Filter out literal "null" string
    if (token == 'null') {
      await prefs.remove(_tokenKey);
      _cachedToken = null;
      return null;
    }

    _cachedToken = token;
    if (token != null) {
      AppLogger.debug('Retrieved token: Bearer ${token.substring(0, 10)}...');
    } else {
      AppLogger.debug('Retrieved token: null');
    }
    return token;
  }

  static Future<void> setToken(String token) async {
    if (token == 'null') {
      AppLogger.error('Attempted to save "null" string as token - REJECTED');
      return;
    }

    _cachedToken = token;
    final prefs = await SharedPreferences.getInstance();
    AppLogger.debug(
        'Setting token: ${token.isNotEmpty ? "Bearer ${token.substring(0, 10)}..." : "empty"}');

    final success = await prefs.setString(_tokenKey, token);

    // Explicit sync/verification for web environments
    final verifyToken = prefs.getString(_tokenKey);
    AppLogger.debug(
        'Token storage write success: $success, verified: ${verifyToken == token}');
  }

  static Future<void> clearToken() async {
    _cachedToken = null;
    final prefs = await SharedPreferences.getInstance();
    AppLogger.debug('Clearing token');
    await prefs.remove(_tokenKey);
  }

  static Future<String?> getRole() async {
    if (_cachedRole != null) return _cachedRole;

    final prefs = await SharedPreferences.getInstance();
    _cachedRole = prefs.getString(_roleKey);
    AppLogger.debug('Retrieved role: $_cachedRole');
    return _cachedRole;
  }

  static Future<void> setRole(String role) async {
    _cachedRole = role;
    final prefs = await SharedPreferences.getInstance();
    AppLogger.debug('Setting role: $role');
    await prefs.setString(_roleKey, role);
  }

  static Future<void> clearRole() async {
    _cachedRole = null;
    final prefs = await SharedPreferences.getInstance();
    AppLogger.debug('Clearing role');
    await prefs.remove(_roleKey);
  }
}
