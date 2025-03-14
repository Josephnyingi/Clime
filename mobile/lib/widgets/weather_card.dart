import 'package:flutter/material.dart';

class WeatherCard extends StatelessWidget {
  final String date;
  final double temperature;
  final double rainfall;
  final IconData icon;

  const WeatherCard({
    super.key,
    required this.date,
    required this.temperature,
    required this.rainfall,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.blueAccent),
        title: Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Temp: ${temperature.toStringAsFixed(1)}°C\nRain: ${rainfall.toStringAsFixed(1)} mm"),
      ),
    );
  }
}
