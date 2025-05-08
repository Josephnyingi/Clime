import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LiveWeatherScreen extends StatefulWidget {
  final String location;

  const LiveWeatherScreen({super.key, required this.location});

  @override
  State<LiveWeatherScreen> createState() => _LiveWeatherScreenState();
}

class _LiveWeatherScreenState extends State<LiveWeatherScreen> {
  bool isLoading = true;
  String? error;
  Map<String, dynamic>? weather;

  @override
  void initState() {
    super.initState();
    fetchLiveWeather();
  }

  Future<void> fetchLiveWeather() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final uri = Uri.parse("http://localhost:8000/live_weather?location=${widget.location.toLowerCase()}");

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        setState(() {
          weather = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Failed to fetch weather.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Error: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Weather")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : weather == null
                  ? const Center(child: Text("No data"))
                  : Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Location: ${weather!['location']}", style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 10),
                          Text("Date: ${weather!['date']}"),
                          Text("Temperature Max: ${weather!['temperature_max']}"),
                          Text("Rain Sum: ${weather!['rain_sum']}"),
                        ],
                      ),
                    ),
    );
  }
}