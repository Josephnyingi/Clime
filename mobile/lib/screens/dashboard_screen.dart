import 'package:flutter/material.dart';
import '../services/weather_services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ Added for location & theme sync

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
  bool isError = false;

  String selectedLocation = "Machakos"; // ✅ Default location
  bool isDarkMode = false; // ✅ Track dark mode state

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _fetchWeather();
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
      });
    } catch (e) {
      print("Error fetching current weather: $e");
      setState(() => isError = true);
    }
  }

  Future<void> _fetchForecast() async {
    try {
      List<Map<String, dynamic>> weatherData = [];
      forecastDates.clear();
      DateTime startDate = DateTime.now();
      DateTime endDate = DateTime.now().add(const Duration(days: 7));

      for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
        final date = startDate.add(Duration(days: i));
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
        tempSpots = weatherData.map((entry) {
          return FlSpot(entry["day"], entry["temperature"].toDouble());
        }).toList();

        rainBars = weatherData.map((entry) {
          return BarChartGroupData(
            x: entry["day"].toInt(),
            barRods: [
              BarChartRodData(
                toY: entry["rain"].toDouble(),
                width: 8,
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      print("Error fetching forecast: $e");
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  Widget _buildComboChart() {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          // Rainfall Bar Chart
          BarChart(
            BarChartData(
              barGroups: rainBars,
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      return index < forecastDates.length
                          ? Text(forecastDates[index], style: const TextStyle(fontSize: 12))
                          : const Text("");
                    },
                  ),
                ),
              ),
            ),
          ),
          // Temperature Line Chart
          LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: tempSpots,
                  isCurved: true,
                  color: Colors.redAccent,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  belowBarData: BarAreaData(
                      show: true, color: Colors.redAccent.withOpacity(0.3)),
                ),
              ],
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weather Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black, // ✅ Adjusted for visibility
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
                    FadeInDown(
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        color: Colors.white.withOpacity(0.9),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                "Current Weather in $selectedLocation", // ✅ Dynamically updates
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.black87, // ✅ Adjusted for visibility
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
                    ),
                    const SizedBox(height: 15),
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      color: Colors.white.withOpacity(0.9),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text("Weather Trends", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            _buildComboChart(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
