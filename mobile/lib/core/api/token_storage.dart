import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

class TokenStorage {
  static const _tokenKey = 'token';
  static const _roleKey = 'role';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    AppLogger.debug(
        'Retrieved token: ${token != null ? "Bearer ${token.substring(0, 10)}..." : "null"}');
    return token;
  }

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    AppLogger.debug(
        'Setting token: ${token.isNotEmpty ? "Bearer ${token.substring(0, 10)}..." : "empty"}');
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    AppLogger.debug('Clearing token');
    await prefs.remove(_tokenKey);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString(_roleKey);
    AppLogger.debug('Retrieved role: $role');
    return role;
  }

  static Future<void> setRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    AppLogger.debug('Setting role: $role');
    await prefs.setString(_roleKey, role);
  }

  static Future<void> clearRole() async {
    final prefs = await SharedPreferences.getInstance();
    AppLogger.debug('Clearing role');
    await prefs.remove(_roleKey);
  }
}
