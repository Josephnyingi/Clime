import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  bool isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(AngaApp(isLoggedIn: isLoggedIn, initialTheme: isDarkMode));
}

class AngaApp extends StatefulWidget {
  final bool isLoggedIn;
  final bool initialTheme;

  const AngaApp({super.key, required this.isLoggedIn, required this.initialTheme});

  @override
  AngaAppState createState() => AngaAppState();
}

class AngaAppState extends State<AngaApp> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.initialTheme;
  }

  /// ✅ **Toggle Theme and Save to SharedPreferences**
  Future<void> _setTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        isDarkMode = value;
      });
    }
    await prefs.setBool('isDarkMode', value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anga Weather App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: widget.isLoggedIn ? '/dashboard' : '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/dashboard': (context) => MainScreen(setTheme: _setTheme),
        '/alerts': (context) => const AlertsScreen(),
        '/settings': (context) => SettingsScreen(setTheme: _setTheme),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final Future<void> Function(bool) setTheme;

  const MainScreen({super.key, required this.setTheme});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;
  final GlobalKey<DashboardScreenState> _dashboardKey = GlobalKey(); // ✅ Fix: Key for Dashboard Refresh

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(key: _dashboardKey), // ✅ Assign Key for Refreshing
      const AlertsScreen(),
      SettingsScreen(setTheme: widget.setTheme),
    ];
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  /// ✅ **Logout Function (Clears Session & Navigates to Login)**
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false); // ✅ Mark as logged out
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  /// ✅ **Refresh Function (Fetches Updated Weather Data)**
  void _fetchWeatherUpdate() {
    if (_selectedIndex == 0) {
      _dashboardKey.currentState?.fetchWeather(); // ✅ Calls `fetchWeather()` in Dashboard
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Weather data refreshed!"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
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

      /// ✅ **Floating Action Buttons (Refresh & Logout)**
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _fetchWeatherUpdate, // ✅ Calls Refresh Function
            backgroundColor: Colors.blueAccent,
            child: const Icon(Icons.refresh, size: 28),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: _logout, // ✅ Logout Button
            backgroundColor: Colors.redAccent,
            child: const Icon(Icons.logout, size: 28),
          ),
        ],
      ),
    );
  }
}
