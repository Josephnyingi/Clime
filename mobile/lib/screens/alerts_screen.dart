import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart'; // ✅ Import Constants

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  AlertsScreenState createState() => AlertsScreenState();
}

class AlertsScreenState extends State<AlertsScreen> {
  bool enableAlerts = true; // ✅ Toggle for notifications

  // ✅ Sample alerts (Replace this with API data)
  final List<Map<String, String>> alerts = [
    {"type": "Heatwave", "location": "Nairobi", "severity": "Extreme Heat", "date": "2025-03-15"},
    {"type": "Heavy Rainfall", "location": "Machakos", "severity": "Flood Risk", "date": "2025-03-16"},
    {"type": "Storm Warning", "location": "Mombasa", "severity": "Strong Winds", "date": "2025-03-17"},
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  /// **🔹 Load user preferences (Toggle state)**
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      enableAlerts = prefs.getBool(prefKeyEnableAlerts) ?? true;
    });
  }

  /// **🔹 Save toggle state**
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefKeyEnableAlerts, enableAlerts);
  }

  /// **🔹 Get alert color based on severity**
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
            // **🔔 Toggle for Push Notifications**
            SwitchListTile(
              title: const Text("Enable Alert Notifications"),
              subtitle: const Text("Get real-time severe weather alerts"),
              value: enableAlerts,
              onChanged: (value) {
                setState(() {
                  enableAlerts = value;
                });
                _savePreferences();
              },
            ),
            const SizedBox(height: 10),

            // **🚨 Alert List**
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
