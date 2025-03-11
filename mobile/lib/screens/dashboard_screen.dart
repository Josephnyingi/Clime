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
  final String location = "Machakos";

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      List<Map<String, dynamic>> weatherData = [];
      forecastDates.clear();
      DateTime today = DateTime.now();
      final todayFormatted = DateFormat('yyyy-MM-dd').format(today);
      currentWeather = await WeatherService.getWeather(todayFormatted, location);

      for (int i = 0; i < 16; i++) {
        final date = today.add(Duration(days: i));
        final formattedDate = DateFormat('yyyy-MM-dd').format(date);
        var data = await WeatherService.getWeather(formattedDate, location);

        forecastDates.add(DateFormat('MM/dd').format(date));
        weatherData.add({
          "day": i,
          "temperature": data['temperature_prediction'],
          "rain": data['rain_prediction'],
        });
      }

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
                width: 10,
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(6),
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
      appBar: AppBar(
        title: Text('16-Day Weather Forecast', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        elevation: 5,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
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
                              Text("Current Weather in $location",
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                              SizedBox(height: 10),
                              Text(
                                "Temperature: ${currentWeather['temperature_prediction']}°C",
                                style: TextStyle(fontSize: 18, color: Colors.redAccent.shade200),
                              ),
                              Text(
                                "Rainfall: ${currentWeather['rain_prediction']} mm",
                                style: TextStyle(fontSize: 18, color: Colors.blueAccent),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Date: ${DateFormat('EEEE, MMM d, yyyy').format(DateTime.now())}",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    FadeInLeft(
                      child: Text(
                        "Weather Predictions (Next 16 Days)",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      color: Colors.white.withOpacity(0.9),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text("Temperature Trends", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            Container(
                              height: 250,
                              child: LineChart(
                                LineChartData(
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: tempSpots,
                                      isCurved: true,
                                      gradient: LinearGradient(
                                        colors: [Colors.redAccent.shade200, Colors.orange.shade300],
                                      ),
                                      barWidth: 3,
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          colors: [Colors.redAccent.shade100.withOpacity(0.3), Colors.orange.shade100.withOpacity(0.3)],
                                        ),
                                      ),
                                    ),
                                  ],
                                  borderData: FlBorderData(show: false),
                                  titlesData: FlTitlesData(show: false),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      color: Colors.white.withOpacity(0.9),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text("Rainfall Forecast", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            Container(
                              height: 250,
                              child: BarChart(
                                BarChartData(
                                  barGroups: rainBars,
                                  gridData: FlGridData(show: false),
                                  borderData: FlBorderData(show: false),
                                  titlesData: FlTitlesData(
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
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      color: Colors.redAccent.withOpacity(0.8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.warning, color: Colors.white, size: 30),
                            SizedBox(width: 10),
                            Text("Extreme Weather Alerts", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
