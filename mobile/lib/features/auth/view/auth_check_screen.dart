import 'package:flutter/material.dart';
import 'package:export_trix/core/utils/logger.dart';
import 'package:export_trix/core/api/token_storage.dart';
import 'package:export_trix/features/auth/view/login_screen.dart';
import 'package:export_trix/features/rider/view/rider_dashboard_screen.dart';

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    AppLogger.debug('AuthCheckScreen: Starting _checkAuthStatus');
    try {
      final token = await TokenStorage.getToken();
      AppLogger.debug(
          'AuthCheckScreen: Token: ${token != null ? "exists" : "null"}');

      setState(() {
        _isAuthenticated = token != null && token.isNotEmpty;
        _isLoading = false;
      });
      AppLogger.debug('AuthCheckScreen: State updated, loading finished');
    } catch (e) {
      AppLogger.error('AuthCheckScreen: Error in _checkAuthStatus', e);
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _isAuthenticated
        ? const RiderDashboardScreen()
        : const LoginScreen();
  }
}
