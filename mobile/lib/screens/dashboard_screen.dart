import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/weather_services.dart';
import '../services/live_weather_service.dart';
import '../utils/helpers.dart';
import '../utils/app_state.dart'; // ✅ new global state

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
  Map<String, dynamic> liveWeather = {};
  bool isLoading = true;

  // Track previous settings
  String _prevLocation = AppState.selectedLocation;
  DateTime _prevStartDate = AppState.startDate;
  DateTime _prevEndDate = AppState.endDate;

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForSettingsChange();
    });
  }

  void _checkForSettingsChange() {
    if (_prevLocation != AppState.selectedLocation ||
        _prevStartDate != AppState.startDate ||
        _prevEndDate != AppState.endDate) {
      _prevLocation = AppState.selectedLocation;
      _prevStartDate = AppState.startDate;
      _prevEndDate = AppState.endDate;

      fetchWeather();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🔄 Settings changed. Refreshing data...")),
      );
    }
  }

  Future<void> fetchWeather() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    await _fetchLiveWeather();
    await _fetchCurrentWeather();
    await _fetchForecast();

    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _fetchLiveWeather() async {
    try {
      final data = await LiveWeatherService.getLiveWeather(AppState.selectedLocation.toLowerCase());
      if (mounted) setState(() => liveWeather = data);
    } catch (e) {
      logMessage("❌ Live weather fetch error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠️ Could not load live weather")),
        );
      }
    }
  }

  Future<void> _fetchCurrentWeather() async {
    try {
      final date = formatApiDate(DateTime.now());
      final data = await WeatherService.getWeather(date, AppState.selectedLocation);
      if (mounted) setState(() => currentWeather = data);
    } catch (e) {
      logMessage("❌ Predicted weather fetch error: $e");
    }
  }

  Future<void> _fetchForecast() async {
    try {
      List<Map<String, dynamic>> weatherData = [];
      forecastDates.clear();

      for (DateTime date = AppState.startDate;
          date.isBefore(AppState.endDate.add(const Duration(days: 1)));
          date = date.add(const Duration(days: 1))) {
        final data = await WeatherService.getWeather(formatApiDate(date), AppState.selectedLocation);
        forecastDates.add(DateFormat('d/M').format(date));
        weatherData.add({
          "day": weatherData.length.toDouble(),
          "temperature": data['temperature_prediction'],
          "rain": data['rain_prediction'],
        });
      }

      if (mounted) {
        setState(() {
          tempSpots = weatherData.map((e) => FlSpot(e["day"], e["temperature"])).toList();
          rainBars = weatherData.map((e) => BarChartGroupData(
            x: e["day"].toInt(),
            barRods: [
              BarChartRodData(
                toY: e["rain"],
                width: 10,
                color: Colors.blue,
                borderRadius: BorderRadius.circular(4),
              )
            ]
          )).toList();
        });
      }
    } catch (e) {
      logMessage("❌ Forecast fetch error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          'Weather Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.orangeAccent : Colors.white,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.blueAccent,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchWeather),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ✅ LIVE WEATHER SECTION
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    color: isDarkMode ? Colors.black87 : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Live Weather in ${AppState.selectedLocation}",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87)),
                          const SizedBox(height: 8),
                          Text("📅 Date: ${liveWeather['date'] ?? '--'}"),
                          Text("🌡️ Max Temp: ${liveWeather['temperature_max'] ?? '--'}",
                              style: const TextStyle(fontSize: 16, color: Colors.redAccent)),
                          Text("🌧️ Rainfall: ${liveWeather['rain_sum'] ?? '--'}",
                              style: const TextStyle(fontSize: 16, color: Colors.blueAccent)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🌡️ Temperature Forecast Chart
                  Text("Temperature Forecast", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
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
                            dotData: FlDotData(show: false),
                          )
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            axisNameWidget: const Text("Date"),
                            axisNameSize: 16,
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, _) {
                                int index = value.toInt();
                                if (index >= forecastDates.length) return const SizedBox.shrink();
                                return Text(forecastDates[index], style: const TextStyle(fontSize: 10));
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 🌧️ Rainfall Forecast Chart
                  Text("Rainfall Forecast", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 250,
                    child: BarChart(
                      BarChartData(
                        barGroups: rainBars,
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            axisNameWidget: const Text("Date"),
                            axisNameSize: 16,
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, _) {
                                int index = value.toInt();
                                if (index >= forecastDates.length) return const SizedBox.shrink();
                                return Text(forecastDates[index], style: const TextStyle(fontSize: 10));
                              },
                            ),
                          ),
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

