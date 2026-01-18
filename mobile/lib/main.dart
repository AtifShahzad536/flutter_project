import 'package:flutter/material.dart';
import 'package:export_trix/core/utils/logger.dart';
import 'app.dart';

void main() {
  AppLogger.debug('main.dart: Entered main');
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.debug('main.dart: Flutter binding initialized');
  runApp(const ExportTrixApp());
  AppLogger.debug('main.dart: runApp called');
}
