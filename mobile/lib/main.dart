import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/alerts_screen.dart';

void main() {
  runApp(AngaApp());
}

class AngaApp extends StatelessWidget {
  const AngaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anga Weather',
      theme: ThemeData(primarySwatch: Colors.blue),
      // The first screen that will load
      initialRoute: '/',
      // Define routes for navigation
      routes: {
        '/': (context) => LoginScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/alerts': (context) => AlertsScreen(),
      },
    );
  }
}
