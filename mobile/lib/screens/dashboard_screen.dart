import 'package:flutter/material.dart';
import '../services/weather_services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<FlSpot> tempSpots = [];
  List<BarChartGroupData> rainBars = [];
  Map<String, dynamic> currentWeather = {};
  List<String> forecastDates = [];
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      List<Map<String, dynamic>> weatherData = [];
      forecastDates.clear();

      // Fetch current weather
      final today = DateTime.now();
      final todayFormatted = DateFormat('yyyy-MM-dd').format(today);
      currentWeather = await WeatherService.getWeather(todayFormatted, "Machakos");

      // Fetching weather for the next 16 days
      for (int i = 0; i < 16; i++) {
        final date = today.add(Duration(days: i));
        final formattedDate = DateFormat('yyyy-MM-dd').format(date);
        var data = await WeatherService.getWeather(formattedDate, "Machakos");

        forecastDates.add(DateFormat('MM/dd').format(date));
        weatherData.add({
          "day": i,
          "temperature": data['temperature_prediction'],
          "rain": data['rain_prediction'],
        });
      }

      // Convert weather data into graph points
      setState(() {
        tempSpots = weatherData.map((entry) {
          return FlSpot(entry["day"].toDouble(), entry["temperature"].toDouble());
        }).toList();

        rainBars = weatherData.map((entry) {
          return BarChartGroupData(
            x: entry["day"],
            barRods: [
              BarChartRodData(
                toY: entry["rain"].toDouble(),
                width: 12,
                color: Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      print("Error fetching weather data: $e");
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weather Forecast Dashboard')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : isError
              ? Center(child: Text("Failed to load data, please try again later."))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      FadeInDown(
                        child: Column(
                          children: [
                            Text(
                              "Current Weather in Machakos",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Temperature: ${currentWeather['temperature_prediction']}°C",
                              style: TextStyle(fontSize: 18, color: Colors.redAccent, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "Rainfall: ${currentWeather['rain_prediction']} mm",
                              style: TextStyle(fontSize: 18, color: Colors.blueAccent, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      FadeInLeft(
                        child: Text(
                          "Weather Predictions (Next 16 Days)",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: BarChart(
                            BarChartData(
                              barGroups: rainBars,
                              gridData: FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 4),
                                        child: Text(value.toInt().toString(),
                                            style: TextStyle(fontSize: 12)),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      return Text(forecastDates[value.toInt()],
                                          style: TextStyle(fontSize: 12));
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: LineChart(
                            LineChartData(
                              titlesData: FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: tempSpots,
                                  isCurved: true,
                                  gradient: LinearGradient(
                                    colors: [Colors.red, Colors.orange],
                                  ),
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.circle, color: Colors.blue, size: 12),
                            SizedBox(width: 5),
                            Text("Rain (mm)"),
                            SizedBox(width: 15),
                            Icon(Icons.circle, color: Colors.red, size: 12),
                            SizedBox(width: 5),
                            Text("Temperature (°C)"),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }
}
