import 'package:flutter/material.dart';

class AlertsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Sample alerts (you can replace these with dynamic data later)
    final List<String> alerts = [
      "Heavy rainfall expected tomorrow",
      "High temperature alert for next week",
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Forecast Alerts')),
      body: ListView.builder(
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.warning, color: Colors.red),
            title: Text(alerts[index]),
          );
        },
      ),
    );
  }
}
