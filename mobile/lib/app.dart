import 'package:flutter/material.dart';
import 'core/utils/logger.dart';
import 'features/auth/view/auth_check_screen.dart';
import 'features/auth/view/login_screen.dart';
import 'features/rider/view/rider_dashboard_screen.dart';

class ExportTrixApp extends StatelessWidget {
  const ExportTrixApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.debug('Building ExportTrixApp');
    return MaterialApp(
      title: 'Export Trix',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthCheckScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const RiderDashboardScreen(),
      },
    );
  }
}
