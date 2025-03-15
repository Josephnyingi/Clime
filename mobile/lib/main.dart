import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const AngaApp());
}

class AngaApp extends StatefulWidget {
  const AngaApp({super.key});

  @override
  AngaAppState createState() => AngaAppState();
}

class AngaAppState extends State<AngaApp> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  /// ✅ **Load Theme Preference**
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  /// ✅ **Toggle Theme and Save to SharedPreferences**
  Future<void> _setTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = value;
    });
    await prefs.setBool('isDarkMode', value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anga Weather App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light, // ✅ Theme Mode Fix
      home: LoginScreen(), // ✅ Use LoginScreen if not authenticated
      routes: {
        '/dashboard': (context) => MainScreen(setTheme: _setTheme), // ✅ Fix type issue
        '/alerts': (context) => const AlertsScreen(),
        '/settings': (context) => SettingsScreen(setTheme: _setTheme), // ✅ Fix type issue
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final Future<void> Function(bool) setTheme; // ✅ Explicitly define type

  const MainScreen({super.key, required this.setTheme});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardScreen(),
      const AlertsScreen(),
      SettingsScreen(setTheme: widget.setTheme), // ✅ Fix type issue
    ];
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack( // ✅ Keeps state when switching tabs
        index: _selectedIndex,
        children: _screens,
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
