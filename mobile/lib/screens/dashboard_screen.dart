import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // ✅ FIX: Added missing import for charts
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/weather_services.dart';
import '../widgets/weather_chart.dart'; // ✅ Modularized chart widget

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  
  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  List<FlSpot> tempSpots = []; // ✅ FIX: FlSpot is correctly recognized
  List<BarChartGroupData> rainBars = []; // ✅ FIX: BarChartGroupData is recognized
  List<String> forecastDates = [];
  Map<String, dynamic> currentWeather = {};
  bool isLoading = true;

  String selectedLocation = "Machakos";
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  /// **✅ Load location & theme settings from SharedPreferences**
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLocation = prefs.getString('location') ?? "Machakos";
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
    _fetchWeather(); // Fetch weather after loading preferences
  }

  Future<void> _fetchWeather() async {
    setState(() => isLoading = true);
    await _fetchCurrentWeather();
    await _fetchForecast();
  }

  Future<void> _fetchCurrentWeather() async {
    try {
      final todayFormatted = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final data = await WeatherService.getWeather(todayFormatted, selectedLocation);

      setState(() {
        currentWeather = data;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching current weather: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchForecast() async {
    try {
      List<Map<String, dynamic>> weatherData = [];
      forecastDates.clear();

      for (int i = 0; i < 7; i++) {
        final date = DateTime.now().add(Duration(days: i));
        final formattedDate = DateFormat('yyyy-MM-dd').format(date);
        var data = await WeatherService.getWeather(formattedDate, selectedLocation);

        forecastDates.add(DateFormat('MM/dd').format(date));
        weatherData.add({
          "day": i.toDouble(),
          "temperature": data['temperature_prediction'],
          "rain": data['rain_prediction'],
        });
      }

      setState(() {
        tempSpots = weatherData.map((entry) => FlSpot(entry["day"], entry["temperature"].toDouble())).toList(); // ✅ FIX: Correct FlSpot usage

        rainBars = weatherData.map((entry) => BarChartGroupData(
          x: entry["day"].toInt(),
          barRods: [
            BarChartRodData( // ✅ FIX: Correct BarChartRodData usage
              toY: entry["rain"].toDouble(),
              width: 8,
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        )).toList();
      });
    } catch (e) {
      print("Error fetching forecast: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weather Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 5,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.pushNamed(context, '/settings');
              _loadPreferences(); // ✅ Reload preferences when returning
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    // ✅ **Current Weather Section**
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      color: Colors.white.withOpacity(0.9),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              "Current Weather in $selectedLocation",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Temperature: ${currentWeather['temperature_prediction']}°C",
                              style: const TextStyle(fontSize: 18, color: Colors.redAccent),
                            ),
                            Text(
                              "Rainfall: ${currentWeather['rain_prediction']} mm",
                              style: const TextStyle(fontSize: 18, color: Colors.blueAccent),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ✅ **Weather Graph**
                    WeatherChart(
                      tempSpots: tempSpots,
                      rainBars: rainBars,
                      forecastDates: forecastDates,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
