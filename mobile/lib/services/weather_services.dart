import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _apiUrl = "http://127.0.0.1:8000/predict/";

  static Future<Map<String, dynamic>> getWeather(String date, String location) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"date": date, "location": location}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch weather data');
      }
    } catch (e) {
      print("Error fetching weather data: $e");
      return {"temperature_prediction": 0.0, "rain_prediction": 0.0}; // Return default values in case of error
    }
  }
}


