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
  List<String> forecastDates = [];
  Map<String, dynamic> currentWeather = {};
  bool isLoading = true;
  bool isError = false;

  String selectedLocation = "Machakos";
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(days: 7));

  @override
  void initState() {
    super.initState();
    _fetchWeather();
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

  void _selectLocation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Location"),
        content: DropdownButton<String>(
          value: selectedLocation,
          onChanged: (newValue) {
            setState(() {
              selectedLocation = newValue!;
            });
            _fetchWeather();
            Navigator.pop(context);
          },
          items: ["Machakos", "Nairobi", "Mombasa", "Kisumu"].map((location) {
            return DropdownMenuItem(
              value: location,
              child: Text(location),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      _fetchForecast();
    }
  }

  Widget _buildComboChart() {
    return Container(
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
                          ? Text(forecastDates[index], style: TextStyle(fontSize: 12))
                          : Text("");
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
        title: Text('Weather Dashboard'),
        backgroundColor: Colors.blueAccent,
        elevation: 5,
        actions: [
          IconButton(
            icon: Icon(Icons.location_on),
            onPressed: _selectLocation,
          ),
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: _selectDateRange,
          ),
        ],
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
                              Text("Current Weather in $selectedLocation",
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                              SizedBox(height: 10),
                              Text(
                                "Temperature: ${currentWeather['temperature_prediction']}°C",
                                style: TextStyle(fontSize: 18, color: Colors.redAccent),
                              ),
                              Text(
                                "Rainfall: ${currentWeather['rain_prediction']} mm",
                                style: TextStyle(fontSize: 18, color: Colors.blueAccent),
                              ),
                            ],
                          ),
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
                            Text("Weather Trends", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
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
