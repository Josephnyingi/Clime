import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeatherChart extends StatelessWidget {
  final List<FlSpot> tempSpots;
  final List<BarChartGroupData> rainBars;
  final List<String> forecastDates;

  const WeatherChart({
    super.key,
    required this.tempSpots,
    required this.rainBars,
    required this.forecastDates,
  });

  @override
  Widget build(BuildContext context) {
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
                  sideTitles: SideTitles(showTitles: false), // Hide left Y-axis
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
                  sideTitles: SideTitles(showTitles: false), // Hide left Y-axis
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
