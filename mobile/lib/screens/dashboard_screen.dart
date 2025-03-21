import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/weather_services.dart';
import '../utils/helpers.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  List<FlSpot> tempSpots = [];
  List<BarChartGroupData> rainBars = [];
  List<String> forecastDates = [];
  Map<String, dynamic> currentWeather = {};
  bool isLoading = true;
  bool isDarkMode = false;
  String selectedLocation = "Machakos";
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  /// **🔹 Load User Preferences (Location, Theme, Date Range)**
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        selectedLocation = prefs.getString('location') ?? "Machakos";
        isDarkMode = prefs.getBool('isDarkMode') ?? false;
        startDate = DateTime.tryParse(prefs.getString('startDate') ?? '') ?? DateTime.now().subtract(const Duration(days: 6));
        endDate = DateTime.tryParse(prefs.getString('endDate') ?? '') ?? DateTime.now();
      });
    }
    fetchWeather();
  }

  /// **🔹 Fetch Weather Data**
  Future<void> fetchWeather() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    await _fetchCurrentWeather();
    await _fetchForecast();
  }

  /// **🔹 Fetch Current Weather**
  Future<void> _fetchCurrentWeather() async {
    try {
      final formattedDate = formatApiDate(DateTime.now());
      final data = await WeatherService.getWeather(formattedDate, selectedLocation);

      if (mounted) {
        setState(() {
          currentWeather = data;
        });
      }
    } catch (e) {
      logMessage("Error fetching current weather: $e");
    }
  }

  /// **🔹 Fetch Forecast Data Based on Selected Date Range**
  Future<void> _fetchForecast() async {
    try {
      List<Map<String, dynamic>> weatherData = [];
      forecastDates.clear();

      for (DateTime date = startDate!; date.isBefore(endDate!.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
        var data = await WeatherService.getWeather(formatApiDate(date), selectedLocation);

        forecastDates.add(DateFormat('dd').format(date)); // Only show day
        weatherData.add({
          "day": date.day.toDouble(),
          "temperature": data['temperature_prediction'],
          "rain": data['rain_prediction'],
        });
      }

      if (mounted) {
        setState(() {
          tempSpots = weatherData
              .map((entry) => FlSpot(entry["day"], entry["temperature"].toDouble()))
              .toList();

          rainBars = weatherData
              .map((entry) => BarChartGroupData(
                    x: entry["day"].toInt(),
                    barRods: [
                      BarChartRodData(
                        toY: entry["rain"].toDouble(),
                        width: 10,
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ))
              .toList();
        });
      }
    } catch (e) {
      logMessage("Error fetching forecast: $e");
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          'Weather Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.orangeAccent : Colors.black,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.blueAccent,
        elevation: 5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchWeather,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  // ✅ **Current Weather Section**
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    color: isDarkMode ? Colors.black87 : Colors.white,
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

                  const SizedBox(height: 20),

                  // ✅ **Temperature Line Chart**
                  Text(
                    "Temperature Forecast",
                    style: TextStyle(
                      color: isDarkMode ? Colors.orangeAccent : Colors.blueAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 250,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: tempSpots,
                            isCurved: true,
                            color: Colors.redAccent,
                            barWidth: 2.5,
                            belowBarData: BarAreaData(show: false),
                            dotData: FlDotData(show: true),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false), // Hides left axis
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 20,
                              interval: 1, // Ensures only whole numbers (days)
                              getTitlesWidget: (value, meta) {
                                return Text(value.toInt().toString()); // Converts to whole number
                              },
                            ),
                          ),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hides top X axis
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ✅ **Rainfall Bar Chart**
                  Text(
                    "Rainfall Forecast",
                    style: TextStyle(
                      color: isDarkMode ? Colors.orangeAccent : Colors.blueAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 250,
                    child: BarChart(
                      BarChartData(
                        barGroups: rainBars,
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false), // Hides left axis
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 20,
                              interval: 1, // Ensures whole numbers for days
                            ),
                          ),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hides top X axis
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
