import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/settings_screen.dart'; // ✅ Imported SettingsScreen
import 'theme.dart';

void main() {
  runApp(AngaApp());
}

class AngaApp extends StatelessWidget {
  const AngaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anga Weather',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/alerts': (context) => AlertsScreen(),
        '/settings': (context) => SettingsScreen(), // ✅ Corrected reference
      },
    );
  }
}

