import 'package:flutter/material.dart';
import '../services/weather_services.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<FlSpot> tempSpots = [];
  List<BarChartGroupData> rainBars = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      List<Map<String, dynamic>> weatherData = [];

      // Fetching weather for the next 16 days
      for (int i = 0; i < 16; i++) {
        final date = DateTime.now().add(Duration(days: i)).toIso8601String().split('T')[0];
        var data = await WeatherService.getWeather(date, "Machakos");

        weatherData.add({
          "day": i + 1,
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('16-day Weather Forecast')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    "16-day forecast Temperature and Rainfall",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                                  return Text(value.toInt().toString(),
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
                                colors: [Colors.red, Colors.orange], // ✅ Temperature gradient
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

