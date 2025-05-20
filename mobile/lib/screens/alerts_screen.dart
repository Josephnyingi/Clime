import 'package:flutter/material.dart';
import '../utils/constants.dart';   // For colors and alert types
import '../utils/app_state.dart';   // ✅ In-memory state

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  AlertsScreenState createState() => AlertsScreenState();
}

class AlertsScreenState extends State<AlertsScreen> {
  /// Sample alerts (🔔 replace with API fetch logic later)
  final List<Map<String, String>> alerts = [
    {"type": "Heatwave", "location": "Nairobi", "severity": "Extreme Heat", "date": "2025-03-15"},
    {"type": "Heavy Rainfall", "location": "Machakos", "severity": "Flood Risk", "date": "2025-03-16"},
    {"type": "Storm Warning", "location": "Mombasa", "severity": "Strong Winds", "date": "2025-03-17"},
  ];

  /// Get color based on alert severity
  Color _getAlertColor(String severity) {
    switch (severity) {
      case "Extreme Heat":
        return alertHeatwaveColor;
      case "Flood Risk":
        return alertFloodColor;
      case "Strong Winds":
        return alertStormColor;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Alerts', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// 🔔 Alert Notifications Toggle (stored in AppState)
            SwitchListTile(
              title: const Text("Enable Alert Notifications"),
              subtitle: const Text("Get real-time severe weather alerts"),
              value: AppState.enableExtremeAlerts,
              onChanged: (value) {
                setState(() {
                  AppState.enableExtremeAlerts = value;
                });
              },
            ),
            const SizedBox(height: 10),

            /// 🚨 Alert Cards
            Expanded(
              child: alerts.isNotEmpty
                  ? ListView.builder(
                      itemCount: alerts.length,
                      itemBuilder: (context, index) {
                        final alert = alerts[index];
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          color: _getAlertColor(alert["severity"]!),
                          child: ListTile(
                            leading: const Icon(Icons.warning, color: Colors.white, size: 30),
                            title: Text(
                              "${alert["type"]} - ${alert["location"]}",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            subtitle: Text(
                              "${alert["severity"]} | Date: ${alert["date"]}",
                              style: const TextStyle(fontSize: 14, color: Colors.white70),
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        "No weather alerts at the moment",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
