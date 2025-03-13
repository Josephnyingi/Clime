import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(AngaApp());
}

class AngaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anga Weather App',
      theme: ThemeData.light(),  
      darkTheme: ThemeData.dark(),  
      themeMode: ThemeMode.light,  // ✅ Removed auto dark mode
      home: LoginScreen(), // ✅ Removed const (dynamic content)
      routes: {
        '/dashboard': (context) => MainScreen(),  // ✅ Removed const
        '/alerts': (context) => AlertsScreen(),   // ✅ Removed const
        '/settings': (context) => SettingsScreen(), // ✅ Removed const
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // **List of screens for navigation**
  final List<Widget> _screens = [
    DashboardScreen(),
    AlertsScreen(),
    SettingsScreen(),
  ];

  // **Tab Switching**
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher( // ✅ Smooth transitions when switching tabs
        duration: const Duration(milliseconds: 300),
        child: _screens[_selectedIndex],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchWeatherUpdate,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.refresh, size: 28),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: "Alerts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }

  void _fetchWeatherUpdate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Fetching latest weather update..."),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
