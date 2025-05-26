import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/helpers.dart'; // ✅ Import Helpers


class WeatherService {
  static const String baseUrl = 'http://localhost:8000'; // 🧠 Change to ngrok when testing on device/emulator

  // 🌦️ Predict endpoint
  static Future<Map<String, dynamic>> getWeather(String date, String location) async {
    final url = Uri.parse('$baseUrl/predict/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"date": date, "location": location}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  // ☀️ Live weather endpoint
  static Future<Map<String, dynamic>> getLiveWeather(String location) async {
    final url = Uri.parse('$baseUrl/live_weather?location=${location.toLowerCase()}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load live weather');
    }
  }
}
