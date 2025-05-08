import 'dart:convert';
import 'package:http/http.dart' as http;

class LiveWeatherService {
  static const String baseUrl = 'http://localhost:8000/live_weather/';

  static Future<Map<String, dynamic>> getLiveWeather(String location) async {
    final url = Uri.parse('$baseUrl?location=$location');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return decoded;
    } else {
      throw Exception("Failed to fetch live weather");
    }
  }
}
