import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LiveWeatherScreen extends StatefulWidget {
  const LiveWeatherScreen({super.key});

  @override
  State<LiveWeatherScreen> createState() => _LiveWeatherScreenState();
}

class _LiveWeatherScreenState extends State<LiveWeatherScreen> {
  bool isLoading = true;
  String? error;
  String? location;
  String? date;
  double? temperature; // store as number
  double? rain;        // store as number

  @override
  void initState() {
    super.initState();
    _fetchLiveWeather();
  }

  Future<void> _fetchLiveWeather() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedLocation = prefs.getString('location')?.toLowerCase() ?? 'machakos';

    if (!['machakos', 'vhembe'].contains(selectedLocation)) {
      setState(() {
        isLoading = false;
        error = "Live weather not available for '$selectedLocation'.";
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/live_weather?location=$selectedLocation'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          isLoading = false;
          location = data['location'];
          date = data['date'];
          temperature = (data['temperature_max'] as num).toDouble();
          rain = (data['rain_sum'] as num).toDouble();
        });
      } else {
        setState(() {
          isLoading = false;
          error = 'Failed to fetch live weather.';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        error = 'Error fetching data. Check connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Weather"),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("📍 Live Weather in ${location ?? '--'}",
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text("Date: ${date ?? '--'}", style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 8),
                          Text("🌡️ Max Temp: ${temperature?.toStringAsFixed(1) ?? '--'} °C",
                              style: const TextStyle(fontSize: 18, color: Colors.redAccent)),
                          const SizedBox(height: 8),
                          Text("🌧️ Rainfall: ${rain?.toStringAsFixed(1) ?? '--'} mm",
                              style: const TextStyle(fontSize: 18, color: Colors.blueAccent)),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
